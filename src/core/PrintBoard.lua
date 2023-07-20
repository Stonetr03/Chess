-- Stonetr03 - Prints the board

function PrintBoard(board)
    local Txt = " \n========\n"
    Txt = Txt .. "B:" .. board.Black .. "\n--------\n"
    -- Board
    for i = 8,1,-1 do
        Txt = Txt .. board.Board[i] .. "\n"
    end
    Txt = Txt .. "--------\nW:" .. board.White .. "\n--------\n" .. "T:" .. board.Turn .. ", C:" .. board.Castle .. ", L:" .. board.Last .. "\n========\n" .. board.PGN .. "\n========\n"
    print(Txt)
    return
end

return PrintBoard
