package ru.whitered.toolkit.imap.data 
{

	/**
	 * @author whitered
	 */
	public class MailMessage 
	{
		public var id:int;
		public var from:String;
		public var to:String;
		public var subject:String;
		public var date:String;
		public var body:String;
		
		
		
		public function toString():String
		{
			return "[MailMessage from='" + from + "' to='" + to + "' subject='" + subject + "' date='" + date + "' body='" + body + "']";
		}
	}
}
