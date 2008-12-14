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
	import flash.net.URLRequest;
	import flash.geom.ColorTransform;
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
		private var layers		:Layers;
		private var klasse		:String;
		private var rings			:Array;
		private var layer			:Sprite;
		/**
		 *	@Constructor
		 */
		public function Layer(_layers:Layers, _klasse:String):void{
			//  DEFINITIONS
			//--------------------------------------
			layers	= _layers;
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
		private function loadLayers():void{
			for (var i:int = 1; i<=5; i++){
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onloadedLayers);
				var url:String = 'swf/layers/' + klasse + '/layer_' + i + '.swf';
				loader.load(new URLRequest(url));
			};
		} // END loadLayers()
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
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function onloadedLayers(_e:Event):void{
			var ring:Sprite = new Sprite();
			ring.addChild(_e.currentTarget.content);
			ring.blendMode = BlendMode.HARDLIGHT;
			//ring.blendMode = BlendMode.OVERLAY;
			rings.push(ring);
			layer.addChild(ring);
			layers.updateLayer(this);
			sChanged(new SliderEvent(SliderEvent.GRIP_UP, 3));
		} // END onloadedLayers()
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
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
		public function show():void{
			this.addChild(layer);
		} // END show()
		public function hide():void{
			this.removeChild(layer);
		} // END hide()
		public function toggle():void{
			if(numChildren == 0){
				this.addChild(layer);
			}else{
				this.removeChild(layer);
			};
		} // END toggle()
	} // END Layer Class
} // END package
