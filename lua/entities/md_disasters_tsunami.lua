AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Tsunami"
ENT.Category = "MDisasters"
ENT.Spawnable = true

ENT.Model = "models/disasters/tsunami/tsunami.mdl"

function ENT:Initialize()
    if CLIENT then
        LocalPlayer().MDisasters.Sounds.tsunami = CreateLoopedSound(LocalPlayer(), "disasters/tsunami/tsunami_loop")
        LocalPlayer().MDisasters.Sounds.tsunami:Play()
    end

    if SERVER then
        self:SetModel( self.Model )
        self:SetMoveType(MOVETYPE_VPHYSICS)  
        self:SetSolid(SOLID_VPHYSICS) 
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetUseType(ONOFF_USE)
        self:SetTrigger(true)
        self:SetModelScale(100, 0) -- 🔥 Tsunami gigante

        -- Obtener los límites del mapa
        local bounds = MDisasters_getMapBounds()
        if not bounds then
            MDisasters:msg("Error: Límites del mapa inválidos.")
            self:Remove()
            return
        end

        local min, max, ground = bounds[1], bounds[2], bounds[3]

        -- 🌊 Posición inicial del tsunami
        local spawnOffset = GetConVar("MDisasters_tsunami_offset"):GetInt()
        local spawnSide = math.random(1, 4)
        local spawnPos, velocity

        if spawnSide == 1 then
            spawnPos = Vector(min.x - spawnOffset, (min.y + max.y) / 2, ground.z)
            velocity = Vector(1, 0, 0)
        elseif spawnSide == 2 then
            spawnPos = Vector(max.x + spawnOffset, (min.y + max.y) / 2, ground.z)
            velocity = Vector(-1, 0, 0)
        elseif spawnSide == 3 then
            spawnPos = Vector((min.x + max.x) / 2, min.y - spawnOffset, ground.z)
            velocity = Vector(0, 1, 0)
        else
            spawnPos = Vector((min.x + max.x) / 2, max.y + spawnOffset, ground.z)
            velocity = Vector(0, -1, 0)
        end

        self:SetPos(spawnPos)
        self:SetAngles(velocity:Angle())
        self.Velocity = velocity * GetConVar("MDisasters_tsunami_velocity"):GetInt()
        self.Force = GetConVar("MDisasters_tsunami_force"):GetInt()
    end
end

-- 🔹 Movimiento manual sin físicas
function ENT:Think()
    if SERVER then
        -- Mueve el tsunami sin físicas
        local moveVector = self.Velocity * FrameTime()
        self:SetPos(self:GetPos() + moveVector)

        self:NextThink(CurTime() + 0.1)
        return true
    end
end

-- 🌊 Empuja objetos pero sin bugs
function ENT:StartTouch(ent)
    if ent == self then return end  -- Evitar colisión consigo mismo

    local pushForce = self.Velocity:GetNormalized() * self.Force

    if ent:IsPlayer() or ent:IsNPC() then
        ent:Kill()
    else
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:ApplyForceCenter(pushForce * phys:GetMass())    
            constraint.RemoveAll(ent)
            phys:EnableMotion(true)
            phys:Wake()
        end
    end
end

function ENT:OnRemove()
    if CLIENT then
        LocalPlayer().MDisasters.Sounds.tsunami:Stop() 
    end
end

function ENT:Draw()
    self:DrawModel()
end
