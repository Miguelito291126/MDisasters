AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Tsunami"
ENT.Category = "MDisasters"
ENT.Spawnable = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/disasters/tsunami/tsunami.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)  -- No colisiona para evitar errores
        self:SetModelScale(100, 0)

        local bounds = MDisasters_getMapBounds()
        local min, max, ground = bounds[1], bounds[2], bounds[3]

        -- Asegurar que los valores son válidos
        if not min or not max or not ground then
            print("[Tsunami] Error: Límites del mapa inválidos.")
            self:Remove()
            return
        end

        local spawnSide = math.random(1, 4)
        local spawnPos
        local velocity

        if spawnSide == 1 then
            spawnPos = Vector(min.x + 100, (min.y + max.y) / 2, ground.z)  -- Ligeramente dentro del mapa
            velocity = Vector(1, 0, 0) 
        elseif spawnSide == 2 then
            spawnPos = Vector(max.x - 100, (min.y + max.y) / 2, ground.z)
            velocity = Vector(-1, 0, 0)
        elseif spawnSide == 3 then
            spawnPos = Vector((min.x + max.x) / 2, min.y + 100, ground.z)
            velocity = Vector(0, 1, 0)
        else
            spawnPos = Vector((min.x + max.x) / 2, max.y - 100, ground.z)
            velocity = Vector(0, -1, 0)
        end

        -- Verificar si el spawn es válido
        if not util.IsInWorld(spawnPos) then
            print("[Tsunami] Spawn en posición inválida:", spawnPos)
            self:Remove()
            return
        end

        self:SetPos(spawnPos)
        self:SetAngles(velocity:Angle())  
        self.Velocity = velocity * 5000  -- Reducida para evitar bugs
        self.Force = 5000  
        self.Radius = 10000

        self:EmitSound("disasters/water/tsunami_loop.wav", 100, 90)  
    end
end

function ENT:Think()
    if SERVER then
        local moveVector = self.Velocity * FrameTime()

        -- Validar que la posición no se vuelva loca
        local newPos = self:GetPos() + moveVector
        if not util.IsInWorld(newPos) then
            print("[Tsunami] Se ha salido del mundo, eliminando.")
            self:Remove()
            return
        end

        self:SetPos(newPos)

        for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.Radius)) do
            if ent == self then continue end  

            if ent:IsPlayer() or ent:IsNPC() then
                ent:SetVelocity(self.Velocity:GetNormalized() * self.Force)  
            else
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(self.Velocity:GetNormalized() * self.Force * phys:GetMass())  
                    constraint.RemoveAll(ent)
                    phys:EnableMotion(true)
                    phys:Wake()
                end
            end
        end

        self:NextThink(CurTime() + 0.1)
        return true
    end
end

function ENT:OnRemove()
    self:StopSound("disasters/water/tsunami_loop.wav")
end
