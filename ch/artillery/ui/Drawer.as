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
	import flash.filters.DropShadowFilter;
	
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
		private var shadow			:Sprite;
		private var title				:TextField;
		private var body				:TextField;
		//--------------------------------------
		//  CONSTANTS
		//--------------------------------------
		private const FONT					:String	= 'Georgia';
		private const COLOR					:uint		= 0x000000;
		private const T_SIZE				:uint		= 24;
		private const B_SIZE				:uint		= 16;
		private const PADDING				:uint		= 10;
		private const PADDING_LEFT	:uint		= 20;
		private const LINE					:uint		= 10;
		private const BG_COLOR			:uint		= 0x688599;
		private const BG_OPACITY		:Number		= .70;
		/**
		 *	@Constructor
		 */
		public function Drawer(_db:Dashboard):void{
			//  DEFINITIONS
			//--------------------------------------
			dashboard	= _db;
			bg				= new Sprite();
			shadow		= new Sprite();
			title			= new TextField();
			body			= new TextField();
			//  ADDINGS
			//--------------------------------------
			this.addChild(shadow);
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
			title.multiline	= true;
			title.wordWrap	= true;
			title.width			= dashboard.BG_WIDTH - PADDING - PADDING_LEFT;
			body.multiline	= true;
			body.wordWrap		= true;
			body.width			= dashboard.BG_WIDTH - PADDING - PADDING_LEFT;
		} // END setTextFields()
		private function setText(_title:String = null, _body:String = null):void{
			title.htmlText	= (_title) ? _title : "Title";
			body.htmlText		= (_body) ? _body : "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
			formatText(title, COLOR, T_SIZE);
			formatText(body, COLOR, B_SIZE, true);
		} // END setText()
		private function layoutAssets():void{
			title.x			= PADDING_LEFT;
			title.y			= PADDING;
			body.x			= title.x;
			body.y			= title.y + title.textHeight + LINE;
		} // END layoutAssets()
		private function formatText(_tf:TextField, _color = null, _size = null, _italic:Boolean = false):void {
			var tFormat:TextFormat = new TextFormat();
			tFormat.font		= FONT;
			tFormat.color		= (_color) ? _color : COLOR;
			tFormat.size		= (_size) ? _size : B_SIZE;
			tFormat.italic	= (true) ? _italic : false;
			_tf.setTextFormat(tFormat);
		} // END formatText()
		private function setBackground():void{
			var g:Graphics = bg.graphics;
			g.clear();
			g.beginFill(BG_COLOR, BG_OPACITY);
			g.drawRect(0, 0, Math.round(dashboard.BG_WIDTH), Math.round(body.y + body.height + PADDING));
			g.endFill();
		} // END setBackground()
		private function setShadow():void{
			var g:Graphics = shadow.graphics;
			var shadowFilter:DropShadowFilter = new DropShadowFilter(0, 0, 0, .5, 8, 8, 1, 3, false, true, false);
			shadow.filters = [shadowFilter];
			g.clear();
			g.beginFill(0, 1);
			g.drawRect(0, 0, Math.round(dashboard.BG_WIDTH), Math.round(body.y + body.height + PADDING));
			g.endFill();
		} // END setShadow()
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		public function setDrawer(_t:String = null, _b:String = null):void{
			setText(_t, _b);
			layoutAssets();
			setBackground();
			setShadow();
		} // END setDrawer()
	} // END Drawer Class
} // END package ch.artillery.ui
