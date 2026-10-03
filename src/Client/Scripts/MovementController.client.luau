local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local mouse = Players.LocalPlayer:GetMouse()

-- Sicherer Zugriff mit Timeout, um Infinite Yield zu verhindern
local moveEvent = ReplicatedStorage:WaitForChild("MoveUnitEvent", 10)
local getUnitsFunc = ReplicatedStorage:WaitForChild("GetUnitsData", 10)

if not moveEvent or not getUnitsFunc then
    warn("Client: Einheiten-Events konnten nicht geladen werden!")
    return
end

local selectedUnitId = nil
local unitParts = {}

local function RenderUnits()
    local unitsData = getUnitsFunc:InvokeServer()
    for unitId, data in pairs(unitsData) do
        local part = workspace:FindFirstChild(unitId)
        if not part then
            part = Instance.new("Part")
            part.Name = unitId
            part.Shape = Enum.PartType.Cylinder
            part.Size = Vector3.new(5, 3, 3)
            part.Color = Color3.fromRGB(52, 152, 219)
            part.Anchored = true
            part.Parent = workspace
        end
        part.Position = HexGridMath.AxialToWorld(data.q, data.r, 5)
        unitParts[unitId] = part
    end
end

mouse.Button1Down:Connect(function()
    local target = mouse.Target
    if not target then return end
    
    if unitParts["Unit_1"] == target then
        selectedUnitId = "Unit_1"
        print("Client: Einheit ausgewählt!")
        target.Color = Color3.fromRGB(241, 196, 15)
        return
    end
    
    if selectedUnitId and string.sub(target.Name, 1, 4) == "Hex_" then
        local _, _, qStr, rStr = string.find(target.Name, "Hex_(-?%d+)_(-?%d+)")
        if qStr and rStr then
            local targetQ = tonumber(qStr)
            local targetR = tonumber(rStr)
            
            print(string.format("Client: Sende Bewegungsbefehl zu (%d, %d)", targetQ, targetR))
            moveEvent:FireServer(selectedUnitId, targetQ, targetR)
        end
    end
end)

moveEvent.OnClientEvent:Connect(function(unitId, newQ, newR)
    local part = workspace:FindFirstChild(unitId)
    if part then
        part.Position = HexGridMath.AxialToWorld(newQ, newR, 5)
        part.Color = Color3.fromRGB(52, 152, 219)
    end
    selectedUnitId = nil
end)

task.wait(1.5)
RenderUnits()