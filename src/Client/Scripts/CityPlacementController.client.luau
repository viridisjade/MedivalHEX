local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HexGridMath = require(ReplicatedStorage:WaitForChild("HexGridMath"))

local mouse = Players.LocalPlayer:GetMouse()
local foundCityEvent = ReplicatedStorage:WaitForChild("FoundCityEvent", 10)
local getCitiesFunc = ReplicatedStorage:WaitForChild("GetCitiesData", 10)

if not foundCityEvent or not getCitiesFunc then return end

local cityParts = {}

local function RenderCities()
    local citiesData = getCitiesFunc:InvokeServer()
    for cityId, data in pairs(citiesData) do
        if not workspace:FindFirstChild(cityId) then
            local part = Instance.new("Part")
            part.Name = cityId
            part.Shape = Enum.PartType.Block
            part.Size = Vector3.new(6, 6, 6)
            part.Color = Color3.fromRGB(231, 76, 60) -- Roter Klotz als Stadtzentrum
            part.Anchored = true
            part.Position = HexGridMath.AxialToWorld(data.q, data.r, 3)
            part.Parent = workspace
            cityParts[cityId] = part
        end
    end
end

-- Wenn man die Taste 'C' drückt, wird auf dem aktuell anvisierten Hex-Feld eine Stadt gegründet
mouse.KeyDown:Connect(function(key)
    if key:lower() == "c" then
        local target = mouse.Target
        if target and string.sub(target.Name, 1, 4) == "Hex_" then
            local _, _, qStr, rStr = string.find(target.Name, "Hex_(-?%d+)_(-?%d+)")
            if qStr and rStr then
                local q = tonumber(qStr)
                local r = tonumber(rStr)
                print(string.format("Client: Versuche Stadt bei (%d, %d) zu gründen...", q, r))
                foundCityEvent:FireServer(q, r)
            end
        end
    end
end)

foundCityEvent.OnClientEvent:Connect(function(cityId, q, r)
    local part = Instance.new("Part")
    part.Name = cityId
    part.Shape = Enum.PartType.Block
    part.Size = Vector3.new(6, 6, 6)
    part.Color = Color3.fromRGB(231, 76, 60)
    part.Anchored = true
    part.Position = HexGridMath.AxialToWorld(q, r, 3)
    part.Parent = workspace
end)

task.wait(2)
RenderCities()