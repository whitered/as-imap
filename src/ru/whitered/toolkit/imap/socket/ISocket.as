package ru.whitered.toolkit.imap.socket 
{
	import ru.whitered.kote.Signal;

	/**
	 * @author whitered
	 */
	public interface ISocket 
	{
		function get onConnect():Signal;
		function get onDisconnect():Signal;
		function get onError():Signal;
		function get onData():Signal;
		function send(message:String):void;
	}
}
