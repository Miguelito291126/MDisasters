SetGlobalFloat("temperature", 0)
SetGlobalFloat("pressure", 0)
SetGlobalFloat("humidity", 0)
SetGlobalFloat("wind_speed", 0)
SetGlobalVector("wind_dir", Vector(1,0,0))

function Weather_Update()
    MDisasters.weather.Temperature = math.Clamp(MDisasters.weather.Temperature, -273.3, 273.3)
    MDisasters.weather.Pressure = math.Clamp(MDisasters.weather.Pressure, 0, math.huge)
    MDisasters.weather.Humidity  = math.Clamp(MDisasters.weather.Humidity, 0, 100)


    MDisasters.weather.Temperature = Lerp(0.005, MDisasters.weather.Temperature,MDisasters.weather.target.Temperature)
    MDisasters.weather.Pressure = Lerp(0.005, MDisasters.weather.Pressure,MDisasters.weather.target.Pressure)
    MDisasters.weather.Wind.speed = Lerp(0.005, MDisasters.weather.Wind.speed,MDisasters.weather.target.Wind.speed)
    MDisasters.weather.Humidity = Lerp(0.005, MDisasters.weather.Humidity,MDisasters.weather.target.Humidity)
    MDisasters.weather.Wind.dir = LerpVector(0.005, MDisasters.weather.Wind.dir,MDisasters.weather.target.Wind.dir)


    Temperature()
    Humidity()
    Oxygen()
    Pressure()
    Wind()
end

function Temperature()

    if GetConVar("MDisasters_hud_temperature_enabled"):GetBool() == false then return end


	local temp = MDisasters.weather.Temperature  
	local humidity = MDisasters.weather.Humidity
	local compensation_max = 10   -- degrees 
	local body_heat_genK = engine.TickInterval() -- basically 1 degree Celsius per second
	local body_heat_genMAX = 0.01/4
	local fire_heat_emission = 50
    local plys = player.GetAll()

    SetGlobalFloat("temperature", temp)

    local function updatevars()
        for k,v in pairs(plys) do

			local heatscale               = 0
			local coolscale               = 0

			local core_equilibrium           =  math.Clamp((37 - v.MDisasters.body.Temperature)*body_heat_genK, -body_heat_genMAX, body_heat_genMAX)
			local heatsource_equilibrium     =  math.Clamp((fire_heat_emission * (heatscale ))*body_heat_genK, 0, body_heat_genMAX * 1.3)  -- must be negative cause we wanna temperature difference to only be valid if player is colder than 
			local coldsource_equilibrium     =  math.Clamp((fire_heat_emission * ( coolscale))*body_heat_genK,body_heat_genMAX * -1.3, 0)  -- must be negative cause we wanna temperature difference to only be valid if player is colder than 
		
			local ambient_equilibrium        = math.Clamp(((temp - v.MDisasters.body.Temperature)*body_heat_genK), -body_heat_genMAX*1.1, body_heat_genMAX * 1.1)
			
			if temp >= 5 and temp <= 37 then
				ambient_equilibrium          = 0
			end

            v.MDisasters.body.Temperature = math.Clamp(v.MDisasters.body.Temperature + core_equilibrium  + heatsource_equilibrium + coldsource_equilibrium + ambient_equilibrium, 24, 44)
            
            v:SetNWFloat("BodyTemperature", v.MDisasters.body.Temperature)
        end
        
    end
    local function Damage()
        if GetConVar("MDisasters_hud_damage_temperature_enabled"):GetBool() == false then return end

        for k,v in pairs(plys) do
            local tempbody = v.MDisasters.body.Temperature
			local alpha_hot  =  1-((44-math.Clamp(tempbody,39,44))/5)
			local alpha_cold =  ((35-math.Clamp(tempbody,24,35))/11)
            
			if math.random(1,25) == 25 then
				if alpha_cold != 0 then
					
                    local dmg = DamageInfo()
                    dmg:SetDamage( math.random(1,25) )
                    dmg:SetAttacker( v )
                    dmg:SetDamageType( DMG_GENERIC )
                    v:TakeDamageInfo(  dmg)
					
					v:SetWalkSpeed( v:GetWalkSpeed() - (alpha_cold + 1) )
					v:SetRunSpeed( v:GetRunSpeed() - (alpha_cold + 1)  )
				
					
				
				elseif alpha_hot != 0 then
					
                    local dmg = DamageInfo()
                    dmg:SetDamage( math.random(1,25) )
                    dmg:SetAttacker( v )
                    dmg:SetDamageType( DMG_BURN  )
                    v:TakeDamageInfo(  dmg)
					
					v:SetWalkSpeed( v:GetWalkSpeed() - (alpha_hot - 1) )
					v:SetRunSpeed( v:GetRunSpeed() - (alpha_hot - 1)  )
					
					
				else					
					v:SetWalkSpeed( 200 )
					v:SetRunSpeed( 240 )
				end
            end


            if MDisasters.weather.Temperature <= -100 then
                v.MDisasters.body.Temperature = v.MDisasters.body.Temperature - 0.01
            elseif MDisasters.weather.Temperature >= 100 then
                v.MDisasters.body.Temperature = v.MDisasters.body.Temperature + 0.01
            elseif MDisasters.weather.Temperature <= -500 then
                v.MDisasters.body.Temperature = v.MDisasters.body.Temperature - 0.1
            elseif MDisasters.weather.Temperature >= 500 then
                v.MDisasters.body.Temperature = v.MDisasters.body.Temperature + 0.1
            end

            if v:WaterLevel() >= 2 then
                v.MDisasters.body.Temperature = v.MDisasters.body.Temperature - 0.001
            end
            
            if v.MDisasters.body.Temperature >= 45 or v.MDisasters.body.Temperature <= 25 then 
                if v:Alive() then v:Kill() end 
            end
        end     
    end
    updatevars()
    Damage()

