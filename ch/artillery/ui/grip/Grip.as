//////////////////////////////////////////////////////////////////////////
//  Slider
//
//  Created by Benjamin Wiederkehr on 081118.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.ui.grip{
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.events.*;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.geom.ColorTransform;
	/**
	 *	Standalone scrollbar consisting of a track and a grip.
	 *	Dispatching an event with the amount of the grips actual position
	 *	or a specific section the track was divided in
	 *
	 *	@langversion		ActionScript 3.0
	 *	@playerversion	Flash 9.0
	 *	@author					Benjamin Wiederkehr
	 *	@since					081118
	 *	@version				0.1
	 */
	public class Grip extends Sprite{
		//--------------------------------------
		//  Variables
		//--------------------------------------
		private var dc					:DocumentClass;
		private var lines				:Sprite;
		private var bg					:Sprite;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private static const GRIP_WIDTH					:Number		= 10;
		private static const GRIP_COLOR					:uint			= 0xFFFFFFF;
		private static const GRIP_OPACITY				:Number		= 1;
		private static const PADDING						:Number		= 4;
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		/**
		*	@param	_sliderSize	:Size the slider
		*	@param	_sections		:Amount of sections to divert the slider
		*/
		public function Grip(_dc:DocumentClass):void{
			//  DEFINITIONS
			//--------------------------------------
			dc 									= _dc;
			lines								= new Sprite();
			bg									= new Sprite();
			this.mouseChildren	= false;
			//  ADD
			//--------------------------------------
			//  LISTENERS
			//--------------------------------------
			this.addEventListener(MouseEvent.MOUSE_OVER, gripOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, gripOut);
			this.addEventListener(MouseEvent.MOUSE_DOWN, gripDown);
			//  CALLS
			//--------------------------------------
			drawAssets();
		} // END Slider()
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		private function drawAssets():void{
			//drawBackground();
			drawLines();
		} // END drawAssets()
		private function drawBackground():void{
			var g:Graphics = bg.graphics;
			g.clear();
			g.beginFill(0, 0);
			g.drawRect(-GRIP_WIDTH/2 - PADDING, 0 - PADDING, GRIP_WIDTH + PADDING*2, 6 + PADDING*2);
			g.endFill();
		} // END drawBackground()
		private function drawLines():void{
			var g:Graphics = lines.graphics;
			g.clear();
			g.beginFill(0, 0);
			g.drawRect(-GRIP_WIDTH/2 - PADDING, 0 - PADDING, GRIP_WIDTH + PADDING*2, 6 + PADDING*2);
			g.endFill();
			g.lineStyle(1, GRIP_COLOR, GRIP_OPACITY);
			g.moveTo(-GRIP_WIDTH/2, 0);
			g.lineTo(GRIP_WIDTH/2, 0);
			g.moveTo(-GRIP_WIDTH/2, 2);
			g.lineTo(GRIP_WIDTH/2, 2);
			g.moveTo(-GRIP_WIDTH/2, 4);
			g.lineTo(GRIP_WIDTH/2, 4);
			lines.alpha = .2;
		} // END drawLines()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function gripOver(_e:MouseEvent):void{
			lines.alpha = .4;
			dc.gui.addCustomCursor();
		} // END gripOver()
		private function gripOut(_e:MouseEvent):void{
			lines.alpha = .2;
			dc.gui.removeCustomCursor();
		} // END gripOut()
		private function gripDown(_e:MouseEvent):void{
		} // END gripUp()
		private function gripMove(_e:MouseEvent):void{
			_e.updateAfterEvent();
		} // END gripMove()
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		public function parameterOver():void{
			this.addChild(bg);
			this.addChild(lines);
		} // END parameterOver()
		public function parameterOut():void{
			this.removeChild(bg);
			this.removeChild(lines);
		} // END parameterOver()
	} // END Slider Class
} // END package ch.artillery.ui.slider
