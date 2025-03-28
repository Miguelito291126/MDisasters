spawnmenu.AddCreationTab("MDisasters", function()
    local ctrl = vgui.Create("SpawnmenuContentPanel")
    ctrl:CallPopulateHook("HookDisasters")
    ctrl:CallPopulateHook("HookWeather")
    ctrl:CallPopulateHook("HookWeapons")
    return ctrl
    end, "icon16/weather_clouds.png", 30
)

function AddMDisastersSpawn(name, class, category, adminonly)
	if category == "Disasters" then 
		list.Set( "MD_Disasters", class, {
			Name = name, 
			Class = class, 
			Category = category, 
			AdminOnly = adminonly, 
			Offset = 0
		})
	elseif category == "Weather" then 
		list.Set( "MD_Weather", class, {
			Name = name,
			Class = class, 
			Category = category, 
			AdminOnly = adminonly, 
            Offset = 0
		})
	elseif category == "Weapons" then 
		list.Set( "Weapon", class, {
			Name = name,
			Class = class, 
			Category = category, 
			AdminOnly = adminonly, 
			Spawnable = true,
		})
		list.Set( "MD_Weapons", class, {
			Name = name,
			Class = class, 
			Category = category, 
			AdminOnly = adminonly,
			Spawnable = true,
		})
	end
end

hook.Add( "HookWeather", "MDisasters_AddWeatherContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("Weather", "icon16/weather_rain.png")
    local WeatherCategory = {}
    local SpawnableWeatherList = list.Get("MD_Weather")

    if (SpawnableWeatherList) then
        for k, v in pairs(SpawnableWeatherList) do
            WeatherCategory[v.Category] = WeatherCategory[v.Category] or {}
            table.insert(WeatherCategory[v.Category], v)
        end
    end

    for CategoryName, v in SortedPairs(WeatherCategory) do 
        dtree.DoPopulate = function( self )

            if ( self.PropPanel ) then return end

            dtree.PropPanel = vgui.Create("ContentContainer", pnlContent)
            dtree.PropPanel:SetVisible(false)
            dtree.PropPanel:SetTriggerSpawnlistChange(false)

            for name, ent in SortedPairsByMemberValue(  v, "PrintName" ) do
                
                spawnmenu.CreateContentIcon( "entity", self.PropPanel, 
                { 
                    nicename	= ent.PrintName or ent.Name,
                    spawnname	= ent.Class,
                    material	= "entities/" .. ent.Class .. ".png",
                    admin		= ent.AdminOnly or false
                })
                
            end

        end

        dtree.DoClick = function( self )

            self:DoPopulate()		
            pnlContent:SwitchPanel( self.PropPanel )

        end
    end

end )

hook.Add( "HookDisasters", "MDisasters_AddDisastersContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("Disasters", "icon16/weather_lightning.png")
    local DisastersCategory = {}
    local SpawnableDisasterList = list.Get("MD_Disasters")

    if (SpawnableDisasterList) then
        for k, v in pairs(SpawnableDisasterList) do
            DisastersCategory[v.Category] = DisastersCategory[v.Category] or {}
            table.insert(DisastersCategory[v.Category], v)
        end
    end

    for CategoryName, v in SortedPairs(DisastersCategory) do 
        dtree.DoPopulate = function( self )
            
            if ( self.PropPanel ) then return end

            self.PropPanel = vgui.Create("ContentContainer", pnlContent)
            self.PropPanel:SetVisible(false)
            self.PropPanel:SetTriggerSpawnlistChange(false)

            for name, ent in SortedPairsByMemberValue(  v, "PrintName" ) do
                
                spawnmenu.CreateContentIcon( "entity", self.PropPanel, 
                { 
                    nicename	= ent.PrintName or ent.Name,
                    spawnname	= ent.Class,
                    material	= "entities/" .. ent.Class .. ".png",
                    admin		= ent.AdminOnly or false
                })
                
            end

        end

        dtree.DoClick = function( self )

            self:DoPopulate()		
            pnlContent:SwitchPanel( self.PropPanel )

        end
    end



end )

hook.Add( "HookWeapons", "MDisasters_AddWeaponsContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("Weapons", "icon16/wrench.png")

    local WeaponsCategory = {}
    local SpawnableWeaponsList = list.Get("MD_Weapons")

    if SpawnableWeaponsList then
        for k, v in pairs(SpawnableWeaponsList) do
            WeaponsCategory[v.Category] = WeaponsCategory[v.Category] or {}
            table.insert(WeaponsCategory[v.Category], v)
        end
    end

    for CategoryName, v in SortedPairs(WeaponsCategory) do 
        dtree.DoPopulate = function( self )

            if ( self.PropPanel ) then return end

            dtree.PropPanel = vgui.Create("ContentContainer", pnlContent)
            dtree.PropPanel:SetVisible(false)
	        dtree.PropPanel:SetTriggerSpawnlistChange(false)

            for name, swep in SortedPairsByMemberValue(  v, "PrintName" ) do
                
                spawnmenu.CreateContentIcon( "weapon", self.PropPanel, 
                { 
                    nicename	= swep.PrintName or swep.Name,
                    spawnname	= swep.Class,
                    material	= "weapon/" .. swep.Class .. ".png",
                    admin		= swep.AdminOnly or false
                })
                
            end

        end

        dtree.DoClick = function( self )

            self:DoPopulate()		
            pnlContent:SwitchPanel( self.PropPanel )

        end
    end




end )