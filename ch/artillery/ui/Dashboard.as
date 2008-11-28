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
		private var parameters			:Array;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private const BG_COLOR			:uint		= 0x688599;
		private const BG_OPACITY		:Number	= .70;
		public const BG_WIDTH				:uint		= 200;
		public const PARAMS					:uint		= 10;
		/**
		*	@Constructor
		*/
		public function Dashboard(_dc:DocumentClass){
			//  DEFINITIONS
			//--------------------------------------
			dc					= _dc;
			parameters	= new Array();
			//  LISTENERS
			//--------------------------------------
			//  CALLS
			//--------------------------------------
			draw();
			setParameters();
		} // END Dashboard()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		private function draw():void{
			graphics.beginFill(BG_COLOR, BG_OPACITY);
			graphics.drawRect(0, 0, BG_WIDTH, dc.stage.stageHeight);
			graphics.endFill();
		} // END draw()
		private function setParameters():void{
			for (var i:int = 0; i<PARAMS; i++){
				var tParameter = new Parameter(this);
				addChild(tParameter);
				parameters.push(tParameter);
				tParameter.y = dc.PADDING + i*(tParameter.height);
				tParameter.name = 'Parameter_'+i;
			};
		} // END setParameters()
		private function sChanged(_e:SliderEvent):void{
			trace(_e.target.name + ': ' + _e.amount);
		} // END sCHanged()
	} // END Dashboard Class
}