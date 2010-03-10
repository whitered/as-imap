package ru.whitered.toolkit.imap.commands 
{
	
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;

	/**
	 * @author whitered
	 */
	public class ImapLoginCommand implements IImapCommand
	{
		public const onSuccess:Signal = new Signal();
		
		
		
		private var login:String;
		private var password:String;

		
		
		public function ImapLoginCommand(login:String, password:String) 
		{
			this.password = password;
			this.login = login;
		}

		
		
		public function getCommand():String
		{
			return "LOGIN " + login + " " + password;
		}
		
		
		
		public function processResult(message:String):void
		{
			const status:String = message.split(" ")[1];
			if(status == "OK") onSuccess.dispatch();
			else Logger.debug(this, "Login not OK:", message);
		}
		
		
		
		public function processContinuation(message:String):String
		{
			return null;
		}
	}
}
