package  
{
	import ru.whitered.toolkit.imap.ImapBox;
	import ru.whitered.toolkit.imap.ImapSocket;

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
		}

		
		
		private function handleConnect() : void 
		{
			imap.login("tmp06", "qwerty");
		}
		
		
			
		private function handleLogin () : void 
		{
			imap.list();
		}

		
		
	}
}
