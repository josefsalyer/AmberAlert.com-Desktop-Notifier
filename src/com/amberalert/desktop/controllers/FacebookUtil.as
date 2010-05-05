package com.amberalert.desktop.controllers
{
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.core.FlexGlobals;
	import mx.core.Window;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	import mx.utils.DisplayUtil;
	
	[Event("authorized",true,false)]
	[Event("gotme",true,false)]
	public class FacebookUtil extends EventDispatcher
	{
	
		private var html:HTMLLoader;
		private var token:String;
		private var user:Object;
		
		public static const CLIENT_ID		:String = ""; // this is your Facebook Application ID
		
		public static const GRAPH			:String = "https://graph.facebook.com/";
		public static const REQUEST_TOKEN	:String = "https://graph.facebook.com/oauth/authorize";
		public static const REDIRECT_URI	:String = "http://www.facebook.com/connect/login_success.html";  //this is a dummy page that handles the redirect after login
		
		public var service:HTTPService;
		
		public function FacebookUtil()
		{
			service = new HTTPService();
			service.useProxy = false;
			service.addEventListener(ResultEvent.RESULT, resultHandler);
			service.addEventListener(FaultEvent.FAULT,faultHandler);
		}
		
		
		public function feed(msg:String):void
		{
			var params:Object = new Object();
			params.link = msg; //info.text;
			service.method = "POST";
			service.url = GRAPH + "me/feed?access_token=" + token;
			service.send(params);
		}
		
		public function friends(event:MouseEvent):void
		{
			var params:Object = new Object();
			params.key = "";
			
			service.method = "GET";
			service.url = GRAPH + "me/friends?access_token=" + token;
			service.send(params);
			
		}
		
		public function authenticate():void
		{
			var so:SharedObject = SharedObject.getLocal("facebook");
			var savedToken:String = so.data["accessToken"];
			
			var options:NativeWindowInitOptions = new NativeWindowInitOptions(); 
			var windowBounds:Rectangle = new Rectangle(10,10,820,420);
			
			html 		= HTMLLoader.createRootWindow( true, options, true, windowBounds);
			html.width 	= 600; 
			html.height = 400; 	
			
			//the type is user_agent as opposed to user-agent in the docs
			var urlReq:URLRequest = new URLRequest(REQUEST_TOKEN + "?client_id=" + CLIENT_ID + "&redirect_uri=" + REDIRECT_URI + "&type=user_agent&display=popup&scope=publish_stream"); 
			
			html.load(urlReq);
			html.addEventListener(Event.LOCATION_CHANGE, handleLocationChange);
			
		}
		
		public function getme():void
		{
			var request:URLRequest = new URLRequest(GRAPH + "me" + "?access_token=" + token);
			request.useCache = false;
			var loader:URLLoader = new URLLoader(request);
			loader.addEventListener(Event.COMPLETE, getUserResultHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, getUserFaultHandler);
			
		}	
		
		protected function handleLocationChange(event:Event):void
		{
			var location:String = event.currentTarget.location;
			
			if ( location.search('#access_token=') > -1 ) {
				token = location.substr(location.search('=')+1);
				saveToken(token);
				
				var parent:DisplayObjectContainer = html.parent;
				var window:NativeWindow = parent['nativeWindow'];
				window.close();
				dispatchEvent(new Event('authorized'));
				
			}
		}
		
		protected function saveToken(tokenToSave:String):void
		{
			var so:SharedObject 	= SharedObject.getLocal("facebook");
			so.data["accessToken"] 	= tokenToSave
			so.flush();
		}
		
		protected function getUserResultHandler(event:Event):void
		{
			trace(event.type);
			//store the facebook user id for later ca	
			var decoder:JSONDecoder = new JSONDecoder(event.currentTarget.data, false);
			user = decoder.getValue();
			dispatchEvent(new Event('gotme'));
		}	
		
		
		protected function getUserFaultHandler(event:*):void
		{
			trace(event.fault.content);
		}
		
		
		protected function resultHandler(event:Event):void
		{
			trace(event.type);
		}
		
		protected function faultHandler(event:*):void
		{
			trace(event.fault);
		}
		
	}
}