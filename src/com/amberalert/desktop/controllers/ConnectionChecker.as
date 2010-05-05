package com.amberalert.desktop.controllers
{
	// What I need to Work //
	import air.net.URLMonitor;
	
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.net.URLRequest;
	
	[Event(name="internetStatusChange", type="flash.events.Event")]
	[Bindable]
	public class ConnectionChecker
	{
		private var monitor:URLMonitor;
		public static var internets:Boolean;
		
		/**
		 * ConnectionChecker
		 * 
		 * ConnectionCheck constructor that starts monitoring the current
		 * network connection
		 * 
		 * @param var monitor:URLMonitor
		 * @author ASU Amber Alert Team
		 **/
		public function ConnectionChecker()
		{
			monitor = new URLMonitor(new URLRequest('http://www.amberalert.com'));
			monitor.addEventListener(StatusEvent.STATUS, announceStatus);
			monitor.start();		
		}
		
		/**
		 * announceStatus
		 * 
		 * Function that saves any changes to the state of the current
		 * internet connection
		 * 
		 * @param var internets:Boolean
		 * @author ASU Amber Alert Team
		 **/
		private function announceStatus(e:StatusEvent):void
		{
			internets = monitor.available;
			dispatchEvent(new Event('internetStatusChange'));
		}
	}
}