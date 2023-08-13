-- Stonetr03

local NewGame = require(script:WaitForChild("NewGame"))
local PrintBoard = require(script:WaitForChild("PrintBoard"))
local HttpService = game:GetService("HttpService")
local Moves = require(script:WaitForChild("Moves"))
local PlayMove = require(script:WaitForChild("PlayMove"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))

local legalPromote = {"r","n","b","q","","nil"}

local Module = {
    Games = {};
    Signals = {};
    Challenges = {};
    ChallengeSignal = Signal.new()
}

function Module:NewGame(p1: Player,p2: Player)
    local Hash = HttpService:GenerateGUID(true)
    Module.Games[Hash] = NewGame:New(Hash,nil,p1,p2)
    PrintBoard(Module.Games[Hash])
    local GameSignal = Signal.new()
    Module.Signals[Hash] = GameSignal;
    return Hash,GameSignal
end

function Module:GetLegalMoves(Hash: string,Square: string)
    local Board = Module.Games[Hash]
    if Board then
        return Moves:GetLegalMoves(Board,Square)
    end
end

function Module:Playmove(Hash: string,Player: Player,Square: string,Move: string,Promote: string)
    if not table.find(legalPromote,string.lower(tostring(Promote))) then return end
    local Board = Module.Games[Hash]
    if Board then
        local Moved,New,UpdateMoves = PlayMove:Move(Board,Player,Square,Move,Promote)
        if Moved == true then
            Module.Games[Hash] = New
            Module.Signals[Hash]:Fire(UpdateMoves,New)
            PrintBoard(Module.Games[Hash])
            print(UpdateMoves)
            return true
        end
    end
    return false
end

function Module:Draw(Hash: string,Player: Player,v: boolean)
    local Board = Module.Games[Hash]
    if Board then
        if Board.White == Player then
            Board.Draw[1] = v
        elseif Board.Black == Player then
            Board.Draw[2] = v
        end
    end
    if v == false then
        Board.Draw = {false,false}
    end
    if Board.Draw[1] == true and Board.Draw[2] == true then
        Board.Turn = ""
        Board.Status = "draw;agreement"
        Board.PGN = Board.PGN .. " 1/2-1/2"
        Module.Signals[Hash]:Fire({},Board)
    end
end

function Module:Resign(Hash: string,Player: Player)
    local Board = Module.Games[Hash]
    if Board then
        if Board.White == Player then
            Board.Turn = ""
            Board.Status = "resign;b"
            Board.PGN = Board.PGN .. " 0-1"
            Module.Signals[Hash]:Fire({},Board)
        elseif Board.Black == Player then
            Board.Turn = ""
            Board.Status = "resign;w"
            Board.PGN = Board.PGN .. " 1-0"
            Module.Signals[Hash]:Fire({},Board)
        end
    end
end

function PlayChallenge(p1,p2)
    local White
    local Black
    if math.random(1,2) == 1 then
        White = p1
        Black = p2
    else
        White = p2
        Black = p1
    end
    for _,o in pairs(Module.Challenges) do
        if o[1] == p1 or o[1] == p2 or o[2] == p1 or o[2] == p2 then
            table.remove(Module.Challenges,table.find(Module.Challenges,o))
        end
    end
    Module.ChallengeSignal:Fire({p1,p2},false)
    return Module:NewGame(White,Black)
end

function Module:Challenge(p1: Player,p2: Player)
    -- Check if Challenge Exists
    for _,o in pairs(Module.Challenges) do
        if o[1] == p1 then
            if o[2] == p2 then
                -- Cancel
                for _,i in pairs(Module.Challenges) do
                    if i[1] == p1 or i[1] == p2 or i[2] == p1 or i[2] == p2 then
                        table.remove(Module.Challenges,table.find(Module.Challenges,i))
                        Module.ChallengeSignal:Fire({o[1],o[2]},false)
                    end
                end
                return false,""
            end
        elseif o[1] == p2 then
            if o[2] == p1 then
                -- Accept
                local Hash = PlayChallenge(p1,p2)
                return true,Hash
            end
        end
    end

    -- Add Challenge
    table.insert(Module.Challenges,{p1,p2})
    Module.ChallengeSignal:Fire({p1,p2},true)
    return false,""
end

game.Players.PlayerRemoving:Connect(function(p)
    -- Remove Challenges
    for _,o in pairs(Module.Challenges) do
        if o[1] == p or o[1] == p then
            table.remove(Module.Challenges,table.find(Module.Challenges,o))
            Module.ChallengeSignal:Fire({o[1],o[2]},false)
        end
    end
    -- Remove Boards
    for _,g in pairs(Module.Games) do
        if g.White == p or g.Black == p then
            Module:Resign(g.Hash,p)
        end
    end
end)

return Module
