package ru.whitered.toolkit.imapSocket.data 
{

	/**
	 * @author whitered
	 */
	public class ImapMailbox 
	{
		public var name:String;
		public var numMessagesExist:uint = 0;
		public var messages:Vector.<ImapMessage>;

		
		
		public function ImapMailbox(name:String) 
		{
			this.name = name;
		}
	}
}
