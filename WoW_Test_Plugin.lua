local addonName, addon = ...

addon.name = addonName

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, loadedAddonName)
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        print("|cff33ff99WoW Test Plugin|r loaded.")
    elseif event == "PLAYER_LOGIN" then
        frame:UnregisterEvent("PLAYER_LOGIN")
    end
end)

SLASH_WOWTESTPLUGIN1 = "/wptest"
---@diagnostic disable-next-line: undefined-global
SlashCmdList.WOWTESTPLUGIN = function()
    print("|cff33ff99WoW Test Plugin|r is running.")
end