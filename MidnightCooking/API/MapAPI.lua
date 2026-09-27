local MC = _G.MidnightCookingCompletionist
if not MC then
    return
end

MC.API = MC.API or {}
MC.API.Map = MC.API.Map or {}

function MC.API.Map:SetWaypoint(location)
    if type(C_Map) ~= "table" then
        return false
    end

    if type(C_Map.SetUserWaypoint) == "function" then
        C_Map.SetUserWaypoint(location)
        return true
    end

    return false
end

function MC.API.Map:ClearWaypoint()
    if type(C_Map) == "table" and type(C_Map.ClearUserWaypoint) == "function" then
        C_Map.ClearUserWaypoint()
        return true
    end

    return false
end

function MC.API.Map:GetCurrentWaypoint()
    if type(C_Map) == "table" and type(C_Map.GetUserWaypoint) == "function" then
        return C_Map.GetUserWaypoint()
    end

    return nil
end
