package ru.whitered.toolkit.imap.commands 
{

	
	/**
	 * @author whitered
	 */
	public class ImapListCommand implements IImapCommand 
	{
		// half-finished yet

		public function getCommand():String
		{
			return "LIST \"\" \"\"";
		}

		
		
		public function processResponse(response:String):void
		{
		}
	}
}
