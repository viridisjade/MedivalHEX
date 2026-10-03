local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local diplomacyEvent = Instance.new("RemoteEvent")
diplomacyEvent.Name = "DiplomacyEvent"
diplomacyEvent.Parent = ReplicatedStorage

local getDiplomacyFunc = Instance.new("RemoteFunction")
getDiplomacyFunc.Name = "GetDiplomacyData"
getDiplomacyFunc.Parent = ReplicatedStorage

local relations = {}

Players.PlayerAdded:Connect(function(player)
    relations[player.UserId] = {}
end)

Players.PlayerRemoving:Connect(function(player)
    relations[player.UserId] = nil
end)

getDiplomacyFunc.OnServerInvoke = function(player)
    return relations[player.UserId] or {}
end

diplomacyEvent.OnServerEvent:Connect(function(player, targetUserId, status)
    if relations[player.UserId] then
        relations[player.UserId][targetUserId] = status
        print(string.format("Server: Spieler %s setzt Diplomatie mit %d auf: %s", player.Name, targetUserId, status))
        diplomacyEvent:FireClient(player, targetUserId, status)
    end
end)