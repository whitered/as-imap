package ru.whitered.toolkit.imapSocket.commands 
{
	import ru.whitered.toolkit.imapSocket.ImapSocket;
	import ru.whitered.toolkit.imapSocket.data.ImapEvent;
	import ru.whitered.toolkit.imapSocket.data.ImapMailbox;

	/**
	 * @author whitered
	 */
	public class ImapSelectCommand extends ImapBaseCommand
	{
		
		private var name:String;
		
		
		
		public function ImapSelectCommand(name:String) 
		{
			this.name = name;
			super("SELECT " + name);
		}

		
		
		override public function processResult(message:String):void
		{
			const lines:Vector.<String> = Vector.<String>(message.split(ImapSocket.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			var event:ImapEvent;
			switch(lastLineWords[1])
			{
				case "OK":
					event = new ImapEvent(ImapEvent.COMMAND_COMPLETE);
					event.mailbox = new ImapMailbox(name);
					
					for each(var line:String in lines)
					{
						var words:Vector.<String> = Vector.<String>(line.split(" ", 3));
						if(words.length > 2 && words[2] == "EXISTS") event.mailbox.numMessagesExist = int(words[1]);
					}
					break;
					
				default:
					event = new ImapEvent(ImapEvent.COMMAND_FAILED);
					event.errorMessage = lastLineWords.slice(2).join(" ");
					break;
			}
			dispatchEvent(event); 
		}
	}
}
