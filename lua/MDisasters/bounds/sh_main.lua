-- Verifica si el mapa está registrado
function MDisasters_IsMapRegistered()
    local worldEnts = ents.FindByClass("worldspawn")
    MDisasters:msg("Worldspawn entities found: " .. #worldEnts)

    if #worldEnts > 0 then
        return true
    else 
        return false
    end 
end

function MDisasters_getMapBounds()
    if not MDisasters_IsMapRegistered() then
        MDisasters:error("Este mapa no tiene límites registrados.")
        return nil
    end

    -- Obtener límites del mundo
    local minVector, maxVector = game.GetWorld():GetModelBounds()
    MDisasters:msg("Límites sin procesar: Min " .. tostring(minVector) .. " | Max " .. tostring(maxVector))

    if not minVector or not maxVector then
        MDisasters:error("GetModelBounds() devolvió valores nulos.")
        return nil
    end

    -- Obtener el spawn del jugador
    local spawnPos = Vector(0, 0, 0)  -- Fallback por si no hay jugadores
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsValid() and ply:Alive() then
            spawnPos = ply:GetPos()
            break
        end
    end

    MDisasters:msg("Usando spawn del jugador en: " .. tostring(spawnPos))

    -- Función para hacer trazos a los límites del mundo
    local function TraceToBounds(targetPos)
        local traceParams = {
            start = spawnPos,
            endpos = targetPos,
            mask = MASK_SOLID_BRUSHONLY
        }
        local traceResult = util.TraceLine(traceParams)
        return traceResult.Hit and traceResult.HitPos or targetPos
    end

    -- Ajustar límites con trazos
    local adjustedMin = TraceToBounds(minVector)
    local adjustedMax = TraceToBounds(maxVector)

    MDisasters:msg("Límites ajustados: Min " .. tostring(adjustedMin) .. " | Max " .. tostring(adjustedMax))

    -- Trazar hacia abajo para encontrar el suelo
    local traceParams = {
        start = Vector(spawnPos.x, spawnPos.y, spawnPos.z),
        endpos = Vector(spawnPos.x, spawnPos.y, minVector.z),
        mask = MASK_SOLID_BRUSHONLY
    }
    local traceResult = util.TraceLine(traceParams)

    if not traceResult.Hit then
        MDisasters:error("No se pudo detectar el suelo, usando fallback.")
        traceResult.HitPos = Vector(spawnPos.x, spawnPos.y, minVector.z)  -- Fallback
    end

    local groundPosition = traceResult.HitPos
    MDisasters:msg("Posición del suelo detectada en: " .. tostring(groundPosition))

    return { adjustedMin, adjustedMax, groundPosition }
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
