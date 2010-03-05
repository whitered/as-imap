package ru.whitered.toolkit.imap 
{
	import ru.whitered.kote.Signal;

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
		
		
		
		public function processResponse(response:String):Boolean
		{
			const status:String = response.split(" ")[1];
			if(status == "OK") onSuccess.dispatch();
			return true;
		}
	}
}
