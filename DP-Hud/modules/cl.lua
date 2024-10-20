local hunger = 100
local thirst = 100

RegisterNetEvent("hud:client:UpdateNeeds")
AddEventHandler("hud:client:UpdateNeeds", function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
end)

CreateThread(function()
    while true do
        local msec = 1000;
        local ped = PlayerPedId()

        SendNUIMessage({
            action = "u-hud",
            vida = GetEntityHealth(ped) - 105,
            hunger = hunger,
            thirst = thirst,
            escudo = GetPedArmour(ped),
            stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId()),
            oxigeno = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10,
            enVeh = IsPedInAnyVehicle(PlayerPedId())
        })
        DisplayRadar(IsPedInAnyVehicle(PlayerPedId()))
        Wait(msec)
    end
end)

CreateThread(function()
    while true do
        SetRadarBigmapEnabled(false, false)
        Wait(500)
    end
end)

CreateThread(function()
    local minimap = RequestScaleformMovie('minimap')
    if not HasScaleformMovieLoaded(minimap) then
        RequestScaleformMovie(minimap)
        while not HasScaleformMovieLoaded(minimap) do
            Wait(1)
        end
    end
end)