local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local getMapFunc = ReplicatedStorage:WaitForChild("GetMapData", 10)
if not getMapFunc then return end

local mapData = getMapFunc:InvokeServer()
if not mapData then return end

-- Alten Map-Ordner aufräumen falls vorhanden
local mapFolder = workspace:FindFirstChild("HexMap")
if mapFolder then
    mapFolder:ClearAllChildren()
else
    mapFolder = Instance.new("Folder")
    mapFolder.Name = "HexMap"
    mapFolder.Parent = workspace
end

-- Generiere die Hex-Teile basierend auf den 2-Schichten-Daten (Elevation + Soil)
for _, data in pairs(mapData) do
    local part = Instance.new("Part")
    part.Name = string.format("Hex_%d_%d", data.q, data.r)
    part.Shape = Enum.PartType.Cylinder
    
    -- Höhe aus Layer 1 (Elevation -> HeightLevel) berechnen
    local heightOffset = (data.HeightLevel or 0) * 1.5
    part.Position = HexGridMath.AxialToWorld(data.q, data.r, heightOffset)
    part.Size = Vector3.new(6, 2, 6)
    part.Anchored = true
    
    -- Farbgebung basierend auf Elevation (Layer 1) und Soil (Layer 2)
    if data.Elevation == "Water" then
        part.Color = Color3.fromRGB(41, 128, 185) -- Blaues Wasser
        part.Material = Enum.Material.SmoothPlastic
    elseif data.Elevation == "Mountain" then
        part.Color = Color3.fromRGB(127, 140, 141) -- Felsiger Berg
        part.Material = Enum.Material.Slate
    elseif data.Soil == "Forest" then
        part.Color = Color3.fromRGB(39, 174, 96) -- Wald (Grün)
        part.Material = Enum.Material.Grass
    elseif data.Soil == "Desert" then
        part.Color = Color3.fromRGB(241, 196, 15) -- Wüste (Sand)
        part.Material = Enum.Material.Sand
    elseif data.Soil == "Rocky" then
        part.Color = Color3.fromRGB(149, 165, 166) -- Felsiges Hügelland
        part.Material = Enum.Material.Concrete
    else
        -- Standard Grasland / Flachland
        part.Color = Color3.fromRGB(46, 204, 113)
        part.Material = Enum.Material.Grass
    end
    
    part.Parent = mapFolder
end

print("Client: 2-Schichten Karte erfolgreich gerendert!")