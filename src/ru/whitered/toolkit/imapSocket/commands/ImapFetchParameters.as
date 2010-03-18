package ru.whitered.toolkit.imapSocket.commands 
{

	/**
	 * @author whitered
	 */
	public class ImapFetchParameters 
	{
		public var body:Boolean = true;
		public var flags:String = null;
		public var fields:String = null;
		
		public var startIndex:int = 1;
		public var numMessages:int = 1;
		
		public var peek:Boolean = false;
		
		
		
		public function toString():String
		{
			
			var str:String = "FETCH";
			
			var bodyRequest:String = "BODY";
			if(peek) bodyRequest += ".PEEK";
			
			str += " " + startIndex;
			if(numMessages > 1) str += ":" + (startIndex + numMessages - 1);
			str += " (";
			if(body) str += " " + bodyRequest + "[TEXT]";
			if(fields) str += " " + bodyRequest + "[HEADER.FIELDS (" + fields + ")]";
			if(flags) str += " FLAGS";
			str += ")"; 
			return str;
		}
	}
}
