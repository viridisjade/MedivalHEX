local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Korrekter Zugriff auf die Geschwister-Module im ServerScriptService
local ElevationGenerator = require(ServerScriptService:WaitForChild("ElevationGenerator"))
local SoilGenerator = require(ServerScriptService:WaitForChild("SoilGenerator"))

local MapManager = {}
MapManager.GridData = {}

function MapManager.GenerateMap(radius)
    MapManager.GridData = {}
    print("Server: Starte 2-Schichten World-Building (Elevation -> Soil)...")
    
    for q = -radius, radius do
        local r1 = math.max(-radius, -q - radius)
        local r2 = math.min(radius, -q + radius)
        for r = r1, r2 do
            local key = q .. "_" .. r
            
            -- Schritt 1: Layer 1 (Elevation) generieren
            local noiseVal = (math.noise(q * 0.1, r * 0.1) + 1) / 2
            local elevation, heightLevel = ElevationGenerator.Generate(q, r, noiseVal)
            
            -- Schritt 2: Layer 2 (Soil / Biome) direkt auf die Elevation legen
            local soil = SoilGenerator.Generate(elevation, q, r, noiseVal)
            
            MapManager.GridData[key] = {
                q = q,
                r = r,
                Elevation = elevation,
                HeightLevel = heightLevel,
                Soil = soil
            }
        end
    end
    print("Server: 2-Schichten Welt erfolgreich generiert!")
    return MapManager.GridData
end

-- RemoteFunction für den Client zur Kartenabfrage
local getMapFunc = Instance.new("RemoteFunction")
getMapFunc.Name = "GetMapData"
getMapFunc.Parent = ReplicatedStorage

getMapFunc.OnServerInvoke = function(player)
    if next(MapManager.GridData) == nil then
        MapManager.GenerateMap(4)
    end
    return MapManager.GridData
end

-- Initiale Generierung beim Start
MapManager.GenerateMap(4)

return MapManager