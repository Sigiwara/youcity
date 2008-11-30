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
		private var params					:Array;
		private var drawer					:Drawer;
		public var paramCount				:uint;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private const BG_COLOR			:uint		= 0x688599;
		private const BG_OPACITY		:Number	= .70;
		public const BG_WIDTH				:uint		= 200;
		/**
		*	@Constructor
		*/
		public function Dashboard(_dc:DocumentClass){
			//  DEFINITIONS
			//--------------------------------------
			dc					= _dc;
			bg					= new Sprite();
			params			= new Array();
			//  ADDINGS
			//--------------------------------------
			this.addChild(bg);
			//  LISTENERS
			//--------------------------------------
			//  CALLS
			//--------------------------------------
			draw();
			setParameters();
			setDrawer();
		} // END Dashboard()
		//--------------------------------------
		// PRIVATE METHODS
		//--------------------------------------
		private function draw():void{
			var g:Graphics = bg.graphics;
			g.beginFill(BG_COLOR, BG_OPACITY);
			g.drawRect(0, 0, BG_WIDTH, dc.stage.stageHeight);
			g.endFill();
		} // END draw()
		private function setParameters():void{
			paramCount = dc.params.length;
			for (var i:int = 0; i<paramCount; i++){
				var tParameter = new Parameter(this);
				addChild(tParameter);
				params.push(tParameter);
				tParameter.y = dc.PADDING + i*(tParameter.height);
				tParameter.name = 'Parameter_'+i;
				//dc.params[i].title
			};
		} // END setParameters()
		private function setDrawer():void{
			drawer			= new Drawer(this);
			dc.addChild(drawer);
			drawer.x = dc.stage.stageWidth / 2 - drawer.width / 2;
			drawer.y = dc.stage.stageHeight / 2 - drawer.height / 2;
		} // END setDrawer()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		public function displayDrawer(_target:Parameter, _t:String, _b:String):void{
			drawer.setDrawer(_t, _b);
			drawer.x = BG_WIDTH;
			drawer.y = _target.y - ((_target.height - drawer.height) / 2);
		} // END displayDrawer()
	} // END Dashboard Class
}