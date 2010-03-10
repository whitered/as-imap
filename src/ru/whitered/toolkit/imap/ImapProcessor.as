package ru.whitered.toolkit.imap 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;
	import ru.whitered.toolkit.imap.commands.IImapCommand;
	import ru.whitered.toolkit.imap.socket.ISocket;

	import flash.events.ErrorEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 * @author whitered
	 */
	public class ImapProcessor 
	{
		public static const NEWLINE:String = "\r\n";
		
		public const onConnect			:Signal = new Signal();
		public const onDisconnect		:Signal = new Signal();
		
		

		
		private var socket:ISocket;
		private var buffer:String = "";
		private var lastID:uint = 0;
		
		private const commands:Dictionary = new Dictionary();
		private var currentCommand:IImapCommand;
		private var literalBytes:int = 0;
		
		

		
		
		public function ImapProcessor(socket:ISocket) 
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

		
		
		public function sendCommand(command:IImapCommand):void
		{
			const id:String = "CMD" + ++lastID;
			commands[id] = command;
			currentCommand = command;
			socket.send(id + " " + command.getCommand());
		}
	}
}
