package ru.whitered.toolkit.utils 
{
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	public class ObjectUtils 
	{
		private static const objectID:Dictionary = new Dictionary(true);
		private static var freeID:uint = 0;
		
		

		public static function clone(obj:Object):Object 
		{
			const ba:ByteArray = new ByteArray();
			ba.writeObject(obj);
			ba.position = 0;
			return ba.readObject();
		}

		
		
		public static function inspect(obj:Object, depth:int = 2):String 
		{
			return scan(obj, depth, "\t", new Dictionary());
		} 

		
		
		private static function scan(obj:Object, depth:int, prefix:String, flags:Dictionary):String 
		{
			if(depth < 1 || obj is String || obj is int || obj is Number || obj is Boolean || obj is Date || obj is Function || obj == null) return String(obj);
			else if(obj is XML || obj is XMLList) return obj.toXMLString();
			
			if(flags[obj]) return obj + " (recursive)";
			flags[obj] = true;
			
			const classDef:XML = describeType(obj);
			
			var str:String = "";
			
			for each(var variable:XML in classDef.variable)
			{
				str += prefix + "." + variable.@name + " = " + scan(obj[variable.@name], depth - 1, prefix + "\t", flags) + "\n";
			}
			
			for each(var accessor:XML in classDef.accessor.(@access == "readwrite" || @access == "readonly"))
			{
				try
				{
					str += prefix + "" + accessor.@name + "() = " + scan(obj[accessor.@name], depth - 1, prefix + "\t", flags) + "\n";
				}
				catch(error:Error)
				{
					str += prefix + "" + accessor.@name + "() = " + error + "\n"; 
				}
			}
			
			for(var s:* in obj) 
			{
				str += prefix + "[\"" + s + "\"] = " + scan(obj[s], depth - 1, prefix + "\t", flags) + "\n";
			}
			return str ? (obj + " {\n" + str + prefix + "}\n") : ((obj != null) ? obj + "" : "null");
		}
		
		
		
		public static function cloneTextFormat(source:TextFormat):TextFormat
		{
			const clone:TextFormat = new TextFormat();
			clone.align				= source.align;
			clone.blockIndent		= source.blockIndent;
			clone.bold				= source.bold;
			clone.bullet			= source.bullet;
			clone.color				= source.color;
			clone.display			= source.display;
			clone.font				= source.font;
			clone.indent			= source.indent;
			clone.italic			= source.italic;
			clone.kerning			= source.kerning;
			clone.leading			= source.leading;
			clone.leftMargin		= source.leftMargin;
			clone.letterSpacing		= source.letterSpacing;
			clone.rightMargin		= source.rightMargin;
			clone.size				= source.size;
			clone.tabStops			= source.tabStops;
			clone.target			= source.target;
			clone.underline			= source.underline;
			clone.url				= source.url;
			return clone;
		}
		
		
		
		public static function getUniqueID(object:*):uint
		{
			return objectID.hasOwnProperty(object) ? objectID[object] : objectID[object] = freeID++;
		}
	}
}
