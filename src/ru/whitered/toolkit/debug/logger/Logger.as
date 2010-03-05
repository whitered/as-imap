package ru.whitered.toolkit.debug.logger
{

	/**
	 * класс для ведения лога программы
	 */
	public class Logger
	{

		private static const SHOW_TIME:Boolean = true;
		private static const MULTILINE_PREFIX:String = "\n     |";

		public static const NOTIFICATION:int = 1;
		public static const WARNING:int = 2;
		public static const ERROR:int = 3;
		public static const DEBUG:int = 4;
		public static const PERFORMANCE:int = 5;
		public static const FIXME:int = 6;
		
		
		
		/**
		 * запись строк в лог
		 * @param status тип сообщения
		 * @param object объект - источник сообщения
		 * @param strings строки для вывода
		 */ 		
		public static function push(status:int, object:Object, ... strings):void 
		{
			/*FDT_IGNORE*/config::DEBUG {/*FDT_IGNORE*/
			if(status <= 0) return;
			
			var str:String = "";
			switch(status)
			{
				
				case NOTIFICATION:
					str = ">     ";
					break;
					
				case WARNING:
					str = "!!!   ";
					break;
					
				case ERROR:
					str = "ERROR ";
					break;
					
				case DEBUG:
					str = "debug ";
					break;
					
				case PERFORMANCE:
					str = "%%%   ";
					break;
					
				case FIXME:
					str = "FIXME ";
					break;
					
				default:
					str = "??    ";
					break;
			}
			
			if(SHOW_TIME)
			{
				var d:Date = new Date();
				str += d.toLocaleTimeString().substr(0, 8) + "." + d.getTime() % 1000 + " ";
			} 
			str += object + ": ";
			
			var lines:Array = strings.join(" ").split("\n");
			if(lines.length > 1)
			{
				str += MULTILINE_PREFIX + lines.join(MULTILINE_PREFIX);
			} 
			else 
			{
				str += lines[0];
			}
			
			trace(str);
			
			/*FDT_IGNORE*/}/*FDT_IGNORE*/
		}

		
		
		public static function error(object:Object, ... strings):void 
		{
			strings.unshift(ERROR, object);
			push.apply(Logger, strings);
		}

		
		
		public static function notice(object:Object, ... strings):void 
		{
			strings.unshift(NOTIFICATION, object);
			push.apply(Logger, strings);
		}

		
		
		public static function debug(object:Object, ... strings):void 
		{
			strings.unshift(DEBUG, object);
			push.apply(Logger, strings);
		}

		
		
		public static function warning(object:Object, ... strings):void 
		{
			strings.unshift(WARNING, object);
			push.apply(Logger, strings);
		}

		
		
		public static function fixme(object:Object, ... strings):void 
		{
			strings.unshift(FIXME, object);
			push.apply(Logger, strings);
		}
	}
}
