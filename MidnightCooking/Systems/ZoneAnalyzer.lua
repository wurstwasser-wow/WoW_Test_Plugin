local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Systems = MC.Systems or {}
MC.Systems.ZoneAnalyzer = MC.Systems.ZoneAnalyzer or {}

local function getStatus(recipeID, recipe, characterRecipes)
    characterRecipes = characterRecipes or {}
    if characterRecipes[recipeID] == true then
        return MC.Constants.RECIPE_STATUS.LEARNED
    end

    if recipe and recipe.playerState and recipe.playerState.status then
        return recipe.playerState.status
    end

    if recipe and recipe.playerState and recipe.playerState.learned == true then
        return MC.Constants.RECIPE_STATUS.LEARNED
    end

    return MC.Constants.RECIPE_STATUS.UNKNOWN
end

local function getMapID(recipe)
    if recipe and recipe.location and recipe.location.mapID then
        return recipe.location.mapID
    end

    if type(recipe and recipe.sources) == "table" then
        for _, sourceID in ipairs(recipe.sources) do
            local source = MC.Database and MC.Database.Sources and MC.Database.Sources[sourceID]
            if source and source.location and source.location.mapID then
                return source.location.mapID
            end
        end
    end

    return nil
end

local function ensureMapStat(stats, mapID)
    local key = tostring(mapID)
    if not stats[key] then
        stats[key] = {
            mapID = mapID,
            total = 0,
            learned = 0,
            missing = 0,
            unknown = 0,
            unavailable = 0,
            recipeIDs = {},
            sources = {},
        }
    end

    return stats[key]
end

local function normalizeResultMap(stats)
    local result = {}
    for _, stat in pairs(stats) do
        table.insert(result, stat)
    end

    table.sort(result, function(a, b)
        if (a.missing or 0) ~= (b.missing or 0) then
            return (a.missing or 0) > (b.missing or 0)
        end

        if (a.total or 0) ~= (b.total or 0) then
            return (a.total or 0) > (b.total or 0)
        end

        return (a.mapID or 0) < (b.mapID or 0)
    end)

    return result
end

function MC.Systems.ZoneAnalyzer:GetZoneStats(recipeDB, characterRecipes)
    if MC.Systems and MC.Systems.CompletionEngine and MC.Systems.CompletionEngine.Compute then
        local result = MC.Systems.CompletionEngine:Compute(recipeDB, characterRecipes)
        if result and result.zoneStats then
            return result.zoneStats
        end
    end

    local stats = {}
    recipeDB = recipeDB or (MC.Database and MC.Database.Recipes) or {}
    characterRecipes = characterRecipes or {}

    for recipeID, recipe in pairs(recipeDB) do
        local mapID = getMapID(recipe)
        if mapID then
            local zone = ensureMapStat(stats, mapID)
            zone.total = zone.total + 1
            zone.recipeIDs[tostring(recipeID)] = true

            local status = getStatus(recipeID, recipe, characterRecipes)
            if status == MC.Constants.RECIPE_STATUS.LEARNED then
                zone.learned = zone.learned + 1
            elseif status == MC.Constants.RECIPE_STATUS.MISSING then
                zone.missing = zone.missing + 1
            elseif status == MC.Constants.RECIPE_STATUS.UNAVAILABLE then
                zone.unavailable = zone.unavailable + 1
            else
                zone.unknown = zone.unknown + 1
            end

            if type(recipe.sources) == "table" then
                for _, sourceID in ipairs(recipe.sources) do
                    zone.sources[sourceID] = true
                end
            end
        end
    end

    return stats
end

function MC.Systems.ZoneAnalyzer:GetMapStats(recipeDB, characterRecipes)
    return self:GetZoneStats(recipeDB, characterRecipes)
end

function MC.Systems.ZoneAnalyzer:GetHotspots(recipeDB, characterRecipes)
    local stats = self:GetZoneStats(recipeDB, characterRecipes)
    local hotspots = {}

    for _, stat in pairs(stats) do
        local expansion = (stat.missing or 0) + (stat.unknown or 0)
        local coverage = 0
        if (stat.total or 0) > 0 then
            coverage = ((stat.learned or 0) / stat.total) * 100
        end

        table.insert(hotspots, {
            mapID = stat.mapID,
            total = stat.total or 0,
            learned = stat.learned or 0,
            missing = stat.missing or 0,
            unknown = stat.unknown or 0,
            unavailable = stat.unavailable or 0,
            expansion = expansion,
            coverage = coverage,
            recipeIDs = stat.recipeIDs or {},
            sourceCount = 0,
        })
    end

    table.sort(hotspots, function(a, b)
        if (a.missing or 0) ~= (b.missing or 0) then
            return (a.missing or 0) > (b.missing or 0)
        end

        if (a.coverage or 0) ~= (b.coverage or 0) then
            return (a.coverage or 0) < (b.coverage or 0)
        end

        return (a.mapID or 0) < (b.mapID or 0)
    end)

    return hotspots
end

function MC.Systems.ZoneAnalyzer:GetSourceCoverage(recipeDB, characterRecipes)
    local coverage = {}
    recipeDB = recipeDB or (MC.Database and MC.Database.Recipes) or {}
    characterRecipes = characterRecipes or {}

    for recipeID, recipe in pairs(recipeDB) do
        if type(recipe.sources) == "table" then
            for _, sourceID in ipairs(recipe.sources) do
                if not coverage[sourceID] then
                    coverage[sourceID] = {
                        sourceID = sourceID,
                        total = 0,
                        learned = 0,
                        missing = 0,
                        unknown = 0,
                        unavailable = 0,
                        recipeIDs = {},
                    }
                end

                local item = coverage[sourceID]
                item.total = item.total + 1
                item.recipeIDs[tostring(recipeID)] = true

                local status = getStatus(recipeID, recipe, characterRecipes)
                if status == MC.Constants.RECIPE_STATUS.LEARNED then
                    item.learned = item.learned + 1
                elseif status == MC.Constants.RECIPE_STATUS.MISSING then
                    item.missing = item.missing + 1
                elseif status == MC.Constants.RECIPE_STATUS.UNAVAILABLE then
                    item.unavailable = item.unavailable + 1
                else
                    item.unknown = item.unknown + 1
                end
            end
        end
    end

    local result = {}
    for _, source in pairs(coverage) do
        table.insert(result, source)
    end

    table.sort(result, function(a, b)
        if (a.missing or 0) ~= (b.missing or 0) then
            return (a.missing or 0) > (b.missing or 0)
        end

        return (a.total or 0) > (b.total or 0)
    end)

    return result
end
