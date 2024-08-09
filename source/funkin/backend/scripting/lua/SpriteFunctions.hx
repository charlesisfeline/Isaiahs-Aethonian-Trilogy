package funkin.backend.scripting.lua;

import funkin.game.PlayState;

class SpriteFunctions {
	
	public static function getSpriteFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		return [
			"createSprite" => function(name:String, ?imagePath:String = null, ?x:Float = 0, ?y:Float = 0)
			{
				if(instance.luaObjects["SPRITE"].exists(name))
					return;
				
				var theSprite:FunkinSprite = new FunkinSprite(x, y);
				if(imagePath != null && imagePath.length > 0)
					theSprite.loadGraphic(Paths.image(imagePath));
				instance.luaObjects["SPRITE"].set(name, theSprite);
			},
			"createText" => function(name:String, text:String = '', ?x:Float = 0, ?y:Float = 0, ?width:Float = 0, ?size:Int = 16, ?camera:String = 'default') {
				if(instance.luaObjects["TEXT"].exists(name))
					return;
				
				var yourText:FunkinText = new FunkinText(x, y, width, text, size);
				yourText.scrollFactor.set();
				yourText.cameras = [LuaTools.getCamera(camera)];
				instance.luaObjects["TEXT"].set(name, yourText);
			},
			"setText" => function(name:String, text:String = '') {
				var yourText:FunkinText = LuaTools.getObject(instance, name);
				if(yourText != null){
					yourText.text = text;
				}
			},
			"addSprite" => function(name:String, ?camera:String = "default") {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);
				/*
				if(PlayState.instance.luaObjects["SPRITE"].exists(name))
					sprite = PlayState.instance.luaObjects["SPRITE"].get(name);
				*/
				if(sprite != null) {
					instance.add(sprite);
					sprite.cameras = [LuaTools.getCamera(camera)];
				}
			},
			"setSpriteCamera" => function(name:String, ?camera:String = 'default') {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);
				/*
				if(PlayState.instance.luaObjects["SPRITE"].exists(name))
					sprite = PlayState.instance.luaObjects["SPRITE"].get(name);
				*/
				if(sprite != null) {
					sprite.cameras = [LuaTools.getCamera(camera)];
				}
			},
			"setSpriteScale" => function(name:String, ?scaleX:Float = 1, ?scaleY:Float = 1) {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);
				/*
				if(PlayState.instance.luaObjects["SPRITE"].exists(name))
					sprite = PlayState.instance.luaObjects["SPRITE"].get(name);
				*/
				if(sprite != null) {
					sprite.scale.set(scaleX, scaleY);
					sprite.updateHitbox();
				}
			},
			"setSpriteSize" => function(name:String, ?width:Int = 0, ?height:Int = 0) {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);
				/*
				if(PlayState.instance.luaObjects["SPRITE"].exists(name))
					sprite = PlayState.instance.luaObjects["SPRITE"].get(name);
				*/
				if(sprite != null) {
					sprite.setGraphicSize(width, height);
					sprite.updateHitbox();
				}
			},
			"setSpriteScroll" => function(name:String, ?scrollX:Int = 0, ?scrollY:Int = 0) {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);

				if(sprite != null) {
					sprite.scrollFactor.set(scrollX, scrollY);
				}
			}
		];
	}
}