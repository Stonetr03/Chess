-- Stonetr03

local NewGame = require(script:WaitForChild("NewGame"))
local PrintBoard = require(script:WaitForChild("PrintBoard"))
local HttpService = game:GetService("HttpService")
local Moves = require(script:WaitForChild("Moves"))
local PlayMove = require(script:WaitForChild("PlayMove"))

local Module = {
    Games = {}
}

function Module:NewGame()
    local Hash = HttpService:GenerateGUID(true)
    Module.Games[Hash] = NewGame:New(Hash,"r1bk1bnr/5Qpp/p1P5/1p6/8/3PB3/PPP2PPP/RN2KB1R w KQ - 0 11")
    PrintBoard(Module.Games[Hash])
    return Hash
end

function Module:GetLegalMoves(Hash,Square)
    local Board = Module.Games[Hash]
    if Board then
        return Moves:GetLegalMoves(Board,Square)
    end
end

function Module:Playmove(Hash,Player,Square,Move)
    local Board = Module.Games[Hash]
    if Board then
        local Moved,New = PlayMove:Move(Board,Player,Square,Move)
        if Moved == true then
            Module.Games[Hash] = New
        end

        PrintBoard(Module.Games[Hash])
    end
end

return Module
