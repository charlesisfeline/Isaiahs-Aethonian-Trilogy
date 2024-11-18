var subtitleTxts:Array<FunkinText> = [];

function onEvent(e) {
    if (e.event.name == "Subtitle") {
        if (subtitleTxts.length >= 3) {
            remove(subtitleTxts[0]);
            subtitleTxts[0].destroy();
            subtitleTxts.remove(subtitleTxts[0]);
        }
        subtitleTxts.push(newText(e.event.params));
        add(subtitleTxts[subtitleTxts.length - 1]);
    }
}

function update(_:Float) {
    for (num => a in subtitleTxts)
        a.y = FlxMath.lerp(a.y, 675 - ((subtitleTxts.length-num) * 70), 0.04);
}

function newText(params:Array<Dynamic>):FunkinText {
    var mycock:FunkinText = new FunkinText(0, 675, 0, params[0], 64, true);
    mycock.color = params[1];
    mycock.camera = camHUD;
    mycock.antialiasing = Options.antialiasing;
    mycock.screenCenter(FlxAxes.X);
    FlxTween.tween(mycock, {alpha: 0}, (Conductor.stepCrochet / 1000) * 16, {startDelay: (Conductor.stepCrochet / 1000) * 8, onComplete: (_) -> remove(mycock.destroy())});
    return mycock;
}