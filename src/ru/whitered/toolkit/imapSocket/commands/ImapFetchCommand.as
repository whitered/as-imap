package ru.whitered.toolkit.imapSocket.commands 
{
	import ru.whitered.toolkit.imapSocket.ImapSocket;
	import ru.whitered.toolkit.imapSocket.data.ImapEvent;
	import ru.whitered.toolkit.imapSocket.data.ImapMessage;

	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 * @author whitered
	 */
	public class ImapFetchCommand extends ImapBaseCommand
	{
		
		private var data:String;
		
		
		
		public function ImapFetchCommand(parameters:ImapFetchParameters) 
		{
			super(parameters.toString());
		}

		
		
		override public function processResult(message:String):void
		{
			const lines:Vector.<String> = Vector.<String>(message.split(ImapSocket.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			var event:ImapEvent;
			switch(lastLineWords[1])
			{
				case "OK":
					event = new ImapEvent(ImapEvent.COMMAND_COMPLETE);
					data = message;
					event.messages = parseRoot();
					break;
					
				default:
					event = new ImapEvent(ImapEvent.COMMAND_FAILED);
					event.errorMessage = lastLineWords.slice(2).join(" ");
					break;
			}
			dispatchEvent(event); 
		}

		
		
		private function match(regexp:RegExp):Array
		{
			var md:Array = data.match(regexp);
			if(md)
			{
				data = data.slice(data.indexOf(md[0]) + md[0].length);
				
			}
			return md;
		}
		
		
		
		private function readBytes(num:int):String
		{
			const ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(data);
			ba.position = 0;
			const res:String = ba.readUTFBytes(num);
						ba.position = num;
			data = ba.readUTFBytes(ba.length - num);
			return res;
		}

		
		
		private function parseRoot():Vector.<ImapMessage>
		{
			var word:String;
			var md:Array;
			
			const messages:Vector.<ImapMessage> = new Vector.<ImapMessage>();
			
			while(data.length > 0)
			{
				word = match(/([^\s]+)/)[1];
				
				switch(word)
				{
					case "*":
						md = match(/(\d+) FETCH /);
						messages.push(parseMessage(md[1]));
						break;
						
					default:
						// last line with command status
						return messages;
				}
				
			}
			
			return messages;
		}
		
		
		
		private function parseMessage(id:int):ImapMessage
		{
			const msg:ImapMessage = new ImapMessage();
			msg.id = id;
			
			var md:Array = match(/\(/);
			for(;data.length > 0;)
			{
				md = match(/([^\s]+)/);
				if(md) switch(md[0])
				{
					case "FLAGS":
						md = match(/\(([^\)]*)\)/);
						msg.flags = new Dictionary();
						for each(var txtFlag:String in md[1].split(" "))
						{
							msg.flags[txtFlag.slice(1)] = true;
						}
						break;
						
					case "BODY[TEXT]":
						md = match(/{(\d+)}\r\n/);
						msg.body = readBytes(int(md[1]));
						break;
						
					case "BODY[HEADER.FIELDS":
						md = match(/{(\d+)}\r\n/);
						msg.headers = parseHeaders(readBytes(int(md[1])));
						break;
						
					case ")":
						return msg;
				}
			}
			return msg;
		}

		
		
		private function parseHeaders(str:String):Dictionary 
		{
			const dic:Dictionary = new Dictionary();
			var md:Array;
			for each(var s:String in str.split("\r\n"))
			{
				md = s.match(/(\w+): (.*)/);
				if(md) dic[md[1]] = md[2];
			}
			return dic;
		}
	}
}
