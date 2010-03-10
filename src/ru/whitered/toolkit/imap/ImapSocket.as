package ru.whitered.toolkit.imap 
{
	import ru.whitered.toolkit.imap.commands.ImapBaseCommand;

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

		
		
		
		
		public function ImapSocket(server:String, port:int) 
		{
			super(server, port);
			addEventListener(ProgressEvent.SOCKET_DATA, handleSocketData);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSocketError); 
			addEventListener(IOErrorEvent.IO_ERROR, handleSocketError);
			
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
								break;
						}
					}
				}
			}
			
			if(commandBody.length > 0) buffer = commandBody + buffer;
			literalBytes = 0;
		}

		
		
		public function sendCommand(command:ImapBaseCommand):void
		{
			const id:String = "CMD" + ++lastID;
			commands[id] = command;
			currentCommand = command;
			writeUTFBytes(id + " " + command.getCommand() + NEWLINE);
			flush();
		}
	}
}