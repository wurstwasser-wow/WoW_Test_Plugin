local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.UI = MC.UI or {}
MC.UI.Dashboard = MC.UI.Dashboard or {}

function MC.UI.Dashboard:Create(parent)
    if not parent then
        return nil
    end

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(280, 180)
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
    title:SetText("Midnight Cooking")

    local summary = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summary:SetPoint("TOPLEFT", 12, -40)
    summary:SetText("Progress: 0%")
    frame.summaryText = summary

    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    status:SetPoint("TOPLEFT", 12, -60)
    status:SetText("Learned: 0")
    frame.statusText = status

    local quality = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    quality:SetPoint("TOPLEFT", 12, -80)
    quality:SetText("Quality: UNKNOWN")
    frame.qualityText = quality

    return frame
end

function MC.UI.Dashboard:Refresh(frame, summary)
    if not frame then
        return
    end

    summary = summary or { learned = 0, total = 0, percentage = 0, qualityLevel = "UNKNOWN" }
    local percentageText = string.format("Progress: %.2f%%", summary.percentage or 0)
    local learnedText = string.format("Learned: %d / %d", summary.learned or 0, summary.total or 0)
    local qualityLevel = summary.qualityLevel or summary.level or "UNKNOWN"
    local qualityText = string.format("Quality: %s", qualityLevel)

    if frame.summaryText then
        frame.summaryText:SetText(percentageText)
    end

    if frame.statusText then
        frame.statusText:SetText(learnedText)
    end

    if frame.qualityText then
        frame.qualityText:SetText(qualityText)
    end
end
