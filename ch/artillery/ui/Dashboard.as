//////////////////////////////////////////////////////////////////////////
//  Dashboard
//
//  Created by Benjamin Wiederkehr on 081121.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.ui{
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.display.Sprite;
	import flash.display.Graphics;
	import ch.artillery.ui.parameter.*;
	import ch.artillery.ui.slider.*;
	import ch.artillery.ui.GUI;
	import gs.TweenLite;
	import fl.motion.easing.*;
	import flash.filters.DropShadowFilter;
	/**
	 *	Dashboard Class
	 *
	 */
	public class Dashboard extends Sprite{
		//--------------------------------------
		// VARIABLES
		//--------------------------------------
		private var dc							:DocumentClass;
		private var gui							:GUI;
		private var bg							:Sprite;
		private var shadow					:Sprite;
		private var drawer					:Drawer;
		public var params						:Array;
		public var paramCount				:uint;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private const BG_COLOR			:uint		= 0x046296;
		private const BG_OPACITY		:Number	= .60;
		public const BG_WIDTH				:uint		= 200;
		/**
		*	@Constructor
		*/
		public function Dashboard(_dc:DocumentClass, _gui:GUI){
			//  DEFINITIONS
			//--------------------------------------
			dc					= _dc;
			gui					= _gui;
			bg					= new Sprite();
			shadow			= new Sprite();
			params			= new Array();
			//  ADDINGS
			//--------------------------------------
			this.addChild(shadow);
			this.addChild(bg);
			//  LISTENERS
			//--------------------------------------
			//  CALLS
			//--------------------------------------
			setDashboard();
			setParameters();
			setDrawer();
		} // END Dashboard()
		//--------------------------------------
		// PRIVATE METHODS
		//--------------------------------------
		private function setDashboard():void{
			setBackground();
			setShadow();
		} // END setDashboard()
		private function setBackground():void{
			var g:Graphics = bg.graphics;
			g.clear();
			g.beginFill(BG_COLOR, BG_OPACITY);
			g.drawRect(0, 0, BG_WIDTH, dc.stage.stageHeight);
			g.endFill();
		} // END setBackground()
		private function setShadow():void{
			var g:Graphics = shadow.graphics;
			var shadowFilter:DropShadowFilter = new DropShadowFilter(5, 0, 0, .6, 6, 0, 1, 3, false, true, false);
			shadow.filters = [shadowFilter];
			g.clear();
			g.beginFill(0, 1);
			g.drawRect(0, 0, BG_WIDTH, dc.stage.stageHeight);
			g.endFill();
		} // END setShadow()
		private function setParameters():void{
			var i:uint = 0;
			paramCount = dc.params.length;
			for each (var param:XML in dc.params){
				var tParameter = new Parameter(dc, this, param, dc.layers.layers[i]);
				this.addChild(tParameter);
				params.push(tParameter);
				tParameter.y			= i*(tParameter.height);
				tParameter.name		= 'Parameter_'+i;
				tParameter.index	= i;
				i++;
			};
		} // END setParameters()
		private function setDrawer():void{
			drawer = new Drawer(this);
			gui.addChild(drawer);
			drawer.x = BG_WIDTH;
			drawer.y = - drawer.height - 10;
		} // END setDrawer()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		public function hideDrawer():void{
			TweenLite.to(drawer, 1, {y: - drawer.height - 10, ease:Cubic.easeOut});
		} // END hideDrawer()
		public function displayDrawer(_target:Parameter, _q:String, _b:String):void{
			drawer.setDrawer(_q, _b);
			var dY:Number = _target.y - (drawer.height - _target.height) / 2;
			if(dY <= 0){ dY = 0 };
			if(dY >= (stage.stageHeight - drawer.height)){ dY = stage.stageHeight - drawer.height };
			TweenLite.to(drawer, 1, {y:dY, ease:Cubic.easeOut});
		} // END displayDrawer()
		public function swapParameters(_p:Parameter):void{
			this.setChildIndex(_p, this.numChildren-1);
		} // END switchParameters()
		public function adjustParameters(_index:uint, _amount:Number):void{
			var tHeight:Number = 0;
			for each (var param:Parameter in params){
				param.adjustParameter(_amount);
				param.y = tHeight;
				tHeight += param._height;
			};
		} // END adjustParameters()
	} // END Dashboard Class
}