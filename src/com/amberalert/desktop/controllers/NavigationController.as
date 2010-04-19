package com.amberalert.desktop.controllers
{
	import com.amberalert.desktop.models.Destinations;
	
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.NotificationType;
	import flash.desktop.SystemTrayIcon;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	[Bindable]
	public class NavigationController extends EventDispatcher
	{
		
		public var currentState:String = Destinations.FIRST_RUN;
		public var stage:Stage;
		public var alertExists:Boolean;
		
		public function setCurrentView(destination:String):void
		{
			currentState = destination;
		}
		
		//This sets the stage in which it is coming from the view, it also loads the system tray icon/dock icon
		public function loadNav(value:Stage):void
		{
			stage = value;
			
			//Load system tray icon / dock icon.
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, prepareForSystray);
			try {loader.load(new URLRequest("/assets/icons/aa16.png"));}
			catch(error:Error){trace("Unable to load icon.");}
		}
		
		private function prepareForSystray(event:Event):void 
		{
			//Retrieve the image being used as the systray/dock icon				
			var dockImage:BitmapData = event.target.content.bitmapData;
			NativeApplication.nativeApplication.icon.bitmaps = [dockImage];
			
			if(NativeApplication.supportsDockIcon) //Mac
			{
				var dockIcon: DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, trayIcon_click);
				dockIcon.menu = createIconMenu();
			}
			else if (NativeApplication.supportsSystemTrayIcon) //Windows
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip = "AMBERAlert.com";
				SystemTrayIcon(NativeApplication.nativeApplication.icon).addEventListener(MouseEvent.CLICK, trayIcon_click);
				stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, windowMinimized);
				SystemTrayIcon(NativeApplication.nativeApplication.icon).menu = createIconMenu();
			}
		}
		
		private function trayIcon_click(evt:Event):void 
		{
			if(currentState != Destinations.FIRST_RUN) 
			{ 
				if(currentState != Destinations.NOTIFICATION) 
				{
					if(alertExists)
						showAlerts();
					else
						showSafetyTips();
				}
					
				else
				{
					stage.nativeWindow.visible = true;
					stage.nativeWindow.orderToFront();
				}
			}
		}
		
		private function windowMinimized(displayStateEvent:NativeWindowDisplayStateEvent):void 
		{
			if(displayStateEvent.afterDisplayState == NativeWindowDisplayState.MINIMIZED)
			{
				displayStateEvent.preventDefault();
				dock();
			}
		}
		
		private function createIconMenu():NativeMenu
		{
			var cmdActiveAlerts: NativeMenuItem = new NativeMenuItem("Active Alerts");
			var cmdSafetyTips:   NativeMenuItem = new NativeMenuItem("Child Safety Tips");
			var cmdSettings:     NativeMenuItem = new NativeMenuItem("Settings");
			var cmdAbout:        NativeMenuItem = new NativeMenuItem("About us...");
			var cmdQuit:         NativeMenuItem = new NativeMenuItem("Exit");
			var menu:NativeMenu = new NativeMenu();
			
			//Add event listeners
			cmdActiveAlerts.addEventListener(Event.SELECT, showAlerts);
			cmdSafetyTips.addEventListener(Event.SELECT, showSafetyTips);
			cmdSettings.addEventListener(Event.SELECT, showSettings);
			cmdAbout.addEventListener(Event.SELECT, showAbout);
			cmdQuit.addEventListener(Event.SELECT, closeFromIcon);
			
			//Add menu items to the menu.
			menu.addItem(cmdActiveAlerts);
			menu.addItem(cmdSafetyTips);
			menu.addItem(cmdSettings);
			menu.addItem(cmdAbout);
			menu.addItem(new NativeMenuItem("",true)); //Separator
			menu.addItem(cmdQuit);
			
			return menu;
		}
		
		public function showAlerts(event:Event = null):void 
		{
			//TODO: Slide up the alert notification. Make it work.
			currentState = Destinations.NOTIFICATION;
			stage.nativeWindow.visible = true;
			stage.nativeWindow.orderToFront();
			notify();
			
			/*var n: NativeWindowInitOptions = new NativeWindowInitOptions();
			n.systemChrome = NativeWindowSystemChrome.NONE;
			n.type = NativeWindowType.LIGHTWEIGHT;
			n.transparent = true;
			
			var w:NativeWindow = new NativeWindow(n);
			NativeApplication.nativeApplication.activate(w);
			w.orderToFront();*/
			
			//Set timer to close notification window
		}
		
		public function showSafetyTips(event:Event = null):void 
		{
			currentState = Destinations.SAFETY_TIPS;
			stage.nativeWindow.visible = true;
			stage.nativeWindow.orderToFront();
		}
		
		public function showSettings(event:Event = null):void 
		{
			currentState = Destinations.SETTINGS;
			stage.nativeWindow.visible = true;
			stage.nativeWindow.orderToFront();
		}
		
		public function showAbout(event:Event = null):void 
		{
			currentState = Destinations.ABOUT;
			stage.nativeWindow.visible = true;
			stage.nativeWindow.orderToFront();
		}
		
		public function closeFromIcon(event:Event = null):void
		{
			stage.nativeWindow.close();
		}
		
		private function notify():void
		{
			if(NativeApplication.supportsDockIcon)
			{
				var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				dock.bounce(NotificationType.CRITICAL);
			} 
			
			if (NativeApplication.supportsSystemTrayIcon)
				stage.nativeWindow.notifyUser(NotificationType.CRITICAL);
		}
		
		//TODO: For some reason, closing with Alt-F4 sometimes makes
		//the system tray icon disappear but the application continues
		//running invisibly. Make it work.
		public function closeSetupWarning():void
		{
			if(currentState == Destinations.FIRST_RUN)
				Alert.show("Are you sure you want to cancel setup?", "Cancel Setup", Alert.YES | Alert.NO,null, closingFromSetup, null, Alert.YES);
			else if(currentState == Destinations.DOCKED)
				stage.nativeWindow.close();
			else
				dock();
		}
		
		private function dock():void 
		{
			currentState = Destinations.DOCKED;
			stage.nativeWindow.visible = false;
		}
		
		private function closingFromSetup(eventObj:CloseEvent):void 
		{
			if (eventObj.detail==Alert.YES)
				stage.nativeWindow.close();
		}
	}
}