package ru.whitered.toolkit.imapSocket.commands 
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
