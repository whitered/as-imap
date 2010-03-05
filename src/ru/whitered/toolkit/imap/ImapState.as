package ru.whitered.toolkit.imap 
{

	/**
	 * @author whitered
	 */
	public class ImapState 
	{
		public static const DISCONNECTED : ImapState = new ImapState( "DISCONNECTED" );
		public static const CONNECTED : ImapState = new ImapState( "CONNECTED" );
		public static const AUTHENTICATED : ImapState = new ImapState( "AUTHENTICATED" );
		public static const FOLDER_SELECTED : ImapState = new ImapState( "FOLDER_SELECTED" );

		
		
		private var name : String;

		
		
		public function ImapState (name : String) 
		{
			this.name = name;
		}
		
		
		
		public function toString():String
		{
			return name;
		}
	}
}
