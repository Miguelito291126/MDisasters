MDisasters = {}
MDisasters.name = "MDisasters"
MDisasters.author = "Miguelillo948"
MDisasters.version = "0.0.2.2"

function msg(...)
    local args = {...}
    local output = ""

    for i, v in ipairs(args) do
        if istable(v) then
            output = output .. util.TableToJSON(v, true) .. " "  -- Convierte la tabla a JSON legible
        else
            output = output .. tostring(v) .. " "
        end
    end

    MsgC(Color(43,255,0), "[MDisasters][Debug] ", Color(255,255,255), output .. "\n")
end

function error(...)
    local args = {...}
    local output = ""

    for i, v in ipairs(args) do
        if istable(v) then
            output = output .. util.TableToJSON(v, true) .. " "
        else
            output = output .. tostring(v) .. " "
        end
    end

    MsgC(Color(43,255,0), "[MDisasters][Error] ", Color(255,0,0), output .. "\n")
end

local LuaDirectory = "MDisasters"

local function AddLuaFile( File, directory )
	local prefix = string.lower(File)

	if prefix:StartWith("sv_") or  prefix:StartWith("_sv_") then
		if (SERVER) then
			include( directory .. File )
        	msg("Server Include file: " .. File)
		end
	elseif prefix:StartWith("sh_") or  prefix:StartWith("_sh_") then
		if (SERVER) then
			AddCSLuaFile( directory .. File )
			msg("Shared ADDC file: " .. File)
		end
		include( directory .. File )
		msg("Shared Include file: " .. File)
	elseif prefix:StartWith("cl_") or  prefix:StartWith("_cl_")then
		if (SERVER) then
			AddCSLuaFile( directory .. File )
			msg("Client ADDC file: " .. File)
		elseif (CLIENT) then
			include( directory .. File )
			msg("Client Include file: " .. File)
		end
	end
end

local function LoadLuaFiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddLuaFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		msg("Included Directory:" .. v)
		LoadLuaFiles( directory .. v )
	end
end

LoadLuaFiles( LuaDirectory )

local ParticlesDirectory = "particles/MDisasters"

local function AddParticlesFile( File, directory )
	game.AddParticles(directory .. File)
    msg("Added File: " .. File)
end

local function loadParticles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".pcf" ) then
			AddParticlesFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		msg("Included Directory: " .. v)
		loadParticles( directory .. v )
	end
end

loadParticles( ParticlesDirectory )



local DecalsDirectory = "materials/decals/MDisasters"

local function AddDecalsFile(Key, File, directory)
    -- Extraemos el nombre base, ignorando cualquier número al final y la extensión
    local baseName = File:match("(.+)_?%d*%.")  -- Ahora esta expresión regular también captura casos con guiones bajos o sin ellos y elimina los números

    local decalPath = "decals/MDisasters/" .. baseName
    
    -- Imprime el decal cargado
    msg("Adding decal: " .. decalPath)
    
    -- Agregar decal
    game.AddDecal(baseName, decalPath)

    -- Puedes aplicar más lógica para manejar diferentes tipos de decals si es necesario
end

local function loadDecalsFiles(directory)
    directory = directory .. "/"

    local files, directories = file.Find(directory .. "*", "THIRDPARTY")

    for _, v in ipairs(files) do
        -- Solo cargamos imágenes válidas
        if string.EndsWith(v, ".vtf") or string.EndsWith(v, ".png") then
            AddDecalsFile(_, v, directory)
        end
    end

    for _, v in ipairs(directories) do
        msg("Directory: " .. v)
        loadDecalsFiles(directory .. v)
    end
end

loadDecalsFiles(DecalsDirectory)

PrecacheParticleSystem("meteor_trail")
PrecacheParticleSystem("volcano_trail")
PrecacheParticleSystem("tornado")
PrecacheParticleSystem("volcano_explosion")
PrecacheParticleSystem("rain_effect")
PrecacheParticleSystem("rain_effect_ground")
PrecacheParticleSystem("snow_effect")
PrecacheParticleSystem("lightning_strike")


msg("MDisasters Loaded")
