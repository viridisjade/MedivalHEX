local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local mouse = Players.LocalPlayer:GetMouse()
local moveEvent = ReplicatedStorage:WaitForChild("MoveUnitEvent", 10)
local getUnitsFunc = ReplicatedStorage:WaitForChild("GetUnitsData", 10)
local getMapFunc = ReplicatedStorage:WaitForChild("GetMapData", 10)

if not moveEvent or not getUnitsFunc or not getMapFunc then return end

local mapData = getMapFunc:InvokeServer() or {}
local selectedUnitId = nil
local unitParts = {}
local pathLineParts = {}

local function GetSurfaceY(q, r)
    local key = q .. "_" .. r
    local hexData = mapData[key]
    if not hexData then return 0 end
    local hasSoil = (hexData.Soil and hexData.Soil ~= "None")
    return HexGridMath.GetSurfaceHeight(hexData.HeightLevel, hasSoil)
end

local function ClearPathLines()
    for _, part in ipairs(pathLineParts) do
        if part and part.Parent then part:Destroy() end
    end
    pathLineParts = {}
end

local function DrawPathLine(path, uData)
    ClearPathLines()
    if not path or #path == 0 then return end

    local points = {}
    local startY = GetSurfaceY(uData.q, uData.r) + 0.5
    table.insert(points, HexGridMath.AxialToWorld(uData.q, uData.r, startY))
    
    for _, step in ipairs(path) do
        local stepY = GetSurfaceY(step.q, step.r) + 0.5
        table.insert(points, HexGridMath.AxialToWorld(step.q, step.r, stepY))
    end

    for i = 1, #points - 1 do
        local p1 = points[i]
        local p2 = points[i + 1]
        
        local linePart = Instance.new("Part")
        linePart.Name = "PathLineSegment"
        linePart.Anchored = true
        linePart.CanCollide = false
        linePart.Material = Enum.Material.Neon
        linePart.Color = Color3.fromRGB(241, 196, 15) -- Gelber Pfad
        
        local distance = (p1 - p2).Magnitude
        linePart.Size = Vector3.new(0.6, 0.6, distance)
        linePart.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -distance / 2)
        linePart.Parent = workspace
        table.insert(pathLineParts, linePart)
    end
end

-- Erstellt die Einheiten und die schwebende Krone
local function RenderUnits()
    local unitsData = getUnitsFunc:InvokeServer()
    for unitId, data in pairs(unitsData) do
        local part = workspace:FindFirstChild(unitId)
        if not part then
            part = Instance.new("Part")
            part.Name = unitId
            part.Shape = Enum.PartType.Cylinder
            part.Size = Vector3.new(4, 2.5, 2.5) -- Die Figuren etwas dicker gemacht
            part.Color = data.color
            part.Anchored = true
            part.Parent = workspace
            
            -- Wenn diese Einheit der König ist, Krone hinzufügen!
            if data.isKing then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "CrownUI"
                billboard.Size = UDim2.new(0, 100, 0, 100)
                billboard.StudsOffset = Vector3.new(0, 4, 0) -- Schwebt über der Figur
                billboard.AlwaysOnTop = true
                
                local crownText = Instance.new("TextLabel")
                crownText.Size = UDim2.new(1, 0, 1, 0)
                crownText.BackgroundTransparency = 1
                crownText.Text = "👑" -- Visuelles UI-Symbol für den König
                crownText.TextScaled = true
                crownText.Parent = billboard
                
                billboard.Parent = part
            end
        end
        local surfaceY = GetSurfaceY(data.q, data.r)
        part.Position = HexGridMath.AxialToWorld(data.q, data.r, surfaceY + 1.25)
        
        -- CFrame so anpassen, dass der Zylinder steht, falls nötig (Standard-Roblox-Zylinder liegen auf der X-Achse)
        part.CFrame = CFrame.new(part.Position) * CFrame.Angles(0, 0, math.rad(90))
        
        unitParts[unitId] = part
    end
end

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
    
    -- Einheitenauswahl (Klick auf die Einheit)
    for unitId, part in pairs(unitParts) do
        if part == target or target.Parent == part then
            -- Letzte Einheit zurückfärben
            local allUnits = getUnitsFunc:InvokeServer()
            if selectedUnitId and unitParts[selectedUnitId] then
                unitParts[selectedUnitId].Color = allUnits[selectedUnitId].color
            end
            
            selectedUnitId = unitId
            part.Color = Color3.fromRGB(241, 196, 15) -- Gold für Selektion
            return
        end
    end
    
    -- Einheit bewegen (Klick auf ein Hex-Feld)
    if selectedUnitId and string.sub(target.Name, 1, 4) == "Hex_" then
        local _, _, qStr, rStr = string.find(target.Name, "Hex_(-?%d+)_(-?%d+)")
        if qStr and rStr then
            local targetQ = tonumber(qStr)
            local targetR = tonumber(rStr)
            
            local unitsData = getUnitsFunc:InvokeServer()
            local uData = unitsData[selectedUnitId]
            local path = HexGridMath.FindPath(uData.q, uData.r, targetQ, targetR)
            
            if path and #path <= uData.currentMoves then
                moveEvent:FireServer(selectedUnitId, targetQ, targetR, path)
                ClearPathLines()
            end
        end
    end
end)

moveEvent.OnClientEvent:Connect(function(unitId, path)
    local part = workspace:FindFirstChild(unitId)
    local unitsData = getUnitsFunc:InvokeServer()
    
    if part and path then
        task.spawn(function()
            for _, step in ipairs(path) do
                local surfaceY = GetSurfaceY(step.q, step.r)
                local targetWorldPos = HexGridMath.AxialToWorld(step.q, step.r, surfaceY + 1.25)
                
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(part, tweenInfo, {Position = targetWorldPos})
                tween:Play()
                tween.Completed:Wait()
            end
            -- Farbe nach Bewegung auf Fraktionsfarbe zurücksetzen
            part.Color = unitsData[unitId].color
        end)
    end
    selectedUnitId = nil
    ClearPathLines()
end)

task.wait(1.5)
RenderUnits()
print("Client: Kriegssimulator-UI (Kronen & Pfade) geladen!")