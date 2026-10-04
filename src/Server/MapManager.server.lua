local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ElevationGenerator = require(ServerScriptService:WaitForChild("ElevationGenerator"))
local SoilGenerator = require(ServerScriptService:WaitForChild("SoilGenerator"))

local MapManager = {}
MapManager.GridData = {}

function MapManager.GenerateMap(radius)
    MapManager.GridData = {}
    print("Server: Generiere raue 3D-Weltkarte mit fraktalem Noise...")
    
    local seed = math.random(1, 100000)
    
    for q = -radius, radius do
        local r1 = math.max(-radius, -q - radius)
        local r2 = math.min(radius, -q + radius)
        for r = r1, r2 do
            local key = q .. "_" .. r
            
            -- Koordinaten für den Noise
            local scale = 0.12
            local nx = (q + r/2) * scale
            local ny = (r * math.sqrt(3)/2) * scale
            
            -- Oktave 1: Weiche, riesige Landmassen
            local baseNoise = math.noise(nx + seed, ny + seed, seed) + 0.5 
            
            -- Oktave 2: Hohe Frequenz für raue Details (bricht die Gleichmäßigkeit)
            local detailNoise = math.noise(nx * 3 + seed, ny * 3 + seed, seed + 100) + 0.5
            
            -- Kombination: 80% Grundform, 20% raue Störfaktoren
            local combinedNoise = (baseNoise * 0.80) + (detailNoise * 0.20)
            local noiseVal = math.clamp(combinedNoise, 0, 1)
            
            local elevation, heightLevel = ElevationGenerator.Generate(q, r, noiseVal)
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
    print("Server: Map generiert!")
    return MapManager.GridData
end

local getMapFunc = Instance.new("RemoteFunction")
getMapFunc.Name = "GetMapData"
getMapFunc.Parent = ReplicatedStorage

getMapFunc.OnServerInvoke = function(player)
    if not MapManager.GridData["0_0"] then MapManager.GenerateMap(14) end
    return MapManager.GridData
end

MapManager.GenerateMap(14)

return MapManager