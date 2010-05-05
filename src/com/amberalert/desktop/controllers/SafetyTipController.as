package com.amberalert.desktop.controllers
{
	import com.amberalert.desktop.models.SafetyTip;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	/**
	 * SafetyTipController
	 *
	 * Controller that handles the grabbing of safety tips
	 * from either the internet or locally. Then parses the
	 * data for later use.
	 *
	 * @param var safetyTips:ArrayCollection
	 * @param var safetyFeed:HTTPService
	 * @param arcTips:SharedObject
	 * @author ASU Amber Alert Team
	 **/ 
	[Bindable]
	public class SafetyTipController extends EventDispatcher
	{
		public var safetyTips:ArrayCollection;
		public var safetyFeed:HTTPService;
		public var currentTip:SafetyTip;  //this is going to be injected in the view through glue
		public var alerting:int;
		private var parser:XmlParser;
		private var tipIndex:int;
		private var timer:Timer;
		private var arcTips:SharedObject;
		
		/**
		 * SafetyTipController
		 * 
		 * Driving function of the safety tip controller class.
		 * If there is a valid internet connection then it
		 * fetches the latest safety tips. Otherwise it loads
		 * the saved safety tips from the last fetch.
		 **/
		public function SafetyTipController():void
		{
			arcTips = SharedObject.getLocal("tips");
			safetyFeed = new HTTPService();
			safetyFeed.url = 'http://www.amberalert.com/category/tips/feed/';
			safetyFeed.resultFormat = 'object';
			safetyFeed.addEventListener(ResultEvent.RESULT,safetyTipResult);
			safetyFeed.addEventListener(FaultEvent.FAULT,faultHandler);
			
			safetyTips = new ArrayCollection();
			startTipTimer();
		}
		
		/**
		 * grabSafetyTips
		 *
		 * If there is a valid internet connection new safety tips are 
		 * pulled, otherwise it loads previously saved safety tips
		 **/ 
		public function grabSafetyTips():void
		{
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
		
		/**
		 * startTipTimer
		 *
		 * Starts safety tip refresh timer.
		 **/ 
		protected function startTipTimer():void
		{
			timer = new Timer(10000);
			timer.addEventListener(TimerEvent.TIMER, tipSwitch);
			timer.start();
			
			grabSafetyTips();
		}
		
		/**
		 * stopTipTimer
		 *
		 * Stops safety tip refresh timer.
		 **/ 
		protected function stopTipTimer():void
		{
			timer.removeEventListener(TimerEvent.TIMER,null);
			timer.stop();
		}
		
		/**
		 * safetyTipResult
		 *
		 * Event listener that is called when new safety
		 * tips are pulled down from the cloud.
		 **/ 
		protected function safetyTipResult(event:ResultEvent):void
		{
			tipIndex = 0;
			safetyTips = event.result.rss.channel.item;
			setCurrSafetyTip(safetyTips[tipIndex]);
		}
		
		/**
		 * safetyTipFault
		 * 
		 * **/
		protected function faultHandler(fault:FaultEvent):void
		{
			trace(fault);
		}
		
		/**
		 * tipSwitch
		 *
		 * Simple timer event handler that switches the currently
		 * displayed tip to the next one. It also insures that 
		 * only valid indexs of the tips array are referenced
		 **/
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
		
		/**
		 * setCurrentSafetyTip
		 *
		 * Function that changes the displayed tip information
		 * to another tip.
		 **/
		private function setCurrSafetyTip(tip:Object):void
		{
			currentTip = new SafetyTip();
			currentTip.title = tip.title;
			currentTip.description = tip.description;
		}
	}
}
