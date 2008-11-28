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
	import flash.events.MouseEvent;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.GradientType;
	import ch.artillery.ui.slider.*;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	
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
		private var bg							:Sprite;
		private var ruler						:Sprite;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private const BG_COLOR						:uint		= 0x000000;
		private const BG_OPACITY_START		:Number	= 1;
		private const BG_OPACITY_END			:Number	= .50;
		
		/**
		*	@Constructor
		*/
		public function Parameter(_dashboard:Dashboard){
			//  DEFINITIONS
			//--------------------------------------
			dashboard			= _dashboard;
			bg						= new Sprite();
			ruler					= new Sprite();
			_width				= dashboard.width;
			_height				= Math.floor(dashboard.height / dashboard.paramCount);
			//	ADDINGS
			//--------------------------------------
			this.addChild(bg);
			this.addChild(ruler);
			//  LISTENERS
			//--------------------------------------
			addEventListener(MouseEvent.MOUSE_OVER, parameterOver);
			addEventListener(MouseEvent.MOUSE_OUT, parameterOut);
			//  CALLS
			//--------------------------------------
			draw();
			setSlider();
		} // END Dashboard()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		private function draw():void{
			// Definitions
			var g:Graphics = bg.graphics;
			var r:Graphics = ruler.graphics;
			//	Matrix
			var matrix = new Matrix();
			matrix.createGradientBox(_width, _height, 0, 0, 0);
			//	Background
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, [BG_COLOR,BG_COLOR], [BG_OPACITY_START,BG_OPACITY_END], [0,255], matrix);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
			//	Ruler
			r.lineStyle(1, 0xFFFFFF, 0.50);
			r.moveTo(1, _height-1);
			r.lineTo(_width-1, _height-1);
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
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function parameterOver(_e:MouseEvent):void{
			bg.transform.colorTransform = new ColorTransform(0,0,0,1,0,0,0,255);
		} // END parameterOver()
		private function parameterOut(_e:MouseEvent):void{
			bg.transform.colorTransform = new ColorTransform(0,0,0,1,0,0,0,0);
		} // END parameterOut()
	} // END Dashboard Class
}