package  
{
	import ru.whitered.toolkit.imap.ImapSocket;
	import ru.whitered.toolkit.imap.commands.ImapExpungeCommand;
	import ru.whitered.toolkit.imap.commands.ImapLoginCommand;
	import ru.whitered.toolkit.imap.commands.ImapSelectCommand;
	import ru.whitered.toolkit.imap.commands.ImapStoreCommand;
	import ru.whitered.toolkit.imap.data.ImapEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author whitered
	 */
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="640", height="480")]
	public class Main extends Sprite 
	{
		public static const SUCCESS:String = "Main.SUCCESS";
		public static const FAILURE:String = "Main.FAILURE";
		
		
		private var imap:ImapSocket;

		
		
		public function Main() 
		{
			const timer:Timer = new Timer(1000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);
			timer.start();
		}

		
		
		private function handleTimerComplete(event:TimerEvent):void 
		{
			imap = new ImapSocket("192.168.1.51", 143); 
			imap.addEventListener(Event.CONNECT, handleConnect);
			
			addEventListener(SUCCESS, handleSuccess);
			addEventListener(FAILURE, handleFailure);
		}

		
		
		private function handleSuccess(event:Event):void 
		{
			trace("Success!");
		}

		
		
		private function handleFailure(event:TextEvent):void 
		{
			trace("FAILURE! " + event.text);
		}

		
		
		private function handleConnect(event:Event):void 
		{
			const command:ImapLoginCommand = new ImapLoginCommand("tmp06", "qwerty");
			command.addEventListener(ImapEvent.COMMAND_COMPLETE, handleLoginSuccess);
			imap.sendCommand(command);
		}

		
		
		private function handleLoginSuccess(event:ImapEvent):void 
		{
			deleteLetters("INBOX");
		}

		
		
		public function deleteLetters(mailboxName:String, index:int = 0):void
		{
			const select:ImapSelectCommand = new ImapSelectCommand(mailboxName);
			
			select.addEventListener(ImapEvent.COMMAND_COMPLETE, function (event:ImapEvent):void
			{
				if(event.mailbox.numMessagesExist == 0)
				{
					dispatchEvent(new TextEvent(FAILURE, false, false, "Mailbox is empty"));
				}
				else if(event.mailbox.numMessagesExist < index)
				{
					dispatchEvent(new TextEvent(FAILURE, false, false, "Index too big: there are only " + event.mailbox.numMessagesExist + " messages in the mailbox"));
				}
				else
				{
					const store:ImapStoreCommand = new ImapStoreCommand(1, Vector.<String>(["\\Deleted"]), index || 1, (index > 0) ? 1 : event.mailbox.numMessagesExist);
						
					store.addEventListener(ImapEvent.COMMAND_COMPLETE, function(event:ImapEvent):void
					{
						const expunge:ImapExpungeCommand = new ImapExpungeCommand();
								
						expunge.addEventListener(ImapEvent.COMMAND_COMPLETE, function (event:ImapEvent):void
						{
							dispatchEvent(new Event(SUCCESS));
						});
								
						expunge.addEventListener(ImapEvent.COMMAND_FAILED, function (event:ImapEvent):void
						{
							dispatchEvent(new Event(SUCCESS));
						});
								
						imap.sendCommand(expunge);
					});
						
					store.addEventListener(ImapEvent.COMMAND_FAILED, function(event:ImapEvent):void
					{
						dispatchEvent(new TextEvent(FAILURE, false, false, event.errorMessage));					});
						
					imap.sendCommand(store);
				}
			});
			
			select.addEventListener(ImapEvent.COMMAND_FAILED, function (event:ImapEvent):void
			{
				dispatchEvent(new TextEvent(FAILURE, false, false, event.errorMessage));
			});
			
			imap.sendCommand(select);
		}
	}
}
