MDisasters = {}
MDisasters.name = "MDisasters"
MDisasters.author = "Miguelillo948"
MDisasters.version = "0.0.2.2"

function MDisasters:msg(...)
    local args = {...}
    local output = ""

    for i, v in ipairs(args) do
        if istable(v) then
            output = output .. util.TableToJSON(v, true) .. " "
        else
            output = output .. tostring(v) .. " "
        end
    end

    -- Determinar el color según el entorno
    local prefixColor = Color(255, 255, 255) -- Blanco por defecto

    if SERVER then
        prefixColor = Color(0, 150, 255)  -- Azul (Servidor)
    elseif CLIENT then
        prefixColor = Color(255, 255, 0)  -- Amarillo (Cliente)
    else
        prefixColor = Color(0, 255, 0)  -- Verde (Shared)
    end

    MsgC(prefixColor, "[MDisasters][Debug] ", Color(255, 255, 255), output .. "\n")
end

function MDisasters:error(...)
    local args = {...}
    local output = ""

    for i, v in ipairs(args) do
        if istable(v) then
            output = output .. util.TableToJSON(v, true) .. " "
        else
            output = output .. tostring(v) .. " "
        end
    end

    -- Determinar el color según el entorno
    local prefixColor = Color(255, 255, 255) -- Blanco por defecto

    if SERVER then
        prefixColor = Color(0, 100, 255)  -- Azul oscuro (Servidor)
    elseif CLIENT then
        prefixColor = Color(255, 200, 0)  -- Naranja (Cliente)
    else
        prefixColor = Color(0, 255, 0)  -- Verde (Shared)
    end

    MsgC(prefixColor, "[MDisasters][Error] ", Color(255, 0, 0), output .. "\n")
end

local LuaDirectory = "MDisasters"


function MDisasters:AddLuaFile(File, directory)
    local prefix = string.lower(File)

    if prefix:StartWith("sv_") or prefix:StartWith("_sv_") then
        if SERVER then
            include(directory .. File)
            MDisasters:msg("Server Include file: " .. File)
        end
    elseif prefix:StartWith("sh_") or prefix:StartWith("_sh_") then
        if SERVER then
            AddCSLuaFile(directory .. File)
            MDisasters:msg("Shared ADDC file: " .. File)
        end
        if not SERVER or not CLIENT then
            include(directory .. File)
            MDisasters:msg("Shared Include file: " .. File)
        end
    elseif prefix:StartWith("cl_") or prefix:StartWith("_cl_") then
        if SERVER then
            AddCSLuaFile(directory .. File)
            MDisasters:msg("Client ADDC file: " .. File)
        elseif CLIENT then
            include(directory .. File)
            MDisasters:msg("Client Include file: " .. File)
        end
    end
end



function MDisasters:LoadLuaFiles(directory)
    directory = directory .. "/"

    local files, directories = file.Find(directory .. "*", "LUA")

    for _, v in ipairs(files) do
        if string.EndsWith(v, ".lua") then
            MDisasters:AddLuaFile(v, directory)
        end
    end

    for _, v in ipairs(directories) do
        MDisasters:msg("Included Directory: " .. v)
        MDisasters:LoadLuaFiles(directory .. v)
    end
end


MDisasters:LoadLuaFiles(LuaDirectory)
 

local ParticlesDirectory = "particles/MDisasters"

function MDisasters:AddParticlesFile( File, directory )
	game.AddParticles(directory .. File)
    MDisasters:msg("Added File: " .. File)
end

function MDisasters:loadParticles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".pcf" ) then
			MDisasters:AddParticlesFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		MDisasters:msg("Included Directory: " .. v)
		MDisasters:loadParticles( directory .. v )
	end
end


MDisasters:loadParticles( ParticlesDirectory )

local DecalsDirectory = "materials/decals/MDisasters"

function MDisasters:AddDecalsFile(Key, File, directory)
    -- Extraemos el nombre base, ignorando cualquier número al final y la extensión
    local baseName = File:match("(.+)_?%d*%.")  -- Ahora esta expresión regular también captura casos con guiones bajos o sin ellos y elimina los números

    local decalPath = "decals/MDisasters/" .. baseName
    
    -- Imprime el decal cargado
    MDisasters:msg("Adding decal: " .. decalPath)
    
    -- Agregar decal
    game.AddDecal(baseName, decalPath)

    -- Puedes aplicar más lógica para manejar diferentes tipos de decals si es necesario
end

function MDisasters:loadDecalsFiles(directory)
    directory = directory .. "/"

    local files, directories = file.Find(directory .. "*", "THIRDPARTY")

    for _, v in ipairs(files) do
        -- Solo cargamos imágenes válidas
        if string.EndsWith(v, ".vtf") or string.EndsWith(v, ".png") then
            MDisasters:AddDecalsFile(_, v, directory)
        end
    end

    for _, v in ipairs(directories) do
        MDisasters:msg("Directory: " .. v)
        MDisasters:loadDecalsFiles(directory .. v)
    end
end

MDisasters:loadDecalsFiles( ParticlesDirectory )

PrecacheParticleSystem("meteor_trail")
PrecacheParticleSystem("volcano_trail")
PrecacheParticleSystem("tornado")
PrecacheParticleSystem("volcano_explosion")
PrecacheParticleSystem("rain_effect")
PrecacheParticleSystem("rain_effect_ground")
PrecacheParticleSystem("snow_effect")
PrecacheParticleSystem("lightning_strike")


MDisasters:msg("MDisasters Loaded")
