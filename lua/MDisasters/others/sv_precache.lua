
-- 🔹 Registrar el mensaje de red antes de usarlo


-- 📌 Función para precachear modelos
function MDisasters:PrecacheAllModels(directory)
    local files, directories = file.Find(directory .. "*", "GAME")

    for _, model in ipairs(files) do
        if string.EndsWith(model, ".mdl") then
            local modelPath = directory .. model
            util.PrecacheModel(modelPath)
            MDisasters:msg("Precaching model: " .. modelPath)
        end
    end

    for _, dir in ipairs(directories) do
        MDisasters:PrecacheAllModels(directory .. dir .. "/")
    end
end

-- 📌 Función para precachear sonidos
function MDisasters:PrecacheAllSounds(directory)
    local files, directories = file.Find(directory .. "*", "GAME")

    for _, sound in ipairs(files) do
        if string.EndsWith(sound, ".wav") or string.EndsWith(sound, ".mp3") or string.EndsWith(sound, ".ogg") then
            local soundPath = directory .. sound
            util.PrecacheSound(soundPath)
            MDisasters:msg("Precaching sound: " .. soundPath)
        end
    end

    for _, dir in ipairs(directories) do
        MDisasters:PrecacheAllSounds(directory .. dir .. "/")
    end
end

-- 📌 Enviar lista de materiales al cliente para precachearlos manualmente
function MDisasters:GetAllMaterials(directory)
    local files, directories = file.Find(directory .. "*", "GAME")
    local materials = {}

    for _, mat in ipairs(files) do
        if string.EndsWith(mat, ".vmt") then
            table.insert(materials, string.gsub(directory .. mat, "materials/", ""))
        end
    end

    for _, dir in ipairs(directories) do
        table.Add(materials, MDisasters:GetAllMaterials(directory .. dir .. "/"))
    end

    return materials
end

-- 📌 Enviar lista de materiales al cliente
hook.Add("PlayerInitialSpawn", "SendMDisastersMaterials", function(ply)
    local materials = MDisasters:GetAllMaterials("materials/disasters/") -- Ajusta la ruta si es necesario

    net.Start("md_PrecacheMaterials")
    net.WriteTable(materials)
    net.Send(ply)
end)

-- 📌 Ejecutar Precache en el Servidor
MDisasters:PrecacheAllModels("models/disasters/")  -- Ajusta según tu addon
MDisasters:PrecacheAllSounds("sound/disasters/")  -- Ajusta según tu addon
