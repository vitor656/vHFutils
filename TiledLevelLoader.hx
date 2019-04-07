package vHFutils;

import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;

typedef MapLayer = { 
	layerName : String, 
	isCollidable : Bool, 
	tileSet : FlxTilemapGraphicAsset, 
	autotile : FlxTilemapAutoTiling 
}

typedef EntitiesLayer = { 
	layerName : String, 
	type : Class<FlxSprite> 
}

// This class has to be used for Tiled based levels (.tmx)
class TiledLevelLoader 
{

	public static var currentLevel : String;
	public static var currentLevelPath : String;
	private static var currentTiledMap : TiledMap;
	private static var currentCollidableMap : FlxTilemap;

	private static var tilesLayers : Array<MapLayer> = new Array<MapLayer>();
	private static var entitiesLayers : Array<EntitiesLayer> = new Array<EntitiesLayer>();

	public static function loadLevel(state:FlxState, level:String)
	{
		currentLevel = level;
		currentLevelPath = "assets/data/" + level + ".tmx";

		var tiledMap = new TiledMap(currentLevelPath);

		for(layer in tilesLayers) {
			var layerMap = new FlxTilemap();
			var tiledLayer : TiledTileLayer = cast tiledMap.getLayer(layer.layerName);

			if(tiledLayer != null)
			{
				layerMap.loadMapFromArray(
					tiledLayer.tileArray,
					tiledMap.width,
					tiledMap.height,
					layer.tileSet,
					tiledMap.tileWidth,
					tiledMap.tileHeight,
					layer.autotile
				);

				layerMap.solid = layer.isCollidable;

				if (layer.isCollidable)
				{
					currentCollidableMap = layerMap;
				}
				
				state.add(layerMap);
			} else {
				trace(layer.layerName + " layer not found.");
			}
		}

		FlxG.camera.setScrollBoundsRect(0, 0, tiledMap.fullWidth, tiledMap.fullHeight, true);

		currentTiledMap = tiledMap;
		
		//Spawn all objects
		placeEntities(state, currentTiledMap);
		
	}
	
	public static function placeEntities(state:FlxState, map:TiledMap) : Void
	{
		for(layer in entitiesLayers){
			var arrEntities : Array<TiledObject> = getLevelEntities(map, layer);
			if(arrEntities != null && arrEntities.length > 0){

				for(entity in arrEntities){

					spawnEntity(state, entity, layer.type);

				}

			}
		}

	}

	private static function spawnEntity(state : FlxState, entity : TiledObject, type : Class<FlxSprite>) : Void 
	{
		var spawnPosition : FlxPoint = new FlxPoint(entity.x, entity.y);
		var newEntity = Type.createInstance(type, []);

		newEntity.x = spawnPosition.x;
		newEntity.y = spawnPosition.y;

		state.add(newEntity);

	}
	
	private static function getLevelEntities(map:TiledMap, layer:EntitiesLayer) : Array<TiledObject>
	{
		if (map != null && map.getLayer(layer.layerName) != null){
			var objLayer : TiledObjectLayer = cast map.getLayer(layer.layerName);
			return objLayer.objects;
		} else {
			trace(layer + " layer not found.");
			
			return [];
		}
	}

	public static function registerTilesLayer(layer : MapLayer, position : Int = -1) : Void
	{
		if(position != -1) {
			tilesLayers.insert(position, layer);
		} else {
			tilesLayers.push(layer);
		}
	}

	public static function registerEntitiesLayer(layer : EntitiesLayer, position : Int = -1) : Void
	{
		if(position != -1) {
			entitiesLayers.insert(position, layer);
		} else {
			entitiesLayers.push(layer);
		}
	}
}