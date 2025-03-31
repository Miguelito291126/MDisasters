function MDisasters_PostSpawnSV(ply)
    ply.MDisasters = {}
    ply.MDisasters.Body = {}
    ply.MDisasters.Body.Temperature = 36.6
    ply.MDisasters.Body.Oxygen = 100

    ply.MDisasters.Area = {}
    ply.MDisasters.Area.Local_wind = 0
    ply.MDisasters.Area.IsOutDoor = false
    
    ply.MDisasters.Sounds = {}

    ply:SetNWFloat("MDisasters_BodyTemperature", ply.MDisasters.Body.Temperature)
    ply:SetNWFloat("MDisasters_BodyOxygen", ply.MDisasters.Body.Oxygen)
    ply:SetNWFloat("MDisasters_BodyWind", ply.MDisasters.Area.Local_wind)
end
hook.Add("PlayerInitialSpawn", "MDisasters_PostSpawnSV", MDisasters_PostSpawnSV)

function MDisasters_PostSpawnSV_Reset(ply)
    ply.MDisasters.Body.Temperature = 36.6
    ply.MDisasters.Body.Oxygen = 100

    ply:SetNWFloat("MDisasters_BodyTemperature", ply.MDisasters.Body.Temperature)
    ply:SetNWFloat("MDisasters_BodyOxygen", ply.MDisasters.Body.Oxygen)
end
hook.Add("PlayerSpawn", "MDisasters_PostSpawnSV_Reset", MDisasters_PostSpawnSV_Reset)