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
			layer		= new Sprite
			//  ADDINGS
			//--------------------------------------
			//  CALLS
			//--------------------------------------
			super();
			loadLayers();
		}
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		public function sChanged(_e:SliderEvent):void{
			//this.alpha = _e.amount / 10;
		} // END sChanged()
		public function pChanged(_amount:uint):void{
			this.alpha = _amount;
		} // END sChanged()
		private function loadLayers():void{
			for (var i:int = 1; i<=5; i++){
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onloadedLayers);
				var url:String = 'swf/layers/' + klasse + '/layer_' + i + '.swf';
				loader.load(new URLRequest(url));
				layer.addChild(loader);
			};
		} // END loadLayers()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		var counter:Number = 0;
		private function onloadedLayers(_e:Event):void{
			counter++;
			if(counter == 5){
				show();
			};
		} // END onloadedLayers()
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		public function show():void{
			this.addChild(layer);
		} // END show()
		public function clear():void{
			this.removeChild(layer);
		} // END clear()
	} // END Layer Class
} // END package
