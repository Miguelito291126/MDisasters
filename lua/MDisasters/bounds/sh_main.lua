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

    -- Hacer un trace desde arriba hasta abajo en el centro del mapa
    local midX = (minVector.x + maxVector.x) / 2
    local midY = (minVector.y + maxVector.y) / 2
    local traceParams = {
        start = Vector(midX, midY, maxVector.z), -- Un poco más alto para evitar fallos
        endpos = Vector(midX, midY, minVector.z), -- Un poco más bajo por seguridad
        mask = MASK_SOLID_BRUSHONLY
    }
    local traceResult = util.TraceLine(traceParams)

    local groundPosition = traceResult.Hit and traceResult.HitPos or Vector(midX, midY, minVector.z)
    
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
