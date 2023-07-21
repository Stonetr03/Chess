-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Fusion"))

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Event = Fusion.OnEvent

local Module = {
    Challenge = nil;
}

local CurrentGamesList = Value({})
local PlayersList = Value({})
local InvitesList = Value({})

function Module.Title(props)
    return New "TextLabel" {
        BackgroundTransparency = 1;
        Position = props.Position;
        Size = UDim2.new(0.2,0,0.05,0);
        Font = Enum.Font.SourceSans;
        Text = props.Text;
        TextScaled = true;
        TextColor3 = Color3.new(1,1,1);
        [Children] = New "Frame" {
            BackgroundColor3 = Color3.new(1,1,1);
            Position = UDim2.new(0,0,1,-1);
            Size = UDim2.new(1,0,0,2);
        };
    }
end

function Module.List(props)
    return New "ScrollingFrame" {
        BackgroundTransparency = 1;
        Position = props.Position;
        Size = UDim2.new(0.2,0,0.7,0);
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        TopImage = "";
        BottomImage = "";
        MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
        ScrollBarImageColor3 = Color3.new(1,1,1);
        ScrollBarThickness = 5;
        ScrollingDirection = Enum.ScrollingDirection.Y;
        [Children] = {
            New "UIListLayout" {
                Padding = UDim.new(0,2);
            };
            props.Children;
        }
    }
end

function Module.Ui(props)
    return New "Frame" {
        Visible = Computed(function()
            if props.ActiveGame:get() == "" then
                return true
            end
            return false
        end);
        Size = UDim2.new(1,0,1,0);
        ZIndex = 2;
        BackgroundTransparency = 1;
        [Children] = {
            Module.Title({Position = UDim2.new(0.1,0,0.075,0),Text = "Current Games"});
            Module.Title({Position = UDim2.new(0.4,0,0.075,0),Text = "Players"});
            Module.Title({Position = UDim2.new(0.7,0,0.075,0),Text = "Invites"});

            Module.List({Position = UDim2.new(0.1,0,0.15,0),Children = Fusion.ForPairs(CurrentGamesList,function(i,o)
                return i, New "TextButton" {
                    BackgroundColor3 = Color3.fromRGB(88,88,88);
                    Size = UDim2.new(1,0,0.2,0);
                    SizeConstraint = Enum.SizeConstraint.RelativeXX;
                    Font = Enum.Font.SourceSans;
                    TextScaled = true;
                    Text = o[2][1].Name .. "\n" .. o[2][2].Name;
                    TextColor3 = Color3.new(1,1,1);
                    AutoButtonColor = true;
                    [Children] = {
                        New "UICorner" {
                            CornerRadius = UDim.new(0.2,0);
                        };
                        New "UIPadding" {
                            PaddingLeft = UDim.new(0.02,0);
                            PaddingRight = UDim.new(0.02,0);
                        };
                    };
                }
            end,Fusion.cleanup)});
            Module.List({Position = UDim2.new(0.4,0,0.15,0),Children = Fusion.ForPairs(PlayersList,function(i,o)
                return i, New "TextButton" {
                    BackgroundColor3 = Color3.fromRGB(88,88,88);
                    Size = UDim2.new(1,0,0.2,0);
                    SizeConstraint = Enum.SizeConstraint.RelativeXX;
                    Font = Enum.Font.SourceSans;
                    TextScaled = true;
                    Text = o.Name;
                    TextColor3 = Color3.new(1,1,1);
                    AutoButtonColor = true;
                    [Children] = {
                        New "UICorner" {
                            CornerRadius = UDim.new(0.2,0);
                        };
                        New "UIPadding" {
                            PaddingLeft = UDim.new(0.02,0);
                            PaddingRight = UDim.new(0.02,0);
                        };
                    };
                    [Event "MouseButton1Up"] = function()
                        Module.Challenge(o)
                    end
                }
            end,Fusion.cleanup)});
            Module.List({Position = UDim2.new(0.7,0,0.15,0),Children = Fusion.ForPairs(InvitesList,function(i,o)
                return i, New "TextButton" {
                    BackgroundColor3 = Color3.fromRGB(88,88,88);
                    Size = UDim2.new(1,0,0.2,0);
                    SizeConstraint = Enum.SizeConstraint.RelativeXX;
                    Font = Enum.Font.SourceSans;
                    TextScaled = true;
                    Text = o[1].Name;
                    TextColor3 = Color3.new(1,1,1);
                    AutoButtonColor = true;
                    [Children] = {
                        New "UICorner" {
                            CornerRadius = UDim.new(0.2,0);
                        };
                        New "UIPadding" {
                            PaddingLeft = UDim.new(0.02,0);
                            PaddingRight = UDim.new(0.02,0);
                        };
                    };
                    [Event "MouseButton1Up"] = function()
                        Module.Challenge(o[1])
                    end
                }
            end,Fusion.cleanup)});
        }
    }
end

function Module:SetPlayers(Games,Invites,Players)
    CurrentGamesList:set(Games)
    InvitesList:set(Invites)
    PlayersList:set(Players)
end

return Module
