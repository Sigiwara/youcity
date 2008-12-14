//////////////////////////////////////////////////////////////////////////
//  OverlayLayer
//
//  Created by Benjamin Wiederkehr on 2008-12-12.
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
	/**
	 *	Sprite sub class description.
	 *
	 *	@langversion		ActionScript 3.0
	 *	@playerversion	Flash 9.0
	 *	@author					Benjamin Wiederkehr
	 *	@since					2008-12-12
	 *	@version				0.1
	 */
	public class OverlayLayer extends Sprite {
		
		//--------------------------------------
		//  VARIABLES
		//--------------------------------------
		private var layer			:Sprite;
		private var swf				:String;
		//--------------------------------------
		//  CONSTANTS
		//--------------------------------------
		/**
		 *	@Constructor
		 */
		public function OverlayLayer(_swf):void{
			//  DEFINITIONS
			//--------------------------------------
			layer		= new Sprite();
			swf			= _swf;
			//  ADDINGS
			//--------------------------------------
			addChild(layer);
			//  CALLS
			//--------------------------------------
			super();
			draw();
			loadLayer();
		}
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		private function draw():void{
			layer.graphics.clear();
			layer.graphics.beginFill(0xffffff, 0);
			layer.graphics.drawRect(0,0,200,200)
			layer.graphics.endFill();
		} // END draw()
		private function erase():void{
			layer.graphics.clear();
		} // END erase()
		private function loadLayer():void{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onloadedLayer);
			loader.load(new URLRequest(swf));
		} // END loadLayer()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function onloadedLayer(_e:Event):void{
			var ring:Sprite = new Sprite();
			ring.addChild(_e.currentTarget.content);
			layer.addChild(ring);
		} // END onloadedLayer()
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		public function show():void{
			this.addChild(layer);
		} // END show()
		public function hide():void{
			this.removeChild(layer);
		} // END hide()
	} // END OverlayLayer Class
} // END package
