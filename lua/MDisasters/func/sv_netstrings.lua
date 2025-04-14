util.AddNetworkString( "md_clmenu_vars" )
util.AddNetworkString( "md_isOutdoor" )
util.AddNetworkString("md_clparticles")
util.AddNetworkString("md_clparticles_ground")
util.AddNetworkString("md_sendsound")
util.AddNetworkString("md_sendloopsound")
util.AddNetworkString("md_stopsound")
util.AddNetworkString("md_stoploopsound")
util.AddNetworkString("md_maplight_cl")
util.AddNetworkString("md_ambientlight")
util.AddNetworkString("md_VersionCheck")

net.Receive( "md_clmenu_vars", function( len, pl )
	if !pl:IsAdmin() or !pl:IsSuperAdmin() then return end
	
	local cvar = net.ReadString();
	local val = net.ReadFloat();

	if( GetConVar( tostring( cvar ) ) == nil ) then return end
	if( GetConVar( tostring( cvar ) ):GetInt() == tonumber( val ) ) then return end

	game.ConsoleCommand( tostring( cvar ) .." ".. tostring( val ) .."\n" );
end)

