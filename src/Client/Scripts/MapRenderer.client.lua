local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))
local GameConfigs = ReplicatedStorage:WaitForChild("GameConfigs")
local ElevationConfig = require(GameConfigs:WaitForChild("ElevationConfig"))
local SoilConfig = require(GameConfigs:WaitForChild("SoilConfig"))

local function DrawMap()
    print("Client: Warte auf Server-Kartendaten...")
    -- Warte explizit, bis der Server das Event erstellt hat
    local getMapEvent = ReplicatedStorage:WaitForChild("GetMapData", 10) 
    
    if not getMapEvent then
        warn("Fehler: Server hat 'GetMapData' nicht rechtzeitig erstellt!")
        return
    end

    local mapData = getMapEvent:InvokeServer()
    
    local mapFolder = Instance.new("Folder")
    mapFolder.Name = "HexMap"
    mapFolder.Parent = workspace

    for hexId, hex in pairs(mapData) do
        local elevData = ElevationConfig[hex.elevation]
        local soilData = SoilConfig[hex.soil]
        
        local pos = HexGridMath.AxialToWorld(hex.q, hex.r, elevData.Height)
        
        local part = Instance.new("Part")
        part.Name = "Hex_" .. hexId
        part.Shape = Enum.PartType.Cylinder
        part.Orientation = Vector3.new(0, 90, 90)
        part.Size = Vector3.new(4, 18, 18) 
        part.Position = pos
        part.Anchored = true
        part.Color = soilData.Color
        
        if hex.elevation == 1 then
            part.Color = Color3.fromRGB(41, 128, 185)
            part.Material = Enum.Material.Glass
            part.Transparency = 0.4
        else
            part.Material = Enum.Material.Grass
        end
        
        part.Parent = mapFolder
    end
    print("Client: Hex-Welt erfolgreich gerendert!")
end

-- Ein kleiner Delay, um dem Server Zeit zum Laden zu geben
task.wait(1)
DrawMap()