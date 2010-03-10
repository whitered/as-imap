package ru.whitered.toolkit.imap.commands 
{

	/**
	 * @author whitered
	 */
	public class ImapExpungeCommand extends ImapBaseCommand
	{
		public function ImapExpungeCommand() 
		{
			super("EXPUNGE");
		}
	}
}
