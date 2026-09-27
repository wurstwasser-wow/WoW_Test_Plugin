local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Database = MC.Database or {}
MC.Database.Locations = MC.Database.Locations or {}

MC.Database.Locations = {
    ["location:1:0.45:0.55"] = {
        mapID = 1,
        x = 0.45,
        y = 0.55,
        zoneName = "Sample Zone",
        subZoneName = "Sample Subzone",
        verified = false,
    },
}
