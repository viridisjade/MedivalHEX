local ElevationGenerator = {}

function ElevationGenerator.Generate(q, r, noiseVal)
    -- noiseVal kommt von einem 2D Perlin Noise (-1 bis 1 oder 0 bis 1)
    if noiseVal < 0.3 then
        return "Water", 0 -- Unpassierbar / Meer
    elseif noiseVal < 0.55 then
        return "Flat", 1 -- Standard-Land (Grasland/Ebene Basis)
    elseif noiseVal < 0.75 then
        return "Hills", 2 -- Hügel (Verteidigungsbonus, teurere Bewegung)
    else
        return "Mountain", 3 -- Berg (Blockiert Einheiten, hoher Ertrag/Schutz)
    end
end

return ElevationGenerator