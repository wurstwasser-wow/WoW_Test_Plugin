local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Systems = MC.Systems or {}
MC.Systems.MaterialPlanner = MC.Systems.MaterialPlanner or {}

function MC.Systems.MaterialPlanner:BuildShoppingList(selectedRecipes, ownedItems)
    local shoppingList = {}
    local owned = ownedItems or {}

    for _, recipeID in ipairs(selectedRecipes or {}) do
        local recipe = MC.Database and MC.Database.Recipes and MC.Database.Recipes[recipeID]
        if recipe and type(recipe.reagents) == "table" then
            for _, reagent in ipairs(recipe.reagents) do
                local itemID = reagent.itemID
                if itemID then
                    shoppingList[itemID] = shoppingList[itemID] or {
                        required = 0,
                        owned = 0,
                        missing = 0,
                    }

                    shoppingList[itemID].required = shoppingList[itemID].required + (reagent.quantity or 0)
                    shoppingList[itemID].owned = owned[itemID] or 0
                    shoppingList[itemID].missing = math.max(0, shoppingList[itemID].required - shoppingList[itemID].owned)
                end
            end
        end
    end

    return shoppingList
end
