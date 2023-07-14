-- Stonetr03

-- Pieces
local Pawn = require(script.Parent:WaitForChild("Pieces"):WaitForChild("Pawn"))
local Rook = require(script.Parent:WaitForChild("Pieces"):WaitForChild("Rook"))

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

local CheckFuncs = {
    ["p"] = Pawn;
    ["r"] = Rook;
}

function Module:GetLegalMoves(Board,Square)
    -- Get Squares
    if string.len(Square) ~= 2 then return {} end

    local File = Files[string.lower(string.sub(Square,1,1))]
    if not File then return {} end
    local Rank = tonumber(string.sub(Square,2,2));
    if not Rank then return {} end
    if Rank < 1 or Rank > 8 then return {} end

    -- Get Piece
    local Piece = string.sub(Board.Board[Rank],File,File)
    if Piece == " " then return {} end

    -- Get Legal Moves
    local Color = "w"
    if table.find(BlackPieces,Piece) then
        Color = "b"
    end
    -- Check if king is in check
    local LegalMoves = CheckFuncs[string.lower(Piece)]:GetMoves(Board,File,Rank,Color)
    -- Check if king is Still in check
    return LegalMoves
end

return Module
