-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Fusion"))
local ClientCore = require(script.Parent:WaitForChild("ClientCore"))
local Pieces = require(script.Parent:WaitForChild("Pieces"))

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Observer = Fusion.Observer
local Value = Fusion.Value

local Module = {
    ActiveBoard = nil;
    BoardFlipped = nil;
}

local WImage = Value("")
local BImage = Value("")
local WName = Value("")
local BName = Value("")

local WDiff = Value(0)
local BDiff = Value(0)
local WMissing = Value({})
local BMissing = Value({})

local SizeRef = Value()

function Module:init()
    Observer(Module.ActiveBoard):onChange(function()
        if Module.ActiveBoard:get().White and Module.ActiveBoard:get().White.Name ~= WName:get() then
            WName:set(Module.ActiveBoard:get().White.Name)
            WImage:set(game.Players:GetUserThumbnailAsync(Module.ActiveBoard:get().White.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150))
        end
        if Module.ActiveBoard:get().Black and Module.ActiveBoard:get().Black.Name ~= BName:get() then
            BName:set(Module.ActiveBoard:get().Black.Name)
            BImage:set(game.Players:GetUserThumbnailAsync(Module.ActiveBoard:get().Black.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150))
        end

        if Module.ActiveBoard:get().Board then
            local Diff = ClientCore:GetPieceDifference(Module.ActiveBoard:get())
            WDiff:set(Diff.w.diff)
            BDiff:set(Diff.b.diff)
            WMissing:set(Diff.w.missing)
            BMissing:set(Diff.b.missing)
        end
    end)
end

local Order = {
    p = 1;
    r = 4;
    n = 3;
    b = 2;
    q = 5;
    k = 6;
}

function MissingPiece(Piece,Count,offset)
    local ui = {}

    for _ = 1,Count,1 do
        table.insert(ui,New "ImageLabel" {
            BackgroundTransparency = 1;
            Image = Pieces.ImageId;
            ImageRectSize = Vector2.new(170,170);
            Size = UDim2.new(1,0,1,0);
            SizeConstraint = Enum.SizeConstraint.RelativeYY;
            ImageRectOffset = Vector2.new(Pieces[Piece].X,offset)
        })
    end

    return ui
end

