function Atmosphere()
    WindControl()
end
hook.Add("Think", "atmosphericLoop", Atmosphere)

function WindControl()
    local ply = LocalPlayer()
    if not ply or not ply.mdisasters.Outside then return end
    if ply.Sounds == nil then ply.Sounds = {} end

    local localWind = ply:GetNWFloat("BodyWind")
    local outsideFactor = math.Clamp(ply.mdisasters.Outside.OutsideFactor / 100, 0, 1)

    local windWeakVolume = math.Clamp(((math.Clamp((localWind / 20), 0, 1) * 5) ^ 2 * localWind) / 20, 0, 1)
    
    if ply.mdisasters.Outside.IsOutside then
        windWeakVolume = windWeakVolume * outsideFactor
    else
        windWeakVolume = windWeakVolume * math.max(outsideFactor, 0.1)
    end

    local windModVolume = math.Clamp((localWind - 20) / 60, 0, 1) * outsideFactor
    local windStrongVolume = math.Clamp((localWind - 80) / 120, 0, 1) * outsideFactor

    if not ply.Sounds["Wind_Heavy"] then
        ply.Sounds["Wind_Light"] = CreateLoopedSound(ply, "weather/wind/wind_effect.wav")
        ply.Sounds["Wind_Moderate"] = CreateLoopedSound(ply, "weather/wind/wind_effect.wav")
        ply.Sounds["Wind_Heavy"] = CreateLoopedSound(ply, "weather/wind/wind_effect.wav")

        ply.Sounds["Wind_Light"]:ChangeVolume(0, 0)
        ply.Sounds["Wind_Moderate"]:ChangeVolume(0, 0)
        ply.Sounds["Wind_Heavy"]:ChangeVolume(0, 0)
    end

    ply.Sounds["Wind_Light"]:ChangeVolume(windWeakVolume, 0)
    ply.Sounds["Wind_Moderate"]:ChangeVolume(windModVolume, 0)
    ply.Sounds["Wind_Heavy"]:ChangeVolume(windStrongVolume, 0)
end
