package ru.whitered.toolkit.imap 
{
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
		
		
		
		public const onConnect:Signal = new Signal();
		public const onDisconnect:Signal = new Signal();
		
		public const onLoginSuccess:Signal = new Signal();
		
		public const onLogoutSuccess:Signal = new Signal();
		
		public const onSelectSuccess:Signal = new Signal();
		public const onSelectFailure:Signal = new Signal();
		
		public const onFetchSuccess:Signal = new Signal();
		public const onFetchFailure:Signal = new Signal();
		

		
		private var socket:ISocket;
		private var buffer:String = "";
		private var lastID:uint = 0;
		private const commands:Dictionary = new Dictionary();
		
		
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
					Logger.debug(this, "response not complete, rolling back:", buffer);
					buffer = commandBody + buffer;
					return;
				}
				else
				{
					var line:String = buffer.substr(0, lineLength);
					buffer = buffer.substr(lineLength);
					commandBody += line;
					
					//Logger.debug(this, "checking line:", line);
					var words:Vector.<String> = Vector.<String>(line.split(" ", 3));
					if(words.length > 0 && words[0] == "*")
					{
						continue;
					}
					else if(words.length > 1 && (words[1] == "OK" || words[1] == "BAD" || words[1] == "NO"))
					{
						var command:IImapCommand = commands[words[0]];
						if(command)
						{
							//Logger.debug(this, "processing with command:", command, commandBody);
							command.processResponse(commandBody);
							delete commands[words[0]];
						}
						else
						{
							//Logger.debug(this, "processing without command:", message);
							throw message;
						}
						commandBody = "";
					}
				}
			}
			
			if(commandBody.length > 0) buffer = commandBody + buffer;
		}

		
		
		private function sendCommand(command:IImapCommand):void
		{
			const id:String = "CMD" + ++lastID;
			commands[id] = command;
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
	}
}
