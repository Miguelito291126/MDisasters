-- 📌 Función para registrar todas las entidades y armas en el menú de MDisasters
function MDisasters:RegisterAllEntitiesAndWeapons()
    local entityClasses = {}
    local weaponClasses = {}

    -- 📂 Buscar todas las entidades en "entities/"
    local entityFiles, entityFolders = file.Find("entities/*", "LUA")
    for _, fileName in ipairs(entityFiles) do
        if fileName:StartsWith("md_disasters") then 
            local className = fileName:gsub("%.lua$", "") -- Quitar extensión .lua
            local displayName = className:gsub("md_", ""):gsub("_", " "):gsub("disasters", "")

            table.insert(entityClasses, { name = displayName, class = className, category = "Disasters" })
        elseif fileName:StartsWith("md_weather") then
            local className = fileName:gsub("%.lua$", "") -- Quitar extensión .lua
            local displayName = className:gsub("md_", ""):gsub("_", " "):gsub("weather", "")

            table.insert(entityClasses, { name = displayName, class = className, category = "Weather" })
        end 

    end

    -- 📂 Buscar todas las armas en "weapons/"
    local weaponFiles, weaponFolders = file.Find("weapons/*", "LUA")
    for _, fileName in ipairs(weaponFiles) do
        if string.StartsWith(fileName, "md_weapons") then 
            local className = fileName:gsub("%.lua$", "") -- Quitar extensión .lua
            local displayName = className:gsub("md_", ""):gsub("_", " "):gsub("weapons", "")

            table.insert(weaponClasses, { name = displayName, class = className, category = "Weapons" })
        end
    end

    -- 🔄 Registrar entidades
    for _, ent in ipairs(entityClasses) do
        AddMDisastersSpawn(ent.name, ent.class, ent.category, true)
    end

    -- 🔄 Registrar armas
    for _, wep in ipairs(weaponClasses) do
        AddMDisastersSpawn(wep.name, wep.class, wep.category, false)
    end

    MDisasters:msg("Se han registrado automáticamente " .. #entityClasses .. " entidades y " .. #weaponClasses .. " armas en el menú.")
end

-- 📌 Ejecutar el registro en la carga del servidor
hook.Add("Initialize", "MDisasters_AutoRegister", function()
    MDisasters:RegisterAllEntitiesAndWeapons()
end)
