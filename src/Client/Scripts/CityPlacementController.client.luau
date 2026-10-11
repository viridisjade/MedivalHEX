local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local cityEvent = ReplicatedStorage:WaitForChild("CityEvent", 10)
local getCitiesFunc = ReplicatedStorage:WaitForChild("GetCitiesData", 10)
local getMapFunc = ReplicatedStorage:WaitForChild("GetMapData", 10)

if not cityEvent or not getCitiesFunc or not getMapFunc then return end

local mouse = Players.LocalPlayer:GetMouse()
local mapData = getMapFunc:InvokeServer() or {}

-- Gleiche dynamische Höhenabfrage wie bei den Einheiten!
local function GetSurfaceY(q, r)
    local key = q .. "_" .. r
    local hexData = mapData[key]
    if not hexData then return 0 end
    
    local hasSoil = (hexData.Soil and hexData.Soil ~= "None")
    return HexGridMath.GetSurfaceHeight(hexData.HeightLevel, hasSoil)
end

-- Baut das physische Modell der Stadt in die Welt
local function RenderCity(data)
    local cityModel = workspace:FindFirstChild("City_" .. data.q .. "_" .. data.r)
    if cityModel then return end -- Render nicht doppelt
    
    cityModel = Instance.new("Part")
    cityModel.Name = "City_" .. data.q .. "_" .. data.r
    cityModel.Shape = Enum.PartType.Block
    cityModel.Size = Vector3.new(4, 5, 4) -- Ein wuchtiger Turm/Block als Stadt
    cityModel.Color = Color3.fromRGB(231, 76, 60) -- Rotes Imperium
    cityModel.Material = Enum.Material.Wood
    cityModel.Anchored = true
    
    -- Exakt auf die Oberfläche setzen (+2.5 für den eigenen Mittelpunkt)
    local surfaceY = GetSurfaceY(data.q, data.r)
    cityModel.Position = HexGridMath.AxialToWorld(data.q, data.r, surfaceY + 2.5)
    
    cityModel.Parent = workspace
end

-- Lade alle bestehenden Städte beim Start
local existingCities = getCitiesFunc:InvokeServer()
for _, city in pairs(existingCities) do
    RenderCity(city)
end

-- Höre auf neue Städte vom Server
cityEvent.OnClientEvent:Connect(function(action, data)
    if action == "RenderCity" then
        RenderCity(data)
    end
end)

-- Hotkey: 'C' drücken, während man über ein Hex hovert, um zu siedeln
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.C then
        local target = mouse.Target
        if target and string.sub(target.Name, 1, 4) == "Hex_" then
            local _, _, qStr, rStr = string.find(target.Name, "Hex_(-?%d+)_(-?%d+)")
            if qStr and rStr then
                local q, r = tonumber(qStr), tonumber(rStr)
                
                -- Verhindern, dass auf Wasser gesiedelt wird (nur rudimentäre Client-Prüfung)
                local hexData = mapData[q .. "_" .. r]
                if hexData and hexData.Elevation ~= "Water" then
                    cityEvent:FireServer("Found", q, r)
                else
                    print("Client: Du kannst nicht im Wasser siedeln!")
                end
            end
        end
    end
end)

print("Client: CityPlacementController (Hotkey 'C') bereit!")