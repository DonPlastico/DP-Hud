lib.callback.register("DP-VehicleMileage:server:get-mileage", function(_, plate)
    local vehicle = MySQL.single.await("SELECT mileage FROM " .. Framework.VehiclesTable .. " WHERE plate = ?", {plate})
    if not vehicle then
        return {
            error = true
        }
    end
    return {
        mileage = vehicle.mileage
    }
end)

RegisterNetEvent("DP-VehicleMileage:server:update-mileage", function(plate, mileage)
    MySQL.update("UPDATE " .. Framework.VehiclesTable .. " SET mileage = ? WHERE plate = ?", {mileage, plate})
end)

exports("GetMileage", function(plate)
    local vehicle = MySQL.single.await("SELECT mileage FROM " .. Framework.VehiclesTable .. " WHERE plate = ?", {plate})
    if not vehicle then
        return false
    end
    return vehicle.mileage, Config.Unit
end)
