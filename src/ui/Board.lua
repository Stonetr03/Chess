-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Fusion"))
local UserInputService = game:GetService("UserInputService")

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

local BoardRef = Value()

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

-- Get Square From Position
local FileNumToTxt = {
    [1] = "a";
    [2] = "b";
    [3] = "c";
    [4] = "d";
    [5] = "e";
    [6] = "f";
    [7] = "g";
    [8] = "h";
}
local FileTxtToNum = {
    ["a"] = 1;
    ["b"] = 2;
    ["c"] = 3;
    ["d"] = 4;
    ["e"] = 5;
    ["f"] = 6;
    ["g"] = 7;
    ["h"] = 8;
}
function GetPosition(Code: string)
    local File = GetXPos(FileTxtToNum[string.sub(Code,1,1)]) - 1
    local Rank = GetYPos(tonumber(string.sub(Code,2,2))) - 1
    return UDim2.new(0.125 * File,0, 0.125 * Rank,0)
end
function GetNewSquare(Position: Vector2)
    local BoardSize = BoardRef:get().AbsoluteSize
    local BoardPosition = BoardRef:get().AbsolutePosition
    local PieceSize = BoardSize / 8

    for file = 0,7,1 do
        local PosX = BoardPosition.X + (file * PieceSize.X)
        local PosBX = BoardPosition.X + PieceSize.X + (file * PieceSize.X)
        if Position.X >= PosX and Position.X < PosBX then
            -- Found File
            for rank = 0,7,1 do
                local PosY = BoardPosition.Y + (rank * PieceSize.Y)
                local PosBY = BoardPosition.Y + PieceSize.Y + (rank * PieceSize.Y)
                if Position.Y >= PosY and Position.Y < PosBY then
                    -- Found Rank
                    local NewFile = FileNumToTxt[GetXPos(file + 1)]
                    local NewRank = GetYPos(rank + 1)
                    return NewFile .. tostring(NewRank)
                end
            end
        end
    end
    return nil
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
                [Fusion.Ref] = BoardRef;
                [Children] = {
                    Squares = RenderBoardBG();
                    Pieces = Computed(function()
                        local NewPieces = {}
                        local board = Module.RenderingBoard:get()
                        if not board then
                            return {}
                        end
                        for rank = 1,8,1 do
                            for file = 1,8,1 do
                                if string.sub(board[rank],file,file) ~= " " then
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
                            if Pieces[o.Piece] then
                                -- Button
                                local Position = Value(UDim2.new(0.125 * (GetXPos(o.File)-1),0,0.125 * (GetYPos(o.Rank)-1),0))
                                local PieceRef = Value()

                                -- Dragging
                                local dragging
                                local dragInput
                                local dragStart
                                local startPos
                                local mousePos
                                local mouseOffset

                                local function update(input)
                                    local delta = input.Position - dragStart
                                    mousePos = Vector2.new(input.Position.X,input.Position.Y)
                                    --Position:set(UDim2.new(0,input.Position.X - BoardRef:get().AbsolutePosition.X,0,input.Position.Y - BoardRef:get().AbsolutePosition.X))
                                    Position:set(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + mouseOffset.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y + mouseOffset.Y))
                                end

                                UserInputService.InputChanged:Connect(function(input)
                                    if input == dragInput and dragging then
                                        update(input)
                                    end
                                end)
                                Ui[i] = New "ImageButton" {
                                    BackgroundTransparency = 1;
                                    Size = UDim2.new(0.125,0,0.125);
                                    Position = Position;
                                    Image = Pieces.ImageId;
                                    ImageRectSize = Vector2.new(175, 175);
                                    ImageRectOffset = Pieces[o.Piece];
                                    [Fusion.Ref] = PieceRef;

                                    -- Drag
                                    [Event "InputBegan"] = function(input)
                                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                            dragging = true
                                            dragStart = input.Position
                                            startPos = Position:get()

                                            -- Offset
                                            mouseOffset = Vector2.new( input.Position.X - (PieceRef:get().AbsolutePosition.X + (PieceRef:get().AbsoluteSize.X / 2)), input.Position.Y -  (PieceRef:get().AbsolutePosition.Y + (PieceRef:get().AbsoluteSize.Y / 2)) )

                                            input.Changed:Connect(function()
                                                if input.UserInputState == Enum.UserInputState.End then
                                                    dragging = false
                                                    -- Get Nearest Square
                                                    local NewSqr = GetNewSquare(mousePos)
                                                    if NewSqr then
                                                        print(NewSqr)
                                                        Position:set(GetPosition(NewSqr))
                                                    else
                                                        Position:set(startPos)
                                                    end
                                                end
                                            end)
                                        end
                                    end;
                                    [Event "InputChanged"] = function(input)
                                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                            dragInput = input
                                        end
                                    end;
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
