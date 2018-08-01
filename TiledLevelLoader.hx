package vHFutils;

import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
import utils.GroupsManager;

// This class has to be used for Tiled based levels (.tmx)
class TiledLevelLoader 
{

	public static var currentLevel : String;
	public static var currentLevelPath : String;
	public static var currentTiledMap : TiledMap;
	public static var currentCollidableMap : FlxTilemap;
	public static var tilesAsset : String = "";

	public inline static var LAYER_MAIN : String = "main";
	public inline static var LAYER_BACKGROUND : String = "background";
	public inline static var LAYER_FOREGROUND : String = "foreground";
	public inline static var LAYER_PLAYER : String = "player";
	public inline static var LAYER_ENEMIES : String = "enemies";
	public inline static var LAYER_COLLECTABLES : String = "collectables";

	public static function loadLevel(state:FlxState, level:String)
	{
		currentLevel = level;
		currentLevelPath = "assets/data/" + level + ".tmx";
		
		if (setupTilesAsset(level)){
			
			var tiledMap = new TiledMap(currentLevelPath);

			var backMap = new FlxTilemap();
			var backgroundLayer : TiledTileLayer = cast tiledMap.getLayer(LAYER_BACKGROUND);
			if(backgroundLayer != null){	
				backMap.loadMapFromArray(
					backgroundLayer.tileArray, 
					tiledMap.width, 
					tiledMap.height, 
					tilesAsset, 
					16, 
					16, 
					1
				);
				backMap.solid = false;

				state.add(backMap);
			}

		
			var mainLayer : TiledTileLayer = cast tiledMap.getLayer(LAYER_MAIN);
			if(mainLayer != null){
				currentCollidableMap = new FlxTilemap();
				currentCollidableMap.loadMapFromArray(
					mainLayer.tileArray, 
					tiledMap.width, 
					tiledMap.height, 
					tilesAsset, 
					16, 
					16, 
					1
				);
				state.add(currentCollidableMap);
			} else {
				trace("Tiled: Main layer not found.");
			}
			
			
			var foreMap = new FlxTilemap();
			var foregroundLayer : TiledTileLayer = cast tiledMap.getLayer(LAYER_FOREGROUND);
			if(foregroundLayer != null){
				foreMap.loadMapFromArray(
					foregroundLayer.tileArray, 
					tiledMap.width, 
					tiledMap.height, 
					tilesAsset, 
					16, 
					16, 
					1
				);
				foreMap.solid = false;

				state.add(foreMap);
			}

			FlxG.camera.setScrollBoundsRect(0, 0, tiledMap.fullWidth, tiledMap.fullHeight, true);

			currentTiledMap = tiledMap;
			
			//Spawn all objects
			spawnObjects(state, currentTiledMap);
		} else {
			trace("Tiles Asset not found");
		}
	}
	
	public static function spawnObjects(state:FlxState, map:TiledMap) : Void
	{
		spawnPlayer(state, map);
		spawnEnemies(state, map);
		spawnCollectables(state, map);
	}

	public static function spawnPlayer(state:FlxState, map:TiledMap) : Void
	{
		var arrPlayer = getLevelObjects(map, LAYER_PLAYER);
		if(arrPlayer != null && arrPlayer.length > 0){
			var playerObject : TiledObject = arrPlayer[0];

			//Choose Player class to instantiate
			//(cast state).player = new Player(playerObject.x, playerObject.y);
			//state.add((cast state).player);
		}
	}

	public static function spawnEnemies(state:FlxState, map:TiledMap) : Void
	{
		var arrEnemies : Array<TiledObject> = getLevelObjects(map, LAYER_ENEMIES);
		if(arrEnemies != null && arrEnemies.length > 0){

			for(enemyObject in arrEnemies){
				switch(enemyObject.type){
					case "type_1":
					break;
					case "type_2":
					break;
				}
			}

		}
	}

	public static function spawnCollectables(state:FlxState, map:TiledMap) : Void
	{
		var arrCollectables : Array<TiledObject> = getLevelObjects(map, LAYER_COLLECTABLES);
		if(arrCollectables != null && arrCollectables.length > 0){

			for(collectableObject in arrCollectables){
				switch(collectableObject.type){
					case "type_1":
					break;
					case "type_2":
					break;
				}
			}

		}
	}
	
	public static function getLevelObjects(map:TiledMap, layer:String) : Array<TiledObject>
	{
		if (map != null && map.getLayer(layer) != null){
			var objLayer : TiledObjectLayer = cast map.getLayer(layer);
			return objLayer.objects;
		} else {
			trace(layer + " layer not found.");
			
			return [];
		}
	}
	
	public static function setupTilesAsset(level : String) : Bool
	{
		switch(level){
			case 'level':
				tilesAsset = AssetPaths.tiles_2__png;
		}
		
		if (tilesAsset != null && tilesAsset != "")
			return true;
		
		return false;
	}
}