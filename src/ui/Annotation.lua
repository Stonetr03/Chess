-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Fusion"))

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value
local Event = Fusion.OnEvent

local Module = {
    BoardFlipped = nil;
    ScreenGuiRef = Value();
    BoardRef = nil;
    Confirmation = Value(0); -- 0:Not Visible, 1:Resign, 2:Draw, 3:Draw Offer

    Resign = nil;
    Draw = nil;
}

function Module.Ui()
    return New "Frame" {
        AnchorPoint = Vector2.new(0,0.5);
        Position = UDim2.new(1,5,0.5,0);
        Size = Computed(function()
            local ScreenGui = Module.ScreenGuiRef:get()
            local Board = Module.BoardRef:get()
            if ScreenGui and Board then
                return UDim2.new(0,((ScreenGui.AbsoluteSize.X - Board.AbsolutePosition.X) - Board.AbsoluteSize.X) - 10,0.6,0)
            end
            return UDim2.new(0,0,0,0)
        end);

        [Children] = {
            -- Buttons
            -- Draw
            New "TextButton" {
                AnchorPoint = Vector2.new(0,1);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0,0,1,0);
                Size = UDim2.new(0.44,0,0.08,0);
                Text = "Draw";
                TextColor3 = Color3.fromRGB(197,197,197);
                TextScaled = true;
                [Event "MouseButton1Up"] = function()
                    if Module.Confirmation:get() == 2 then
                        Module.Confirmation:set(0)
                    else
                        Module.Confirmation:set(2)
                    end
                end;
                [Children] = New "UIPadding" {
                    PaddingBottom = UDim.new(0.03,0)
                }
            };
            -- Resign
            New "TextButton" {
                AnchorPoint = Vector2.new(0,1);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0.44,0,1,0);
                Size = UDim2.new(0.44,0,0.08,0);
                Text = "Resign";
                TextColor3 = Color3.fromRGB(197,197,197);
                TextScaled = true;
                [Event "MouseButton1Up"] = function()
                    if Module.Confirmation:get() == 1 then
                        Module.Confirmation:set(0)
                    else
                        Module.Confirmation:set(1)
                    end
                end;
                [Children] = New "UIPadding" {
                    PaddingBottom = UDim.new(0.03,0)
                }
            };
            -- Flip Board
            New "ImageButton" {
                AnchorPoint = Vector2.new(0,1);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Image = "rbxassetid://11419667031";
                ImageColor3 = Color3.fromRGB(197,197,197);
                Position = UDim2.new(0.88,0,1,0);
                ScaleType = Enum.ScaleType.Fit;
                Size = UDim2.new(0.12,0,0.08,0);
                [Event "MouseButton1Up"] = function()
                    Module.BoardFlipped:set(not Module.BoardFlipped:get())
                end;
            };


            -- Confirmation
            New "Frame" {
                AnchorPoint = Vector2.new(0.5,1);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Position = UDim2.new(0.5,0,0.9,0);
                Size = UDim2.new(0.95,0,0.2,0);
                Visible = Computed(function()
                    if Module.Confirmation:get() == 0 then
                        return false
                    end
                    return true
                end);
                [Children] = {
                    New "UICorner" {
                        CornerRadius = UDim.new(0.12,0);
                    };
                    
                    New "TextLabel" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSansBold;
                        Size = UDim2.new(1,0,0.5,0);
                        Text = Computed(function()
                            local v = Module.Confirmation:get()
                            if v == 1 then
                                return "Are you sure you want to resign?"
                            elseif v == 2 then
                                return "Are you sure you want to offer a draw?"
                            elseif v == 3 then
                                return "Would you like to accept a draw?";
                            end;
                            return ""
                        end);
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Children] = New "UIPadding" {
                            PaddingBottom = UDim.new(0.03,0);
                            PaddingLeft = UDim.new(0,5);
                            PaddingRight = UDim.new(0,5);
                        };
                    };
                    -- Yes
                    New "TextButton" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSans;
                        Position = UDim2.new(0,0,0.5,0);
                        Size = UDim2.new(0.5,0,0.5,0);
                        Text = "Yes";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            local v = Module.Confirmation:get()
                            if v == 1 then
                                -- Resign
                                Module.Resign()
                            elseif v == 2 then
                                -- Draw
                                Module.Draw(true)
                            elseif v == 3 then
                                -- Draw
                                Module.Draw(true)
                            end;
                            Module.Confirmation:set(0)
                        end;
                        [Children] = New "UIPadding" {
                            PaddingBottom = UDim.new(0.1,0);
                            PaddingLeft = UDim.new(0,5);
                            PaddingRight = UDim.new(0,5);
                            PaddingTop = UDim.new(0.05,0);
                        };
                    };
                    -- No
                    New "TextButton" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSans;
                        Position = UDim2.new(0.5,0,0.5,0);
                        Size = UDim2.new(0.5,0,0.5,0);
                        Text = "No";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            if Module.Confirmation:get() == 3 then
                                -- Draw
                                Module.Draw(false)
                            end
                            Module.Confirmation:set(0)
                        end;
                        [Children] = New "UIPadding" {
                            PaddingBottom = UDim.new(0.1,0);
                            PaddingLeft = UDim.new(0,5);
                            PaddingRight = UDim.new(0,5);
                            PaddingTop = UDim.new(0.05,0);
                        };
                    }
                }
            };
        }
    }
end

return Module
