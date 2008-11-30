//////////////////////////////////////////////////////////////////////////
//  Marker
//
//  Created by Benjamin Wiederkehr on 081115.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.map{
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.display.Sprite;
	/**
	 *	Marker Class
	 *
	 */
	public class Marker extends Sprite{
		//--------------------------------------
		// VARIABLES
		//--------------------------------------
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private const M_COLOR		:uint		= 0x00CCFF;
		private const M_SIZE		:uint		= 12;
		/**
		*	@Constructor
		*/
		public function Marker(){
			//trace(scaleFactor);
		} // END Marker()
		//--------------------------------------
		// PUBLIC METHODS
		//--------------------------------------
		public function draw():void{
			graphics.beginFill(M_COLOR, 0.75);
			graphics.drawCircle(0, 0, M_SIZE);
		} // END draw()
		public function clear():void{
			this.graphics.clear();
		} // END clear()
	} // END Marker()
}