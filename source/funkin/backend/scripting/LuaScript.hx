package funkin.backend.scripting;
#if ENABLE_LUA
import funkin.backend.chart.ChartData.ChartEvent;
import funkin.backend.scripting.lua.LuaTools;
import flixel.util.typeLimit.OneOfThree;
import lime.system.System;
import haxe.io.Path;
import funkin.menus.StoryMenuState.WeekData;
import funkin.backend.system.Conductor;
import funkin.backend.assets.ModsFolder;
import flixel.FlxState;

import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import llua.Macro.*;
import haxe.DynamicAccess;

import openfl.utils.Assets;

using llua.Lua;
using llua.LuaL;
using llua.Convert;

class LuaScript extends FlxBasic implements IFlxDestroyable{

	public static function getPlayStateVariables():Map<String, Dynamic> {
		return [
			// PlayState property things 
			"curBpm" 			=> Conductor.bpm,
			"songBpm" 			=> PlayState.SONG.meta.bpm,
			"scrollSpeed" 		=> PlayState.SONG.scrollSpeed,
			"crochet" 			=> Conductor.crochet,
			"stepCrochet" 		=> Conductor.stepCrochet,
			"songLength" 		=> FlxG.sound.music.length,
			"songName" 			=> PlayState.SONG.meta.name,
			"startedCountdown" 	=> PlayState.instance.startCountdown,
			"stage" 			=> PlayState.SONG.stage,
			"storyMode" 		=> PlayState.isStoryMode,
			"difficulty" 		=> PlayState.difficulty,
			"week" 				=> PlayState.storyWeek.name,
			"seenCutscene" 		=> PlayState.seenCutscene,
			"hasVocals" 		=> PlayState.SONG.meta.needsVoices,
			// Camera
			"camX" 			=> 0,
			"camY" 			=> 0,
			// Game Screen
			"gameWidth" 	=> FlxG.width,
			"gameHeight" 	=> FlxG.height,

			// Variables
			"curBeat" 		=> 0,
			"curBeatFloat" 	=> 0.0,
			"curStep" 		=> 0,
			"curStepFloat" 	=> 0.0,

			"score" 		=> 0,
			"misses" 		=> 0,
			"hits" 			=> 0,
			"combo" 		=> 0,

			"rating" 		=> '',

			"inGameOver" 	=> false,
			
			"healthGainMulti" => 1.0,
			"healthLossMulti" => 1.0,

			"botPlay" 		=> PlayState.instance.playerStrums.cpu,
			
			// TODO: playerStrum/opponentStrum position

			"boyfriendName" => PlayState.instance.boyfriend.curCharacter,
			"boyfriendX" 	=> PlayState.instance.stage.characterPoses['boyfriend'].x,
			"boyfriendY" 	=> PlayState.instance.stage.characterPoses['boyfriend'].y,
			"boyfriendRawX" => PlayState.instance.boyfriend.x,
			"boyfriendRawY" => PlayState.instance.boyfriend.y,
			"dadName" 		=> PlayState.instance.dad.curCharacter,
			"dadX" 			=> PlayState.instance.stage.characterPoses['dad'].x,
			"dadY" 			=> PlayState.instance.stage.characterPoses['dad'].y,
			"dadRawX" 		=> PlayState.instance.dad.x,
			"dadRawY" 		=> PlayState.instance.dad.y,
			"girlfriendName" => PlayState.instance.gf.curCharacter,
			"girlfriendX" 	=> PlayState.instance.stage.characterPoses['girlfriend'].x,
			"girlfriendY" 	=> PlayState.instance.stage.characterPoses['girlfriend'].y,
			"girlfriendRawX" => PlayState.instance.gf.x,
			"girlfriendRawY" => PlayState.instance.gf.y,

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

    public var state:State = null;
	public var path:String = '';
    public var callbacks:Map<String, Dynamic> = [];

	public function new(path:String) {
		super();
	}

    public function onCreate(path:String) {

        state = LuaL.newstate();
		LuaL.openlibs(state);

		this.path = path.trim();

		var game = PlayState.instance;
		//game.stateScripts.scripts.push(this);
		
        
    }

    public function onLoad() {
        if (state.dostring(Assets.getText(path)) != 0)
            return;
    }

    public function onCall(funcName:String, args:Array<Dynamic>):Dynamic {
        return null;
    }

    public function set(variable:String, value:Dynamic) {
        
    }

	public override function destroy() {
		if (state != null) {
            Lua.close(state);
            state = null;
        }
	}

    public function reload() {
        Logs.trace('Hot-reloading is currently not supported on Lua.', WARNING);
    }

    public function setParent(variable:Dynamic) {

	}
}
#end
