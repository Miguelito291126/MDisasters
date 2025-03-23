function convars()
    CreateConVar( "mdisasters_tornado_speed", "10", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_tornado_force", "6000", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_tornado_radius", "3000", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_tornado_time", "100", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_earthquake_radius", "1500", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_earthquake_force", "150", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_earthquake_player_force", "1500", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_earthquake_shake_force", "15", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_earthquake_time", "100", {FCVAR_ARCHIVE}, "" )
    CreateConVar( "mdisasters_volcano_time", "200", {FCVAR_ARCHIVE}, "" )

end


hook.Add( "InitPostEntity", "mdisasters_convars_init_sv", convars)