local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local mouse = Players.LocalPlayer:GetMouse()
local moveEvent = ReplicatedStorage:WaitForChild("MoveUnitEvent", 10)
local getUnitsFunc = ReplicatedStorage:WaitForChild("GetUnitsData", 10)

if not moveEvent or not getUnitsFunc then return end

local selectedUnitId = nil
local unitParts = {}
local pathLineParts = {}

local function ClearPathLines()
    for _, part in ipairs(pathLineParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    pathLineParts = {}
end

-- Zeichnet eine neon-grüne Linie entlang des Pfades
local function DrawPathLine(path, uData)
    ClearPathLines()
    if not path or #path == 0 then return end

    -- Sammle alle Koordinaten-Punkte (Start bei der Einheit, dann durch den Pfad)
    local points = {}
    table.insert(points, HexGridMath.AxialToWorld(uData.q, uData.r, 5.2))
    for _, step in ipairs(path) do
        table.insert(points, HexGridMath.AxialToWorld(step.q, step.r, 5.2))
    end

    -- Erstelle Segmente zwischen den Punkten
    for i = 1, #points - 1 do
        local p1 = points[i]
        local p2 = points[i + 1]
        
        local linePart = Instance.new("Part")
        linePart.Name = "PathLineSegment"
        linePart.Anchored = true
        linePart.CanCollide = false
        linePart.Material = Enum.Material.Neon
        linePart.Color = Color3.fromRGB(46, 204, 113) -- Neon-Grün
        
        local distance = (p1 - p2).Magnitude
        linePart.Size = Vector3.new(0.6, 0.6, distance)
        linePart.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -distance / 2)
        linePart.Parent = workspace
        
        table.insert(pathLineParts, linePart)
    end
end

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

-- Hover-Logik: Zeichnet in Echtzeit die Ziellinie
mouse.Move:Connect(function()
    if not selectedUnitId then return end
    local target = mouse.Target
    if not target or string.sub(target.Name, 1, 4) ~= "Hex_" then 
        ClearPathLines()
        return 
    end
    
    local _, _, qStr, rStr = string.find(target.Name, "Hex_(-?%d+)_(-?%d+)")
    if not qStr then return end
    local targetQ, targetR = tonumber(qStr), tonumber(rStr)
    
    local unitsData = getUnitsFunc:InvokeServer()
    local uData = unitsData[selectedUnitId]
    if not uData then return end
    
    local path = HexGridMath.FindPath(uData.q, uData.r, targetQ, targetR)
    
    if path and #path <= uData.currentMoves then
        DrawPathLine(path, uData)
    else
        ClearPathLines()
    end
end)

mouse.Button1Down:Connect(function()
    local target = mouse.Target
    if not target then return end
    
    if unitParts["Unit_1"] == target then
        selectedUnitId = "Unit_1"
        print("Client: Einheit ausgewählt. Bewege die Maus über die Karte, um den Weg als Linie zu sehen.")
        target.Color = Color3.fromRGB(241, 196, 15)
        return
    end
    
    if selectedUnitId and string.sub(target.Name, 1, 4) == "Hex_" then
        local _, _, qStr, rStr = string.find(target.Name, "Hex_(-?%d+)_(-?%d+)")
        if qStr and rStr then
            local targetQ = tonumber(qStr)
            local targetR = tonumber(rStr)
            
            print("Client: Sende Bewegungs-Pfad an Server...")
            moveEvent:FireServer(selectedUnitId, targetQ, targetR)
            ClearPathLines()
        end
    end
end)

moveEvent.OnClientEvent:Connect(function(unitId, path)
    local part = workspace:FindFirstChild(unitId)
    if part and path then
        task.spawn(function()
            for _, step in ipairs(path) do
                local targetWorldPos = HexGridMath.AxialToWorld(step.q, step.r, 5)
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(part, tweenInfo, {Position = targetWorldPos})
                tween:Play()
                tween.Completed:Wait()
            end
            part.Color = Color3.fromRGB(52, 152, 219)
        end)
    end
    selectedUnitId = nil
    ClearPathLines()
end)

task.wait(1.5)
RenderUnits()