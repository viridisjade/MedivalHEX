local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Event, um den Clients mitzuteilen, wer gewonnen hat
local victoryEvent = Instance.new("RemoteEvent")
victoryEvent.Name = "VictoryEvent"
victoryEvent.Parent = ReplicatedStorage

-- BindableEvent für das kommende CombatSystem. 
-- Wenn eine Einheit stirbt, ruft das Kampfsystem dieses Event auf.
local unitDiedBindable = Instance.new("BindableEvent")
unitDiedBindable.Name = "UnitDiedBindable"
unitDiedBindable.Parent = ReplicatedStorage

unitDiedBindable.Event:Connect(function(deadUnitData)
    -- Die einzige Siegbedingung im gesamten Spiel:
    if deadUnitData.unitType == "King" then
        local loser = deadUnitData.ownerId
        -- Wenn Player1 den König verliert, gewinnt Player2 und umgekehrt
        local winner = (loser == "Player1") and "Player2" or "Player1"
        
        print(string.format("Server: SCHACHMATT! Der Koenig von %s ist gefallen! %s gewinnt das Spiel!", loser, winner))
        
        -- Allen Spielern den Sieger verkünden
        victoryEvent:FireAllClients(winner, loser)
    end
end)

print("Server: VictorySystem geladen. Einzige Win-Condition: Der Koenig muss sterben.")