end

function Humidity()
    SetGlobalVector("humidity", MDisasters.weather.Humidity)   
end

function Pressure()
    SetGlobalVector("pressure", MDisasters.weather.Pressure)   
end

function Wind()
    local Direction = MDisasters.weather.Wind.dir
    local Force = MDisasters.weather.Wind.speed
    local windVec = Direction:GetNormalized() * Force
    local ents = ents.GetAll()

    SetGlobalFloat("wind_speed", Force)
    SetGlobalVector("wind_dir", Direction)

    for _, ply in ipairs(player.GetAll()) do
       
        local local_wind = Force
        
        if !isOutdoor(ply) or IsSomethingBlockingWind(ply) then local_wind = 0 end
        
        local local_windVec = Direction:GetNormalized() * local_wind
         
        ply.MDisasters.Area.Local_wind = local_wind
        ply:SetNWFloat("BodyWind", local_wind)
        ply:SetVelocity(local_windVec)



    end
    for _, ent in ipairs(ents) do
        if ent:IsValid() then
            local phys = ent:GetPhysicsObject()
            if phys:IsValid() then
                if Force >= 25 then
                    -- Solo afectar props si están al aire libre
                    if isOutdoor(ent) then
                        phys:AddVelocity(windVec)
                        
                        if math.random(0,25) == 25 then
                            constraint.RemoveAll(ent)
                            phys:Wake()
                            phys:EnableMotion(true)
                        end
                    end
                else
                    -- Solo afectar props si están al aire libre
                    if isOutdoor(ent) then
                        phys:AddVelocity(windVec)
                    end
                end 
            else
                ent:SetVelocity(windVec)              
            end
        end
    end
end

local delay = 0

function Oxygen() 
    
    if GetConVar("MDisasters_hud_oxygen_enabled"):GetBool() == false then return end

    if CurTime() < delay then return end

    for k, v in pairs(player.GetAll()) do
        
        if v:WaterLevel() >= 3 then
            if CurTime() < delay then return end
            
            v.MDisasters.body.Oxygen = math.Clamp( v.MDisasters.body.Oxygen - 5,0,100 )
            
            
        else
            v.MDisasters.body.Oxygen = math.Clamp( v.MDisasters.body.Oxygen + 5,0,100 )
        end

        if v.MDisasters.body.Oxygen <= 0 then
            if GetConVar("MDisasters_hud_damage_oxygen_enabled"):GetBool() == false then return end


            if math.random(1,5) == 5 then
                local dmg = DamageInfo()
                dmg:SetDamage( math.random(1,25) )
                dmg:SetAttacker( v )
                dmg:SetDamageType( DMG_DROWN  )
            
        
                v:TakeDamageInfo(  dmg)
            end
        end

        v:SetNWFloat("BodyOxygen", v.MDisasters.body.Oxygen)
    end
    delay = CurTime() + 0.5
end

hook.Add("Think", "Weather_Update", Weather_Update)
