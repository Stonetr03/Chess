-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Fusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Signal"))
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
    MakeMove = nil;
}

local BoardRef = Value()

-- Settings
local BoardWColor = Value(Color3.fromRGB(240, 217, 181))
local BoardBColor = Value(Color3.fromRGB(181, 136, 99))

local PieceColors = {
    w = {"R","N","B","Q","K","P"};
    b = {"r","n","b","q","k","p"};
}

local MouseButtonSignal = Signal.new()
local PromoteSignal = Signal.new()

local PromoteOffset = Value(0)
local PromoteVis = Value(false)
local PromotePosition = Value(UDim2.new(0,0,0,0))

MouseButtonSignal:Connect(function()
    print("Mouse Click")
    print("PromoteVis:", PromoteVis:get());
    if PromoteVis:get() == true then
        PromoteSignal:Fire("")
        task.wait()
        PromoteVis:set(false)
    end
end);

function PromoteUi()
    New "Frame" {
        BackgroundColor3 = Color3.fromRGB(162,162,162);
        BorderColor3 = Color3.fromRGB(27,42,53);
        BorderMode = Enum.BorderMode.Outline;
        BorderSizePixel = 5;
        Size = UDim2.new(0.125,0,4 * 0.125,0);
        ZIndex = 100;
        Visible = PromoteVis;
        Position = PromotePosition;
        AnchorPoint = Computed(function()
            if PromotePosition:get().Y.Scale == 0.875 then
                return Vector2.new(0,0.75);
            end
            return Vector2.new(0,0)
        end);
        Parent = BoardRef;

        [Children] = {
            New "ImageButton" {
                BackgroundTransparency = 1;
                BackgroundColor3 = Color3.new(0,0,0);
                Image = Pieces.ImageId;
                ImageRectOffset = Computed(function()
                    return Vector2.new(Pieces.Q.X,PromoteOffset:get());
                end);
                ImageRectSize = Vector2.new(175,175);
                Size = UDim2.new(1,0,0.25,0);
                Position = Computed(function()
                    if PromotePosition:get().Y.Scale == 0.875 then
                        return UDim2.new(0,0,0.75,0);
                    end
                    return UDim2.new(0,0,0,0)
                end);
                [Event "MouseButton1Down"] = function()
                    PromoteSignal:Fire("Q")
                end
            };
            New "ImageButton" {
                BackgroundTransparency = 0.8;
                BackgroundColor3 = Color3.new(0,0,0);
                Image = Pieces.ImageId;
                ImageRectOffset = Computed(function()
                    return Vector2.new(Pieces.N.X,PromoteOffset:get());
                end);
                ImageRectSize = Vector2.new(175,175);
                Size = UDim2.new(1,0,0.25,0);
                Position = Computed(function()
                    if PromotePosition:get().Y.Scale == 0.875 then
                        return UDim2.new(0,0,0.5,0);
                    end
                    return UDim2.new(0,0,0.25,0)
                end);
                [Event "MouseButton1Down"] = function()
                    PromoteSignal:Fire("N")
                end
            };
            New "ImageButton" {
                BackgroundTransparency = 1;
                BackgroundColor3 = Color3.new(0,0,0);
                Image = Pieces.ImageId;
                ImageRectOffset = Computed(function()
                    return Vector2.new(Pieces.R.X,PromoteOffset:get());
                end);
                ImageRectSize = Vector2.new(175,175);
                Size = UDim2.new(1,0,0.25,0);
                Position = Computed(function()
                    if PromotePosition:get().Y.Scale == 0.875 then
                        return UDim2.new(0,0,0.25,0);
                    end
                    return UDim2.new(0,0,0.5,0)
                end);
                [Event "MouseButton1Down"] = function()
                    PromoteSignal:Fire("R")
                end
            };
            New "ImageButton" {
                BackgroundTransparency = 0.8;
                BackgroundColor3 = Color3.new(0,0,0);
                Image = Pieces.ImageId;
                ImageRectOffset = Computed(function()
                    return Vector2.new(Pieces.B.X,PromoteOffset:get());
                end);
                ImageRectSize = Vector2.new(175,175);
                Size = UDim2.new(1,0,0.25,0);
                Position = Computed(function()
                    if PromotePosition:get().Y.Scale == 0.875 then
                        return UDim2.new(0,0,0,0);
                    end
                    return UDim2.new(0,0,0.75,0)
                end);
                [Event "MouseButton1Down"] = function()
                    PromoteSignal:Fire("B")
                end
            }
        }
    }
