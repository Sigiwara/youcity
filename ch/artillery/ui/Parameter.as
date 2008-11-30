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
	import ch.artillery.map.Layer;
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
		private var data						:XML;
		private var layer						:Layer;
		private var _width					:Number;
		private var _height					:Number;
		private var slider					:Slider;
		private var bg							:Sprite;
		private var ruler						:Sprite;
		private var pointer					:Sprite;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private const BG_COLOR						:uint		= 0x000000;
		private const BG_OPACITY_START		:Number	= 1;
		private const BG_OPACITY_END			:Number	= .40;
		// Color of the ruler
		private static const RULER_COLOR			= 0xFFFFFF;
		// Opacity of the ruler
		private static const RULER_OPACITY		= .30;
		// Thickness of the ruler
		private static const RULER_THICKNESS	= 1;
		
		/**
		*	@Constructor
		*/
		public function Parameter(_dashboard:Dashboard, _data:XML, _layer:Layer){
			//  DEFINITIONS
			//--------------------------------------
			dashboard			= _dashboard;
			data					= _data;
			layer					= _layer;
			bg						= new Sprite();
			ruler					= new Sprite();
			pointer				= new Sprite();
			_width				= dashboard.BG_WIDTH;
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
			setParameter();
			setSlider();
		} // END Dashboard()
		//--------------------------------------
		// PRIVATE METHODS
		//--------------------------------------
		private function setBackground():void{
			var g:Graphics = bg.graphics;
			var matrix = new Matrix();
			matrix.createGradientBox(_width*1.4, _height, 0, 0, 0);
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, [BG_COLOR,BG_COLOR], [BG_OPACITY_START,BG_OPACITY_END], [0,255], matrix);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
		} // END setBackground()
		private function setRuler():void{
			var g:Graphics = ruler.graphics;
			g.clear();
			g.lineStyle(RULER_THICKNESS, RULER_COLOR, RULER_OPACITY);
			g.moveTo(0, _height);
			g.lineTo(_width, _height);
		} // END setRuler()
			private function setPointer():void{
				var g:Graphics = pointer.graphics;
				g.clear();
				g.beginFill(0x000000, 1);
				g.moveTo(_width, _height/2-10);
				g.lineTo(_width+12, _height/2);
				g.lineTo(_width, _height/2+10);
				g.endFill();
			} // END setPointer()
		private function setSlider():void{
			var tSlider = new Slider(_width-20);
			addChild(tSlider);
			tSlider.x = 10;
			tSlider.y = this.height / 2;
			tSlider.addEventListener(SliderEvent.GRIP_UP, sChanged);
		} // END setSliders()
		private function sChanged(_e:SliderEvent):void{
			trace(_e.target.name + ': ' + _e.amount);
		} // END sCHanged()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		public function setParameter():void{
			setBackground();
			setRuler();
			setPointer();
		} // END setParameter()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function parameterOver(_e:MouseEvent):void{
			bg.transform.colorTransform = new ColorTransform(0,0,0,1,0,0,0,255);
			dashboard.displayDrawer(this, data.title, data.description);
			this.addChild(pointer);
		} // END parameterOver()
		private function parameterOut(_e:MouseEvent):void{
			bg.transform.colorTransform = new ColorTransform(0,0,0,1,0,0,0,0);
			dashboard.hideDrawer();
			this.removeChild(pointer);
		} // END parameterOut()
	} // END Dashboard Class
}