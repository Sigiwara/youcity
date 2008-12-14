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
		public function Layer(_index:uint):void{
			// DEFINITIONS
			//--------------------------------------
			this.alpha = 1/(_index+1);;
			//  CALLS
			//--------------------------------------
			super();
			draw();
		}
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		public function sChanged(_e:SliderEvent):void{
			//this.alpha = _e.amount / 10;
		} // END sChanged()
		public function pChanged(_activeLayer:uint, _index:uint, _alpha:Number):void{
			if(_index>=_activeLayer){
				this.alpha = _alpha;
				//trace(this.name+": "+this.alpha);
			}
		} // END pChanged()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
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
