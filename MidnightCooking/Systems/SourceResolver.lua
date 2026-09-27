local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Systems = MC.Systems or {}
MC.Systems.SourceResolver = MC.Systems.SourceResolver or {}

function MC.Systems.SourceResolver:GetSource(sourceID)
    if not MC.Database or not MC.Database.Sources then
        return nil
    end

    return MC.Database.Sources[sourceID]
end

local function normalizeSourceEntry(sourceID, recipe)
    local source = MC.Database and MC.Database.Sources and MC.Database.Sources[sourceID]
    if not source then
        return nil
    end

    return {
        sourceID = sourceID,
        type = source.type,
        name = source.name,
        location = source.location,
        requirements = source.requirements or {},
        recipe = recipe,
    }
end

function MC.Systems.SourceResolver:GetRecipesForSource(sourceID)
    local recipes = {}
    if not MC.Database or not MC.Database.Recipes then
        return recipes
    end

    for recipeID, recipe in pairs(MC.Database.Recipes) do
        if type(recipe.sources) == "table" then
            for _, candidate in ipairs(recipe.sources) do
                if candidate == sourceID then
                    recipes[recipeID] = recipe
                    break
                end
            end
        end
    end

    return recipes
end

function MC.Systems.SourceResolver:GetRecipeSources(recipeID, recipeDB)
    recipeDB = recipeDB or (MC.Database and MC.Database.Recipes) or {}
    local recipe = recipeDB[recipeID]
    if not recipe then
        return {}
    end

    local sources = {}
    for _, sourceID in ipairs(recipe.sources or {}) do
        local sourceData = normalizeSourceEntry(sourceID, recipe)
        if sourceData then
            table.insert(sources, sourceData)
        end
    end

    return sources
end

function MC.Systems.SourceResolver:GetSourcesByMap(recipeID, recipeDB)
    local byMap = {}
    local sources = self:GetRecipeSources(recipeID, recipeDB)

    for _, sourceEntry in ipairs(sources) do
        local location = sourceEntry.location
        if location and location.mapID then
            local key = tostring(location.mapID)
            byMap[key] = byMap[key] or {
                mapID = location.mapID,
                sources = {},
                count = 0,
            }

            byMap[key].sources[sourceEntry.sourceID] = sourceEntry
            byMap[key].count = byMap[key].count + 1
        end
    end

    return byMap
end

function MC.Systems.SourceResolver:GetSourceIndex()
    local index = {}

    if not MC.Database or not MC.Database.Recipes then
        return index
    end

    for recipeID, recipe in pairs(MC.Database.Recipes) do
        if type(recipe.sources) == "table" then
            for _, sourceID in ipairs(recipe.sources) do
                index[sourceID] = index[sourceID] or {
                    sourceID = sourceID,
                    recipes = {},
                    count = 0,
                }

                index[sourceID].recipes[recipeID] = recipe
                index[sourceID].count = index[sourceID].count + 1
            end
        end
    end

    return index
end

function MC.Systems.SourceResolver:GetMissingRecipeSources(recipeID, recipeDB)
    recipeDB = recipeDB or (MC.Database and MC.Database.Recipes) or {}
    local recipe = recipeDB[recipeID]
    if not recipe then
        return {}
    end

    local missingSources = {}
    for _, sourceID in ipairs(recipe.sources or {}) do
        local source = self:GetSource(sourceID)
        if source and source.type then
            table.insert(missingSources, {
                sourceID = sourceID,
                type = source.type,
                name = source.name,
                location = source.location,
            })
        end
    end

    return missingSources
end
