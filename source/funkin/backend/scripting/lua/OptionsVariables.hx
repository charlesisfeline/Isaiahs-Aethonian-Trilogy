package funkin.backend.scripting.lua;
#if ENABLE_LUA
import funkin.backend.assets.ModsFolder;
import funkin.options.Options;

final class OptionsVariables {
	public static function getOptionsVariables(?script:Script):Map<String, Dynamic> {
		return [
			// Preferences
			"downScroll" => Options.downscroll,
			"framerate" => Options.framerate,
			"ghostTapping" => Options.ghostTapping,
			"camZoomOnBeat" => Options.camZoomOnBeat,
			"lowMemoryMode" => Options.lowMemoryMode,
			"antialiasing" => Options.antialiasing,
			"gameplayShaders" => Options.gameplayShaders,
			"currentModDirectory" => ModsFolder.currentModFolder,

			"currentSystem" => LuaTools.getCurrentSystem()
		];
	}
}
#end
