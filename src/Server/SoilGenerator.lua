local SoilGenerator = {}

function SoilGenerator.Generate(elevationType, q, r, altNoiseVal)
    -- Wasser und Berge bekommen keinen normalen Boden
    if elevationType == "Water" or elevationType == "Mountain" then
        return "None"
    end
    
    -- Nutzt einen zweiten Noise-Wert oder Hash für natürliche Verteilung
    local biomeNoise = math.noise(q * 0.15, r * 0.15, 42)
    
    if elevationType == "Flat" then
        if biomeNoise < -0.2 then
            return "Desert"
        elseif biomeNoise < 0.2 then
            return "Grassland"
        else
            return "Forest"
        end
    elseif elevationType == "Hills" then
        if biomeNoise < 0.3 then
            return "Rocky"
        else
            return "Forest"
        end
    end
    
    return "Grassland"
end

return SoilGenerator