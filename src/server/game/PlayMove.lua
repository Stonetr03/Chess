-- Stonetr03

local Moves = require(script.Parent:WaitForChild("Moves"))
local Checkmate = require(script.Parent:WaitForChild("Checkmate"))

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

function Module:SetSquare(Board,Square,Piece)
    local File = Files[string.lower(string.sub(Square,1,1))]
    local Rank = tonumber(string.sub(Square,2,2));
    Board.Board[Rank] = string.sub(Board.Board[Rank],0,File-1) .. Piece .. string.sub(Board.Board[Rank],File+1,9)
    return Board
end

function Module:Move(Board,Player,Square,Move) -- Square:OldSquare, Move:NewSquare
    -- Check Player
    local KingPiece = "K"
    if Board.Turn == "w" then
        if Board.White ~= Player and Board.White ~= "White" then
            return
        end
    elseif Board.Turn == "b" then
        KingPiece = "k"
        if Board.Black ~= Player and Board.Black ~= "Black" then
            return
        end
    else
        return
    end
    -- Check if square is piece
    local File = Files[string.lower(string.sub(Square,1,1))]
    local Rank = tonumber(string.sub(Square,2,2));
    local NewFile = Files[string.lower(string.sub(Move,1,1))]
    local NewRank = tonumber(string.sub(Move,2,2));
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
    local inCheck = Moves:CheckifCheck(Board,Moves:GetSquareFromPiece(Board,KingPiece),Board.Turn)
    -- Check if LegalMove
    local LegalMoves = Moves:GetLegalMoves(Board,Square)
    local Legal = false
    local CheckMove
    for i,o in pairs(LegalMoves) do
        if typeof(o) == "table" and o[1] == Move then
            CheckMove = i
            Legal = true
            break
        elseif o == Move then
            CheckMove = i
            Legal = true
            break
        end
    end
    if not Legal then
        return
    end

    -- Check Check
    local inCheck2
    if string.sub(Board.Board[Rank],File,File) == KingPiece then
        Moves:CheckifCheck(Board,Move,Board.Turn)
    else
        Moves:CheckifCheck(Board,Moves:GetSquareFromPiece(Board,KingPiece),Board.Turn)
    end
    if inCheck == false and inCheck2 == true then
        -- illegal
        return
    elseif inCheck == true and inCheck2 == true then
        -- illegal
        return
    end

    -- Check Castle
    if inCheck == true and typeof(LegalMoves[CheckMove]) == "table" then
        if LegalMoves[CheckMove][2] == "castle" then
            return
        end
    end

    -- Taking
    local isTaking = false
    if string.sub(Board.Board[NewRank],NewFile,NewFile) ~= " " then
        isTaking = true
    end

    -- Castles
    local ValidCastle = {}
    for i = 1,string.len(Board.Castle),1 do
        table.insert(ValidCastle,string.sub(Board.Castle,i,i))
    end
    if Board.Turn == "w" then
        if string.sub(Board.Board[Rank],File,File) == "K" then
            -- Remove Castles
            if table.find(ValidCastle,"K") then
                table.remove(ValidCastle,table.find(ValidCastle,"K"))
            end
            if table.find(ValidCastle,"Q") then
                table.remove(ValidCastle,table.find(ValidCastle,"Q"))
            end
        elseif string.sub(Board.Board[Rank],File,File) == "R" then
            if Rank == 1 then
                if File == 1 then
                    -- Remove Queen
                    if table.find(ValidCastle,"Q") then
                        table.remove(ValidCastle,table.find(ValidCastle,"Q"))
                    end
                elseif File == 8 then
                    -- Remove King
                    if table.find(ValidCastle,"K") then
                        table.remove(ValidCastle,table.find(ValidCastle,"K"))
                    end
                end
            end
        end
    elseif Board.Turn == "b" then
        if string.sub(Board.Board[Rank],File,File) == "k" then
            -- Remove Castles
            if table.find(ValidCastle,"k") then
                table.remove(ValidCastle,table.find(ValidCastle,"k"))
            end
            if table.find(ValidCastle,"q") then
                table.remove(ValidCastle,table.find(ValidCastle,"q"))
            end
        elseif string.sub(Board.Board[Rank],File,File) == "r" then
            if Rank == 1 then
                if File == 1 then
                    -- Remove Queen
                    if table.find(ValidCastle,"q") then
                        table.remove(ValidCastle,table.find(ValidCastle,"q"))
                    end
                elseif File == 8 then
                    -- Remove King
                    if table.find(ValidCastle,"k") then
                        table.remove(ValidCastle,table.find(ValidCastle,"k"))
                    end
                end
            end
        end
    end
    local NewCastle = ""
    for _,o in pairs(ValidCastle) do
        NewCastle = NewCastle .. o
    end
    Board.Castle = NewCastle

    -- Make Move
    Board = Module:SetSquare(Board,Move,string.sub(Board.Board[Rank],File,File))
    Board = Module:SetSquare(Board,Square," ")
    if typeof(LegalMoves[CheckMove]) == "table" then
        if LegalMoves[CheckMove][2] == "castle" then
            -- Move Rook
            local Rooks = string.split(LegalMoves[CheckMove][3],"-")
            Board = Module:SetSquare(Board,Rooks[1]," ")
            if Board.Turn == "w" then
                Board = Module:SetSquare(Board,Rooks[2],"R")
            else
                Board = Module:SetSquare(Board,Rooks[2],"r")
            end
        else
            -- EnPassant
            Board = Module:SetSquare(Board,LegalMoves[CheckMove][2]," ")
        end
    end
    -- PGN


    -- Switch Turns
    if Board.Turn == "w" then
        Board.Turn = "b"
    else
        Board.Turn = "w"
    end
    Board.Last = Move;

    -- Check for Checkmate
    if Checkmate:CheckForCheckmate(Board,Board.Last) == true then
        Board.Turn = ""
        local Winner
        if Board.Turn == "w" then
            Winner = "b";
        else
            Winner = "w";
        end
        Board.Status = "Checkmate;" .. Winner
    end
    -- Check for Stalemate
    -- Check for Insuffient Material
    if Checkmate:CheckForInsufficientMaterial(Board) == true then
        Board.Turn = ""
        Board.Status = "Draw;insufficient material"
    end
    -- Check for Same Board 3x Draw

    return true, Board
end

return Module
