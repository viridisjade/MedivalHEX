local ElevationConfig = {
    [1] = {Name = "Water", Height = -2, IsPassable = false, DefenseBonus = 0},
    [2] = {Name = "Flatland", Height = 0, IsPassable = true, DefenseBonus = 0},
    [3] = {Name = "Hills", Height = 5, IsPassable = true, DefenseBonus = 20},
    [4] = {Name = "Mountain", Height = 15, IsPassable = false, DefenseBonus = 50},
}
return ElevationConfig
