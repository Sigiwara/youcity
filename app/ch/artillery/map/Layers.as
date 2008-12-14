//////////////////////////////////////////////////////////////////////////
//  Layers
//
//  Created by Benjamin Wiederkehr on 081130.
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
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 *	Layers Class
	 *
	 */
	public class Layers extends Sprite{
		//--------------------------------------
		// VARIABLES
		//--------------------------------------
		private var map								:Map;
		private var starting					:Point;
		private var coordinates				:Array;
		private var params						:Array;
		private var classes						:Array;
		private var overlays					:Array;
		public var points							:Array;
		public var overlayers					:Array;
		public var layers							:Array;
		public var cityLayer					:Sprite;
		public var lakeLayer					:Sprite;
		/**
		*	@Constructor
		*/
		public function Layers(_dc:DocumentClass, _map:Map, _coordinates:Array, _params:Array){
			//  DEFINITIONS
			//--------------------------------------
			this.map						= _map;
			this.coordinates		= _coordinates;
			this.params					= _params;
			this.points					= new Array();
			this.layers					= new Array();
			this.overlayers			= new Array();
			//this.overlays				= new Array('swf/overlays/seeflaeche.swf', 'swf/overlays/gebaeudeflaeche.swf');
			this.overlays				= new Array('swf/overlays/seeflaeche.swf');
			this.cityLayer			= new Sprite();
			this.lakeLayer			= new Sprite();
			//  ADDINGS
			//--------------------------------------
			this.x 									= map.getWidth() / 2;
			this.y 									= map.getHeight() / 2;
			//  LISTENERS
			//--------------------------------------			
			this.addEventListener(MouseEvent.MOUSE_DOWN, map.grid.mousePressed, true);
			this.addEventListener(MouseEvent.MOUSE_UP, map.grid.mouseReleased);
			this.map.addEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
			this.map.addEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
			this.map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
			this.map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
			this.map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
			this.map.addEventListener(MapEvent.PANNED, onMapPanned);
			//  CALLS
			//--------------------------------------
			setCoordinates();
			setLayers();
		}
		private function setCoordinates():void{
			var p:Point;
			for (var i:int = 0; i < coordinates.length; i++) {
				p = map.locationPoint(coordinates[i], this);
				points[i] = p;
			};
		} // END setCoordinates()
		private function setLayers():void{
			for (var i:int = 0; i < params.length; i++){
				var layer:Layer = new Layer(i, this, params[i].klasse);
				this.addChild(layer);
				layer.x				= points[0].x;
				layer.y				= points[0].y;
				layer.width		= points[1].x - points[0].x;
				layer.height	= points[1].y - points[0].y;
				layer.name		= 'layer' + i.toString();
				//layer.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick)
				//layer.doubleClickEnabled = true;
				layers.push(layer);
			};
			for (var j:int = 0; j<overlays.length; j++){
				var oLayer:OverlayLayer = new OverlayLayer(this, overlays[j]);
				this.addChild(oLayer);
				oLayer.x				= points[0].x;
				oLayer.y				= points[0].y;
				oLayer.width		= points[1].x - points[0].x;
				oLayer.height		= points[1].y - points[0].y;
				if(j==0){
					oLayer.alpha		= 1;
				}else{
					oLayer.alpha		= .25;
				}
				overlayers.push(oLayer);
			}
		} // END setLayers()
		private function displayLayers():void{
			for (var i:int = 0; i < layers.length; i++) {
				layers[i].show();
			};
			for (var j:int = 0; j < overlayers.length; j++) {
				overlayers[j].show();
			};
		} // END displayLayers()
		private function hideLayers():void{
			for (var i:int = 0; i < layers.length; i++) {
				layers[i].hide();
			};
			for (var j:int = 0; j < overlayers.length; j++) {
				overlayers[j].hide();
			};
		} // END hideLayers()
		private function updatePoints():void{
			setCoordinates();
			for (var i:int = 0; i < layers.length; i++) {
				layers[i].x				= points[0].x;
				layers[i].y				= points[0].y;
				layers[i].width		= points[1].x - points[0].x;
				layers[i].height	= points[1].y - points[0].y;
			};
			for (var j:int = 0; j < overlayers.length; j++) {
				overlayers[j].x				= points[0].x;
				overlayers[j].y				= points[0].y;
				overlayers[j].width		= points[1].x - points[0].x;
				overlayers[j].height	= points[1].y - points[0].y;
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
		//  PUBLIC METHODS
		//--------------------------------------
		public function toggleOverlays(_e:MouseEvent):void{
			for (var j:int = 0; j < overlayers.length; j++) {
				overlayers[j].toggle();
			};
		} // END toggleOverlays()
		public function updateLayer(_layer):void{
			_layer.x				= points[0].x;
			_layer.y				= points[0].y;
			_layer.width		= points[1].x - points[0].x;
			_layer.height		= points[1].y - points[0].y;
		} // END updateLayer()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function onMapStartZooming(event:MapEvent):void{
			hideLayers();
		} // END onMapStartZooming()
		private function onMapStopZooming(event:MapEvent):void{
			displayLayers();
			updatePoints();
		} // END onMapStopZooming()
		private function onMapZoomedBy(event:MapEvent):void{
		} // END onMapZoomedBy()
		private function onMapStartPanning(event:MapEvent):void{
			starting = new Point(this.x, this.y);
		} // END onMapStartPanning()
		private function onMapPanned(event:MapEvent):void{
			if (starting) {
				this.x = starting.x + event.panDelta.x;
				this.y = starting.y + event.panDelta.y;
			}else{
				this.x = event.panDelta.x;
				this.y = event.panDelta.y;
			};
		} // END onMapPanned()
		private function onMapStopPanning(event:MapEvent):void{
		} // END onMapStopPanning()
		private function onExtentChanged(event:MapEvent):void{
			updatePoints();
		} // END onExtentChanged()
		private function onMapResized(event:MapEvent):void{
			this.x = event.newSize[0]/2;
			this.y = event.newSize[1]/2;
			updatePoints();
		} // END onMapResized()
	} // END Layers
} // END package ch.artillery.map