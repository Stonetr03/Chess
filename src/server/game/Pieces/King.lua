-- Stonetr03

local Module = {}

local WhitePieces = {"R","N","B","Q","K","P"}
local BlackPieces = {"r","n","b","q","k","p"}

local Files = {
    [1] = "a";
    [2] = "b";
    [3] = "c";
    [4] = "d";
    [5] = "e";
    [6] = "f";
    [7] = "g";
    [8] = "h";
}

local Jumps = {
    [1] = {1,1};
    [2] = {0,1};
    [3] = {-1,1};
    [4] = {1,0};
    [5] = {-1,0};
    [6] = {1,-1};
    [7] = {0,-1};
    [8] = {-1,-1};
}

function Module:GetMoves(Board,File,Rank,Color)
    local Moves = {}
    if Color == "w" then
        -- Check White Piece
        for _,o in pairs(Jumps) do
            local Sqr = {File+o[1],Rank+o[2]}
            if Sqr[1] < 1 or Sqr[2] < 1  or Sqr[1] > 8 or Sqr[2] > 8 then
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(BlackPieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                end
            end
        end
    elseif Color == "b" then
        -- Check Black Piece
        for _,o in pairs(Jumps) do
            local Sqr = {File+o[1],Rank+o[2]}
            if Sqr[1] < 1 or Sqr[2] < 1  or Sqr[1] > 8 or Sqr[2] > 8 then
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(WhitePieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                end
            end
        end
    end
    return Moves
end

return Module
