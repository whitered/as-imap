package ru.whitered.toolkit.imapSocket.commands 
{

	/**
	 * @author whitered
	 */
	public class ImapStoreCommand extends ImapBaseCommand
	{
		
		public function ImapStoreCommand(action:int, flags:Vector.<String>, startIndex:uint, numMessages:uint = 1) 
		{
			const indexes:String = (numMessages == 1) ? startIndex + "" : (startIndex + ":" + (startIndex + numMessages - 1)); 
			const modifier:String = (action < 0 ? "-" : action > 0 ? "+" : "") + "FLAGS";
			super("STORE " + indexes + " " + modifier + " (" + flags.join(" ") + ")");
		}
	}
}
