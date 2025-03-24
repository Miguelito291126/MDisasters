function setMapLight(light)
	local light_env = ents.FindByClass("light_environment")[1]
	
    if light_env != nil then 
        light_env:Fire( 'FadeToPattern' , light , 0 )

    else
        if light == "a" then

            engine.LightStyle( 0, "b" )
            net.Start("md_maplight_cl")
            net.Broadcast()
        else
            engine.LightStyle( 0, light )
            net.Start("md_maplight_cl")
            net.Broadcast()

        end
    end
end


function GetLightLevel(player)

    net.Start("md_ambientlight")
    net.Send(player)
    return player.AmbientLight
end

function paintSky_Fade(data_to, fraction) -- fade from one skypaint setting to another

    local self          = ents.FindByClass("env_skypaint")[1]

    if self==nil  then 
    
        local ent = ents.Create("env_skypaint")
        ent:SetPos(Vector(0,0,0))
        ent:Spawn()
        ent:Activate()
        self = ent

    end

    if data_to==nil then return end

    local TopColor      = LerpVector( fraction, self:GetTopColor()      ,data_to["TopColor"]      or Vector(0.20,0.50,1.00))
    local BottomColor   = LerpVector( fraction, self:GetBottomColor()   ,data_to["BottomColor"]   or Vector(0.80,1.00,1.00))
    local FadeBias      = Lerp(       fraction, self:GetFadeBias()      ,data_to["FadeBias"]      or 1.00)
    local HDRScale      = Lerp(       fraction, self:GetHDRScale()      ,data_to["HDRScale"]      or 0.66)


    local DrawStars     = true
    local StarTexture   = "skybox/starfield"
    local StarScale     = Lerp(       fraction, self:GetStarScale()     ,data_to["StarScale"]     or 0.50)
    local StarFade      = Lerp(       fraction, self:GetStarFade()      ,data_to["StarFade"]      or 1.50)
    local StarSpeed     = Lerp(       fraction, self:GetStarSpeed()     ,data_to["StarSpeed"]     or 0.01)

    local DuskIntensity = Lerp(       fraction, self:GetDuskIntensity() ,data_to["DuskIntensity"] or 0.5)
    local DuskScale     = Lerp(       fraction, self:GetDuskScale()     ,data_to["DuskScale"]     or 1.00)
    local DuskColor     = LerpVector( fraction, self:GetDuskColor()     ,data_to["DuskColor"]     or Vector(1.00,0.20,0.00))

    local SunSize       = Lerp(       fraction, self:GetSunSize()       ,data_to["SunSize"]       or 2.00)
    local SunColor      = LerpVector( fraction, self:GetSunColor()      ,data_to["SunColor"]      or Vector(0.20,0.10,0.00))

    if( IsValid( self ) ) then
        
        self:SetTopColor( TopColor )
        self:SetBottomColor( BottomColor )
        self:SetFadeBias( FadeBias )

        self:SetDrawStars( DrawStars )
        self:SetStarTexture( StarTexture )	
        
        self:SetStarSpeed( StarSpeed )
        self:SetStarScale( StarScale )
        self:SetStarFade( StarFade )

        self:SetDuskColor( DuskColor )
        self:SetDuskScale( DuskScale )
        self:SetDuskIntensity( DuskIntensity )
        
        self:SetSunColor( SunColor )
        self:SetSunSize( SunSize )


        self:SetHDRScale( HDRScale )

    end


end

function isOutdoor(ent)
    local traceData = {}
    traceData.start = ent:GetPos()
    traceData.endpos = ent:GetPos() + Vector(0, 0, 48000)  -- 1000 units hacia arriba
    traceData.mask = MASK_SOLID
    traceData.filter = ent
    local tr = util.TraceLine(traceData)

    if ent:IsPlayer() then
        net.Start("md_isOutdoor")
        net.WriteBool(tr.HitSky)
        net.Send(ent)
        ent.mdisasters.area.isoutdoor = tr.HitSky  -- Si no golpea nada arriba, está al aire libre
    else
        ent.IsOutdoor = tr.HitSky
    end

    return tr.HitSky  -- Si no golpea nada arriba, está al aire libre
end


function IsSomethingBlockingWind(entity)


	local tr = util.TraceLine( {
		start = entity:GetPos() + Vector(0,0,10),
		endpos = entity:GetPos() + Vector(0,0,10) + (mdisasters.weather.Wind.dir * 300),
		filter = entity

	} )



	return tr.Hit
end

