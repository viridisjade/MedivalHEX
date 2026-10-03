local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local victoryEvent = ReplicatedStorage:WaitForChild("VictoryEvent", 10)
if not victoryEvent then return end

local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VictoryGui"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.5, -200, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(241, 196, 15) -- Goldener Sieges-Look
frame.Visible = false
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(44, 62, 80)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Text = "SPIEL GEWONNEN!"
title.Parent = frame

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, 0, 0, 100)
desc.Position = UDim2.new(0, 0, 0, 70)
desc.BackgroundTransparency = 1
desc.TextColor3 = Color3.fromRGB(44, 62, 80)
desc.TextScaled = true
desc.Font = Enum.Font.SourceSans
desc.Text = "Ehre und Ruhm gebühren deinem Reich."
desc.Parent = frame

victoryEvent.OnClientEvent:Connect(function(winnerName, victoryType)
    desc.Text = string.format("Fraktion %s errang einen %s!", winnerName, victoryType)
    frame.Visible = true
end)