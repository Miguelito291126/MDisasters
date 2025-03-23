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

       mdisasters.weather.target.Wind.dir = Vector(math.random(-1000,1000), math.random(-1000,1000),0)
       mdisasters.weather.target.Wind.speed = math.random(5, 10)
       mdisasters.weather.target.Temperature = math.random(5, 15)
       mdisasters.weather.target.Humidity = math.random(25, 40)
       mdisasters.weather.target.Pressure = math.random(980, 990)
        
    end
end

function ENT:OnRemove()
 	if (SERVER) then	
       mdisasters.weather.target.Wind.dir =mdisasters.weather.original.Wind.dir 
       mdisasters.weather.target.Wind.speed =mdisasters.weather.original.Wind.speed
       mdisasters.weather.target.Temperature =mdisasters.weather.original.Temperature
       mdisasters.weather.target.Humidity =mdisasters.weather.original.Humidity
       mdisasters.weather.target.Pressure =mdisasters.weather.original.Pressure
	end
end

function ENT:Think()
    self:NextThink(CurTime() + 1)
    return true
end

function ENT:Draw()
    -- Invisible
end
