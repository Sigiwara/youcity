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
	import ch.artillery.ui.slider.*;
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
		private var bg							:Sprite;
		private var shadow					:Sprite;
		private var params					:Array;
		private var drawer					:Drawer;
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
		public function Dashboard(_dc:DocumentClass){
			//  DEFINITIONS
			//--------------------------------------
			dc					= _dc;
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
			paramCount = dc.params.length;
			var i:uint = 0;
			for each (var param:XML in dc.params){
				var tParameter = new Parameter(this, param);
				addChild(tParameter);
				params.push(tParameter);
				tParameter.y = dc.PADDING + i*(tParameter.height);
				tParameter.name = 'Parameter_'+i;
				i++;
			};
		} // END setParameters()
		private function setDrawer():void{
			drawer			= new Drawer(this);
			dc.addChild(drawer);
			drawer.x = BG_WIDTH;
			drawer.y = - drawer.height - 10;
		} // END setDrawer()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		public function setDashboard():void{
			setBackground();
			setShadow();
		} // END setDashboard()
		public function hideDrawer():void{
			TweenLite.to(drawer, 1, {y: - drawer.height - 10, ease:Cubic.easeOut});
		} // END hideDrawer()
		public function displayDrawer(_target:Parameter, _t:String, _b:String):void{
			drawer.setDrawer(_t, _b);
			var dY:Number = _target.y - (drawer.height - _target.height) / 2;
			if(dY <= 0){ dY = 0 };
			if(dY >= (stage.stageHeight - drawer.height)){ dY = stage.stageHeight - drawer.height };
			TweenLite.to(drawer, 1, {y:dY, ease:Cubic.easeOut});
		} // END displayDrawer()
	} // END Dashboard Class
}