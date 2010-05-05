package com.amberalert.desktop.models
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class AMBERAlert
	{
		public var uid:String;
		public var issuedDate:String;
		public var phone:String;
		public var victims:ArrayCollection = null;
		public var suspects:ArrayCollection = null;
		public var vehicles:ArrayCollection = null;
		public var locations:ArrayCollection = null;
		public var description:String;
		
		public function get url():String
		{
			return 'http://www.amberalert.com/alerts/' + uid;
		}
	}
}