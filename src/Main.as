package  
{
	import ru.whitered.toolkit.imap.data.ImapEvent;
	import ru.whitered.toolkit.imap.commands.ImapLoginCommand;
	import ru.whitered.toolkit.imap.ImapProcessor;
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;
	import ru.whitered.toolkit.imap.commands.ImapExpungeCommand;
	import ru.whitered.toolkit.imap.commands.ImapSelectCommand;
	import ru.whitered.toolkit.imap.commands.ImapStoreCommand;
	import ru.whitered.toolkit.imap.data.Mailbox;
	import ru.whitered.toolkit.imap.socket.ImapSocket;

	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author whitered
	 */
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="640", height="480")]
	public class Main extends Sprite 
	{
		private var imap:ImapProcessor;

		
		
		public function Main() 
		{
			const timer:Timer = new Timer(1000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);
			timer.start();
		}

		
		
		private function handleTimerComplete(event:TimerEvent):void 
		{
			imap = new ImapProcessor(new ImapSocket("192.168.1.51", 143)); 
			imap.onConnect.addCallback(handleConnect);
		}

		
		
		private function handleConnect():void 
		{
			const command:ImapLoginCommand = new ImapLoginCommand("tmp06", "qwerty");
			command.addEventListener(ImapEvent.COMMAND_COMPLETE, handleLoginSuccess);
			imap.sendCommand(command);
		}

		
		
		private function handleLoginSuccess(event:ImapEvent):void 
		{
			deleteLetters("INBOX").addCallback(function(error:String):void 
			{
				Logger.debug(this, error || "deleted OK");
			});
		}

		
		
		public function deleteLetters(mailbox:String, index:int = 0):Signal
		{
			const signal:Signal = new Signal();
			const select:ImapSelectCommand = new ImapSelectCommand(mailbox);
			
			select.addEventListener(ImapEvent.COMMAND_COMPLETE, function (mailbox:Mailbox):void
			{
				if(mailbox.numMessagesExist == 0)
				{
					signal.dispatch("Mailbox is empty");
				}
				else if(mailbox.numMessagesExist < index)
				{
					signal.dispatch("Index too big: there are only " + mailbox.numMessagesExist + " messages in the mailbox");
				}
				else
				{
					const store:ImapStoreCommand = new ImapStoreCommand(1, Vector.<String>(["\\Deleted"]), index || 1, (index > 0) ? 1 : mailbox.numMessagesExist);
						
					store.addEventListener(ImapEvent.COMMAND_COMPLETE, function():void
					{
						const expunge:ImapExpungeCommand = new ImapExpungeCommand();
								
						expunge.addEventListener(ImapEvent.COMMAND_COMPLETE, function ():void
						{
							signal.dispatch(null);
						});
								
						expunge.addEventListener(ImapEvent.COMMAND_FAILED, function (errorMessage:String):void
						{
							signal.dispatch(errorMessage);
						});
								
						imap.sendCommand(expunge);
					});
						
					store.addEventListener(ImapEvent.COMMAND_FAILED, function(errorMessage:String):void
					{
						signal.dispatch(errorMessage);
					});
						
					imap.sendCommand(store);
				}
			});
			
			select.addEventListener(ImapEvent.COMMAND_FAILED, function (errorMessage:String):void
			{
				signal.dispatch(errorMessage);
			});
			
			imap.sendCommand(select);
			
			return signal;
		}
	}
}
