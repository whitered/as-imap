package ru.whitered.toolkit.imap.commands 
{
	import ru.whitered.toolkit.imap.data.Mailbox;
	import ru.whitered.kote.Signal;
	
	import ru.whitered.toolkit.imap.ImapBox;

	/**
	 * @author whitered
	 */
	public class ImapSelectCommand implements IImapCommand 
	{
		public const onSuccess:Signal = new Signal();
		public const onFailure:Signal = new Signal();
		
		
		
		private var name:String;
		
		
		
		public function ImapSelectCommand(name:String) 
		{
			this.name = name;
		}

		
		
		public function getCommand():String
		{
			return "SELECT " + name;
		}
		
		
		
		public function processResponse(response:String):void
		{
			const lines:Vector.<String> = Vector.<String>(response.split(ImapBox.NEWLINE));
			const lastLineWords:Vector.<String> = Vector.<String>(lines[lines.length - 2].split(" "));
			switch(lastLineWords[1])
			{
				case "OK":
					const mailbox:Mailbox = new Mailbox(name);
					
					for each(var line:String in lines)
					{
						var words:Vector.<String> = Vector.<String>(line.split(" "));
						if(words.length > 2 && words[2] == "EXISTS") mailbox.numMessagesExist = int(words[1]);
					}
					
					onSuccess.dispatch(mailbox);
					break;
					
				case "NO":
					onFailure.dispatch(lastLineWords.slice(2).join(" "));
					break;
			}
		}
	}
}
