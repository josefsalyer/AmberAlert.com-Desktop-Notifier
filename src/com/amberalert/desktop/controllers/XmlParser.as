package com.amberalert.desktop.controllers
{
	import com.amberalert.desktop.models.AMBERAlert;
	import com.amberalert.desktop.models.Location;
	import com.amberalert.desktop.models.Person;
	import com.amberalert.desktop.models.Vehicle;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class XmlParser
	{
		public function parseAmberAlerts(currentLoc:String, xml:XML):ArrayCollection
		{
			var alertsAC:ArrayCollection = new ArrayCollection();
			var alerts:XML = xml;
			
			for each (var thisAlert:XML in alerts.alert)
			{
				if(currentLoc.localeCompare(thisAlert.@province) == 0)
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
					
					alertsAC.addItem(alert);
				}
			}
			return alertsAC;
		}
	}
}