local QBCore = exports['qb-core']:GetCoreObject()

local hunger = 100
local thirst = 100
local cineToggleKey = nil
local minimapToggleKey = nil
local minimapManualVisible = false
local lastMinimapBorderState = false
local lastSpeed = 0
local vehicleHudVisible = false
local lastGear = 0
local lastAcceleration = 0
local isLimiterActive = false
local currentSpeedLimit = 0
local isSeatbeltOn = false -- Estado local para rastrear si el cinturón está puesto

-- Función auxiliar para obtener la dirección de la brújula (N, NE, E, SE, S, SO, O, NO)
local function GetCompassDirection()
    local heading = GetEntityHeading(PlayerPedId())
    local directions = {
        [0] = 'N', -- Norte
        [1] = 'NE', -- Noreste
        [2] = 'E', -- Este
        [3] = 'SE', -- Sureste
        [4] = 'S', -- Sur
        [5] = 'SW', -- Suroeste
        [6] = 'W', -- Oeste
        [7] = 'NW' -- Noroeste
    }
    -- Divide el círculo (360 grados) en 8 sectores de 45 grados.
    local directionIndex = math.floor(((heading + 22.5) % 360) / 45)
    return directions[directionIndex] or 'N'
end

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

RegisterNetEvent('DP-Hud:setMinimapKey')
AddEventHandler('DP-Hud:setMinimapKey', function(key)
    if key and keyMap[key] then
        minimapToggleKey = keyMap[key]
    else
        minimapToggleKey = nil
    end
end)

RegisterNetEvent('DP-Hud:setCineKey')
AddEventHandler('DP-Hud:setCineKey', function(key)
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
            vida = GetEntityHealth(ped) - 100,
            hunger = hunger,
            thirst = thirst,
            escudo = GetPedArmour(ped),
            stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId()),
            oxigeno = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10,
            enVeh = IsPedInAnyVehicle(PlayerPedId())
        })
        DisplayRadar(IsPedInAnyVehicle(PlayerPedId()) or minimapManualVisible)
        Wait(msec)
    end
end)

-- Hilo para actualizar la información de la calle y la brújula
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Se actualiza cada 0.5 segundos para ahorrar recursos

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Obtener nombres de las calles
        local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local currentStreet = GetStreetNameFromHashKey(streetHash)
        local currentCrossing = GetStreetNameFromHashKey(crossingHash)

        -- Formatear la ubicación (muestra la calle actual o la intersección)
        local location = currentStreet
        -- Solo añade la intersección si no es 0 (no hay) y tiene un nombre válido
        if crossingHash ~= 0 and currentCrossing and currentCrossing ~= "" then
            location = location .. " / " .. currentCrossing
        end

        -- Obtener dirección de la brújula
        local compass = GetCompassDirection()

        -- Enviar el mensaje a la NUI
        SendNUIMessage({
            action = "updateStreetLabel", -- Nuevo action para JavaScript
            street = location,
            direction = compass
        })
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

-- Hilo de control continuo del minimapa (Visibilidad en vehículo/manual)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)

        local ped = GetPlayerPed(-1)
        SetRadarZoom(1100)

        local currentRadarVisible = IsPedInAnyVehicle(ped, true) or minimapManualVisible

        if currentRadarVisible ~= lastMinimapBorderState then
            lastMinimapBorderState = currentRadarVisible

            DisplayRadar(currentRadarVisible)

            SendNUIMessage({
                action = "toggleMinimapBorder",
                show = currentRadarVisible
            })
        else
            DisplayRadar(currentRadarVisible)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if minimapToggleKey and IsControlJustPressed(0, minimapToggleKey) then
            minimapManualVisible = not minimapManualVisible

            local currentRadarVisible = IsPedInAnyVehicle(PlayerPedId(), true) or minimapManualVisible

            lastMinimapBorderState = currentRadarVisible

            DisplayRadar(minimapManualVisible)

            SendNUIMessage({
                action = "toggleMinimapBorder",
                show = minimapManualVisible
            })
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

