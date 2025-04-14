
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

function MDisasters:PrecacheAllMaterials(directory)
    local files, directories = file.Find(directory .. "*", "GAME")

    for _, materials in ipairs(files) do
        if string.EndsWith(materials, ".vmt") then
            local materialPath = directory .. materials
            Material(materials) -- Forzar carga en el cliente
            MDisasters:msg("Precaching material: " .. materialPath)
        end
    end

    for _, dir in ipairs(directories) do
        MDisasters:PrecacheAllMaterials(directory .. dir .. "/")
    end
end

-- 📌 Ejecutar Precache en el Servidor
MDisasters:PrecacheAllModels("models/disasters/")  -- Ajusta según tu addon
MDisasters:PrecacheAllSounds("sound/disasters/")  -- Ajusta según tu addon
MDisasters:PrecacheAllSounds("sound/weather/")  -- Ajusta según tu addon
MDisasters:PrecacheAllMaterials("materials/hd/")  -- Ajusta según tu addon
MDisasters:PrecacheAllMaterials("materials/hd2/")  -- Ajusta según tu addon



