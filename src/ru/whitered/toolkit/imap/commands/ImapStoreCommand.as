package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.imap.ImapProcessor;

	/**
	 * @author whitered
	 */
	public class ImapStoreCommand implements IImapCommand 
	{
		public const onSuccess:Signal = new Signal();
		public const onFailure:Signal = new Signal();
		
		
		
		private var action:int;
		private var flags:Vector.<String>;
		private var startIndex:uint;
		private var numMessages:uint;

		
		
		public function ImapStoreCommand(action:int, flags:Vector.<String>, startIndex:uint, numMessages:uint = 1) 
		{
			this.action = action;
			this.flags = flags;
			this.startIndex = startIndex;
			this.numMessages = numMessages;
		}

		
		
		public function getCommand():String
		{
			const indexes:String = (numMessages == 1) ? startIndex + "" : (startIndex + ":" + (startIndex + numMessages - 1)); 
			const modifier:String = (action < 0 ? "-" : action > 0 ? "+" : "") + "FLAGS";
			return "STORE " + indexes + " " + modifier + " (" + flags.join(" ") + ")";
		}
		
		
		
		public function processResult(message:String):void
		{
			const lines:Vector.<String> = Vector.<String>(message.split(ImapProcessor.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			switch(lastLineWords[1])
			{
				case "OK":
					onSuccess.dispatch();
					break;
					
				case "NO":
				case "BAD":
					onFailure.dispatch(lastLineWords.slice(2).join(" "));
					break;
			}
		}
		
		
		
		public function processContinuation(message:String):String
		{
			return null;
		}
	}
}
