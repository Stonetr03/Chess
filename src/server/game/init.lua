-- Stonetr03

local NewGame = require(script:WaitForChild("NewGame"))
local PrintBoard = require(script:WaitForChild("PrintBoard"))
local HttpService = game:GetService("HttpService")
local Moves = require(script:WaitForChild("Moves"))

local Module = {
    Games = {}
}

function Module:NewGame()
    local Hash = HttpService:GenerateGUID(true)
    Module.Games[Hash] = NewGame:New(Hash,"rnbqkbnr/ppppp1pp/8/8/4Pp2/8/PPPP1PPP/RNBQKBNR w KQkq e4 0 1")
    PrintBoard(Module.Games[Hash])
    print("...")
    print(Moves:GetLegalMoves(Module.Games[Hash], "f4"))
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
        -- Check Move
    end
end

return Module