-- Hilo de control principal para el HUD del vehículo
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local delay = 500 -- Retraso por defecto (a pie)

        -- 1. Comprobar si el jugador está en un vehículo
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local fuel = GetVehicleFuelLevel(vehicle) -- ¡NUEVO! Obtiene el nivel de combustible (0.0 a 100.0)
            local speed = GetEntitySpeed(vehicle) * 3.6
            local rpm = GetVehicleCurrentRpm(vehicle)
            local gear = GetVehicleCurrentGear(vehicle) -- Valor API de FiveM (0, 1, 2, 3...)
            local isEngineRunning = GetIsVehicleEngineRunning(vehicle)
            local throttle = GetControlValue(0, 71) -- Entrada de aceleración
            local brake = GetControlValue(0, 72) -- Entrada de freno

            delay = 5

            -- Lógica para el valor de las RPM (barra vacía si está parado)
            if speed < 0.5 then
                rpm = 0.0 -- Fija las RPM a 0.0 si el vehículo está esencialmente parado
            end

            -- LÓGICA SECUENCIAL PARA EL INDICADOR DE MARCHA

            local displayGear = lastGear

            local downshiftThresholds = {
                [6] = 100, -- De 6 a 5 (baja si la velocidad cae de 100)
                [5] = 80, -- De 5 a 4
                [4] = 60, -- De 4 a 3
                [3] = 30, -- De 3 a 2
                [2] = 10, -- De 2 a 1
                [1] = 2 -- De 1 a N (baja si la velocidad cae de 2)
            }

            if not isEngineRunning then
                displayGear = 0 -- Motor apagado = Neutral (FiveM 0)

            elseif gear > displayGear then
                displayGear = gear

            else
                for currentGear = 6, 1, -1 do
                    local nextGear = currentGear - 1
                    local threshold = downshiftThresholds[currentGear]

                    if displayGear == currentGear and speed < threshold and speed > 0.5 then
                        displayGear = nextGear
                        break
                    end
                end
            end

            -- Caso especial para Neutral (N) y Reversa (R)
            if speed < 1.0 and throttle < 0.1 and brake < 0.1 then
                displayGear = 0 -- Neutral si estamos parados y sin acelerar/frenar
            elseif GetVehicleCurrentRpm(vehicle) < 0.0 and speed < 5.0 then
                displayGear = -1 -- Usamos -1 para representar Reversa
            end

            -- 4. Formateo para la NUI
            local gearDisplay = "N"
            if displayGear == 0 then
                gearDisplay = "N"
            elseif displayGear == -1 then
                gearDisplay = "R"
            else
                -- Marchas de avance (1, 2, 3...)
                gearDisplay = tostring(displayGear)
            end

            -- Lógica para mostrar/actualizar el HUD
            if not vehicleHudVisible or math.abs(speed - lastSpeed) > 0.05 or displayGear ~= lastGear then
                SendNUIMessage({
                    action = "updateVehicleHud",
                    show = true,
                    speed = speed,
                    rpm = rpm,
                    gear = gearDisplay,
                    fuel = fuel -- ¡NUEVO! Enviamos el porcentaje de combustible
                })
                vehicleHudVisible = true
            end

            lastSpeed = speed
            lastGear = displayGear
        else
            -- Lógica para ocultar el HUD al bajarse
            if vehicleHudVisible then
                SendNUIMessage({
                    action = "updateVehicleHud",
                    show = false,
                    speed = 0,
                    rpm = 0.0,
                    gear = "N",
                    fuel = 0 -- Reseteamos el combustible al salir
                })
                vehicleHudVisible = false
            end
        end

        Citizen.Wait(delay)
    end
end)

