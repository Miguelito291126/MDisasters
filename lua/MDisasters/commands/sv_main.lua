function convars()
    CreateConVar( "MDisasters_tornado_speed", "10", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_tornado_force", "6000", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_tornado_radius", "3000", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_tornado_time", "100", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_earthquake_radius", "1500", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_earthquake_force", "150", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_earthquake_player_force", "1500", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_earthquake_shake_force", "15", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_earthquake_time", "100", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_volcano_time", "200", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_tsunami_force", "5000", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_tsunami_velocity", "5000", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_tsunami_radius", "10000", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "MDisasters_tsunami_offset", "0", {FCVAR_ARCHIVE}, "" )

end


hook.Add( "InitPostEntity", "MDisasters_convars_init_sv", convars)