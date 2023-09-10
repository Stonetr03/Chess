-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Fusion"))
local UserInputService = game:GetService("UserInputService")

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Event = Fusion.OnEvent
local Value = Fusion.Value

local Module = {
    BoardSize = Value(UDim2.new(0.75,0,0.75,0));
    BoardAbsSize = nil;
    BoardAbsPos = nil;
}

local Size = Value(0.75)
local AbsSize = Value()
local AbsPos = Value()

-- Dragging
local Position = Value(UDim2.new(1,5,1,-20))
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	-- Convert Delta Offset to Scale
	local scaleY = delta.Y / AbsSize:get().Y
	local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale + scaleY, startPos.Y.Offset) -- + delta.Y
	if newPos.Y.Scale < 0.001 then
		newPos = UDim2.new(1,5,0.001,-20)
	end

    -- X
    local BoardSize = Module.BoardAbsSize:get();
    local BoardPos = Module.BoardAbsPos:get();
    if BoardSize and BoardPos then
        local ToX = BoardSize.X + BoardPos.X - AbsPos:get().X + 5
        if ToX then
            newPos = UDim2.new(UDim.new(0,ToX),newPos.Y)
        end
    end

	Position:set(newPos)
    Module.BoardSize:set(UDim2.new(Size:get() * Position:get().Y.Scale,0,Size:get() * Position:get().Y.Scale,0))
end

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)


function Module.Ui()
    return New "Frame" {
        BackgroundTransparency = 1;
        Size = Computed(function()
            return UDim2.new(Size:get(),0,Size:get(),0);
        end);
        Position = UDim2.new(0.5,0,0.12,0);
        AnchorPoint = Vector2.new(.5,0);
        SizeConstraint = Enum.SizeConstraint.RelativeYY;
        [Fusion.Out "AbsoluteSize"] = AbsSize;
        [Fusion.Out "AbsolutePosition"] = AbsPos;

        [Children] = New "ImageButton" {
            Size = UDim2.new(0,20,0,20);
            Position = Position;
            BackgroundColor3 = Color3.new(0,0,0);
            BackgroundTransparency = 0.5;
            Image = "rbxassetid://11295287825";
            Rotation = 90;
            -- Drag
            [Event "InputBegan"] = function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = Position:get()

                    local con
                    con = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                            con:Disconnect()
                            Size:set(Size:get() * Position:get().Y.Scale)
                            Position:set(UDim2.new(1,5,1,-20))
                            Module.BoardSize:set(UDim2.new(Size:get() * Position:get().Y.Scale,0,Size:get() * Position:get().Y.Scale,0))
                        end
                    end)
                end
            end;
            [Event "InputChanged"] = function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput = input
                end
            end;
            [Event "MouseButton2Up"] = function()
                Size:set(0.75)
                Position:set(UDim2.new(1,5,1,-20))
                Module.BoardSize:set(UDim2.new(0.75,0,0.75,0))
            end;
        }
    }
end

return Module
