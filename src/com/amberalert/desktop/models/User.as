package com.amberalert.desktop.models
{
	
	

	/**
	 * The user model.  Mostly a singleton used to track the current logged in user's preferences
	 * 
	 * @author Josef Salyer
	 * @updated 08FEB2010
	 * @version 1.0
	 * 
	 * @param email User's email address
	 * @param cellNumber User's cell phone number
	 * @param cellProvider User's cell phone number
	 * @param zip User's ZIP Code of choice
	 * @param storeAlerts Store previously viewed alerts on the user's machine?
	 * */
	
	[RemoteClass]
	[Bindable]
	public class User
	{
		/**
		 * a properly formatted email address.  validation done in the view
		 * */
		public var email			:String		=	"";
		
		/**
		 * a properly formated phone number.  validation done in the view
		 * */
		public var cellNumber		:String		=	"";
		
		/**
		 * enumerated value selected from assets.data.Providers
		 * @see assets.data.Providers
		 * */
		public var cellProvider		:String		=	"";
		
		/**
		 * A regional representation of the area that the user would like to receive alerts for.
		 * */
		public var province			:String		=	null;
		
		public var serviceProvider :String	= 	"";
		
		/**
		 * this value is set to true initially so that alerts are stored in the LSO of the users computer
		 * for offline functions
		 * */
		public var storeAlerts		:Boolean	=	true;
		
		/**
		 * this value is set to true initially so that alerts are sent to the user's email
		 * */
		public var subscribeEmail	:Boolean	=	false;
		
		/**
		 * this gives the option for the user to receive alerts via SMS.
		 * */
		public var subscribeSMS		:Boolean	=	false;
		
		/**
		 * this gives the option for the user to receive alerts via RSS Feed.
		 * */
		public var subscribeRSS		:Boolean	=	false;
		
		/**
		 * Boolean representation of whether the user has completed the firstrun setup.
		 * */
		public var firstRunCompleted	:Boolean	=	false;
		 
	}
}
