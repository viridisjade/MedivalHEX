local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local cityEvent = Instance.new("RemoteEvent")
cityEvent.Name = "CityEvent"
cityEvent.Parent = ReplicatedStorage

local getCitiesFunc = Instance.new("RemoteFunction")
getCitiesFunc.Name = "GetCitiesData"
getCitiesFunc.Parent = ReplicatedStorage

-- Speichert alle Städte (Key = "q_r")
local activeCities = {}

getCitiesFunc.OnServerInvoke = function(player)
    return activeCities
end

cityEvent.OnServerEvent:Connect(function(player, action, q, r)
    if action == "Found" then
        local key = q .. "_" .. r
        
        -- Prüfen, ob hier schon eine Stadt steht
        if activeCities[key] then
            print("Server: Hier steht bereits eine Stadt!")
            return
        end
        
        -- Stadt in der Datenbank anlegen
        activeCities[key] = {
            q = q, 
            r = r, 
            ownerId = player.UserId, 
            ownerName = player.Name,
            population = 1
        }
        
        print(string.format("Server: Stadt gegründet von %s auf (%d, %d)", player.Name, q, r))
        
        -- Alle Clients anweisen, das 3D-Modell der Stadt zu rendern
        cityEvent:FireAllClients("RenderCity", activeCities[key])
    end
end)