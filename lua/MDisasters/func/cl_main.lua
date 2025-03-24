function CreateLoopedSound(client, sound)
	local sound = Sound(sound)

	CSPatch = CreateSound(client, sound)
	CSPatch:Play()
	return CSPatch
	
end

function StopLoopedSound(client, sound)
	CSPatch = CreateLoopedSound(client, sound)
	CSPatch:Stop()
	return CSPatch
	
end