package ru.whitered.toolkit.utils 
{
	import flash.utils.ByteArray;

	public class StringUtil
	{

		public static function substitute(str:String, ... rest):String
		{
			if (str == null) return '';
	        
			var len:uint = rest.length;
			var args:Array;
			if (len == 1 && rest[0] is Array)
			{
				args = rest[0] as Array;
				len = args.length;
			}
			else
			{
				args = rest;
			}
	        
			for (var i:int = 0;i < len; i++)
			{
				str = str.replace(new RegExp("\\{" + i + "\\}", "g"), args[i]);
			}
	
			return str;
		}
		
		
		
		public static function tag(tag:String, body:String, attribs:Object = null):String
		{
			var attrString:String = "";
			for (var key:String in attribs)
			{
				attrString += " " + key + "='" + attribs[key] + "'"; 
			}
			
			return "<" + tag + attrString + ">" + body + "</" + tag + ">";
		}

		
		
		public static function trim(source:String):String
		{
			return source.replace(/^\s*/, "").replace(/\s*$/, "");
		}
		
		
		
		public static function hexNumber(n:uint, length:int = 8):String
		{
			var hexChars:String = '0123456789abcdef';
			var mask:uint = 0xf;
			
			var dig:int;
			var s:String = '';
			
			for (var i:int = 0;i < length; i++)
			{
				dig = mask & n;
				s = hexChars.charAt(dig) + s;
				n >>= 4;
			}
			return s;
		}

		
		
		public static function getPluralForm(value:int, form1:String, form2:String, form5:String):String
		{
			var lastNum:int = value % 10;
			if(value > 10 && value < 20) return form5;
			else if(lastNum == 1) return form1;
			else if(lastNum > 1 && lastNum < 5) return form2;
			else return form5;
		}

		
		
		public static function secondsToTimeString(seconds:int):String
		{
			const day:int = seconds / (3600 * 24);
			const hr:int = seconds % (3600 * 24) / 3600;
			const min:int = seconds % 3600 / 60;
			const sec:int = seconds % 60; 
			var s:String = "";
			if(day > 0) s += day + "д ";
			if(hr > 0) s += hr + "ч ";
			if(min > 0) s += min + "м ";
			if(sec > 0 || !s) s += sec + "с";
			return s; 
		}

		
		
		public static function dateToRussian(date:Date, showTime:Boolean = true):String
		{
			var str:String = "";
			str += date.date + " ";
			switch(date.month)
			{
				case 0: 	
					str += "января"; 	
					break;
				case 1: 	
					str += "февраля"; 	
					break;
				case 2: 	
					str += "марта"; 	
					break;
				case 3: 	
					str += "апреля"; 	
					break;
				case 4: 	
					str += "мая"; 		
					break;
				case 5: 	
					str += "июня"; 		
					break;
				case 6: 	
					str += "июля"; 		
					break;
				case 7: 	
					str += "августа"; 	
					break;
				case 8: 	
					str += "сентября"; 	
					break;
				case 9: 	
					str += "октября"; 	
					break;
				case 10: 	
					str += "ноября"; 	
					break;
				case 11: 	
					str += "декабря"; 	
					break;
			}
			str += " " + date.fullYear + " г.";
			
			if(showTime)
			{
				str += " " + date.hours.toString() + ":" + rjust(date.minutes.toString());
			}
			
			return str; 
		}
		
		
		
		public static function parseStringToDate(dateStr:String):Date
		{
			
			// dd.mm.YYYY hh.nn.ss
			// YY is also supported
			
			const dateTimeArray:Vector.<String> = Vector.<String>(dateStr.split(" "));
			const dateArray:Vector.<String> = Vector.<String>(dateTimeArray[0].split("."));
			const timeArray:Vector.<String> = Vector.<String>(dateTimeArray[1].split(":"));
			
			if (dateArray[2].length == 2) dateArray[2] = "20" + dateArray[2];
			
			var date:Date = new Date(int(dateArray[2]), int(dateArray[1]) - 1, int(dateArray[0]), int(timeArray[0]), int(timeArray[1]), int(timeArray[2]));
			
			return date;
		}

		
		
		public static function rjust(str:String, length:int = 2, padstr:String = "0"):String 
		{
			var begin:String = padstr;
			const beginLength:int = length - str.length;
			while(begin.length < beginLength) begin += begin;
			begin = begin.substr(0, beginLength);
			return begin + str;
		}
		
		
		
		
		public static function utf8BytesLength(string:String):int {
			const bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(string);
			return bytes.length;
		}




		public static function substringBytes(source:String, startIndex:uint = 0, len:uint = 0xffffff):String
		{
			const ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(source);
			ba.position = startIndex;
			
			const numBytes:uint = (len > ba.length - startIndex) ? ba.length - startIndex : len; 
			return ba.readUTFBytes(numBytes);
		}
	}
}
