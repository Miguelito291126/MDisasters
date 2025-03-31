function MDisasters_IsMapRegistered()
	local worldEnt = #ents.FindByClass("worldspawn")
	
	if worldEnt > 0 then
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

	local minVector, maxVector = game.GetWorld():GetModelBounds()
	local startpos = Vector(0, 0, maxVector.z - 500)
	local traceParams = {
		start = startpos,
		endpos = minVector,
		filter = function(ent) return ent:IsWorld() end
	}
	
	local traceResult = util.TraceLine(traceParams)

	local groundPosition = traceResult.HitPos

	return { Vector(maxVector.x, maxVector.y, minVector.z), Vector(minVector.x, minVector.y, maxVector.z), groundPosition}

end

function MDisasters_getMapCeiling()
	if MDisasters_IsMapRegistered()==false then MDisasters:error("This map no have Ceiling") return nil end 

	return MDisasters_getMapBounds()[2].z
end

function MDisasters_getMapSkyBox()
	if MDisasters_IsMapRegistered()==false then MDisasters:error("This map no have SkyBox") return nil end 
	local bounds = MDisasters_getMapBounds()
	local min    = bounds[1]
	local max    = bounds[2]

	return { Vector(min.x, min.y, max.z), Vector(max.x, max.y, max.z) }
end


function MDisasters_getMapCenterPos()
	if MDisasters_IsMapRegistered()==false then MDisasters:error("This map no have CenterPos") return nil end 

	local av         = ((MDisasters_getMapBounds()[1] + MDisasters_getMapBounds()[2])  / 2)
	return av
end

function MDisasters_getMapCenterFloorPos()
	if MDisasters_IsMapRegistered()==false then MDisasters:error("This map no have FloorPos") return nil end 

	return MDisasters_getMapBounds()[3]
end
