/**
 * MapProvider for Open Street Map data.
 * 
 * @author migurski
 * $Id$
 */
package com.modestmaps.mapproviders
{ 
	import com.modestmaps.core.Coordinate;
	
	public class OpenStreetMapProvider
		extends AbstractMapProvider
		implements IMapProvider
	{
	    public function toString() : String
	    {
	        return "OPEN_STREET_MAP";
	    }
	
	    public function getTileUrls(coord:Coordinate):Array
	    {
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
	        return [ 'http://tile.openstreetmap.org/'+(sourceCoord.zoom)+'/'+(sourceCoord.column)+'/'+(sourceCoord.row)+'.png' ];
	    }
	    
	}
}