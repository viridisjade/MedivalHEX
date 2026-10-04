local ElevationGenerator = {}

function ElevationGenerator.Generate(q, r, noiseVal)
    if noiseVal < 0.22 then
        return "Water", 1 -- Level 1
    elseif noiseVal < 0.80 then
        -- Flachland-Terrassen (Level 2 bis 4)
        if noiseVal < 0.40 then return "Flat", 2
        elseif noiseVal < 0.60 then return "Flat", 3
        else return "Flat", 4 end
    elseif noiseVal < 0.90 then
        -- Raueres Hügelland (Level 5 und 6)
        if noiseVal < 0.85 then return "Hills", 5
        else return "Hills", 6 end
    else
        -- Gebirge bricht radikal aus (Level 7 und 8)
        if noiseVal < 0.95 then return "Mountain", 7
        else return "Mountain", 8 end 
    end
end

return ElevationGenerator