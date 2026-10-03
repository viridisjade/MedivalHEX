local HexGridMath = {}

local HEX_SIZE = 10 -- Die Größe eines Hex-Feldes (Abstand vom Zentrum zur Ecke)
local SQRT_3 = math.sqrt(3)

-- Wandelt axiale Koordinaten (q, r) in 3D-Weltkoordinaten (x, y, z) um
function HexGridMath.AxialToWorld(q, r, height)
    local x = HEX_SIZE * SQRT_3 * (q + r/2)
    local z = HEX_SIZE * 3/2 * r
    return Vector3.new(x, height or 0, z)
end

-- Definiert die 6 Richtungen um ein Hexagon
local directions = {
    Vector2.new(1, 0), Vector2.new(1, -1), Vector2.new(0, -1),
    Vector2.new(-1, 0), Vector2.new(-1, 1), Vector2.new(0, 1)
}

-- Gibt die Koordinaten aller 6 Nachbarfelder zurück
function HexGridMath.GetNeighbors(q, r)
    local neighbors = {}
    for _, dir in ipairs(directions) do
        table.insert(neighbors, {q = q + dir.X, r = r + dir.Y})
    end
    return neighbors
end

return HexGridMath
