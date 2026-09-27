local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Systems = MC.Systems or {}
MC.Systems.SearchEngine = MC.Systems.SearchEngine or {}

function MC.Systems.SearchEngine:IndexRecipe(recipe)
    if not recipe then
        return
    end

    local index = MC.Systems.SearchEngine._index or {}
    MC.Systems.SearchEngine._index = index

    local tokens = {
        string.lower(recipe.name or ""),
        string.lower((recipe.result and recipe.result.itemID) and tostring(recipe.result.itemID) or ""),
    }

    for _, token in ipairs(tokens) do
        if token ~= "" then
            index[token] = index[token] or {}
            index[token][recipe.recipeID] = recipe
        end
    end
end

function MC.Systems.SearchEngine:IndexDatabase(recipeDB)
    recipeDB = recipeDB or {}
    self._index = self._index or {}

    for _, recipe in pairs(recipeDB) do
        self:IndexRecipe(recipe)
    end
end

function MC.Systems.SearchEngine:Search(term, recipeDB)
    local query = string.lower(tostring(term or ""))
    if query == "" then
        return {}
    end

    recipeDB = recipeDB or (MC.Database and MC.Database.Recipes) or {}
    local matches = {}

    for _, recipe in pairs(recipeDB) do
        local name = string.lower(recipe.name or "")
        local resultItem = tostring(recipe.result and recipe.result.itemID or "")
        if string.find(name, query, 1, true) or string.find(resultItem, query, 1, true) then
            matches[recipe.recipeID] = recipe
        end
    end

    return matches
end
