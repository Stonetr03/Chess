-- Admin Cube - Data Store Controller / Handler

local DataStoreService = game:GetService("DataStoreService")
local DataStore = DataStoreService:GetDataStore("_ChessSettings")

local Module = {
    Data = {};
}

local SavingFor = {}
local NeedsSaving = {}
local LastSave = {}
local BlockSaving = {}

local DefaultData = {
    DataVersion = 1;
    Piece = "standard";
    WColor = "f0d9b5";
    BColor = "b58863";
}

local function CheckData(Data)
    if typeof(Data) ~= "table" then
        Data = {}
    end

    local NewData = {}
    local Updated = false
    for o,i in pairs(DefaultData) do
        if Data[o] then
            NewData[o] = Data[o]
        else
            Updated = true
            NewData[o] = i
        end
    end
    return NewData,Updated
end

function Module:GetDataStore(Key)
    local Data
    local s,e = pcall(function()
        Data = DataStore:GetAsync(Key)
    end)
    if not s then
        warn("Unable to save",Key,":",e)
        BlockSaving[Key] = true
    end
    NeedsSaving[Key] = false
    if Data == nil then
        Data = DefaultData
        NeedsSaving[Key] = true
    end

    -- Check Data / Update Data
    local NewData,Updated = CheckData(Data)
    Module.Data[Key] = NewData
    if Updated == true then
        NeedsSaving[Key] = true
    end

    SavingFor[Key] = false
    LastSave[Key] = os.time()

    return NewData
end

-- Save Data
function SaveDataStore(Key)
    if SavingFor[Key] == true then
        return false
    end
    if BlockSaving[Key] == true then
        return false
    end
    print("Save",Key,Module.Data[Key])
    SavingFor[Key] = true
    local s,e = pcall(function()
        -- Save to DataStore
        DataStore:SetAsync(Key,Module.Data[Key])
    end)
    if not s then
        warn(e)
    else
        NeedsSaving[Key] = false
    end
    LastSave[Key] = os.time() + 60
    SavingFor[Key] = false
    return s
end

function Module:SaveData()
    for Key,ToUpdate in pairs(NeedsSaving) do
        if ToUpdate == true then

            if LastSave[Key] < os.time() then
                SaveDataStore(Key)
            end

        end
    end
end

-- Used for when Player is Leaving the server
function Module:ExitDataStore(Key)
    -- Remove Server Data
    if NeedsSaving[Key] == true then
        SaveDataStore(Key)
    end

    Module.Data[Key] = nil
    NeedsSaving[Key] = false
    LastSave[Key] = false
    SavingFor[Key] = false
    BlockSaving[Key] = false
    return
end

function Module:UpdateData(Key,Name,Value)
    if Module.Data[Key][Name] == Value then
        return -- Already Current Value
    end

    Module.Data[Key][Name] = Value
    NeedsSaving[Key] = true
    Module:SaveData()
end

-- Bind to Close
game:BindToClose(function()
    for Key,ToUpdate in pairs(NeedsSaving) do
        if ToUpdate == true then
            SaveDataStore(Key)
        end
    end
    task.wait(3)
end)

return Module