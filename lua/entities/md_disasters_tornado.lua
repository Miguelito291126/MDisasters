AddCSLuaFile()

ENT.Base 			= "base_anim"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.PrintName = "Tornado"

ENT.Category = "MDisasters"


ENT.EnhancedFujitaScale = "EF1"
ENT.Model = "models/props_c17/oildrum001.mdl"
ENT.Mass = 100




function ENT:Initialize()
	local sound = Sound("disasters/tornado/tornado_loop.wav")
    CSPatch = CreateSound(self, sound)
	CSPatch:Play()
    self.Sounds = CSPatch

    if SERVER then
        self:SetModel(self.Model)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)  -- Cambia a VPHYSICS momentáneamente

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(self.Mass)
            phys:EnableMotion(false)
        end

        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetNoDraw(true)  -- Haz visible por ahora para test

        local dir = VectorRand()
        dir.z = 0
        dir:Normalize()
        self.Direction = dir
        self.NextDirectionChange = CurTime() + 5
        self.NextPhysicsTime = CurTime()

        self.MaxGroundFunnelHeight = 100
        self.Radius = GetConVar("MDisasters_tornado_radius"):GetInt()
        self.Force = GetConVar("MDisasters_tornado_force"):GetInt()
        self.Speed = GetConVar("MDisasters_tornado_speed"):GetInt()

        timer.Simple(GetConVar("MDisasters_tornado_time"):GetInt(), function()
            if not self:IsValid() then return end
            self:Remove()
        end)
        
        ParticleEffectAttach("tornado", PATTACH_POINT_FOLLOW, self, 0)
    end
end

function ENT:PerpVectorCW(ent1, ent2)
	local ent1_pos = ent1:GetPos()
	local ent2_pos = ent2:GetPos()
	
	local dir      = (ent2_pos - ent1_pos):GetNormalized()
	local perp     = Vector(-dir.y, dir.x, 0)
	
	return perp

end

function ENT:Physics()
    local phys_scalar = 1

    local wind_speed_mod = (self.Force / 323) * 5

    for _, ent in ipairs(ents.GetAll()) do
        if ent:IsValid() then
            local distSqr = ent:GetPos():DistToSqr(self:GetPos())
            if distSqr < self.Radius^2 and distSqr > 0 then
                local suctional_dir = (Vector(self:GetPos().x, self:GetPos().y, ent:GetPos().z + self.MaxGroundFunnelHeight) - ent:GetPos()):GetNormalized()
                local tangential_dir = self:PerpVectorCW(self, ent)

                local suctional_force = suctional_dir * 50 * wind_speed_mod
                local tangential_force = tangential_dir * 50 * wind_speed_mod
                local updraft_force = Vector(0, 0, wind_speed_mod / 5 * 110)

                local total_force = suctional_force + Vector(tangential_force.x, tangential_force.y, 0) + updraft_force

                if ent:IsPlayer() or ent:IsNPC() then
                    ent:SetVelocity(total_force)
                end
                
                if ent:GetPhysicsObject():IsValid() then
                    ent:GetPhysicsObject():AddVelocity(total_force)
                    
                    if GetConVar( "MDisasters_tornado_constraints_damage" ):GetInt()!=1 then return end
                    
                    if HitChance(GetConVar( "MDisasters_tornado_constraints_damage" ):GetInt()) then
                        constraint.RemoveAll( ent )
                        ent:GetPhysicsObject():EnableMotion( true )
                    end
                end
            end
        end
    end
end

function ENT:BounceFromWalls(dir)
	local selfPos = self:GetPos()
	local traceStart = selfPos + (dir * self.Speed)
	local traceEnd = selfPos + (dir * 8 * self.Speed)

	local tr = util.TraceLine({
		start = traceStart,
		endpos = traceEnd,
		mask = MASK_WATER + MASK_SOLID_BRUSHONLY
	})

	if tr.Hit then
        self.Direction = -dir
		self.NextDirectionChange = CurTime() + 5
	end
end

function ENT:Move()
    -- Cambiar levemente la dirección cada 5 segundos
    if CurTime() >= self.NextDirectionChange then
        local randomAngle = Angle(0, math.random(-15, 15), 0)
        self.Direction:Rotate(randomAngle)
        self.Direction:Normalize()
        self.NextDirectionChange = CurTime() + 5
    end

    -- Intentar mover el tornado horizontalmente
    local horizontalMove = self.Direction * self.Speed
    local currentPos = self:GetPos()
    local nextPos = currentPos + horizontalMove

    -- Trazar hacia abajo desde el siguiente punto para encontrar el suelo
    local traceData = {
        start = nextPos + Vector(0, 0, 500),     -- desde arriba
        endpos = nextPos - Vector(0, 0, 1000),   -- hasta abajo
        filter = self
    }
    local tr = util.TraceLine(traceData)

    if tr.Hit then
        -- Coloca el tornado a una altura fija sobre el suelo
        nextPos.z = tr.HitPos.z + 50  -- 50 unidades sobre el suelo
    end

    self:SetPos(nextPos)

    -- Rebote en muros u obstáculos sólidos
    self:BounceFromWalls(self.Direction)
end


function ENT:Think()
    if (SERVER) then
        if !self:IsValid() then return end

        self:Physics()
        self:Move()

        self:NextThink(CurTime())
        return true
    end 
end

function ENT:OnRemove()
    self.Sounds:Stop()
end


function ENT:Draw()



	self:DrawModel()
	
end