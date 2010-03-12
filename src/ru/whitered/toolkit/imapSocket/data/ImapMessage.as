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
		public var flags:Dictionary = null;
		public var headers:Dictionary = null;
		
		
		
		
		public function toString():String
		{
			var headersStr:String = "";
			if(headers) for (var h:String in headers) 
			{
				headersStr += " " + h + "=<" + headers[h] + ">";
			}
			
			var flagsStr:String = "";
			if(flags) for (var f:String in flags)
			{
				flagsStr += " " + f;
			}
			
			return "[ImapMessage id=<"+ id + ">" + headersStr + flagsStr + " body=<" + body + ">]";
		}
	}
}
