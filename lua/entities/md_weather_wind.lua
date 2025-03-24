AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Wind"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "MDisasters"

function ENT:Initialize()

    if SERVER then
        self:SetModel("models/props_junk/PopCan01a.mdl") -- invisible
        self:SetNoDraw(true)
        self:SetSolid(SOLID_NONE)

       MDisasters.weather.target.Wind.dir = Vector(math.random(-1,1), math.random(-1,1), 0)
       MDisasters.weather.target.Wind.speed = math.random(5, 10)
       MDisasters.weather.target.Temperature = math.random(5, 15)
       MDisasters.weather.target.Humidity = math.random(25, 40)
       MDisasters.weather.target.Pressure = math.random(980, 990)
        
    end
end

function ENT:OnRemove()
 	if (SERVER) then	
       MDisasters.weather.target.Wind.dir =MDisasters.weather.original.Wind.dir 
       MDisasters.weather.target.Wind.speed =MDisasters.weather.original.Wind.speed
       MDisasters.weather.target.Temperature =MDisasters.weather.original.Temperature
       MDisasters.weather.target.Humidity =MDisasters.weather.original.Humidity
       MDisasters.weather.target.Pressure =MDisasters.weather.original.Pressure
	end
end

function ENT:Think()
    self:NextThink(CurTime() + 1)
    return true
end

function ENT:Draw()
    -- Invisible
end
