local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local moveEvent = Instance.new("RemoteEvent")
moveEvent.Name = "MoveUnitEvent"
moveEvent.Parent = ReplicatedStorage

local activeUnits = {
    ["Unit_1"] = {q = 0, r = 0, owner = 1, maxMoves = 2, currentMoves = 2}
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
    
    local neighbors = HexGridMath.GetNeighbors(unit.q, unit.r)
    local isValidMove = false
    for _, n in ipairs(neighbors) do
        if n.q == targetQ and n.r == targetR then
            isValidMove = true
            break
        end
    end
    
    if isValidMove and unit.currentMoves > 0 then
        unit.q = targetQ
        unit.r = targetR
        unit.currentMoves -= 1
        
        print(string.format("Server: Einheit %s bewegt nach (%d, %d)", unitId, targetQ, targetR))
        moveEvent:FireAllClients(unitId, targetQ, targetR)
    end
end)