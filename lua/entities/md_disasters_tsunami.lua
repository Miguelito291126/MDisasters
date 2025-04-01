AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Tsunami"
ENT.Category = "MDisasters"
ENT.Spawnable = true

function ENT:Initialize()
    if CLIENT then
        LocalPlayer().Sounds.tsunami = CreateLoopedSound(LocalPlayer(), "disasters/tsunami/tsunami_loop")
        LocalPlayer().Sounds.tsunami:Play()
    end
    if SERVER then
        self:SetModel("models/disasters/tsunami/tsunami.mdl")
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)  -- Ahora el modelo choca de verdad
        self:PhysicsInit(SOLID_VPHYSICS) -- Inicializa físicas
        self:SetTrigger(true)  -- Activa detección de colisión sin bloquear el movimiento
        self:SetModelScale(100, 0)

        local bounds = MDisasters_getMapBounds()
        local min, max, ground = bounds[1], bounds[2], bounds[3]

        if not min or not max or not ground then
            MDisasters:msg("Error: Límites del mapa inválidos.")
            self:Remove()
            return
        end

        -- 🏝️ Generar tsunami **fuera** de los límites del mapa
        local spawnOffset = GetConVar("MDisasters_tsunami_offset"):GetInt() -- 🔥 Se spawnea 500 unidades más afuera
        local spawnSide = math.random(1, 4)
        local spawnPos
        local velocity

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

        -- 🔍 **Verificar que el spawn es válido con un trace**
        local trace = util.TraceLine({
            start = spawnPos,
            endpos = spawnPos + Vector(0, 0, -10000),  -- Buscar suelo
            mask = MASK_SOLID_BRUSHONLY
        })

        if not trace.Hit or not util.IsInWorld(trace.HitPos) then
            MDisasters:msg("Posición de spawn fuera del mundo, abortando tsunami.")
            self:Remove()
            return
        end

        -- 🚀 Spawnear el tsunami en una posición válida
        self:SetPos(trace.HitPos)  -- Ajusta la posición al suelo detectado
        self:SetAngles(velocity:Angle())

        self.Velocity = velocity * GetConVar("MDisasters_tsunami_velocity"):GetInt()
        self.Force = GetConVar("MDisasters_tsunami_force"):GetInt()
        
    end
end

function ENT:Think()
    if SERVER then
        local moveVector = self.Velocity * FrameTime()
        local newPos = self:GetPos() + moveVector

        if not util.IsInWorld(newPos) then
            MDisasters:msg("Se ha salido del mundo, eliminando.")
            self:Remove()
            return
        end

        self:SetPos(newPos)
        self:NextThink(CurTime() + 0.1)
        return true
    end
end

-- 🔥 Cuando el tsunami toca algo, lo destruye o lo empuja
function ENT:StartTouch(ent)
    if ent == self then return end  -- Evita colisión consigo mismo

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
        LocalPlayer().Sounds.tsunami:Stop() 
    end
end
