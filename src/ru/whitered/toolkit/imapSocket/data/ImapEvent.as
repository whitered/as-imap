package ru.whitered.toolkit.imapSocket.data 
{
	import flash.events.Event;

	/**
	 * @author whitered
	 */
	public class ImapEvent extends Event 
	{
		public static const COMMAND_COMPLETE:String = "ImapEvent.COMMAND_COMPLETE";
		public static const COMMAND_FAILED:String = "ImapEvent.COMMAND_FAILED";
		
		public var errorMessage:String = null;
		public var messages:Vector.<ImapMessage> = null;
		public var mailbox:ImapMailbox = null;

		
		
		public function ImapEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
		}

		
		
		override public function clone():Event 
		{
			const event:ImapEvent = new ImapEvent(type, bubbles, cancelable);
			event.errorMessage = errorMessage;
			event.messages = messages;
			event.mailbox = mailbox;
			return event;
		}
	}
}
