/**
 * @author migurski
 * $Id$
 */
package com.modestmaps.mapproviders
{
	import com.modestmaps.core.Coordinate;
	
	public class BlueMarbleMapProvider 
		extends AbstractMapProvider
		implements IMapProvider
	{
	    public function BlueMarbleMapProvider()
	    {
	        super();
	        __bottomRightInLimit.zoomTo(9);
	    }
	
	    public function toString():String
	    {
	        return "BLUE_MARBLE";
	    }
	
	    public function getTileUrls(coord:Coordinate):Array
	    {
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
	        return [ 'http://s3.amazonaws.com/com.modestmaps.bluemarble/' + 
	        		 (sourceCoord.zoom) + '-r' + (sourceCoord.row) + '-c' + (sourceCoord.column) +
	        	    '.jpg' ];
	    }
	    
	}
}