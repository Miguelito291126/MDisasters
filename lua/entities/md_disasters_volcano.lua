AddCSLuaFile()

ENT.Base 			= "base_anim"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.PrintName = "volcano"

ENT.Category = "MDisasters"

ENT.Mass = 100

ENT.Model = "models/disasters/volcano/volcano.mdl"

function ENT:Initialize()

    self:DrawShadow( false)
    self:SetModelScale(10, 0)

	local sound = Sound("disasters/volcano/volcano_loop.wav")
	CSPatch = CreateSound(self, sound)
	CSPatch:Play()
	self.Sounds = CSPatch

    timer.Create("Lava_Erupt",  GetConVar("MDisasters_volcano_time"):GetInt(), 0, function()
        if !self:IsValid() then return end
        self:VolcanoErupt() 
    end)

    if (SERVER) then
        self:SetModel( self.Model )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( ONOFF_USE )

        local phys = self:GetPhysicsObject()

        if (phys:IsValid()) then
            phys:SetMass(self.Mass)
            phys:EnableMotion(false)
        end
    end

    if (CLIENT) then
        self.volcanotrail = self:CreateParticleEffect("volcano_trail", PATTACH_POINT_FOLLOW)
    end
end

function ENT:LavaGlow()

	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.pos = self:GetPos()
		dlight.r = 255
		dlight.g = 67
		dlight.b = 0
		dlight.brightness = 8
		dlight.Decay = 1000
		dlight.Size = 50000
		dlight.DieTime = CurTime() + 1
	end
	
end

function ENT:VolcanoErupt()
    self:EmitSound("disasters/volcano/volcano_explosion.wav", 100)

    if CLIENT then
        self.volcanoexplosion = self:CreateParticleEffect("volcano_explosion", PATTACH_POINT_FOLLOW)

        if self.volcanotrail:IsValid() then
            self.volcanotrail:StopEmission(true)
            
        end
        timer.Simple(6, function() 
            if self.volcanoexplosion:IsValid() then
                self.volcanoexplosion:StopEmission(true)
                self.volcanotrail = self:CreateParticleEffect("volcano_trail", PATTACH_POINT_FOLLOW)
            end 
        end)
    end
    if SERVER then
        local earthquake = ents.Create("md_disasters_earthquake")
        earthquake:Spawn()
        earthquake:Activate()

        for i = 0,5 do
            local rock = ents.Create("md_disasters_meteor")
            rock:Spawn()
            rock:Activate()
            rock:SetPos(self:GetPos() + Vector(0, 0, 100))
            rock:GetPhysicsObject():SetVelocity( Vector(math.random(-10000,10000),math.random(-10000,10000),math.random(5000,10000)) )
            rock:GetPhysicsObject():AddAngleVelocity( VectorRand() * 100 ) 
        end

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
		
    end
end

function ENT:Think()

	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1	

	if (SERVER) then
	
		self:NextThink(CurTime() + t)
		return true
	
	end
    if CLIENT then
        self:LavaGlow()
    end
			

end

function ENT:OnRemove()

    self.Sounds:Stop()
    timer.Remove("Lava_Erupt")
end

function ENT:Draw()



	self:DrawModel()
	
end