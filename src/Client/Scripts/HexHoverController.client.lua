local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

local lastHovered = nil
local originalColor = nil

Mouse.Move:Connect(function()
    local target = Mouse.Target
    
    -- Prüfen, ob wir ein Hex-Feld treffen (Name beginnt mit "Hex_")
    if target and string.sub(target.Name, 1, 4) == "Hex_" then
        if lastHovered ~= target then
            -- Altes Feld zurücksetzen
            if lastHovered and originalColor then
                lastHovered.Color = originalColor
            end
            
            -- Neues Feld hervorheben
            lastHovered = target
            originalColor = target.Color
            target.Color = Color3.new(1, 1, 1) -- Weißes Highlight
        end
    else
        -- Maus ist nicht mehr auf der Karte
        if lastHovered and originalColor then
            lastHovered.Color = originalColor
            lastHovered = nil
            originalColor = nil
        end
    end
end)