function Module.Ui()
    return {
        New "Frame" {
            BackgroundTransparency = 1;
            Position = UDim2.new(0,0,1,30);
            Size = UDim2.new(1,0,0.1,0);

            [Children] = {
                -- Name
                New "ImageLabel" {
                    BackgroundColor3 = Color3.fromRGB(46,46,46);
                    Size = UDim2.new(1,0,1,0);
                    SizeConstraint = Enum.SizeConstraint.RelativeYY;
                    Image = Computed(function()
                        if Module.BoardFlipped:get() == false then
                            return WImage:get()
                        end
                        return BImage:get()
                    end);
                    [Fusion.Ref] = SizeRef;

                    [Children] = {
                        New "UICorner" {
                            CornerRadius = UDim.new(0,10);
                        };

                        New "TextLabel" {
                            BackgroundTransparency = 1;
                            Font = Enum.Font.SourceSansBold;
                            Position = UDim2.new(1.1,0,0,0);
                            Size = UDim2.new(5,0,0.5,0);
                            Text = Computed(function()
                                if Module.BoardFlipped:get() == false then
                                    return WName:get()
                                end
                                return BName:get()
                            end);
                            TextColor3 = Color3.fromRGB(197,197,197);
                            TextSize = 28;
                            TextXAlignment = Enum.TextXAlignment.Left;
                        };

                        New "Frame" {
                            BackgroundTransparency = 1;
                            Position = UDim2.new(1.1,0,0.5,0);
                            Size = UDim2.new(0.5,0,0.5,0);
                            SizeConstraint = Enum.SizeConstraint.RelativeYY;

                            [Children] = {
                                New "UIListLayout" {
                                    FillDirection = Enum.FillDirection.Horizontal;
                                    SortOrder = Enum.SortOrder.LayoutOrder;
                                };
                                New "TextLabel" {
                                    BackgroundTransparency = 1;
                                    Font = Enum.Font.SourceSansBold;
                                    LayoutOrder = 15;
                                    Size = UDim2.new(1,0,1,0);
                                    Text = Computed(function()
                                        if Module.BoardFlipped:get() == false then
                                            if WDiff:get() > 0 then
                                                return "+" .. tostring(WDiff:get())
                                            end
                                        else
                                            if BDiff:get() > 0 then
                                                return "+" .. tostring(BDiff:get())
                                            end
                                        end
                                        return ""
                                    end);
                                    TextColor3 = Color3.fromRGB(197,197,197);
                                    TextSize = 23;
                                };
                                Fusion.ForPairs(Computed(function()
                                    if Module.BoardFlipped:get() == true then
                                        return WMissing:get();
                                    end
                                    return BMissing:get();
                                end),function(i,o)
                                    if o > 0 then
                                        local offset = 0
                                        if Module.BoardFlipped:get() == false then
                                            offset = 170
                                        end
                                        local sizeoffset = (((SizeRef:get().AbsoluteSize.X / 2) - 12) * (o-1))
                                        return i, New "Frame" {
                                            BackgroundTransparency = 1;
                                            Size = UDim2.new(1,sizeoffset,1,0);
                                            LayoutOrder = Order[i] or 0;

                                            [Children] = {
                                                New "UIListLayout" {
                                                    Padding = UDim.new(0,-12);
                                                    FillDirection = Enum.FillDirection.Horizontal;
                                                };
                                                MissingPiece(i,o,offset)
                                            }
                                        };
                                    end
                                    return i,{}
                                end,Fusion.cleanup)
                            };
                        };
                    }
                };
                -- Clock
                New "TextLabel" {
                    AnchorPoint = Vector2.new(1,0.5);
                    BackgroundColor3 = Computed(function()
                        if Module.BoardFlipped:get() == false then
                            return Color3.fromRGB(226,226,226);
                        end
                        return Color3.fromRGB(26,26,26);
                    end);
                    Font = Enum.Font.SourceSansBold;
                    Position = UDim2.new(1,0,0.5,0);
                    Size = UDim2.new(0.25,0,0.8,0);
                    Text = "0:00";
                    TextColor3 = Computed(function()
                        if Module.BoardFlipped:get() == false then
                            return Color3.fromRGB(26,26,26);
                        end
                        return Color3.fromRGB(226,226,226);
                    end);
                    TextTransparency = Computed(function()
                        if Module.BoardFlipped:get() == false then
                            if Module.ActiveBoard:get().Turn == "w" then
                                return 0
                            else
                                return 0.5;
                            end
                        else
                            if Module.ActiveBoard:get().Turn == "b" then
                                return 0
                            else
                                return 0.5;
                            end
                        end
                    end);
                    TextScaled = true;
                    [Children] = New "UICorner" {
                        CornerRadius = UDim.new(0,8);
                    };
                }
            };
        };

        New "Frame" {
            AnchorPoint = Vector2.new(0,1);
            BackgroundTransparency = 1;
            Position = UDim2.new(0,0,0,-10);
            Size = UDim2.new(1,0,0.1,0);

            [Children] = {
                -- Name
                New "ImageLabel" {
                    BackgroundColor3 = Color3.fromRGB(46,46,46);
                    Size = UDim2.new(1,0,1,0);
                    SizeConstraint = Enum.SizeConstraint.RelativeYY;
                    Image = Computed(function()
                        if Module.BoardFlipped:get() == true then
                            return WImage:get()
                        end
                        return BImage:get()
                    end);

                    [Children] = {
                        New "UICorner" {
                            CornerRadius = UDim.new(0,10);
                        };

                        New "TextLabel" {
                            BackgroundTransparency = 1;
                            Font = Enum.Font.SourceSansBold;
                            Position = UDim2.new(1.1,0,0,0);
                            Size = UDim2.new(5,0,0.5,0);
                            Text = Computed(function()
                                if Module.BoardFlipped:get() == true then
                                    return WName:get()
                                end
                                return BName:get()
                            end);
                            TextColor3 = Color3.fromRGB(197,197,197);
                            TextSize = 28;
                            TextXAlignment = Enum.TextXAlignment.Left;
                        };

                        New "Frame" {
                            BackgroundTransparency = 1;
                            Position = UDim2.new(1.1,0,0.5,0);
                            Size = UDim2.new(0.5,0,0.5,0);
                            SizeConstraint = Enum.SizeConstraint.RelativeYY;

                            [Children] = {
                                New "UIListLayout" {
                                    FillDirection = Enum.FillDirection.Horizontal;
                                    SortOrder = Enum.SortOrder.LayoutOrder;
                                };
                                New "TextLabel" {
                                    BackgroundTransparency = 1;
                                    Font = Enum.Font.SourceSansBold;
                                    LayoutOrder = 15;
                                    Size = UDim2.new(1,0,1,0);
                                    Text = Computed(function()
                                        if Module.BoardFlipped:get() == true then
                                            if WDiff:get() > 0 then
                                                return "+" .. tostring(WDiff:get())
                                            end
                                        else
                                            if BDiff:get() > 0 then
                                                return "+" .. tostring(BDiff:get())
                                            end
                                        end
                                        return ""
                                    end);
                                    TextColor3 = Color3.fromRGB(197,197,197);
                                    TextSize = 23;
                                };
                                Fusion.ForPairs(Computed(function()
                                    if Module.BoardFlipped:get() == false then
                                        return WMissing:get();
                                    end
                                    return BMissing:get();
                                end),function(i,o)
                                    if o > 0 then
                                        local offset = 0
                                        if Module.BoardFlipped:get() == true then
                                            offset = 170
                                        end
                                        local sizeoffset = (((SizeRef:get().AbsoluteSize.X / 2) - 12) * (o-1))
                                        return i, New "Frame" {
                                            BackgroundTransparency = 1;
                                            Size = UDim2.new(1,sizeoffset,1,0);
                                            LayoutOrder = Order[i] or 0;

                                            [Children] = {
                                                New "UIListLayout" {
                                                    Padding = UDim.new(0,-12);
                                                    FillDirection = Enum.FillDirection.Horizontal;
                                                };
                                                MissingPiece(i,o,offset)
                                            }
                                        };
                                    end
                                    return i,{}
                                end,Fusion.cleanup)
                            };
                        };
                    }
                };
                -- Clock
                New "TextLabel" {
                    AnchorPoint = Vector2.new(1,0.5);
                    BackgroundColor3 = Computed(function()
                        if Module.BoardFlipped:get() == true then
                            return Color3.fromRGB(226,226,226);
                        end
                        return Color3.fromRGB(26,26,26);
                    end);
                    Font = Enum.Font.SourceSansBold;
                    Position = UDim2.new(1,0,0.5,0);
                    Size = UDim2.new(0.25,0,0.8,0);
                    Text = "0:00";
                    TextColor3 = Computed(function()
                        if Module.BoardFlipped:get() == true then
                            return Color3.fromRGB(26,26,26);
                        end
                        return Color3.fromRGB(226,226,226);
                    end);
                    TextTransparency = Computed(function()
                        if Module.BoardFlipped:get() == true then
                            if Module.ActiveBoard:get().Turn == "w" then
                                return 0
                            else
                                return 0.5;
                            end
                        else
                            if Module.ActiveBoard:get().Turn == "b" then
                                return 0
                            else
                                return 0.5;
                            end
                        end
                    end);
                    TextScaled = true;
                    [Children] = New "UICorner" {
                        CornerRadius = UDim.new(0,8);
                    };
                }
            };
        };
    }
end

return Module

