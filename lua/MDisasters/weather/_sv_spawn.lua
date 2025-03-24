function PostSpawnSV(ply)
    ply.mdisasters = {}
    ply.mdisasters.body = {}
    ply.mdisasters.body.Temperature = 36.6
    ply.mdisasters.body.Oxygen = 100

    ply.mdisasters.Area = {}
    ply.mdisasters.Area.Local_wind = 0
    ply.mdisasters.Area.IsOutDoor = false
    
    ply.Sounds = {}

    ply:SetNWFloat("BodyTemperature", ply.mdisasters.body.Temperature)
    ply:SetNWFloat("BodyOxygen", ply.mdisasters.body.Oxygen)
    ply:SetNWFloat("BodyWind", ply.mdisasters.body.local_wind)
end

function PostSpawnSV_Reset(ply)
    ply.mdisasters.body.Temperature = 36.6
    ply.mdisasters.body.Oxygen = 100

    ply:SetNWFloat("BodyTemperature", ply.mdisasters.body.Temperature)
    ply:SetNWFloat("BodyOxygen", ply.mdisasters.body.Oxygen)
end

hook.Add("PlayerInitialSpawn", "PostSpawnSV", PostSpawnSV)
hook.Add("PlayerSpawn", "PostSpawnSV_Reset", PostSpawnSV_Reset)