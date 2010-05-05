package com.amberalert.desktop.controllers
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	
	import com.amberalert.desktop.models.User;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import mx.controls.Alert;
	
	[Event(name="setToFirstRun", type="flash.events.Event")]
	[Event(name="setToNotification", type="flash.events.Event")]
	[Event(name="setToSafety", type="flash.events.Event")]
	[Event(name="loadSystemTray", type="flash.events.Event")]
	[Event(name="emailSignUp", type="flash.events.Event")]
	[Event(name="smsSignUp", type="flash.events.Event")]
	
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

		private var appUpdater:ApplicationUpdaterUI;
		
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
			appUpdater = new ApplicationUpdaterUI();
			appUpdater.configurationFile = new File("app:/updateConfig.xml");
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, updaterInitialized);
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
		 **/
		public function setupComplete():void
		{
			//Copy User object from firstrun
			if(alertExists)
				dispatchEvent(new Event('setToNotification'));
			else
				dispatchEvent(new Event('setToSafety'));
		}
		
		/**
		 * saveUserPrefs
		 * 
		 * Function that saves the user entered preferences to be
		 * retrieved the next time the program is run.
		 * 
		 * @param userPrefs:User
		 **/
		public function saveUserPrefs(user:User):void
		{
			//first check to see if any of the data has changed from what is stored OR if it's new
			if(user.subscribeEmail == true) {
				if(user.email != null || user.email != sharedObj.data.User.email) {
					userPrefs = user; //save the fresh data to the externally exposed current user data
					dispatchEvent(new Event('emailSignUp')); //dispatch the event to main glue
				}
			}
			
			if(user.subscribeSMS == true) {
				if(user.cellNumber != null || user.cellNumber != sharedObj.data.User.cellNumber) {
					if(user.cellProvider != null) {
						user.cellNumber = PhoneFormatter.strip(user.cellNumber);
						userPrefs = user; //save the fresh data to the externally exposed current user data
						dispatchEvent(new Event('smsSignUp')); //dispatch the event to main glue
					}
				}
			}			
			//finally save the freshest data to the shared object and everythign should be in sync
			sharedObj.data.User = user;
			sharedObj.flush();	
			
			
			if(userPrefs.firstRunCompleted)
			{
				setupComplete();
				dispatchEvent(new Event('loadSystemTray'));
			} else {
				dispatchEvent(new Event('setToFirstRun'));
			}
			Alert.show("Settings have been successfully saved!");
		}
		
		/**
		 * updateInitialized
		 * 
		 * Checks to see if there have been any new versions of the
		 * application posted to the hosting site.
		 **/
		private function updaterInitialized(event:UpdateEvent):void
		{
			appUpdater.checkNow();
		}
	}
}
