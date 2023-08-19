-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Fusion"))
local Knit = require(game.ReplicatedStorage.Packages:WaitForChild("Knit"))
local tab = require(script:WaitForChild("tab"))

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value

local Menu = require(script:WaitForChild("Menu"))
local Board = require(script:WaitForChild("Board"))
local GameOver = require(script:WaitForChild("GameOver"))
local Letters = require(script:WaitForChild("Letters"))
local Clocks = require(script:WaitForChild("Clocks"))
local Dots = require(script:WaitForChild("Dots"))
local Highlights = require(script:WaitForChild("Highlights"))

-- Values

local ActiveGame = Value("")
local ActiveBoard = Value({})
local RenderingBoard = Value({
    [1] = "        ";
    [2] = "        ";
    [3] = "        ";
    [4] = "        ";
    [5] = "        ";
    [6] = "        ";
    [7] = "        ";
    [8] = "        ";
})
local BoardFlipped = Value(false)

Board.ActiveGame = ActiveGame
Board.ActiveBoard = ActiveBoard
Board.RenderingBoard = RenderingBoard
Board.BoardFlipped = BoardFlipped

GameOver.ActiveBoard = ActiveBoard
local LastStatus = ""
GameOver:init()

Letters.BoardFlipped = BoardFlipped

Clocks.ActiveBoard = ActiveBoard;
Clocks.BoardFlipped = BoardFlipped;
Clocks:init()

Dots.BoardFlipped = BoardFlipped;
Highlights.BoardFlipped = BoardFlipped;

-- Ui
local ScreenGui = New "ScreenGui" {
    ResetOnSpawn = false;
    IgnoreGuiInset = true;
    Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui");
    [Children] = {
        Background = New "Frame" {
            Size = UDim2.new(1,0,1,0);
            BackgroundColor3 = Color3.fromRGB(36,36,36);
            ZIndex = 1;
        };
        Menu = Menu.Ui({ActiveGame = ActiveGame;});
        Board = Board.Ui();
    };
}

local Challenges = {}
local Games = {}
local Players = {}

function ManagePlayers()
    local plrs = game.Players:GetPlayers()
    for _,c in pairs(Challenges) do
        if table.find(plrs,c[1]) then
            table.remove(plrs,table.find(plrs,c[1]))
        end
    end
    for _,o in pairs(Games) do
        if table.find(plrs,o[2][1]) then
            table.remove(plrs,table.find(plrs,o[2][1]))
        end
        if table.find(plrs,o[2][2]) then
            table.remove(plrs,table.find(plrs,o[2][2]))
        end
    end
    if table.find(plrs,game.Players.LocalPlayer) then
        table.remove(plrs,table.find(plrs,game.Players.LocalPlayer))
    end
    Players = plrs

    Menu:SetPlayers(Games,Challenges,Players)
end

game.Players.PlayerAdded:Connect(function()
    ManagePlayers()
end)

-- Knit
Knit.Start({ServicePromises = false}):andThen(function()
    local Chess = Knit.GetService("Chess")
    Chess.OnChallenge:Connect(function(player,v)
        if v == 0 then
            -- Remove Challenge
            if tab:Find(Challenges,{player,1}) then
                table.remove(Challenges,tab:Find(Challenges,{player,1}))
            elseif tab:Find(Challenges,{player,2}) then
                table.remove(Challenges,tab:Find(Challenges,{player,2}))
            end
        else
            if tab:Find(Challenges,{player,1}) then
                if v == 2 then
                    Challenges[tab:Find(Challenges,{player,1})][2] = 2
                end
            elseif tab:Find(Challenges,{player,2}) then
                if v == 1 then
                    Challenges[tab:Find(Challenges,{player,2})][2] = 1
                end
            else
                table.insert(Challenges,{player,v})
            end
        end
        ManagePlayers()
    end)
    Chess.GameStart:Connect(function(hash,players,Newboard)
        table.insert(Games,{hash,players})
        ManagePlayers()
        if players[1] == game.Players.LocalPlayer or players[2] == game.Players.LocalPlayer then
            -- Spectate Game
            LastStatus = ""
            ActiveGame:set(hash)
            ActiveBoard:set(Newboard)
            RenderingBoard:set(Newboard.Board)
            if Newboard.Black == game.Players.LocalPlayer then
                BoardFlipped:set(true)
            else
                BoardFlipped:set(false)
            end
        end
    end)

    -- Game Update Events
    Chess.UpdateGame:Connect(function(Hash,Moves,Newboard)
        if ActiveGame:get() == Hash then
            ActiveBoard:set(Newboard);
            RenderingBoard:set(Newboard.Board)
            if Newboard.Status then
                if Newboard.Status ~= "" and LastStatus == "" then
                    GameOver.Visible:set(true);
                end
                LastStatus = Newboard.Status
            end
            Highlights:SetMoveHighlight(Moves)
        end
    end)

    Menu.Challenge = function(p)
        Chess:Challenge(p)
    end

    -- Init
    for _,g in pairs(Chess:GetGames()) do
        local found = false
        for _,g in pairs(Games) do
            if g[1] == g.Hash then
                found = true
                break
            end
        end
        if found == false then
            table.insert(Games,{g.Hash,{g.White,g.Black}})
        end
    end
    ManagePlayers()

    -- Make Move
    Board.MakeMove = function(Sqr,Move,Promote)
        return Chess:MakeMove(ActiveGame:get(),Sqr,Move,Promote)
    end
end):catch(warn)

game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable