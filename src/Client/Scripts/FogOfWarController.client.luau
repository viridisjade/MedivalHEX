local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fogFunc = ReplicatedStorage:WaitForChild("GetFogData", 10)
local getUnitsFunc = ReplicatedStorage:WaitForChild("GetUnitsData", 10)
local getCitiesFunc = ReplicatedStorage:WaitForChild("GetCitiesData", 10)

if not fogFunc then return end

local function UpdateFogOfWar()
    -- Hole die echten Einheiten- und Städtedaten vom Server
    local units = getUnitsFunc and getUnitsFunc:InvokeServer() or {}
    local cities = getCitiesFunc and getCitiesFunc:InvokeServer() or {}
    
    -- Frage den Server nach den sichtbaren Feldern basierend auf der aktuellen Realität
    local success, visibleHexes = pcall(function()
        return fogFunc:InvokeServer(units, cities)
    end)
    
    if not success or not visibleHexes then return end
    
    -- Gehe alle Hex-Teile auf der Karte durch
    local mapFolder = workspace:FindFirstChild("HexMap")
    if not mapFolder then return end
    
    for _, part in ipairs(mapFolder:GetChildren()) do
        if string.sub(part.Name, 1, 4) == "Hex_" then
            local hexId = string.sub(part.Name, 5) -- Entfernt "Hex_" (Format: q_r)
            if visibleHexes[hexId] then
                -- Sichtbar: Volle Deckkraft
                part.Transparency = (part.Color == Color3.fromRGB(41, 128, 185)) and 0.4 or 0
            else
                -- Im Nebel: Stark abgedunkelt
                part.Transparency = 0.85
            end
        end
    end
end

-- Reagiere auf Bewegungen oder reche alle Sekunde nach
task.spawn(function()
    while true do
        pcall(UpdateFogOfWar)
        task.wait(1)
    end
end)