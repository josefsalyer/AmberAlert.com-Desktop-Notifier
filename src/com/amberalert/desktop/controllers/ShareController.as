package com.amberalert.desktop.controllers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.iotashan.utils.URLEncoding;
	
	public class ShareController extends EventDispatcher
	{
		public var fb:FacebookUtil;
		private var msg:String;
		
		public function facebook(message:String):void
		{
			msg = message;
			fb = new FacebookUtil();
			fb.authenticate();
			fb.addEventListener('authorized', handleAuthorization);
			
		}
		
		private function handleAuthorization(event:Event):void
		{
			fb.getme();
			fb.addEventListener('gotme',handleIdentity);
		}
		
		private function handleIdentity(event:Event):void
		{
			fb.feed(msg);
		}
		
		public function twitter(message:String):void
		{
			var request:URLRequest = new URLRequest('http://twitter.com?status=' + URLEncoding.encode(message));
			navigateToURL(request, '_blank');
		}
		
		public function rss():void
		{
			trace('rss');
		}
		
		public function email(message:String):void
		{
			var request:URLRequest = new URLRequest('mailto:?subject=' + 'I am sharing an AMBER Alert with you' + '&body=Find out more here: ' + URLEncoding.encode(message));
			navigateToURL(request, '_blank');
		}
		
	}
}