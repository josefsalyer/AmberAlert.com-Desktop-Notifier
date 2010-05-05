package com.amberalert.desktop.controllers
{
	import com.amberalert.desktop.models.AMBERAlert;
	import com.amberalert.desktop.models.Data;
	import com.amberalert.desktop.models.Location;
	import com.amberalert.desktop.models.Person;
	import com.amberalert.desktop.models.Vehicle;
	import com.amberalert.desktop.models.lookups.Provinces;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * XmlParser
	 * 
	 * Action script class that parses Amber ALert XML
	 * 
	 * @param alertsAC:ArrayCollection
	 * @author ASU Amber Alert Team
	 **/
	[Bindable]
	public class XmlParser
	{
		
		/**
		 * parseAmberAlerts
		 * 
		 * Function that inputs an XML and a string containg a state, then
		 * returns an ArrayCollection containing the alert data gathered
		 * from the XML
		 * 
		 * @param alertsAC:ArrayCollection
		 * @param alerts:XML
		 * @author ASU Amber Alert Team
		 **/
		public function parseAmberAlerts(currentLoc:String, xml:XML):Array
		{
			var alertsAC:ArrayCollection = new ArrayCollection();
			var alerts:XML = xml;
			var locations:Provinces = new Provinces();
			var stateAlerts:Array = new Array();
			
			//for each(var locObj:Object in locations.US) <--we only want to parse the alerts.xml once, not 50 times then place the alerts in the appropriate state bucket (array)
				for each (var thisAlert:XML in alerts.alert)
				{
					 
						// Create an Alert Object //
						var alert:AMBERAlert = new AMBERAlert();
						alert.victims = new ArrayCollection();
						alert.suspects = new ArrayCollection();
						alert.vehicles = new ArrayCollection();
						alert.locations = new ArrayCollection();
						alert.uid = thisAlert.@uid;
						alert.issuedDate = thisAlert.@issueDate;
						alert.phone = thisAlert.agency.@publicPhone;
						alert.description = thisAlert.@incidentSummary;
						// Add information for each victim //
						for each(var vic:XML in thisAlert.victims.victim)
						{
							var victim:Person = new Person();
							victim.name	= vic.@firstName + ' ' + vic.@lastName;
							victim.age  = vic.@age;
							victim.gender = vic.@gender;
							victim.dob = vic.@dob;
							victim.height = vic.@heightFt + '\' ' + vic.@heightIn + '\"';
							victim.weight = vic.@weight + ' lbs';
							victim.hair = vic.@hairColor;
							victim.eyes = vic.@eyeColor;
							victim.picture = vic.@thumbnailURL;
							victim.description = chopString(vic.@identityFeatures);
							
							alert.victims.addItem(victim);
						}
						
						// Add information for each suspect //
						for each(var sus:XML in thisAlert.suspects.suspect)
						{
							var suspect:Person = new Person();
							suspect.name	= sus.@firstName + ' ' + sus.@lastName;
							suspect.age  = sus.@age;
							suspect.gender = sus.@gender;
							suspect.dob = sus.@dob;
							suspect.height = sus.@heightFt + '\' ' + sus.@heightIn + '\"';
							suspect.weight = sus.@weight + ' lbs';
							suspect.hair = sus.@hairColor;
							suspect.eyes = sus.@eyeColor;
							suspect.picture = sus.@thumbnailURL;
							suspect.description = chopString(sus.@identityFeatures);
							
							alert.suspects.addItem(suspect);
						}
						// Add information for each vehicle //
						for each(var veh:XML in thisAlert.vehicles.vehicle)
						{
							var vehicle:Vehicle = new Vehicle();
							vehicle.color = veh.@color;
							vehicle.make = veh.@make;
							vehicle.model = veh.@model;
							vehicle.year = veh.@year;
							vehicle.plate = veh.@lPlateNumber;
							vehicle.description = veh.@description;
							vehicle.picture = veh.@thumbnailImage;
							
							alert.vehicles.addItem(vehicle);
						}
						// Add information for each location //
						for each(var loc:XML in thisAlert.locations.location)
						{
							var location:Location = new Location();
							location.city = loc.@city;
							location.province = loc.@province;
							location.lastSeenLat = loc.@latitude;
							location.lastSeenLon = loc.@longitude;
							
							alert.locations.addItem(location);
						}
						
						if(stateAlerts[thisAlert.@province] == null) 
							stateAlerts[thisAlert.@province] = new Array(); //creates a new arrayCollection with the state abbr. as the index
								
						stateAlerts[thisAlert.@province].push(alert);
				}
				
				return stateAlerts[currentLoc];
		}
		
		private function chopString(inputString:String):String{
			var maxDescriptionLengthMinusThree:int = 65;
			if(inputString.length > maxDescriptionLengthMinusThree)
				return inputString.substring(0, maxDescriptionLengthMinusThree) + "...";
			else
				return inputString;
		}
	}
}
