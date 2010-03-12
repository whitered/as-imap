package ru.whitered.toolkit.imapSocket.commands 
{
	import ru.whitered.toolkit.imapSocket.ImapSocket;
	import ru.whitered.toolkit.imapSocket.data.ImapMessage;

	import flash.utils.ByteArray;

	/**
	 * @author whitered
	 */
	public class ImapAppendCommand extends ImapBaseCommand 
	{
		
		private var command:String;
		private var literal:String;

		
		
		public function ImapAppendCommand(mailbox:String, message:ImapMessage) 
		{
			literal = "";
			
			for (var h:String in message.headers)
			{
				literal += h + ": " + message.headers[h] + ImapSocket.NEWLINE;
			}
			
			literal += ImapSocket.NEWLINE;
			literal += message.body.split("\r").join(ImapSocket.NEWLINE);
			literal += ImapSocket.NEWLINE;
			
			const flags:Vector.<String> = new Vector.<String>();
			for (var f:String in message.flags) flags.push("\\" + f);
			
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
