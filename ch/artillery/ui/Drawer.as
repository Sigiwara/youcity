//////////////////////////////////////////////////////////////////////////
//  Drawer
//
//  Created by Benjamin Wiederkehr on 2008-11-28.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.ui{	
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.*;
	import flash.text.*;
	
	/**
	 *	Drawer for the dashboard parameters.
	 *
	 *	@langversion		ActionScript 3.0
	 *	@playerversion	Flash 9.0
	 *	@author					Benjamin Wiederkehr
	 *	@since					2008-11-28
	 *	@version				0.1
	 */
	public class Drawer extends Sprite {
		
		//--------------------------------------
		//  VARIABLES
		//--------------------------------------
		private var dashboard		:Dashboard;
		private var bg					:Sprite;
		private var title				:TextField;
		private var body				:TextField;
		//--------------------------------------
		//  CONSTANTS
		//--------------------------------------
		private const FONT			:String	= 'Georgia';
		private const COLOR			:uint		= 0x000000;
		private const T_SIZE		:uint		= 24;
		private const B_SIZE		:uint		= 16;
		private const PADDING		:uint		= 10;
		private const LINE			:uint		= 10;
		private const BG_COLOR	:uint		= 0xFFFFFF;
		private const BG_OPACITY:Number		= .75;
		/**
		 *	@Constructor
		 */
		public function Drawer(_db:Dashboard):void{
			//  DEFINITIONS
			//--------------------------------------
			dashboard	= _db;
			bg				= new Sprite();
			title			= new TextField();
			body			= new TextField();
			//  ADDINGS
			//--------------------------------------
			this.addChild(bg);
			this.addChild(title);
			this.addChild(body);
			//  LISTENERS
			//--------------------------------------
			//  CALLS
			//--------------------------------------
			setTextFields();
			setDrawer();
		}
		//--------------------------------------
		//  PRIVATE METHODS
		//--------------------------------------
		private function setTextFields():void{
			title.width			= dashboard.BG_WIDTH - PADDING*2;
			title.multiline	= true;
			body.width			= dashboard.BG_WIDTH - PADDING*2;
			body.multiline	= true;
		} // END setTextFields()
		private function setText(_title:String = null, _body:String = null):void{
			title.text = (_title) ? _title : "Title";
			formatText(title, COLOR, T_SIZE);
			body.text = (_body) ? _body : "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
			formatText(body, COLOR, B_SIZE);
		} // END setText()
		private function layoutAssets():void{
			title.x			= PADDING;
			title.y			= PADDING;
			body.x			= title.x;
			body.y			= title.y + title.textHeight + LINE;
		} // END layoutAssets()
		private function formatText(_tf:TextField, _color = false, _size = false):void {
			var tFormat:TextFormat = new TextFormat();
			tFormat.font = FONT;
			tFormat.color = (_color) ? _color : COLOR;
			tFormat.color = (_size) ? _size : B_SIZE;
			_tf.setTextFormat(tFormat);
		} // END formatText()
		private function setBackground():void{
			var g:Graphics = bg.graphics;
			g.clear();
			g.beginFill(BG_COLOR, BG_OPACITY);
			g.drawRect(0, 0, Math.round(dashboard.BG_WIDTH), Math.round(body.y + body.height + PADDING));
			g.endFill();
		} // END setBackground()
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		public function setDrawer(_t:String = null, _b:String = null):void{
			setText(_t, _b);
			layoutAssets();
			setBackground();
		} // END setDrawer()
	} // END Drawer Class
} // END package ch.artillery.ui
