package  
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;
	import ru.whitered.toolkit.imap.ImapSocket;
	import ru.whitered.toolkit.imap.commands.ImapExpungeCommand;
	import ru.whitered.toolkit.imap.commands.ImapLoginCommand;
	import ru.whitered.toolkit.imap.commands.ImapSelectCommand;
	import ru.whitered.toolkit.imap.commands.ImapStoreCommand;
	import ru.whitered.toolkit.imap.data.ImapEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author whitered
	 */
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="640", height="480")]
	public class Main extends Sprite 
	{
		private var imap:ImapSocket;

		
		
		public function Main() 
		{
			const timer:Timer = new Timer(1000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);
			timer.start();
		}

		
		
		private function handleTimerComplete(event:TimerEvent):void 
		{
			Logger.debug(this, "connecting...");
			imap = new ImapSocket("192.168.1.51", 143); 
			imap.addEventListener(Event.CONNECT, handleConnect);
		}

		
		
		private function handleConnect(event:Event):void 
		{
			Logger.debug(this, "connected!");
			Logger.debug(this, "logging in...");
			const command:ImapLoginCommand = new ImapLoginCommand("tmp06", "qwerty");
			command.addEventListener(ImapEvent.COMMAND_COMPLETE, handleLoginSuccess);
			imap.sendCommand(command);
		}

		
		
		private function handleLoginSuccess(event:ImapEvent):void 
		{
			Logger.debug(this, "logged in!");
			Logger.debug(this, "deleting letters...");
			deleteLetters("INBOX").addCallback(function(error:String):void 
			{
				Logger.debug(this, error || "deleted OK");
			});
		}

		
		
		public function deleteLetters(mailboxName:String, index:int = 0):Signal
		{
			const signal:Signal = new Signal();
			const select:ImapSelectCommand = new ImapSelectCommand(mailboxName);
			
			select.addEventListener(ImapEvent.COMMAND_COMPLETE, function (event:ImapEvent):void
			{
				if(event.mailbox.numMessagesExist == 0)
				{
					signal.dispatch("Mailbox is empty");
				}
				else if(event.mailbox.numMessagesExist < index)
				{
					signal.dispatch("Index too big: there are only " + event.mailbox.numMessagesExist + " messages in the mailbox");
				}
				else
				{
					const store:ImapStoreCommand = new ImapStoreCommand(1, Vector.<String>(["\\Deleted"]), index || 1, (index > 0) ? 1 : event.mailbox.numMessagesExist);
						
					store.addEventListener(ImapEvent.COMMAND_COMPLETE, function(event:ImapEvent):void
					{
						const expunge:ImapExpungeCommand = new ImapExpungeCommand();
								
						expunge.addEventListener(ImapEvent.COMMAND_COMPLETE, function (event:ImapEvent):void
						{
							signal.dispatch(null);
						});
								
						expunge.addEventListener(ImapEvent.COMMAND_FAILED, function (event:ImapEvent):void
						{
							signal.dispatch(event.errorMessage);
						});
								
						imap.sendCommand(expunge);
					});
						
					store.addEventListener(ImapEvent.COMMAND_FAILED, function(event:ImapEvent):void
					{
						signal.dispatch(event.errorMessage);
					});
						
					imap.sendCommand(store);
				}
			});
			
			select.addEventListener(ImapEvent.COMMAND_FAILED, function (event:ImapEvent):void
			{
				signal.dispatch(event.errorMessage);
			});
			
			imap.sendCommand(select);
			
			return signal;
		}
	}
}
