local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local roundEvent = ReplicatedStorage:WaitForChild("EndTurnEvent")

-- Speichert die Ressourcen pro Spieler (PlayerId -> {Gold, Food})
local playerResources = {}

Players.PlayerAdded:Connect(function(player)
    playerResources[player.UserId] = {Gold = 100, Food = 50}
end)

Players.PlayerRemoving:Connect(function(player)
    playerResources[player.UserId] = nil
end)

-- RemoteEvent für Ressourcen-Updates zum Client
local resourceEvent = Instance.new("RemoteEvent")
resourceEvent.Name = "ResourceUpdateEvent"
resourceEvent.Parent = ReplicatedStorage

-- Bei Rundenwechsel Ressourcen generieren
roundEvent.OnServerEvent:Connect(function(player)
    local data = playerResources[player.UserId]
    if data then
        -- Einfaches Einkommen pro Runde (später durch Städte/Gebäude bestimmt)
        data.Gold += 10
        data.Food += 5
        
        print(string.format("Server: Spieler %s hat nun Gold: %d, Nahrung: %d", player.Name, data.Gold, data.Food))
        
        -- Sende neue Werte an den Client
        resourceEvent:FireClient(player, data.Gold, data.Food)
    end
end)