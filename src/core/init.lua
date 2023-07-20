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
    Challenge = Signal.new()
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
        end

        PrintBoard(Module.Games[Hash])
        print(UpdateMoves)
    end
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
        Board.Status = "Draw;Agreement"
        Board.PGN = Board.PGN .. " 1/2-1/2"
        Module.Signals[Hash]:Fire({},Board)
    end
end

function Module:Resign(Hash: string,Player: Player)
    local Board = Module.Games[Hash]
    if Board then
        if Board.White == Player then
            Board.Turn = ""
            Board.Status = "Resign;b"
            Board.PGN = Board.PGN .. " 0-1"
            Module.Signals[Hash]:Fire({},Board)
        elseif Board.Black == Player then
            Board.Turn = ""
            Board.Status = "Resign;w"
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
    return Module:NewGame(White,Black)
end

function Module:Challenge(p1: Player,p2: Player)
    -- Check if Challenge Exists
    for _,o in pairs(Module.Challenges) do
        if o[1] == p1 then
            if o[2] == p2 then
                -- Accept
                local Hash = PlayChallenge(p1,p2)
                return true,Hash
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
    table.insert(Module.Challenge,{p1,p2})
    Module.Challenge:Fire({p1,p2})
    return false,""
end

return Module
