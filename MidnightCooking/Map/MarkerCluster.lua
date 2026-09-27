local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Map = MC.Map or {}
MC.Map.MarkerCluster = MC.Map.MarkerCluster or {}

function MC.Map.MarkerCluster:BuildClusters(markers, zoomLevel)
    local clusters = {}
    local threshold = 0.02

    if zoomLevel then
        if zoomLevel >= 3 then
            threshold = 0.015
        elseif zoomLevel >= 2 then
            threshold = 0.02
        else
            threshold = 0.04
        end
    end

    markers = markers or {}

    for _, marker in pairs(markers) do
        local matched = false

        for _, cluster in ipairs(clusters) do
            local dx = math.abs(cluster.centerX - marker.location.x)
            local dy = math.abs(cluster.centerY - marker.location.y)

            if dx <= threshold and dy <= threshold then
                table.insert(cluster.members, marker)
                cluster.centerX = (cluster.centerX + marker.location.x) / 2
                cluster.centerY = (cluster.centerY + marker.location.y) / 2
                cluster.count = (cluster.count or 0) + (marker.count or 1)
                matched = true
                break
            end
        end

        if not matched then
            table.insert(clusters, {
                centerX = marker.location.x,
                centerY = marker.location.y,
                members = { marker },
                count = marker.count or 1,
            })
        end
    end

    return clusters
end

function MC.Map.MarkerCluster:BuildClustersFromHotspots(hotspots, zoomLevel)
    local markers = {}
    for _, hotspot in ipairs(hotspots or {}) do
        if hotspot and hotspot.mapID then
            local marker = {
                markerID = string.format("hotspot:%s:%s:%s", tostring(hotspot.mapID), tostring(hotspot.x or 0.5), tostring(hotspot.y or 0.5)),
                location = {
                    mapID = hotspot.mapID,
                    x = hotspot.x or 0.5,
                    y = hotspot.y or 0.5,
                },
                count = (hotspot.missing or 0) + (hotspot.unknown or 0),
            }
            table.insert(markers, marker)
        end
    end

    return self:BuildClusters(markers, zoomLevel)
end
