AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Infinite Lightning Storm"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "MDisasters"

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_junk/PopCan01a.mdl")
        self:SetNoDraw(true)

        self.NextStrikeTime = CurTime() + 1  -- Primer rayo tras 1 segundo
        self:SetPos(self:GetPos())
    end
end

function ENT:Think()
    if SERVER then
        if CurTime() >= self.NextStrikeTime then
            local origin = self:GetPos()
            local mapbound = MDisasters_getMapBounds()

            -- Posición aleatoria alrededor
            local strikePos = origin + Vector(math.random(mapbound[1].x, mapbound[2].x), math.random(mapbound[1].y, mapbound[2].y), 0)

            -- Trazar hacia abajo para encontrar el suelo
            local tr = util.TraceLine({
                start = strikePos + Vector(0, 0, 1000),
                endpos = strikePos - Vector(0, 0, 5000),
                mask = MASK_SOLID_BRUSHONLY
            })

            if tr.Hit then
                local lightning = ents.Create("md_disasters_lightning_strike")
                if IsValid(lightning) then
                    lightning:SetPos(tr.HitPos)
                    lightning:Spawn()
                end
            end

            self.NextStrikeTime = CurTime() + math.Rand(2.5, 5.5)  -- Delay aleatorio entre rayos
        end

        self:NextThink(CurTime())
        return true
    end
end

function ENT:Draw() end  -- Invisible
