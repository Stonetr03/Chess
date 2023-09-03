-- Stonetr03 - Comm

local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))
local core = require(game:GetService("ServerScriptService"):WaitForChild("Core"))
local Settings = require(script:WaitForChild("Settings"))

local Chess = Knit.CreateService {
    Name = "Chess";
    Client = {
        OnChallenge = Knit.CreateSignal();
        GameStart = Knit.CreateSignal();
        UpdateGame = Knit.CreateSignal();
        DrawUpdate = Knit.CreateSignal();
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

core.OtherSignal:Connect(function(t,Hash,v1)
    if t == "Draw" then
        Chess.Client.DrawUpdate:Fire(v1,Hash)
    elseif t == "Cleanup" then
        -- Cleanup
        if GameListeners[Hash] then
            GameListeners[Hash] = nil;
            Chess.Client.GameStart:FireAll(Hash,"Cleanup")
        end
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

-- Make Move
function Chess.Client:MakeMove(p,Hash,Sqr,Move,Promote)
    if core.Games[Hash] then
        if core.Games[Hash].Turn == "w" and core.Games[Hash].White == p then
        elseif core.Games[Hash].Turn == "b" and core.Games[Hash].Black == p then
        else
            return
        end
        return core:Playmove(Hash,p,Sqr,Move,Promote)
    end
    return false
end

-- Resign
function Chess.Client:Resign(p,Hash)
    if core.Games[Hash] then
        core:Resign(Hash,p)
    end
end
function Chess.Client:Draw(p,Hash,Value)
    if core.Games[Hash] then
        core:Draw(Hash,p,Value)
    end
end

-- Settings
game.Players.PlayerAdded:Connect(function(p)
    Settings:GetDataStore(p.UserId)
end)
game.Players.PlayerRemoving:Connect(function(p)
    Settings:ExitDataStore(p.UserId)
end)
function Chess.Client:GetSettings(p)
    if Settings.Data[p.UserId] then
        return Settings.Data[p.UserId];
    end
    return nil;
end

local ValidSettings = {
    [1] = "standard";
    [2] = "caliente";
    [3] = "california";
    [4] = "cardinal";
    [5] = "cburnett";
    [6] = "disguised";
    [7] = "fresca";
    [8] = "gioco";
    [9] = "kiwen-suwi";
    [10] = "kosal";
    [11] = "letter";
    [12] = "libra";
    [13] = "maestro";
    [14] = "merida";
    [15] = "mono";
    [16] = "mpchess";
    [17] = "pirouetti";
    [18] = "pixel";
    [19] = "shapes";
    [20] = "staunty";
    [21] = "tatiana";
}
function checkHex(str)
    -- Check if the string starts with "#" and is exactly 7 characters long
    if type(str) == "string" and str:match("^%x%x%x%x%x%x$") then
        return true
    else
        return false
    end
end

function Chess.Client:SetSetting(p,Key,Value)
    if typeof(Key) ~= "string" or typeof(Value) ~= "string" then
        return
    end
    if Settings.Data[p.UserId] then
        if Key == "Piece" then
            if table.find(ValidSettings,Value) then
                -- Update Data
                Settings:UpdateData(p.UserId,Key,Value)
            end
        elseif Key == "WColor" or Key == "BColor" then
            if checkHex(Value) == true then
                -- Update Data
                Settings:UpdateData(p.UserId,Key,Value)
            end
        end
    end
end

Knit.Start():andThen(function() end):catch(warn)
