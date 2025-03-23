hook.Add("HUDPaint", "MDisasters_HUDPaint", function() 
    if not GetConVar("mdisasters_hud_enabled"):GetBool() then return end 

    local w, h = ScrW(), ScrH() 

    -- Clima global
    local temperature = math.Clamp(GetGlobalVector("temperature") or 0, -273.3, 273.3)
    local humidity = math.Clamp(GetGlobalVector("humidity") or 0, 0, 100)
    local pressure = math.Clamp(GetGlobalVector("pressure") or 1013, 950, 1050)
    local windSpeed = math.Clamp(GetGlobalVector("wind_speed") or 0, 0, 200)  -- km/h
    local windDir = GetGlobalVector("wind_dir")
    local windDirAngle = math.Round(math.NormalizeAngle(convert_VectorToAngle(windDir).y))   -- º

    -- Jugador
    local ply = LocalPlayer()
    local bodyTemp = math.Clamp(ply:GetNWFloat("BodyTemperature") or 37, 25, 45)
    local bodyOxy = math.Clamp(ply:GetNWFloat("BodyOxygen") or 100, 0, 100)

    -- Velocidad de viento local
    local localWind = math.Clamp(ply:GetNWFloat("BodyWind") or 0, 0, 200)  -- km/h
    local localWindPerc = localWind / 200

    -- Porcentajes globales
    local tempPerc = (temperature + 273.3) / 546.6 
    local humidPerc = humidity / 100
    local pressurePerc = (pressure - 950) / 100
    local windSpeedPerc = windSpeed / 200
    local windDirPerc = windDirAngle / 360
    local bodyTempPerc = (bodyTemp - 25) / 20
    local bodyOxyPerc = bodyOxy / 100

    -- Posiciones
    local baseX, baseY = 50, h - 450
    local barWidth, barHeight = 400, 20
    local spacing = 30

    -- Dibuja una barra
    local function drawBar(label, valueText, percent, yOffset, color)
        draw.RoundedBox(4, baseX, baseY + yOffset, barWidth, barHeight, Color(0, 0, 0, 180))
        draw.RoundedBox(4, baseX, baseY + yOffset, barWidth * percent, barHeight, color)
        draw.SimpleText(label .. ": " .. valueText, "DermaDefaultBold", baseX + barWidth + 10, baseY + yOffset + 2, Color(255,255,255,255), TEXT_ALIGN_LEFT)
    end

    -- Dibuja todas las barras
    drawBar("Temperature", math.Round(temperature,1) .. " ºC", tempPerc, 0, Color(255, 100, 100, 255))
    drawBar("Humidity", math.Round(humidity) .. " %", humidPerc, spacing, Color(100, 150, 255, 255))
    drawBar("Pressure", math.Round(pressure) .. " hPa", pressurePerc, spacing*2, Color(150, 255, 150, 255))
    drawBar("Wind Speed (Global)", math.Round(windSpeed) .. " km/h", windSpeedPerc, spacing*3, Color(200, 200, 255, 255))
    drawBar("Wind Dir", windDirAngle .. " º", windDirPerc, spacing*4, Color(200, 255, 200, 255))
    drawBar("Local Wind Speed", math.Round(localWind) .. " km/h", localWindPerc, spacing*5, Color(255, 255, 200, 255))
    drawBar("Body Temp", math.Round(bodyTemp,1) .. " ºC", bodyTempPerc, spacing*6, Color(255, 200, 100, 255))
    drawBar("Body Oxygen", math.Round(bodyOxy) .. " %", bodyOxyPerc, spacing*7, Color(150, 255, 255, 255))
end)
