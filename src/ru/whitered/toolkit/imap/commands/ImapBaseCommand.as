package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.toolkit.imap.ImapProcessor;
	import ru.whitered.toolkit.imap.data.ImapEvent;

	import flash.events.EventDispatcher;

	/**
	 * @author whitered
	 */
	public class ImapBaseCommand extends EventDispatcher
	{
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
			var event:ImapEvent;
			switch(lastLineWords[1])
			{
				case "OK":
					event = new ImapEvent(ImapEvent.COMMAND_COMPLETE);
					break;
					
				default:
					event = new ImapEvent(ImapEvent.COMMAND_FAILED);
					event.errorMessage = lastLineWords.slice(2).join(" ");
					break;
			}
			dispatchEvent(event); 
		}
	}
}
