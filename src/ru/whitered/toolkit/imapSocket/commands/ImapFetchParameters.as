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
		
		
		
		public function toString():String
		{
			var str:String = "";
			str += "FETCH " + startIndex;
			if(numMessages > 1) str += ":" + (startIndex + numMessages - 1);
			str += " (";
			if(body) str += " BODY[TEXT]";
			if(fields) str += " BODY[HEADER.FIELDS (" + fields + ")]";
			if(flags) str += " FLAGS";
			str += ")"; 
			return str;
		}
	}
}
