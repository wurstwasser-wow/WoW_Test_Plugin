local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.UI = MC.UI or {}
MC.UI.RecipeList = MC.UI.RecipeList or {}

function MC.UI.RecipeList:Create(parent)
    if not parent then
        return nil
    end

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(280, 260)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText("Recipes")

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame)
    scrollFrame:SetPoint("TOPLEFT", 12, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.scrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(240, 200)
    scrollFrame:SetScrollChild(content)
    frame.content = content
    frame.rows = {}

    return frame
end

function MC.UI.RecipeList:Refresh(frame, recipeDB)
    if not frame or not frame.content then
        return
    end

    recipeDB = recipeDB or {}

    for _, row in ipairs(frame.rows or {}) do
        row:Hide()
        row:SetParent(nil)
    end
    frame.rows = {}

    local sorted = {}
    for _, recipe in pairs(recipeDB) do
        table.insert(sorted, recipe)
    end
    table.sort(sorted, function(a, b)
        return (a.name or "") < (b.name or "")
    end)

    local offsetY = 0
    for _, recipe in ipairs(sorted) do
        local row = CreateFrame("Button", nil, frame.content)
        row:SetSize(220, 18)
        row:SetPoint("TOPLEFT", 0, -offsetY)
        row:SetNormalFontObject("GameFontNormal")
        row:SetText(recipe.name or "Unknown Recipe")
        row:SetHighlightTexture("Interface\\Buttons\\UI-ListHighlight")
        row:RegisterForClicks("LeftButtonUp")
        row:SetScript("OnClick", function()
            if recipe and recipe.recipeID then
                MC:Log("Selected recipe: " .. tostring(recipe.recipeID))
            end
        end)

        table.insert(frame.rows, row)
        offsetY = offsetY + 20
    end

    frame.content:SetHeight(math.max(200, offsetY + 10))
end
