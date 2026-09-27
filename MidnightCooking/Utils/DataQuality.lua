local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Utils = MC.Utils or {}
MC.Utils.DataQuality = MC.Utils.DataQuality or {}

MC.Utils.DataQuality.SCHEMA_VERSION = 1
MC.Utils.DataQuality.QUALITY_LEVELS = {
    UNKNOWN = 0,
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3,
    VERIFIED = 4,
}

local function getQualityLevelByScore(score)
    if score >= 90 then
        return "VERIFIED"
    elseif score >= 70 then
        return "HIGH"
    elseif score >= 45 then
        return "MEDIUM"
    elseif score >= 20 then
        return "LOW"
    end

    return "UNKNOWN"
end

local function safeNumber(value, fallback)
    if type(value) == "number" then
        return value
    end

    return fallback
end

function MC.Utils.DataQuality:GetSchemaVersion()
    local db = MC:GetSavedDB()
    db.meta = db.meta or {}
    return safeNumber(db.meta.schemaVersion, 0)
end

function MC.Utils.DataQuality:EnsureSchemaVersion()
    local db = MC:GetSavedDB()
    db.meta = db.meta or {}

    if safeNumber(db.meta.schemaVersion, 0) < self.SCHEMA_VERSION then
        db.meta.schemaVersion = self.SCHEMA_VERSION
        db.meta.lastSchemaMigration = date("%Y-%m-%d %H:%M:%S")
    end

    return db.meta.schemaVersion
end

function MC.Utils.DataQuality:GetVersionInfo()
    return {
        addonVersion = MC.version or "0.1.0",
        clientVersion = MC.clientVersion or "12.1.0",
        schemaVersion = self:GetSchemaVersion(),
        dataQuality = self:GetDatabaseQualitySummary(),
    }
end

function MC.Utils.DataQuality:NormalizeRecipeData(recipe)
    if not recipe then
        return nil
    end

    recipe.dataQuality = recipe.dataQuality or {}
    recipe.dataQuality.verified = recipe.dataQuality.verified == true
    recipe.dataQuality.sourceVerified = recipe.dataQuality.sourceVerified == true
    recipe.dataQuality.locationVerified = recipe.dataQuality.locationVerified == true

    local quality = self:EvaluateRecipeQuality(recipe)
    recipe.dataQuality.score = quality.score
    recipe.dataQuality.level = quality.level
    recipe.dataQuality.summary = quality.summary

    return recipe
end

function MC.Utils.DataQuality:EvaluateRecipeQuality(recipe)
    local score = 0
    local issues = {}

    if recipe and recipe.recipeID then
        score = score + 15
    else
        table.insert(issues, "missing recipeID")
    end

    if recipe and recipe.name and recipe.name ~= "" then
        score = score + 15
    else
        table.insert(issues, "missing name")
    end

    if recipe and recipe.result and recipe.result.itemID then
        score = score + 15
    else
        table.insert(issues, "missing result itemID")
    end

    if type(recipe and recipe.sources) == "table" and #recipe.sources > 0 then
        score = score + 20
    else
        table.insert(issues, "missing source list")
    end

    if type(recipe and recipe.reagents) == "table" and #recipe.reagents > 0 then
        score = score + 15
    else
        table.insert(issues, "missing reagents")
    end

    if recipe and recipe.dataQuality then
        if recipe.dataQuality.verified then
            score = score + 20
        end

        if recipe.dataQuality.sourceVerified then
            score = score + 10
        end

        if recipe.dataQuality.locationVerified then
            score = score + 10
        end
    end

    local level = getQualityLevelByScore(score)

    return {
        score = math.max(0, math.min(100, score)),
        level = level,
        summary = table.concat(issues, ", ")
    }
end

function MC.Utils.DataQuality:EnsureDatabaseQuality(recipeDB)
    recipeDB = recipeDB or (MC.Database and MC.Database.Recipes) or {}

    for recipeID, recipe in pairs(recipeDB) do
        recipeDB[recipeID] = self:NormalizeRecipeData(recipe)
    end

    return recipeDB
end

function MC.Utils.DataQuality:GetDatabaseQualitySummary(recipeDB)
    recipeDB = recipeDB or (MC.Database and MC.Database.Recipes) or {}

    local total = 0
    local totalScore = 0
    local issues = {}
    local levels = {
        UNKNOWN = 0,
        LOW = 0,
        MEDIUM = 0,
        HIGH = 0,
        VERIFIED = 0,
    }

    for _, recipe in pairs(recipeDB) do
        if recipe then
            total = total + 1
            local quality = self:EvaluateRecipeQuality(recipe)
            totalScore = totalScore + quality.score
            levels[quality.level] = (levels[quality.level] or 0) + 1

            if quality.level ~= "VERIFIED" and quality.summary ~= "" then
                table.insert(issues, tostring(recipe.recipeID or "unknown") .. ": " .. quality.summary)
            end
        end
    end

    local average = 0
    if total > 0 then
        average = totalScore / total
    end

    return {
        total = total,
        average = average,
        level = getQualityLevelByScore(average),
        levels = levels,
        issues = issues,
    }
end

function MC.Utils.DataQuality:LogSummary()
    local summary = self:GetDatabaseQualitySummary()
    MC:Log(string.format("data quality: %s (%.1f/100)", summary.level, summary.average or 0))

    if summary.issues and #summary.issues > 0 then
        for _, issue in ipairs(summary.issues) do
            MC:Log("data quality issue: " .. tostring(issue))
        end
    end
end
