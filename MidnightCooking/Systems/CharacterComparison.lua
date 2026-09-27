local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Systems = MC.Systems or {}
MC.Systems.CharacterComparison = MC.Systems.CharacterComparison or {}

local function resolveCharacter(characterOrKey, db)
    db = db or MC:GetSavedDB()

    if type(characterOrKey) == "string" then
        local key = characterOrKey
        if db.characters and db.characters[key] then
            return db.characters[key]
        end

        if db.account and db.account.characters and db.account.characters[key] then
            return db.account.characters[key]
        end

        return nil
    end

    return characterOrKey
end

local function asRecipeSet(character)
    local recipes = {}

    if not character or type(character.recipes) ~= "table" then
        return recipes
    end

    for recipeID in pairs(character.recipes) do
        recipes[tostring(recipeID)] = true
    end

    return recipes
end

local function buildStatusSummary(recipeSet, recipeDB)
    local statusMap = (MC.Constants and MC.Constants.RECIPE_STATUS) or {
        LEARNED = "LEARNED",
        MISSING = "MISSING",
        UNKNOWN = "UNKNOWN",
        UNAVAILABLE = "UNAVAILABLE",
    }

    local summary = {
        total = 0,
        learned = 0,
        missing = 0,
        unknown = 0,
        unavailable = 0,
    }

    local ids = {}
    for recipeID in pairs(recipeSet) do
        table.insert(ids, recipeID)
    end

    table.sort(ids, function(a, b)
        local an = tonumber(a) or 0
        local bn = tonumber(b) or 0
        return an < bn
    end)

    for _, recipeID in ipairs(ids) do
        summary.total = summary.total + 1

        local numericID = tonumber(recipeID)
        local recipe = recipeDB and (recipeDB[numericID] or recipeDB[recipeID])
        local status = statusMap.UNKNOWN

        if recipe and recipe.playerState and recipe.playerState.status then
            status = recipe.playerState.status
        elseif recipe and recipe.playerState and recipe.playerState.learned == true then
            status = statusMap.LEARNED
        end

        if status == statusMap.LEARNED then
            summary.learned = summary.learned + 1
        elseif status == statusMap.MISSING then
            summary.missing = summary.missing + 1
        elseif status == statusMap.UNAVAILABLE then
            summary.unavailable = summary.unavailable + 1
        else
            summary.unknown = summary.unknown + 1
        end
    end

    summary.percentage = 0
    if summary.total > 0 then
        summary.percentage = (summary.learned / summary.total) * 100
    end

    return summary
end

function MC.Systems.CharacterComparison:CompareCharacters(firstCharacter, secondCharacter)
    local db = MC:GetSavedDB()
    local first = resolveCharacter(firstCharacter, db)
    local second = resolveCharacter(secondCharacter, db)

    local firstSet = asRecipeSet(first)
    local secondSet = asRecipeSet(second)
    local shared = {}
    local uniqueToFirst = {}
    local uniqueToSecond = {}

    for recipeID in pairs(firstSet) do
        if secondSet[recipeID] then
            shared[recipeID] = true
        else
            uniqueToFirst[recipeID] = true
        end
    end

    for recipeID in pairs(secondSet) do
        if not firstSet[recipeID] then
            uniqueToSecond[recipeID] = true
        end
    end

    local recipeDB = MC.Database and MC.Database.Recipes or {}

    return {
        firstKey = first and first.name and (first.name .. "-" .. (first.realm or "UnknownRealm")) or "unknown",
        secondKey = second and second.name and (second.name .. "-" .. (second.realm or "UnknownRealm")) or "unknown",
        shared = shared,
        uniqueToFirst = uniqueToFirst,
        uniqueToSecond = uniqueToSecond,
        summaryFirst = buildStatusSummary(firstSet, recipeDB),
        summarySecond = buildStatusSummary(secondSet, recipeDB),
    }
end

function MC.Systems.CharacterComparison:CompareCharacterKeys(firstKey, secondKey)
    return self:CompareCharacters(firstKey, secondKey)
end

function MC.Systems.CharacterComparison:CompareCurrentCharacterWithAccount()
    local tracker = MC.Systems and MC.Systems.CharacterTracker
    if not tracker then
        return nil
    end

    local currentKey = tracker:GetCurrentCharacterKey()
    local db = MC:GetSavedDB()

    local currentCharacter = db.characters and db.characters[currentKey]
    local accountCharacter = db.account and db.account.characters and db.account.characters[currentKey]

    if not currentCharacter and not accountCharacter then
        return nil
    end

    return self:CompareCharacters(currentCharacter or currentKey, accountCharacter or currentKey)
end
