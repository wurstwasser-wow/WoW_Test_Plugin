local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Core.Bootstrap = MC.Core.Bootstrap or {}

local eventFrame = CreateFrame("Frame")
MC.eventFrame = eventFrame

local function initializeAddon()
    if MC.initialized then
        return
    end

    MC:InitializeSavedVariables()

    if MC.Systems and MC.Systems.CharacterTracker then
        MC.Systems.CharacterTracker:Initialize()
    end

    if MC.Systems and MC.Systems.RecipeScanner then
        MC.Systems.RecipeScanner:ScanCharacter()
    end

    if MC.Utils and MC.Utils.DataValidator then
        local ok, issues = MC.Utils.DataValidator:ValidateDatabase()
        if not ok then
            MC.Utils.DataValidator:LogIssues(issues)
        else
            MC:Log("data validation passed")
        end
    end

    if MC.UI and MC.UI.MainWindow and MC.UI.MainWindow.Create then
        local window = MC.UI.MainWindow:Create(UIParent)
        if window then
            window:Hide()
        end
    end

    MC.initialized = true
    MC:Log("initialized. Architecture scaffold is active.")
end

function MC:Initialize()
    initializeAddon()
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, eventName, loadedAddonName)
    if eventName == "ADDON_LOADED" and loadedAddonName == MC.name then
        MC:InitializeSavedVariables()
    elseif eventName == "PLAYER_LOGIN" then
        initializeAddon()
    end
end)
