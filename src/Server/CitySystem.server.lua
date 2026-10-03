local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local foundCityEvent = Instance.new("RemoteEvent")
foundCityEvent.Name = "FoundCityEvent"
foundCityEvent.Parent = ReplicatedStorage

local getCitiesFunc = Instance.new("RemoteFunction")
getCitiesFunc.Name = "GetCitiesData"
getCitiesFunc.Parent = ReplicatedStorage

-- Speichert alle Städte (CityId -> {q, r, owner, name, level})
local activeCities = {}
local cityCounter = 0

getCitiesFunc.OnServerInvoke = function(player)
    return activeCities
end

foundCityEvent.OnServerEvent:Connect(function(player, q, r)
    -- Prüfe, ob auf dem Feld bereits eine Stadt steht
    for _, city in pairs(activeCities) do
        if city.q == q and city.r == r then
            return -- Feld ist bereits besetzt
        end
    end
    
    cityCounter += 1
    local cityId = "City_" .. cityCounter
    
    activeCities[cityId] = {
        q = q,
        r = r,
        owner = player.UserId,
        name = "Stadt " .. cityCounter,
        level = 1
    }
    
    print(string.format("Server: Spieler %s hat neue Stadt bei (%d, %d) gegründet!", player.Name, q, r))
    
    -- Informiere alle Clients über die neue Stadt
    foundCityEvent:FireAllClients(cityId, q, r)
end)