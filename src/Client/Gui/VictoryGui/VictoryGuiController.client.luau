local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local victoryEvent = ReplicatedStorage:WaitForChild("VictoryEvent", 10)
if not victoryEvent then return end

victoryEvent.OnClientEvent:Connect(function(winnerName, loserName)
    local player = Players.LocalPlayer
    
    -- Prüfen, ob schon ein Siegesbildschirm existiert
    local gui = player.PlayerGui:FindFirstChild("VictoryGui")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "VictoryGui"
        gui.IgnoreGuiInset = true -- Überdeckt den ganzen Bildschirm
        gui.Parent = player.PlayerGui
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        bg.BackgroundTransparency = 0.2
        bg.Parent = gui
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.8, 0, 0.4, 0)
        label.Position = UDim2.new(0.1, 0, 0.3, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(241, 196, 15) -- Gold
        label.TextScaled = true
        label.Font = Enum.Font.Cinzel -- Epische Mittelalter-Schriftart
        
        -- Festlegen des Textes
        if winnerName == "Player1" then
            label.Text = "SCHACHMATT\n\nBLAU HAT GESIEGT!"
            label.TextColor3 = Color3.fromRGB(52, 152, 219)
        else
            label.Text = "SCHACHMATT\n\nROT HAT GESIEGT!"
            label.TextColor3 = Color3.fromRGB(231, 76, 60)
        end
        
        label.Parent = bg
    end
end)

print("Client: VictoryGuiController wartet auf das Spielende.")