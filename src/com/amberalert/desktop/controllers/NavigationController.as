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
	
	/**
	 * NavigationController
	 * 
	 * Class that manages all the different states of the program.
	 * 
	 * @param var currentState:String
	 * @author ASU Amber Alert Team
	 **/
	[Bindable]
	public class NavigationController extends EventDispatcher
	{
		
		public var currentState:String = Destinations.FIRST_RUN;
		public var stage:Stage;
		public var alertExists:Boolean;
		
		/**
		 * setCurrentView
		 * 
		 * Function that changes the current state of the program to the
		 * inputted string.
		 * 
		 * @param var currentState:String
		 **/
		public function setCurrentView(destination:String):void
		{
			currentState = destination;
		}
		
		/**
		 * loadNav
		 * 
		 * Function that sets the stage in which it is coming from the 
		 * view, it also loads the system tray icon/dock icon.
		 * 
		 * @param var stage:Stage
		 **/
		public function loadNav(mainStage:Stage):void
		{
			stage = mainStage;
			//Load system tray icon / dock icon.
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, prepareForSystray);
			try {loader.load(new URLRequest("/assets/icons/aa16.png"));}
			catch(error:Error){trace("Unable to load icon.");}
		}
		
		/**
		 * prepareForSystray
		 * 
		 * Function that loads Systray icon, sets the icon on the Systray.
		 * 
		 * @param var dockImage:BitmapData
		 **/
		public function resizeAndMoveWindow(width:Number=-100000,height:Number=-100000,x:Number=-100000,y:Number=-100000):void
		{
			if(width != -100000)
				NativeApplication.nativeApplication.activeWindow.width = width;	
			
			if(height != -100000)
				NativeApplication.nativeApplication.activeWindow.height = height;
			
			if(x != -100000)
				NativeApplication.nativeApplication.activeWindow.x = x;
				
			if(y != -100000)
				NativeApplication.nativeApplication.activeWindow.y = y;
		}
		
		private function prepareForSystray(event:Event):void 
		{
			//Retrieve the image being used as the systray/dock icon				
			var dockImage:BitmapData = event.target.content.bitmapData;
			NativeApplication.nativeApplication.icon.bitmaps = [dockImage];
			
			if(NativeApplication.supportsDockIcon) //Mac
			{
				//var dockIcon: DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, trayIcon_click);
				//dockIcon.menu = createIconMenu();
			}
			else if (NativeApplication.supportsSystemTrayIcon) //Windows
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip = "AMBERAlert.com";
				SystemTrayIcon(NativeApplication.nativeApplication.icon).addEventListener(MouseEvent.CLICK, trayIcon_click);
				stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, windowMinimized);
				//SystemTrayIcon(NativeApplication.nativeApplication.icon).menu = createIconMenu();
			}
		}
		
		public function prepareMenu():void
		{
			if(NativeApplication.supportsDockIcon) //Mac
			{
				var dockIcon: DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				dockIcon.menu = createIconMenu();
			}
			else if (NativeApplication.supportsSystemTrayIcon) //Windows
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).menu = createIconMenu();
			}
		}
		
		/**
		 * trayIcon_click
		 * 
		 * Function that handles the proper events once the tray icon
		 * is clicked.
		 **/
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
					bringWindowToFront();
				}
			}
		}
		
		/**
		 * windowMinimized
		 * 
		 * Function that controls the events once the desktop notifier window
		 * gets minimized.
		 **/
		private function windowMinimized(displayStateEvent:NativeWindowDisplayStateEvent):void 
		{
			if(displayStateEvent.afterDisplayState == NativeWindowDisplayState.MINIMIZED)
			{
				displayStateEvent.preventDefault();
				dock();
			}
		}
		
		/**
		 * createIconMenu
		 * 
		 * Creates the menu that's displayed and accesed from the system tray. As well
		 * as creates the event handelers for each menu item.
		 **/
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
		
		/**
		 * showAlerts
		 * 
		 * Function that changes to the alert notification state and view which
		 * displays any active Amber Alerts in a given state
		 **/
		public function showAlerts(event:Event = null):void 
		{
			//TODO: Slide up the alert notification. Make it work.
			currentState = Destinations.NOTIFICATION;
			bringWindowToFront();
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
		
		/**
		 * showSafetyTips
		 * 
		 * Function that switches the current state and view to display child
		 * safety tips acquired from the web.
		 **/
		public function showSafetyTips(event:Event = null):void 
		{
			currentState = Destinations.SAFETY_TIPS;
			bringWindowToFront();
		}
		
		/**
		 * showSettings
		 * 
		 * Function that switches the current state and view to display the
		 * settings. Also from which they can be changed.
		 **/
		public function showSettings(event:Event = null):void 
		{
			currentState = Destinations.SETTINGS;
			bringWindowToFront();
		}
		
		/**
		 * showAbout
		 * 
		 * Function that switches the current state and view to the "about"
		 * information.
		 **/
		public function showAbout(event:Event = null):void 
		{
			currentState = Destinations.ABOUT;
			bringWindowToFront();
		}
		
		/**
		 * closeFromIcon
		 * 
		 * Function that quits the application by exiting from the system
		 * tray.
		 **/
		public function closeFromIcon(event:Event = null):void
		{
			stage.nativeWindow.close();
		}
		
		/**
		 * notify
		 * 
		 * Function that notifies the user of an event through the syetem
		 * tray icon.
		 **/
		public function bringWindowToFront():void
		{
			stage.nativeWindow.visible = true;
			stage.nativeWindow.orderToFront();
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
		/**
		 * closeSetupWarning
		 * 
		 * Function that displays an "are you sure" message when closing during
		 * the setup wizard.
		 **/
		public function closeSetupWarning():void
		{
			if(currentState == Destinations.FIRST_RUN)
				Alert.show("Are you sure you want to cancel setup?", "Cancel Setup", Alert.YES | Alert.NO,null, closingFromSetup, null, Alert.YES);
			else if(currentState == Destinations.DOCKED)
				stage.nativeWindow.close();
			else
				dock();
		}
		
		/**
		 * dock
		 *
		 * Minimize the program to the system dock
		 **/
		private function dock():void 
		{
			currentState = Destinations.DOCKED;
			stage.nativeWindow.visible = false;
		}
		
		/**
		 * closingFromSetup
		 *
		 * Event handler for when a user exits from first-run
		 **/
		private function closingFromSetup(eventObj:CloseEvent):void 
		{
			if (eventObj.detail==Alert.YES)
				stage.nativeWindow.close();
		}
	}
}
