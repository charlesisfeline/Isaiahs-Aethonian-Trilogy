import openfl.geom.Rectangle;
import openfl.text.TextFormat;
import flixel.text.FlxTextBorderStyle;
import flixel.ui.FlxBar;
import flixel.FlxG;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.math.FlxPoint;
import openfl.events.KeyboardEvent;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.framerate.FramerateCounter;
import openfl.system.System;
import openfl.text.TextFormat;
import openfl.Lib;
import flixel.FlxG;
import funkin.options.Options;

public var botplayTxt:FlxText;
public var botplaySine:Float = 0;

function create() {
    botplayTxt = new FlxText(400, 83, FlxG.width - 800, "AUTOPLAY", 32);
    botplayTxt.setFormat(Paths.font("youtube.ttf"), 32, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    botplayTxt.scrollFactor.set();
    botplayTxt.borderSize = 3;
    botplayTxt.alpha = 0;
    botplayTxt.cameras = [camHUD];
    add(botplayTxt);
}

function update(elapsed:Float) {
    if (FlxG.save.data.botplayOption) {
        botplaySine += 180 *  FlxG.elapsed;
        botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
        player.cpu = true;
    }
}

function onPlayerMiss(event) {
    if (event.note.isSustainNote) return;
}
function onPlayerHit(event) {
    if (event.note.isSustainNote) return;
}

function postCreate() {
}