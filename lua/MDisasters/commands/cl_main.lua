function convars()
    CreateConVar( "MDisasters_hud_enabled", "1", {FCVAR_ARCHIVE}, "" )
end


hook.Add( "InitPostEntity", "MDisasters_convars_cl", convars)