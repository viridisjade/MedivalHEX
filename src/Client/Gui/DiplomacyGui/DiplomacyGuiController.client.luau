local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local diplomacyEvent = ReplicatedStorage:WaitForChild("DiplomacyEvent", 10)
local getDiplomacyFunc = ReplicatedStorage:WaitForChild("GetDiplomacyData", 10)

if not diplomacyEvent or not getDiplomacyFunc then return end

local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DiplomacyGui"
screenGui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 120, 0, 40)
openButton.Position = UDim2.new(0, 140, 0, 70)
openButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextScaled = true
openButton.Font = Enum.Font.SourceSansBold
openButton.Text = "DIPLOMATIE"
openButton.Parent = screenGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
frame.Visible = false
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Text = "Diplomatie-Uebersicht"
title.Parent = frame

openButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    if frame.Visible then
        local data = getDiplomacyFunc:InvokeServer()
        print("Client: Diplomatie-Daten erfolgreich abgerufen.")
    end
end)

diplomacyEvent.OnClientEvent:Connect(function(targetUserId, status)
    print(string.format("Client: Status mit Spieler %d aktualisiert auf: %s", targetUserId, status))
end)