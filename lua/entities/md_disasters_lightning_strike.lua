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

        local currentPos = self:GetPos()
        local additionalHeight = 5000  -- Ajusta este valor según la longitud deseada del rayo
        local startPos = currentPos + Vector(0, 0, additionalHeight)
        local endPos = currentPos

        self:SetNWVector("StartPos", startPos)
        self:SetNWVector("EndPos", endPos)
        self:SetNWFloat("BeamStartTime", CurTime())
        self:SetNWFloat("BeamDuration", 0.3)

        sound.Play("ambient/energy/zap1.wav", endPos, 120, 100, 1)

        local explosion = ents.Create("env_explosion")
        if IsValid(explosion) then
            explosion:SetPos(endPos)
            explosion:SetOwner(self)
            explosion:Spawn()
            explosion:SetKeyValue("iMagnitude", "100")
            explosion:Fire("Explode", "", 0)
        end

        timer.Simple(2, function()
            if IsValid(self) then self:Remove() end
        end)
    end
end


function ENT:Think()
    if CLIENT then
        local endPos = self:GetNWVector("EndPos")
        local beamStartTime = self:GetNWFloat("BeamStartTime", 0)
        local beamDuration = self:GetNWFloat("BeamDuration", 0.3)
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

function ENT:Draw()
    self:DrawModel()
end

function GenerateSubrays(startPos, endPos, numSubrays, deviation)
    local subrays = {}
    for i = 1, numSubrays do
        local t = math.Rand(0.2, 0.8)
        local mainPos = LerpVector(t, startPos, endPos)
        local subrayDir = VectorRand():GetNormalized()
        local subrayLength = math.Rand(20, 50)
        local subrayEndPos = mainPos + subrayDir * subrayLength
        table.insert(subrays, {startPos = mainPos, endPos = subrayEndPos})
    end
    return subrays
end

function ENT:DrawTranslucent()
    local startPos = self:GetNWVector("StartPos")
    local endPos = self:GetNWVector("EndPos")
    local beamStartTime = self:GetNWFloat("BeamStartTime", 0)
    local beamDuration = self:GetNWFloat("BeamDuration", 0.3)
    local elapsed = CurTime() - beamStartTime

    if elapsed <= beamDuration then
        local segments = 10
        local material = Material("cable/blue_elec")
        render.SetMaterial(material)

        -- Dibujar rayo principal
        render.StartBeam(segments)
        for i = 0, segments - 1 do
            local t = i / (segments - 1)
            local pos = LerpVector(t, startPos, endPos)
            if i ~= 0 and i ~= segments - 1 then
                local deviation = VectorRand() * 30
                deviation.z = deviation.z * 0.2
                pos = pos + deviation
            end
            render.AddBeam(pos, 10, t, Color(255, 255, 255, 255))
        end
        render.EndBeam()

        -- Generar y dibujar subrayos
        local numSubrays = 3
        local subrays = GenerateSubrays(startPos, endPos, numSubrays, 30)
        for _, subray in ipairs(subrays) do
            render.StartBeam(2)
            render.AddBeam(subray.startPos, 8, 0, Color(255, 255, 255, 255))
            render.AddBeam(subray.endPos, 8, 1, Color(255, 255, 255, 255))
            render.EndBeam()
        end
    end
end