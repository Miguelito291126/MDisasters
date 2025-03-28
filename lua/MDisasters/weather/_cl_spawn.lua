function MDisasters_PostSpawnCL(ply)
    LocalPlayer().MDisasters = {}
    
    LocalPlayer().MDisasters.HUD = {}
    LocalPlayer().MDisasters.HUD.NextWarningSoundTime = CurTime()
    LocalPlayer().MDisasters.HUD.NextHeartSoundTime   = CurTime()
    LocalPlayer().MDisasters.HUD.NextVomitTime        = CurTime()
    LocalPlayer().MDisasters.HUD.NextVomitBloodTime   = CurTime()
    LocalPlayer().MDisasters.HUD.VomitIntensity       = 0
    LocalPlayer().MDisasters.HUD.BloodVomitIntensity  = 0
    LocalPlayer().MDisasters.HUD.NextSneezeTime       = CurTime()
    LocalPlayer().MDisasters.HUD.NextSneezeBigTime  = CurTime()
    LocalPlayer().MDisasters.HUD.SneezeIntensity       = 0
    LocalPlayer().MDisasters.HUD.SneezeBigIntensity  = 0

    LocalPlayer().MDisasters.Outside = {}
    LocalPlayer().MDisasters.Outside.IsOutside = false
    LocalPlayer().MDisasters.Outside.OutsideFactor = 0

    LocalPlayer().MDisasters.Sounds = {}
end

hook.Add("InitPostEntity", "MDisasters_PostSpawnCL", MDisasters_PostSpawnCL)