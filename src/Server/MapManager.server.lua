local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ElevationGenerator = require(script.Parent.ElevationGenerator)
local SoilGenerator = require(script.Parent.SoilGenerator)

-- RemoteFunction erstellen, damit der Client die Karte abfragen kann
local getMapEvent = Instance.new("RemoteFunction")
getMapEvent.Name = "GetMapData"
getMapEvent.Parent = ReplicatedStorage

local MAP_RADIUS = 12
local mapData = {}
local tileCount = 0

local function GenerateWorld()
    print("Server: Generiere Hex-Welt...")
    -- Loopt in einem hexagonalen Muster
    for q = -MAP_RADIUS, MAP_RADIUS do
        for r = -MAP_RADIUS, MAP_RADIUS do
            if math.abs(q + r) <= MAP_RADIUS then
                local elevId = ElevationGenerator.Generate(q, r)
                local soilId = SoilGenerator.Generate(q, r, elevId)
                local hexId = q .. "_" .. r
                
                mapData[hexId] = {
                    q = q,
                    r = r,
                    elevation = elevId,
                    soil = soilId
                }
                tileCount = tileCount + 1
            end
        end
    end
    print("Server: Welt generiert! 2-Schichten-Daten für " .. tileCount .. " Felder gespeichert.")
end

GenerateWorld()

-- Schickt die Map-Daten an den Client, wenn er spawnt
getMapEvent.OnServerInvoke = function(player)
    return mapData
end
