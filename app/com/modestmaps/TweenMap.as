/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author tom
 *
 * com.modestmaps.TweenMap adds smooth animated panning and zooming to the basic Map class
 *
 */
package com.modestmaps
{
	import com.modestmaps.core.*;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.IMapProvider;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import gs.TweenLite;
	
    public class TweenMap extends Map
	{

		/** easing function used for panLeft, panRight, panUp, panDown */
		public var panEase:Function = quadraticEaseOut;
		/** time to pan using panLeft, panRight, panUp, panDown */
		public var panDuration:Number = 0.5;

		/** easing function used for zoomIn, zoomOut */
		public var zoomEase:Function = quadraticEaseOut;
		/** time to zoom using zoomIn, zoomOut */
		public var zoomDuration:Number = 0.2;

		/** time to pan and zoom using, uh, panAndZoom */
		public var panAndZoomDuration:Number = 0.3;

        /*
	    * Initialize the map: set properties, add a tile grid, draw it.
	    * Default extent covers the entire globe, (+/-85, +/-180).
	    *
	    * @param    Width of map, in pixels.
	    * @param    Height of map, in pixels.
	    * @param    Whether the map can be dragged or not.
	    * @param    Desired map provider, e.g. Blue Marble.
	    *
	    * @see com.modestmaps.core.TileGrid
	    */
	    public function TweenMap(width:Number=320, height:Number=240, draggable:Boolean=true, provider:IMapProvider=null, ... rest)
	    {
	    	super(width, height, draggable, provider, rest);	    	
        }

	   /** Pan up by 1/3 (or panFraction) of the map height. */
	    override public function panUp(event:Event=null):void
	    {
	    	if (!grid.panning && !grid.zooming) {
		    	grid.prepareForPanning();
		    	var target:Number = grid.panY+(mapHeight*panFraction/grid.scale);
	    	    TweenLite.to(grid, panDuration, { panY: target, onComplete: grid.donePanning, ease: panEase });
	    	}
	    }      
	
	   /** Pan down by 1/3 (or panFraction) of the map height. */
	    override public function panDown(event:Event=null):void
	    {
	    	if (!grid.panning && !grid.zooming) {
		    	grid.prepareForPanning();
		    	var target:Number = grid.panY-(mapHeight*panFraction/grid.scale);
	    	    TweenLite.to(grid, panDuration, { panY: target, onComplete: grid.donePanning, ease: panEase });
	    	}
	    }

	   	/** Pan left by 1/3 (or panFraction) of the map width. */	    
	    override public function panLeft(event:Event=null):void
	    {
	    	if (!grid.panning && !grid.zooming) {
		    	grid.prepareForPanning();
		    	var target:Number = grid.panX+(mapWidth*panFraction/grid.scale);
	    	    TweenLite.to(grid, panDuration, { panX: target, onComplete: grid.donePanning, ease: panEase });
	    	}
	    }      
	
	   	/** Pan left by 1/3 (or panFraction) of the map width. */	    
	    override public function panRight(event:Event=null):void
	    {
	    	if (!grid.panning && !grid.zooming) {
		    	grid.prepareForPanning();
		    	var target:Number = grid.panX-(mapWidth*panFraction/grid.scale);
	    	    TweenLite.to(grid, panDuration, { panX: target, onComplete: grid.donePanning, ease: panEase });
	    	}
	    }
	    
	    /** default easing function for panUp, panDown, panLeft, panRight and setCenter */
	    protected static function linearEaseOut(t:Number, b:Number, c:Number, d:Number):Number
	    {
			return c * t / d + b;
		}
		protected static function quadraticEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * (t /= d) * (t - 2) + b;
		}
		protected static function exponentialEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return t == d ? b + c : c * (-Math.pow(2, -10 * t / d) + 1) + b;
		}
		
		override public function panAndZoomIn(location:Location, targetPoint:Point=null):void
		{
			// remember where we are so we can zoom *from* here
			var startX:Number = grid.panX;
			var startY:Number = grid.panY;
			var startZoom:Number = grid.zoomLevel;

			// zoom first so that the calculation for location is correct
			grid.prepareForZooming();
			grid.zoomLevel = Math.min(grid.maxZoom, Math.ceil(grid.zoomLevel+1.0));	
					
			// figure out the pan
	    	var p:Point = locationPoint(location,this);
	    	if (!targetPoint) targetPoint = new Point(mapWidth/2, mapHeight/2);
    		var pan:Point = targetPoint.subtract(p);

			// now apply the pan
    		grid.prepareForPanning();
    		grid.panX += (pan.x / grid.scale);
    		grid.panY += (pan.y / grid.scale);
    		
    		// now reset and tween here instead    		
     		TweenLite.from(grid, panAndZoomDuration, { panY: startY, panX: startX, onComplete: grid.donePanning, ease: panEase });			
   			TweenLite.from(grid, panAndZoomDuration, { zoomLevel: startZoom, onComplete: grid.doneZooming, ease: zoomEase, overwrite: false });
		}

        public function panAndZoomOut(location:Location, targetPoint:Point=null):void
        {
            // remember where we are so we can zoom *from* here
            var startX:Number = grid.panX;
            var startY:Number = grid.panY;
            var startZoom:Number = grid.zoomLevel;

            // zoom first so that the calculation for location is correct
            grid.prepareForZooming();
            grid.zoomLevel = Math.max(grid.minZoom, Math.ceil(grid.zoomLevel - 1.0)); // thanks NPaquin! 
                    
            // figure out the pan
            var p:Point = locationPoint(location,this);
            if (!targetPoint) targetPoint = new Point(mapWidth/2, mapHeight/2);
            var pan:Point = targetPoint.subtract(p);

            // now apply the pan
            grid.prepareForPanning();
            grid.panX += (pan.x / grid.scale);
            grid.panY += (pan.y / grid.scale);
            
            // now reset and tween here instead         
            TweenLite.from(grid, panAndZoomDuration, { panY: startY, panX: startX, onComplete: grid.donePanning, ease: panEase });          
            TweenLite.from(grid, panAndZoomDuration, { zoomLevel: startZoom, onComplete: grid.doneZooming, ease: zoomEase, overwrite: false });
        }

        public function zoomInAbout(targetPoint:Point, duration:Number=-1):void
        {
            zoomByAbout(1, targetPoint, duration);
        }

        public function zoomOutAbout(targetPoint:Point, duration:Number=-1):void
        {
            zoomByAbout(-1, targetPoint, duration);
        }
        
        public function zoomByAbout(zoomDelta:int, targetPoint:Point, duration:Number=-1):void
        {
            if (duration < 0) duration = panAndZoomDuration;
            
            var location:Location = pointLocation(targetPoint);
            
            var startX:Number = grid.panX;
            var startY:Number = grid.panY;
            var startZoom:Number = grid.zoomLevel;
            
            var zoomed:Boolean = false;
            var targetZoom:int = Math.max(grid.minZoom, Math.min(grid.maxZoom, grid.zoomLevel + zoomDelta));
            if (grid.zoomLevel != targetZoom)
            {
                grid.zoomLevel = targetZoom;
                zoomed = true;
            }
            
            // now find the current position of the requested location:
            var p:Point = locationPoint(location);
            
            // now find the pan offset from the target point to the current center
            var pan:Point = targetPoint.subtract(p);
            
            // and move!
            if (zoomed) grid.prepareForZooming();
            grid.prepareForPanning();

            grid.panX += (pan.x / grid.scale);
            grid.panY += (pan.y / grid.scale);

            if (duration > 0)
            {
                if (zoomed)
                    TweenLite.from(grid, duration, {zoomLevel: startZoom,
                                                    onComplete: grid.doneZooming,
                                                    ease: zoomEase});
                TweenLite.from(grid, duration, {panX: startX,
                                                panY: startY,
                                                onComplete: grid.donePanning,
                                                ease: panEase,
                                                overwrite: false}); 
            }
            else
            {
                if (zoomed) grid.doneZooming();
                grid.donePanning();
            }
        }

        /** EXPERIMENTAL! */
        public function tweenExtent(extent:MapExtent, duration:Number=-1):void
        {
            if (duration < 0) duration = panAndZoomDuration;
            var position:MapPosition = extentPosition(extent);

            var sc:Number = Math.pow(2, position.coord.zoom);

            // figure out where in the world we are
            var tx:Number = -mapProvider.tileWidth * position.coord.column / sc;
            var ty:Number = -mapProvider.tileHeight * position.coord.row / sc;

            // plus the offset          
            tx += position.point.x / sc;
            ty += position.point.y / sc;

            grid.prepareForZooming();
            grid.prepareForPanning();

            TweenLite.to(grid, duration, {zoomLevel: position.coord.zoom,
                                          ease: linearEaseOut});
            TweenLite.to(grid, duration, {panY: ty,
                                          panX: tx,
                                          ease: exponentialEaseOut,
                                          overwrite: false,
                                          onComplete: onDoneTweeningExtent});
        }

        protected function onDoneTweeningExtent(event:Event=null):void
        {
            grid.donePanning();
            grid.doneZooming();
        }

	   /**
		 * Put the given location in the middle of the map, animated in panDuration using panEase.
		 * 
		 * Use setCenter or setCenterZoom for big jumps, set forceAnimate to true
		 * if you really want to animate to a location that's currently off screen.
		 * But no promises! 
		 * 
		 * @see com.modestmaps.TweenMap#panDuration
		 * @see com.modestmaps.TweenMap#panEase
  		 * @see com.modestmaps.TweenMap#tweenTo
  		 */
		override public function panTo(location:Location, forceAnimate:Boolean=false):void
		{
			var p:Point = locationPoint(location, grid);

			if (forceAnimate || (p.x >= 0 && p.x <= mapWidth && p.y >= 0 && p.y <= mapHeight))
			{
	     		var centerPoint:Point = new Point(mapWidth / 2, mapHeight / 2);
	    		var pan:Point = centerPoint.subtract(p);
	    		pan.x /= grid.scale;
	    		pan.y /= grid.scale;

	    		// grid.prepareForPanning();
	    		TweenLite.to(grid, panDuration, {panY: grid.panY + pan.y,
	    		                                 panX: grid.panX + pan.x,
	    		                                 ease: panEase,
	    		                                 onStart: grid.prepareForPanning,
	    		                                 onComplete: grid.donePanning});
	    	}
			else
			{
				setCenter(location);
			}
		}

	   /**
		 * Animate to put the given location in the middle of the map.
		 * Use setCenter or setCenterZoom for big jumps, or panTo for pre-defined animation.
		 * 
		 * @see com.modestmaps.Map#panTo
		 */
		public function tweenTo(location:Location, duration:Number, easing:Function=null):void
		{
    		var pan:Point = new Point(mapWidth/2, mapHeight/2).subtract(locationPoint(location,grid));
    		pan.x /= grid.scale;
    		pan.y /= grid.scale;
    		// grid.prepareForPanning();
    		TweenLite.to(grid, duration, {panY: grid.panY + pan.y,
    		                              panX: grid.panX + pan.x,
    		                              ease: easing,
    		                              onStart: grid.prepareForPanning,
    		                              onComplete: grid.donePanning});
		}
		
	    // keeping it DRY, as they say    
	  	// dir should be 1, for in, or -1, for out
	    override protected function zoomBy(dir:int):void
	    {
	    	if (!grid.panning)
	    	{
		    	var target:Number = (dir < 0) ? Math.floor(grid.zoomLevel + dir) : Math.ceil(grid.zoomLevel + dir);
		    	target = Math.max(grid.minZoom, Math.min(grid.maxZoom, target));

		    	TweenLite.to(grid, zoomDuration, {zoomLevel: target,
		    	                                  onStart: grid.prepareForZooming,
		    	                                  onComplete: grid.doneZooming,
		    	                                  ease: zoomEase });
		    }
	    }

		override public function createTile(column:int, row:int, zoom:int):Tile
		{
			return new TweenTile(column, row, zoom);
		}

	}
}

