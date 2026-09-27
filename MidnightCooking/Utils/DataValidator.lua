local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Utils = MC.Utils or {}
MC.Utils.DataValidator = MC.Utils.DataValidator or {}

function MC.Utils.DataValidator:IsValidStatus(status)
    local valid = {
        [MC.Constants.RECIPE_STATUS.LEARNED] = true,
        [MC.Constants.RECIPE_STATUS.MISSING] = true,
        [MC.Constants.RECIPE_STATUS.UNKNOWN] = true,
        [MC.Constants.RECIPE_STATUS.UNAVAILABLE] = true,
    }

    return valid[status] == true
end

function MC.Utils.DataValidator:ValidateRecipe(recipe)
    if not recipe then
        return false, "Recipe missing"
    end

    if not recipe.recipeID then
        return false, "Recipe missing recipeID"
    end

    if not recipe.name or recipe.name == "" then
        return false, "Recipe missing name"
    end

    if recipe.playerState and recipe.playerState.status and not self:IsValidStatus(recipe.playerState.status) then
        return false, "Invalid recipe status"
    end

    return true, "ok"
end

function MC.Utils.DataValidator:ValidateSource(source)
    if not source then
        return false, "Source missing"
    end

    if not source.sourceID then
        return false, "Source missing sourceID"
    end

    if not source.type then
        return false, "Source missing type"
    end

    if not MC.Constants.SOURCE_TYPES[source.type] then
        return false, "Unknown source type"
    end

    return true, "ok"
end

function MC.Utils.DataValidator:ValidateLocation(location)
    if not location then
        return true, "ok"
    end

    if not location.mapID then
        return false, "Location missing mapID"
    end

    if type(location.x) ~= "number" or type(location.y) ~= "number" then
        return false, "Location coordinates invalid"
    end

    if location.x < 0 or location.x > 1 or location.y < 0 or location.y > 1 then
        return false, "Location coordinates out of range"
    end

    return true, "ok"
end

function MC.Utils.DataValidator:ValidateDatabase()
    local issues = {}

    if not MC.Database or not MC.Database.Recipes then
        table.insert(issues, "Recipes database missing")
        return false, issues
    end

    for recipeID, recipe in pairs(MC.Database.Recipes) do
        local ok, message = self:ValidateRecipe(recipe)
        if not ok then
            table.insert(issues, tostring(recipeID) .. ": " .. message)
        end
    end

    if MC.Database.Sources then
        for sourceID, source in pairs(MC.Database.Sources) do
            local ok, message = self:ValidateSource(source)
            if not ok then
                table.insert(issues, tostring(sourceID) .. ": " .. message)
            end
        end
    end

    if MC.Database.Locations then
        for locationID, location in pairs(MC.Database.Locations) do
            local ok, message = self:ValidateLocation(location)
            if not ok then
                table.insert(issues, tostring(locationID) .. ": " .. message)
            end
        end
    end

    return #issues == 0, issues
end

function MC.Utils.DataValidator:LogIssues(issues)
    if not issues or #issues == 0 then
        MC:Log("data validation passed")
        return
    end

    for _, issue in ipairs(issues) do
        MC:Log("data validation issue: " .. tostring(issue))
    end
end
