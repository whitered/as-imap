package ru.whitered.toolkit.imap.commands 
{

	/**
	 * @author whitered
	 */
	public class ImapLoginCommand extends ImapBaseCommand
	{

		
		public function ImapLoginCommand(login:String, password:String) 
		{
			super("LOGIN " + login + " " + password);
		}
	}
}
