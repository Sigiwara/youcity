package com.modestmaps.core 
{

	import com.modestmaps.Map;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.mapproviders.IMapProvider;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class TileGrid extends Sprite
	{
		// we need a reference to our map for createTile() only, 
		// slightly messy but better than a whole TileFactory hierarchy!
		private var map:Map;

        // TILE_WIDTH and TILE_HEIGHT are now provider.tileWidth and provider.tileHeight
        // this was needed for the NASA DailyPlanetProvider which has 512x512px tiles
		// public static const TILE_WIDTH:Number = 256;
		// public static const TILE_HEIGHT:Number = 256;        
        
        public var minZoom:Number;
        public var maxZoom:Number;

		protected var minTx:Number, maxTx:Number, minTy:Number, maxTy:Number;

		// pan and zoom
		protected var _panX:Number;
		protected var _panY:Number;
		protected var _scale:Number;
		
		protected var worldMatrix:Matrix;
		protected var _invertedMatrix:Matrix; // use lazy getter for this
		
		// these also have lazy getters
		protected var _topLeftCoordinate:Coordinate;
		protected var _bottomRightCoordinate:Coordinate;

		// where the tiles live:
		protected var well:Sprite;

		protected var provider:IMapProvider;

		// Tiles we want to load:
		protected var queue:Array = [];
		
		// per-tile, the number of images we're expecting to load
		// TODO: document this in IMapProvider, so that provider implementers know
		// they are free to check the bounds of their overlays and don't have to serve
		// millions of 404s
		protected var layersNeeded:Dictionary = new Dictionary(true);

		// Tiles we've already seen and fully loaded, by key (.name)
		protected var alreadySeen:Dictionary = new Dictionary();
		
		// keys we've recently seen
		protected var recentlySeen:Array = [];
		
		// open requests
		protected var openRequests:Array = [];

		// keeping track for dispatching MapEvent.ALL_TILES_LOADED and MapEvent.BEGIN_TILE_LOADING
		protected var previousOpenRequests:int = 0;
		
		// currently visible tiles
		protected var visibleTiles:Array = [];
		
		// TODO: move to MapConfig
		public static var MAX_OPEN_REQUESTS:int = 4;
		
		// number of tiles we're failing to show
		protected var blankCount:int = 0;

		// a textfield with lots of stats
		public var debugField:TextField;
		
		// for stats:
		protected var lastFrameTime:Number;
		protected var fps:Number = 30;

		// what zoom level of tiles is 'correct'?
		protected var currentZoom:int; 
		// so we know if we're going in or out
		protected var previousZoom:int;		
		
		// for sorting the queue:
		protected var centerRow:Number;
		protected var centerColumn:Number;

		// for pan events
		protected var startPan:Point;
		public var panning:Boolean;
		
		// for zoom events
		protected var startZoom:Number = -1;
		public var zooming:Boolean;

		protected static const DEFAULT_MAX_PARENT_SEARCH:int = 5;
		protected static const DEFAULT_MAX_CHILD_SEARCH:int = 1;
		protected static const DEFAULT_MAX_TILES_TO_KEEP:int = 256;
		protected static const DEFAULT_TILE_BUFFER:int = 0;
		protected static const DEFAULT_ENFORCE_BOUNDS:Boolean = false;

		/** if we don't have a tile at currentZoom, onRender will look for tiles up to 5 levels out.
		 *  set this to 0 if you only want the current zoom level's tiles
		 *  WARNING: tiles will get scaled up A LOT for this, but maybe it beats blank tiles? */ 
		public var maxParentSearch:int = DEFAULT_MAX_PARENT_SEARCH;
		/** if we don't have a tile at currentZoom, onRender will look for tiles up to one levels further in.
		 *  set this to 0 if you only want the current zoom level's tiles
 		 *  WARNING: bad, bad nasty recursion possibilities really soon if you go much above 1
		 *  - it works, but you probably don't want to change this number :) */
		public var maxChildSearch:int = DEFAULT_MAX_CHILD_SEARCH;
		
		// TODO: move to MapConfig
		public var maxTilesToKeep:int = DEFAULT_MAX_TILES_TO_KEEP; // 256*256*4bytes = 0.25MB ... so 256 tiles is 64MB of memory, minimum!
		
		// 0 or 1, really: 2 will load *lots* of extra tiles
		public var tileBuffer:int = DEFAULT_TILE_BUFFER;

		// set this to true to enable enforcing of map bounds from the map provider's limits
		public var enforceBoundsEnabled:Boolean = DEFAULT_ENFORCE_BOUNDS;
		
		public var mapWidth:Number;
		public var mapHeight:Number;
		
		// TODO: markers
		// TODO: scroll and zoom limits
		
		protected var draggable:Boolean;

		// setting this.dirty = true will request an Event.RENDER
		protected var _dirty:Boolean;

		// previous mouse position when dragging 
		protected var pmouse:Point;
		
		public function TileGrid(map:Map, w:Number, h:Number, draggable:Boolean, provider:IMapProvider)
		{
			this.map = map;
			this.draggable = draggable;
			this.provider = provider;

			_panX = -provider.tileWidth/2;
			_panY = -provider.tileHeight/2;
			_scale = 1;

			// from provider:
			calculateBounds();
			
			debugField = new TextField();
			debugField.defaultTextFormat = new TextFormat(null, 12, 0x000000, false);
			debugField.backgroundColor = 0xffffff;
			debugField.background = true;
			debugField.text = "messages";
			debugField.x = debugField.y = 5;
 			debugField.name = 'text';
 			debugField.mouseEnabled = false;
 			debugField.selectable = false;
 			debugField.multiline = true;
 			debugField.wordWrap = false;
			
			lastFrameTime = getTimer();
			
			this.mapWidth = w;
			this.mapHeight = h;

			well = new Sprite();
			addChild(well);

			worldMatrix = new Matrix();
			worldMatrix.translate(_panX,_panX);
			worldMatrix.scale(_scale,_scale);
			worldMatrix.translate(mapWidth/2, mapHeight/2);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			
		}
		
		private function onAddedToStage(event:Event):void
		{
			if (draggable) {
				addEventListener(MouseEvent.MOUSE_DOWN, mousePressed, true);
			}
			addEventListener(Event.RENDER, onRender);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.invalidate(); // call onRender
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			if (hasEventListener(MouseEvent.MOUSE_DOWN)) {
				removeEventListener(MouseEvent.MOUSE_DOWN, mousePressed, true);
			}
			removeEventListener(Event.RENDER, onRender);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function onEnterFrame(event:Event=null):void
		{
			// for stats...
			var frameDuration:Number = getTimer() - lastFrameTime;
			lastFrameTime = getTimer();
			
			fps = (0.9 * fps) + (0.1 * (1000.0/frameDuration));

			// report stats:
			
			if (debugField.parent) {
				var alreadySeenCount:int = 0;
				for (var key:* in alreadySeen) {
					alreadySeenCount++;
				}
				
				debugField.text = "tx: " + _panX.toFixed(3) + " ty: " + _panY.toFixed(3) + " sc: " + _scale.toFixed(4)
						+ "\nfps: " + fps.toFixed(0)
						+ "\ncurrent child count: " + well.numChildren
						+ "\nvisible tile count: " + visibleTiles.length
						+ "\nqueue length: " + queue.length
						+ "\nblank count: " + blankCount
						+ "\nrequests: " + openRequests.length
						+ "\nfinished tiles: " + alreadySeenCount
						+ "\nrecently used tiles: " + recentlySeen.length
						+ "\nmemory: " + (System.totalMemory/1048576).toFixed(1) + "MB";
				debugField.width = debugField.textWidth+8;
				debugField.height = debugField.textHeight+4;
			}
			
//			if (!panning && !zooming) {
				processQueue();
//			}				
			
		}
		
		protected function onRender(event:Event=null):void
		{
			if (!dirty || !stage) {
				return;
			}
			
			//var startTime:Number = getTimer();
			
			// TODO:
			// wrap tx/ty to -256:0 ?
			// or would that break tweening? 

			// find the extents of the ur-tile:
			// (where would the top left and bottom right corners of the 
			//  world be now if we only had one tile at zoom level 0?)
			// TODO deal with what happens with non-square projections!
			var worldMin:Point = worldMatrix.transformPoint(new Point(0,0));
			var worldMax:Point = worldMatrix.transformPoint(new Point(provider.tileWidth, provider.tileHeight));

			// what zoom level of tiles should we be loading, taking into account min/max zoom?
			// (0 when scale == 1, 1 when scale == 2, 2 when scale == 4, etc.)
			var newZoom:int = Math.min(maxZoom, Math.max(minZoom, Math.round(zoomLevel)));
			
			// see if the newZoom is different to currentZoom
			// so we know which way we're zooming, if any:
			if (currentZoom != newZoom) {
				previousZoom = currentZoom;
			}
			
			// this is the level of tiles we'll be loading:
			currentZoom = newZoom;
		
			// this is how big the world is, in tiles:
			// (same as rounding scale to the nearest power of 2)
			var numCols:int = Math.pow(2, currentZoom);
			var numRows:int = numCols; // TODO deal with what happens with non-square projections!
					
			// find start and end columns for the visible tiles:
			var realMinCol:Number = numCols * (-worldMin.x) / (worldMax.x-worldMin.x);
			var realMaxCol:Number = numCols * (mapWidth-worldMin.x) / (worldMax.x-worldMin.x);
			var realMinRow:Number = numRows * (-worldMin.y) / (worldMax.y-worldMin.y);
			var realMaxRow:Number = numRows * (mapHeight-worldMin.y) / (worldMax.y-worldMin.y);
			
			// round these up or down to pad things out a bit
			var minCol:int = Math.floor(realMinCol);
			var maxCol:int = Math.ceil(realMaxCol);
			var minRow:int = Math.floor(realMinRow);
			var maxRow:int = Math.ceil(realMaxRow);
					
			// optionally pad it out a little bit more
			// TODO: investigate giving a directional bias to TILE_BUFFER when panning quickly
 			minCol -= tileBuffer;
			maxCol += tileBuffer;
			minRow -= tileBuffer;
			maxRow += tileBuffer; 
			
			visibleTiles = [];
			blankCount = 0; // keep count of how many tiles we missed?
		
			// for use in loops etc.
			var tile:Tile;
			var key:String;
			var coord:Coordinate = new Coordinate(0,0,0);

			// loop over currently visible tiles
			for (var col:int = minCol; col <= maxCol; col++) {
				for (var row:int = minRow; row <= maxRow; row++) {
					
					// create a string key for this tile
					key = tileKey(col, row, currentZoom);
					
					// see if we already have this tile
					tile = well.getChildByName(key) as Tile;
										
					// create it if not, and add it to the load queue
					if (!tile) {
						tile = alreadySeen[key] as Tile;
						if (!tile) {
							tile = map.createTile(col, row, currentZoom);
							tile.name = key;
							coord.row = tile.row;
							coord.column = tile.column;
							coord.zoom = tile.zoom;
							// keep a local copy of the URLs so we don't have to call this twice: 
							layersNeeded[tile] = provider.getTileUrls(coord);
							queue.push(tile);
						}
						else {
							tile.show();
						}
						well.addChild(tile);
					}
					
 					visibleTiles.push(tile);

					var tileReady:Boolean = tile.isShowing() && (layersNeeded[tile] == null);
					
					//
					// if the tile isn't ready yet, we're going to reuse a parent tile
					// if there isn't a parent tile, and we're zooming out, we'll reuse child tiles
					// if we don't get all 4 child tiles, we'll look at more parent levels
					//
					// yes, this is quite involved, but it should be fast enough because most of the loops
					// don't get hit most of the time
					//
					
					if (!tileReady) {
					
						var foundParent:Boolean = false;
						var foundChildren:int = 0;
	
						// for searching parents, reused further down too
	 					var pzoom:int;
						var pkey:String;
						var ptile:Tile;
						
						// for fixing row/cols so they're positioned at currentZoom
						var scaleFactor:Number;
						
						if (currentZoom > previousZoom) {
							
							// if it still doesn't have enough images yet, or it's fading in, try a double size parent instead
		 					if (maxParentSearch > 0 && currentZoom > minZoom) {
								pkey = parentKey(col, row, currentZoom, currentZoom-1);
								if (alreadySeen[pkey] is Tile) {
									ptile = ensureVisible(pkey);
									foundParent = true;
								}
							}
							
						}
						else {
							 
							// currentZoom <= previousZoom, so we're zooming out
							// and therefore we might want to reuse 'smaller' tiles
							
							// if it doesn't have an image yet, see if we can make it from smaller images
		  					if (!foundParent && maxChildSearch > 0 && currentZoom < maxZoom) {
	 	  						for (var czoom:int = currentZoom+1; czoom <= Math.min(maxZoom, currentZoom+maxChildSearch); czoom++) {
			  						var ckeys:Array = childKeys(col, row, currentZoom, czoom);
									for each (var ckey:String in ckeys) {
										if (alreadySeen[ckey] is Tile) {
											var ctile:Tile = ensureVisible(ckey);
											foundChildren++;
										}
									} // ckeys
									if (foundChildren == ckeys.length) {
										break;
									} 
		  						} // czoom
		 					}
		 				}
	
		 				var startZoomSearch:int = currentZoom - 1;
		 				
		 				if (currentZoom > previousZoom) {
		 					// we already looked for parent level 1, and didn't find it, so:
		 					startZoomSearch -= 1;
		 				}
		 				
		 				var endZoomSearch:int = Math.max(minZoom, currentZoom-maxParentSearch);
	
						var stillNeedsAnImage:Boolean = !foundParent && foundChildren < 4; 					
						// if it still doesn't have an image yet, try more parent zooms
	 					if (stillNeedsAnImage && maxParentSearch > 1 && currentZoom > minZoom) {
	 						for (pzoom = startZoomSearch; pzoom >= endZoomSearch; pzoom--) {
	 							pkey = parentKey(col, row, currentZoom, pzoom);
								if (alreadySeen[pkey] is Tile) {
									ptile = ensureVisible(pkey);								
									stillNeedsAnImage = false;
									break;
								}
	 						}
						}
											
						if (stillNeedsAnImage) {
							blankCount++;
							//trace("sorry, no parent known for", key);
						}

					} // if !tileReady
					
				}
			}

			// make absolutlely sure all our newly visible tiles are cached if they're done loading
			// TODO: this should probably happen onLoadEnd when there are no URLs left? 
			for each (tile in visibleTiles) {
				// if we're done loading this one, add/move it to the end of recently seen:
				if (!layersNeeded[tile]) {
					var ri:int = recentlySeen.indexOf(tile.name); 
					if (ri >= 0) {
						recentlySeen.splice(ri, 1);
					}
					recentlySeen.push(tile.name);
				}				
			}

			// prune tiles from the well if they shouldn't be there (not currently in visibleTiles)
			// (loop backwards so removal doesn't change i)
			for (var i:int = well.numChildren-1; i >= 0; i--) {
				tile = well.getChildAt(i) as Tile;
				if (visibleTiles.indexOf(tile) < 0) {
					well.removeChild(tile);
					tile.hide();
				}
			}
						
 			// sort children by difference from current zoom level
 			// this means current is on top, +1 and -1 are next, then +2 and -2, etc.
			visibleTiles.sort(distanceFromCurrentZoomCompare, Array.DESCENDING);

			// for fixing positions when we're between zoom levels:
 			var positionScaleCompensation:Number = Math.pow(2, zoomLevel-currentZoom);
			
 			// apply the sorted depths, position all the tiles and also keep recentlySeen updated:
			for each (tile in visibleTiles) {
			
				// if we set them all to numChildren-1, descending, they should end up correctly sorted
				well.setChildIndex(tile, well.numChildren-1);

 				// position tile according to current transform
 				scaleFactor = Math.pow(2.0, currentZoom-tile.zoom);
 				var positionCol:Number = (scaleFactor*tile.column) - realMinCol;
 				var positionRow:Number = (scaleFactor*tile.row) - realMinRow;
				tile.x = positionCol*provider.tileWidth*positionScaleCompensation;
				tile.y = positionRow*provider.tileHeight*positionScaleCompensation;
				tile.scaleX = tile.scaleY = Math.pow(2, zoomLevel-tile.zoom);				
			}
			
			// all the visible tiles will be at the end of recentlySeen
			// let's make sure we keep them around:
			var maxRecentlySeen:int = Math.max(visibleTiles.length,maxTilesToKeep);
/* 			trace();
			trace('visibleTiles', visibleTiles.length);
			trace('maxRecentlySeen', maxRecentlySeen);
			trace('recentlySeen', recentlySeen.length); */
			
			// prune cache of already seen tiles if it's getting too big:
 			if (recentlySeen.length > maxRecentlySeen) {
 				// throw away keys at the beginning of recentlySeen
				recentlySeen = recentlySeen.slice(recentlySeen.length - maxTilesToKeep, recentlySeen.length);
				// loop over our internal tile cache 
				// and throw out tiles not in recentlySeen 
				for (key in alreadySeen) {
					if (recentlySeen.indexOf(key) < 0) {
						delete alreadySeen[key];
					}
				}
			}
			
			// update center position:			
			centerRow = (realMaxRow+realMinRow)/2;
			centerColumn = (realMaxCol+realMinCol)/2.0;

			dirty = false;
			
			//trace((getTimer() - startTime)/1000.0, "seconds in TileGrid.onRender");

		}
		
		private function processQueue():void
		{
			// prepare the queue
			if (openRequests.length < MAX_OPEN_REQUESTS && queue.length > 0) {

				// prune queue for tiles that aren't visible
				queue = queue.filter(function(tile:Tile, i:int, a:Array):Boolean {
					return visibleTiles.indexOf(tile) >= 0;
				});
				
				// note that queue is not the same as visible tiles, because things 
				// that have already been loaded are also in visible tiles. if we
				// reuse visible tiles for the queue we'll be loading the same things over and over
	
				// sort queue by distance from 'center'
				queue = queue.sort(centerDistanceCompare);				
			}
			
			// process the queue
			while (openRequests.length < MAX_OPEN_REQUESTS && queue.length > 0) {
				var tile:Tile = queue.shift() as Tile;
				// if it's still on the stage:
				if (tile.parent) {
					loadNextURLForTile(tile);
				}
			}
			
			// you might want to wait for tiles to load before displaying other data, interface elements, etc.
			// these events take care of that for you...
			if (previousOpenRequests == 0 && openRequests.length > 0) {
				dispatchEvent(new MapEvent(MapEvent.BEGIN_TILE_LOADING));
			}
			else if (previousOpenRequests > 0 && openRequests.length == 0) {
				dispatchEvent(new MapEvent(MapEvent.ALL_TILES_LOADED));
			}
			previousOpenRequests = openRequests.length;
			
		}

		private function loadNextURLForTile(tile:Tile):void
		{
			// TODO: add urls to Tile?
			var urls:Array = layersNeeded[tile] as Array;
			if (urls && urls.length > 0) {
				var url:* = urls.shift();
				var tileLoader:Loader = new Loader(); 
				tileLoader.name = tile.name;
				try {
					tileLoader.load((url is URLRequest) ? url : new URLRequest(url));
					tileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadEnd, false, 0, true);
					tileLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false, 0, true);
					openRequests.push(tileLoader);
				}
				catch(error:Error) {
					tile.paintError();
				}
			}
			else if (urls && urls.length == 0) {
				if (tile.zoom == currentZoom) {
					tile.show();
				}
				else {
					tile.showNow();
				}					
				alreadySeen[tile.name] = tile;
				
				delete layersNeeded[tile];
			}			
		}

		// for sorting arrays of tiles by distance from center Coordinate		
		private function centerDistanceCompare(t1:Tile, t2:Tile):int
		{
			if (t1.zoom == t2.zoom && t1.zoom == currentZoom && t2.zoom == currentZoom) {
				var d1:int = Math.pow(t1.row-centerRow,2) + Math.pow(t1.column-centerColumn,2); 
				var d2:int = Math.pow(t2.row-centerRow,2) + Math.pow(t2.column-centerColumn,2); 
				return d1 < d2 ? -1 : d1 > d2 ? 1 : 0; 
			}
			return Math.abs(t1.zoom-currentZoom) < Math.abs(t2.zoom-currentZoom) ? -1 : 1;
		}
		
		// for sorting arrays of tiles by distance from currentZoom		
		private function distanceFromCurrentZoomCompare(t1:Tile, t2:Tile):int
		{
			var d1:int = Math.abs(t1.zoom-currentZoom);
			var d2:int = Math.abs(t2.zoom-currentZoom);
			return d1 < d2 ? -1 : d1 > d2 ? 1 : 0; 
		}

		// make sure the tile with the given key is in the well and added to visibleTiles
		// you should check alreadySeen[key] exists before calling this function 
		private function ensureVisible(key:String):Tile
		{
			var tile:Tile = well.getChildByName(key) as Tile;
			if (!tile) {
				tile = alreadySeen[key] as Tile;
				well.addChildAt(tile,0);
			}
			if (visibleTiles.indexOf(tile) < 0) {
				visibleTiles.push(tile); // don't get rid of it yet!
			}
			tile.showNow();
			return tile;
		}

		private function tileKey(col:int, row:int, zoom:int):String
		{ 
			return col+":"+row+":"+zoom;
		}
		
		// TODO: check that this does the right thing with negative row/col?
		private function parentKey(col:int, row:int, zoom:int, parentZoom:int):String
		{
			var scaleFactor:Number = Math.pow(2.0, zoom-parentZoom);
			var pcol:int = Math.floor(Number(col) / scaleFactor); 
			var prow:int = Math.floor(Number(row) / scaleFactor);
			return tileKey(pcol,prow,parentZoom);			
		}
		
		// TODO: check that this does the right thing with negative row/col?
		private function childKeys(col:int, row:int, zoom:int, childZoom:int):Array
		{
 			var scaleFactor:Number = Math.pow(2, zoom-childZoom); // one zoom in = 0.5
 			var rowColSpan:int = Math.pow(2, childZoom-zoom); // one zoom in = 2, two = 4
 			var keys:Array = [];
 			for (var ccol:int = col/scaleFactor; ccol < (col/scaleFactor)+rowColSpan; ccol++) {
 				for (var crow:int = row/scaleFactor; crow < (row/scaleFactor)+rowColSpan; crow++) {
 					keys.push(tileKey(ccol, crow, childZoom));
 				}
 			}
 			return keys;
		}
						
		private function onLoadEnd(event:Event):void
		{
			var loader:Loader = (event.target as LoaderInfo).loader;

			var tile:Tile = well.getChildByName(loader.name) as Tile;
			if (tile) { 
				tile.addChild(loader);
				loadNextURLForTile(tile);
			}
			else {
				// TODO: keep it around since we did the work
				// only if it didn't have more overlays to come				
//				trace("\t \t !!! parent already removed:", loader.name);
//				trace("\t \t !!! tl/br:", topLeftCoordinate, bottomRightCoordinate);
			}
			var index:int = openRequests.indexOf(loader);
			if (index >= 0) {
				openRequests.splice(index,1);
			}
		}

		private function onLoadError(event:IOErrorEvent):void
		{
			//trace("\t \t !!! load error: ", event.text);
			var foundLoader:Boolean = false;
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			for (var i:int = openRequests.length-1; i >= 0; i--) {
				var loader:Loader = openRequests[i] as Loader;
				if (loader.contentLoaderInfo == loaderInfo) {
					openRequests.splice(i,1);
					var tile:Tile = well.getChildByName(loader.name) as Tile;
					if (tile) {
						delete layersNeeded[tile];
						//trace("painting error");
						tile.paintError(provider.tileWidth, provider.tileHeight);
						if (tile.zoom == currentZoom) {
							tile.show();
						}
						else {
							tile.showNow();
						}
					}
					foundLoader = true;
					break;
				}
			}
		}	
		
		public function mousePressed(event:MouseEvent=null):void
		{
			prepareForPanning(true);
			pmouse = globalToLocal(new Point(event.stageX, event.stageY));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseDragged);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseReleased);
		}

		public function mouseReleased(event:Event=null):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseDragged);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			stage.removeEventListener(Event.MOUSE_LEAVE, mouseReleased);
			donePanning();
			if (event is MouseEvent) {
				MouseEvent(event).updateAfterEvent();
			}
		}

		public function mouseDragged(event:MouseEvent):void
		{
			var mousePoint:Point = globalToLocal(new Point(event.stageX, event.stageY));
			_panX += (mousePoint.x - pmouse.x) / _scale;
			_panY += (mousePoint.y - pmouse.y) / _scale;
			pmouse = mousePoint;
			calculateMatrix();
			var origin:Point = startPan || new Point(_panX,_panY);
			dispatchEvent(new MapEvent(MapEvent.PANNED, new Point(-(origin.x-_panX)*_scale, -(origin.y-_panY)*_scale)));
			event.updateAfterEvent();
		}	

		private function calculateMatrix():void
		{
			// first, simply do what was asked:
			worldMatrix.identity();
			worldMatrix.translate(_panX,_panY);
			worldMatrix.scale(_scale,_scale);
			worldMatrix.translate(mapWidth/2, mapHeight/2);
			
			// nullify things that will be recalculated as needed
			_invertedMatrix = null;
			_topLeftCoordinate = null;
			_bottomRightCoordinate = null;

			// enforce map bounds?
			if (enforceBounds()) {
				// try again!
				worldMatrix.identity();
				worldMatrix.translate(_panX,_panY);
				worldMatrix.scale(_scale,_scale);
				worldMatrix.translate(mapWidth/2, mapHeight/2);				

				// nullify things that will be recalculated as needed
				_invertedMatrix = null;
				_topLeftCoordinate = null;
				_bottomRightCoordinate = null;
			}
			
			// and request a redraw:
			dirty = true;
		}
						
		// today is all about lazy evaluation
		// this gets set to null by calculateMatrix
		// and only calculated again if you need it
		protected function get invertedMatrix():Matrix
		{
			if (!_invertedMatrix) {
				_invertedMatrix = worldMatrix.clone();
				_invertedMatrix.invert();
			}
			return _invertedMatrix;
		}
		protected function set invertedMatrix(m:Matrix):void
		{
			throw new Error("invertedMatrix is read only");
		}

		public function get topLeftCoordinate():Coordinate
		{
			if (!_topLeftCoordinate) {
				var tl:Point = invertedMatrix.transformPoint(new Point());
				tl.x *= _scale/provider.tileWidth;
				tl.y *= _scale/provider.tileHeight;
				_topLeftCoordinate = new Coordinate(tl.y, tl.x, zoomLevel);			
			}
			return _topLeftCoordinate;
		}
		public function set topLeftCoordinate(c:Coordinate):void
		{
			throw new Error("topLeftCoordinate is read only");
		}

		public function get bottomRightCoordinate():Coordinate
		{
			if (!_bottomRightCoordinate) {
				var br:Point = invertedMatrix.transformPoint(new Point(mapWidth, mapHeight));
				br.x *= _scale/provider.tileWidth;
				br.y *= _scale/provider.tileHeight;
				_bottomRightCoordinate = new Coordinate(br.y, br.x, zoomLevel);			
			}
			return _bottomRightCoordinate;
		}
		public function set bottomRightCoordinate(c:Coordinate):void
		{
			throw new Error("bottomRightCoordinate is read only");
		}
						
		// for backward compatibility:
		
		public function centerCoordinate():Coordinate
		{
			var c:Point = invertedMatrix.transformPoint(new Point(mapWidth/2, mapHeight/2));
			c.x *= _scale/provider.tileWidth;
			c.y *= _scale/provider.tileHeight;
			return new Coordinate(c.y, c.x, zoomLevel);			
		}
		
		public function coordinatePoint(coord:Coordinate, context:DisplayObject=null):Point
		{
			// this is the same as coord.zoomTo, but doesn't make a new Coordinate:
			var zoomFactor:Number = Math.pow(2, zoomLevel - coord.zoom)
			var zoomedColumn:Number = coord.column * zoomFactor;
			var zoomedRow:Number = coord.row * zoomFactor;
			
			var tl:Coordinate = topLeftCoordinate;
			var br:Coordinate = bottomRightCoordinate;
			
			var cols:Number = br.column - tl.column;
			var rows:Number = br.row - tl.row;
			
			var screenPoint:Point = new Point(mapWidth * (zoomedColumn-tl.column) / cols, mapHeight * (zoomedRow-tl.row) / rows);

			if (context && context != this)
            {
    			screenPoint = this.parent.localToGlobal(screenPoint);
    			screenPoint = context.globalToLocal(screenPoint);
            }

			return screenPoint; 
		}
		public function pointCoordinate(point:Point, context:DisplayObject=null):Coordinate
		{			
			if (context && context != this)
            {
    			point = context.localToGlobal(point);
    			point = this.globalToLocal(point);
            }
			
			var p:Point = invertedMatrix.transformPoint(point);
			return new Coordinate(_scale*p.y/provider.tileHeight, _scale*p.x/provider.tileWidth, zoomLevel);
		}
		
		public function prepareForPanning(dragging:Boolean=false):void
		{
			if (startPan != null) {
				donePanning();
			}
			if (!dragging && draggable) {
				if (hasEventListener(MouseEvent.MOUSE_DOWN)) {
					removeEventListener(MouseEvent.MOUSE_DOWN, mousePressed, true);
				}
			}
			startPan = new Point(_panX,_panY);
			panning = true;
			dispatchEvent(new MapEvent(MapEvent.START_PANNING));
		}
		
		public function donePanning():void
		{
			if (draggable) {
				if (!hasEventListener(MouseEvent.MOUSE_DOWN)) {
					addEventListener(MouseEvent.MOUSE_DOWN, mousePressed, true);
				}
			}
			startPan = null;
			panning = false;
			dispatchEvent(new MapEvent(MapEvent.STOP_PANNING));
		}
		
		public function prepareForZooming():void
		{
			if (startZoom >= 0) {
				doneZooming();
			}
			startZoom = zoomLevel;
			zooming = true;
			var event:MapEvent = new MapEvent(MapEvent.START_ZOOMING);
			event.zoomLevel = startZoom; 
			dispatchEvent(event);
		}
			    		
		public function doneZooming():void
		{
			startZoom = -1;
			zooming = false;
			var event:MapEvent = new MapEvent(MapEvent.STOP_ZOOMING);
			event.zoomLevel = zoomLevel; 
			dispatchEvent(event);
		}

		public function resetTiles(coord:Coordinate, point:Point):void
		{
			// set new scale according to zoom
			_scale = Math.pow(2, coord.zoom);

			// figure out where in the world we are			
			_panX = -provider.tileWidth*coord.column/_scale;
			_panY = -provider.tileHeight*coord.row/_scale;

			// plus the offset			
			_panX += point.x/_scale;
			_panY += point.y/_scale;

			// reset the worldMatrix
			calculateMatrix();
		}
		
		public function get panX():Number
		{
			return _panX;
		}

		public function set panX(n:Number):void
		{
		    if (n != panX)
		    {
    			var origin:Point = startPan || new Point(_panX, _panY);
    			_panX = n;
    			calculateMatrix();
    			dispatchEvent(new MapEvent(MapEvent.PANNED, new Point(-(origin.x - _panX) * _scale, -(origin.y - _panY) * _scale)));
    		}
		}

		public function get panY():Number
		{
			return _panY;
		}
		public function set panY(n:Number):void
		{
		    if (n != panY)
		    {
    			var origin:Point = startPan || new Point(_panX, _panY);
    			_panY = n;
    			calculateMatrix();
    			dispatchEvent(new MapEvent(MapEvent.PANNED, new Point(-(origin.x - _panX) * _scale, -(origin.y - _panY) * _scale)));
		    }
		}

		public function get zoomLevel():Number
		{
			return Math.log(_scale) / Math.log(2);
		}

		public function set zoomLevel(n:Number):void
		{
		    if (zoomLevel != n)
		    {
    			_scale = Math.pow(2, n);						
    			calculateMatrix();
    			var zoomEvent:MapEvent = new MapEvent(MapEvent.ZOOMED_BY);
    	        zoomEvent.zoomDelta = zoomLevel-startZoom;
    	        zoomEvent.zoomLevel = zoomLevel;
    	        dispatchEvent(zoomEvent);
            }
		}

		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(n:Number):void
		{
		    if (scale != n)
		    {
    			var old:Number = zoomLevel;
    			_scale = n;
    			calculateMatrix();	
    			prepareForZooming();
    			var zoomEvent:MapEvent = new MapEvent(MapEvent.ZOOMED_BY);
    	        zoomEvent.zoomDelta = zoomLevel-old;
    	        zoomEvent.zoomLevel = zoomLevel;
    	        dispatchEvent(zoomEvent);
    			doneZooming();
		    }
		}
				
		public function resizeTo(p:Point):void
		{
		    if (mapWidth != p.x || mapHeight != p.y)
		    {
    			mapWidth = p.x;
    			mapHeight = p.y;
    	        scrollRect = new Rectangle(0, 0, mapWidth, mapHeight);
    			calculateMatrix();
    			// force this but only for onResize
    			onRender();
		    }
			
			// this makes sure the well is clickable even without tiles
			well.graphics.beginFill(0x000000, 0);
			well.graphics.drawRect(0, 0, mapWidth, mapHeight);
		}
		
		public function setMapProvider(provider:IMapProvider):void
		{
			this.provider = provider;
			
			calculateBounds();
			
			// TODO: enforce bounds here?

			while (well.numChildren > 0) {			
				well.removeChildAt(0);
			}
			
			for each (var loader:Loader in openRequests) {
				try {
					// la la I can't hear you
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadEnd);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
					loader.close();
				}
				catch (error:Error) {
					// close often doesn't work, no biggie
				}
			}
			
			var key:*;
			for (key in alreadySeen) {
				delete alreadySeen[key];
			}

			for (key in layersNeeded) {
				delete layersNeeded[key];
			}
			
			alreadySeen = new Dictionary();
			layersNeeded = new Dictionary(true); 

			openRequests = [];
			recentlySeen = [];
			queue = [];			
			
			dirty = true;
		}

		protected function calculateBounds():void
		{
			var limits:Array = provider.outerLimits();			
			var tl:Coordinate = limits[0] as Coordinate;
			var br:Coordinate = limits[1] as Coordinate;

			maxZoom = Math.max(tl.zoom, br.zoom);  
			minZoom = Math.min(tl.zoom, br.zoom);
			
			tl = tl.zoomTo(0);
			br = br.zoomTo(0);

			minTx = tl.column * provider.tileWidth;
			maxTx = br.column * provider.tileWidth;
			minTy = tl.row * provider.tileHeight;
			maxTy = br.row * provider.tileHeight;

			//trace("bounds of useful map area: ", minTx, maxTx, minTy, maxTy);			
		}
		
		/** called inside of calculateMatrix before events are fired
		 *  don't use setters inside of here to correct values otherwise we'll get stuck in a loop! */
		protected function enforceBounds():Boolean
		{
			if (!enforceBoundsEnabled) {
				return false;
			}
			
/* 			if (zoomLevel < minZoom) {
				_scale = Math.pow(2, minZoom);
				return true;
			}

			if (zoomLevel > maxZoom) {
				_scale = Math.pow(2, maxZoom);
				return true;
			} */
			
			var touched:Boolean = false;
			
			var tl:Coordinate = topLeftCoordinate.zoomTo(0);
			var br:Coordinate = bottomRightCoordinate.zoomTo(0);
			
			var leftX:Number = tl.column * provider.tileWidth;
			var rightX:Number = br.column * provider.tileHeight;
			
   			if (rightX-leftX > maxTx-minTx) {
 				//trace("CENTERING X");
 				_panX = -(minTx+maxTx)/2;
				touched = true;
 			}
 			else if (leftX < minTx) {
				//trace("TOO LEFT");
				_panX += leftX-minTx;
				touched = true;
			}
 			else if (rightX > maxTx) {
				//trace("TOO RIGHT");
				_panX += rightX-maxTx;
				touched = true;
			}  

 			var upY:Number = tl.row * provider.tileHeight;
			var downY:Number = br.row * provider.tileWidth;

   			if (downY-upY > maxTy-minTy) {
 				//trace("CENTERING Y");
 				_panY = -(minTy+maxTy)/2;
				touched = true;
 			}
			else if (upY < minTy) {
				//trace("TOO HIGH");
				_panY += upY-minTy;
				touched = true;
			}
			else if (downY > maxTy) {
				//trace("TOO LOW");
				_panY += downY-maxTy;
				touched = true;
			} 

			//trace("bounds of visible map area: ", leftX, rightX, upY, downY);

			return touched;			
		}

 		override public function set doubleClickEnabled(enabled:Boolean):void
		{
			if (enabled) {
				well.doubleClickEnabled = true;
				well.mouseEnabled = true;
				well.mouseChildren = false;
   			}
   			else {
   				well.doubleClickEnabled = false;
   			}
			super.doubleClickEnabled = false;
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


