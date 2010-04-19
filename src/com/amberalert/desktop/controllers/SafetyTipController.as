package com.amberalert.desktop.controllers
{
	import com.amberalert.desktop.models.SafetyTip;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	[Bindable]
	public class SafetyTipController extends EventDispatcher
	{
		public var safetyTips:ArrayCollection;
		public var safetyFeed:HTTPService;
		public var currentTip:SafetyTip;  //this is going to be injected in the view through glue
		public var alerting:int;
		private var parser:XmlParser;
		private var tipIndex:int;
		private var arcTips:SharedObject;
		
		public function SafetyTipController():void
		{
			arcTips = SharedObject.getLocal("tips");
			safetyFeed = new HTTPService();
			safetyFeed.url = 'http://www.amberalert.com/category/tips/feed/';
			safetyFeed.resultFormat = 'object';
			safetyFeed.addEventListener(ResultEvent.RESULT,safetyTipResult);
			
			safetyTips = new ArrayCollection();
			
			var t1:Timer = new Timer(10000);
			t1.addEventListener(TimerEvent.TIMER, tipSwitch);
			t1.start();
			
			if(ConnectionChecker.internets)
			{
				safetyFeed.send();
				arcTips.data.tips = safetyTips;
			}
			else
			{
				safetyTips = arcTips.data.tips;
				tipIndex = 0;
			}
		}
		
		protected function safetyTipResult(event:ResultEvent):void
		{
			tipIndex = 0;
			safetyTips = event.result.rss.channel.item;
			setCurrSafetyTip(safetyTips[tipIndex]);
		}
		
		public function tipSwitch(event:TimerEvent):void
		{
			if(alerting == 0 && safetyTips != null)
			{
				tipIndex++;
				if(tipIndex == safetyTips.length)
					tipIndex = 0;
				
				setCurrSafetyTip(safetyTips[tipIndex]);
			}
		}
		
		private function setCurrSafetyTip(tip:Object):void
		{
			currentTip = new SafetyTip();
			currentTip.title = tip.title;
			currentTip.description = tip.description;
		}
	}
}