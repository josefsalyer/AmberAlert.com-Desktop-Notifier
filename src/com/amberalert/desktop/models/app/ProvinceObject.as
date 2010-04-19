package com.amberalert.desktop.models.app
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ProvinceObject
	{
		public var name			:	String;
		public var abbr			:	String;
		public var path			:	String;
		public var centerLatLng	:	String;
		public var zoomLevel	:	Number;
		public var polygon		:	String;
		public var activeAlerts	:	ArrayCollection;
		public var closedAlerts	:	ArrayCollection;
		public var activeMarkers:	ArrayCollection;
		public var closedMarkers:	ArrayCollection;
		public var markerOptions:	ArrayCollection;
	}
}