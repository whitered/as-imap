package ru.whitered.toolkit.imap.commands 
{

	/**
	 * @author whitered
	 */
	public interface IImapCommand 
	{
		function getCommand():String;
		function processResult(message:String):void;
		function processContinuation(message:String):String;
	}
}
