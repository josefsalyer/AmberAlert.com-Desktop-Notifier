package com.amberalert.desktop.models
{
	import mx.collections.ArrayCollection;

	public class AMBERAlert
	{
		public var uid:String;
		public var issuedDate:String;
		public var phone:String;
		public var victims:ArrayCollection = null;
		public var suspects:ArrayCollection = null;
		public var vehicles:ArrayCollection = null;
		public var locations:ArrayCollection = null;
	}
}