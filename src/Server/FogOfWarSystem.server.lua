local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local fogFunc = Instance.new("RemoteFunction")
fogFunc.Name = "GetFogData"
fogFunc.Parent = ReplicatedStorage

-- Berechnet für einen Spieler alle Felder im Sichtradius (z.B. Reichweite 3)
fogFunc.OnServerInvoke = function(player, playerUnits, playerCities)
    local visibleHexes = {}
    local sightRange = 3
    
    -- Sammle Sicht von Einheiten
    if playerUnits then
        for _, unit in pairs(playerUnits) do
            visibleHexes[unit.q .. "_" .. unit.r] = true
            local neighbors = HexGridMath.GetNeighbors(unit.q, unit.r)
            for _, n in ipairs(neighbors) do
                visibleHexes[n.q .. "_" .. n.r] = true
                -- Zweiter Ring für vollen Radius 3
                for _, n2 in ipairs(HexGridMath.GetNeighbors(n.q, n.r)) do
                    visibleHexes[n2.q .. "_" .. n2.r] = true
                end
            end
        end
    end
    
    -- Sammle Sicht von Städten
    if playerCities then
        for _, city in pairs(playerCities) do
            visibleHexes[city.q .. "_" .. city.r] = true
            local neighbors = HexGridMath.GetNeighbors(city.q, city.r)
            for _, n in ipairs(neighbors) do
                visibleHexes[n.q .. "_" .. n.r] = true
            end
        end
    end
    
    return visibleHexes
end