end

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
    if typeof(Position) ~= "Vector2" then
        return nil
    end
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
                    Promote = PromoteUi();
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

                                local OldSqr = FileNumToTxt[o.File] .. tostring(o.Rank)

                                local function update(input)
                                    local delta = input.Position - dragStart
                                    mousePos = Vector2.new(input.Position.X,input.Position.Y)
                                    Position:set(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + mouseOffset.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y + mouseOffset.Y))
                                end

                                local Con1
                                Con1 = UserInputService.InputChanged:Connect(function(input)
                                    if input == dragInput and dragging then
                                        update(input)
                                    end
                                end)
                                Ui[i] = New "ImageButton" {
                                    Name = o.Piece;
                                    BackgroundTransparency = 1;
                                    Size = UDim2.new(0.125,0,0.125);
                                    Position = Position;
                                    Image = Pieces.ImageId;
                                    ImageRectSize = Vector2.new(175, 175);
                                    ImageRectOffset = Pieces[o.Piece];
                                    [Fusion.Ref] = PieceRef;
                                    [Fusion.Cleanup] = {
                                        Con1;
                                        Position;
                                        PieceRef;
                                    };

                                    -- Drag
                                    [Event "InputBegan"] = function(input)
                                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch and PromoteVis:get() ~= true then
                                            dragging = true
                                            dragStart = input.Position
                                            startPos = Position:get()

                                            -- Offset
                                            mouseOffset = Vector2.new( input.Position.X - (PieceRef:get().AbsolutePosition.X + (PieceRef:get().AbsoluteSize.X / 2)), input.Position.Y -  (PieceRef:get().AbsolutePosition.Y + (PieceRef:get().AbsoluteSize.Y / 2)) )

                                            local con
                                            con = input.Changed:Connect(function()
                                                if input.UserInputState == Enum.UserInputState.End then
                                                    dragging = false
                                                    -- Get Nearest Square
                                                    local NewSqr = GetNewSquare(mousePos)
                                                    if NewSqr then
                                                        -- Make sure its your piece and not opponants piece
                                                        if Module.ActiveBoard:get().White and Module.ActiveBoard:get().White == game.Players.LocalPlayer then
                                                            -- Is the w player
                                                            if table.find(PieceColors.w,o.Piece) then
                                                                -- Can Move
                                                                Position:set(GetPosition(NewSqr))
                                                                print(NewSqr,OldSqr)
                                                                if NewSqr ~= OldSqr then
                                                                    -- Moved Piece
                                                                    if Module.ActiveBoard:get().Turn == "w" then
                                                                        -- Make Move
                                                                        -- Check if premoves first
                                                                        local ExtraCode = ""
                                                                        if o.Piece == "P" and tonumber(string.sub(NewSqr,2,2)) == 8 then
                                                                            -- Promote
                                                                            task.wait()
                                                                            PromoteVis:set(true)
                                                                            PromoteOffset:set(0)
                                                                            PromotePosition:set(Position:get())
                                                                            local Yield = false
                                                                            PromoteSignal:Once(function(Piece)
                                                                                ExtraCode = Piece
                                                                                Yield = true
                                                                            end)
                                                                            repeat
                                                                                task.wait()
                                                                            until Yield == true
                                                                            if ExtraCode == "" then
                                                                                Position:set(startPos)
                                                                                if con then
                                                                                    con:Disconnect()
                                                                                    con = nil;
                                                                                end
                                                                                return
                                                                            end
                                                                        elseif o.Piece == "K" and NewSqr == "h1" and OldSqr == "e1" then
                                                                            NewSqr = "g1"
                                                                        elseif o.Piece == "K" and NewSqr == "a1" and OldSqr == "e1" then
                                                                            NewSqr = "c1"
                                                                        elseif o.Piece == "K" and NewSqr == "b1" and OldSqr == "e1" then
                                                                            NewSqr = "c1"
                                                                        end
                                                                        print('extra code',ExtraCode)
                                                                        if Module.MakeMove(OldSqr,NewSqr,ExtraCode) == false then
                                                                            Position:set(startPos)
                                                                        else
                                                                            OldSqr = NewSqr
                                                                        end
                                                                    else
                                                                        -- Premove
                                                                        Position:set(startPos)
                                                                    end
                                                                end
                                                            else
                                                                Position:set(startPos)
                                                            end
                                                        elseif Module.ActiveBoard:get().Black and Module.ActiveBoard:get().Black == game.Players.LocalPlayer then
                                                            -- Is the b player
                                                            if table.find(PieceColors.b,o.Piece) then
                                                                -- Can Move
                                                                Position:set(GetPosition(NewSqr))
                                                                print(NewSqr,OldSqr)
                                                                if NewSqr ~= OldSqr then
                                                                    -- Moved Piece
                                                                    if Module.ActiveBoard:get().Turn == "b" then
                                                                        -- Make Move
                                                                        -- Check if premoves first
                                                                        local ExtraCode = ""
                                                                        if o.Piece == "p" and tonumber(string.sub(NewSqr,2,2)) == 1 then
                                                                            -- Promote
                                                                            task.wait()
                                                                            PromoteVis:set(true)
                                                                            PromoteOffset:set(175)
                                                                            PromotePosition:set(Position:get())
                                                                            local Yield = false
                                                                            PromoteSignal:Once(function(Piece)
                                                                                ExtraCode = Piece
                                                                                Yield = true
                                                                            end)
                                                                            repeat
                                                                                task.wait()
                                                                            until Yield == true
                                                                            if ExtraCode == "" then
                                                                                Position:set(startPos)
                                                                                if con then
                                                                                    con:Disconnect()
                                                                                    con = nil;
                                                                                end
                                                                                return
                                                                            end
                                                                        elseif o.Piece == "k" and NewSqr == "h8" and OldSqr == "e8" then
                                                                            NewSqr = "g8"
                                                                        elseif o.Piece == "k" and NewSqr == "a8" and OldSqr == "e8" then
                                                                            NewSqr = "c8"
                                                                        elseif o.Piece == "k" and NewSqr == "b8" and OldSqr == "e8" then
                                                                            NewSqr = "c8"
                                                                        end
                                                                        if Module.MakeMove(OldSqr,NewSqr,ExtraCode) == false then
                                                                            Position:set(startPos)
                                                                        else
                                                                            OldSqr = NewSqr
                                                                        end
                                                                    else
                                                                        -- Premove
                                                                        Position:set(startPos)
                                                                    end
                                                                    OldSqr = NewSqr
                                                                end
                                                            else
                                                                Position:set(startPos)
                                                            end
                                                        else
                                                            Position:set(startPos)
                                                        end
                                                    else
                                                        Position:set(startPos)
                                                    end

                                                    -- Cleanup
                                                    if con then
                                                        con:Disconnect()
                                                        con = nil;
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

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        MouseButtonSignal:Fire()
    end
end)

return Module
