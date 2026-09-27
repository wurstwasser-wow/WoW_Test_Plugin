local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Map = MC.Map or {}
MC.Map.WorldMap = MC.Map.WorldMap or {}

local function normalizeKey(mapID, x, y)
    return string.format("location:%s:%s:%s", tostring(mapID), tostring(x), tostring(y))
end

function MC.Map.WorldMap:BuildMarker(location, sourceID, missingRecipeID)
    if not location or not location.mapID then
        return nil
    end

    local x = tonumber(location.x) or 0
    local y = tonumber(location.y) or 0
    local markerKey = normalizeKey(location.mapID, x, y)

    if not MC.Map._markers then
        MC.Map._markers = {}
    end

    if not MC.Map._markers[markerKey] then
        MC.Map._markers[markerKey] = {
            markerID = markerKey,
            location = {
                mapID = location.mapID,
                x = x,
                y = y,
            },
            sources = {},
            missingRecipes = {},
            count = 0,
        }
    end

    local marker = MC.Map._markers[markerKey]
    if sourceID and not marker.sources[sourceID] then
        marker.sources[sourceID] = true
    end

    if missingRecipeID then
        marker.missingRecipes[missingRecipeID] = true
    end

    marker.count = 0
    for _ in pairs(marker.missingRecipes) do
        marker.count = marker.count + 1
    end

    return marker
end

function MC.Map.WorldMap:BuildMarkersFromHotspots(hotspots)
    hotspots = hotspots or {}
    local markers = {}

    for _, hotspot in ipairs(hotspots) do
        if hotspot and hotspot.mapID then
            local location = {
                mapID = hotspot.mapID,
                x = hotspot.x or 0.5,
                y = hotspot.y or 0.5,
            }

            local marker = self:BuildMarker(location, hotspot.sourceID, hotspot.missingRecipeID)
            if marker then
                markers[marker.markerID] = marker
            end
        end
    end

    return markers
end

function MC.Map.WorldMap:GetMarkers()
    MC.Map._markers = MC.Map._markers or {}
    return MC.Map._markers
end

function MC.Map.WorldMap:GetMarkerSummary()
    local markers = self:GetMarkers()
    local summary = {
        total = 0,
        withMissingRecipes = 0,
        sourceCount = 0,
    }

    for _, marker in pairs(markers) do
        summary.total = summary.total + 1
        if (marker.count or 0) > 0 then
            summary.withMissingRecipes = summary.withMissingRecipes + 1
        end

        summary.sourceCount = summary.sourceCount + (marker.sourceCount or 0)
    end

    return summary
end
