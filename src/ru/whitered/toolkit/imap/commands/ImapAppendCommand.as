package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.imap.ImapProcessor;
	import ru.whitered.toolkit.imap.data.MailMessage;

	import flash.utils.ByteArray;

	/**
	 * @author whitered
	 */
	public class ImapAppendCommand implements IImapCommand 
	{
		public const onSuccess:Signal = new Signal();
		public const onFailure:Signal = new Signal();
		
		
		
		private var mailbox:String;
		private var mailMessage:MailMessage;
		
		private var command:String;
		private var literal:String;

		
		
		public function ImapAppendCommand(mailbox:String, message:MailMessage) 
		{
			this.mailbox = mailbox;
			this.mailMessage = message;
			
			literal = [	
				"From: " + message.from,
				"To: " + message.to,
				"Date: " + message.date,
				"Subject: " + message.subject,
				"Content-Type: text/plain; charset=UTF-8; format=flowed",
				"",
				message.body.split("\r").join(ImapProcessor.NEWLINE),
				""
			].join(ImapProcessor.NEWLINE);
			
			
			
			const flags:Vector.<String> = new Vector.<String>();
			if(message.seen) flags.push("\\Seen");
			
			const ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(literal);
			
			command = "APPEND " + mailbox;
			if(flags.length > 0) command += " (" + flags.join(" ") + ")";
			command += " {" + ba.length + "}";
		}

		
		
		public function getCommand():String
		{
			return command;
		}

		
		
		
		public function processContinuation(message:String):String
		{
			return literal;
		}
		
		
		public function processResult(message:String):void
		{
			const lines:Vector.<String> = Vector.<String>(message.split(ImapProcessor.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			switch(lastLineWords[1])
			{
				case "OK":
					onSuccess.dispatch(mailbox, mailMessage);
					break;
					
				case "NO":
				case "BAD":
					onFailure.dispatch(mailbox, mailMessage, lastLineWords.slice(2).join(" "));
					break;
			}
		}
	}
}
