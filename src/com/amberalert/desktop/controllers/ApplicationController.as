package com.amberalert.desktop.controllers
{
	import com.amberalert.desktop.models.User;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	import mx.controls.Alert;
	
	[Event(name="setToFirstRun", type="flash.events.Event")]
	[Event(name="setToNotification", type="flash.events.Event")]
	[Event(name="setToSafety", type="flash.events.Event")]
	[Event(name="loadSystemTray", type="flash.events.Event")]
	
	/**
	 * ApplicationController
	 * 
	 * Class that runs on start up and checks to see if the program
	 * has been run before. If it has, it loads the previously stored
	 * data. If it has not, the program enters the "first run" set-up
	 * wizard.
	 * 
	 * @param var userPrefs:User;
	 * @param var sharedObj:SharedObject
	 * @param var internets:ConnectionChecker
	 * @author ASU Amber Alert Team
	 **/
	[Bindable]
	public class ApplicationController extends EventDispatcher
	{
		public var userPrefs:User;
		public var sharedObj:SharedObject;
		public var alertExists:Boolean;
		public var internets:ConnectionChecker;

		private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
		
		/**
		 * grabUserObject
		 * 
		 * Function that check if the program has been run before (by checking
		 * for saved user data). If it has, it loads the previous data. If it
		 * has not, it enters the "first run" set-up wizard.
		 * 
		 * @param var sharedObj:SharedObject
		 * @author ASU Amber Alert Team
		 **/
		public function grabUserObject():void
		{
			// Stuff to manage updates!
			appUpdater.configurationFile = new File("app:/updateConfig.xml");
			appUpdater.initialize();

			sharedObj = SharedObject.getLocal("User");
			//sharedObj.clear();	//TODO: Use this line of code for testing in order to run firstrun again.
			userPrefs = sharedObj.data.User as User;
			
			if(userPrefs == null)
			{
				userPrefs = new User();
				sharedObj.data.User = userPrefs;
				sharedObj.flush();
			}
			
			if(userPrefs.firstRunCompleted)
			{
				setupComplete();
				dispatchEvent(new Event('loadSystemTray'));
			}
			else
				dispatchEvent(new Event('setToFirstRun'));
		}
		/**
		 * setupComplete
		 * 
		 * Function that runs when the user completes the setup wizard and
		 * saves the entered data in the shared object for later use..
		 * 
		 * @param userPrefs:User
		 * @author ASU Amber Alert Team
		 **/
		public function setupComplete():void
		{
			//Copy User object from firstrun
			if(alertExists)
				dispatchEvent(new Event('setToNotification'));
			else
				dispatchEvent(new Event('setToSafety'));
		}
		
		public function saveUserPrefs(user:User):void
		{
			sharedObj.data.User = userPrefs;
			sharedObj.flush();			
			
			if(userPrefs.firstRunCompleted)
			{
				setupComplete();
				dispatchEvent(new Event('loadSystemTray'));
			}
			else
				dispatchEvent(new Event('setToFirstRun'));
			
			Alert.show("Settings have been successfully saved!");
		}
	}
}
