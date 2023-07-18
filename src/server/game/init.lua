-- Stonetr03

local NewGame = require(script:WaitForChild("NewGame"))
local PrintBoard = require(script:WaitForChild("PrintBoard"))
local HttpService = game:GetService("HttpService")
local Moves = require(script:WaitForChild("Moves"))
local PlayMove = require(script:WaitForChild("PlayMove"))

local legalPromote = {"r","n","b","q","","nil"}

local Module = {
    Games = {}
}

function Module:NewGame()
    local Hash = HttpService:GenerateGUID(true)
    Module.Games[Hash] = NewGame:New(Hash,"8/k1PK4/1p6/1P6/8/8/8/8 w - - 0 1")
    PrintBoard(Module.Games[Hash])
    return Hash
end

function Module:GetLegalMoves(Hash,Square)
    local Board = Module.Games[Hash]
    if Board then
        return Moves:GetLegalMoves(Board,Square)
    end
end

function Module:Playmove(Hash,Player,Square,Move,Promote)
    if not table.find(legalPromote,string.lower(tostring(Promote))) then return end
    local Board = Module.Games[Hash]
    if Board then
        local Moved,New = PlayMove:Move(Board,Player,Square,Move,Promote)
        if Moved == true then
            Module.Games[Hash] = New
        end

        PrintBoard(Module.Games[Hash])
    end
end

return Module
