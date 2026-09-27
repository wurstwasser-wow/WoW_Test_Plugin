local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

if not MC.Constants then
    assert(false, "Midnight Cooking Completionist constants were not loaded.")
end

MC:InitializeSavedVariables()
MC:Initialize()
