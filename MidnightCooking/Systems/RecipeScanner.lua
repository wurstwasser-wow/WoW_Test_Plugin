local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Systems = MC.Systems or {}
MC.Systems.RecipeScanner = MC.Systems.RecipeScanner or {}

function MC.Systems.RecipeScanner:GetLearnedRecipes()
    local learned = {}

    if type(MC.API) == "table" and type(MC.API.Recipe) == "table" and type(MC.API.Recipe.GetAllRecipeIDs) == "function" then
        local ids = MC.API.Recipe:GetAllRecipeIDs()
        if type(ids) == "table" then
            for _, recipeID in ipairs(ids) do
                learned[recipeID] = true
            end
        end
    end

    return learned
end

function MC.Systems.RecipeScanner:GetRecipeRuntimeState(recipeID)
    local learnedMap = self:GetLearnedRecipes()
    local state = {
        recipeID = recipeID,
        learned = learnedMap[recipeID] == true,
        lastUpdated = time(),
        sourceText = "",
    }

    if type(MC.API) == "table" and type(MC.API.Recipe) == "table" and type(MC.API.Recipe.GetRecipeState) == "function" then
        state.status = MC.API.Recipe:GetRecipeState(recipeID)
    else
        state.status = MC.Constants.RECIPE_STATUS.UNKNOWN
    end

    return state
end

function MC.Systems.RecipeScanner:ScanCharacter()
    local learnedRecipes = self:GetLearnedRecipes()
    local character = MC.Systems.CharacterTracker:GetCurrentCharacter()

    if not character then
        return learnedRecipes
    end

    character.recipes = learnedRecipes
    character.lastScan = time()

    if MC.Systems.CharacterTracker and MC.Systems.CharacterTracker.ScanCurrentCharacter then
        MC.Systems.CharacterTracker:ScanCurrentCharacter()
    end

    return learnedRecipes
end

function MC.Systems.RecipeScanner:RefreshUI()
    if not MC.UI or not MC.UI.MainWindow or not MC.UI.MainWindow.Refresh then
        return
    end

    local recipeDB = MC.Database and MC.Database.Recipes or {}
    local characterRecipes = MC.Systems.CharacterTracker and MC.Systems.CharacterTracker:GetEffectiveRecipes() or {}

    if MC.Systems and MC.Systems.CompletionEngine and MC.Systems.CompletionEngine.Compute then
        local summary = MC.Systems.CompletionEngine:Compute(recipeDB, characterRecipes)
        local window = MC.UI.MainWindow.window

        if window then
            MC.UI.MainWindow:Refresh(window, summary, recipeDB)
        end
    end
end
