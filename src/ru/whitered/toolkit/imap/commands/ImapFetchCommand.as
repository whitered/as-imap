package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.imap.ImapBox;
	import ru.whitered.toolkit.imap.data.MailMessage;
	import ru.whitered.toolkit.utils.StringUtil;

	/**
	 * @author whitered
	 */
	public class ImapFetchCommand implements IImapCommand 
	{
		public const onSuccess:Signal = new Signal();
		public const onFailure:Signal = new Signal();
		
		
		
		private var startIndex:int;
		private var endIndex:int;

		
		
		public function ImapFetchCommand(startIndex:int, endIndex:int) 
		{
			this.startIndex = startIndex;
			this.endIndex = endIndex;
		}

		
		
		
		public function getCommand():String
		{
			//return "FETCH " + startIndex + ":" + endIndex + " (BODY.PEEK[HEADER.FIELDS (Date From Subject To Alliance Pid)] FLAGS)";
			//return "FETCH " + startIndex + ":" + endIndex + " (BODY.PEEK[HEADER.FIELDS (Date From Subject To Alliance Pid)] FLAGS BODY[TEXT])";
			return "FETCH " + startIndex + ":" + endIndex + " (BODY[HEADER.FIELDS (Date From Subject To Alliance Pid)] FLAGS BODY[TEXT])";
		}
		
		
		
		public function processResult(message:String):void
		{
			const lines:Vector.<String> = Vector.<String>(message.split(ImapBox.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			switch(lastLineWords[1])
			{
				case "OK":
					//const messages:Vector.<MailMessage> = parseMessages(lines);
					const messages:Vector.<MailMessage> = parseResponse(message);
					onSuccess.dispatch(messages);
					break;
					
				case "NO":
				case "BAD":
					onFailure.dispatch(lastLineWords.slice(2).join(" "));
					break;
			}
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
		
		
		
		public function processContinuation(message:String):String
		{
			return null;
		}
	}
}
