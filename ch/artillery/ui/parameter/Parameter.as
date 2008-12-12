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
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.GradientType;
	import ch.artillery.ui.Dashboard;
	import ch.artillery.ui.slider.*;
	import ch.artillery.map.Layer;
	import flash.text.*;
	import ch.artillery.map.Layer;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.filters.DropShadowFilter;
	//--------------------------------------
	// METADATA
	//--------------------------------------
	[Embed(source='/fonts/DINOT-Regular.otf', fontName="DINOT-Regular", mimeType="application/x-font-truetype")];
	/**
	 *	Parameter Class
	 *
	 */
	public class Parameter extends Sprite{
		//--------------------------------------
		// VARIABLES
		//--------------------------------------
		private var dc							:DocumentClass;
		private var dashboard				:Dashboard;
		private var data						:XML;
		private var layer						:Layer;
		private var _width					:Number;
		public var _height					:Number;
		private var preY						:Number;
		private var preHeight				:Number;
		private var slider					:Slider;
		private var bg							:Sprite;
		private var ruler						:Sprite;
		private var pointer					:Sprite;
		private var shadow					:Sprite;
		private var title						:TextField;
		private var grip_bottom			:Sprite;
		private var grip_top				:Sprite;
		private var label_left			:TextField;
		private var label_right			:TextField;
		private var dispatcher			:EventDispatcher;
		public var index						:uint;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		// Background
		private static const BG_COLOR						:uint			= 0x000000;
		private static const BG_OPACITY_START	 	:Number		= 1;
		private static const BG_OPACITY_END		 	:Number		= .60;
		// Text
		private static const DEFAULT_POS				:Number		= .50;
		private static const PADDING					 	:uint			= 25;
		private static const MARGIN							:uint			= 2;
		private static const TITLE_OFFSET_X		 	:uint			= 3;
		private static const TITLE_OFFSET_Y		 	:uint			= 5;
		private static const FONT							 	:String		= 'DINOT-Regular';
		private static const LABEL_FONT					:String		= 'DINOT-Regular';
		private static const COLOR						 	:uint			= 0xFFFFFF;
		private static const T_SIZE						 	:uint			= 11;
		private static const B_SIZE						 	:uint			= 12;
		private static const LETTER_SPACING		 	:Number		= 1;
		private static const TEXT_ALIGN					:String		= 'center';
		// Ruler
		private static const RULER_COLOR				:uint			= 0xFFFFFF;
		private static const RULER_OPACITY			:Number		= .10;
		private static const RULER_THICKNESS		:Number		= 1;
		public const SLIDER_SECTIONS						:Number		= 10;
		// Grip
		private static const GRIP_WIDTH					:Number		= 10;
		private static const GRIP_COLOR					:uint			= 0xFFFFFFF;
		private static const GRIP_OVER					:Number		= .4;
		private static const GRIP_OUT						:Number		= .2;
		private static const GRIP_PADDING				:Number		= 4;
		// Size
		private static const SCALE_MAX					:uint			= 450;
		private static const SCALE_MIN					:uint			= 40;
		
		/**
		*	@Constructor
		*/
		public function Parameter(_dc:DocumentClass, _dashboard:Dashboard, _data:XML, _layer:Layer){
			//  DEFINITIONS
			//--------------------------------------
			dc						= _dc;
			dashboard			= _dashboard;
			layer					= _layer;
			data					= _data;
			layer					= _layer;			
			bg						= new Sprite();
			ruler					= new Sprite();
			pointer				= new Sprite();
			shadow				= new Sprite();
			grip_top			= new Sprite();
			grip_bottom		= new Sprite();
			title					= new TextField();
			label_left		= new TextField();
			label_right		= new TextField();
			dispatcher		= new EventDispatcher();
			_width				= dashboard.BG_WIDTH;
			_height				= Math.floor(dashboard.height / dashboard.paramCount);
			//	ADDINGS
			//--------------------------------------
			this.addChild(bg);
			this.addChild(ruler);
			this.addChild(title);
			//  LISTENERS
			//--------------------------------------
			addEventListeners()
			//  CALLS
			//--------------------------------------
			setTextFields();
			setText(data.title, data.labels.label[0], data.labels.label[1]);
			setParameter();
			setSlider();
			setGrip();
			layoutAssets();
		} // END Dashboard()
		//--------------------------------------
		// PRIVATE METHODS
		//--------------------------------------
		private function setTextFields():void{
			// Titel
			title.multiline	= false;
			title.wordWrap	= false;
			title.autoSize = TextFieldAutoSize.CENTER;
			title.antiAliasType = AntiAliasType.ADVANCED;
			title.selectable = false;
			title.mouseEnabled = false;
			// Label links
			label_left.multiline = false;
			label_left.wordWrap = true;
			label_left.autoSize = TextFieldAutoSize.LEFT;
			label_left.antiAliasType = AntiAliasType.ADVANCED;
			label_left.selectable = false;
			label_left.mouseEnabled = false;
			label_left.alpha = .4;
			// Label rechts
			label_right.multiline = false;
			label_right.wordWrap = true;
			label_right.autoSize = TextFieldAutoSize.RIGHT;
			label_right.antiAliasType = AntiAliasType.ADVANCED;
			label_right.selectable = false;
			label_right.mouseEnabled = false;
			label_right.alpha = .4;
		} // END setTextFields()
		private function setText(_title:String = null, _label_left:String = null, _label_right:String = null):void{
			// Titel
			_title = _title.toUpperCase();
			title.htmlText	= (_title) ? _title : "Title";
			title.width = title.textWidth + 3;
			formatText(FONT, title, COLOR, T_SIZE);
			// Label links
			_label_left = _label_left.toUpperCase();
			label_left.htmlText	= (_label_left) ? _label_left : "Label";
			label_left.width = label_left.textWidth + 10;
			formatText(LABEL_FONT, label_left, COLOR, T_SIZE);
			label_left.embedFonts = true;
			// Label rechts
			_label_right = _label_right.toUpperCase();
			label_right.htmlText	= (_label_right) ? _label_right : "Label";
			label_right.width = label_right.textWidth + 10;
			formatText(LABEL_FONT, label_right, COLOR, T_SIZE);
			label_right.embedFonts = true;
		} // END setText()
		private function formatText(_font:String, _tf:TextField, _color = null, _size = null, _italic:Boolean = false):void{
			var tFormat:TextFormat = new TextFormat();
			tFormat.font					= (_font) ? _font : FONT;
			tFormat.color					= (_color) ? _color : COLOR;
			tFormat.size					= (_size) ? _size : B_SIZE;
			tFormat.italic				= (true) ? _italic : false;
			tFormat.align					= TEXT_ALIGN;
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
			slider.addEventListener(SliderEvent.GRIP_UP, layer.sChanged);
			slider.setPosition(DEFAULT_POS);
		} // END setSlider()
		private function setGrip():void{
			drawGrip(grip_top);
			grip_top.alpha = GRIP_OUT;
			grip_top.mouseChildren	= false;
			grip_top.name	= "grip_top";
			drawGrip(grip_bottom);
			grip_bottom.alpha = GRIP_OUT;
			grip_bottom.mouseChildren	= false;
			grip_bottom.name	= "grip_bottom";
		} // END setGrip()
		private function drawGrip(_grip:Sprite):void{
			var g:Graphics = _grip.graphics;
			g.clear();
			g.beginFill(0, 0);
			g.drawRect(-GRIP_WIDTH/2 - GRIP_PADDING, 0 - GRIP_PADDING, GRIP_WIDTH + GRIP_PADDING*2, 6 + GRIP_PADDING*2);
			g.endFill();
			g.lineStyle(1, GRIP_COLOR, 1);
			g.moveTo(-GRIP_WIDTH/2, 0);
			g.lineTo(GRIP_WIDTH/2, 0);
			g.moveTo(-GRIP_WIDTH/2, 2);
			g.lineTo(GRIP_WIDTH/2, 2);
			g.moveTo(-GRIP_WIDTH/2, 4);
			g.lineTo(GRIP_WIDTH/2, 4);
		} // END drawGrip()
		private function layoutAssets():void{
			title.x				= _width/2 - title.textWidth/2 - TITLE_OFFSET_X;
			title.y				= _height/2 - title.textHeight - TITLE_OFFSET_Y;
			slider.x			= PADDING;
			slider.y			= _height / 2;
			label_left.x	= PADDING - MARGIN - label_left.textWidth - 7;
			label_left.y	= _height/2 - TITLE_OFFSET_Y - 5;
			label_right.x	= _width - PADDING + MARGIN - 2;
			label_right.y	= _height/2 - TITLE_OFFSET_Y - 5;
			grip_top.x		= _width/2;
			grip_top.y		= 4;
			grip_bottom.x	= _width/2;
			grip_bottom.y	= _height - 10;
		} // END layoutAssets()
		private function adaptParameter(_e:MouseEvent):void{
			switch(_e.target.name){
				case 'grip_top':
				if(_height < SCALE_MAX - 10){
					_height += 10;
					setParameter();
					layoutAssets();
					dashboard.adjustParameters(index, -1);
				}
				break;
				case 'grip_bottom':
				if(_height > SCALE_MIN + 10){
					_height -= 10;
					setParameter();
					layoutAssets();
					dashboard.adjustParameters(index, 1);
				}
				break;
			};
		} // END parameterAdapt()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		public function setParameter():void{
			setBackground();
			setRuler();
			setPointer();
			setShadow();
		} // END setParameter()
		public function adjustParameter(_amount:Number):void{
			_height += _amount;
			setBackground();
			setRuler();
			layoutAssets();
		} // END adjustParameter()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		public function addEventListeners():void{
			this.addEventListener(MouseEvent.MOUSE_OVER, parameterOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, parameterOut);
			dispatcher.addEventListener("parameterOver", parameterOver);
			grip_top.addEventListener(MouseEvent.MOUSE_OVER, gripOver);
			grip_top.addEventListener(MouseEvent.MOUSE_OUT, gripOut);
			grip_top.addEventListener(MouseEvent.MOUSE_DOWN, gripDown);
			grip_bottom.addEventListener(MouseEvent.MOUSE_OVER, gripOver);
			grip_bottom.addEventListener(MouseEvent.MOUSE_OUT, gripOut);
			grip_bottom.addEventListener(MouseEvent.MOUSE_DOWN, gripDown);
		} // END addEventListeners()
		public function removeEventListeners():void{
			this.removeEventListener(MouseEvent.MOUSE_OVER, parameterOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, parameterOut);
			dispatcher.removeEventListener("parameterOver", parameterOver);
			grip_top.removeEventListener(MouseEvent.MOUSE_OVER, gripOver);
			grip_top.removeEventListener(MouseEvent.MOUSE_OUT, gripOut);
			grip_top.removeEventListener(MouseEvent.MOUSE_DOWN, gripDown);
			grip_bottom.removeEventListener(MouseEvent.MOUSE_OVER, gripOver);
			grip_bottom.removeEventListener(MouseEvent.MOUSE_OUT, gripOut);
			grip_bottom.removeEventListener(MouseEvent.MOUSE_DOWN, gripDown);
		} // END removeEventListeners()
		private function parameterOver(_e:MouseEvent):void{
			bg.transform.colorTransform = new ColorTransform(0,0,0,1,0,0,0,255);
			dashboard.displayDrawer(this, data.question, data.description);
			this.addChild(pointer);
			this.addChild(shadow);
			this.addChild(label_left);
			this.addChild(label_right);
			this.addChild(grip_top);
			this.addChild(grip_bottom);
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
			this.removeChild(label_left);
			this.removeChild(label_right);
			this.removeChild(grip_top);
			this.removeChild(grip_bottom);
		} // END parameterOut()
		private function gripOver(_e:MouseEvent):void{
			dispatcher.dispatchEvent(new MouseEvent("parameterOver"));
			dc.gui.addCustomCursor();
			dashboard.swapParameters(this);
			_e.target.alpha = GRIP_OVER;
		} // END gripOver()
		private function gripOut(_e:MouseEvent):void{
			dc.gui.removeCustomCursor();
			_e.target.alpha = GRIP_OUT;
		} // END gripOut()
		private function gripDown(_e:MouseEvent):void{
			preY				= this.y;
			preHeight		= this.height;
			_e.target.addEventListener(MouseEvent.MOUSE_UP, gripUp);
		} // END gripUp()
		private function gripUp(_e:MouseEvent):void{
			_e.target.removeEventListener(MouseEvent.MOUSE_UP, gripUp);
			adaptParameter(_e);
		} // END gripUp()
	} // END Dashboard Class
}