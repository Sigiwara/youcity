﻿////////////////////////////////////////////////////////////////////////////  Slider////  Created by Benjamin Wiederkehr on 081118.//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.////////////////////////////////////////////////////////////////////////////package ch.artillery.ui.slider{	//--------------------------------------	// IMPORT	//--------------------------------------	import flash.events.*;	import flash.display.Sprite;	import flash.display.Graphics;	import flash.geom.ColorTransform;	/**	 *	Standalone scrollbar consisting of a track and a grip.	 *	Dispatching an event with the amount of the grips actual position	 *	or a specific section the track was divided in	 *	 *	@langversion		ActionScript 3.0	 *	@playerversion	Flash 9.0	 *	@author					Benjamin Wiederkehr	 *	@since					081118	 *	@version				0.1	 */	public class Slider extends Sprite{		//--------------------------------------		//  Variables		//--------------------------------------		private var sliderSize	:uint;		private var gripSize		:uint;		private var sCount			:uint;		private var sections		:Array;		private var track				:Sprite;		private var bar					:Sprite;		private var grip				:Sprite;		private var xOffset			:Number;		private var xMin				:Number;		private var xMax				:Number;		private var amount			:Number;		private var section			:Number;		//--------------------------------------		// CONSTANTS		//--------------------------------------		// Height of the scrollbar		private static const TRACK_HEIGHT		= 5;		// Color of the track		private static const TRACK_COLOR		= 0xFFFFFF;		// Opacity of the track		private static const TRACK_OPACITY	= 0.20;		// Color of the grip		private static const GRIP_COLOR			= 0xFFFFFF;		// Opacity of the grip		private static const GRIP_OPACITY		= 1;		// Width of the grip		private static const GRIP_WIDTH			= 10;		// Height of the grip		private static const GRIP_HEIGHT		= 10		// Color of the bar		private static const BAR_COLOR			= 0xFFFFFF;		// Opacity of the bar		private static const BAR_OPACITY		= .20;		//--------------------------------------		//  CONSTRUCTOR		//--------------------------------------		/**		*	@param	_sliderSize	:Size the slider		*	@param	_sections		:Amount of sections to divert the slider		*/		public function Slider(_sliderSize:uint, _sCount:* = false, _startPos:Number = 0):void{			//  DEFINITIONS			//--------------------------------------			sliderSize	= _sliderSize;			sCount			= _sCount;			gripSize		= TRACK_HEIGHT;			sections		= new Array();			track				= new Sprite();			bar					= new Sprite();			grip				= new Sprite();			xOffset			= 0;			xMin				= 0;			xMax				= sliderSize;			//  ADD			//--------------------------------------			this.addChild(track);			this.addChild(grip);			this.addChild(bar);			//  LISTENERS			//--------------------------------------			//grip.addEventListener(MouseEvent.MOUSE_OVER, gripOver);			//grip.addEventListener(MouseEvent.MOUSE_OUT, gripOut);			grip.addEventListener(MouseEvent.MOUSE_DOWN, gripDown);			//  CALLS			//--------------------------------------			setSections();			drawAssets();		} // END Slider()		//--------------------------------------		//  PRIVATE METHODS		//--------------------------------------		private function drawAssets():void{			drawTrack();			drawGrip();			drawBar();		} // END drawAssets()		private function drawTrack():void{			var g:Graphics = track.graphics;			g.clear();			g.beginFill(TRACK_COLOR, TRACK_OPACITY);			g.drawRect(0, 0, sliderSize, TRACK_HEIGHT);			g.endFill();		} // END drawTrack()		private function drawGrip():void{			var g:Graphics = grip.graphics;			g.clear();			g.beginFill(GRIP_COLOR, GRIP_OPACITY);			g.moveTo(0, 0);			g.lineTo(GRIP_WIDTH / 2, GRIP_HEIGHT);			g.lineTo(-GRIP_WIDTH / 2, GRIP_HEIGHT);			g.lineTo(0, 0);			g.endFill();			grip.y = TRACK_HEIGHT;			grip.buttonMode = true;		} // END drawGrip()		private function drawBar():void{			var g:Graphics = bar.graphics;			g.clear();			g.lineStyle(2, BAR_COLOR, BAR_OPACITY);			g.moveTo(grip.x, 0);			g.lineTo(grip.x, TRACK_HEIGHT)		} // END drawDiagram()		private function setSections():void{			if(sCount){				var div:Number = 1/sCount;				for (var i:uint = 0; i<=sCount; i++){					var tSection:Object = new Object;					tSection.min = div*(i) - (div*0.5);					tSection.max = div*(i+1) - (div*0.5);					sections.push(tSection);				};			};		} // END setSections()		private function checkSection():void{			for (var i:int = 0; i<sections.length; i++){				if(amount >= sections[i].min && amount <= sections[i].max){					section = i;				};			};		} // END checkSections()		private function adjustToSections():void{			grip.x = xMax / sCount * section;			amount = grip.x / xMax;			drawBar();		} // END adjustToSections()		//--------------------------------------		//  EVENT HANDLERS		//--------------------------------------		private function gripOver(_e:MouseEvent):void{			grip.transform.colorTransform = new ColorTransform(1,1,1,1,255,255,255,255);		} // END gripOver()		private function gripOut(_e:MouseEvent):void{			grip.transform.colorTransform = new ColorTransform(1,1,1,1,255,255,255,GRIP_OPACITY);		} // END gripOut()		private function gripMove(_e:MouseEvent):void{			grip.x		= mouseX - xOffset;			if(grip.x	<= xMin){				grip.x	= xMin;			};			if(grip.x	>= xMax){				grip.x	= xMax;			};			amount = grip.x / xMax;			drawBar();			dispatchEvent(new SliderEvent(SliderEvent.GRIP_MOVE, amount));			_e.updateAfterEvent();		} // END gripMove()		private function gripDown(_e:MouseEvent):void{			// To adjust grip position while dragging			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, gripMove);			// To catch if the grip gets released outside of the track			this.stage.addEventListener(MouseEvent.MOUSE_UP, gripUp);			// To prevent the grip to switch color while dragging			grip.removeEventListener(MouseEvent.MOUSE_OUT, gripOut);			// To prevent grip to jump to the mouse position			xOffset = mouseX - grip.x;		} // END gripDown()		private function gripUp(_e:MouseEvent):void{			// To switch color when the mouse isn't over the grip anymore			grip.addEventListener(MouseEvent.MOUSE_OUT, gripOut);			// To stop the moving of the grip			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, gripMove);			// To stop listening for the up event			this.stage.removeEventListener(MouseEvent.MOUSE_UP, gripUp);			if(sCount){				checkSection()				adjustToSections();				dispatchEvent(new SliderEvent(SliderEvent.GRIP_UP, amount));			}else{				dispatchEvent(new SliderEvent(SliderEvent.GRIP_UP, amount));			};			gripOut(_e);		} // END gripUp()		//--------------------------------------		//  PUBLIC METHODS		//--------------------------------------		public function setPosition(_pos:Number):void{			grip.x		= _pos * xMax;			amount = grip.x / xMax;			drawBar();			dispatchEvent(new SliderEvent(SliderEvent.GRIP_MOVE, amount));		} // END setPosition()	} // END Slider Class} // END package ch.artillery.ui.slider