function PostSpawnSV(ply)
    ply.MDisasters = {}
    ply.MDisasters.body = {}
    ply.MDisasters.body.Temperature = 36.6
    ply.MDisasters.body.Oxygen = 100

    ply.MDisasters.Area = {}
    ply.MDisasters.Area.Local_wind = 0
    ply.MDisasters.Area.IsOutDoor = false
    
    ply.Sounds = {}

    ply:SetNWFloat("BodyTemperature", ply.MDisasters.body.Temperature)
    ply:SetNWFloat("BodyOxygen", ply.MDisasters.body.Oxygen)
    ply:SetNWFloat("BodyWind", ply.MDisasters.body.local_wind)
end

function PostSpawnSV_Reset(ply)
    ply.MDisasters.body.Temperature = 36.6
    ply.MDisasters.body.Oxygen = 100

    ply:SetNWFloat("BodyTemperature", ply.MDisasters.body.Temperature)
    ply:SetNWFloat("BodyOxygen", ply.MDisasters.body.Oxygen)
end

hook.Add("PlayerInitialSpawn", "PostSpawnSV", PostSpawnSV)
hook.Add("PlayerSpawn", "PostSpawnSV_Reset", PostSpawnSV_Reset)