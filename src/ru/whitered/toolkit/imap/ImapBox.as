package ru.whitered.toolkit.imap 
{
	import flash.events.ErrorEvent;
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;

	import flash.utils.Dictionary;

	/**
	 * @author whitered
	 */
	public class ImapBox 
	{
		public const onConnect:Signal = new Signal();
		public const onDisconnect:Signal = new Signal();
		public const onLogin:Signal = new Signal();
		
		
		private var socket : ISocket;
		private var _state : ImapState = ImapState.DISCONNECTED;
		private var lastID : uint = 0;
		private const commands : Dictionary = new Dictionary( );

		
		
		public function ImapBox (socket:ISocket) 
		{
			this.socket = socket;
			socket.onConnect.addCallback(handleSocketConnect);
			socket.onDisconnect.addCallback(handleSocketDisconnect);
			socket.onError.addCallback(handleSocketError);
			socket.onData.addCallback(handleSocketData );
		}

		
		
		private function handleSocketConnect () : void 
		{
			state = ImapState.CONNECTED;
			onConnect.dispatch();
		}

		
		
		private function handleSocketDisconnect () : void 
		{
			state = ImapState.DISCONNECTED;
			onDisconnect.dispatch();
		}

		
		
		private function handleSocketError (event:ErrorEvent) : void 
		{
			Logger.debug(this, event);
		}

		
		
		private function handleSocketData ( message : String ) : void 
		{
			const id : String = message.split( " " )[0];
			const command : IImapCommand = commands[id];
			if(command)
			{
				Logger.debug( this, "processing with command:", command, message );
				if(command.processResponse( message ))
				{
					delete commands[id];
				}
			}
			else
			{
				Logger.debug( this, "processing without command:", message );
			}
		}

		
		
		private function sendCommand (command : IImapCommand) : void
		{
			const id : String = "CMD" + ++lastID;
			commands[id] = command;
			socket.send(id + " " + command.getCommand());
		}

		
		
		private function set state(value:ImapState):void
		{
			Logger.debug(this, "state:", _state, "->", value);
			_state = value;
		}
		
		
		
		private function get state():ImapState
		{
			return _state;
		}



		//----------------------------------------------------------------------
		// login
		//----------------------------------------------------------------------
		public function login ( login : String, password : String ) : void
		{
			if(state != ImapState.CONNECTED) throw new ImapStateError( "Login command can be called in ImapState.CONNECTED state only" );
			const command : ImapLoginCommand = new ImapLoginCommand( login, password );
			command.onSuccess.addCallback( handleLoginSuccess );
			sendCommand( command );
		}

		
		
		private function handleLoginSuccess () : void 
		{
			state = ImapState.AUTHENTICATED;
			onLogin.dispatch();
		}
		
		
		
		//----------------------------------------------------------------------
		// list
		//----------------------------------------------------------------------
		public function list():void
		{
			if(state != ImapState.AUTHENTICATED) throw new ImapStateError("List command can be called in ImapStatee.AUTHENTICATED state only");
			const command:ImapListCommand = new ImapListCommand();
			sendCommand(command);
		}
	}
}
