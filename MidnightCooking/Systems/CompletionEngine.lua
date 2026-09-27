local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Systems = MC.Systems or {}
MC.Systems.CompletionEngine = MC.Systems.CompletionEngine or {}

local function normalizeStatus(status)
    if status == MC.Constants.RECIPE_STATUS.LEARNED then
        return MC.Constants.RECIPE_STATUS.LEARNED
    elseif status == MC.Constants.RECIPE_STATUS.MISSING then
        return MC.Constants.RECIPE_STATUS.MISSING
    elseif status == MC.Constants.RECIPE_STATUS.UNAVAILABLE then
        return MC.Constants.RECIPE_STATUS.UNAVAILABLE
    end

    return MC.Constants.RECIPE_STATUS.UNKNOWN
end

local function getRecipeStatus(recipeID, recipe, characterRecipes)
    characterRecipes = characterRecipes or {}

    if characterRecipes[recipeID] == true then
        return MC.Constants.RECIPE_STATUS.LEARNED
    end

    if recipe and recipe.playerState and recipe.playerState.status then
        return normalizeStatus(recipe.playerState.status)
    end

    return MC.Constants.RECIPE_STATUS.UNKNOWN
end

local function ensureZoneStat(zoneStats, mapID)
    if not mapID then
        return nil
    end

    local key = tostring(mapID)
    if not zoneStats[key] then
        zoneStats[key] = {
            mapID = mapID,
            totalRecipes = 0,
            learned = 0,
            missing = 0,
            unknown = 0,
            unavailable = 0,
            locations = 0,
        }
    end

    return zoneStats[key]
end

local function ensureSourceStat(sourceStats, sourceID)
    local key = tostring(sourceID)
    if not sourceStats[key] then
        sourceStats[key] = {
            sourceID = sourceID,
            total = 0,
            learned = 0,
            missing = 0,
            unknown = 0,
            unavailable = 0,
        }
    end

    return sourceStats[key]
end

function MC.Systems.CompletionEngine:Compute(recipeDB, characterRecipes)
    local total = 0
    local learned = 0
    local missing = 0
    local unknown = 0
    local unavailable = 0
    local zoneStats = {}
    local sourceStats = {}

    recipeDB = recipeDB or {}
    characterRecipes = characterRecipes or {}

    for recipeID, recipe in pairs(recipeDB) do
        total = total + 1

        local status = getRecipeStatus(recipeID, recipe, characterRecipes)

        if status == MC.Constants.RECIPE_STATUS.LEARNED then
            learned = learned + 1
        elseif status == MC.Constants.RECIPE_STATUS.MISSING then
            missing = missing + 1
        elseif status == MC.Constants.RECIPE_STATUS.UNKNOWN then
            unknown = unknown + 1
        elseif status == MC.Constants.RECIPE_STATUS.UNAVAILABLE then
            unavailable = unavailable + 1
        else
            unknown = unknown + 1
        end

        local sourceList = recipe and recipe.sources or {}
        for _, sourceID in ipairs(sourceList) do
            local sourceSummary = ensureSourceStat(sourceStats, sourceID)
            sourceSummary.total = sourceSummary.total + 1

            if status == MC.Constants.RECIPE_STATUS.LEARNED then
                sourceSummary.learned = sourceSummary.learned + 1
            elseif status == MC.Constants.RECIPE_STATUS.MISSING then
                sourceSummary.missing = sourceSummary.missing + 1
            elseif status == MC.Constants.RECIPE_STATUS.UNKNOWN then
                sourceSummary.unknown = sourceSummary.unknown + 1
            elseif status == MC.Constants.RECIPE_STATUS.UNAVAILABLE then
                sourceSummary.unavailable = sourceSummary.unavailable + 1
            else
                sourceSummary.unknown = sourceSummary.unknown + 1
            end
        end

        local mapID = nil
        if recipe and type(recipe.location) == "table" and recipe.location.mapID then
            mapID = recipe.location.mapID
        elseif recipe and type(recipe.sources) == "table" then
            for _, sourceID in ipairs(recipe.sources) do
                local source = MC.Database and MC.Database.Sources and MC.Database.Sources[sourceID]
                if source and source.location and source.location.mapID then
                    mapID = source.location.mapID
                    break
                end
            end
        end

        local zoneSummary = ensureZoneStat(zoneStats, mapID)
        if zoneSummary then
            zoneSummary.totalRecipes = zoneSummary.totalRecipes + 1

            if status == MC.Constants.RECIPE_STATUS.LEARNED then
                zoneSummary.learned = zoneSummary.learned + 1
            elseif status == MC.Constants.RECIPE_STATUS.MISSING then
                zoneSummary.missing = zoneSummary.missing + 1
            elseif status == MC.Constants.RECIPE_STATUS.UNKNOWN then
                zoneSummary.unknown = zoneSummary.unknown + 1
            elseif status == MC.Constants.RECIPE_STATUS.UNAVAILABLE then
                zoneSummary.unavailable = zoneSummary.unavailable + 1
            else
                zoneSummary.unknown = zoneSummary.unknown + 1
            end
        end
    end

    local percentage = 0
    if total > 0 then
        percentage = (learned / total) * 100
    end

    return {
        total = total,
        learned = learned,
        missing = missing,
        unknown = unknown,
        unavailable = unavailable,
        percentage = percentage,
        zoneStats = zoneStats,
        sourceStats = sourceStats,
    }
end
