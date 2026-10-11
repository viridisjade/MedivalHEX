local UnitConfig = {
    ["King"] = {
        Name = "König",
        MaxHP = 100,
        Attack = 15,
        Defense = 10,
        Movement = 3,
        AttackRange = 1,
        ModelName = "KingMesh"
    },
    ["Swordsman"] = {
        Name = "Schwertkämpfer",
        MaxHP = 60,
        Attack = 20,
        Defense = 8,
        Movement = 2,
        AttackRange = 1,
        ModelName = "SwordsmanMesh"
    },
    ["Archer"] = {
        Name = "Bogenschütze",
        MaxHP = 30,
        Attack = 15,      -- Dein gewünschter Schaden
        Defense = 2,
        Movement = 2,
        AttackRange = 3,  -- Massive 3 Hex-Felder Reichweite!
        ModelName = "ArcherMesh"
    },
    ["Cavalry"] = {
        Name = "Kavallerie",
        MaxHP = 50,
        Attack = 25,      -- Sehr hoher Schaden
        Defense = 5,
        Movement = 4,     -- Sehr hohe Reichweite
        AttackRange = 1,
        ModelName = "CavalryMesh"
    }
}

return UnitConfig