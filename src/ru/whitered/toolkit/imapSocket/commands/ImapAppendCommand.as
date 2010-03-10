package ru.whitered.toolkit.imapSocket.commands 
{
	import ru.whitered.toolkit.imapSocket.ImapSocket;
	import ru.whitered.toolkit.imapSocket.data.MailMessage;

	import flash.utils.ByteArray;

	/**
	 * @author whitered
	 */
	public class ImapAppendCommand extends ImapBaseCommand 
	{
		
		private var command:String;
		private var literal:String;

		
		
		public function ImapAppendCommand(mailbox:String, message:MailMessage) 
		{
			literal = [	
				"From: " + message.from,
				"To: " + message.to,
				"Date: " + message.date,
				"Subject: " + message.subject,
				"Content-Type: text/plain; charset=UTF-8; format=flowed",
				"",
				message.body.split("\r").join(ImapSocket.NEWLINE),
				""
			].join(ImapSocket.NEWLINE);
			
			
			
			const flags:Vector.<String> = new Vector.<String>();
			if(message.seen) flags.push("\\Seen");
			
			const ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(literal);
			
			command = "APPEND " + mailbox;
			if(flags.length > 0) command += " (" + flags.join(" ") + ")";
			command += " {" + ba.length + "}";
			
			super(command);
		}

		
		
		override public function processContinuation(message:String):String
		{
			return literal;
		}
	}
}
