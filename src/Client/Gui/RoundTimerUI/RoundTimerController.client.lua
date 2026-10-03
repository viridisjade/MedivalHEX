local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui erstellen oder holen
local screenGui = playerGui:WaitForChild("RoundGui", 10)
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RoundGui"
    screenGui.Parent = playerGui
end

-- Runden-Anzeige Label (oben Mitte)
local roundLabel = screenGui:FindFirstChild("RoundLabel") or Instance.new("TextLabel")
roundLabel.Name = "RoundLabel"
roundLabel.Size = UDim2.new(0, 200, 0, 50)
roundLabel.Position = UDim2.new(0.5, -100, 0, 10)
roundLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
roundLabel.BackgroundTransparency = 0.5
roundLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
roundLabel.TextScaled = true
roundLabel.Font = Enum.Font.SourceSansBold
roundLabel.Text = "Runde: 1"
roundLabel.Parent = screenGui

-- Ressourcen-Anzeige (oben links)
local resourceLabel = screenGui:FindFirstChild("ResourceLabel") or Instance.new("TextLabel")
resourceLabel.Name = "ResourceLabel"
resourceLabel.Size = UDim2.new(0, 250, 0, 50)
resourceLabel.Position = UDim2.new(0, 10, 0, 10)
resourceLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
resourceLabel.BackgroundTransparency = 0.5
resourceLabel.TextColor3 = Color3.fromRGB(255, 223, 0)
resourceLabel.TextScaled = true
resourceLabel.Font = Enum.Font.SourceSansBold
resourceLabel.Text = "Gold: 100 | Nahrung: 50"
resourceLabel.Parent = screenGui

-- "Runde beenden" Button (unten rechts)
local endButton = screenGui:FindFirstChild("EndTurnButton") or Instance.new("TextButton")
endButton.Name = "EndTurnButton"
endButton.Size = UDim2.new(0, 160, 0, 50)
endButton.Position = UDim2.new(1, -180, 1, -70)
endButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
endButton.TextColor3 = Color3.fromRGB(255, 255, 255)
endButton.TextScaled = true
endButton.Font = Enum.Font.SourceSansBold
endButton.Text = "RUNDE BEENDEN"
endButton.Parent = screenGui

local roundEvent = ReplicatedStorage:WaitForChild("EndTurnEvent")
local resourceEvent = ReplicatedStorage:WaitForChild("ResourceUpdateEvent")

-- Alte Verbindungen verhindern (falls Skript neu lädt)
if _G.EndTurnConnected then
    _G.EndTurnConnected:Disconnect()
end
_G.EndTurnConnected = endButton.MouseButton1Click:Connect(function()
    roundEvent:FireServer()
end)

roundEvent.OnClientEvent:Connect(function(newRound)
    roundLabel.Text = "Runde: " .. newRound
end)

resourceEvent.OnClientEvent:Connect(function(gold, food)
    resourceLabel.Text = string.format("Gold: %d | Nahrung: %d", gold, food)
end)