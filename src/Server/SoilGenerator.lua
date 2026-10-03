local SoilGenerator = {}
local SEED = math.random(1, 100000) + 5000 -- Anderer Seed als die Höhe

function SoilGenerator.Generate(q, r, elevationId)
    -- Wasser und Berge überschreiben das Biom meistens
    if elevationId == 1 then return 1 end -- Wasser kriegt Standard-Boden (wird farblich später überschrieben)
    if elevationId == 4 then return 4 end -- Berge sind immer Felsig
    
    local noise = math.noise(q / 8, r / 8, SEED)
    
    -- Mappe den Noise-Wert auf unsere Soil-IDs
    if noise < -0.1 then return 3       -- Wüste
    elseif noise < 0.2 then return 1    -- Grasland
    elseif noise < 0.4 then return 2    -- Wald
    else return 4 end                   -- Felsig
end

return SoilGenerator
