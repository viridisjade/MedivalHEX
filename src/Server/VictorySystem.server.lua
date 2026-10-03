local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local victoryEvent = Instance.new("RemoteEvent")
victoryEvent.Name = "VictoryEvent"
victoryEvent.Parent = ReplicatedStorage

local roundEvent = ReplicatedStorage:WaitForChild("EndTurnEvent")

-- Überprüft nach jeder Runde die Siegbedingungen (z.B. maximale Runden oder Städte-Anzahl)
roundEvent.OnServerEvent:Connect(function(player)
    -- Beispiel-Bedingung: Wenn Runde 30 erreicht ist oder ein Spieler dominiert
    -- Für unser Skelett simulieren wir einen Sieg bei Runde 20 als Test
    -- (Später wird hier z.B. geprüft, ob alle anderen Städte zerstört wurden)
    
    local currentRound = 20 -- Platzhalter, wird vom GameLoop gesteuert
    if currentRound >= 20 then
        print(string.format("Server: SPIELER %s HAT DAS SPIEL GEWONNEN!", player.Name))
        victoryEvent:FireAllClients(player.Name, "Dominanz-Sieg")
    end
end)