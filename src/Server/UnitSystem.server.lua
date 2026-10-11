local ReplicatedStorage = game:GetService("ReplicatedStorage")

local getUnitsFunc = Instance.new("RemoteFunction")
getUnitsFunc.Name = "GetUnitsData"
getUnitsFunc.Parent = ReplicatedStorage

local moveEvent = Instance.new("RemoteEvent")
moveEvent.Name = "MoveUnitEvent"
moveEvent.Parent = ReplicatedStorage

-- Startaufstellung des Krieges: Fraktion Blau vs. Fraktion Rot
local activeUnits = {
    -- BLAUE ARMEE (Spieler 1)
    ["Blue_King"] = { q = 0, r = 5, faction = "Blue", isKing = true, color = Color3.fromRGB(41, 128, 185), currentMoves = 3 },
    ["Blue_Infantry_1"] = { q = 1, r = 5, faction = "Blue", isKing = false, color = Color3.fromRGB(41, 128, 185), currentMoves = 3 },
    ["Blue_Infantry_2"] = { q = -1, r = 6, faction = "Blue", isKing = false, color = Color3.fromRGB(41, 128, 185), currentMoves = 3 },

    -- ROTE ARMEE (Spieler 2 / Gegner)
    ["Red_King"] = { q = 0, r = -5, faction = "Red", isKing = true, color = Color3.fromRGB(192, 57, 43), currentMoves = 3 },
    ["Red_Infantry_1"] = { q = -1, r = -5, faction = "Red", isKing = false, color = Color3.fromRGB(192, 57, 43), currentMoves = 3 },
    ["Red_Infantry_2"] = { q = 1, r = -6, faction = "Red", isKing = false, color = Color3.fromRGB(192, 57, 43), currentMoves = 3 },
}

getUnitsFunc.OnServerInvoke = function(player)
    return activeUnits
end

moveEvent.OnServerEvent:Connect(function(player, unitId, targetQ, targetR, path)
    local unit = activeUnits[unitId]
    if unit then
        -- In einer echten Version würde der Server hier den Pfad validieren.
        -- Für das Konzept übernehmen wir die neue Position direkt.
        unit.q = targetQ
        unit.r = targetR
        
        -- Alle Clients anweisen, die Bewegung abzuspielen
        moveEvent:FireAllClients(unitId, path)
    end
end)

print("Server: Kriegssimulator initialisiert. Truppen stehen bereit!")