function Atmosphere()
	WindControl()
end
hook.Add("Think", "Weather_Sounds", Atmosphere)

function WindControl()
	if LocalPlayer().MDisasters == nil then return end
	if LocalPlayer().MDisasters.Sounds == nil then LocalPlayer().MDisasters.Sounds = {} end
	
	local local_wind    = LocalPlayer():GetNWFloat("MDisasters_BodyWind")
	local outside_fac   = LocalPlayer().MDisasters.Outside.OutsideFactor/100 
	local wind_weak_vol = math.Clamp( ( (math.Clamp((( math.Clamp(local_wind / 20, 0, 1) * 5)^2) * local_wind, 0, local_wind)) / 20), 0, 1) 
	
	
	if LocalPlayer().MDisasters.Outside.IsOutside then
		wind_weak_vol   = wind_weak_vol * math.Clamp(outside_fac , 0, 1) 
	else
		wind_weak_vol   = wind_weak_vol * math.Clamp(outside_fac , 0.1, 1)
	end
	
	local wind_mod_vol  = math.Clamp( ( (local_wind-20) / 60), 0, 1) * outside_fac 		
	local wind_str_vol  = math.Clamp( ( (local_wind-80) / 120), 0, 1) * outside_fac 	
	
	if LocalPlayer().MDisasters.Sounds.Wind_Heavy == nil then
		
		
		LocalPlayer().MDisasters.Sounds.Wind_Light        = CreateLoopedSound(LocalPlayer(), "weather/wind/wind_effect.wav")
		LocalPlayer().MDisasters.Sounds.Wind_Moderate   = CreateLoopedSound(LocalPlayer(), "weather/wind/wind_effect.wav")
		LocalPlayer().MDisasters.Sounds.Wind_Heavy         = CreateLoopedSound(LocalPlayer(), "weather/wind/wind_effect.wav")
		
		LocalPlayer().MDisasters.Sounds.Wind_Light:ChangeVolume(0, 0)
		LocalPlayer().MDisasters.Sounds.Wind_Moderate:ChangeVolume(0, 0)
		LocalPlayer().MDisasters.Sounds.Wind_Heavy:ChangeVolume(0, 0)
						
	end

	LocalPlayer().MDisasters.Sounds.Wind_Light:ChangeVolume(wind_weak_vol, 0)
	LocalPlayer().MDisasters.Sounds.Wind_Moderate:ChangeVolume(wind_mod_vol, 0)
	LocalPlayer().MDisasters.Sounds.Wind_Heavy:ChangeVolume(wind_str_vol, 0)		
	
	
end