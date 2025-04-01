AddCSLuaFile()

ENT.Base 			= "base_anim"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.PrintName = "Meteor"

ENT.Category = "MDisasters"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Mass = 700

ENT.Model = "models/disasters/meteor/meteor.mdl"

function ENT:Initialize()

    if (SERVER) then
        self:SetModel( self.Model )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )

        local phys = self:GetPhysicsObject()

        if (phys:IsValid()) then
            phys:SetMass(self.Mass)
            phys:Wake()
            phys:EnableDrag(false)
            phys:EnableMotion(true)
            phys:SetVelocity( Vector(0,0,math.random(-5000,-10000))  )
            phys:AddAngleVelocity( VectorRand() * 100 )
        end

        self:SetMeteoriteSkyPos()

        timer.Simple(14, function()
            if !self:IsValid() then return end
            self:Remove()
        end)

        timer.Simple(0.1, function()
            if !self:IsValid() then return end
            ParticleEffectAttach("meteor_trail", PATTACH_POINT_FOLLOW, self, 0)
        end)

        
    end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -1.00  ) 
	ent:Spawn()
	ent:Activate()
	return ent
	
end

function ENT:FireGlow()

	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.pos = self:GetPos()
		dlight.r = 255
		dlight.g = 67
		dlight.b = 0
		dlight.brightness = 8
		dlight.Decay = 1000
		dlight.Size = 1000
		dlight.DieTime = CurTime() + 1
	end
	
end

function ENT:PhysicsCollide(data, physobj)

	local tr,trace = {},{}
	tr.start = self:GetPos() + self:GetForward() * -200
	tr.endpos = tr.start + self:GetForward() * 500
	tr.filter = { self, physobj }
	trace = util.TraceLine( tr )

	if( trace.HitSky ) then
	
		self:Remove()
		
		return
		
	end
    if (data.Speed > 200) then
        self:EmitSound("disasters/meteor/meteor_explosion.wav", 100)
        ParticleEffect( "meteor_explosion", self:GetPos(), Angle(0,0,0) )
        for k,v in pairs(ents.FindInSphere(self:GetPos(), 2500)) do
            if IsValid( v:GetPhysicsObject()) then
                constraint.RemoveAll( v )
                v:GetPhysicsObject():EnableMotion(true)
                v:GetPhysicsObject():Wake()
            end
        end

        local pe = ents.Create( "env_physexplosion" );
        pe:SetPos( self:GetPos() );
        pe:SetKeyValue( "Magnitude", 5000 );
        pe:SetKeyValue( "radius", 4000 );
        pe:SetKeyValue( "spawnflags", 19 );
        pe:Spawn();
        pe:Activate();
        pe:Fire( "Explode", "", 0 );
        pe:Fire( "Kill", "", 0.5 );

        util.BlastDamage( self, self, self:GetPos(), 3200, math.random( 10000, 40000 ) )
		
        local h = data.HitPos + data.HitNormal
		local p = data.HitPos - data.HitNormal
        util.Decal("Scorch", h, p )

        self:Remove()
    end
end

function ENT:SetMeteoriteSkyPos()
    local Zbounds = MDisasters_getMapSkyBox()[2].z  -- Límite superior del skybox
    local startpos = self:GetPos()
    local endpos = Vector(startpos.x, startpos.y, Zbounds) -- Un poco más arriba por seguridad

    local tr = util.TraceLine({
        start  = startpos,
        endpos = endpos,
        mask = MASK_SOLID_BRUSHONLY,
        filter = function(ent) 
            return not ent:IsWorld() -- Ignorar estructuras que no sean el mapa
        end
    })
    MDisasters:msg(tr.HitPos)

    -- Si el trace no golpeó nada, usar la altura máxima del skybox
    local finalPos = tr.Hit and tr.HitPos or endpos

    self:SetPos(finalPos)
end

function ENT:Think()

    self:SetModelScale(10, 0)
   

	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1	

	if (SERVER) then
	
		self:NextThink(CurTime() + t)
		return true
	
	end
    if (CLIENT) then
        self:FireGlow()
    end
			

end

function ENT:OnRemove()

end

function ENT:Draw()



	self:DrawModel()
	
end