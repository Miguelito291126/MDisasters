-- Verifica si el mapa está registrado
function MDisasters_IsMapRegistered()
    local worldEnts = ents.FindByClass("worldspawn")
    MDisasters:msg("Worldspawn entities found: " .. #worldEnts)

    return #worldEnts > 0
end

function MDisasters_getMapBounds()
    if not MDisasters_IsMapRegistered() then
        MDisasters:error("Este mapa no tiene límites registrados.")
        return nil
    end

    -- Obtener límites del mundo
    local minVector, maxVector = game.GetWorld():GetModelBounds()
    MDisasters:msg("Límites: Min " .. tostring(minVector) .. " | Max " .. tostring(maxVector))

    if not minVector or not maxVector then
        MDisasters:error("GetModelBounds() devolvió valores nulos.")
        return nil
    end

    -- Obtener el primer "info_player_start" en el mapa
    local playerStart = ents.FindByClass("info_player_start")[1]
    if not playerStart then
        MDisasters:error("No se encontró un info_player_start en el mapa.")
        return nil
    end

    -- Obtener la posición de "info_player_start"
    local startPos = playerStart:GetPos()

    -- Ajustar endPos para asegurar que esté un poco por debajo de startPos
    local traceDistance = 1000  -- Distancia suficientemente larga para alcanzar el suelo
    local endPos = startPos - Vector(0, 0, traceDistance)  -- Desplazar hacia abajo

    MDisasters:msg("Posición de info_player_start: " .. tostring(startPos))

    -- Hacer un trace desde el "info_player_start" hacia abajo
    local traceParams = {
        start = startPos + Vector(0, 0, 10),  -- Iniciar un poco por encima de info_player_start
        endpos = endPos,  -- Finalizar un poco por debajo
        mask = MASK_SOLID_BRUSHONLY,
        filter = playerStart  -- Asegurarse de que el rayo no se detenga en el info_player_start
    }
    local traceResult = util.TraceLine(traceParams)

    -- Si el trazo detecta algo, usar esa posición como el suelo
    local groundPosition = traceResult.HitPos
    if not groundPosition then
        MDisasters:error("No se encontró un suelo bajo el info_player_start.") 
        return nil 
    end
    
    MDisasters:msg("Posición del suelo detectada en: " .. tostring(groundPosition))

    return { minVector, maxVector, groundPosition }
end



function MDisasters_getMapCeiling()
    if not MDisasters_IsMapRegistered() then 
        MDisasters:error("This map has no Ceiling") 
        return nil 
    end

    return MDisasters_getMapBounds()[2].z
end

-- Obtén la caja del cielo del mapa
function MDisasters_getMapSkyBox()
    if not MDisasters_IsMapRegistered() then 
        MDisasters:error("This map has no SkyBox") 
        return nil 
    end 

    local bounds = MDisasters_getMapBounds()
    local min = bounds[1]
    local max = bounds[2]

    -- Asegurarse de que las coordenadas del cielo estén dentro del mapa
    return { Vector(min.x, min.y, max.z), Vector(max.x, max.y, max.z) }
end

-- Obtén la posición central del mapa
function MDisasters_getMapCenterPos()
    if not MDisasters_IsMapRegistered() then 
        MDisasters:error("This map has no CenterPos") 
        return nil 
    end

    local bounds = MDisasters_getMapBounds()
    local av = (bounds[1] + bounds[2]) / 2

    -- Asegúrate de que la posición central esté dentro del mapa
    return av
end

-- Obtén la posición central del suelo del mapa
function MDisasters_getMapCenterFloorPos()
    if not MDisasters_IsMapRegistered() then 
        MDisasters:error("This map has no FloorPos") 
        return nil 
    end

    return MDisasters_getMapBounds()[3]
end
