package com.amberalert.desktop.controllers
{
	// What I need to Work //
	import air.net.URLMonitor;
	
	import flash.events.StatusEvent;
	import flash.net.URLRequest;
	
	[Bindable]
	public class ConnectionChecker
	{
		private var monitor:URLMonitor;
		public static var internets:Boolean;
		
		public function ConnectionChecker()
		{
			monitor = new URLMonitor(new URLRequest('http://amberalert.com'));
			monitor.addEventListener(StatusEvent.STATUS, announceStatus);
			monitor.start();		
		}
		
		private function announceStatus(e:StatusEvent):void
		{
			internets = monitor.available;
		}
		
		/*public function amIConnected():Boolean
		{
			return internets;
		}*/
	}
}