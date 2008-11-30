//////////////////////////////////////////////////////////////////////////
//  Document Class
//
//  Created by Benjamin Wiederkehr on 081114.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package {
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import ch.artillery.map.MarkersClip;
	import ch.artillery.ui.GUI;
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.yahoo.*;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.ColorTransform;
	import flash.net.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import fl.motion.easing.*;
	//--------------------------------------
	// METADATA
	//--------------------------------------
	[SWF(width="1200", height="768", frameRate="32", backgroundColor="#EEEEEE")]

	/**
	 *	DocumentClass of the YouCity project.
	 *
	 *	@langversion		ActionScript 3.0
	 *	@playerversion	Flash 9.0
	 *	@author					Benjamin Wiederkehr
	 *	@since					081114
	 *	@version				0.1
	 */
	public class DocumentClass extends Sprite{
		//--------------------------------------
		//  VARIABLES
		//--------------------------------------
		public var map					:Map;
		private var mapEx				:MapExtent;
		private var mapProv			:YahooRoadMapProvider;
		private var mapWidth		:Number;
		private var mapHeight		:Number;
		private var markers			:MarkersClip;
		private var urlLoader		:URLLoader;
		private var locations		:Array;
		private var color				:Boolean;
		private var waiter			:TextField;
		private var gui					:GUI;
		
		public var params				:Array;
		public var layers				:Array;
		//--------------------------------------
		//  CONSTANTS
		//--------------------------------------
		private const T_FONT		:String	= 'Arial';
		private const T_COLOR		:uint		= 0xFFFFFF;
		private const T_SIZE		:uint		= 16;
		/**
		*	@Constructor
		*/
		public function DocumentClass(){
			//  SETTINGS
			//--------------------------------------
			this.stage.scaleMode	= StageScaleMode.NO_SCALE;
			this.stage.quality		= StageQuality.HIGH;
			this.stage.align			= StageAlign.TOP_LEFT;
			//  DEFINITIONS
			//--------------------------------------
			mapWidth							= stage.stageWidth;
			mapHeight							= stage.stageHeight;
			locations							= new Array();
			params								= new Array();
			//layers								= new Array(Gruenflaeche,23,34);
			color									= true;
			//  CALLS
			//--------------------------------------
			setWaiter();
			setMap();
			colorizeMap();
			loadData('xml/params.xml', onLoadParams);
			//loadData('xml/parcells.xml', onLoadParcells);
		} // END DocumentClass()
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		private function setWaiter():void{
			waiter				= new TextField();
			waiter.text		= 'loading data';
			formatText(waiter, 0xDDDDDD, 60)
			waiter.width	= waiter.textWidth + 10;
			waiter.height	= waiter.textHeight + 10;
			waiter.x			= this.stage.stageWidth / 2 - waiter.textWidth / 2;
			waiter.y			= this.stage.stageHeight / 2 - waiter.textHeight / 2;;
			addChild(waiter);
		} // END setWaiter()
		private function setMap():void{
			mapProv	= new YahooRoadMapProvider();
			mapEx		= new MapExtent(47.40, 47.35, 8.60, 8.45);
			map			= new TweenMap(mapWidth, mapHeight, true, mapProv);
			map.setExtent(mapEx);
			map.x = 0;
			map.y = 0;
			addChild(map);
		} // END setMap()
		private function setMarkers():void{
			markers = new MarkersClip(map, locations);
			map.addChild(markers);
		} // END setMarkers()
		private function setLayers():void{
			for each (var param:XML in params){
			}
		} // END setLayers()
		private function setGUI():void{
			gui = new GUI(this);
			this.addChild(gui);
		} // END setGUI()
		private function loadData(_xmlPath:String, _callback:Function):void{
			var urlRequest:URLRequest = new URLRequest(_xmlPath);
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, _callback);
			urlLoader.load(urlRequest);
		} // END loadData()
		private function formatText(_tf:TextField, _color = false, _size = false):void {
			var tFormat:TextFormat = new TextFormat();
			tFormat.font = T_FONT;
			tFormat.color		= (_color) ? _color : T_COLOR;
			tFormat.size		= (_size) ? _size : T_SIZE;
			_tf.setTextFormat(tFormat);
		} // END formatText()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function onLoadParcells(e:Event):void{
			var xml:XML = new XML(e.target.data);
			for each(var w:* in xml.parcell) {
				locations.push(new Location(w.latitude, w.longitude));
			};
			setMarkers();
		} // END onLoadParcells()
		private function onLoadParams(e:Event):void{
			var xml:XML = new XML(e.target.data);
			for each(var p:* in xml.param) {
				params.push(p);
			};
			setLayers();
			setGUI();
		} // END onLoadParams()
		private function onResize(e:Event):void{
		} // END onResize();
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		public function colorizeMap(_e:Event = null):void{
			color = !color;
			var light = new ColorMatrixFilter ();
			light.matrix = new Array (.25, .25, .25, 0, 75, .25, .25, .25, 0, 75, .25, .25, .25, 0, 75, 0, 0, 0, 1, 0);
			var dark = new ColorMatrixFilter ();
			dark.matrix = new Array (-.25, -.25, -.25, 0, 200, -.25, -.25, -.25, 0, 200, -.25, -.25, -.25, 0, 200, 0, 0, 0, 1, 0);
			if(color){
				map.grid.filters = [dark];
			}else{
				map.grid.filters = [light];
			};
		} // END colorizeMap()
	} // END DocumentClass
} // END package