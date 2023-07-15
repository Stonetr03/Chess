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
    Module.Games[Hash] = NewGame:New(Hash)
    PrintBoard(Module.Games[Hash])
    print("...")
    print(Moves:GetLegalMoves(Module.Games[Hash], "e4"))
    Module:Playmove(Hash,"White","e2","e4")
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
        PlayMove:Move(Board,Player,Square,Move)
    end
end

return Module
