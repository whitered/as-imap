package  
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;
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
			const timer:Timer = new Timer(1000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);
			timer.start();
		}

		
		
		private function handleTimerComplete(event:TimerEvent):void 
		{
			
			imap = new ImapBox(new ImapSocket("192.168.1.51", 143)); 
			imap.onConnect.addCallback(handleConnect);
			
			imap.onLoginSuccess.addCallback(handleLoginSuccess);
			
			imap.onLogoutSuccess.addCallback(handleLogoutSuccess);
			
			imap.onSelectSuccess.addCallback(handleSelectSuccess);
			imap.onSelectFailure.addCallback(handleSelectFailure);
			
			imap.onFetchSuccess.addCallback(handleFetchSuccess);
			imap.onFetchFailure.addCallback(handleFetchFailure);
			
			imap.onAppendSuccess.addCallback(handleAppendSuccess);
		}

		
		
		private function handleAppendSuccess(mailbox:String, message:MailMessage):void 
		{
			imap.select("INBOX");
		}

		
		
		private function handleFetchSuccess(messages:Vector.<MailMessage>):void 
		{
			Logger.debug(this, "Messages fetched:", messages);
			imap.store(1, messages.length, 1, Vector.<String>(["\\Deleted"]));
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
		}
		
		
			
		private function handleLoginSuccess () : void 
		{
//			const msg:MailMessage = new MailMessage();
//			msg.date = "Fri,  5 Mar 2010 18:04:13 +0300 (MSK)";
//			msg.from = "Tom@Sawyer.es";
//			msg.to = "Huckleberry@Finn.ua";
//			msg.seen = true;
//			msg.subject = "I gotta kill ya";
//			msg.body = "How r u, asshole?";
//			
//			imap.append("INBOX", msg);
			imap.select("INBOX");
		}

		
		
		private function handleLogoutSuccess():void
		{
			Logger.debug(this, "LOGOUT OK");
		}

		
		
	}
}
