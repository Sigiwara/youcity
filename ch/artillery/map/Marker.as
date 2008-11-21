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
		public var scaleFactor	:uint;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		private const M_COLOR		:uint		= 0x51BFF7;
		private const M_SIZE		:uint		= 12;
		/**
		*	@Constructor
		*/
		public function Marker(_scaleFactor:uint){
			scaleFactor = _scaleFactor;
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
		public function scale(scaleFactor:uint):void{
			//trace(_scaleFactor);
		} // END scale()
	} // END Marker()
}