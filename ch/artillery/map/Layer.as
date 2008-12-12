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
		/**
		 *	@Constructor
		 */
		public function Layer():void{
			//  CALLS
			//--------------------------------------
			super();
			draw();
		}
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		public function sChanged(_e:SliderEvent):void{
			//this.alpha = _e.amount / 10;
		} // END sChanged()
		public function pChanged(_amount:uint):void{
			this.alpha = _amount;
		} // END sChanged()
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		public function draw():void{
			graphics.clear();
			graphics.beginFill(0x00CCFF, 1);
			graphics.drawRect(0,0,200,200);
			graphics.endFill();
		} // END draw()
		public function clear():void{
			graphics.clear();
		} // END clear()
	} // END Layer Class
} // END package
