-- Stonetr03 - Comm

local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))
local core = require(game:GetService("ServerScriptService"):WaitForChild("Core"))

local Chess = Knit.CreateService {
    Name = "Chess";
    Client = {
        OnChallenge = Knit.CreateSignal();
        GameStart = Knit.CreateSignal();
        UpdateGame = Knit.CreateSignal();
    }
}

local GameListeners = {}

core.ChallengeSignal:Connect(function(plrs,value)
    if value == true then
        Chess.Client.OnChallenge:Fire(plrs[1],plrs[2],1)
        Chess.Client.OnChallenge:Fire(plrs[2],plrs[1],2)
    else
        Chess.Client.OnChallenge:Fire(plrs[1],plrs[2],0)
        Chess.Client.OnChallenge:Fire(plrs[2],plrs[1],0)
    end
end)

function Chess.Client:Challenge(p1,p2)
    if typeof(p2) ~= "Instance" or p2:IsA("Player") ~= true then
        return false
    end
    if p1 == p2 then
        return false
    end
    local Start, Hash = core:Challenge(p1,p2)
    if Start == true then
        -- Notif Clients
        Chess.Client.GameStart:FireAll(Hash,{p1,p2},core.Games[Hash])
        -- Listen to game
        GameListeners[Hash] = {p1,p2}

        core.Signals[Hash]:Connect(function(Moves,Newboard)
            Chess.Client.UpdateGame:FireFor(GameListeners[Hash],Hash,Moves,Newboard)
        end)

        return true
    else
        return false
    end
end

function Chess.Client:GetGames()
    return core.Games
end

function Chess.Client:GetBoardFromHash(p,Hash)
    if core.Games[Hash] then
        return core.Games[Hash]
    end
end

function Chess.Client:ListenHash(p,Hash,Value)
    if core.Games[Hash] and GameListeners[Hash] then
        if Value == true then
            if table.find(GameListeners[Hash],p) == nil then
                table.insert(GameListeners[Hash],p)
            end
        elseif Value == false then
            if table.find(GameListeners[Hash],p) then
                table.remove(GameListeners[Hash],table.find(GameListeners[Hash],p))
            end
        end
    end
end

Knit.Start():andThen(function() end):catch(warn)
