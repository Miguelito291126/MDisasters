MDisasters_time = CurTime()

local function AddControlCB(CPanel, label, command)
	return CPanel:CheckBox( label, command )
end
local function AddControlLabel( CPanel, label )
	return  CPanel:Help( language.GetPhrase(label) )
end
local function AddControlSlider( CPanel, label, command, min, max, dp  )
	return  CPanel:NumSlider( label, command, min, max, dp );
end

local function AddComboBox( CPanel, title, listofitems, convar)
		
	local combobox, label = CPanel:ComboBox( language.GetPhrase(title), convar)
		
		
	for k, item in pairs(listofitems) do
		combobox:AddChoice(item)
	end
		
	return combobox
end
	
local function CreateTickboxConVariable(CPanel, desc, convarname)
	local CB = AddControlCB(CPanel, language.GetPhrase(desc), convarname)
	
 
	CB.OnChange = function( panel, bVal ) 
		if (CurTime() - MDisasters_time) < 1 then return end 

		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( convarname ) ) then return end
			net.Start( "md_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
			
			timer.Simple(0.1, function()
				if( CB ) then
					CB:SetValue( GetConVar(( convarname )):GetFloat() );
				end
			end)
		end
	end

	
	return CB 
	
end

local function CreateSliderConVariable(CPanel, desc, minvar, maxvar, dp, convarname)
	local CB = AddControlSlider( CPanel, language.GetPhrase(desc), convarname, minvar, maxvar, dp  )
	

	CB.OnValueChanged = function( panel, val )
		if (CurTime() - MDisasters_time) < 1 then return end 
		
		
		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and !Created ) then
			if ( tonumber(val) ) == cvars.Number( convarname )  then return end
			net.Start( "md_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat( tonumber(val) );
			net.SendToServer();
			
			timer.Simple(0.1, function()
				
				if( CB ) then
					CB:SetValue( GetConVar(( convarname )):GetFloat() );
				end
			end)
		end
		
	end

	
	return CB
end

local function MDisastersSettings( CPanel )
    CreateTickboxConVariable(CPanel, "Enable Oxygen" ,"MDisasters_hud_oxygen_enabled");
    CreateTickboxConVariable(CPanel, "Enable Temp" ,"MDisasters_hud_temperature_enabled");
    CreateTickboxConVariable(CPanel, "Enable Oxygen Damage" ,"MDisasters_hud_damage_oxygen_enabled");
    CreateTickboxConVariable(CPanel, "Enable Temp Damage" ,"MDisasters_hud_damage_temperature_enabled");
end

local function MDisastersSettingsClient( CPanel )
    CreateTickboxConVariable(CPanel, "Enable Hud" ,"MDisasters_hud_enabled");
end

local function MDisastersSettingsServer( CPanel )
	CreateSliderConVariable(CPanel, "Tornado Speed", 0, 10000, 0, "MDisasters_tornado_speed")
	CreateSliderConVariable(CPanel, "Tornado Radius", 0, 10000, 0, "MDisasters_tornado_radius")
	CreateSliderConVariable(CPanel, "Tornado Force", 0, 10000, 0, "MDisasters_tornado_force")
	CreateSliderConVariable(CPanel, "Tornado Remove Time", 0, 10000, 0, "MDisasters_tornado_time")
	CreateSliderConVariable(CPanel, "Earthquake Force", 0, 10000, 0, "MDisasters_earthquake_force")
	CreateSliderConVariable(CPanel, "Earthquake Remove Time", 0, 10000, 0, "MDisasters_earthquake_time")
	CreateSliderConVariable(CPanel, "Earthquake Shake Force", 0, 10000, 0, "MDisasters_earthquake_shake_force")
	CreateSliderConVariable(CPanel, "Volcano Time", 0, 10000, 0, "MDisasters_volcano_time")
	CreateSliderConVariable(CPanel, "Tornado Constrains Damage", 0, 10000, 0, "MDisasters_tornado_constraints_damage")
	CreateSliderConVariable(CPanel, "Tsunami Force", 0, 10000, 0, "MDisasters_tsunami_force")
	CreateSliderConVariable(CPanel, "Tsunami Velocity", 0, 10000, 0, "MDisasters_tsunami_velocity")
	CreateSliderConVariable(CPanel, "Tsunami offset", -10000, 10000, 0, "MDisasters_tsunami_offset")
end

hook.Add( "AddToolMenuTabs", "MDisasters_Tab", function()
	spawnmenu.AddToolTab( "MDisasters", "#MDisasters", "icon16/weather_clouds.png" )
end)

hook.Add( "PopulateToolMenu", "MDisasters_PopulateMenu", function()
	

	spawnmenu.AddToolMenuOption( "MDisasters", "Shared", "MDisastersSettings", "Main", "", "", MDisastersSettings )
	spawnmenu.AddToolMenuOption( "MDisasters", "Server", "MDisastersSettingsServer", "Main", "", "", MDisastersSettingsServer )
    spawnmenu.AddToolMenuOption( "MDisasters", "Client", "MDisastersSettingsClient", "Main", "", "", MDisastersSettingsClient )


end );