-- Función auxiliar para enviar el estado del limitador al HUD (NUI)
local function SendLimiterStatus(active)
    SendNUIMessage({
        action = 'limiterStatus', -- El action que definimos en script.js
        active = active
    })
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5) -- Chequeo rápido para la pulsación de tecla y la limitación

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local isDriver = IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(vehicle, -1) == ped

        if isDriver then
            -- 1. Manejo de la tecla (Control: 0 es el grupo por defecto del teclado/ratón)
            if IsControlJustReleased(0, 246) then
                isLimiterActive = not isLimiterActive -- Alterna el estado (ON/OFF)

                if isLimiterActive then
                    -- Limitador activado: Coge la velocidad actual como límite
                    local currentSpeed = GetEntitySpeed(vehicle) * 3.6 -- Convierte m/s a km/h
                    currentSpeedLimit = math.ceil(currentSpeed) -- Redondea el límite hacia arriba

                    QBCore.Functions.Notify("Limitador ACTIVO: " .. currentSpeedLimit .. " KM/H", "success", 2500)
                else
                    -- Limitador desactivado: Quita cualquier límite
                    currentSpeedLimit = 0
                    SetVehicleMaxSpeed(vehicle, 999.0)
                    QBCore.Functions.Notify("Limitador DESACTIVO", "error", 2500)
                end

                -- Enviar estado a la interfaz de usuario (HTML/JS)
                SendLimiterStatus(isLimiterActive)
            end

            -- 2. Forzar la velocidad si el limitador está activo
            if isLimiterActive then
                local limitSpeedMs = currentSpeedLimit / 3.6 -- Límite convertido de km/h a m/s

                -- Esto ajusta el "tope" de velocidad del motor del vehículo
                SetVehicleMaxSpeed(vehicle, limitSpeedMs)
            else
                -- Siempre asegura que el vehículo pueda alcanzar su velocidad normal si el limitador está OFF
                SetVehicleMaxSpeed(vehicle, 999.0)
            end
        else
            -- Si el conductor sale del vehículo y el limitador estaba activo, lo desactiva.
            if isLimiterActive then
                isLimiterActive = false
                currentSpeedLimit = 0
                -- Asegura que la NUI sepa que se ha desactivado
                SendLimiterStatus(isLimiterActive)
            end
            -- Cuando no está en un vehículo, podemos esperar más para ahorrar recursos
            Citizen.Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()

        -- Solo comprobamos si está en un vehículo
        if IsPedInAnyVehicle(ped, false) then
            Citizen.Wait(5) -- Chequeo rápido en vehículo

            -- Detectar si la tecla 'B' (29) ha sido pulsada *justo ahora*
            if IsControlJustPressed(0, 29) then

                -- 1. Cambiamos el estado del cinturón
                isSeatbeltOn = not isSeatbeltOn

                if isSeatbeltOn then
                    -- Cinturón PUESTO
                    QBCore.Functions.Notify('Cinturón puesto', 'success', 2500)

                    -- 🎯 NUEVO: ENVIAR ESTADO AL HUD
                    SendNUIMessage({
                        action = 'seatbeltStatus',
                        active = true
                    })

                    -- Lógica opcional para la física del cinturón
                    SetPedConfigFlag(ped, 32, true) -- Flag 32 = BF_CAN_FLY_THROUGH_WINDSCREEN
                else
                    -- Cinturón QUITADO
                    QBCore.Functions.Notify('Cinturón quitado', 'error', 2500)

                    -- 🎯 NUEVO: ENVIAR ESTADO AL HUD
                    SendNUIMessage({
                        action = 'seatbeltStatus',
                        active = false
                    })

                    -- Lógica opcional para la física del cinturón
                    SetPedConfigFlag(ped, 32, false)
                end
            end
        else
            -- Si no está en un vehículo (se baja)
            Citizen.Wait(500)

            -- Si estaba puesto y se bajó, enviamos el mensaje de apagado una sola vez.
            if isSeatbeltOn then
                -- 🎯 NUEVO: ENVIAR ESTADO AL HUD (solo si el estado cambia de ON a OFF)
                SendNUIMessage({
                    action = 'seatbeltStatus',
                    active = false
                })
            end

            -- Aseguramos que el cinturón esté "quitado" al salir
            isSeatbeltOn = false
            SetPedConfigFlag(ped, 32, false)
        end
    end
end)

