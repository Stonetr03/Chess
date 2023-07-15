-- Stonetr03

local Moves = require(script.Parent:WaitForChild("Moves"))

local Module = {}

local WhitePieces = {"R","N","B","Q","K","P"}
local BlackPieces = {"r","n","b","q","k","p"}

local Files = {
    ["a"] = 1;
    ["b"] = 2;
    ["c"] = 3;
    ["d"] = 4;
    ["e"] = 5;
    ["f"] = 6;
    ["g"] = 7;
    ["h"] = 8;
}

function Module:Move(Board,Player,Square,Move) -- Square:OldSquare, Move:NewSquare
    -- Check Player
    local KingPiece = "K"
    if Board.Turn == "w" then
        if Board.White ~= Player and Board.White ~= "White" then
            return
        end
    else
        KingPiece = "k"
        if Board.Black ~= Player and Board.Black ~= "Black" then
            return
        end
    end
    -- Check if square is piece
    local File = Files[string.lower(string.sub(Square,1,1))]
    local Rank = tonumber(string.sub(Square,2,2));
    if Board.Turn == "w" then
        if table.find(WhitePieces,string.sub(Board.Board[Rank],File,File)) then else
            return
        end
    elseif Board.Turn == "b" then
        if table.find(BlackPieces,string.sub(Board.Board[Rank],File,File)) then else
            return
        end
    end
    -- Check if Check
    local inCheck = Moves:CheckifCheck(Board,Moves:GetSquareFromPiece(Board,KingPiece))
    -- Check if LegalMove
    local LegalMoves = Moves:GetLegalMoves(Board,Square)
    local Legal = false
    for _,o in pairs(LegalMoves) do
        if o == Move then
            Legal = true
            break
        end
    end
    if not Legal then
        return
    end

    -- Check Check
    local inCheck2 = Moves:CheckifCheck(Board,Move)
    if inCheck == false and inCheck2 == true then
        -- illegal
        return
    elseif inCheck == true and inCheck2 == true then
        -- illegal
        return
    end

    -- Make Move
end

return Module
