local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.UI = MC.UI or {}
MC.UI.MainWindow = MC.UI.MainWindow or {}

function MC.UI.MainWindow:Create(parent)
    local frame = CreateFrame("Frame", "MidnightCookingMainWindow", parent or UIParent)
    frame:SetSize(360, 420)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 12, -12)
    frame.title:SetText("Midnight Cooking Completionist")

    frame.dashboard = MC.UI.Dashboard:Create(frame)
    frame.dashboard:SetPoint("TOPLEFT", 12, -40)
    frame.dashboard:SetPoint("TOPRIGHT", -12, -40)

    frame.routeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.routeText:SetPoint("TOPLEFT", 12, -170)
    frame.routeText:SetText("Route: waiting for scan")

    frame.recipeList = MC.UI.RecipeList:Create(frame)
    frame.recipeList:SetPoint("TOPLEFT", 12, -220)
    frame.recipeList:SetPoint("BOTTOMRIGHT", -12, 12)

    MC.UI.MainWindow.window = frame
    frame:Hide()
    return frame
end

function MC.UI.MainWindow:Refresh(frame, summary, recipeDB)
    if not frame then
        return
    end

    MC.UI.Dashboard:Refresh(frame.dashboard, summary)

    local routeText = "Route: no data"
    local recipeSet = {}
    if summary and type(summary) == "table" then
        for recipeID in pairs(summary.missingRecipes or {}) do
            recipeSet[recipeID] = true
        end
    end

    if MC.Systems and MC.Systems.ZoneAnalyzer then
        local hotspots = MC.Systems.ZoneAnalyzer:GetHotspots(recipeDB, MC.Systems.CharacterTracker and MC.Systems.CharacterTracker:GetEffectiveRecipes() or {})
        if hotspots and #hotspots > 0 then
            routeText = string.format("Route: %d hotspot(s) across %d map(s)", #hotspots, #hotspots)
        end
    end

    if MC.Systems and MC.Systems.RoutePlanner and type(recipeDB) == "table" then
        local missingRecipes = {}
        for recipeID, recipe in pairs(recipeDB) do
            if recipe and recipe.playerState and recipe.playerState.status == MC.Constants.RECIPE_STATUS.MISSING then
                missingRecipes[recipeID] = recipe
            end
        end

        local plan = MC.Systems.RoutePlanner:BuildSuggestedOrder(missingRecipes)
        if plan and #plan > 0 then
            routeText = string.format("Route: %d target(s) in %d location(s)", #plan, #plan)
        end
    end

    if frame.routeText then
        frame.routeText:SetText(routeText)
    end

    MC.UI.RecipeList:Refresh(frame.recipeList, recipeDB)
end

function MC.UI.MainWindow:Open()
    if not self.window then
        self.window = self:Create(UIParent)
    end

    self.window:Show()

    if MC.Systems and MC.Systems.RecipeScanner then
        MC.Systems.RecipeScanner:RefreshUI()
    end
end
