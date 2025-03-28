AddCSLuaFile()

ENT.Base 			= "base_anim"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.PrintName = "EF1 Tornado"

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

function ENT:Physics()
    local tornadoPos = self:GetPos()
    for _, ent in ipairs(ents.GetAll()) do
        if ent:IsValid() then
            local distSqr = ent:GetPos():DistToSqr(tornadoPos)
            if distSqr < self.Radius ^ 2 and distSqr > 0 then
                local distance = math.sqrt(distSqr)

                -- Fracción de cercanía (1 cerca del centro, 0 en el borde)
                local distanceFraction = 1 - (distance / self.Radius)
                distanceFraction = math.Clamp(distanceFraction, 0, 1)

                -- Fuerza proporcional a cercanía al centro (decay cuadrático)
                local forceMagnitude = self.Force * distanceFraction ^ 2

                -- Direcciones de fuerza (movimiento circular)
                local direction = (tornadoPos - ent:GetPos()):GetNormalized()
                direction.z = 0  -- solo horizontal
                local tangentialDir = Vector(-direction.y, direction.x, 0)

                -- Aplicar fuerzas
                local pullForce = direction * (forceMagnitude * 0.5)  -- Reducido para que no jale tan fuerte al centro
                local circularForce = tangentialDir * (forceMagnitude * 1.2)  -- Aumentado para más giro

                local verticalForce = Vector(0, 0, forceMagnitude * 1.5)  -- Aumentado para más altura
                local vortexDir = Vector(-direction.y, direction.x, 0)
                local vortexForce = vortexDir * (forceMagnitude * 0.8)  -- Puede combinarse con circularForce

                local totalForce = pullForce + verticalForce + circularForce + vortexForce

                if ent:GetPhysicsObject():IsValid() then
                    local phys = ent:GetPhysicsObject()
                    phys:AddVelocity(totalForce)

                    if GetConVar("MDisasters_tornado_constraints_damage"):GetInt() ~= 1 then return end
                    if HitChance(GetConVar("MDisasters_tornado_constraints_damage"):GetInt()) then
                        constraint.RemoveAll(ent)
                        phys:EnableMotion(true)
                        phys:Wake()
                    end
                end

                if ent:IsPlayer() or ent:IsNPC() then
                    ent:SetVelocity(totalForce * 2)
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
	end
end

function ENT:Move()
    -- Cambiar la dirección de forma constante, pero con un cambio más sutil.
    local randomAngle = Angle(0, math.random(-5, 5), 0)  -- Ángulo aleatorio más sutil
    self.Direction:Rotate(randomAngle)
    self.Direction:Normalize()

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
    else
        nextPos.z = nextPos.z - 50  -- 50 unidades sobre el suelo
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

        self:NextThink(CurTime() )
        return true
    end 
end

function ENT:OnRemove()
    self.Sounds:Stop()
end


function ENT:Draw()



	self:DrawModel()
	
end