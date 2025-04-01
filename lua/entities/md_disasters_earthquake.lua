AddCSLuaFile()

ENT.Base = "base_anim"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.PrintName = "Earthquake"
ENT.Category = "MDisasters"




function ENT:Initialize()
    if SERVER then
        -- Timer constante del terremoto
        self:SetModel("models/props_junk/rock001a.mdl") -- Modelo opcional
        self:SetNoDraw(true) -- No se ve, puro efecto
        self:SetSolid(SOLID_NONE)

        timer.Simple(GetConVar("MDisasters_earthquake_time"):GetInt(), function()
            if not self:IsValid() then return end
            self:Remove()
        end)

        net.Start("md_sendloopsound")
        net.WriteString("disasters/earthquake/earthquake_loop.wav")
        net.Broadcast()

        self.Radius = GetConVar("MDisasters_earthquake_radius"):GetInt()
        self.ShakeIntensity = GetConVar("MDisasters_earthquake_shake_force"):GetInt()
        self.ShakeDuration = 1
        self.ShakeFreq = 5 -- frecuencia de la sacudida
        self.PushForce = GetConVar("MDisasters_earthquake_force"):GetInt()
        self.PushForcePlayer = GetConVar("MDisasters_earthquake_player_force"):GetInt()


       
    end
end

function ENT:DoEarthquake()
    local pos = self:GetPos()

    -- Sacude la pantalla cerca del epicentro
    util.ScreenShake(pos, self.ShakeIntensity, self.ShakeFreq, self.ShakeDuration, self.Radius)

    for _, ent in ipairs(ents.GetAll()) do
        local dist = pos:Distance(ent:GetPos())

        if ent:IsPlayer() or ent:IsNPC() then
            -- ⚡ Empuje solo horizontal (X, Y), sin levantar en Z
            local randVec = VectorRand()
            randVec.z = 0  
            local pushForce = randVec:GetNormalized() * self.PushForcePlayer

            if ent:OnGround() then
                ent:SetVelocity(pushForce)
            end
        else
            local phys = ent:GetPhysicsObject()
            if phys:IsValid() then
                local randVec = VectorRand()
                randVec.z = 0 

                -- Calcula una fuerza decreciente según la distancia
                local forceScale = math.Clamp(1 - (dist / self.Radius), 0, 1)  
                local scaledForce = randVec * (self.PushForce * forceScale)

                -- Aplica el empuje con offset para girar los objetos
                local forceOffset = ent:GetPos() + VectorRand() * 10
                phys:ApplyForceOffset(scaledForce, forceOffset)

                -- Probabilidad mayor de romper restricciones
                if math.random(1, 512) == 1 then  -- 25% de probabilidad
                    constraint.RemoveAll(ent)
                    phys:EnableMotion(true) 
                    phys:Wake()

                end
            end
        end
    end
end

function ENT:Think()
    if (SERVER) then 
        self:DoEarthquake()
        self:NextThink(CurTime())
        return true 
    end
end

function ENT:OnRemove()
    -- Detiene sonido y timer
    if (SERVER) then
        net.Start("md_stoploopsound")
        net.WriteString("disasters/earthquake/earthquake_loop.wav")
        net.Broadcast()
    end
    timer.Remove("EarthquakeLoop_" .. self:EntIndex())
end

function ENT:Draw()
    -- Invisible, pero si quieres verlo, cambia esto:
    self:DrawModel()
end
