//////////////////////////////////////////////////////////////////////////
//  Dashboard
//
//  Created by Benjamin Wiederkehr on 081121.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.ui{
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.display.Sprite;
	import ch.artillery.ui.slider.*;
	/**
	 *	Dashboard Class
	 *
	 */
	public class Dashboard extends Sprite{
		//--------------------------------------
		// VARIABLES
		//--------------------------------------
		private var dc							:DocumentClass;
		private var sliders					:Array;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private const BG_COLOR			:uint		= 0x000000;
		private const BG_OPACITY		:Number	= .75;
		private const BG_HEIGHT			:uint		= 200;
		/**
		*	@Constructor
		*/
		public function Dashboard(_dc:DocumentClass){
			//  DEFINITIONS
			//--------------------------------------
			dc			= _dc;
			sliders	= new Array();
			//  LISTENERS
			//--------------------------------------
			//  CALLS
			//--------------------------------------
			draw();
			setSliders();
		} // END Dashboard()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		private function draw():void{
			graphics.beginFill(BG_COLOR, BG_OPACITY);
			graphics.drawRect(0, 0, dc.stage.stageWidth, BG_HEIGHT);
			graphics.endFill();
		} // END draw()
		private function setSliders():void{
			for (var i:int = 0; i<10; i++){
				var tSlider = new Slider(BG_HEIGHT-20);
				addChild(tSlider);
				sliders.push(tSlider);
				tSlider.x = dc.PADDING + i*(tSlider.width + 40);
				tSlider.y = 10;
				tSlider.name = 'Slider_'+i;
				tSlider.addEventListener(SliderEvent.GRIP_UP, sChanged);
			};
		} // END setSliders()
		private function sChanged(_e:SliderEvent):void{
			trace(_e.target.name + ': ' + _e.amount);
		} // END sCHanged()
	} // END Dashboard Class
}