local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local moveEvent = Instance.new("RemoteEvent")
moveEvent.Name = "MoveUnitEvent"
moveEvent.Parent = ReplicatedStorage

local activeUnits = {
    ["Unit_1"] = {q = 0, r = 0, owner = 1, maxMoves = 4, currentMoves = 4}
}

local getUnitsFunc = Instance.new("RemoteFunction")
getUnitsFunc.Name = "GetUnitsData"
getUnitsFunc.Parent = ReplicatedStorage

getUnitsFunc.OnServerInvoke = function(player)
    return activeUnits
end

moveEvent.OnServerEvent:Connect(function(player, unitId, targetQ, targetR)
    local unit = activeUnits[unitId]
    if not unit then return end
    
    local path = HexGridMath.FindPath(unit.q, unit.r, targetQ, targetR)
    if path and #path <= unit.currentMoves then
        local finalNode = path[#path]
        unit.q = finalNode.q
        unit.r = finalNode.r
        unit.currentMoves -= #path
        
        print(string.format("Server: Einheit %s bewegt über Pfad zu (%d, %d). Rest-Moves: %d", unitId, finalNode.q, finalNode.r, unit.currentMoves))
        moveEvent:FireAllClients(unitId, path)
    else
        print("Server: Ungültiger Pfad oder nicht genug Bewegungspunkte!")
    end
end)