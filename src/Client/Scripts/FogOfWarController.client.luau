-- SCHALTER: Auf 'true' setzen, um Fog of War wieder zu aktivieren
local FOG_ENABLED = false 

if not FOG_ENABLED then
    print("Client: Fog of War ist fuer die Map-Vorschau temporaer deaktiviert.")
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fogFunc = ReplicatedStorage:WaitForChild("GetFogData", 10)
local getUnitsFunc = ReplicatedStorage:WaitForChild("GetUnitsData", 10)
local getCitiesFunc = ReplicatedStorage:WaitForChild("GetCitiesData", 10)

if not fogFunc then return end

local function UpdateFogOfWar()
    local units = getUnitsFunc and getUnitsFunc:InvokeServer() or {}
    local cities = getCitiesFunc and getCitiesFunc:InvokeServer() or {}
    
    local success, visibleHexes = pcall(function()
        return fogFunc:InvokeServer(units, cities)
    end)
    
    if not success or not visibleHexes then return end
    
    local mapFolder = workspace:FindFirstChild("HexMap")
    if not mapFolder then return end
    
    for _, part in ipairs(mapFolder:GetChildren()) do
        if string.sub(part.Name, 1, 4) == "Hex_" then
            local hexId = string.sub(part.Name, 5)
            if visibleHexes[hexId] then
                part.Transparency = (part.Color == Color3.fromRGB(41, 128, 185)) and 0.4 or 0
            else
                part.Transparency = 0.85
            end
        end
    end
end

task.spawn(function()
    while true do
        pcall(UpdateFogOfWar)
        task.wait(1)
    end
end)