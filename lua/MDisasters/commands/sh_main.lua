function convars()
    CreateConVar( "MDisasters_hud_oxygen_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_hud_temperature_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_hud_damage_oxygen_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_hud_damage_temperature_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_tornado_constraints_damage", "1", {FCVAR_ARCHIVE}, " " )
    
    concommand.Add("MDisasters_setwind", function(cmd, args, wind)
        local speed = wind[1]
        MDisasters.weather.target.Wind.speed = tonumber(speed)
    end)

    concommand.Add("MDisasters_setwind_direction", function(cmd, args, wind)
        local direction = Vector(tonumber(wind[1]), tonumber(wind[2]), tonumber(wind[3]))
        MDisasters.weather.target.Wind.dir  = direction
    end)


    concommand.Add("MDisasters_setbody_temp", function(cmd, args, temp)
        for k, v in pairs(player.GetAll()) do
            local temperature = temp[1]
            v.MDisasters.body.Temperature = tonumber(temperature)
        
        end
    end)

    concommand.Add("MDisasters_setbody_oxygen", function(cmd, args, O2)
        for k, v in pairs(player.GetAll()) do
            local Oxygen = O2[1]
            v.MDisasters.body.Oxygen = tonumber(Oxygen)
        
        end
    end)

    concommand.Add("MDisasters_setpressure", function(cmd, args, pressure)
        local press = pressure[1]
        MDisasters.weather.target.Pressure = tonumber(press)
    end)

    concommand.Add("MDisasters_sethumidity", function(cmd, args, humidity)
        local humi =  humidity[1]
        MDisasters.weather.target.Humidity = tonumber(humi)
    end)

    concommand.Add("MDisasters_settemp", function(cmd, args, temp)
        local temperature = temp[1]
        MDisasters.weather.target.Temperature = tonumber(temperature)
    end)

end


hook.Add( "InitPostEntity", "MDisasters_convars_init_sh", convars)