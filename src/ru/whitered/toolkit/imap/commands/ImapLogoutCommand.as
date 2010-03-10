package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.toolkit.imap.ImapSocket;
	import ru.whitered.toolkit.imap.data.ImapEvent;

	/**
	 * @author whitered
	 */
	public class ImapLogoutCommand extends ImapBaseCommand 
	{
		
		public function ImapLogoutCommand() 
		{
			super("LOGOUT");
		}

		
		
		
		override public function processResult(message:String):void 
		{
			const lines:Vector.<String> = Vector.<String>(message.split(ImapSocket.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			var event:ImapEvent;
			switch(lastLineWords[1])
			{
				case "BYE":
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
