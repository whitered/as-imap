package ru.whitered.toolkit.imap.data 
{

	/**
	 * @author whitered
	 */
	public class Mailbox 
	{
		public var name:String;
		public var numMessagesExist:uint = 0;
		public var messages:Vector.<MailMessage>;

		
		
		public function Mailbox(name:String) 
		{
			this.name = name;
		}
	}
}
