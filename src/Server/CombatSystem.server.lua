local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local combatEvent = Instance.new("RemoteEvent")
combatEvent.Name = "CombatEvent"
combatEvent.Parent = ReplicatedStorage

-- Wir erweitern die Einheiten-Daten um HP und Angriffsstärke
-- (Hinweis: Läuft hier über ein gemeinsames State-Modell oder direkt im UnitSystem. 
-- Für unser Skelett bauen wir eine direkte Schnittstelle ein.)

combatEvent.OnServerEvent:Connect(function(player, attackerId, targetQ, targetR)
    print(string.format("Server: Kampf-Anfrage von %s auf Feld (%d, %d)", attackerId, targetQ, targetR))
    
    -- Einfache Schadenssimulation für das Skelett:
    -- Wir lassen die Einheit auf dem Ziel-Hex "Schaden" zufügen
    
    -- Informiere alle Clients über den Kampf
    combatEvent:FireAllClients(attackerId, targetQ, targetR, 25) -- 25 Schadenspunkte
end)