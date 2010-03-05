package  
{
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
			imap.onLogin.addCallback(handleLogin );
			imap.onSelectSuccess.addCallback(handleSelectSuccess);
			imap.onSelectFailure.addCallback(handleSelectFailure);
		}

		
		
		private function handleSelectSuccess(name:String):void 
		{
			Logger.debug(this, "mailbox selected:", name);
		}

		
		
		private function handleSelectFailure(message:String):void 
		{
			Logger.debug(this, "select failed:", message);
		}

		
		
		private function handleConnect() : void 
		{
			imap.login("tmp06", "qwerty");
		}
		
		
			
		private function handleLogin () : void 
		{
			imap.select("INBOX.Draft");
		}

		
		
	}
}
