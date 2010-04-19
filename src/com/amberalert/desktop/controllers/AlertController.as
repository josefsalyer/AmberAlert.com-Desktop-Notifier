package com.amberalert.desktop.controllers
{
	import com.amberalert.desktop.models.AMBERAlert;
	import com.amberalert.desktop.models.Destinations;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	/**
	 * AlertController
	 * 
	 * Action script controller that manages the checking and
	 * parsing of incoming Amber Alerts from the web.
	 * 
	 * @author ASU Amber Alert Team
	 **/
	[Event(name="showNotification", type="flash.events.Event")]

	[Bindable]
	public class AlertController extends EventDispatcher
	{
		// What I Neeeeeeeed //
		public var alerts:ArrayCollection;
		public var alertFeed:HTTPService;
		public var currentAlert:AMBERAlert;
		public var alertIndex:int;
		public var alertCount:int = 0;
		public var recentAlerts:XML;
		private var _currentLoc:String = '';
		public var alertExists:Boolean = false;
		private var timer:Timer;
		private var parser:XmlParser;
		private var arcAlerts:SharedObject;
		private var destination:String;
		
		public function set currentLoc(value:String):void
		{
			_currentLoc = value;
			if(destination != Destinations.FIRST_RUN)
			{
				recentAlerts = new XML();
				alertFeed.send();
			}
		}
		
		public function get currentLoc():String
		{
			return _currentLoc;
		}
		
		public function set currentState(value:String):void
		{
			destination = value;
			if(value != Destinations.FIRST_RUN)
			{
				if(!timer.running)
					startAlertTimer();
			}
			else
			{
				if(!timer.running)
					stopTipTimer();
			}	
		}
		
		/**
		 * AlertController constructor
		 * 
		 * Function that sets up the AlertController by establishing a
		 * HTTP connection with amberalert.com and set up a timer to 
		 * check for alerts at a given rate
		 * 
		 * @param var parser:XmlParser
		 * @param var alertFeed:HTTPService
		 * @author ASU Amber Alert Team
		 **/
		public function AlertController():void
		{
			alerts = new ArrayCollection();
			parser = new XmlParser();
			recentAlerts = new XML();
			arcAlerts = SharedObject.getLocal("alertData");
			alertFeed = new HTTPService();
			alertFeed.url = 'https://amberleapalerts.s3.amazonaws.com/alerts-test.xml';
			alertFeed.resultFormat = 'e4x';
			alertFeed.addEventListener(ResultEvent.RESULT,alertFeedResult);
			timer = new Timer(10000);
			timer.addEventListener(TimerEvent.TIMER, pullAlerts);
		}
		
		protected function startAlertTimer():void
		{
			timer.start();
			
			pullAlerts();
		}
		/**
		 * setCurrentLocation
		 * 
		 * Function that changes the value of the current location then
		 * pulls the feed again to check for Active Amber Alerts in the
		 * new location
		 * 
		 * @author ASU Amber Alert Team
		 **/
		protected function stopTipTimer():void
		{
			timer.stop();
		}
		
		public function setCurrentLocation(loc:String):void
		{
			currentLoc = loc;
			if(destination != Destinations.FIRST_RUN)
			{
				alertFeed.send();	
			}
		}
		
		/**
		 * alertFeedResult
		 * 
		 * Function continually called that first checks for changes in the
		 * alert XML file, then if there are changes it parses the new XML
		 * file
		 * 
		 * @author ASU Amber Alert Team
		 **/
		protected function alertFeedResult(event:ResultEvent):void
		{
			var temp:XML = event.result as XML;
			
			if(temp.contains(recentAlerts)) 
			{
				trace('there have been no changes')
			} 
			else 
			{
				var stateAlerts:Array = parser.parseAmberAlerts(currentLoc, event.result as XML); 
				alerts.source = stateAlerts;
				recentAlerts = temp;
				
				//resets the alert
				alertIndex = 0;
				if(alerts != null)
				{
					if(alerts.source[currentLoc].length == 0)
						currentAlert = null;
					//else if (currentAlert == alerts.getItemAt(alertIndex)  || alertCount > alerts.length)
					//else if (currentAlert == stateAlerts[currentLoc].getItemAt(alertIndex))
					else if (arcAlerts.data.alertData == alerts)
					{
						currentAlert = alerts.source[currentLoc].getItemAt(alertIndex) as AMBERAlert;
						alertCount = alerts.source[currentLoc].length;
					}
					else
					{
						currentAlert = alerts.source[currentLoc].getItemAt(alertIndex) as AMBERAlert;
						alertCount = alerts.source[currentLoc].length;
						dispatchEvent(new Event('showNotification'));
					}
				}	
			}
			
			if(alerts.source[currentLoc] == null)
				alertExists = false;
			else if(alerts.source[currentLoc].length == 0)
				alertExists = false;
			else
			{
				alertExists = true;
			}
			
			arcAlerts.data.alertData = alerts;
			arcAlerts.flush();
		}
		
		/**
		 * pullAlerts
		 * 
		 * Function that checks to see if there is a vaild current
		 * internet connection. If there is, it loads the new alerts
		 * XML from the web (and saves it). If there is not, then it 
		 * loads the last saved alert data.
		 * 
		 * @param var arcAlerts:SharedObject
		 * @author ASU Amber AlertTeam
		 **/
		public function pullAlerts(e:TimerEvent=null):void
		{
			if(ConnectionChecker.internets)
			{
				alertFeed.send();
			}
			else
			{
				alerts = arcAlerts.data.alertData;
			}
		}
		
		//A event from the notification view will be routed to here
		public function nextAlert():void
		{
			//TO DO increment the index and set the current alert
			if (alerts != null)
			{
				if (alertIndex + 1 < alerts.source[currentLoc].length)
					alertIndex++;
				else
					alertIndex = 0;
				currentAlert = alerts.source[currentLoc].getItemAt(alertIndex) as AMBERAlert;
			}
		}
		
		//A event from the notification view will be routed to here
		public function prevAlert():void
		{
			//TO DO decrement the index and set the current alert
			if (alerts != null)
			{
				if (alertIndex - 1 >= 0)
					alertIndex--;
				else
					alertIndex = alerts.source[currentLoc].length - 1;	
				currentAlert = alerts.source[currentLoc].getItemAt(alertIndex) as AMBERAlert;
			}
		}
	}
}