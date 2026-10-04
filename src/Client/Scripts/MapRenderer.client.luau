local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local getMapFunc = ReplicatedStorage:WaitForChild("GetMapData", 10)
if not getMapFunc then return end

local mapData = getMapFunc:InvokeServer()
if not mapData then return end

local mapFolder = workspace:FindFirstChild("HexMap")
if mapFolder then mapFolder:ClearAllChildren() else
    mapFolder = Instance.new("Folder")
    mapFolder.Name = "HexMap"
    mapFolder.Parent = workspace
end

local exactDiameter = math.sqrt(3) * HexGridMath.HexSize

local function CreateHexPart(name, thickness, diameter, pos, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(thickness, diameter, diameter)
    part.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    part.Color = color
    part.Material = material
    part.Anchored = true
    return part
end

for _, data in pairs(mapData) do
    local hasSoil = (data.Soil and data.Soil ~= "None")
    
    -- Nutzt jetzt die zentrale Lookup-Tabelle
    local baseThickness = HexGridMath.HeightLookup[data.HeightLevel] or 4
    local baseHeightOffset = baseThickness / 2 
    
    local basePos = HexGridMath.AxialToWorld(data.q, data.r, baseHeightOffset)
    local baseName = hasSoil and "BaseHex" or string.format("Hex_%d_%d", data.q, data.r)
    
    local baseColor = Color3.fromRGB(120, 85, 43)
    local baseMat = Enum.Material.Slate
    
    if data.Elevation == "Water" then
        baseColor = Color3.fromRGB(41, 128, 185)
        baseMat = Enum.Material.SmoothPlastic
    elseif data.Elevation == "Mountain" then
        baseColor = Color3.fromRGB(90, 95, 100)
    end
    
    local basePart = CreateHexPart(baseName, baseThickness, exactDiameter, basePos, baseColor, baseMat)
    basePart.Parent = mapFolder

    if hasSoil then
        local soilThickness = 0.6 
        local soilPos = basePos + Vector3.new(0, (baseThickness / 2) + (soilThickness / 2), 0)
        local soilName = string.format("Hex_%d_%d", data.q, data.r)
        
        local soilColor = Color3.fromRGB(115, 190, 85) 
        local soilMat = Enum.Material.Grass
        
        if data.Soil == "Forest" then
            soilColor = Color3.fromRGB(25, 90, 45) 
            soilMat = Enum.Material.LeafyGrass
        elseif data.Soil == "Desert" then
            soilColor = Color3.fromRGB(241, 196, 15)
            soilMat = Enum.Material.Sand
        elseif data.Soil == "Rocky" then
            soilColor = Color3.fromRGB(149, 165, 166)
            soilMat = Enum.Material.Concrete
        end
        
        local soilPart = CreateHexPart(soilName, soilThickness, exactDiameter, soilPos, soilColor, soilMat)
        soilPart.Parent = mapFolder
    end
end