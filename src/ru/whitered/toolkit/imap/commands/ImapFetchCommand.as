package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;
	import ru.whitered.toolkit.imap.ImapBox;
	import ru.whitered.toolkit.imap.data.MailMessage;

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
			return "FETCH " + startIndex + ":" + endIndex + " (BODY.PEEK[HEADER.FIELDS (Date From Subject To Alliance Pid)] FLAGS)";
		}
		
		
		
		public function processResponse(response:String):void
		{
			Logger.debug(this, response);
			const lines:Vector.<String> = Vector.<String>(response.split(ImapBox.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			switch(lastLineWords[1])
			{
				case "OK":
					const messages:Vector.<MailMessage> = parseMessages(lines);
					onSuccess.dispatch(messages);
					break;
					
				case "NO":
				case "BAD":
					onFailure.dispatch(lastLineWords.slice(2).join(" "));
					break;
			}
		}
		
		
		
		private function parseMessages(lines:Vector.<String>):Vector.<MailMessage>
		{
			const messages:Vector.<MailMessage> = new Vector.<MailMessage>();
			var words:Vector.<String>;
			var message:MailMessage;
			for each(var line:String in lines)
			{
				words = Vector.<String>(line.split(" "));
				if(words.length > 0) switch(words[0])
				{
					case "*":
						if(message) messages.push(message);
						message = new MailMessage();
						break;
						
					case "From:":
						message.from = words.slice(1).join(" ");
						break;
						
					case "To:":
						message.to = words.slice(1).join(" ");
						break;
						
					case "Subject:":
						message.subject = words.slice(1).join(" ");
						break;
						
					case "Date:":
						message.date = words.slice(1).join(" ");
						break;
				}
			}
			if(message) messages.push(message);
			return messages;
		}
	}
}
