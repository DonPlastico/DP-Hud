local hunger = 100
local thirst = 100
local cineToggleKey = nil
local minimapToggleKey = nil
local minimapManualVisible = false

local keyMap = {
    ["V"] = 0,
    ["PAGEUP"] = 10,
    ["PAGEDOWN"] = 11,
    ["ENTER"] = 18,
    ["Z"] = 20,
    ["C"] = 26,
    ["B"] = 29,
    ["Q"] = 44,
    ["R"] = 45,
    ["G"] = 47,
    ["F9"] = 56,
    ["F10"] = 57,
    ["X"] = 73,
    ["H"] = 74,
    ["."] = 81,
    [","] = 82,
    ["INSERT"] = 121,
    ["F5"] = 166,
    ["F6"] = 167,
    ["F7"] = 168,
    ["UP"] = 172,
    ["L"] = 182,
    ["HOME"] = 212,
    ["M"] = 244,
    ["Y"] = 246,
    ["N"] = 249,
    ["U"] = 303,
    ["K"] = 311
}

RegisterNetEvent('DP-HealthHud:setMinimapKey')
AddEventHandler('DP-HealthHud:setMinimapKey', function(key)
    if key and keyMap[key] then
        minimapToggleKey = keyMap[key]
    else
        minimapToggleKey = nil
    end
end)

RegisterNetEvent('DP-HealthHud:setCineKey')
AddEventHandler('DP-HealthHud:setCineKey', function(key)
    if key and keyMap[key] then
        cineToggleKey = keyMap[key]
    else
        cineToggleKey = nil
    end
end)

RegisterNUICallback('toggleMinimap', function(_, cb)
    minimapManualVisible = not minimapManualVisible
    if minimapManualVisible then
        DisplayRadar(true)
    else
        DisplayRadar(false)
    end
    cb('ok')
end)

RegisterNUICallback('setMinimapKey', function(data, cb)
    if data and data.key then
        minimapToggleKey = data.key
    end
    cb('ok')
end)

RegisterNetEvent("hud:client:UpdateNeeds")
AddEventHandler("hud:client:UpdateNeeds", function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
end)

Citizen.CreateThread(function()
    while true do
        local msec = 1000
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
        -- Cambia esta línea:
        -- DisplayRadar(IsPedInAnyVehicle(PlayerPedId()))
        -- Por esta:
        DisplayRadar(IsPedInAnyVehicle(PlayerPedId()) or minimapManualVisible)
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

Citizen.CreateThread(function()
    SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local ped = GetPlayerPed(-1)
        SetRadarZoom(1100)
        -- Cambia la lógica aquí también:
        if IsPedInAnyVehicle(ped, true) or minimapManualVisible then
            DisplayRadar(true)
        else
            DisplayRadar(false)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if minimapToggleKey and IsControlJustPressed(0, minimapToggleKey) then
            minimapManualVisible = not minimapManualVisible
            if minimapManualVisible then
                DisplayRadar(true)
            else
                DisplayRadar(false)
            end
        end
    end
end)

local cineBarsVisible = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if cineToggleKey and IsControlJustPressed(0, cineToggleKey) then
            cineBarsVisible = not cineBarsVisible
            SendNUIMessage({
                action = "toggleCineBars",
                show = cineBarsVisible
            })
        end
    end
end)
