package ru.whitered.toolkit.imapSocket.commands 
{

	/**
	 * @author whitered
	 */
	public class ImapStoreCommand extends ImapBaseCommand
	{
		
		public function ImapStoreCommand(action:int, flags:String, startIndex:uint, numMessages:uint = 1) 
		{
			const flagsVec:Vector.<String> = Vector.<String>(flags.split(" "));
			for (var i:int = 0;i < flagsVec.length;i++)
			{
				if(flagsVec[i].charAt(0) != "\\") flagsVec[i] = "\\" + flagsVec[i];
			}
			
			const indexes:String = (numMessages == 1) ? startIndex + "" : (startIndex + ":" + (startIndex + numMessages - 1)); 
			const modifier:String = (action < 0 ? "-" : action > 0 ? "+" : "") + "FLAGS";
			super("STORE " + indexes + " " + modifier + " (" + flagsVec.join(" ") + ")");
		}
	}
}
