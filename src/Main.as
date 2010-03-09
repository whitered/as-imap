package  
{
	import ru.whitered.toolkit.imap.data.MailMessage;
	import ru.whitered.toolkit.imap.data.Mailbox;
	import ru.whitered.toolkit.debug.logger.Logger;
	import ru.whitered.toolkit.imap.ImapBox;
	import ru.whitered.toolkit.imap.socket.ImapSocket;

	import flash.display.Sprite;

	/**
	 * @author whitered
	 */
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="640", height="480")]
	public class Main extends Sprite 
	{
		private var imap:ImapBox;
		
		
		
		
		public function Main() 
		{
			imap = new ImapBox(new ImapSocket("192.168.1.51", 143)); 
			imap.onConnect.addCallback(handleConnect);
			
			imap.onLoginSuccess.addCallback(handleLoginSuccess);
			
			imap.onLogoutSuccess.addCallback(handleLogoutSuccess);
			
			imap.onSelectSuccess.addCallback(handleSelectSuccess);
			imap.onSelectFailure.addCallback(handleSelectFailure);
			
			imap.onFetchSuccess.addCallback(handleFetchSuccess);
			imap.onFetchFailure.addCallback(handleFetchFailure);
		}

		
		
		private function handleFetchSuccess(messages:Vector.<MailMessage>):void 
		{
			Logger.debug(this, "Messages fetched:", messages);
			imap.logout();
		}

		
		
		private function handleFetchFailure(message:String):void 
		{
			Logger.debug(this, "fetch failed:", message);
		}

		
		
		private function handleSelectSuccess(mailbox:Mailbox):void 
		{
			Logger.debug(this, "mailbox selected:", mailbox.name, ",", mailbox.numMessagesExist, "messages exist");
			imap.fetchAll();
		}

		
		
		private function handleSelectFailure(message:String):void 
		{
			Logger.debug(this, "select failed:", message);
		}

		
		
		private function handleConnect() : void 
		{
			imap.login("tmp06", "qwerty");
			imap.select("INBOX");
		}
		
		
			
		private function handleLoginSuccess () : void 
		{
		}
		
		
		
		private function handleLogoutSuccess():void
		{
			Logger.debug(this, "LOGOUT OK");
		}

		
		
	}
}
