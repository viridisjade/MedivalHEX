local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local researchEvent = ReplicatedStorage:WaitForChild("ResearchTechEvent", 10)
local getTechFunc = ReplicatedStorage:WaitForChild("GetTechData", 10)

if not researchEvent or not getTechFunc then return end

local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TechTreeGui"
screenGui.Parent = playerGui

-- Tech-Tree Button (Öffnet/Schließt das Menü)
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 120, 0, 40)
openButton.Position = UDim2.new(0, 10, 0, 70)
openButton.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextScaled = true
openButton.Font = Enum.Font.SourceSansBold
openButton.Text = "TECHNOLOGIE"
openButton.Parent = screenGui

-- Tech-Fenster (Frame)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
frame.Visible = false
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Text = "Forschungsbaum"
title.Parent = frame

openButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    if frame.Visible then
        local data, definitions = getTechFunc:InvokeServer()
        print("Client: Tech-Daten geladen. Verfügbare Science: " .. data.Science)
    end
end)

researchEvent.OnClientEvent:Connect(function(status, techName, remainingScience)
    if status == "Success" then
        print("Client: Erfolgreich erforscht -> " .. techName)
    end
end)