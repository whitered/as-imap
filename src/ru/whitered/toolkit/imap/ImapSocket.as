package ru.whitered.toolkit.imap 
{
	import ru.whitered.kote.Signal;
	import ru.whitered.toolkit.debug.logger.Logger;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;

	/**
	 * @author whitered
	 */
	public class ImapSocket implements ISocket
	{
		public const _onConnect:Signal = new Signal();
		public const _onDisconnect:Signal = new Signal();
		public const _onData:Signal = new Signal();
		public const _onError:Signal = new Signal();
		
		private var socket:Socket;
		
		
		
		public function ImapSocket(server:String, port:uint) 
		{
			socket = new Socket(server, port);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, handleSocketData);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError); 
			socket.addEventListener(IOErrorEvent.IO_ERROR, handleError);
			socket.addEventListener(Event.CONNECT, handleConnect);
			socket.addEventListener(Event.CLOSE, handleDisconnect);
		}

		
		
		public function send(message:String):void 
		{
			Logger.debug(this, message);
			socket.writeUTFBytes(message + "\r\n");
			socket.flush();
		}

		
		
		private function handleConnect(event:Event):void 
		{
			onConnect.dispatch();
		}
		
		
		
		private function handleDisconnect(event:Event):void
		{
			onDisconnect.dispatch();
		}

		
		
		private function handleError(event:ErrorEvent):void 
		{
			Logger.debug(this, event );
			onError.dispatch(event);
		}

		
		
		private function handleSocketData(event:ProgressEvent):void 
		{
			const message:String = socket.readUTFBytes(socket.bytesAvailable );
			onData.dispatch(message );
		}
		
		
		
		public function get onConnect () : Signal
		{
			return _onConnect;
		}

		
		
		public function get onDisconnect () : Signal
		{
			return _onDisconnect;
		}

		
		
		public function get onError () : Signal
		{
			return _onError;
		}

		
		
		public function get onData () : Signal
		{
			return _onData;
		}
	}
}
