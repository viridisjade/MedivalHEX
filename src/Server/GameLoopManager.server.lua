local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent für Rundenwechsel
local roundEvent = Instance.new("RemoteEvent")
roundEvent.Name = "EndTurnEvent"
roundEvent.Parent = ReplicatedStorage

local currentRound = 1

print("Server: Runden-System gestartet. Aktuelle Runde: " .. currentRound)

roundEvent.OnServerEvent:Connect(function(player)
    currentRound += 1
    print("Server: Spieler " .. player.Name .. " hat die Runde beendet. Starte Runde " .. currentRound)
    
    -- Hier wird später die Wirtschaft, Einheitenbewegung und KI getriggert!
    
    -- Informiere alle Clients über die neue Runde
    roundEvent:FireAllClients(currentRound)
end)