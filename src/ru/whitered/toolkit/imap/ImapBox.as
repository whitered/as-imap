package ru.whitered.toolkit.imap 
{
	import ru.whitered.toolkit.imap.commands.ImapStoreCommand;

	import flash.utils.ByteArray;
	import ru.whitered.toolkit.imap.commands.ImapAppendCommand;
	import ru.whitered.toolkit.imap.commands.ImapLogoutCommand;
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;
	import ru.whitered.toolkit.imap.commands.IImapCommand;
	import ru.whitered.toolkit.imap.commands.ImapFetchCommand;
	import ru.whitered.toolkit.imap.commands.ImapListCommand;
	import ru.whitered.toolkit.imap.commands.ImapLoginCommand;
	import ru.whitered.toolkit.imap.commands.ImapSelectCommand;
	import ru.whitered.toolkit.imap.data.MailMessage;
	import ru.whitered.toolkit.imap.data.Mailbox;
	import ru.whitered.toolkit.imap.socket.ISocket;

	import flash.events.ErrorEvent;
	import flash.utils.Dictionary;

	/**
	 * @author whitered
	 */
	public class ImapBox 
	{
		public static const NEWLINE:String = "\r\n";
		
		
		
		public const onConnect			:Signal = new Signal();
		public const onDisconnect		:Signal = new Signal();
		
		public const onLoginSuccess	:Signal = new Signal();
		
		public const onLogoutSuccess	:Signal = new Signal();
		
		public const onSelectSuccess	:Signal = new Signal();
		public const onSelectFailure	:Signal = new Signal();
		
		public const onFetchSuccess	:Signal = new Signal();
		public const onFetchFailure	:Signal = new Signal();
		
		public const onAppendSuccess	:Signal = new Signal();
		public const onAppendFailure	:Signal = new Signal();
		
		public const onStoreSuccess	:Signal = new Signal();
		public const onStoreFailure	:Signal = new Signal();
		

		
		private var socket:ISocket;
		private var buffer:String = "";
		private var lastID:uint = 0;
		
		private const commands:Dictionary = new Dictionary();
		private var currentCommand:IImapCommand;
		private var literalBytes:int = 0;
		
		
		private var selectedMailbox:Mailbox;

		
		
		public function ImapBox(socket:ISocket) 
		{
			this.socket = socket;
			socket.onConnect.addCallback(handleSocketConnect);
			socket.onDisconnect.addCallback(handleSocketDisconnect);
			socket.onError.addCallback(handleSocketError);
			socket.onData.addCallback(handleSocketData);
		}

		
		
		private function handleSocketConnect():void 
		{
			onConnect.dispatch();
		}

		
		
		private function handleSocketDisconnect():void 
		{
			onDisconnect.dispatch();
		}

		
		
		private function handleSocketError(event:ErrorEvent):void 
		{
			Logger.debug(this, "Socket error:", event);
		}

		
		
		private function handleSocketData( message:String ):void 
		{
			Logger.debug(this, "socketData:", message);
			buffer += message;
			
			var commandBody:String = "";
			var lineLength:int;
			while(buffer.length > 0)
			{
				lineLength = buffer.indexOf(NEWLINE) + 2;
				if(lineLength < 2)
				{
					buffer = commandBody + buffer;
					return;
				}
				else
				{
					var line:String = buffer.substr(0, lineLength);
					buffer = buffer.substr(lineLength);
					commandBody += line;
					
					if(literalBytes > 0)
					{
						var ba:ByteArray = new ByteArray();
						ba.writeUTFBytes(line);
						literalBytes -= ba.length; 
					}
					else
					{
						var prefix:String = Vector.<String>(line.split(" ", 2))[0];
						switch(prefix)
						{
							case ")\r\n":
								break;
								
							case "*":
							case "":
								var md:Array = line.match(/ \{([\d]+)\}\r\n$/);
								literalBytes = md ? int(md[1]) : 0;
								break;
								
							case "+":
								var continuation:String = currentCommand.processContinuation(commandBody);
								if(continuation) socket.send(continuation);
								commandBody = "";
								break;
								
							default:
								var command:IImapCommand = commands[prefix];
								var body:String = commandBody;
								currentCommand = null;
								delete commands[prefix];
								commandBody = "";
								command.processResult(body);
								break;
						}
					}
				}
			}
			
			if(commandBody.length > 0) buffer = commandBody + buffer;
			literalBytes = 0;
		}

		
		
		private function sendCommand(command:IImapCommand):void
		{
			const id:String = "CMD" + ++lastID;
			commands[id] = command;
			currentCommand = command;
			socket.send(id + " " + command.getCommand());
		}

		
		
		//----------------------------------------------------------------------
		// login
		//----------------------------------------------------------------------
		public function login( login:String, password:String ):void
		{
			const command:ImapLoginCommand = new ImapLoginCommand(login, password);
			command.onSuccess.addCallback(handleLoginSuccess);
			sendCommand(command);
		}

		
		
		private function handleLoginSuccess():void 
		{
			onLoginSuccess.dispatch();
		}

		
		
		//----------------------------------------------------------------------
		// logout
		//----------------------------------------------------------------------
		public function logout():void
		{
			const command:ImapLogoutCommand = new ImapLogoutCommand();
			command.onSuccess.addCallback(handleLogoutSuccess);
			sendCommand(command); 
		}
		
		
		
		private function handleLogoutSuccess():void
		{
			onLogoutSuccess.dispatch();
		}
		//----------------------------------------------------------------------
		// list
		//----------------------------------------------------------------------
		public function list():void
		{
			const command:ImapListCommand = new ImapListCommand();
			sendCommand(command);
		}

		
		
		//----------------------------------------------------------------------
		// select
		//----------------------------------------------------------------------
		public function select(name:String):void
		{
			const command:ImapSelectCommand = new ImapSelectCommand(name);
			command.onSuccess.addCallback(handleSelectSuccess);
			command.onFailure.addCallback(handleSelectFailure);
			sendCommand(command); 
		}

		
		
		private function handleSelectSuccess(mailbox:Mailbox):void 
		{
			selectedMailbox = mailbox;
			onSelectSuccess.dispatch(mailbox);
		}

		
		
		private function handleSelectFailure(message:String):void 
		{
			selectedMailbox = null;
			onSelectFailure.dispatch(message);
		}
		
		
		
		//----------------------------------------------------------------------
		// fetch
		//----------------------------------------------------------------------
		public function fetchAll():void
		{
			if(!selectedMailbox)
			{
				onFetchFailure.dispatch("No mailbox is selected!");
			}
			else if(selectedMailbox.numMessagesExist == 0)
			{
				handleFetchSuccess(new Vector.<MailMessage>());
			}
			else
			{
				const command:ImapFetchCommand = new ImapFetchCommand(1, selectedMailbox.numMessagesExist);
				command.onSuccess.addCallback(handleFetchSuccess);
				command.onFailure.addCallback(handleFetchFailure);
				sendCommand(command);
			}
		}

		
		
		private function handleFetchSuccess(messages:Vector.<MailMessage>):void 
		{
			selectedMailbox.messages = messages;
			onFetchSuccess.dispatch(messages);
		}

		
		
		private function handleFetchFailure(message:String):void 
		{
			onFetchFailure.dispatch(message);
		}
		
		
		
		//----------------------------------------------------------------------
		// append
		//----------------------------------------------------------------------
		public function append(mailbox:String, message:MailMessage):void
		{
			const command:ImapAppendCommand = new ImapAppendCommand(mailbox, message);
			command.onSuccess.addCallback(handleAppendSuccess);
			command.onFailure.addCallback(handleAppendFailure);
			sendCommand(command);
		}

		
		
		private function handleAppendSuccess(mailbox:String, message:MailMessage):void 
		{
			onAppendSuccess.dispatch(mailbox, message);
		}

		
		
		private function handleAppendFailure(mailbox:String, message:MailMessage, errorMessage:String):void 
		{
			onAppendFailure.dispatch(mailbox, message, errorMessage);
		}
		
		
		//----------------------------------------------------------------------
		// store
		//----------------------------------------------------------------------
		public function store(indexFrom:int, indexTo:int, action:int, flags:Vector.<String>):void
		{
			const command:ImapStoreCommand = new ImapStoreCommand(indexFrom, indexTo, action, flags);
			command.onSuccess.addCallback(handleStoreSuccess);
			command.onFailure.addCallback(handleStoreFailure);
			sendCommand(command);
		}

		
		
		private function handleStoreSuccess():void 
		{
			onStoreSuccess.dispatch();
		}

		
		
		private function handleStoreFailure(errorMessage:String):void 
		{
			onStoreFailure.dispatch(errorMessage);
		}
	}
}
