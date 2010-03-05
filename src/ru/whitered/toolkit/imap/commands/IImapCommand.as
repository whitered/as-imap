package ru.whitered.toolkit.imap.commands 
{

	/**
	 * @author whitered
	 */
	public interface IImapCommand 
	{
		function getCommand():String;
		function processResponse(response:String):void;
	}
}
