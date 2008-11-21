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
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.microsoft.*;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.net.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import fl.motion.easing.*;
	//--------------------------------------
	// METADATA
	//--------------------------------------
	[SWF(width="900", height="600", frameRate="32", backgroundColor="#FFFFFF")]

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
		private var map					:Map;
		private var mapEx				:MapExtent;
		private var mapProv			:MicrosoftRoadMapProvider;
		private var mapWidth		:Number;
		private var mapHeight		:Number;
		private var markers			:MarkersClip;
		private var navButtons		:Sprite;
		private var urlLoader		:URLLoader;
		private var locations		:Array;
		private var storeCount		:TextField;

		//--------------------------------------
		//  CONSTANTS
		//--------------------------------------
		private const T_FONT		:String	= 'Arial';
		private const T_COLOR		:uint		= 0xFFFFFF;
		private const T_SIZE		:uint		= 16;
		private const B_SIZE		:uint		= 20;
		private const PADDING		:uint		= 10;
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
			//  CALLS
			//--------------------------------------
			setMap();
			colorizeMap();
			setCount();
			setButtons();
			loadData();
		} // END DocumentClass()
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		private function setMap():void{
			mapProv	= new MicrosoftRoadMapProvider();
			mapEx		= new MapExtent(47.40, 47.35, 8.60, 8.45);
			map			= new TweenMap(mapWidth, mapHeight, true, mapProv);
			map.setExtent(mapEx);
			map.x = 0;
			map.y = 0;
			addChild(map);
		} // END setMap()
		private function colorizeMap():void{
			var mat:Array = [
			0.2,0.5,0.1,0,50,
			0.2,0.5,0.1,0,50,
			0.2,0.5,0.1,0,50,
			0,0,0,1,0
			];
			var colorMat:ColorMatrixFilter = new ColorMatrixFilter(mat);
			map.grid.filters = [colorMat];
		} // END colorizeMap()
		private function setCount():void{
			storeCount				= new TextField();
			storeCount.text		= 'loading data';
			storeCount.x			= this.stage.stageWidth - storeCount.width - PADDING;
			storeCount.y			= this.stage.stageHeight - T_SIZE - PADDING;
			addChild(storeCount);
		} // END setCount()
		private function setMarkers():void{
			markers = new MarkersClip(map, locations);
			map.addChild(markers);
			storeCount.text = String(markers.markers.length);
			formatText(storeCount);
		} // END setMarkers()
		private function setButtons():void{
			var buttons:Array = new Array();
			navButtons = new Sprite();
			addChild(navButtons);
			buttons.push(makeButton(navButtons, 'plus', '+', map.zoomIn));
			buttons.push(makeButton(navButtons, 'minus', '–', map.zoomOut));
			var nextX:Number = 0;
			for(var i:Number = 0; i < buttons.length; i++) {
				var currButton:Sprite = buttons[i];
				Sprite(buttons[i]).x = nextX;
				nextX += Sprite(buttons[i]).width + 2;
			};
			navButtons.x = PADDING;
			navButtons.y = map.height - navButtons.height - PADDING;
		} // END setButtons()
		private function makeButton(clip:Sprite, name:String, labelText:String, action:Function):Sprite{
			var button:Sprite = new Sprite();
			button.name = name;
			button.graphics.moveTo(0, 0);
			button.graphics.beginFill(0x51BFF7, 1);
			button.graphics.drawRoundRect(0, 0, B_SIZE, B_SIZE, 5, 5);
			button.graphics.endFill();
			button.addEventListener(MouseEvent.CLICK, action);
			button.useHandCursor = true;
			button.mouseChildren = false;
			button.buttonMode = true;
			var label:TextField = new TextField();
			label.name				= 'label';
			label.selectable	= false;
			label.textColor		= 0xFFFFFF;
			label.text				= labelText;
			label.width				= label.textWidth + 4;
			label.height			= label.textHeight + 3;
			label.x						= button.width/2 - label.width/2;
			label.y						= button.height/2 - label.height/2;
			button.addChild(label);
			clip.addChild(button);
			return button;
		} // END makeButton()
		private function loadData():void{
			var urlRequest:URLRequest = new URLRequest('data/parcells.xml');
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onLoadData);
			urlLoader.load(urlRequest);
		} // END loadData()
		private function formatText(_tf:TextField, _color = false, _size = false):void {
			var tFormat:TextFormat = new TextFormat();
			tFormat.font = T_FONT;
			if(_color) tFormat.color	= _color;
			else tFormat.color				= T_COLOR;
			if(_size) tFormat.size		= _size;
			else tFormat.size					= T_SIZE;
			// lorem
			_tf.setTextFormat(tFormat);
		} // END onLoadData()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function onLoadData(e:Event):void{
			var xml:XML = new XML(e.target.data);
			for each(var w:* in xml.walmart) {
				locations.push(new Location(w.latitude, w.longitude));
			};
			setMarkers();
		} // END onLoadData()
		private function onResize(e:Event):void{
		} // END onResize();
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
	} // END DocumentClass
} // END package