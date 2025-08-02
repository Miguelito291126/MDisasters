AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Rain"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "MDisasters"

function ENT:Initialize()
    if CLIENT then
        LocalPlayer().MDisasters.Sounds.rain = CreateLoopedSound(LocalPlayer(), "weather/rain/rain_effect.wav")
        LocalPlayer().MDisasters.Sounds.rain:Play()
    end


    if SERVER then
       MDisasters.weather.target.Wind.dir = Vector(math.random(-1,1), math.random(-1,1), 0)
       MDisasters.weather.target.Wind.speed = math.random(5, 10)
       MDisasters.weather.target.Temperature = math.random(5, 15)
       MDisasters.weather.target.Humidity = math.random(25, 40)
       MDisasters.weather.target.Pressure = math.random(980, 990)
        
        self:SetModel("models/props_junk/PopCan01a.mdl") -- invisible prop
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		self.Original_SkyData = {}
        self.Original_SkyData["TopColor"]    = Vector(0.2, 0.2, 0.2)
        self.Original_SkyData["BottomColor"] = Vector(0.2, 0.2, 0.2)
        self.Original_SkyData["DuskScale"]   = 0

		for i=0, 100 do
			timer.Simple(i/100, function()
				if !self:IsValid() then return  end
				paintSky_Fade(self.Original_SkyData, 0.05)
			end)
		end 
        
        setMapLight("d")

        self:SetNoDraw(true)
    end
end

function ENT:RainEffect()
    for _, ply in ipairs(player.GetAll()) do

        if isOutdoor(ply) then
            net.Start("md_clparticles")
            net.WriteString("rain_effect")
            net.Send(ply)

            net.Start("md_clparticles_ground")
            net.WriteString("rain_effect_ground")
            net.Send(ply)

        end
    end
end

function ENT:OnRemove()
    if CLIENT then
        LocalPlayer().MDisasters.Sounds.rain:Stop()
        LocalPlayer().MDisasters.Sounds.rain = nil
    end  
	if (SERVER) then		
       MDisasters.weather.target.Wind.dir =MDisasters.weather.original.Wind.dir 
       MDisasters.weather.target.Wind.speed =MDisasters.weather.original.Wind.speed
       MDisasters.weather.target.Temperature =MDisasters.weather.original.Temperature
       MDisasters.weather.target.Humidity =MDisasters.weather.original.Humidity
       MDisasters.weather.target.Pressure =MDisasters.weather.original.Pressure

        Reset_SkyData = {}
        Reset_SkyData["TopColor"]       = Vector(0.20,0.50,1.00)
        Reset_SkyData["BottomColor"]    = Vector(0.80,1.00,1.00)
        Reset_SkyData["DuskScale"]      = 1
        Reset_SkyData["SunColor"]       = Vector(0.20,0.10,0.00)   

		for i=0, 40 do
			timer.Simple(i/100, function()
				paintSky_Fade(Reset_SkyData,0.05)
			end)
		end

		setMapLight("t")
    end
end

function ENT:Think()
    local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate

    if (CLIENT) then
        if LocalPlayer().MDisasters.Outside.IsOutside then
            LocalPlayer().MDisasters.Sounds.rain:ChangeVolume(1)
        else
            LocalPlayer().MDisasters.Sounds.rain:ChangeVolume(0.5)
        end
    end
    if (SERVER) then
        self:RainEffect()
        self:NextThink(CurTime())
        return true
    end
end

