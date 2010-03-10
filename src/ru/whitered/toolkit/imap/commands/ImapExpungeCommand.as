package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.imap.ImapProcessor;

	/**
	 * @author whitered
	 */
	public class ImapExpungeCommand implements IImapCommand
	{
		public const onSuccess:Signal = new Signal();
		public const onFailure:Signal = new Signal();
		
		
		
		public function getCommand():String
		{
			return "EXPUNGE";
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
