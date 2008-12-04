//////////////////////////////////////////////////////////////////////////
//  MarkersClip
//
//  Created by Benjamin Wiederkehr on 081115.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.map{
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import com.modestmaps.Map;
	import com.modestmaps.events.MapEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 *	MarkersClip Class
	 *
	 */
	public class MarkersClip extends Sprite{
		//--------------------------------------
		// VARIABLES
		//--------------------------------------
		private var map								:Map;
		private var xpoints						:Array;
		private var ypoints						:Array;
		private var starting					:Point;
		private var tZoom							:uint
		public var markers						:Array;
		public var locations					:Array;
		/**
		*	@Constructor
		*/
		public function MarkersClip(_map:Map, _locations:Array, _zoom:uint){
			//  DEFINITIONS
			//--------------------------------------
			this.map						= _map;
			this.locations			= _locations;
			xpoints							= new Array();
			ypoints							= new Array();
			//  ADDINGS
			//--------------------------------------
			this.x = map.getWidth() / 2;
			this.y = map.getHeight() / 2;
			//  LISTENERS
			//--------------------------------------
			this.map.addEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
			this.map.addEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
			this.map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
			this.map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
			this.map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
			this.map.addEventListener(MapEvent.PANNED, onMapPanned);
			//  CALLS
			//--------------------------------------
			setPoints();
			setMarkers();
			displayMarkers();
		}
		private function setPoints():void {
			if(locations){
				var p:Point;
				for (var i:int = 0; i < locations.length; i++) {
					p = map.locationPoint(locations[i], this);
					xpoints[i] = p.x;
					ypoints[i] = p.y;
				};
			};
		} // END setPoints()
		private function setMarkers():void{
			markers = new Array();
			for (var i:int = 0; i < locations.length; i++){
				var marker:Marker = new Marker(tZoom);
				addChild(marker);
				marker.x = xpoints[i]; marker.y = ypoints[i];
				markers.push(marker);
			};
		} // END setMarkers()
		private function displayMarkers():void{
			for (var i:int = 0; i < markers.length; i++) {
				Marker(markers[i]).draw();
			};
		} // END displayMarkers()
		private function updatePoints():void{
			setPoints();
			for (var i:int = 0; i < markers.length; i++) {
				Marker(markers[i]).x = xpoints[i];
				Marker(markers[i]).y = ypoints[i];
			};
		} // END updatePoints()
		private function destroy():void {
			map.removeEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
			map.removeEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
			map.removeEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
			map.removeEventListener(MapEvent.START_PANNING, onMapStartPanning);
			map.removeEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
			map.removeEventListener(MapEvent.PANNED, onMapPanned);
			map.removeEventListener(MapEvent.EXTENT_CHANGED, onExtentChanged);
			map.removeEventListener(MapEvent.RESIZED, onMapResized);
		} // END destroy()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function onMapStartZooming(event:MapEvent):void{
			for (var i:int = 0; i < markers.length; i++) {
				Marker(markers[i]).clear();
			};
		} // END onMapStartZooming()
		private function onMapStopZooming(event:MapEvent):void{
			updatePoints();
			for (var i:int = 0; i < markers.length; i++) {
				Marker(markers[i]).draw();
				Marker(markers[i]).scale(event.zoomLevel);
			};
		} // END onMapStopZooming()
		private function onMapZoomedBy(event:MapEvent):void{
		} // END onMapZoomedBy()
		private function onMapStartPanning(event:MapEvent):void{
			starting = new Point(x, y);
		} // END onMapStartPanning()
		private function onMapPanned(event:MapEvent):void{
			if (starting) {
				x = starting.x + event.panDelta.x;
				y = starting.y + event.panDelta.y;
			}else{
				x = event.panDelta.x;
				y = event.panDelta.y;
			};
		} // END onMapPanned()
		private function onMapStopPanning(event:MapEvent):void{
		} // END onMapStopPanning()
		private function onExtentChanged(event:MapEvent):void{
			updatePoints();
		} // END onExtentChanged()
		private function onMapResized(event:MapEvent):void{
			x = event.newSize[0]/2;
			y = event.newSize[1]/2;
			updatePoints();
		} // END onMapResized()
	} // END MarkersClip
} // END package com.flowingdata.gps