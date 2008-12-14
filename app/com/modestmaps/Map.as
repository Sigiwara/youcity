/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author migurski
 * @author darren
 * @author tom
 *
 * com.modestmaps.Map is the base class and interface for Modest Maps.
 *
 * @description Map is the base class and interface for Modest Maps.
 * 				Correctly attaching an instance of this Sprite subclass 
 * 				should result in a pannable map. Controls and event 
 * 				handlers must be added separately.
 *
 * @usage <code>
 *          import com.modestmaps.Map;
 *          import com.modestmaps.geo.Location;
 *          import com.modestmaps.mapproviders.BlueMarbleMapProvider;
 *          ...
 *          var map:Map = new Map(640, 480, true, new BlueMarbleMapProvider());
 *          addChild(map);
 *        </code>
 *
 */
package com.modestmaps
{
	import com.modestmaps.core.*;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.events.MarkerEvent;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.modestmaps.mapproviders.microsoft.MicrosoftProvider;
	import com.stamen.twisted.Reactor;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
    [Event(name="startZooming",      type="com.modestmaps.events.MapEvent")]
    [Event(name="stopZooming",       type="com.modestmaps.events.MapEvent")]
    [Event(name="zoomedBy",          type="com.modestmaps.events.MapEvent")]
    [Event(name="startPanning",      type="com.modestmaps.events.MapEvent")]
    [Event(name="stopPanning",       type="com.modestmaps.events.MapEvent")]
    [Event(name="panned",            type="com.modestmaps.events.MapEvent")]
    [Event(name="resized",           type="com.modestmaps.events.MapEvent")]
    [Event(name="copyrightChanged",  type="com.modestmaps.events.MapEvent")]
    [Event(name="beginExtentChange", type="com.modestmaps.events.MapEvent")]
    [Event(name="extentChanged",     type="com.modestmaps.events.MapEvent")]
    [Event(name="beginTileLoading",  type="com.modestmaps.events.MapEvent")]
    [Event(name="allTilesLoaded",    type="com.modestmaps.events.MapEvent")]
    [Event(name="markerRollOver",    type="com.modestmaps.events.MarkerEvent")]
    [Event(name="markerRollOut",     type="com.modestmaps.events.MarkerEvent")]
    [Event(name="markerClick",       type="com.modestmaps.events.MarkerEvent")]

    public class Map extends Sprite
	{
	    protected var mapWidth:Number = 320;
	    protected var mapHeight:Number = 240;
	    protected var __draggable:Boolean = true;
	
	    /** das grid */
	    public var grid:TileGrid;
	
		/** markers are attached here */
		public var markerClip:MarkerClip;
		
	    /** Who do we get our Map urls from? How far can we pan? */
	    protected var mapProvider:IMapProvider;
	
		/** htmlText to be added to a label - listen for MapEvent.COPYRIGHT_CHANGED */
		public var copyright:String = "";

		/** fraction of width/height to pan panLeft, panRight, panUp, panDown */
		public var panFraction:Number = 0.333333333;
		
        /**
	    * Initialize the map: set properties, add a tile grid, draw it.
	    * Default extent covers the entire globe, (+/-85, +/-180).
	    *
	    * @param    Width of map, in pixels.
	    * @param    Height of map, in pixels.
	    * @param    Whether the map can be dragged or not.
	    * @param    Desired map provider, e.g. Blue Marble.
	    * @param    Either a MapExtent or a Location and zoom (comma separated)
	    *
	    * @see com.modestmaps.core.TileGrid
	    */
	    public function Map(width:Number=320, height:Number=240, draggable:Boolean=true, provider:IMapProvider=null, ... rest)
	    {
	    	if (!Reactor.running())
	    	{
	    		// should this really be fatal?
	    		//trace('com.modestmaps.Map.init(): com.stamen.Twisted.Reactor ought to be running at this point.');
	    		Reactor.run(this, 100);
	    	}

			// don't call set map provider here
			// the extents are all squirrely
	        mapProvider = provider || new MicrosoftProvider(MicrosoftProvider.ROAD);

			// initialize the grid (so point/location/coordinate functions should be valid after this)
			grid = new TileGrid(this, mapWidth, mapHeight, draggable, mapProvider);
	        addChild(grid);

	        setSize(width, height);
	        
			markerClip = new MarkerClip(this);
			markerClip.addEventListener( MouseEvent.CLICK, onMarkerClick );
			markerClip.addEventListener( MouseEvent.ROLL_OVER, onMarkerRollOver, true );		
			markerClip.addEventListener( MouseEvent.ROLL_OUT, onMarkerRollOut, true );	
			addChild(markerClip);

			try {
		        ExternalInterface.addCallback("setCopyright", setCopyright);
		 	}
		 	catch (error:Error) {
		 		//trace("problem adding setCopyright as callback in Map.as");
		 		//trace(error.getStackTrace());
		 	}
			
			// if rest was passed in from super constructor in a subclass,
			// it will be an array...
			if (rest && rest.length > 0 && rest[0] is Array) {
				rest = rest[0];
			}
			// (doing that is OK because none of the arguments we're expecting are Arrays)
			
			// look at ... rest arguments for MapExtent or Location/zoom	        
        	if (rest && rest.length > 0 && rest[0] is MapExtent) {
        		setExtent(rest[0] as MapExtent);
        	}
        	else if (rest && rest.length > 1 && rest[0] is Location && rest[1] is Number) {
        		setCenterZoom(rest[0] as Location, rest[1] as Number);
        	}
        	else {
        		var extent:MapExtent = new MapExtent(85, -85, 180, -180);
        		//setExtent(extent);
        		
         		var l1:Location = mapProvider.coordinateLocation(mapProvider.outerLimits()[0]);
        		var l2:Location = mapProvider.coordinateLocation(mapProvider.outerLimits()[1]);

				if (!isNaN(l1.lat) && Math.abs(l1.lat) != Infinity) {
					extent.north = l1.lat;
				}        		
				if (!isNaN(l2.lat) && Math.abs(l2.lat) != Infinity) {
					extent.south = l2.lat;
				}        		
				if (!isNaN(l1.lon) && Math.abs(l1.lon) != Infinity) {
					extent.west = l1.lon;
				}        		
				if (!isNaN(l2.lon) && Math.abs(l2.lon) != Infinity) {
					extent.east = l2.lon;
				}
				
				//trace(extent);        		

        		setExtent(extent);			
        	}
        }
        
        

        /**
	    * Based on an array of locations, determine appropriate map
	    * bounds using calculateMapExtent(), and inform the grid of
	    * tile coordinate and point by calling grid.resetTiles().
	    * Resulting map extent will ensure that all passed locations
	    * are visible.
	    *
	    * @param    Array of locations.
	    *
	    * @see com.modestmaps.Map#calculateMapExtent
	    * @see com.modestmaps.core.TileGrid#resetTiles
	    */
	    public function setExtent(extent:MapExtent):void
	    {
	        onExtentChanging(this.getExtent());
	        var position:MapPosition = extentPosition(extent);
	        // tell grid what the rock is cooking
	        grid.resetTiles(position.coord, position.point);
	        onExtentChanged(this.getExtent());
            Reactor.callNextFrame(callCopyright);
	    }
	    
	   /**
	    * Based on a location and zoom level, determine appropriate initial
	    * tile coordinate and point using calculateMapCenter(), and inform
	    * the grid of tile coordinate and point by calling grid.resetTiles().
	    *
	    * @param    Location of center.
	    * @param    Desired zoom level.
	    *
	    * @see com.modestmaps.Map#calculateMapExtent
	    * @see com.modestmaps.core.TileGrid#resetTiles
	    */
	    public function setCenterZoom(location:Location, zoom:Number):void
	    {
	        if (zoom == grid.zoomLevel) {
	            setCenter(location);
	        }
	        else {
	        	onExtentChanging(this.getExtent());
	        	zoom = Math.min(Math.max(zoom, grid.minZoom), grid.maxZoom);
    	        var center:MapPosition = coordinatePosition(mapProvider.locationCoordinate(location).zoomTo(zoom));
    	        // tell grid what the rock is cooking
    	        grid.resetTiles(center.coord, center.point);
    	        onExtentChanged(this.getExtent());
    	        Reactor.callNextFrame(callCopyright);
    	    }
	    }
	   
        /**
         * Based on a zoom level, determine appropriate initial
         * tile coordinate and point using calculateMapCenter(), and inform
         * the grid of tile coordinate and point by calling grid.resetTiles().
         *
         * @param    Desired zoom level.
         *
         * @see com.modestmaps.Map#calculateMapExtent
         * @see com.modestmaps.core.TileGrid#resetTiles
         */
        public function setZoom(zoom:Number):void
        {
			if (zoom == grid.zoomLevel) { // do nothing!
				return;
			}
			else { // else hard reset
				onExtentChanging(this.getExtent());
				var center:MapPosition = coordinatePosition(grid.centerCoordinate().zoomTo(zoom));
				// tell grid what the rock is cooking
				grid.resetTiles(center.coord, center.point);
				onExtentChanged(this.getExtent());
				Reactor.callNextFrame(callCopyright);
			}
        }
                
	   /**
	    * Based on a coordinate, determine appropriate starting tile and position,
	    * and return a two-element object with a coord and a point.
	    */
	    public function coordinatePosition(centerCoord:Coordinate):MapPosition
	    {
	        // initial tile coordinate
	        var initTileCoord:Coordinate = new Coordinate( Math.floor(centerCoord.row),
                                                           Math.floor(centerCoord.column),
                                                           Math.floor(centerCoord.zoom) );
	
	        // initial tile position, assuming centered tile well in grid
	        var initX:Number = (initTileCoord.column - centerCoord.column) * mapProvider.tileWidth;
	        var initY:Number = (initTileCoord.row - centerCoord.row) * mapProvider.tileHeight;
	        var initPoint:Point = new Point(Math.round(initX), Math.round(initY));
	        
	        return new MapPosition(initTileCoord, initPoint);
	    }


		public function locationsPosition(locations:Array):MapPosition
		{
	        var TL:Coordinate = mapProvider.locationCoordinate(locations[0]);
	        var BR:Coordinate = TL.copy();
	        
	        // get outermost top left and bottom right coordinates to cover all locations
	        for (var i:int = 1; i < locations.length; i++)
			{
				var coordinate:Coordinate = mapProvider.locationCoordinate(locations[i]);
	            TL.row = Math.min(TL.row, coordinate.row);
				TL.column = Math.min(TL.column, coordinate.column),
				TL.zoom = Math.min(TL.zoom, coordinate.zoom);
	            BR.row = Math.max(BR.row, coordinate.row),
				BR.column = Math.max(BR.column, coordinate.column),
				BR.zoom = Math.max(BR.zoom, coordinate.zoom);
	        }
	
	        // multiplication factor between horizontal span and map width
	        var hFactor:Number = (BR.column - TL.column) / (mapWidth / mapProvider.tileWidth);
	        
	        // multiplication factor expressed as base-2 logarithm, for zoom difference
	        var hZoomDiff:Number = Math.log(hFactor) / Math.log(2);
	        
	        // possible horizontal zoom to fit geographical extent in map width
	        var hPossibleZoom:Number = TL.zoom - Math.ceil(hZoomDiff);
	        
	        // multiplication factor between vertical span and map height
	        var vFactor:Number = (BR.row - TL.row) / (mapHeight / mapProvider.tileHeight);
	        
	        // multiplication factor expressed as base-2 logarithm, for zoom difference
	        var vZoomDiff:Number = Math.log(vFactor) / Math.log(2);
	        
	        // possible vertical zoom to fit geographical extent in map height
	        var vPossibleZoom:Number = TL.zoom - Math.ceil(vZoomDiff);
	        
	        // initial zoom to fit extent vertically and horizontally
	        // additionally, make sure it's not outside the boundaries set by provider limits
	        var initZoom:Number = Math.min(hPossibleZoom, vPossibleZoom);
	        initZoom = Math.min(initZoom, mapProvider.outerLimits()[1].zoom);
	        initZoom = Math.max(initZoom, mapProvider.outerLimits()[0].zoom);
	
	        // coordinate of extent center
	        var centerRow:Number = (TL.row + BR.row) / 2;
	        var centerColumn:Number = (TL.column + BR.column) / 2;
	        var centerZoom:Number = (TL.zoom + BR.zoom) / 2;
	        var centerCoord:Coordinate = (new Coordinate(centerRow, centerColumn, centerZoom)).zoomTo(initZoom);
	        
	        return coordinatePosition(centerCoord);
		}

	   /*
	    * Based on an array of locations, determine appropriate map bounds
	    * in terms of tile grid, and return a two-element object with a coord
	    * and a point from calculateMapCenter().
	    */
	    public function extentPosition(extent:MapExtent):MapPosition
	    {
	    	var locations:Array = new Array(extent.northWest, extent.southEast);
	    	return locationsPosition(locations);
	    }

	   /*
	    * Return a MapExtent for the current map view.
	    * TODO: MapExtent needs adapting to deal with non-rectangular map projections
	    *
	    * @return   MapExtent object
	    */
	    public function getExtent():MapExtent
	    {
	        var extent:MapExtent = new MapExtent();
	        
	        if(!mapProvider)
	            return extent;
	
	        extent.northWest = mapProvider.coordinateLocation(grid.topLeftCoordinate);
	        extent.southEast = mapProvider.coordinateLocation(grid.bottomRightCoordinate);
	        return extent;
	    }
	
	   /*
	    * Return the current center location and zoom of the map.
	    *
	    * @return   Array of center and zoom: [center location, zoom number].
	    */
	    public function getCenterZoom():Array
	    {
	        return [mapProvider.coordinateLocation(grid.centerCoordinate()), grid.zoomLevel];
	    }

	   /*
	    * Return the current center location of the map.
	    *
	    * @return center Location
	    */
	    public function getCenter():Location
	    {
	        return mapProvider.coordinateLocation(grid.centerCoordinate());
	    }

	   /*
	    * Return the current zoom level of the map.
	    *
	    * @return   zoom number
	    */
	    public function getZoom():int
	    {
	        return Math.floor(grid.zoomLevel);
	    }

	
	   /**
	    * Set new map size, call onResized().
	    *
	    * @param    New map width.
	    * @param    New map height.
	    *
	    * @see com.modestmaps.Map#onResized
	    */
	    public function setSize(width:Number, height:Number):void
	    {
	        mapWidth = width;
	        mapHeight = height;

        	grid.resizeTo(new Point(mapWidth, mapHeight));

	        onResized();
	        
	        // mask out out of bounds marker remnants
	        scrollRect = new Rectangle(0,0,width,height);
	    }
	
	   /**
	    * Get map size.
	    *
	    * @return   Array of [width, height].
	    */
	    public function getSize():/*Number*/Array
	    {
	        var size:/*Number*/Array = [mapWidth, mapHeight];
	        return size;
	    }
	    
	    public function get size():Point
	    {
	        return new Point(mapWidth, mapHeight);
	    }
	    
	    public function set size(value:Point):void
	    {
	        setSize(value.x, value.y);
	    }

	   /** Get map width. */
	    public function getWidth():Number
	    {
	        return mapWidth;
	    }

	   /** Get map height. */
	    public function getHeight():Number
	    {
	        return mapHeight;
	    }
	
	   /**
	    * Get a reference to the current map provider.
	    *
	    * @return   Map provider.
	    *
	    * @see com.modestmaps.mapproviders.IMapProvider
	    */
	    public function getMapProvider():IMapProvider
	    {
	        return mapProvider;
	    }
	
	   /**
	    * Set a new map provider, repainting tiles and changing bounding box if necessary.
	    *
	    * @param   Map provider.
	    *
	    * @see com.modestmaps.mapproviders.IMapProvider
	    */
	    public function setMapProvider(newProvider:IMapProvider):void
	    {
	        var previousGeometry:String;
	        if (mapProvider)
	        {
	        	previousGeometry = mapProvider.geometry();
	        }
	    	var extent:MapExtent = getExtent();

	        mapProvider = newProvider;
	        if (grid)
	        {
	        	grid.setMapProvider(mapProvider);
	        }
	        
	        if (mapProvider.geometry() != previousGeometry)
			{
	        	setExtent(extent);
	        	// notify the marker clip that its cached coordinates are invalid
	        	markerClip.resetCoordinates();
	        }
	        
	        Reactor.callLater(1000,callCopyright);
	    }
	    
	   /**
	    * Get a point (x, y) for a location (lat, lon) in the context of a given clip.
	    *
	    * @param    Location to match.
	    * @param    Movie clip context in which returned point should make sense.
	    *
	    * @return   Matching point.
	    */
	    public function locationPoint(location:Location, context:DisplayObject=null):Point
	    {
	        var coord:Coordinate = mapProvider.locationCoordinate(location);
	        return grid.coordinatePoint(coord, context || this);
	    }
	    
	   /**
	    * Get a location (lat, lon) for a point (x, y) in the context of a given clip.
	    *
	    * @param    Point to match.
	    * @param    Movie clip context in which passed point should make sense.
	    *
	    * @return   Matching location.
	    */
	    public function pointLocation(point:Point, context:DisplayObject=null):Location
	    {
	        var coord:Coordinate = grid.pointCoordinate(point, context || this);
	        return mapProvider.coordinateLocation(coord);
	    }


	   /** Pan up by 1/3 (or panFraction) of the map height. */
	    public function panUp(event:Event=null):void
	    {
	    	if (!grid.panning && !grid.zooming) {
		    	grid.prepareForPanning();
		    	grid.panY = grid.panY+(mapHeight*panFraction/grid.scale);
	    	    grid.donePanning();
	    	}
	    }      
	
	   /** Pan down by 1/3 (or panFraction) of the map height. */
	    public function panDown(event:Event=null):void
	    {
	    	if (!grid.panning && !grid.zooming) {
		    	grid.prepareForPanning();
		    	grid.panY = grid.panY-(mapHeight*panFraction/grid.scale);
	    	    grid.donePanning();
	    	}
	    }

	   	/** Pan left by 1/3 (or panFraction) of the map width. */	    
	    public function panLeft(event:Event=null):void
	    {
	    	if (!grid.panning && !grid.zooming) {
		    	grid.prepareForPanning();
		    	grid.panX = grid.panX+(mapWidth*panFraction/grid.scale);
	    	    grid.donePanning();
	    	}
	    }      
	
	   	/** Pan left by 1/3 (or panFraction) of the map width. */	    
	    public function panRight(event:Event=null):void
	    {
	    	if (!grid.panning && !grid.zooming) {
		    	grid.prepareForPanning();
		    	grid.panX = grid.panX-(mapWidth*panFraction/grid.scale);
	    	    grid.donePanning();
	    	}
	    }
	    
		public function panAndZoomIn(location:Location, targetPoint:Point=null):void
		{
            //trace('zooming in about:', targetPoint);
			
			// first zoom in:
			if (grid.zoomLevel < grid.maxZoom) {
    			grid.prepareForZooming();
    			grid.zoomLevel = Math.min(grid.maxZoom, Math.ceil(grid.zoomLevel+1.0));
    			grid.doneZooming();
   			}
   			
			// now find the current position of the requested location:
	    	var p:Point = locationPoint(location,this);
	    	
	    	// now find the pan offset from the target point to the current center
     		if (!targetPoint) targetPoint = new Point(mapWidth/2, mapHeight/2);
    		var pan:Point = targetPoint.subtract(p);
    		
    		// and move!
    		grid.prepareForPanning();
    		grid.panX += (pan.x / grid.scale);
    		grid.panY += (pan.y / grid.scale);
    		grid.donePanning();			
		}
		
	   /**
		* put the given location in the middle of the map
		* (use panBy to animate if that's what you want)
		* @see com.modestmaps.Map#panFrames
		*/
		public function setCenter(location:Location):void
		{
			onExtentChanging(this.getExtent());
			var center:MapPosition = coordinatePosition(mapProvider.locationCoordinate(location).zoomTo(grid.zoomLevel));
			// tell grid what the rock is cooking
			grid.resetTiles(center.coord, center.point);
			onExtentChanged(this.getExtent());
			Reactor.callNextFrame(callCopyright);
		}

	   /**
		 * Put the given location in the middle of the map.
		 * 
		 * @see com.modestmaps.Map#panFrames
		 */
		public function panTo(location:Location, forceAnimate:Boolean=false):void
		{
			setCenter(location);
		}
	    
	   /**
	    * Zoom in by 200% over the course of several frames.
	    * @see com.modestmaps.Map#zoomFrames
	    */
	    public function zoomIn(event:Event=null):void
	    {
	    	zoomBy(1);
	    }

	   /**
	    * Zoom out by 50% over the course of several frames.
	    * @see com.modestmaps.Map#zoomFrames
	    */
	    public function zoomOut(event:Event=null):void
	    {
	    	zoomBy(-1);
	    }
	    	
	    // keeping it DRY, as they say    
	  	// dir should be 1, for in, or -1, for out
	    protected function zoomBy(dir:int):void
	    {
	    	if (!grid.panning) {
		    	var target:Number = dir < 0 ? Math.floor(grid.zoomLevel+dir) : Math.ceil(grid.zoomLevel+dir);
		    	grid.prepareForZooming();
		    	grid.zoomLevel = Math.min(Math.max(grid.minZoom, target), grid.maxZoom);
		    	grid.doneZooming();
		    }
	    } 
	    
	   /**
	    * Add a marker at the given location (lat, lon)
	    *
	    * @param    Location of marker.
	    * @param	optionally, a sprite (where sprite.name=id) that will always be in the right place
	    */
	    public function putMarker(location:Location, marker:DisplayObject=null):void
	    {
	        markerClip.attachMarker(marker, location);
	    }

		/**
		 * Get a marker with the given id if one was created.
		 *
		 * @param    ID of marker, opaque string.
		 */
		public function getMarker(id:String):DisplayObject
		{
			return markerClip.getMarker(id);
		}

	   /**
	    * Remove a marker with the given id.
	    *
	    * @param    ID of marker, opaque string.
	    */
	    public function removeMarker(id:String):void
	    {
	        markerClip.removeMarker(id); // also calls grid.removeMarker
	    }
	    
	   /**
 	    * Call javascript:modestMaps.copyright() with details about current view.
 	    * See js/copyright.js.
 	    */
 	    protected function callCopyright():void
 	    {
 	        var cenP:Point = new Point(mapWidth/2, mapHeight/2);
 	        var minP:Point = new Point(mapWidth/5, mapHeight/5);
 	        var maxP:Point = new Point(mapWidth*4/5, mapHeight*4/5);
 	       
 	        var cenC:Coordinate = grid.pointCoordinate(cenP, this);
 	        var minC:Coordinate = grid.pointCoordinate(minP, this);
 	        var maxC:Coordinate = grid.pointCoordinate(maxP, this);
 	       
	        var cenL:Location = mapProvider.coordinateLocation(mapProvider.sourceCoordinate(cenC));
 	        var minL:Location = mapProvider.coordinateLocation(mapProvider.sourceCoordinate(minC));
 	        var maxL:Location = mapProvider.coordinateLocation(mapProvider.sourceCoordinate(maxC));
 	   
 	        var minLat:Number = Math.min(minL.lat, maxL.lat);
 	        var minLon:Number = Math.min(minL.lon, maxL.lon);
 	        var maxLat:Number = Math.max(minL.lat, maxL.lat);
 	        var maxLon:Number = Math.max(minL.lon, maxL.lon);
 	       
 	       	try {
 	    	    ExternalInterface.call("modestMaps.copyright", mapProvider.toString(), cenL.lat, cenL.lon, minLat, minLon, maxLat, maxLon, grid.zoomLevel);
 	    	}
 	    	catch (error:Error) {
 	    		//trace("problem setting copyright in Map.as");
 	    		//trace(error.getStackTrace());	
 	    	}
 	    }
	    
	   /**  this function gets exposed to javascript as a callback, to use it
	    *   include copyright.js and override the modestMaps.copyright function to call
	    *   swfname.setCopyright("&copy blah blah")
	    * 
	    *   e.g. in the head of your html page, where your SWF is embedded with the name MyMap
	    * 
	    *   <script type="text/javascript" src="copyright.js">
	    *   <script type="text/javascript">
	    *     modestMaps.copyrightCallback = function(holdersHTML) {
        *       MyMap.setCopyright(holdersHTML);
        *     }
        *   </script>
        * 
        *   to display the copyright string in your flash piece, you then need to listen for 
        *   the COPYRIGHT_CHANGED MapEvent
	    */
	    public function setCopyright(copyright:String):void {
	    	this.copyright = copyright;
	    	this.copyright = this.copyright.replace(/&copy;/g,"©");
	    	var event:MapEvent = new MapEvent(MapEvent.COPYRIGHT_CHANGED);
	    	event.newCopyright = this.copyright;
	    	dispatchEvent(event);
	    }
	    	    
	   /**
	    * Dispatches MapEvent.RESIZED when the map is resized.
	    * The MapEvent includes the newSize.
	    *
	    * @see com.modestmaps.events.MapEvent.RESIZED
	    */
	    public function onResized():void
	    {
	    	var event:MapEvent = new MapEvent(MapEvent.RESIZED);
	    	event.newSize = this.getSize();
	        dispatchEvent(event);
	    }
	    
	   /**
	    * Dispatches MapEvent.EXTENT_CHANGED when the map is resized.
	    * The MapEvent includes the newExtent.
	    *
	    * @see com.modestmaps.events.MapEvent.EXTENT_CHANGED
	    */
	    public function onExtentChanged(extent:MapExtent):void
	    {
	        dispatchEvent(new MapEvent(MapEvent.EXTENT_CHANGED, extent));
	    }

	   /**
	    * Dispatches MapEvent.EXTENT_CHANGED when the map is resized.
	    * The MapEvent includes the newExtent.
	    *
	    * @see com.modestmaps.events.MapEvent.EXTENT_CHANGED
	    */
	    public function onExtentChanging(extent:MapExtent):void
	    {
	        dispatchEvent(new MapEvent(MapEvent.BEGIN_EXTENT_CHANGE, extent));
	    }	    
	    
	   /**
	    * Dispatches MarkerEvent.CLICK when a marker is clicked.
	    * 
	    * The MarkerEvent includes a reference to the marker and its location.
	    *
	    * @see com.modestmaps.events.MarkerEvent.CLICK
	    */
	    protected function onMarkerClick(event:MouseEvent):void
        {
        	var marker:DisplayObject = event.target as DisplayObject;
        	var location:Location = markerClip.getMarkerLocation( marker );
        	dispatchEvent( new MarkerEvent( MarkerEvent.CLICK, marker, location) );
        }
        
		/**
	    * Dispatches MarkerEvent.ROLL_OVER
	    * 
	    * The MarkerEvent includes a reference to the marker and its location.
	    *
	    * @see com.modestmaps.events.MarkerEvent.ROLL_OVER
	    */
        protected function onMarkerRollOver(event:MouseEvent):void
        {
        	var marker:DisplayObject = event.target as DisplayObject;
        	var location:Location = markerClip.getMarkerLocation( marker );
        	dispatchEvent( new MarkerEvent( MarkerEvent.ROLL_OVER, marker, location) );
        }
        
        /**
	    * Dispatches MarkerEvent.ROLL_OUT
	    * 
	    * The MarkerEvent includes a reference to the marker and its location.
	    *
	    * @see com.modestmaps.events.MarkerEvent.ROLL_OUT
	    */
        protected function onMarkerRollOut(event:MouseEvent):void
        {
            var marker:DisplayObject = event.target as DisplayObject;
            var location:Location = markerClip.getMarkerLocation( marker );
        	dispatchEvent( new MarkerEvent( MarkerEvent.ROLL_OUT, marker, location) );
        }

        /** sets double click handling to panAndZoomIn */
		override public function set doubleClickEnabled(enabled:Boolean):void
		{
			if (enabled) {
				grid.doubleClickEnabled = true;
				grid.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			}
			else if (grid.hasEventListener(MouseEvent.DOUBLE_CLICK)) {
				grid.doubleClickEnabled = false;
				grid.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			}
			super.doubleClickEnabled = enabled;
		}        

        /** pans and zooms in on double clicked location */
        protected function onDoubleClick(event:MouseEvent):void
        {
            var p:Point = grid.globalToLocal(new Point(event.stageX, event.stageY));
            panAndZoomIn(pointLocation(p,grid));
        }

		/** override this if you want to create your own tiles */
	    public function createTile(column:int, row:int, zoom:int):Tile
	    {
	    	return new Tile(column, row, zoom);
	    }        
		
	}
}

