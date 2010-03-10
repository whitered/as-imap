package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.toolkit.imap.ImapProcessor;

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
			const lines:Vector.<String> = Vector.<String>(message.split(ImapProcessor.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			switch(lastLineWords[1])
			{
				case "BYE":
					onSuccess.dispatch();
					break;
					
				default:
					onFailure.dispatch(lastLineWords.slice(2).join(" "));
					break;
			}
		}
	}
}
