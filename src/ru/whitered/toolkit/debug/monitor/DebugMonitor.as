package ru.whitered.toolkit.debug.monitor 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	/**
	 * @author whitered
	 */
	public class DebugMonitor extends Sprite
	{

		private static const TEXT_HEIGHT:int = 12;
		private static const UPDATE_TIME:int = 100;

		private static const FPS_COLOR:uint = 0xFF00FF00;
		private static const MEMORY_COLOR:uint = 0xFFFFFFFF;
		private static const BACKGROUND_COLOR:uint = 0xFF333333;

		private var memoryText:TextField;
		private var fpsText:TextField;

		private var memoryGraph:BitmapGraph;
		private var fpsGraph:BitmapGraph;

		private var maxMemory:int;
		private var frameCounter:int;

		private var updateTimer:Timer;

		
		
		public function DebugMonitor(width:int, height:int)
		{
			graphics.beginFill(BACKGROUND_COLOR, (BACKGROUND_COLOR >>> 24) / 0xFF);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			var graphHeight:int = height - 2 * TEXT_HEIGHT;
			if(graphHeight < 0) graphHeight = 0;
			
			var textFormat:TextFormat = new TextFormat("Verdana", 8, MEMORY_COLOR);
			textFormat.align = TextFormatAlign.RIGHT;
			
			memoryText = new TextField();
			memoryText.defaultTextFormat = textFormat;
			memoryText.width = width;
			memoryText.height = TEXT_HEIGHT;
			
			textFormat.color = FPS_COLOR;
			
			fpsText = new TextField();
			fpsText.defaultTextFormat = textFormat;
			fpsText.width = width;
			fpsText.height = TEXT_HEIGHT;
			fpsText.y = TEXT_HEIGHT + graphHeight;
			
			memoryGraph = new BitmapGraph(width, graphHeight, 0x00000000, MEMORY_COLOR);
			memoryGraph.y = TEXT_HEIGHT;
			
			fpsGraph = new BitmapGraph(width, graphHeight, 0x00000000, FPS_COLOR);
			fpsGraph.y = TEXT_HEIGHT;
			
			addChild(memoryText);
			addChild(memoryGraph);
			addChild(fpsGraph);
			addChild(fpsText);
			
			updateTimer = new Timer(UPDATE_TIME);
			updateTimer.addEventListener(TimerEvent.TIMER, update);
			
			addEventListener(Event.ADDED_TO_STAGE, startMonitoring);
			addEventListener(Event.REMOVED_FROM_STAGE, stopMonitoring);
			
			mouseChildren = false;
			doubleClickEnabled = true;
			addEventListener(MouseEvent.DOUBLE_CLICK, runGC);
		}

		
		
		private function runGC(event:MouseEvent):void
		{
			System["gc"]();
		}

		
		
		private function update(event:TimerEvent):void
		{
			var curFps:int = frameCounter * 1000 / UPDATE_TIME;
			frameCounter = 0;
			fpsText.text = curFps + " FPS";
			fpsGraph.addValue(curFps);
			
			var curMemory:int = System.totalMemory;
			if(curMemory > maxMemory) 
			{
				maxMemory = curMemory;
				memoryGraph.setMaximum(maxMemory);
			}
			memoryGraph.addValue(curMemory);
			memoryText.text = curMemory + " / " + maxMemory;
		}

		
		
		private function startMonitoring(event:Event):void
		{
			fpsGraph.setMaximum(stage.frameRate * 1.5);
			addEventListener(Event.ENTER_FRAME, countFrames);
			updateTimer.start();
		}

		
		
		private function stopMonitoring(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, countFrames);
			updateTimer.reset();
		}

		
		
		private function countFrames(event:Event):void
		{
			frameCounter++;
		}
	}
}
