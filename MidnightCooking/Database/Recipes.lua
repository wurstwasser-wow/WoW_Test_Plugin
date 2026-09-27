local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Database = MC.Database or {}
MC.Database.Recipes = MC.Database.Recipes or {}

-- Sample placeholder records only. These IDs are intentionally not real WoW recipe IDs.
MC.Database.Recipes = {
    [900001] = {
        recipeID = 900001,
        spellID = 910001,
        skillLineAbilityID = 920001,
        name = "Sample Midnight Stew",
        profession = {
            skillLineID = 185,
            name = "Cooking",
        },
        expansion = "Midnight",
        category = {
            id = nil,
            name = "Sample Category",
        },
        playerState = {
            learned = false,
            status = MC.Constants.RECIPE_STATUS.UNKNOWN,
        },
        result = {
            itemID = 1000001,
            quantityMin = 1,
            quantityMax = 1,
        },
        reagents = {
            { itemID = 1001001, quantity = 2, required = true },
            { itemID = 1001002, quantity = 1, required = true },
        },
        requirements = {},
        sources = {
            "vendor:sample-001",
            "quest:sample-001",
        },
        dataQuality = {
            verified = false,
            sourceVerified = false,
            locationVerified = false,
        },
    },
    [900002] = {
        recipeID = 900002,
        spellID = 910002,
        skillLineAbilityID = 920002,
        name = "Sample Emberflame Pie",
        profession = {
            skillLineID = 185,
            name = "Cooking",
        },
        expansion = "Midnight",
        category = {
            id = nil,
            name = "Sample Category",
        },
        playerState = {
            learned = false,
            status = MC.Constants.RECIPE_STATUS.UNKNOWN,
        },
        result = {
            itemID = 1000002,
            quantityMin = 1,
            quantityMax = 1,
        },
        reagents = {
            { itemID = 1001003, quantity = 3, required = true },
        },
        requirements = {},
        sources = {
            "drop:sample-001",
        },
        dataQuality = {
            verified = false,
            sourceVerified = false,
            locationVerified = false,
        },
    },
}
