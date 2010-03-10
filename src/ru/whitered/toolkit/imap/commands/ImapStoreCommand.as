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
		
		
		
		private var indexFrom:int;
		private var indexTo:int;
		private var action:int;
		private var flags:Vector.<String>;

		
		
		public function ImapStoreCommand(indexFrom:int, indexTo:int, action:int, flags:Vector.<String>) 
		{
			this.indexFrom = indexFrom;
			this.indexTo = indexTo;
			this.action = action;
			this.flags = flags;
		}

		
		
		public function getCommand():String
		{
			return "STORE " + indexFrom + ":" + indexTo + " " + (action < 0 ? "-" : action > 0 ? "+" : "") + "FLAGS (" + flags.join(" ") + ")";
		}
		
		
		
		public function processResult(message:String):void
		{
			const lines:Vector.<String> = Vector.<String>(message.split(ImapProcessor.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" ", 3));
			switch(lastLineWords[1])
			{
				case "OK":
					onSuccess.dispatch();
					break;
					
				case "NO":
				case "BAD":
					onFailure.dispatch(lastLineWords[2]);
					break;
			}
		}
		
		
		
		public function processContinuation(message:String):String
		{
			return null;
		}
	}
}
