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
		
		
		
		public function processResponse(response:String):void
		{
			const status:String = response.split(" ")[1];
			if(status == "BYE") onSuccess.dispatch();
			else Logger.debug(this, "Logout failed:", response);
		}
	}
}
