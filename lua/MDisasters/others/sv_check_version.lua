
local CURRENT_VERSION = MDisasters.version  -- Versión actual del addon
local VERSION_CHECK_URL = "https://steamcommunity.com/sharedfiles/filedetails/?id=3447089470&tscn=1743507822"  -- Cambia esto por tu URL real

function MDisasters:CheckForUpdates()
    http.Fetch(VERSION_CHECK_URL,
        function(body, len, headers, code)
            if code == 200 then
                local latestVersion = string.match(body, CURRENT_VERSION)
                if latestVersion ~= CURRENT_VERSION then
                    MDisasters:msg("Nueva versión disponible: " .. latestVersion .. " (Actualmente: " .. CURRENT_VERSION .. ")")
                    net.Start("md_VersionCheck")
                    net.WriteString(latestVersion)
                    net.Broadcast()
                else
                    MDisasters:msg("MDisasters está actualizado.")
                end
            else
                MDisasters:error("Error al comprobar la versión (Código: " .. code .. ")")
            end
        end,
        function(error)
            MDisasters:error("Falló la comprobación de versión: " .. error)
        end
    )
end

hook.Add("Initialize", "md_CheckVersion", MDisasters:CheckForUpdates())
timer.Create("md_VersionCheckTimer", 3600, 0, MDisasters:CheckForUpdates) -- Verifica cada hora
