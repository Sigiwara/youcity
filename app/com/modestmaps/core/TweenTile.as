/*
 * vim:et sts=4 sw=4 cindent:
 * $Id$
 */

package com.modestmaps.core
{
	import gs.TweenLite;
	
	public class TweenTile extends Tile
	{
		public static var FADE_TIME:Number = 0.25;
				
		public function TweenTile(col:int, row:int, zoom:int)
		{
			super(col, row, zoom);
		} 
		
		override public function show():void 
		{
			if (alpha < 1) {
				TweenLite.to(this, FADE_TIME, { alpha: 1 });
			}
		}		
	}

}
