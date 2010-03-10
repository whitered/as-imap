package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;

	/**
	 * @author whitered
	 */
	public class ImapLogoutCommand implements IImapCommand 
	{
		public const onSuccess:Signal = new Signal();
		
		
		
		public function getCommand():String
		{
			return "LOGOUT";
		}
		
		
		
		public function processResult(message:String):void
		{
			const status:String = message.split(" ")[1];
			if(status == "BYE") onSuccess.dispatch();
			else Logger.debug(this, "Logout failed:", message);
		}
		
		
		
		public function processContinuation(message:String):String
		{
			return null;
		}
	}
}
