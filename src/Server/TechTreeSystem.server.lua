local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local researchEvent = Instance.new("RemoteEvent")
researchEvent.Name = "ResearchTechEvent"
researchEvent.Parent = ReplicatedStorage

local getTechFunc = Instance.new("RemoteFunction")
getTechFunc.Name = "GetTechData"
getTechFunc.Parent = ReplicatedStorage

-- Definition des Tech-Trees
local TechDefinitions = {
    ["Agriculture"] = {Cost = 50, Unlocks = "Farm"},
    ["BronzeWorking"] = {Cost = 100, Unlocks = "Spearman"},
    ["IronWorking"] = {Cost = 150, Unlocks = "Swordsman"}
}

-- Speichert den Fortschritt der Spieler (PlayerId -> {ResearchedTechs = {}, CurrentTech = nil, Science = 0})
local playerTechs = {}

Players.PlayerAdded:Connect(function(player)
    playerTechs[player.UserId] = {
        ResearchedTechs = {},
        CurrentTech = nil,
        Science = 50 -- Start-Forschungspunkte
    }
end)

getTechFunc.OnServerInvoke = function(player)
    return playerTechs[player.UserId] or {ResearchedTechs = {}, CurrentTech = nil, Science = 0}, TechDefinitions
end

researchEvent.OnServerEvent:Connect(function(player, techName)
    local data = playerTechs[player.UserId]
    local tech = TechDefinitions[techName]
    
    if data and tech and data.Science >= tech.Cost then
        data.Science -= tech.Cost
        table.insert(data.ResearchedTechs, techName)
        print(string.format("Server: Spieler %s hat Technologie '%s' erforscht!", player.Name, techName))
        
        researchEvent:FireClient(player, "Success", techName, data.Science)
    else
        print("Server: Nicht genug Forschungspunkte oder Tech ungültig.")
    end
end)