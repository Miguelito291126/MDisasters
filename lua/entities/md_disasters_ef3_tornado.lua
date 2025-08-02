AddCSLuaFile()

ENT.Base 			= "base_anim"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.PrintName = "EF3 Tornado"
ENT.Category = "MDisasters"

ENT.EnhancedFujitaScale = "EF3"
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
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetNoDraw(true)  -- Haz visible por ahora para test

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(self.Mass)
            phys:EnableMotion(false)
        end

        local dir = VectorRand()
        dir.z = 0
        dir:Normalize()

        self.Direction = dir
        self.Radius = GetConVar("MDisasters_tornado_radius"):GetInt() or 50000 
        self.Force = GetConVar("MDisasters_tornado_force"):GetInt() or 50000
        self.Speed = GetConVar("MDisasters_tornado_speed"):GetInt() or 10

        timer.Simple(GetConVar("MDisasters_tornado_time"):GetInt(), function()
            if not self:IsValid() then return end
            self:Remove()
        end)
        
        ParticleEffectAttach("tornado_ef3", PATTACH_POINT_FOLLOW, self, 0)
    end
end

function ENT:TornadoPhysics()
    local tornadoPos = self:GetPos()
    local tornadoHeight = self.Height or 1000  -- Altura del tornado
    local tornadoRadius = self.Radius or 500   -- Radio del tornado

    -- 🔍 **Buscar entidades dentro del radio horizontal**
    for _, ent in ipairs(ents.FindInSphere(tornadoPos, tornadoRadius)) do
        if IsValid(ent) then
            local entPos = ent:GetPos()

            -- 📏 **Filtrar por altura**
            if entPos.z < tornadoPos.z or entPos.z > (tornadoPos.z + tornadoHeight) then
                -- 💡 Solución alternativa a `goto continue`
                continue
            end

            -- ✅ **Aplicar fuerzas**
            local distanceFraction = 1 - (entPos:Distance(tornadoPos) / tornadoRadius)
            distanceFraction = math.Clamp(distanceFraction, 0, 1)

            local forceMagnitude = self.Force * distanceFraction ^ 2

            -- **Direcciones de fuerza**
            local direction = (tornadoPos - entPos):GetNormalized()
            direction.z = 0  -- Solo horizontal
            local tangentialDir = Vector(-direction.y, direction.x, 0)

            -- **Aplicar fuerzas**
            local pullForce = direction * (forceMagnitude * 0.5)  -- Succión
            local circularForce = tangentialDir * (forceMagnitude * 1.2)  -- Giro
            local verticalForce = Vector(0, 0, forceMagnitude * 1.5)  -- Elevación
            local vortexForce = Vector(-direction.y, direction.x, 0) * (forceMagnitude * 0.8)  -- Movimiento circular extra

            local totalForce = pullForce + verticalForce + circularForce + vortexForce

            if ent:IsPlayer() or ent:IsNPC() then
                ent:SetVelocity(ent:GetVelocity() * -0.2) -- Reducir velocidad anterior
                ent:SetVelocity(totalForce * 1.5) -- Aplicar nueva velocidad
                -- 💡 Ajustar gravedad para mejorar efecto
                ent:SetGravity(0.3) 
                timer.Simple(1, function()
                    if IsValid(ent) then ent:SetGravity(1) end
                end)
            else
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(totalForce * phys:GetMass())


                    if math.random(1, GetConVar("MDisasters_tornado_constraints_damage"):GetInt()) == 1 then
                        constraint.RemoveAll(ent)
                        phys:EnableMotion(true)
                        phys:Wake()
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
    end
end

function ENT:TornadoMove()
    -- Cambiar la dirección de forma constante, pero con un cambio más sutil.
    local randomAngle = Angle(0, math.random(-10, 10), 0)  -- Ángulo aleatorio más sutil
    self.Direction:Rotate(randomAngle)
    self.Direction:Normalize()

    -- Intentar mover el tornado horizontalmente
    local horizontalMove = self.Direction * self.Speed
    local currentPos = self:GetPos()
    local nextPos = currentPos + horizontalMove

    -- Mantener el tornado en el suelo
    local trace = util.TraceLine({
        start = nextPos,
        endpos = nextPos - Vector(0, 0, 100),  -- Ajustar la altura de la traza
        mask = MASK_WATER + MASK_SOLID_BRUSHONLY,
        filter = function(ent)
            return ent == self or ent:GetClass() ~= "worldspawn"
        end
    })

    if trace.Hit then
        nextPos.z = trace.HitPos.z

        -- Rebote en muros u obstáculos sólidos
        self:BounceFromWalls(self.Direction)

        self:SetPos(nextPos)
    else
        nextPos.z = currentPos.z - 50  -- Mantener el tornado a una altura constante
        self:SetPos(nextPos)
    end


end



function ENT:Think()
    if (SERVER) then
        if !self:IsValid() then return end

        self:TornadoPhysics()
        self:TornadoMove()

        self:NextThink(CurTime())
        return true
    end 
end

function ENT:OnRemove()
    if self.Sounds then self.Sounds:Stop() end
    self:StopParticles()
end


function ENT:Draw()
	self:DrawModel()
end