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
	import flash.events.MouseEvent;
	import flash.text.*;
	import ch.artillery.ui.Dashboard;
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
		public var dc						:DocumentClass;
		private var dashboard		:Dashboard;
		private var navButtons	:Sprite;
		//--------------------------------------
		//  CONSTANTS
		//--------------------------------------
		private const FONT			:String	= 'Arial';
		private const T_COLOR		:uint		= 0xFFFFFF;
		private const T_SIZE		:uint		= 16;
		private const PADDING		:uint		= 20;
		private const BG_SIZE		:uint		= 20;
		private const BG_COLOR	:uint		= 0x688599;
		/**
		 *	@Constructor
		 */
		public function GUI(_dc:DocumentClass):void{
			//  DEFINITIONS
			//--------------------------------------
			dc = _dc;
			//  CALLS
			//--------------------------------------
			setButtons();
			setDashboard();
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
		private function makeButton(name:String, labelText:String, action:Function):Sprite{
			var button:Sprite = new Sprite();
			button.name = name;
			button.graphics.moveTo(0, 0);
			button.graphics.beginFill(BG_COLOR, .70);
			button.graphics.drawRoundRect(0, 0, BG_SIZE, BG_SIZE, 5, 5);
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
	} // END GUI Class
} // END package
