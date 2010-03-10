package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.toolkit.imap.ImapProcessor;
	import ru.whitered.toolkit.imap.data.ImapEvent;
	import ru.whitered.toolkit.imap.data.MailMessage;
	import ru.whitered.toolkit.utils.StringUtil;

	/**
	 * @author whitered
	 */
	public class ImapFetchCommand extends ImapBaseCommand
	{
		
		
		public function ImapFetchCommand(startIndex:int, endIndex:int) 
		{
			super("FETCH " + startIndex + ":" + endIndex + " (BODY[HEADER.FIELDS (Date From Subject To Alliance Pid)] FLAGS BODY[TEXT])");
		}

		
		
		
		override public function processResult(message:String):void
		{
			const lines:Vector.<String> = Vector.<String>(message.split(ImapProcessor.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			var event:ImapEvent;
			switch(lastLineWords[1])
			{
				case "OK":
					event = new ImapEvent(ImapEvent.COMMAND_COMPLETE);
					event.messages = parseResponse(message);
					break;
					
				default:
					event = new ImapEvent(ImapEvent.COMMAND_FAILED);
					event.errorMessage = lastLineWords.slice(2).join(" ");
					break;
			}
			dispatchEvent(event); 
		}

		
		
		private function parseResponse(response:String):Vector.<MailMessage> 
		{
			const messageSources:Vector.<String> = Vector.<String>(response.split("\r\n)\r\n"));
			const messages:Vector.<MailMessage> = new Vector.<MailMessage>();
			
			var md1:Array;
			var md2:Array;
			var headers:String;
			var flags:String;
			var body:String;
			
			for each(var source:String in messageSources)
			{
				md1 = source.match(/\* (\d+) FETCH \(\FLAGS \(([^\)]+)\) [^\r]+ \{(\d+)\}\r\n/mi);
				if(!md1) continue;
				
				flags = md1[2];
				
				source = source.substr(source.indexOf(md1[0]) + md1[0].length);
				headers = StringUtil.substringBytes(source, 0, md1[3]);
				source = source.substr(headers.length);
				
				md2 = source.match(/BODY\[TEXT\] \{(\d+)\}\r\n/mi);
				source = source.substr(source.indexOf(md2[0]) + md2[0].length);
				body = StringUtil.substringBytes(source, 0, md2[1]);
				
				messages.push(parseMailMessage(md1[1], headers, body, flags));
			}
			return messages;
		}

		
		
		private function parseMailMessage(id:int, headers:String, body:String, flags:String):MailMessage
		{
			const msg:MailMessage = new MailMessage();
			msg.id = id;
			msg.body = body;
			
			var words:Array;
			for each(var header:String in headers.split("\r\n"))
			{
				words = header.split(" ");
				if(words.length < 2) continue;
				
				switch(words[0])
				{
					case "From:":		
						msg.from = words.slice(1).join(" ");
						break;
						
					case "To:":
						msg.to = words.slice(1).join(" ");
						break;
						
					case "Subject:":
						msg.subject = words.slice(1).join(" ");
						break;
						
					case "Date:":
						msg.date = words.slice(1).join(" ");
						break;
				}
			}
			
			for each(var flag:String in flags.split(" "))
			{
				switch(flag)
				{
					case "\\Seen":
						msg.seen = true;
						break;
				}
			}
			return msg;
		}
		
	}
}
