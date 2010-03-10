package ru.whitered.toolkit.imap 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.imap.commands.ImapAppendCommand;
	import ru.whitered.toolkit.imap.commands.ImapFetchCommand;
	import ru.whitered.toolkit.imap.commands.ImapListCommand;
	import ru.whitered.toolkit.imap.commands.ImapLoginCommand;
	import ru.whitered.toolkit.imap.commands.ImapLogoutCommand;
	import ru.whitered.toolkit.imap.commands.ImapSelectCommand;
	import ru.whitered.toolkit.imap.commands.ImapStoreCommand;
	import ru.whitered.toolkit.imap.data.MailMessage;
	import ru.whitered.toolkit.imap.data.Mailbox;

	/**
	 * @author whitered
	 */
	public class ImapBox extends ImapProcessor
	{

		public const onLoginSuccess	:Signal = new Signal();
		
		public const onLogoutSuccess	:Signal = new Signal();
		
		public const onSelectSuccess	:Signal = new Signal();
		public const onSelectFailure	:Signal = new Signal();
		
		public const onFetchSuccess	:Signal = new Signal();
		public const onFetchFailure	:Signal = new Signal();
		
		public const onAppendSuccess	:Signal = new Signal();
		public const onAppendFailure	:Signal = new Signal();
		
		public const onStoreSuccess	:Signal = new Signal();
		public const onStoreFailure	:Signal = new Signal();
		
		
		private var selectedMailbox:Mailbox;
		
		
		//----------------------------------------------------------------------
		// login
		//----------------------------------------------------------------------
		public function login( login:String, password:String ):void
		{
			const command:ImapLoginCommand = new ImapLoginCommand(login, password);
			command.onSuccess.addCallback(handleLoginSuccess);
			sendCommand(command);
		}

		
		
		private function handleLoginSuccess():void 
		{
			onLoginSuccess.dispatch();
		}

		
		
		//----------------------------------------------------------------------
		// logout
		//----------------------------------------------------------------------
		public function logout():void
		{
			const command:ImapLogoutCommand = new ImapLogoutCommand();
			command.onSuccess.addCallback(handleLogoutSuccess);
			sendCommand(command); 
		}
		
		
		
		private function handleLogoutSuccess():void
		{
			onLogoutSuccess.dispatch();
		}
		
		
		
		//----------------------------------------------------------------------
		// list
		//----------------------------------------------------------------------
		public function list():void
		{
			const command:ImapListCommand = new ImapListCommand();
			sendCommand(command);
		}

		
		
		//----------------------------------------------------------------------
		// select
		//----------------------------------------------------------------------
		public function select(name:String):void
		{
			const command:ImapSelectCommand = new ImapSelectCommand(name);
			command.onSuccess.addCallback(handleSelectSuccess);
			command.onFailure.addCallback(handleSelectFailure);
			sendCommand(command); 
		}

		
		
		private function handleSelectSuccess(mailbox:Mailbox):void 
		{
			selectedMailbox = mailbox;
			onSelectSuccess.dispatch(mailbox);
		}

		
		
		private function handleSelectFailure(message:String):void 
		{
			selectedMailbox = null;
			onSelectFailure.dispatch(message);
		}
		
		
		
		//----------------------------------------------------------------------
		// fetch
		//----------------------------------------------------------------------
		public function fetchAll():void
		{
			if(!selectedMailbox)
			{
				onFetchFailure.dispatch("No mailbox is selected!");
			}
			else if(selectedMailbox.numMessagesExist == 0)
			{
				handleFetchSuccess(new Vector.<MailMessage>());
			}
			else
			{
				const command:ImapFetchCommand = new ImapFetchCommand(1, selectedMailbox.numMessagesExist);
				command.onSuccess.addCallback(handleFetchSuccess);
				command.onFailure.addCallback(handleFetchFailure);
				sendCommand(command);
			}
		}

		
		
		private function handleFetchSuccess(messages:Vector.<MailMessage>):void 
		{
			selectedMailbox.messages = messages;
			onFetchSuccess.dispatch(messages);
		}

		
		
		private function handleFetchFailure(message:String):void 
		{
			onFetchFailure.dispatch(message);
		}
		
		
		
		//----------------------------------------------------------------------
		// append
		//----------------------------------------------------------------------
		public function append(mailbox:String, message:MailMessage):void
		{
			const command:ImapAppendCommand = new ImapAppendCommand(mailbox, message);
			command.onSuccess.addCallback(handleAppendSuccess);
			command.onFailure.addCallback(handleAppendFailure);
			sendCommand(command);
		}

		
		
		private function handleAppendSuccess(mailbox:String, message:MailMessage):void 
		{
			onAppendSuccess.dispatch(mailbox, message);
		}

		
		
		private function handleAppendFailure(mailbox:String, message:MailMessage, errorMessage:String):void 
		{
			onAppendFailure.dispatch(mailbox, message, errorMessage);
		}
		
		
		//----------------------------------------------------------------------
		// store
		//----------------------------------------------------------------------
		public function store(indexFrom:int, indexTo:int, action:int, flags:Vector.<String>):void
		{
			const command:ImapStoreCommand = new ImapStoreCommand(indexFrom, indexTo, action, flags);
			command.onSuccess.addCallback(handleStoreSuccess);
			command.onFailure.addCallback(handleStoreFailure);
			sendCommand(command);
		}

		
		
		private function handleStoreSuccess():void 
		{
			onStoreSuccess.dispatch();
		}

		
		
		private function handleStoreFailure(errorMessage:String):void 
		{
			onStoreFailure.dispatch(errorMessage);
		}
		
		
		
		//----------------------------------------------------------------------
		// 
		//----------------------------------------------------------------------
	}
}
