//////////////////////////////////////////////////////////////////////////
//  Layer
//
//  Created by Benjamin Wiederkehr on 2008-11-29.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.map {
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.display.*;
	import flash.events.*;
<<<<<<< HEAD:ch/artillery/map/Layer.as
	import flash.net.URLRequest;
<<<<<<< HEAD:ch/artillery/map/Layer.as
	import flash.geom.ColorTransform;
=======
=======
>>>>>>> a72e47226194b9e58d1a9be00b313dfbbd54f4ec:ch/artillery/map/Layer.as
>>>>>>> 4294adb6fd3a6a97ad3bed93ab3d30c64d361fa4:ch/artillery/map/Layer.as
	import ch.artillery.ui.slider.SliderEvent;
	/**
	 *	Layer that gets layed over a ModestMap.
	 *
	 *	@langversion		ActionScript 3.0
	 *	@playerversion	Flash 9.0
	 *	@author					Benjamin Wiederkehr
	 *	@since					2008-11-29
	 *	@version				0.1
	 */
	public class Layer extends Sprite {
		
		//--------------------------------------
		//  VARIABLES
		//--------------------------------------
		private var klasse		:String;
		private var rings			:Array;
		private var layer			:Sprite;
		/**
		 *	@Constructor
		 */
		public function Layer(_klasse:String):void{
			//  DEFINITIONS
			//--------------------------------------
			klasse	= _klasse;
			rings		= new Array();
			layer		= new Sprite();
			//  ADDINGS
			//--------------------------------------
			addChild(layer);
			//  CALLS
			//--------------------------------------
			super();
			draw();
			loadLayers();
		}
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		private function draw():void{
			layer.graphics.clear();
			layer.graphics.beginFill(0x000000, 0);
			layer.graphics.drawRect(0,0,200,200)
			layer.graphics.endFill();
		} // END draw()
		private function erase():void{
			layer.graphics.clear();
		} // END erase()
		public function sChanged(_e:SliderEvent):void{
			resetColors();
			var section:Number = rings.length -1 - _e.amount;
			for (var i:int = 0; i<rings.length; i++){
				var diff:int = section - i;
				if(diff < 0){
					diff = diff * -1;
				};
				transformColor(rings[i], diff);
			};
		} // END sChanged()
		public function pChanged(_amount:uint):void{
			this.alpha = _amount;
		} // END sChanged()
<<<<<<< HEAD:ch/artillery/map/Layer.as
		private function loadLayers():void{
			for (var i:int = 1; i<=5; i++){
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onloadedLayers);
				var url:String = 'swf/layers/' + klasse + '/layer_' + i + '.swf';
				loader.load(new URLRequest(url));
			};
		} // END loadLayers()
<<<<<<< HEAD:ch/artillery/map/Layer.as
		private function resetColors():void{
			for (var i:int = 0; i<rings.length; i++){
				rings[i].transform.colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
			};
		} // END resetColors()
		private function transformColor(_ring:Sprite, _diff:Number):void{
			var amount:Number
			if(_diff == 0){
				amount = 255;
			}else{
				amount = 255 - ((255 / (rings.length -1)) * _diff);
			};
			var rOffset:Number = amount;
			_ring.transform.colorTransform = new ColorTransform(1, 1, 1, 1, rOffset, 0, 0, 0);
		} // END transformColor()
=======
=======
>>>>>>> a72e47226194b9e58d1a9be00b313dfbbd54f4ec:ch/artillery/map/Layer.as
>>>>>>> 4294adb6fd3a6a97ad3bed93ab3d30c64d361fa4:ch/artillery/map/Layer.as
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function onloadedLayers(_e:Event):void{
			var ring:Sprite = new Sprite();
			ring.addChild(_e.currentTarget.content);
			rings.push(ring);
			layer.addChild(ring);
		} // END onloadedLayers()
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
<<<<<<< HEAD:ch/artillery/map/Layer.as
		public function show():void{
			this.addChild(layer);
		} // END show()
<<<<<<< HEAD:ch/artillery/map/Layer.as
		public function hide():void{
=======
=======
		public function draw():void{
			graphics.clear();
			graphics.beginFill(0x00CCFF, 1);
			graphics.drawRect(0,0,200,200);
			graphics.endFill();
		} // END draw()
>>>>>>> a72e47226194b9e58d1a9be00b313dfbbd54f4ec:ch/artillery/map/Layer.as
		public function clear():void{
>>>>>>> 4294adb6fd3a6a97ad3bed93ab3d30c64d361fa4:ch/artillery/map/Layer.as
			this.removeChild(layer);
		} // END hide()
	} // END Layer Class
} // END package
