local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Database = MC.Database or {}
MC.Database.Sources = MC.Database.Sources or {}

MC.Database.Sources = {
    ["vendor:sample-001"] = {
        sourceID = "vendor:sample-001",
        type = MC.Constants.SOURCE_TYPES.VENDOR,
        name = "Sample Vendor",
        npcID = 990001,
        location = {
            mapID = 1,
            x = 0.45,
            y = 0.55,
        },
        requirements = {},
        verified = false,
    },
    ["quest:sample-001"] = {
        sourceID = "quest:sample-001",
        type = MC.Constants.SOURCE_TYPES.QUEST,
        name = "Sample Quest",
        questID = 990010,
        requirements = {},
        verified = false,
    },
    ["drop:sample-001"] = {
        sourceID = "drop:sample-001",
        type = MC.Constants.SOURCE_TYPES.DROP,
        name = "Sample Drop Source",
        requirements = {},
        verified = false,
    },
}
