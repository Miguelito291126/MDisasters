net.Receive("md_clparticles", function()
	local effect = net.ReadString()
	local angle  = convert_VectorToAngle(-MDisasters.weather.Wind.dir)
	ParticleEffect( effect, LocalPlayer():GetPos(), angle, nil )
end)

net.Receive("md_clParticles_ground", function()
	for k,v in pairs(player.GetAll()) do
		if !v:IsOnGround() then return end
	end

	local effect = net.ReadString()
	local angle  = convert_VectorToAngle(-MDisasters.weather.Wind.dir)
	ParticleEffect( effect, LocalPlayer():GetPos(), angle, nil )

end)

net.Receive("md_sendsound", function()

	local name  = net.ReadString()
	local pitch  = net.ReadFloat() or 100
	local volume = net.ReadFloat() or 1
	LocalPlayer():EmitSound(name, 100, pitch, volume)



end)

net.Receive("md_stopsound", function()

	local name = net.ReadString()
	LocalPlayer():StopSound(name)

end)

net.Receive( "md_maplight_cl", function( len, pl ) 
	timer.Simple(0.1, function()
		render.RedownloadAllLightmaps()
	end)
end )

net.Receive("md_ambientlight", function()

	local tr = util.TraceLine( {
		start = LocalPlayer():GetPos(),
		endpos = LocalPlayer():GetPos() - Vector(0,0,100),
		filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
	} )

	if tr.Entity:IsValid() then LocalPlayer().AmbientLight = Vector(0,0,0) return end 

	LocalPlayer().AmbientLight = render.ComputeLighting(  tr.HitPos, tr.HitNormal )

	net.Start("md_ambientlight")
	net.WriteEntity(LocalPlayer())
	net.WriteVector(LocalPlayer().AmbientLight)
	net.SendToServer()

end)

net.Receive("md_isOutdoor", function()
	isOutside                = net.ReadBool()

	if LocalPlayer().MDisasters == nil then return end


	LocalPlayer().MDisasters.Outside.IsOutside     = isOutside




	if isOutside then

		LocalPlayer().MDisasters.Outside.OutsideFactor   = Lerp( 0.01, LocalPlayer().MDisasters.Outside.OutsideFactor, 100)

	else
		LocalPlayer().MDisasters.Outside.OutsideFactor   = Lerp( 0.01, LocalPlayer().MDisasters.Outside.OutsideFactor, 0)
	end

end)

net.Receive("md_sendloopsound", function()
	local name = net.ReadString()
	CreateLoopedSound(LocalPlayer(), name)
end)

net.Receive("md_stoploopsound", function()

	local name = net.ReadString()
	StopLoopedSound(LocalPlayer(), name)
end)