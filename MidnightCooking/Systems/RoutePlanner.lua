local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Systems = MC.Systems or {}
MC.Systems.RoutePlanner = MC.Systems.RoutePlanner or {}

local function getLocationKey(location)
    if not location then
        return nil
    end

    local mapID = tostring(location.mapID or "")
    local x = tostring(location.x or "")
    local y = tostring(location.y or "")

    return mapID .. ":" .. x .. ":" .. y
end

function MC.Systems.RoutePlanner:BuildSuggestedOrder(missingRecipes)
    missingRecipes = missingRecipes or {}

    local routes = {}
    local seen = {}

    for recipeID in pairs(missingRecipes) do
        local recipe = MC.Database and MC.Database.Recipes and MC.Database.Recipes[recipeID]
        if recipe then
            local sources = recipe.sources or {}
            for _, sourceID in ipairs(sources) do
                local source = MC.Database and MC.Database.Sources and MC.Database.Sources[sourceID]
                if source then
                    local location = source.location
                    local key = getLocationKey(location)
                    if key then
                        if not seen[key] then
                            seen[key] = {
                                mapID = location.mapID,
                                x = location.x,
                                y = location.y,
                                sources = {},
                                recipes = {},
                            }
                            table.insert(routes, seen[key])
                        end

                        local bucket = seen[key]
                        bucket.sources[sourceID] = true
                        bucket.recipes[recipeID] = recipe
                    end
                end
            end
        end
    end

    table.sort(routes, function(a, b)
        if (a.mapID or 0) ~= (b.mapID or 0) then
            return (a.mapID or 0) < (b.mapID or 0)
        end

        if (a.y or 0) ~= (b.y or 0) then
            return (a.y or 0) < (b.y or 0)
        end

        return (a.x or 0) < (b.x or 0)
    end)

    local ordered = {}
    for _, entry in ipairs(routes) do
        table.insert(ordered, {
            mapID = entry.mapID,
            x = entry.x,
            y = entry.y,
            sources = entry.sources,
            recipes = entry.recipes,
        })
    end

    return ordered
end

function MC.Systems.RoutePlanner:GetCollectionPlan(locationSet)
    locationSet = locationSet or {}
    local plan = {}

    for _, location in ipairs(locationSet) do
        table.insert(plan, {
            mapID = location.mapID,
            x = location.x,
            y = location.y,
            label = string.format("Map %s @ %.3f, %.3f", tostring(location.mapID or 0), location.x or 0, location.y or 0),
        })
    end

    table.sort(plan, function(a, b)
        if (a.mapID or 0) ~= (b.mapID or 0) then
            return (a.mapID or 0) < (b.mapID or 0)
        end
        if (a.y or 0) ~= (b.y or 0) then
            return (a.y or 0) < (b.y or 0)
        end
        return (a.x or 0) < (b.x or 0)
    end)

    return plan
end
