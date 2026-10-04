local SoilGenerator = {}

function SoilGenerator.Generate(elevation, q, r, altNoiseVal)
    if elevation == "Water" or elevation == "Mountain" then
        return "None"
    end
    
    -- 1. Oktave: Die großen, zusammenhängenden Biome (wie bisher)
    local basePatch = math.noise(q * 0.08, r * 0.08, 999)
    
    -- 2. Oktave: Hochfrequente Streuung für kleine, isolierte Flecken
    local scatter = math.noise(q * 0.6, r * 0.6, 333)
    
    -- Wir mischen die kleine Streuung zu 35% in die großen Flächen
    local combinedNoise = basePatch + (scatter * 0.35)
    
    if elevation == "Hills" then
        -- Hügel: Vorwiegend Fels, aber durch die Streuung gibt es Bergwälder und grüne Hochebenen
        if combinedNoise > 0.15 then
            return "Forest" 
        elseif combinedNoise < -0.3 then
            return "Grassland" 
        else
            return "Rocky"  
        end
    elseif elevation == "Flat" then
        -- Flachland: Großes Grasland, durchsetzt mit Wäldern, Wüsten und kleinen Felsbrocken
        if combinedNoise > 0.20 then
            return "Forest"
        elseif combinedNoise < -0.35 then
            return "Desert"
        elseif combinedNoise > 0.10 and scatter > 0.3 then
            -- Ein isolierter Wald-Fleck im normalen Grasland
            return "Forest"
        elseif combinedNoise < -0.15 and scatter > 0.4 then
            -- Sehr seltene, kleine Felsvorkommen mitten im Flachland
            return "Rocky"
        else
            return "Grassland"
        end
    end
    
    return "Grassland"
end

return SoilGenerator