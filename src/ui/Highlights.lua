-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Fusion"))

local New = Fusion.New
local Computed = Fusion.Computed
local Value = Fusion.Value

local Module = {
    Rendering = Value({});
    BoardFlipped = nil;

    Colors = {
        Yellow = Value(Color3.fromRGB(232,232,46));
        Red = Value(Color3.fromRGB(235,100,80));
        Blue = Value(Color3.fromRGB(80, 180, 220));
        Green = Value(Color3.fromRGB(170,200,90));
        Orange = Value(Color3.fromRGB(255,170,0));
    };
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

local ClickHighlight = ""
local MoveHighlight1 = ""
local MoveHighlight2 = ""
function Module:RemoveClickHighlight()
    if ClickHighlight ~= "" and ClickHighlight ~= MoveHighlight1 and ClickHighlight ~= MoveHighlight2 then
        local render = Module.Rendering:get()
        if render[ClickHighlight] then
            render[ClickHighlight] = nil
            Module.Rendering:set(render);
            ClickHighlight = ""
        end
    end
end

function Module:SetClickHighlight(Sqr)
    Module:RemoveClickHighlight()
    local render = Module.Rendering:get()
    render[Sqr] = "Yellow";
    Module.Rendering:set(render);
    ClickHighlight = Sqr
end

function Module:RemoveMoveHighlight()
    if MoveHighlight1 ~= "" or MoveHighlight2 ~= "" then
        local render = Module.Rendering:get()
        render[MoveHighlight1] = nil
        render[MoveHighlight2] = nil;
        Module.Rendering:set(render);
        MoveHighlight1 = ""
        MoveHighlight2 = ""
    end
end

function Module:SetMoveHighlight(Moves)
    Module:RemoveMoveHighlight()
    Module.Rendering:set({})
    if ClickHighlight ~= "" then
        Module:SetClickHighlight(ClickHighlight)
    end
    for _,o in pairs(Moves) do
        if string.split(o,"-")[2] == "x" or string.split(o,"-")[3] == "castle" then
            table.remove(Moves,table.find(Moves,o));
        end;
    end
    if typeof(Moves) ~= "table" and Moves == nil or Moves[1] == nil or #Moves <= 0 then
        return
    end
    local split = string.split(Moves[1],"-")
    if #split == 2 then
        MoveHighlight1 = split[1]
        MoveHighlight2 = split[2]
        local render = Module.Rendering:get()
        render[MoveHighlight1] = "Yellow";
        render[MoveHighlight2] = "Yellow";
        Module.Rendering:set(render);
    end
end

function Module:RemoveHighlight(Sqr)
    if MoveHighlight1 == Sqr or MoveHighlight2 == Sqr or ClickHighlight == Sqr then
        local render = Module.Rendering:get()
        render[Sqr] = "Yellow";
        Module.Rendering:set(render);
    else
        local render = Module.Rendering:get()
        render[Sqr] = nil;
        Module.Rendering:set(render);
    end
end

function Module:RemoveAll()
    for sqr,_ in pairs(Module.Rendering:get()) do
        Module:RemoveHighlight(sqr)
    end
end

function Module.Ui()
    return Fusion.ForPairs(Computed(function()
        return Module.Rendering:get()
    end),function(i,o)
        local BackgroundTransparency = 0.2
        if o == "Yellow" then
            BackgroundTransparency = 0.5
        end
        return i, New "Frame" {
            BackgroundTransparency = BackgroundTransparency;
            BackgroundColor3 = Module.Colors[o];
            Size = UDim2.new(0.125,0,0.125,0);
            Position = UDim2.new(0.125 * (GetXPos(FileTxtToNum[string.sub(i,1,1)])-1),0,0.125 * (GetYPos(tonumber(string.sub(i,2,2)))-1),0);
            ZIndex = 2;
        }
    end,Fusion.cleanup)
end

return Module

