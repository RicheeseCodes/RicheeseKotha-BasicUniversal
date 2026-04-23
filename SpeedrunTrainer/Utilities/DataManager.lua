--[[
    DataManager - Handles saving and loading data (routes, replays, configs)
]]

local DataManager = {}
DataManager.__index = DataManager

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Try to use DataStore, fall back to local storage
local function GetDataStore(name)
    local success, result = pcall(function()
        return DataStoreService:GetDataStore(name)
    end)
    
    if success then
        return result
    end
    
    return nil
end

function DataManager:Init()
    self.dataStore = GetDataStore("SpeedrunTrainer")
    self.localData = {} -- Fallback for when DataStore is unavailable
    
    return self
end

-- Save data
function DataManager:Save(key, data)
    if self.dataStore then
        local success, err = pcall(function()
            local json = game:GetService("HttpService"):JSONEncode(data)
            self.dataStore:SetAsync(key, json)
        end)
        
        if success then
            return true
        end
    end
    
    -- Fallback to local storage
    self.localData[key] = data
    return true
end

-- Load data
function DataManager:Load(key)
    if self.dataStore then
        local success, result = pcall(function()
            return self.dataStore:GetAsync(key)
        end)
        
        if success and result then
            local decodedSuccess, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(result)
            end)
            
            if decodedSuccess then
                return true, data
            end
        end
    end
    
    -- Fallback to local storage
    if self.localData[key] then
        return true, self.localData[key]
    end
    
    return false, nil
end

-- Delete data
function DataManager:Delete(key)
    if self.dataStore then
        local success = pcall(function()
            self.dataStore:RemoveAsync(key)
        end)
        
        if success then
            return true
        end
    end
    
    self.localData[key] = nil
    return true
end

-- Save routes
function DataManager:SaveRoutes(routes)
    return self:Save("routes", routes)
end

-- Load routes
function DataManager:LoadRoutes()
    return self:Load("routes")
end

-- Save replays
function DataManager:SaveReplays(replays)
    return self:Save("replays", replays)
end

-- Load replays
function DataManager:LoadReplays()
    return self:Load("replays")
end

-- Save settings
function DataManager:SaveSettings(settings)
    return self:Save("settings", settings)
end

-- Load settings
function DataManager:LoadSettings()
    return self:Load("settings")
end

-- Save statistics
function DataManager:SaveStatistics(stats)
    return self:Save("statistics", stats)
end

-- Load statistics
function DataManager:LoadStatistics()
    return self:Load("statistics")
end

return DataManager
