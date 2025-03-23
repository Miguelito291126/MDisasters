AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Rain"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "MDisasters"

function ENT:Initialize()

    self:SpawnSnowground()

    if SERVER then
       mdisasters.weather.target.Wind.dir = Vector(math.random(-1000,1000), math.random(-1000,1000),0)
       mdisasters.weather.target.Wind.speed = math.random(5, 15)
       mdisasters.weather.target.Temperature = math.random(-5, 0)
       mdisasters.weather.target.Humidity = math.random(25, 40)
       mdisasters.weather.target.Pressure = math.random(980, 990)
        
        self:SetModel("models/props_junk/PopCan01a.mdl") -- invisible prop
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)


        self.snowProps = {}
		self.Original_SkyData = {}
        self.Original_SkyData["TopColor"]    = Vector(0.2, 0.2, 0.2)
        self.Original_SkyData["BottomColor"] = Vector(0.2, 0.2, 0.2)
        self.Original_SkyData["DuskScale"]   = 0
		
        net.Start("md_sendloopsound")
        net.WriteString("weather/wind/wind_effect.wav")
        net.Broadcast()

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

function ENT:SpawnSnowground() 
	for i=0, 25 do
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]

		local startpos  = Vector(math.random(min.x,max.x), math.random(min.y,max.y), max.z )
		
		local tr = util.TraceLine( {
			start = startpos,
			endpos = startpos - Vector(0,0,50000),
			mask = MASK_SOLID_BRUSHONLY
		} )	

		util.Decal("snow", tr.HitPos + tr.HitNormal,  tr.HitPos - tr.HitNormal)
	end
end

function ENT:SnowEffect()
    for _, ply in ipairs(player.GetAll()) do

        if isOutdoor(ply) then
            net.Start("md_clparticles")
            net.WriteString("snow_effect")
            net.Send(ply)

        end
    end
end

function ENT:OnRemove()
	if (SERVER) then		
       mdisasters.weather.target.Wind.dir =mdisasters.weather.original.Wind.dir 
       mdisasters.weather.target.Wind.speed =mdisasters.weather.original.Wind.speed
       mdisasters.weather.target.Temperature =mdisasters.weather.original.Temperature
       mdisasters.weather.target.Humidity =mdisasters.weather.original.Humidity
       mdisasters.weather.target.Pressure =mdisasters.weather.original.Pressure

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
        
        net.Start("md_stoploopsound")
        net.WriteString("weather/wind/wind_effect.wav")
        net.Broadcast()
    end
end

function ENT:Think()
    local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate

    if (SERVER) then
        self:SnowEffect()
        self:NextThink(CurTime() +  t)
        return true
    end
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end
