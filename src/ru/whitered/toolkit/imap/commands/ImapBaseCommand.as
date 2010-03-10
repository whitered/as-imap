package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.imap.ImapProcessor;

	/**
	 * @author whitered
	 */
	public class ImapBaseCommand
	{
		public const onSuccess:Signal = new Signal();
		public const onFailure:Signal = new Signal();
		
		
		
		private var command:String;

		
		
		public function ImapBaseCommand(command:String) 
		{
			this.command = command;
		}

		
		
		public function getCommand():String
		{
			return command;
		}
		
		
		
		public function processContinuation(message:String):String
		{
			return null;
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
					
				default:
					onFailure.dispatch(lastLineWords.slice(2).join(" "));
					break;
			}
		}
	}
}
