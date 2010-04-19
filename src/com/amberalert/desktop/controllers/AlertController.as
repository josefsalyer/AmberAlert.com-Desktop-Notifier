package com.amberalert.desktop.controllers
{
	import com.amberalert.desktop.models.AMBERAlert;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	[Bindable]
	public class AlertController extends EventDispatcher
	{
		// What I Neeeeeeeed //
		public var alerts:ArrayCollection;
		public var alertFeed:HTTPService;
		public var currentAlert:AMBERAlert;
		public var alertIndex:int;
		public var recentAlerts:XML;
		public var currentLoc:String = 'XX';
		public var alertExists:Boolean = false;
		private var parser:XmlParser;
		private var arcAlerts:SharedObject;
		
		public function AlertController():void
		{
			parser = new XmlParser();
			recentAlerts = new XML();
			alertFeed = new HTTPService();
			alertFeed.url = 'https://amberleapalerts.s3.amazonaws.com/alerts-test.xml';
			alertFeed.resultFormat = 'e4x';
			alertFeed.addEventListener(ResultEvent.RESULT,alertFeedResult);
			
			var t1:Timer = new Timer(10000);
			t1.addEventListener(TimerEvent.TIMER, pullAlerts);
			t1.start();
			
			pullAlerts();
		}
		
		public function setCurrentLocation(loc:String):void
		{
			currentLoc = loc;
			pullAlerts();
		}
		
		protected function alertFeedResult(event:ResultEvent):void
		{
			var temp:XML = event.result as XML;
			
			if(temp.contains(recentAlerts)) 
			{
				trace('there have been no changes')
			} 
			else 
			{
				alerts = parser.parseAmberAlerts(currentLoc, event.result as XML);
				recentAlerts = temp;
				
				//resets the alert
				alertIndex = 0;
				if(alerts != null)
				{
					if(alerts.length == 0)
						currentAlert = null;
					else
						currentAlert = alerts.getItemAt(alertIndex) as AMBERAlert;
				}	
			}
			
			if(alerts == null)
				alertExists = false;
			else if(alerts.length == 0)
				alertExists = false;
			else
				alertExists = true;
		}
		
		private function pullAlerts(e:TimerEvent=null):void
		{
			arcAlerts = SharedObject.getLocal("feed");
			
			if(ConnectionChecker.internets)
			{
				alertFeed.send();
				arcAlerts.data.feed = alerts;
				arcAlerts.flush();
			}
			else
			{
				alerts = arcAlerts.data.feed;
			}
		}
		
		//A event from the notification view will be routed to here
		public function nextAlert():void
		{
			//TO DO increment the index and set the current alert
		}
		
		//A event from the notification view will be routed to here
		public function prevAlert():void
		{
			//TO DO decrement the index and set the current alert
		}
	}
}