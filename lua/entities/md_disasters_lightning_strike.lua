AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Lightning Strike"
ENT.Category = "MDisasters"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT  -- IMPORTANTE

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_junk/PopCan01a.mdl")

        local bounds = MDisasters_getMapSkyBox()
        local min = bounds[1]
        local max = bounds[2]
        local currentPos = self:GetPos()
        local startPos = currentPos + Vector(0, 0, max.z)
        local endPos = currentPos

        self:SetNWVector("StartPos", startPos)
        self:SetNWVector("EndPos", endPos)
        -- Se extiende el tiempo para poder ver el efecto de partículas
        self:SetNWFloat("BeamStartTime", CurTime())
        self:SetNWFloat("BeamDuration", 1.0)

        sound.Play("weather/thunder/thunder_effect.wav", endPos, 120, 100, 1)

        local pe = ents.Create( "env_physexplosion" );
        pe:SetPos( self:GetPos() );
        pe:SetKeyValue( "Magnitude", 50);
        pe:SetKeyValue( "radius", 40 );
        pe:SetKeyValue( "spawnflags", 19 );
        pe:Spawn();
        pe:Activate();
        pe:Fire( "Explode", "", 0 );
        pe:Fire( "Kill", "", 0.5 );

        for k, v in pairs(ents.FindInSphere(self:GetPos(), 32)) do
            if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
                util.BlastDamage( self, self, self:GetPos(), 32, math.random( 10000, 40000 ) )
                v:Ignite(3)
            else
                
                util.BlastDamage( self, self, self:GetPos(), 32, math.random( 10000, 40000 ) )
                v:Ignite(3)
            end
        end

        

        ParticleEffect("lightning_strike", endPos, Angle(0, 0, 0), self)

        timer.Simple(2, function()
            if IsValid(self) then self:Remove() end
        end)
        
    end
end

function ENT:Think()
    if CLIENT then
        local endPos = self:GetNWVector("EndPos")
        local beamStartTime = self:GetNWFloat("BeamStartTime", 0)
        local beamDuration = self:GetNWFloat("BeamDuration", 1.0)
        local elapsed = CurTime() - beamStartTime

        if elapsed <= beamDuration then
            local dlight = DynamicLight(self:EntIndex())
            if dlight then
                dlight.pos = endPos
                dlight.r = 255
                dlight.g = 255
                dlight.b = 200
                dlight.brightness = 4
                dlight.Decay = 500
                dlight.Size = 400
                dlight.DieTime = CurTime() + 0.1
            end
        end
    end
end

function ENT:OnRemove()
    self:StopParticles()
end

function ENT:DrawTranslucent()
    -- En caso de que quieras dibujar el modelo de la entidad
    self:Draw( STUDIO_DRAWTRANSLUCENTSUBMODELS )
end
