local ElevationGenerator = {}
local SEED = math.random(1, 100000)

function ElevationGenerator.Generate(q, r)
    -- Perlin Noise für weiche Übergänge
    local noise = math.noise(q / 10, r / 10, SEED)
    
    -- Mappe den Noise-Wert (-0.5 bis 0.5) auf unsere Elevation-IDs
    if noise < -0.15 then return 1      -- Wasser
    elseif noise < 0.2 then return 2    -- Flachland
    elseif noise < 0.35 then return 3   -- Hügel
    else return 4 end                   -- Berg
end

return ElevationGenerator
