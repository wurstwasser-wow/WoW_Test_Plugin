local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Constants = MC.Constants or {}
MC.Constants.RECIPE_STATUS = {
    LEARNED = "LEARNED",
    MISSING = "MISSING",
    UNKNOWN = "UNKNOWN",
    UNAVAILABLE = "UNAVAILABLE",
}

MC.Constants.SOURCE_TYPES = {
    VENDOR = "VENDOR",
    QUEST = "QUEST",
    DROP = "DROP",
    TREASURE = "TREASURE",
    REPUTATION = "REPUTATION",
    TRAINER = "TRAINER",
    ACHIEVEMENT = "ACHIEVEMENT",
    EVENT = "EVENT",
    WORLD_QUEST = "WORLD_QUEST",
    RARE = "RARE",
    DUNGEON = "DUNGEON",
    RAID = "RAID",
    DELVE = "DELVE",
    WORLD_BOSS = "WORLD_BOSS",
    DISCOVERY = "DISCOVERY",
    PROFESSION = "PROFESSION",
    SPECIAL = "SPECIAL",
    OTHER = "OTHER",
}
