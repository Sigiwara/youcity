//////////////////////////////////////////////////////////////////////////
//  Parameter
//
//  Created by Benjamin Wiederkehr on 081126.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.ui.parameter{
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.events.MouseEvent;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.GradientType;
	import ch.artillery.ui.Dashboard;
	import ch.artillery.ui.slider.*;
	import ch.artillery.map.Layer;
	import flash.text.*;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.filters.DropShadowFilter;
	
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
		private var shadow					:Sprite;
		private var title						:TextField;
		public var index						:uint;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private static const BG_COLOR						:uint			= 0x000000;
		private static const BG_OPACITY_START	 	:Number		= 1;
		private static const BG_OPACITY_END		 	:Number		= .60;
		private static const DEFAULT_POS				:Number		= .50;
		private static const PADDING					 	:uint			= 10;
		private static const TITLE_OFFSET_Y		 	:uint			= 5;
		private static const FONT							 	:String		= 'Helvetica';
		private static const COLOR						 	:uint			= 0xFFFFFF;
		private static const T_SIZE						 	:uint			= 12;
		private static const B_SIZE						 	:uint			= 12;
		private static const LETTER_SPACING		 	:Number		= 1;
		private static const RULER_COLOR				:uint			= 0xFFFFFF;
		private static const RULER_OPACITY			:Number		= .10;
		private static const RULER_THICKNESS		:Number		= 1;
		public const SLIDER_SECTIONS						:Number		= 10;
		
		/**
		*	@Constructor
		*/
		public function Parameter(_dashboard:Dashboard, _data, _layer:Layer){
			//  DEFINITIONS
			//--------------------------------------
			dashboard			= _dashboard;
			layer					= _layer;
			data					= _data;
			bg						= new Sprite();
			ruler					= new Sprite();
			pointer				= new Sprite();
			shadow				= new Sprite();
			title					= new TextField();
			_width				= dashboard.BG_WIDTH;
			_height				= Math.floor(dashboard.height / dashboard.paramCount);
			//	ADDINGS
			//--------------------------------------
			this.addChild(bg);
			this.addChild(ruler);
			this.addChild(title);
			//  LISTENERS
			//--------------------------------------
			addEventListener(MouseEvent.MOUSE_OVER, parameterOver);
			addEventListener(MouseEvent.MOUSE_OUT, parameterOut);
			//  CALLS
			//--------------------------------------
			setTextFields();
			setParameter();
			setSlider();
			layoutAssets();
		} // END Dashboard()
		//--------------------------------------
		// PRIVATE METHODS
		//--------------------------------------
		private function setTextFields():void{
			title.multiline	= true;
			title.wordWrap	= true;
			title.autoSize = TextFieldAutoSize.LEFT;
			title.antiAliasType = AntiAliasType.ADVANCED;
		} // END setTextFields()
		private function setText(_title:String = null):void{
			_title = _title.toUpperCase();
			title.htmlText	= (_title) ? _title : "Title";
			formatText(title, COLOR, T_SIZE);
		} // END setText()
		private function formatText(_tf:TextField, _color = null, _size = null, _italic:Boolean = false):void {
			var tFormat:TextFormat = new TextFormat();
			tFormat.font					= FONT;
			tFormat.color					= (_color) ? _color : COLOR;
			tFormat.size					= (_size) ? _size : B_SIZE;
			tFormat.italic				= (true) ? _italic : false;
			tFormat.letterSpacing = LETTER_SPACING;
			_tf.setTextFormat(tFormat);
		} // END formatText()
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
			g.moveTo(0, _height-1);
			g.lineTo(_width, _height-1);
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
		private function setShadow():void{
			var g:Graphics = shadow.graphics;
			var shadowFilter:DropShadowFilter = new DropShadowFilter(0, 0, 0, 1, 8, 8, 1, 3, false, true, false);
			shadow.filters = [shadowFilter];
			g.clear();
			g.beginFill(0, 1);
			g.moveTo(_width, _height/2-10);
			g.lineTo(_width+12, _height/2);
			g.lineTo(_width, _height/2+10);
			g.endFill();
		} // END setShadow()
		private function setSlider():void{
			slider = new Slider(dashboard.BG_WIDTH-(PADDING*2), SLIDER_SECTIONS);
			this.addChild(slider);
			slider.addEventListener(SliderEvent.GRIP_UP, sChanged);
			slider.setPosition(DEFAULT_POS);
		} // END setSliders()
		private function setParameter():void{
			setText(data.title);
			setBackground();
			setRuler();
			setPointer();
			setShadow();
		} // END setParameter()
		private function layoutAssets():void{
			title.x			= PADDING;
			title.y			= this._height/2 - title.textHeight - TITLE_OFFSET_Y;
			slider.x		= PADDING;
			slider.y		= this.height / 2;
		} // END layoutAssets()
		private function sChanged(_e:SliderEvent):void{
			layer.alpha = _e.amount / 10;
		} // END sCHanged()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		public function adjustParameter():void{
			_width = _width;
			setBackground();
			layoutAssets();
		} // END adjustParameter()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function parameterOver(_e:MouseEvent):void{
			bg.transform.colorTransform = new ColorTransform(0,0,0,1,0,0,0,255);
			dashboard.displayDrawer(this, data.title, data.description);
			this.addChild(pointer);
			this.addChild(shadow);
		} // END parameterOver()
		private function parameterOut(_e:MouseEvent):void{
			bg.transform.colorTransform = new ColorTransform(0,0,0,1,0,0,0,0);
			dashboard.hideDrawer();
			if(pointer != null){
				this.removeChild(pointer);
			};
			if(shadow != null){
				this.removeChild(shadow);
			};
		} // END parameterOut()
	} // END Dashboard Class
}