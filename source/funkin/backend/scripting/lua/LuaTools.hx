package funkin.backend.scripting.lua;
#if ENABLE_LUA
class LuaTools {
	public static function getCurrentSystem():String {
		return lime.system.System.platformName;
	}

	public static function getCamera(camera:String):FlxCamera {
		return switch(camera) {
			case "camgame" | "game": PlayState.instance.camGame;
			case "camhud" | "hud": PlayState.instance.camHUD;
			default: FlxG.cameras.list[FlxG.cameras.list.length - 1];
		}
	}
}
#end
