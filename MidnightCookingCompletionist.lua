local addonName, addon = ...

_G.MidnightCookingCompletionist = _G.MidnightCookingCompletionist or {}
local MC = _G.MidnightCookingCompletionist

MC.name = addonName
MC.version = "0.1.0"
MC.clientVersion = "12.1.0"
MC.DB = MC.DB or {}
MC.API = MC.API or {}
MC.Database = MC.Database or {}
MC.Systems = MC.Systems or {}
MC.Core = MC.Core or {}
MC.Utils = MC.Utils or {}
MC.Config = MC.Config or {}
MC.initialized = false

function MC:Log(message)
    if type(message) ~= "string" then
        message = tostring(message)
    end

    print("|cff8bd4ffMidnight Cooking Completionist|r " .. message)
end

function MC:GetSavedDB()
    if type(_G.MidnightCookingCompletionistDB) ~= "table" then
        _G.MidnightCookingCompletionistDB = {}
    end

    return _G.MidnightCookingCompletionistDB
end

function MC:InitializeSavedVariables()
    local db = self:GetSavedDB()
    db.characters = db.characters or {}
    db.profile = db.profile or {}
    db.config = db.config or {}
    self.DB = db
    return db
end
