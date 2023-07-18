-- Stonetr03

local Chess = require(game.ServerScriptService:WaitForChild("Server"):WaitForChild("game"))
local Hash = Chess:NewGame()

local PlayMove = Instance.new("BindableEvent",script)
PlayMove.Name = "Move"
PlayMove.Event:Connect(function(p,sqr,mov,pro)
    Chess:Playmove(Hash,p,sqr,mov,pro)
end)

local GetLegal = Instance.new("BindableEvent",script)
GetLegal.Name = "Legal"
GetLegal.Event:Connect(function(sqr)
    print(Chess:GetLegalMoves(Hash,sqr))
end)