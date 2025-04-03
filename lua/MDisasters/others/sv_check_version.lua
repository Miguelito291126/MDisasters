local VERSION_CHECK_URL = "https://steamcommunity.com/sharedfiles/filedetails/?id=3447089470&tscn=1743507822"  -- URL del archivo con la versión

function MDisasters:CheckForUpdates()
    http.Fetch(VERSION_CHECK_URL,
        function(body, len, headers, code)
            if code == 200 then
                -- Buscar la versión en el texto usando una expresión regular
                local latestVersion = string.match(body, "v?(%d+%.%d+%.%d+%.?%d*)")  -- Encuentra la primera secuencia de números y puntos, opcionalmente precedida por 'v'
                if latestVersion then
                    if latestVersion ~= MDisasters.version then
                        MDisasters:msg("Nueva versión disponible: " .. latestVersion .. " (Actualmente: " .. MDisasters.version .. ")")
                        net.Start("md_VersionCheck")
                        net.WriteString(latestVersion)
                        net.Broadcast()
                    else
                        MDisasters:msg("MDisasters está actualizado.")
                    end
                else
                    MDisasters:error("No se pudo extraer la versión del archivo.")
                end
            else
                MDisasters:error("Error al comprobar la versión (Código HTTP: " .. code .. ")")
            end
        end,
        function(error)
            MDisasters:error("Falló la comprobación de versión: " .. error)
        end
    )
end

hook.Add("Initialize", "md_CheckVersion", function() MDisasters:CheckForUpdates() end)
timer.Create("md_VersionCheckTimer", 3600, 0, function() MDisasters:CheckForUpdates() end) -- Verifica cada hora
