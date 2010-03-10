package ru.whitered.toolkit.imapSocket.data 
{

	/**
	 * @author whitered
	 */
	public class ImapMessage 
	{
		public var id:int = 0;
		public var body:String = null;
		
		public var from:String = null;
		public var to:String = null;
		public var subject:String = null;
		public var date:String = null;
		
		public var seen:Boolean = false;

		
		
		public function toString():String
		{
			return "[MailMessage from='" + from + 
					"' to='" + to + 
					"' subject='" + subject + 
					"' date='" + date + 
					"' seen='" + seen + 
					"' body='" + body + 
					"']";
		}
	}
}
