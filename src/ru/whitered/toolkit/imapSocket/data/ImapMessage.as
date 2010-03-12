package ru.whitered.toolkit.imapSocket.data 
{
	import flash.utils.Dictionary;

	/**
	 * @author whitered
	 */
	public class ImapMessage 
	{
		public var id:int = 0;
		public var body:String = null;
		public const flags:Dictionary = new Dictionary();
		public const headers:Dictionary = new Dictionary();
		
		
		
		
		public function toString():String
		{
			var headersStr:String = "";
			for (var h:String in headers) 
			{
				headersStr += " " + h + "=<" + headers[h] + ">";
			}
			
			var flagsStr:String = "";
			for (var f:String in flags)
			{
				flagsStr += " " + f;
			}
			
			return "[ImapMessage id=<"+ id + ">" + headersStr + flagsStr + " body=<" + body + ">]";
		}
	}
}
