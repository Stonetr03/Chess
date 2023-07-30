-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Fusion"))

local Pieces = require(script.Parent:WaitForChild("Pieces"))

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Event = Fusion.OnEvent

local Module = {
    ActiveGame = nil;
    ActiveBoard = nil;
    RenderingBoard = nil;
    BoardFlipped = nil;
}

-- Settings
local BoardWColor = Value(Color3.fromRGB(240, 217, 181))
local BoardBColor = Value(Color3.fromRGB(181, 136, 99))

function RenderBoardBG()
    local Squares = {}

    local color = true
    for i = 0,7,1 do
        for o = 0,7,1 do
            local Bgcolor = BoardWColor
            if color == true then
                local Ui = New "Frame" {
                    BackgroundColor3 = Bgcolor;
                    Size = UDim2.new(0.125,0,0.125);
                    Position = UDim2.new(0.125 * i,0,0.125 * o,0);
                }
                table.insert(Squares,Ui)
            end
            
            color = not color
        end
        color = not color
    end

    return Squares
end

local Flipped = {
    [1] = 8;
    [2] = 7;
    [3] = 6;
    [4] = 5;
    [5] = 4;
    [6] = 3;
    [7] = 2;
    [8] = 1;
}
function GetXPos(y)
    if Module.BoardFlipped:get() == false then
        return y
    end
    return Flipped[y]
end
function GetYPos(y)
    if Module.BoardFlipped:get() == true then
        return y
    end
    return Flipped[y]
end

function Module.Ui()
    return New "Frame" {
        BackgroundTransparency = 1;
        Visible = Computed(function()
            if Module.ActiveGame:get() ~= "" then
                return true
            end
            return false
        end);
        Size = UDim2.new(1,0,1,0);
        [Children] = {
            Board = New "Frame" {
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundColor3 = BoardBColor;
                Position = UDim2.new(0.5,0,0.5,0);
                Size = UDim2.new(0.75,0,0.75,0);
                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                ZIndex = 5;
                [Children] = {
                    Squares = RenderBoardBG();
                    Pieces = Computed(function()
                        print("Render Pieces")
                        local NewPieces = {}
                        local board = Module.RenderingBoard:get()
                        if not board then
                            return {}
                        end
                        for rank = 1,8,1 do
                            for file = 1,8,1 do
                                if string.sub(board[rank],file,file) ~= " " then
                                    print("insert piece",string.sub(board[rank],file,file))
                                    table.insert(NewPieces,{
                                        Piece = string.sub(board[rank],file,file);
                                        File = file;
                                        Rank = rank;
                                    })
                                end
                            end
                        end
                        local Ui = {}

                        for i,o in pairs(NewPieces) do
                            print("render piece", o.Piece)
                            if Pieces[o.Piece] then
                                print("render2")
                                Ui[i] = New "ImageButton" {
                                    BackgroundTransparency = 1;
                                    Size = UDim2.new(0.125,0,0.125);
                                    Position = UDim2.new(0.125 * (GetXPos(o.File)-1),0,0.125 * (GetYPos(o.Rank)-1),0);
                                    Image = Pieces.ImageId;
                                    ImageRectSize = Vector2.new(175, 175);
                                    ImageRectOffset = Pieces[o.Piece]
                                };
                            end
                        end

                        return Ui
                    end,Fusion.cleanup)
                }
            }
        }
    }
end

return Module
