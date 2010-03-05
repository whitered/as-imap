package ru.whitered.toolkit.debug.monitor 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/**
	 * @author whitered
	 */
	public class BitmapGraph extends Bitmap
	{

		private var backgroundColor:uint = 0xFF000000;
		private var graphColor:uint = 0xFFFFFFFF;
		private var transparent:Boolean;

		private var maximum:Number;

		
		
		public function BitmapGraph(width:int, height:int, backgroundColor:uint, graphColor:uint)
		{
			this.backgroundColor = backgroundColor;
			this.graphColor = graphColor;
			transparent = ((backgroundColor >>> 24) != 0xFF);
			bitmapData = new BitmapData(width, height, transparent, backgroundColor);
			maximum = height;
		}

		
		
		public function setMaximum(value:Number):void 
		{
			if(maximum != value) 
			{
				scale(maximum / value);
				maximum = value;
			}
		}

		
		
		public function addValue(value:Number):void
		{
			var x:int = bitmapData.width - 1;
			var y:int = bitmapData.height * (1 - value / maximum);
			
			bitmapData.scroll(-1, 0);
			bitmapData.fillRect(new Rectangle(x, 0, 1, bitmapData.height), backgroundColor);
			bitmapData.setPixel32(x, y, graphColor);
		}

		
		
		private function scale(ratio:Number):void 
		{
			var matr:Matrix = new Matrix();
			matr.scale(1, ratio);
			matr.translate(0, bitmapData.height * (1 - ratio));
			
			var bmpd:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, transparent, backgroundColor);
			bmpd.draw(bitmapData, matr, null, null, null, true);
			bitmapData.dispose();
			bitmapData = bmpd;
		}
	}
}
