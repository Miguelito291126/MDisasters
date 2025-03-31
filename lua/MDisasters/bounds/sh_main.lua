-- Verifica si el mapa está registrado
function MDisasters_IsMapRegistered()
    local worldEnts = ents.FindByClass("worldspawn")
    MDisasters:msg(" Worldspawn entities found: " .. #worldEnts)

    if #worldEnts > 0 then
        return true
    else 
        return false
    end 
end

function MDisasters_getMapBounds()
    if not MDisasters_IsMapRegistered() then
        MDisasters:error("This map has no bounds")
        return nil
    end

    -- Intentar obtener los límites del mundo
    local minVector, maxVector = game.GetWorld():GetModelBounds()
	MDisasters:msg(" Raw Map Bounds: Min " .. tostring(minVector) .. " | Max " .. tostring(maxVector))

    if not minVector or not maxVector then
        MDisasters:error("GetModelBounds() returned nil values")
        return nil
    end

    -- Asegurar que las coordenadas no sean extremas
    local adjustedMin = Vector(math.max(minVector.x, -16384), math.max(minVector.y, -16384), math.max(minVector.z, -16384))
    local adjustedMax = Vector(math.min(maxVector.x, 16384), math.min(maxVector.y, 16384), math.min(maxVector.z, 16384))

    -- Realizar un trace para encontrar el suelo
    local startpos = Vector(0, 0, maxVector.z - 500)
    local traceParams = {
        start = startpos,
        endpos = adjustedMin,
        filter = function(ent) return ent:IsWorld() end
    }
    
    local traceResult = util.TraceLine(traceParams)
    
    if not traceResult.Hit or not traceResult.HitPos then
        MDisasters:error("TraceLine() did not hit the ground")
        return nil
    end

    local groundPosition = traceResult.HitPos
    MDisasters:msg(" Ground position detected at: " .. tostring(groundPosition))

    return { adjustedMin, adjustedMax, groundPosition }
end

-- Obtén el techo del mapa
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
