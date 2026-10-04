local HexGridMath = {}
HexGridMath.HexSize = 6

-- Zentrales 8-Level-Höhenprofil
HexGridMath.HeightLookup = {
    [1] = 2,    -- Wasser
    [2] = 4,    -- Flachland Tief
    [3] = 6,    -- Flachland Normal
    [4] = 8,    -- Flachland Hoch
    [5] = 13,   -- Hügel
    [6] = 18,   -- Hohe Hügel
    [7] = 30,   -- Berge
    [8] = 45    -- Bergspitzen
}

function HexGridMath.GetSurfaceHeight(heightLevel, hasSoil)
    local baseThickness = HexGridMath.HeightLookup[heightLevel] or 4
    local soilThickness = hasSoil and 0.6 or 0
    -- Die absolute Y-Höhe der Oberfläche des Hexagons
    return baseThickness + soilThickness
end

function HexGridMath.AxialToWorld(q, r, height)
    local size = HexGridMath.HexSize
    local x = size * (3/2 * q)
    local z = size * (math.sqrt(3)/2 * q + math.sqrt(3) * r)
    return Vector3.new(x, height or 0, z)
end

function HexGridMath.GetNeighbors(q, r)
    local directions = {
        {q = 1, r = 0}, {q = 1, r = -1}, {q = 0, r = -1},
        {q = -1, r = 0}, {q = -1, r = 1}, {q = 0, r = 1}
    }
    local neighbors = {}
    for _, dir in ipairs(directions) do
        table.insert(neighbors, {q = q + dir.q, r = r + dir.r})
    end
    return neighbors
end

function HexGridMath.Distance(q1, r1, q2, r2)
    return (math.abs(q1 - q2) + math.abs(r1 - r2) + math.abs((q1 + r1) - (q2 + r2))) / 2
end

function HexGridMath.FindPath(startQ, startR, goalQ, goalR)
    local startKey = startQ .. "_" .. startR
    local goalKey = goalQ .. "_" .. goalR
    
    if startKey == goalKey then return {{q = startQ, r = startR}} end
    
    local queue = { {q = startQ, r = startR} }
    local cameFrom = {}
    local visited = { [startKey] = true }
    
    local found = false
    while #queue > 0 do
        local current = table.remove(queue, 1)
        local currentKey = current.q .. "_" .. current.r
        
        if currentKey == goalKey then
            found = true; break
        end
        
        for _, neighbor in ipairs(HexGridMath.GetNeighbors(current.q, current.r)) do
            local neighborKey = neighbor.q .. "_" .. neighbor.r
            if not visited[neighborKey] then
                visited[neighborKey] = true
                cameFrom[neighborKey] = current
                table.insert(queue, neighbor)
            end
        end
    end
    
    if not found then return nil end
    
    local path = {}
    local currKey = goalKey
    while currKey ~= startKey do
        local prev = cameFrom[currKey]
        local qStr, rStr = string.match(currKey, "^(-?%d+)_(-?%d+)$")
        table.insert(path, 1, {q = tonumber(qStr), r = tonumber(rStr)})
        currKey = prev.q .. "_" .. prev.r
    end
    
    return path
end

return HexGridMath