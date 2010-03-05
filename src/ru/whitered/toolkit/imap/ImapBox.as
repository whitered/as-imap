package ru.whitered.toolkit.imap 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;
	import ru.whitered.toolkit.imap.commands.IImapCommand;
	import ru.whitered.toolkit.imap.commands.ImapListCommand;
	import ru.whitered.toolkit.imap.commands.ImapLoginCommand;
	import ru.whitered.toolkit.imap.commands.ImapSelectCommand;
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
		public const onLogin:Signal = new Signal();
		
		public const onSelectSuccess:Signal = new Signal();
		public const onSelectFailure:Signal = new Signal();
		

		
		private var socket:ISocket;
		private var buffer:String = "";
		private var lastID:uint = 0;
		private const commands:Dictionary = new Dictionary();

		
		
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
					Logger.debug(this, "response not complete:", buffer);
					throw new Error("Response not complete: " + buffer);
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
					if(words[0] == "*")
					{
						continue;
					}
					else if(words[1] == "OK" || words[1] == "BAD" || words[1] == "NO")
					{
						var command:IImapCommand = commands[words[0]];
						if(command)
						{
							//Logger.debug(this, "processing with command:", command, commandBody);
							command.processResponse(message);
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
			onLogin.dispatch();
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

		
		
		private function handleSelectSuccess(name:String):void 
		{
			onSelectSuccess.dispatch(name);
		}

		
		
		private function handleSelectFailure(message:String):void 
		{
			onSelectFailure.dispatch(message);
		}
	}
}
