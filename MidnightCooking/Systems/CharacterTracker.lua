local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Systems = MC.Systems or {}
MC.Systems.CharacterTracker = MC.Systems.CharacterTracker or {}

local function getCharacterKey()
    local name = UnitName("player") or "Unknown"
    local realm = GetRealmName() or "UnknownRealm"
    return name .. "-" .. realm
end

function MC.Systems.CharacterTracker:Initialize()
    local db = MC:GetSavedDB()
    db.characters = db.characters or {}
    db.profile = db.profile or {}
    db.config = db.config or {}
    db.account = db.account or {}
    db.account.characters = db.account.characters or {}
    MC.DB = db

    local key = getCharacterKey()
    if not db.characters[key] then
        db.characters[key] = {
            name = UnitName("player") or "Unknown",
            realm = GetRealmName() or "UnknownRealm",
            recipes = {},
            lastScan = 0,
        }
    end

    if not db.account.characters[key] then
        db.account.characters[key] = {
            name = UnitName("player") or "Unknown",
            realm = GetRealmName() or "UnknownRealm",
            recipes = {},
            lastScan = 0,
        }
    end
end

function MC.Systems.CharacterTracker:GetCurrentCharacterKey()
    return getCharacterKey()
end

function MC.Systems.CharacterTracker:GetCurrentCharacter()
    local key = self:GetCurrentCharacterKey()
    local db = MC:GetSavedDB()
    db.characters = db.characters or {}
    return db.characters[key]
end

function MC.Systems.CharacterTracker:GetAccountCharacter(key)
    local db = MC:GetSavedDB()
    db.account = db.account or {}
    db.account.characters = db.account.characters or {}
    return db.account.characters[key]
end

function MC.Systems.CharacterTracker:ScanCurrentCharacter()
    local character = self:GetCurrentCharacter()
    if not character then
        return {}
    end

    character.recipes = character.recipes or {}
    character.lastScan = time()

    local accountCharacter = self:GetAccountCharacter(self:GetCurrentCharacterKey())
    if accountCharacter then
        accountCharacter.recipes = character.recipes
        accountCharacter.lastScan = character.lastScan
    end

    return character.recipes
end

function MC.Systems.CharacterTracker:GetLiveCharacterSnapshot()
    local character = self:GetCurrentCharacter()
    if not character then
        return {}
    end

    local snapshot = {}
    for recipeID, value in pairs(character.recipes or {}) do
        snapshot[recipeID] = value
    end

    return snapshot
end

function MC.Systems.CharacterTracker:GetEffectiveRecipes()
    local live = self:GetLiveCharacterSnapshot()
    local key = self:GetCurrentCharacterKey()
    local accountCharacter = self:GetAccountCharacter(key)

    if not accountCharacter then
        return live
    end

    local merged = {}
    for recipeID, value in pairs(accountCharacter.recipes or {}) do
        merged[recipeID] = value
    end

    for recipeID, value in pairs(live) do
        merged[recipeID] = value
    end

    return merged
end
