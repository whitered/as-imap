package ru.whitered.toolkit.imap 
{

	/**
	 * @author whitered
	 */
	public interface IImapCommand 
	{
		function getCommand():String;
		function processResponse(response:String):Boolean;
	}
}
