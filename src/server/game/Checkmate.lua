-- Stonetr03

local Moves = require(script.Parent:WaitForChild("Moves"))

local Module = {}

local ColorPieces = {
    ["w"] = "K";
    ["b"] = "k";
}

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

function Module:SetTmpSquare(Board,Square,Piece)
    local File = Files[string.lower(string.sub(Square,1,1))]
    local Rank = tonumber(string.sub(Square,2,2));
    Board[Rank] = string.sub(Board.Board[Rank],0,File-1) .. Piece .. string.sub(Board.Board[Rank],File+1,9)
    return Board
end

function Module:CheckForCheckmate(Board,Color)
    local King = Moves:GetSquareFromPiece(Board,ColorPieces[Color])
    if Moves:CheckifCheck(Board, King) == false then
        return false
    end

    local Pieces = Moves:GetPieces(Board,Color)
    for _,p in pairs(Pieces) do
        local PieceMoves = Moves:GetLegalMoves(Board,p)
        for _,m in pairs(PieceMoves) do
            local NewBoard = {Board = table.clone(Board.Board), Castle = "",Last = Board.Last}
            if Moves:CheckifCheck(NewBoard,King,Color) == false then
                return false
            end
        end
    end
    return true
end

return Module
