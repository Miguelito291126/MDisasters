function convars()
    CreateConVar( "mdisasters_hud_oxygen_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_hud_temperature_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_hud_damage_oxygen_enabled", "1", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_hud_damage_temperature_enabled", "1", {FCVAR_ARCHIVE}, "" )
    
    concommand.Add("mdisasters_setwind", function(cmd, args, wind)
        local speed = wind[1]
        mdisasters.weather.Wind.speed = tonumber(speed)
    end)

    concommand.Add("mdisasters_setwind_direction", function(cmd, args, wind)
        local direction = Vector(tonumber(wind[1]), tonumber(wind[2]), tonumber(wind[3]))
        mdisasters.weather.Wind.dir  = direction
    end)


    concommand.Add("mdisasters_setbody_temp", function(cmd, args, temp)
        for k, v in pairs(player.GetAll()) do
            local temperature = temp[1]
            v.mdisasters.body.Temperature = tonumber(temperature)
        
        end
    end)

    concommand.Add("mdisasters_setbody_oxygen", function(cmd, args, O2)
        for k, v in pairs(player.GetAll()) do
            local Oxygen = O2[1]
            v.mdisasters.body.Oxygen = tonumber(Oxygen)
        
        end
    end)

    concommand.Add("mdisasters_setpressure", function(cmd, args, pressure)
        local press = pressure[1]
        mdisasters.weather.Pressure = tonumber(press)
    end)

    concommand.Add("mdisasters_sethumidity", function(cmd, args, humidity)
        local humi =  humidity[1]
        mdisasters.weather.Humidity = tonumber(humi)
    end)

    concommand.Add("mdisasters_settemp", function(cmd, args, temp)
        local temperature = temp[1]
        mdisasters.weather.Temperature = tonumber(temperature)
    end)

end


hook.Add( "InitPostEntity", "mdisasters_convars_init_sh", convars)