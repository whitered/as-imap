package ru.whitered.toolkit.imapSocket 
{
	import ru.whitered.toolkit.imapSocket.commands.ImapBaseCommand;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 * @author whitered
	 */
	public class ImapSocket extends Socket
	{
		public static const NEWLINE:String = "\r\n";

		
		private var buffer:String = "";
		private var lastID:uint = 0;

		private const commands:Dictionary = new Dictionary();
		private var currentCommand:ImapBaseCommand;
		private var literalBytes:int = 0;
		private var queue:Vector.<ImapBaseCommand>;
		
		private var host:String;
		private var port:int;

		
		
		
		
		public function ImapSocket(host:String, port:int) 
		{
			this.port = port;
			this.host = host;
			super(host, port);
			addEventListener(ProgressEvent.SOCKET_DATA, handleSocketData);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSocketError); 
			addEventListener(IOErrorEvent.IO_ERROR, handleSocketError);
			addEventListener(Event.CONNECT, handleConnect);
		}



		private function handleConnect(event:Event) : void
		{
			sendNextCommand();
		}



		private function handleSocketError(event:ErrorEvent):void 
		{
			trace(this, "Socket error:", event);
		}

		
		
		private function handleSocketData(event:Event):void 
		{
			const message:String = readUTFBytes(bytesAvailable);
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
								if(continuation)
								{
									writeUTFBytes(continuation + NEWLINE);
									flush();
								}
								
								commandBody = "";
								break;
								
							default:
								var command:ImapBaseCommand = commands[prefix];
								var body:String = commandBody;
								currentCommand = null;
								delete commands[prefix];
								commandBody = "";
								command.processResult(body);
								
								sendNextCommand();
								break;
						}
					}
				}
			}
			
			if(commandBody.length > 0) buffer = commandBody + buffer;
			literalBytes = 0;
		}
		
		
		
		private function sendNextCommand():void
		{
			if(queue)
			{
				const nextCommand:ImapBaseCommand = queue.shift();
				if(queue.length == 0) queue = null;
				sendCommand(nextCommand);
			}
		}

		
		
		public function sendCommand(command:ImapBaseCommand):void
		{
			if(!connected) connect(host, port);
			
			if(!connected || currentCommand)
			{
				queue ||= new Vector.<ImapBaseCommand>();
				queue.push(command);
				return;
			}
			
			const id:String = "CMD" + ++lastID;
			commands[id] = command;
			currentCommand = command;
			writeUTFBytes(id + " " + command.getCommand() + NEWLINE);
			flush();
		}
	}
}
