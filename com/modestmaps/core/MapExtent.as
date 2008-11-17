/*
 * $Id$
 */

package com.modestmaps.core
{
	import com.modestmaps.geo.Location;
	
	public class MapExtent extends Object
	{
		// TODO: OK for rectangular projections, but we need a better way for other projections
		public var north:Number;
		public var south:Number;
		public var east:Number;
		public var west:Number;
		
		/** Creates a new MapExtent from the given String.
		 * @param str "north, south, east, west"
		 * @return a new MapExtent from the given string */
		public static function fromString(str:String):MapExtent
		{
			var parts:Array = str.split(/\s*,\s*/, 4);
			return new MapExtent(parseFloat(parts[0]),
								 parseFloat(parts[1]),
								 parseFloat(parts[2]),
								 parseFloat(parts[3]));
		}

        public static function fromLocations(locations:Array):MapExtent
        {
            var minLat:Number = Number.POSITIVE_INFINITY;
            var minLon:Number = Number.POSITIVE_INFINITY;
            var maxLat:Number = Number.NEGATIVE_INFINITY;
            var maxLon:Number = Number.NEGATIVE_INFINITY;
            for each (var location:Location in locations)
            {
                if (!location) continue;
                minLat = Math.min(minLat, location.lat);
                maxLat = Math.max(maxLat, location.lat);
                minLon = Math.min(minLon, location.lon);
                maxLon = Math.max(maxLon, location.lon);
            }
            return new MapExtent(maxLat, minLat, maxLon, minLon);
        }
        
		/** @param n the most northerly latitude
		 *  @param s the southern latitude
		 *  @param e the eastern-most longitude
		 *  @param w the westest longitude */
		public function MapExtent(n:Number=0, s:Number=0, e:Number=0, w:Number=0)
		{
			north = Math.max(n, s);
			south = Math.min(n, s);
			east = Math.max(e, w);
			west = Math.min(e, w);
		}
		
		public function clone():MapExtent
		{
		    return new MapExtent(north, south, east, west);
		}
		
		/** enlarges this extent so that the given extent is inside it */
		public function encloseExtent(extent:MapExtent):void
		{
		    north = Math.max(extent.north, north);
		    south = Math.min(extent.south, south);
		    east = Math.max(extent.east, east);
		    west = Math.min(extent.west, west);		    
		}
		
		/** enlarges this extent so that the given location is inside it */
		public function enclose(location:Location):void
		{
		    north = Math.max(location.lat, north);
		    south = Math.min(location.lat, south);
		    east = Math.max(location.lon, east);
		    west = Math.min(location.lon, west);
		}
		
		public function get northWest():Location
		{
			return new Location(north, west);
		}
		
		public function get southWest():Location
		{
			return new Location(south, west);
		}
		
		public function get northEast():Location
		{
			return new Location(north, east);
		}
		
		public function get southEast():Location
		{
			return new Location(south, east);
		}
		
		public function set northWest(nw:Location):void
		{
			north = nw.lat;
			west = nw.lon;
		}
		
		public function set southWest(sw:Location):void
		{
			south = sw.lat;
			west = sw.lon;
		}
		
		public function set northEast(ne:Location):void
		{
			north = ne.lat;
			east = ne.lon;
		}
		
		public function set southEast(se:Location):void
		{
			south = se.lat;
			east = se.lon;
		}

		public function get center():Location
        {   
            return new Location(south + (north - south) / 2, east + (west - east) / 2);
        }

        public function set center(location:Location):void
        {   
            var w:Number = east - west;
            var h:Number = north - south;
            north = location.lat - h / 2;
            south = location.lat + h / 2;
            east = location.lon + w / 2;
            west = location.lon - w / 2;
        }

        public function inflate(lat:Number, lon:Number):void
        {
            north += lat;
            south -= lat;
            west -= lon;
            east += lon;
        }

		/** @return "north, south, east, west" */
		public function toString():String
		{
			return [north, south, east, west].join(', ');
		}
		
		public static function fromLocationArray(locations:Array):MapExtent
		{
			if (!locations || locations.length == 0) return new MapExtent();

			var first:Location = locations[0] as Location;
			var extent:MapExtent = new MapExtent(first.lat, first.lat, first.lon, first.lon);
			for (var i:int = 1; i < locations.length; i++)
			{
				extent.enclose(locations[i]);
			}
			return extent;
		}
		
	}
}