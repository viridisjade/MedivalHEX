local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))
local UnitConfig = require(ReplicatedStorage:WaitForChild("GameConfigs"):WaitForChild("UnitConfig"))

local mouse = Players.LocalPlayer:GetMouse()
local moveEvent = ReplicatedStorage:WaitForChild("MoveUnitEvent", 10)
local endTurnEvent = ReplicatedStorage:WaitForChild("EndTurnEvent", 10)
local getUnitsFunc = ReplicatedStorage:WaitForChild("GetUnitsData", 10)
local getMapFunc = ReplicatedStorage:WaitForChild("GetMapData", 10)

if not moveEvent or not getUnitsFunc or not getMapFunc then return end

local mapData = getMapFunc:InvokeServer() or {}

-- NEU: Unser lokaler Datenspeicher, damit wir den Server nicht abfragen müssen!
local localUnitsData = {}
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

local function GetUnitColor(data)
    if data.ownerId == "Player1" then
        return data.currentMoves > 0 and Color3.fromRGB(52, 152, 219) or Color3.fromRGB(34, 100, 145)
    else
        return data.currentMoves > 0 and Color3.fromRGB(231, 76, 60) or Color3.fromRGB(145, 48, 38)
    end
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
        linePart.Color = Color3.fromRGB(46, 204, 113) 
        
        local distance = (p1 - p2).Magnitude
        linePart.Size = Vector3.new(0.6, 0.6, distance)
        linePart.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -distance / 2)
        linePart.Parent = workspace
        
        table.insert(pathLineParts, linePart)
    end
end

local function RenderUnits()
    for unitId, data in pairs(localUnitsData) do
        local part = workspace:FindFirstChild(unitId)
        
        if not part then
            local config = UnitConfig[data.unitType]
            local template = ReplicatedStorage:FindFirstChild(config.ModelName)
            
            if template then part = template:Clone()
            else
                part = Instance.new("Part")
                part.Shape = Enum.PartType.Cylinder
                part.Size = Vector3.new(4, 4, 4)
            end
            
            part.Name = unitId
            part.Anchored = true
            part.Parent = workspace
            
            if data.hasCrown then
                local crown = Instance.new("Part")
                crown.Name = "Crown"
                crown.Size = Vector3.new(1.5, 0.8, 1.5)
                crown.Color = Color3.fromRGB(241, 196, 15)
                crown.Material = Enum.Material.Neon
                crown.CanCollide = false
                crown.Anchored = false 
                crown.Parent = part
                
                local weld = Instance.new("Weld")
                weld.Part0 = part
                weld.Part1 = crown
                weld.C0 = CFrame.new(0, 4, 0)
                weld.Parent = crown
            end
        end
        
        -- Zuweisen der Farbe basierend auf den LOKALEN Daten
        part.Color = GetUnitColor(data)
        
        local surfaceY = GetSurfaceY(data.q, data.r)
        local targetWorldPos = HexGridMath.AxialToWorld(data.q, data.r, surfaceY + 2)
        part.CFrame = CFrame.new(targetWorldPos)
        
        unitParts[unitId] = part
    end
end

-- Hover (Greift jetzt nur noch blitzschnell auf den lokalen Speicher zu)
mouse.Move:Connect(function()
    if not selectedUnitId then return end
    local target = mouse.Target
    if not target or string.sub(target.Name, 1, 4) ~= "Hex_" then 
        ClearPathLines()
        return 
    end
    
    local _, _, qStr, rStr = string.find(target.Name, "Hex_(-?%d+)_(-?%d+)")
    if not qStr then return end
    
    local uData = localUnitsData[selectedUnitId]
    if not uData then return end
    
    local path = HexGridMath.FindPath(uData.q, uData.r, tonumber(qStr), tonumber(rStr))
    
    if path and #path <= uData.currentMoves then
        DrawPathLine(path, uData)
    else
        ClearPathLines()
    end
end)

-- Klick (Nutzt ebenfalls den lokalen Speicher)
mouse.Button1Down:Connect(function()
    local target = mouse.Target
    if not target then return end
    
    if target.Parent == workspace and string.sub(target.Name, 1, 5) == "Unit_" then
        local uData = localUnitsData[target.Name]
        if uData and uData.currentMoves > 0 then
            selectedUnitId = target.Name
            target.Color = Color3.fromRGB(241, 196, 15)
        else
            print("Client: Diese Einheit ist bereits erschöpft!")
        end
        return
    end
    
    if selectedUnitId and string.sub(target.Name, 1, 4) == "Hex_" then
        local _, _, qStr, rStr = string.find(target.Name, "Hex_(-?%d+)_(-?%d+)")
        if qStr and rStr then
            moveEvent:FireServer(selectedUnitId, tonumber(qStr), tonumber(rStr))
            ClearPathLines()
            selectedUnitId = nil
        end
    end
end)

-- Bewegen: Empfängt Rest-Moves vom Server und aktualisiert unseren lokalen Cache
moveEvent.OnClientEvent:Connect(function(unitId, path, remainingMoves)
    local part = workspace:FindFirstChild(unitId)
    
    -- Lokalen Speicher sofort patchen
    if localUnitsData[unitId] then
        localUnitsData[unitId].currentMoves = remainingMoves
        local lastStep = path[#path]
        localUnitsData[unitId].q = lastStep.q
        localUnitsData[unitId].r = lastStep.r
    end
    
    if part and path then
        task.spawn(function()
            for _, step in ipairs(path) do
                local surfaceY = GetSurfaceY(step.q, step.r)
                local targetWorldPos = HexGridMath.AxialToWorld(step.q, step.r, surfaceY + 2)
                
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(part, tweenInfo, {CFrame = CFrame.new(targetWorldPos)})
                tween:Play()
                tween.Completed:Wait()
            end
            RenderUnits()
        end)
    end
end)

-- Runde Beenden: Server schickt uns die brandneue Liste!
endTurnEvent.OnClientEvent:Connect(function(updatedUnits)
    if updatedUnits then
        print("Client: Neue Runde! Daten erhalten, Einheiten erholt.")
        localUnitsData = updatedUnits
        RenderUnits()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        endTurnEvent:FireServer()
        ClearPathLines()
        selectedUnitId = nil
    end
end)

-- EINMALIGER Abruf beim Start
task.spawn(function()
    localUnitsData = getUnitsFunc:InvokeServer() or {}
    RenderUnits()
end)

print("Client: MovementController nutzt jetzt performantes lokales Caching!")