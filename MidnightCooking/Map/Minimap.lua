local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.Map = MC.Map or {}
MC.Map.Minimap = MC.Map.Minimap or {}

function MC.Map.Minimap:CreatePulse(marker)
    if not marker or not marker.location then
        return nil
    end

    return {
        markerID = marker.markerID,
        mapID = marker.location.mapID,
        x = marker.location.x,
        y = marker.location.y,
        count = marker.count or 0,
        type = "pulse",
    }
end

function MC.Map.Minimap:CreatePulses(markers)
    local pulses = {}
    markers = markers or {}

    for _, marker in pairs(markers) do
        local pulse = self:CreatePulse(marker)
        if pulse then
            table.insert(pulses, pulse)
        end
    end

    table.sort(pulses, function(a, b)
        if (a.mapID or 0) ~= (b.mapID or 0) then
            return (a.mapID or 0) < (b.mapID or 0)
        end

        if (a.y or 0) ~= (b.y or 0) then
            return (a.y or 0) < (b.y or 0)
        end

        return (a.x or 0) < (b.x or 0)
    end)

    return pulses
end

function MC.Map.Minimap:GetPulseSummary(pulses)
    local summary = {
        total = 0,
        totalCount = 0,
        maps = {},
    }

    pulses = pulses or {}
    for _, pulse in ipairs(pulses) do
        summary.total = summary.total + 1
        summary.totalCount = summary.totalCount + (pulse.count or 0)

        local key = tostring(pulse.mapID or 0)
        summary.maps[key] = (summary.maps[key] or 0) + 1
    end

    return summary
end
