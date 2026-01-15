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

-- Efectos visuales de temperatura en pantalla
function TemperatureScreenEffects()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	if not GetConVar("MDisasters_hud_temperature_enabled"):GetBool() then return end
	
	local bodyTemp = ply:GetNWFloat("MDisasters_BodyTemperature") or 37
	local temp = GetGlobalFloat("MDisasters_temperature") or 0
	
	-- Calcular intensidad de efectos de calor (temperatura alta del cuerpo: 39-44°C)
	local alpha_hot = 0
	if bodyTemp >= 39 then
		alpha_hot = math.Clamp(1 - ((44 - math.Clamp(bodyTemp, 39, 44)) / 5), 0, 1)
	end
	
	-- Calcular intensidad de efectos de frío (temperatura baja del cuerpo: 24-35°C)
	local alpha_cold = 0
	if bodyTemp <= 35 then
		alpha_cold = math.Clamp(((35 - math.Clamp(bodyTemp, 24, 35)) / 11), 0, 1)
	end
	
	-- Aplicar overlay de calor (rojo/naranja)
	if alpha_hot > 0 then
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(255, 100, 0, alpha_hot * 40))
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(255, 200, 150, alpha_hot * 25))
		
		-- Efecto de distorsión visual por calor extremo
		if alpha_hot > 0.7 then
			local time = CurTime() * 2
			local intensity = (alpha_hot - 0.7) / 0.3
			local wave = math.sin(time) * intensity * 3
			draw.RoundedBox(0, 0, 0 + wave, ScrW(), ScrH() * 0.1, Color(255, 150, 50, alpha_hot * 15))
		end
	end
	
	-- Aplicar overlay de frío (azul/cian)
	if alpha_cold > 0 then
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(100, 150, 255, alpha_cold * 50))
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(150, 200, 255, alpha_cold * 30))
		
		-- Efecto de "congelamiento" en los bordes
		if alpha_cold > 0.6 then
			local borderWidth = 10
			draw.RoundedBox(0, 0, 0, ScrW(), borderWidth, Color(200, 220, 255, alpha_cold * 60))
			draw.RoundedBox(0, 0, ScrH() - borderWidth, ScrW(), borderWidth, Color(200, 220, 255, alpha_cold * 60))
			draw.RoundedBox(0, 0, 0, borderWidth, ScrH(), Color(200, 220, 255, alpha_cold * 60))
			draw.RoundedBox(0, ScrW() - borderWidth, 0, borderWidth, ScrH(), Color(200, 220, 255, alpha_cold * 60))
		end
	end
	
	-- Efecto adicional basado en temperatura ambiente extrema
	if temp >= 50 then
		local env_alpha = math.Clamp((temp - 50) / 100, 0, 0.3)
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(255, 150, 50, env_alpha * 255))
	elseif temp <= -20 then
		local env_alpha = math.Clamp(math.abs(temp + 20) / 50, 0, 0.3)
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(150, 200, 255, env_alpha * 255))
	end
end

-- Hook para renderizar efectos de temperatura en pantalla
hook.Add("HUDPaint", "MDisasters_TemperatureScreenEffects", function()
	TemperatureScreenEffects()
end)

-- Efecto adicional con RenderScreenspaceEffects para modificación de color
hook.Add("RenderScreenspaceEffects", "MDisasters_TemperatureColorModify", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	if not GetConVar("MDisasters_hud_temperature_enabled"):GetBool() then return end
	
	local bodyTemp = ply:GetNWFloat("MDisasters_BodyTemperature") or 37
	local temp = GetGlobalFloat("MDisasters_temperature") or 0
	
	local alpha_hot = 0
	if bodyTemp >= 39 then
		alpha_hot = math.Clamp(1 - ((44 - math.Clamp(bodyTemp, 39, 44)) / 5), 0, 1)
	end
	
	local alpha_cold = 0
	if bodyTemp <= 35 then
		alpha_cold = math.Clamp(((35 - math.Clamp(bodyTemp, 24, 35)) / 11), 0, 1)
	end
	
	-- Modificación de color combinada para calor y frío
	if alpha_hot > 0.1 or alpha_cold > 0.1 then
		-- Combinar ambos efectos si ambos están activos (aunque normalmente solo uno debería estar activo)
		local colormod = {
			["$pp_colour_addr"] = (alpha_hot * 0.15) - (alpha_cold * 0.1),
			["$pp_colour_addg"] = (alpha_hot * 0.05) + (alpha_cold * 0.05),
			["$pp_colour_addb"] = (alpha_hot * -0.1) + (alpha_cold * 0.15),
			["$pp_colour_brightness"] = (alpha_hot * 0.05) - (alpha_cold * 0.1),
			["$pp_colour_contrast"] = 1 + (alpha_hot * 0.1) + (alpha_cold * 0.05),
			["$pp_colour_colour"] = 1 - (alpha_hot * 0.1) - (alpha_cold * 0.2),
			["$pp_colour_mulr"] = 1 + (alpha_hot * 0.2) - (alpha_cold * 0.1),
			["$pp_colour_mulg"] = 1 - (alpha_cold * 0.05),
			["$pp_colour_mulb"] = 1 - (alpha_hot * 0.15) + (alpha_cold * 0.15)
		}
		DrawColorModify(colormod)
	end
end)