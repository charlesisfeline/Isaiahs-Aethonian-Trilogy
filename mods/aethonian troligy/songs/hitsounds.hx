function onPlayerHit(a)
	if (!a.note.isSustainNote)
	    FlxG.sound.play(Paths.sound('hitsounds/hitsound_' + FlxG.save.data.hitsoundStyle), 0.8);