local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.API = MC.API or {}
MC.API.Recipe = MC.API.Recipe or {}

local function callTradeSkill(methodName, recipeID)
    if type(C_TradeSkillUI) ~= "table" then
        return nil
    end

    local fn = C_TradeSkillUI[methodName]
    if type(fn) ~= "function" then
        return nil
    end

    if recipeID ~= nil then
        return fn(C_TradeSkillUI, recipeID)
    end

    return fn(C_TradeSkillUI)
end

function MC.API.Recipe:GetAllRecipeIDs()
    local result = callTradeSkill("GetAllRecipeIDs")
    if type(result) == "table" then
        return result
    end
    return {}
end

function MC.API.Recipe:GetRecipeInfo(recipeID)
    return callTradeSkill("GetRecipeInfo", recipeID) or {}
end

function MC.API.Recipe:GetSchematic(recipeID)
    local method = "GetRecipeSchematic"

    if type(C_TradeSkillUI) == "table" and type(C_TradeSkillUI[method]) == "function" then
        return C_TradeSkillUI[method](C_TradeSkillUI, recipeID) or {}
    end

    return self:GetRecipeInfo(recipeID)
end

function MC.API.Recipe:GetRequirements(recipeID)
    local schematic = self:GetSchematic(recipeID)
    if type(schematic) == "table" and type(schematic.reagents) == "table" then
        return schematic.reagents
    end

    local info = self:GetRecipeInfo(recipeID)
    if type(info) == "table" and type(info.reagents) == "table" then
        return info.reagents
    end

    return {}
end

function MC.API.Recipe:GetSourceText(recipeID)
    local info = self:GetRecipeInfo(recipeID)
    if type(info) == "table" and type(info.sourceText) == "string" then
        return info.sourceText
    end
    return ""
end

function MC.API.Recipe:GetRecipeState(recipeID)
    local info = self:GetRecipeInfo(recipeID)
    if type(info) == "table" then
        if info.learned == true then
            return MC.Constants.RECIPE_STATUS.LEARNED
        end

        if info.learned == false then
            return MC.Constants.RECIPE_STATUS.UNKNOWN
        end
    end

    return MC.Constants.RECIPE_STATUS.UNKNOWN
end
