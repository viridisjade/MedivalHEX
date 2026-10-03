local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fogFunc = ReplicatedStorage:WaitForChild("GetFogData", 10)

if not fogFunc then return end

local function UpdateFogOfWar()
    -- Beispielhafte Abfrage an den Server mit unseren aktuellen Positionen
    local visibleHexes = fogFunc:InvokeServer(
        {["Unit_1"] = {q = 0, r = 0}}, 
        {}
    )
    
    -- Gehe alle Hex-Teile auf der Karte durch
    local mapFolder = workspace:FindFirstChild("HexMap")
    if not mapFolder then return end
    
    for _, part in ipairs(mapFolder:GetChildren()) do
        local hexId = string.sub(part.Name, 5) -- Entfernt "Hex_"
        if visibleHexes[hexId] then
            -- Sichtbar: Volle Deckkraft
            part.Transparency = (part.Color == Color3.fromRGB(41, 128, 185)) and 0.4 or 0
        else
            -- Im Nebel: Stark abgedunkelt oder unsichtbar
            part.Transparency = 0.85
        end
    end
end

-- Aktualisiere den Nebel periodisch oder bei Aktionen
task.spawn(function()
    while true do
        pcall(UpdateFogOfWar)
        task.wait(2)
    end
end)