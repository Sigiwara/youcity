//////////////////////////////////////////////////////////////////////////
//  Parameter
//
//  Created by Benjamin Wiederkehr on 081126.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.ui{
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.display.Sprite;
	import flash.display.Graphics;
	import ch.artillery.ui.slider.*;
	
	/**
	 *	Parameter Class
	 *
	 */
	public class Parameter extends Sprite{
		//--------------------------------------
		// VARIABLES
		//--------------------------------------
		private var dashboard				:Dashboard;
		private var _width					:Number;
		private var _height					:Number;
		private var slider					:Slider;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private const BG_COLOR			:uint		= 0x000000;
		private const BG_OPACITY		:Number	= .10;
		/**
		*	@Constructor
		*/
		public function Parameter(_dashboard:Dashboard){
			//  DEFINITIONS
			//--------------------------------------
			dashboard			= _dashboard;
			_width				= dashboard.width;
			_height				= Math.floor(dashboard.height / dashboard.paramCount);
			//  LISTENERS
			//--------------------------------------
			//  CALLS
			//--------------------------------------
			draw();
			setSlider();
		} // END Dashboard()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		private function draw():void{
			var g:Graphics = this.graphics
			g.beginFill(BG_COLOR, BG_OPACITY);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
		} // END draw()
		private function setSlider():void{
			var tSlider = new Slider(dashboard.BG_WIDTH-20);
			addChild(tSlider);
			tSlider.x = 10;
			tSlider.y = this.height / 2;
			tSlider.addEventListener(SliderEvent.GRIP_UP, sChanged);
		} // END setSliders()
		private function sChanged(_e:SliderEvent):void{
			trace(_e.target.name + ': ' + _e.amount);
		} // END sCHanged()
	} // END Dashboard Class
}