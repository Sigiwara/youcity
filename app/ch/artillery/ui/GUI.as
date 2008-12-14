//////////////////////////////////////////////////////////////////////////
//  GUI
//
//  Created by Benjamin Wiederkehr on 2008-11-29.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.ui {	
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.text.*;
	import ch.artillery.ui.Dashboard;
	import flash.ui.Mouse;
	import flash.geom.Point;
	import flash.filters.DropShadowFilter;
	
	[Embed(source='/fonts/DINOT-Regular.otf', fontName="DINOT-Regular", mimeType="application/x-font-truetype")];
	
	/**
	 *	Controller of the graphical user interface.
	 *
	 *	@langversion		ActionScript 3.0
	 *	@playerversion	Flash 9.0
	 *	@author					Benjamin Wiederkehr
	 *	@since					2008-11-29
	 *	@version				0.1
	 */
	public class GUI extends Sprite {
		
		//--------------------------------------
		//  VARIABLES
		//--------------------------------------
		private var dc					:DocumentClass;
		private var dashboard		:Dashboard;
		private var navButtons	:Sprite;
		private var cursor			:Sprite;
		//--------------------------------------
		//  CONSTANTS
		//--------------------------------------
		private const FONT			:String	= 'DINOT-Regular';
		private const T_COLOR		:uint		= 0xFFFFFF;
		private const T_SIZE		:uint		= 16;
		private const PADDING		:uint		= 20;
		private const BG_SIZE		:uint		= 20;
		private const BG_COLOR	:uint		= 0x046296;
		/**
		 *	@Constructor
		 */
		public function GUI(_dc:DocumentClass):void{
			//  DEFINITIONS
			//--------------------------------------
			dc 			= _dc;
			cursor	= new Sprite();
			//  ADDINGS
			//--------------------------------------
			//  LISTENERS
			//--------------------------------------
			this.addEventListener(MouseEvent.MOUSE_MOVE, cursorMove);
			//  CALLS
			//--------------------------------------
			setButtons();
			setDashboard();
			setCustomCursor();
		}
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		private function setDashboard():void{
			dashboard = new Dashboard(dc, this);
			this.addChild(dashboard);
		} // END setDashboard()
		private function setButtons():void{
			navButtons = new Sprite();
			this.addChild(navButtons);
			navButtons.addChild(makeButton('plus', '+', dc.map.zoomIn))
			navButtons.addChild(makeButton('minus', '-', dc.map.zoomOut))
			navButtons.addChild(makeButton('toggle', '•', dc.layers.toggleOverlays))
			navButtons.addChild(makeButton('switch', 'o', dc.colorizeMap))
			var nextX:Number = 0;
			for(var i:Number = 0; i < navButtons.numChildren; i++) {
				var currButton:Sprite = navButtons.getChildAt(i) as Sprite;
				currButton.x = nextX;
				nextX += currButton.width + 2;
			};
			navButtons.x = dc.stage.stageWidth - navButtons.width - PADDING;;
			navButtons.y = PADDING;
		} // END setButtons()
		private function setCustomCursor():void{
			drawCustomCursor();
			cursor.mouseEnabled = false;
		} // END setCustomCursor()
		private function makeButton(name:String, labelText:String, action:Function):Sprite{
			var button:Sprite = new Sprite();
			var shadow:Sprite = new Sprite();
			var shadowFilter:DropShadowFilter = new DropShadowFilter(0, 0, 0, .2, 8, 8, 1, 3, false, true, false);
			shadow.graphics.moveTo(0, 0);
			shadow.graphics.beginFill(0, 1);
			shadow.graphics.drawRect(0, 0, BG_SIZE, BG_SIZE);
			shadow.graphics.endFill();
			shadow.filters = [shadowFilter];
			button.name = name;
			button.graphics.moveTo(0, 0);
			button.graphics.beginFill(BG_COLOR, .70);
			button.graphics.drawRect(0, 0, BG_SIZE, BG_SIZE);
			//button.graphics.drawRoundRect(0, 0, BG_SIZE, BG_SIZE, 5, 5);
			button.graphics.endFill();
			button.addEventListener(MouseEvent.CLICK, action);
			button.useHandCursor = true;
			button.mouseChildren = false;
			button.buttonMode = true;
			var label:TextField = new TextField();
			label.name				= 'label';
			label.selectable	= false;
			label.textColor		= T_COLOR;
			label.text				= labelText;
			label.width				= label.textWidth + 4;
			label.height			= label.textHeight + 3;
			label.x						= button.width/2 - label.width/2;
			label.y						= button.height/2 - label.height/2;
			button.addChild(shadow);
			button.addChild(label);
			return button;
		} // END makeButton()
		private function formatText(_tf:TextField, _color = false, _size = false):void {
			var tFormat:TextFormat = new TextFormat();
			tFormat.font = FONT;
			tFormat.color		= (_color) ? _color : T_COLOR;
			tFormat.size		= (_size) ? _size : T_SIZE;
			_tf.setTextFormat(tFormat);
		} // END formatText()
		public function drawCustomCursor():void{
			var g:Graphics = cursor.graphics;
			g.clear();
			g.lineStyle(1, 0xFFFFFF, 1, true);
			g.beginFill(0x000000, 1);
			g.moveTo(-2, 0);
			g.lineTo(-2, 4);
			g.lineTo(-5, 4);
			g.lineTo(0, 9);
			g.lineTo(5, 4);
			g.lineTo(2, 4);
			g.lineTo(2, -4);
			g.lineTo(5, -4);
			g.lineTo(0, -9);
			g.lineTo(-5, -4);
			g.lineTo(-2, -4);
			g.lineTo(-2, 0);
			g.endFill();
		} // END drawCustomCursor()
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		private function cursorMove(event:MouseEvent):void{
			cursor.x = mouseX;
			cursor.y = mouseY;
			event.updateAfterEvent();
		} // END mouseMoveHandler()
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		public function addCustomCursor():void{
			this.addChild(cursor);
			Mouse.hide();
		} // END addCustomCursor()
		public function removeCustomCursor():void{
			this.removeChild(cursor);
			Mouse.show();
		} // END removeCustomCursor()
	} // END GUI Class
} // END package
