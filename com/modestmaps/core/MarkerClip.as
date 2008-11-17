/*
 * vim:et sts=4 sw=4 cindent:
 * $Id$
 */

package com.modestmaps.core {

	import com.modestmaps.Map;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.geo.Location;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
    /** This is different from the as2 version for now, because
	 *  it makes more sense to me if you give it a Sprite 
	 *  (or DisplayObject) to take care of rather than ask it to
	 *  make one for you.
	 */
	public class MarkerClip extends Sprite
	{
		// TODO: mask me?
	    protected var map:Map;
	    protected var starting:Point;
	    protected var locations:Dictionary = new Dictionary();
	    protected var coordinates:Dictionary = new Dictionary();
	    protected var markers:Array = []; // all markers
	    protected var markersByName:Object = {};

        // enable this if you want intermediate zooming steps to
        // stretch your graphics instead of reprojecting the points
        // it looks worse and probably isn't faster, but there it is :)
        public var scaleZoom:Boolean = false;
        
        // enable this if you want marker locations snapped to pixels
        public var snapToPixels:Boolean = false;
        
        // the function used to sort the markers array before re-ordering them
        // on the z plane (by child index)
        public var markerSortFunction:Function = sortMarkersByYPosition;

		// setting this.dirty = true will request an Event.RENDER
		protected var _dirty:Boolean;

        /**
         * This is the function provided to markers.sort() in order to determine which
         * markers should go in front of the others. The default behavior is to place
         * markers further down on the screen (with higher y values) frontmost. You
         * can modify this behavior by specifying a different value for
         * MarkerClip.markerSortFunction
         */
        public static function sortMarkersByYPosition(a:DisplayObject, b:DisplayObject):int
        {
            var diffY:Number = a.y - b.y;
            return (diffY > 0) ? 1 : (diffY < 0) ? -1 : 0;
        }
		
	    public function MarkerClip(map:Map)
	    {
	    	// client code can listen to mouse events on this clip
	    	// to get all events bubbled up from the markers
	    	buttonMode = false;
	    	mouseEnabled = false;
	    	mouseChildren = true;
	    		    	
	    	this.map = map;
	    	this.x = map.getWidth() / 2;
	    	this.y = map.getHeight() / 2;
	        //map.addEventListener(MarkerEvent.ENTER, onMapMarkerEnters);
	        //map.addEventListener(MarkerEvent.LEAVE, onMapMarkerLeaves);
	        map.addEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
	        map.addEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
	        map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
	        map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
	        map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
	        map.addEventListener(MapEvent.PANNED, onMapPanned);
	        map.addEventListener(MapEvent.RESIZED, onMapResized);
	        map.addEventListener(MapEvent.EXTENT_CHANGED, onMapExtentChanged);

	        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        override public function set x(value:Number):void
        {
            super.x = snapToPixels ? Math.round(value) : value;
        }
        
        override public function set y(value:Number):void
        {
            super.y = snapToPixels ? Math.round(value) : value;
        }
        
        protected function onAddedToStage(event:Event):void
        {
	        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        	addEventListener(Event.RENDER, updateClips);
	        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        }
        protected function onRemovedFromStage(event:Event):void
        {
	        removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        	removeEventListener(Event.RENDER, updateClips);
	        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        public function attachMarker(marker:DisplayObject, location:Location):void
	    {
	        // TODO: optionally index markers and throw marker events?
	        //map.grid.putMarker(marker.name, map.getMapProvider().locationCoordinate(location), location);
	        
	        locations[marker] = new Location(location.lat, location.lon);
	        coordinates[marker] = map.getMapProvider().locationCoordinate(location);
	        markersByName[marker.name] = marker;
	        markers.push(marker);
	        
	        var point:Point = map.locationPoint(location, this);
            marker.x = snapToPixels ? Math.round(point.x) : point.x;
            marker.y = snapToPixels ? Math.round(point.y) : point.y;
	        
	        var w:Number = map.getWidth() * 2;
	        var h:Number = map.getHeight() * 2;
	        if (markerInBounds(marker, w, h))
	        {
                addChild(marker);
                sortMarkers(true);
            }
	    }
	    
	    protected function markerInBounds(marker:DisplayObject, w:Number, h:Number):Boolean
	    {
	        return marker.x > -w / 2 && marker.x < w / 2 &&
	               marker.y > -h / 2 && marker.y < h / 2;
	    }
	    
	    public function getMarker(id:String):DisplayObject
	    {
	        return markersByName[id] as DisplayObject;
	    }
	    
	    public function getMarkerLocation( marker:DisplayObject ) : Location {
	    	return locations[marker];
	    }
	    
	    public function setMarkerLocation(marker:DisplayObject, location:Location):void
	    {
	        locations[marker] = new Location(location.lat, location.lon);
	        coordinates[marker] = map.getMapProvider().locationCoordinate(location);
	        sortMarkers();
	        dirty = true;
	    }
	    
	    public function removeMarker(id:String):void
	    {
	    	var marker:DisplayObject = getMarker(id);
	    	if (marker)
	    	{
	    		removeMarkerObject(marker);
    	    }
	    }
	    
	    public function removeMarkerObject(marker:DisplayObject):void
	    {
	    	if (this.contains(marker)) {
	    		removeChild(marker);
	    	}
	    	var index:int = markers.indexOf(marker);
	    	if (index >= 0) {
	    		markers.splice(index,1);
	    	}
	    	delete locations[marker];
	    	delete coordinates[marker];
	    	delete markersByName[marker.name];
	    }
	        
	    public function updateClips(event:Event=null):void
	    {
	    	if (!dirty) {
	    		return;
	    	}
	    	
	        var marker:DisplayObject;

	    	//var t:int = flash.utils.getTimer();
	        var w:Number = map.getWidth() * 2;
	        var h:Number = map.getHeight() * 2;
	        var doSort:Boolean = false;
	    	for each (marker in markers)
	    	{
	    	    // TODO: note, hidden markers are not updated, so when 
	    	    // revealing markers using visible=true, they may end up in the wrong spot ?
	    	    if (marker.visible)
	    	    {
	                updateClip(marker);
        	        if (markerInBounds(marker, w, h))
        	        {
        	            if (!contains(marker))
        	            {
        	                addChild(marker);
        	                doSort = true;
        	            }
        	        }
        	        else if (contains(marker))
        	        {
        	            removeChild(marker);
        	            doSort = true;
        	        }
	            }
	    	}

            if (doSort) sortMarkers(true);
            
	    	dirty = false;
	    	//trace("reprojected all markers in " + (flash.utils.getTimer() - t) + "ms");
	    }
	    
	    /** call this if you've made a change to the underlying map geometry such that
	      * provider.locationCoordinate(location) will return a different coordinate */
	    public function resetCoordinates():void
	    {
	    	for each (var marker:DisplayObject in markers) {
				coordinates[marker] = map.getMapProvider().locationCoordinate(locations[marker]);
	    	}
	    }
	    
	    public function sortMarkers(updateOrder:Boolean=false):void
	    {
			// only sort if we have a function:	        
            if (updateOrder && markerSortFunction != null)
	        {
	            markers = markers.sort(markerSortFunction, Array.NUMERIC);
	        }
	        // apply depths to maintain the order things were added in
	        var index:uint = 0;
	        for each (var marker:DisplayObject in markers)
	        {
	            if (contains(marker))
	            {
	                setChildIndex(marker, index);
	                index++;
	            }
	        }
	    }

	    public function updateClip(marker:DisplayObject):void
	    {
	    	// this method previously used the location of the marker
	    	// but map.locationPoint hands off to grid to grid.coordinatePoint
	    	// in the end so we may as well cache the first step
	        var point:Point = map.grid.coordinatePoint(coordinates[marker], this);
            marker.x = snapToPixels ? Math.round(point.x) : point.x;
            marker.y = snapToPixels ? Math.round(point.y) : point.y;
	    }
	    
	    protected function onMapStartPanning(event:MapEvent):void
	    {
	        starting = new Point(x, y);
	    }
	    
	    protected function onMapPanned(event:MapEvent):void
	    {
	        if (starting) {
	            x = starting.x + event.panDelta.x;
	            y = starting.y + event.panDelta.y;
	        }
	        else {
	            x = event.panDelta.x;
	            y = event.panDelta.y;	            
	        }
	    }
	    
	    protected function onMapStopPanning(event:MapEvent):void
	    {
	    	if (starting) {
		        x = starting.x;
		        y = starting.y;
		    }
		    else {
		    	// make sure we're centered
		    	x = map.getWidth() / 2;
		    	y = map.getHeight() / 2;
		    }
		    /*
		     * HACK: Apparently, in Safari the MouseEvent.MOUSE_UP event doesn't fire at the same
		     * point in the render process that it does in other browsers. What ends up happening
		     * is that when the pan stops and the stage is invalidated, an Event.RENDER isn't
		     * dispatched until the next frame. This results in a single frame of incorrectly placed
		     * markers.
		     *
		     * In order to get around this, we set _dirty to true and call updateClips() directly.
		     * This should mean that updateClips() doesn't get called any more than it should, even
		     * though calling it twice on a single frame shouldn't be much of a problem. --Shawn
		     */ 
		    dirty = true;
	        // updateClips();
	    }
	    
	    protected function onMapResized(event:MapEvent):void
	    {
	        x = event.newSize[0] / 2;
	        y = event.newSize[1] / 2;
	        dirty = true;
	        updateClips(); // force redraw because flash seems stingy about it
	    }
	    
	    protected function onMapStartZooming(event:MapEvent):void
	    {
	        dirty = true;
	    }

	    protected function onMapExtentChanged(event:MapEvent):void
	    {
			dirty = true;
	    }
	    
	    protected function onMapStopZooming(event:MapEvent):void
	    {
	        if (scaleZoom) {
	    	    //trace("scaling zoom back to 1");
	            scaleX = scaleY = 1.0;
	        }
	        dirty = true;
	    }
	    
	    protected function onMapZoomedBy(event:MapEvent):void
	    {
	        if (scaleZoom) {
	        	//trace("scaling zoom");
    	        scaleX = scaleY = Math.pow(2, event.zoomDelta);
	        }
	        else { 
		        dirty = true;
	        }
	    }

		protected function set dirty(d:Boolean):void
		{
			_dirty = d;
			if (d) {
				if (stage) stage.invalidate();
			}
		}
		
		protected function get dirty():Boolean
		{
			return _dirty;
		}
		
	}
	
}