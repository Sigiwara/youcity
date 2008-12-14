//////////////////////////////////////////////////////////////////////////
//  ParameterEvent
//
//  Created by Benjamin Wiederkehr on 081205.
//  Copyright (c) 2008 Benjamin Wiederkehr / Artillery.ch. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////
package ch.artillery.ui.parameter{
	//--------------------------------------
	// IMPORT
	//--------------------------------------
	import flash.events.*;
	/**
	 *	Parameter Event for dispatching change status and index.
	 *
	 *	@langversion		ActionScript 3.0
	 *	@playerversion	Flash 9.0
	 *	@author					Benjamin Wiederkehr
	 *	@since					081118
	 */
	public class ParameterEvent extends Event{
		//--------------------------------------
		// VARIABLES
		//--------------------------------------
		public var index:uint;
		public var amount:uint;
		//--------------------------------------
		// CONSTANTS
		//--------------------------------------
		public static const GRIP_UP = "up";
		//--------------------------------------
		// CONSTRUCTOR
		//--------------------------------------
		public function ParameterEvent(type:String, _index:uint, _amount:uint):void{
			super(type);
			index = _index;
			amount = _amount;
		} // END SliderEvent()
		public override function clone():Event {
			return new ParameterEvent(type, index, amount);
		} // END clone()
	} // END ParameterEvent Class
} // END package ch.artillery.ui.parameter