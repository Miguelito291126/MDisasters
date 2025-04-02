search.AddProvider(
	function(str)
		local results = {}
		local entities = {}

		local function searchList(lname, lctype)
			for k, v in pairs(list.Get(lname)) do
				v.ClassName = k
				v.PrintName = v.PrintName or v.Name
				v.ScriptedEntityType = lctype
				table.insert(entities, v)
			end
		end
		searchList("MD_Weapons", "weapon")
		searchList("MD_Disasters", "entity")
		searchList("MD_Weather", "entity")

		// searchList("VJBASE_SPAWNABLE_VEHICLES", "vehicle") -- vehicle (Not yet lol)
		for _, v in pairs(entities) do
			local name = v.PrintName
			local name_c = v.ClassName
			if (!name && !name_c) then continue end

			if ((name && name:lower():find(str, nil, true)) or (name_c && name_c:lower():find(str, nil, true))) then
				local entry = {
					text = v.PrintName or v.ClassName,
					icon = spawnmenu.CreateContentIcon(v.ScriptedEntityType or "entity", nil, {
						nicename = v.PrintName or v.ClassName,
						spawnname = v.ClassName,
						material = "entities/" .. v.ClassName .. ".png",
						admin = v.AdminOnly or false
					}),
					words = {v}
				}
				table.insert(results, entry)
			end
		end
		table.SortByMember(results, "text", true)
		return results
	end, "MDisastersSearch"

)

spawnmenu.AddCreationTab("MDisasters", function()
    local ctrl = vgui.Create("SpawnmenuContentPanel")
    ctrl:EnableSearch("MDisastersSearch","PopulateMDisasters_Disasters")
    ctrl:CallPopulateHook("PopulateMDisasters_Disasters")
    ctrl:CallPopulateHook("PopulateMDisasters_Weather")
    ctrl:CallPopulateHook("PopulateMDisasters_Weapons")
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

hook.Add( "PopulateMDisasters_Weather", "MDisasters_AddWeatherContent", function( pnlContent, tree, node )

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

hook.Add( "PopulateMDisasters_Disasters", "MDisasters_AddDisastersContent", function( pnlContent, tree, node )

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

hook.Add( "PopulateMDisasters_Weapons", "MDisasters_AddWeaponsContent", function( pnlContent, tree, node )

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
                    material	= "weapons/" .. swep.Class .. ".png",
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