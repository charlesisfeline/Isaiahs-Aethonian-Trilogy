local hasTween = false
local canTween = false
local posX = 500
local strumY
local strumY2
local ab = 0.005
local ab1 = 0.0008
local factor = 1

function postCreate()
	print("prePost")
	createSprite('fabi', 'fabi', posX, 500);
	addSprite('fabi', 'camGame');
	setSpriteScale('fabi', 0.2, 0.2)
	tween('fabitween', 'fabi', 'x', posX + 100, (60/curBpm), 'circinout', 'pingpong', 0)

	createText('luaText', 'Isaiahs Aethonian Trilogy', posX + 50, 90, 0, 27, 'camHUD')
	addSprite('luaText', 'camHUD')
	initShader('chromaticAberration')
	addShader('camGame', 'chromaticAberration')

	print("created");

	print(getField("camGame.flashSprite.scaleX"))

	for i=0,1 do
		for j=1,4 do
			tweenNote('skewNote'..i..j, i, j, "skew.x", -10, 0.1, 'linear', 'oneshot', 0)
		end
	end

	print(getClassField('funkin.game.PlayState', 'SONG.meta.bpm'))
	strumY = {getArrayField('playerStrums', 0, 'y'), getArrayField('playerStrums', 1, 'y'), getArrayField('playerStrums', 2, 'y'), getArrayField('playerStrums', 3, 'y')}
	strumY2 = {getArrayField('cpuStrums', 0, 'y'), getArrayField('cpuStrums', 1, 'y'), getArrayField('cpuStrums', 2, 'y'), getArrayField('cpuStrums', 3, 'y')}
end

function postUpdate(elapsed)
	-- playstate setting is not working for some reason (idk why)
	--local curBeatDec = getClassField('funkin.backend.system.Conductor', 'curBeatFloat')

	if canTween then
		for i=0,3 do
			setArrayField('playerStrums', i, 'y', strumY[i+1] + math.sin(curBeatFloat*factor + i * math.pi/4) * 50)
			setArrayField('cpuStrums', i, 'y', strumY2[i+1] + math.sin(curBeatFloat*factor + i * math.pi/4) * 50)
		end
	end
end

function beatHit(curBeat)
	-- body
	if(curBeat == 0) then
		canTween = true
		factor = 2
		skewNotes()
		invertX()
	end
	if(curBeat == 1) then
		invertY()
	end
	if(curBeat == 2) then
		invertX()
	end
	if(curBeat == 3) then
		invertY()
	end

	if(math.fmod(curBeat, 2) == 0 and not hasTween) then
		--print(curBeat)
		shake('camHUD', 0.01, 0.1)
		setShaderField('chromaticAberration', 'redOff', {ab1, 0})
		setShaderField('chromaticAberration', 'blueOff', {-ab1, 0})
		hasTween = true
	elseif(math.fmod(curBeat, 4) == 0 and hasTween) then
		setShaderField('chromaticAberration', 'redOff', {ab, 0})
		setShaderField('chromaticAberration', 'blueOff', {-ab, 0})
		hasTween = false
	end

	if curBeat == 32 then
		cancelTween('fabitween')
		resetSkew()
		factor = 1
	end
end

function invertX()
	--tween('invertHUD', 'camHUD.flashSprite', 'scaleX', getField('camHUD.flashSprite.scaleX') * -1, 0.5, 'circOut')
	--tween('invertGame', 'camGame.flashSprite', 'scaleX', getField('camGame.flashSprite.scaleX') * -1, 0.5, 'circOut')
	camHUD.flashSprite.scaleX = camHUD.flashSprite.scaleX * -1;
	camGame.flashSprite.scaleX = camGame.flashSprite.scaleX * -1;
end

function invertY() 
	--tween('invertHUD2', 'camHUD.flashSprite', 'scaleY', getField('camHUD.flashSprite.scaleY') * -1, 0.5, 'circOut')
	--tween('invertGame2', 'camGame.flashSprite', 'scaleY', getField('camGame.flashSprite.scaleY') * -1, 0.5, 'circOut')
	camHUD.flashSprite.scaleY = camHUD.flashSprite.scaleY * -1;
	camGame.flashSprite.scaleY = camGame.flashSprite.scaleY * -1;
end

function skewNotes()
	for i=0,1 do -- strumline
		for j=1,4 do -- note
			tweenNote('skewNote'..i..j, i, j, "skew.x", 10, (60/curBpm), 'elasticout', 'pingpong', 0)
		end
	end
end

function resetSkew()
	for i=0,1 do
		for j=1,4 do
			cancelTween('skewNote'..i..j)
			tweenNote('RskewNote'..i..j, i, j, "skew.x", 0, 0.1, 'linear', 'oneshot', 0)
		end
	end
end

function callMe()
	print("Hi! :3")
	--createSprite('fish2', 'credits/credit icon example', posX + 700, 300);
	--addSprite('fish2');
end