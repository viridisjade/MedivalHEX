local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local combatEvent = ReplicatedStorage:WaitForChild("CombatEvent", 10)
if not combatEvent then return end

-- Beispiel: Wenn Einheiten angreifen, spielen wir einen visuellen Effekt ab oder zeigen Text
combatEvent.OnClientEvent:Connect(function(attackerId, targetQ, targetR, damage)
    print(string.format("Kampf-Event: %s hat bei (%d, %d) %d Schaden verursacht!", attackerId, targetQ, targetR, damage))
    
    -- Visuelles Feedback: Lass uns kurz die Kamera wackeln oder ein Partikel aufblitzen lassen
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = "-" .. damage .. " HP!"
    textLabel.Parent = billboard
    
    -- Platziere es provisorisch im Workspace (wird im nächsten Schritt an Einheiten gekoppelt)
    billboard.Parent = workspace
    task.wait(1)
    billboard:Destroy()
end)