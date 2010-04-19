package com.amberalert.desktop.controllers
{
	import com.amberalert.desktop.models.User;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	[Event(name="setToFirstRun", type="flash.events.Event")]
	[Event(name="setToNotification", type="flash.events.Event")]
	[Event(name="setToSafety", type="flash.events.Event")]
	
	[Bindable]
	public class ApplicationController extends EventDispatcher
	{
		
		public var userPrefs:User;
		public var sharedObj:SharedObject;
		public var alertExists:Boolean;
		public var internets:ConnectionChecker;
	
		public function setupConnection():void
		{
			internets = new ConnectionChecker;
		}
		
		public function grabUserObject():void
		{
			setupConnection();
			
			sharedObj = SharedObject.getLocal("User");
			//sharedObj.clear();	//TODO: Use this line of code for testing in order to run firstrun again.
			
			if(userDataIsComplete())
				setupComplete();
			else
				dispatchEvent(new Event('setToFirstRun'));
		}
		
		public function setupComplete():void
		{
			//Copy User object from firstrun
			sharedObj = SharedObject.getLocal("User");
			userPrefs = sharedObj.data.User as User;
			
			if(alertExists)
				dispatchEvent(new Event('setToNotification'));
			else
				dispatchEvent(new Event('setToSafety'));
		}
		
		private function isValid_Phone(phone:String):Boolean{
			//TODO: Complete this function.
			// I have some pre-coded classes that can take care of this.
			return true;
		}
		
		private function isValid_Email(email:String):Boolean{
			//TODO: Complete this function.
			// I have some pre-coded classes that can take care of this.
			if(email.length == 0)
				return false;
			else
				return true;
		}
		
		private function isValid_ZIPCode(zip:String):Boolean{
			if(zip.length == 0 || (zip.length == 5 && !isNaN(Number(zip))))
				return true;
			else
				return false;
		}
		
		private function userDataIsComplete():Boolean{
			if(sharedObj.data.firstrun == null){
				sharedObj.data.firstrun = "no";	//Ensures that the user finishes setup.
				return false;
			}
			else{
				if(sharedObj.data.firstrun == "no")
					return false;
				else
				{
					//Check that the user has the required information in sharedObj.data
					if(sharedObj.data.User == null)
						return false;
					else{
						userPrefs = sharedObj.data.User as User;
						if(userPrefs == null){
							return false;
						}
						else
						{
							if(!isValid_Email(userPrefs.email) || !isValid_ZIPCode(userPrefs.zip)){
								//NTS: Can add more conditions here if desired.
								return false;
							}
							else{
								return true;
							}
						}
					}
				}
			}
		}
	}
}