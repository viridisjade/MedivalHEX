local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitConfig = require(ReplicatedStorage:WaitForChild("GameConfigs"):WaitForChild("UnitConfig"))
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local getUnitsFunc = Instance.new("RemoteFunction")
getUnitsFunc.Name = "GetUnitsData"
getUnitsFunc.Parent = ReplicatedStorage

local moveEvent = Instance.new("RemoteEvent")
moveEvent.Name = "MoveUnitEvent"
moveEvent.Parent = ReplicatedStorage

local endTurnEvent = Instance.new("RemoteEvent")
endTurnEvent.Name = "EndTurnEvent"
endTurnEvent.Parent = ReplicatedStorage

local activeUnits = {}
local unitCounter = 0

local function SpawnUnit(ownerId, unitType, q, r)
    unitCounter += 1
    local unitId = "Unit_" .. unitCounter
    local config = UnitConfig[unitType]
    
    if not config then return end

    activeUnits[unitId] = {
        id = unitId,
        ownerId = ownerId,
        unitType = unitType,
        q = q,
        r = r,
        hp = config.MaxHP,
        maxMoves = config.Movement,
        currentMoves = config.Movement,
        hasCrown = (unitType == "King") 
    }
end

SpawnUnit("Player1", "King", 0, 0)
SpawnUnit("Player2", "King", 0, 5)

getUnitsFunc.OnServerInvoke = function(player)
    return activeUnits
end

moveEvent.OnServerEvent:Connect(function(player, unitId, targetQ, targetR)
    local unit = activeUnits[unitId]
    if unit then
        local path = HexGridMath.FindPath(unit.q, unit.r, targetQ, targetR)
        
        if path and #path > 0 and #path <= unit.currentMoves then
            unit.q = targetQ
            unit.r = targetR
            unit.currentMoves = unit.currentMoves - #path
            
            moveEvent:FireAllClients(unitId, path, unit.currentMoves)
        end
    end
end)

endTurnEvent.OnServerEvent:Connect(function(player)
    print(string.format("Server: %s hat die Runde beendet!", player.Name))
    for _, unit in pairs(activeUnits) do
        -- Punkte für alle Einheiten wieder auf Maximum setzen!
        unit.currentMoves = unit.maxMoves
    end
    -- WICHTIG: Wir senden die komplett frische Liste an alle Clients zurück!
    endTurnEvent:FireAllClients(activeUnits)
end)

print("Server: UnitSystem synchronisiert die Runden-Resets nun direkt!")