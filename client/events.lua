-- QBCore Command Events
RegisterNetEvent('QBCore:Command:TeleportToPlayer')
AddEventHandler('QBCore:Command:TeleportToPlayer', function(coords)
	local ped = PlayerPedId()
	SetPedCoordsKeepVehicle(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('QBCore:Command:TeleportToCoords')
AddEventHandler('QBCore:Command:TeleportToCoords', function(x, y, z)
	local ped = PlayerPedId()
	SetPedCoordsKeepVehicle(ped, x, y, z)
end)

RegisterNetEvent('QBCore:Command:SpawnVehicle')
AddEventHandler('QBCore:Command:SpawnVehicle', function(model)
	QBCore.Functions.SpawnVehicle(model, function(vehicle)
		TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
	end)
end)

RegisterNetEvent('QBCore:Command:DeleteVehicle')
AddEventHandler('QBCore:Command:DeleteVehicle', function()
	local vehicle = QBCore.Functions.GetClosestVehicle()
	if IsPedInAnyVehicle(PlayerPedId()) then vehicle = GetVehiclePedIsIn(PlayerPedId(), false) else vehicle = QBCore.Functions.GetClosestVehicle() end
	-- TriggerServerEvent('QBCore:Command:CheckOwnedVehicle', GetVehicleNumberPlateText(vehicle))
	QBCore.Functions.DeleteVehicle(vehicle)
end)

RegisterNetEvent('QBCore:Command:Revive')
AddEventHandler('QBCore:Command:Revive', function()
	local coords = QBCore.Functions.GetCoords(PlayerPedId())
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z+0.2, coords.a, true, false)
	SetPlayerInvincible(PlayerPedId(), false)
	ClearPedBloodDamage(PlayerPedId())
end)

RegisterNetEvent('QBCore:Command:GoToMarker')
AddEventHandler('QBCore:Command:GoToMarker', function()
    Citizen.CreateThread(function()
        local pedId = PlayerPedId()
        local plCoords = GetEntityCoords(pedId)
        local ox, oy, oz = table.unpack(plCoords)
        local waypoint = GetFirstBlipInfoId(8)
        local entity = IsPedInAnyVehicle(pedId, false) and GetVehiclePedIsIn(pedId, false) or pedId
        if DoesBlipExist(waypoint) == 0 then
            return
        end
        local wpCoords = GetBlipInfoIdCoord(waypoint)
        local x, y, z = table.unpack(wpCoords)
        NetworkFadeOutEntity(entity, false, true)
        NetworkFadeOutEntity(veh, false, true)
        DoScreenFadeOut(250)
        while not IsScreenFadedOut() do
            Citizen.Wait(0)
        end
        for i = 1, 1001, 1 do
            RequestCollisionAtCoord(x, y, i + 0.0)
            SetEntityCoords(entity, x, y, i + 0.0)

            NewLoadSceneStart(x, y, i + 0.0, x, y, i + 0.0, 50.0, 0)

            while IsNetworkLoadingScene() do
                Citizen.Wait(0)
            end

            while not HasCollisionLoadedAroundEntity(entity) do
                Citizen.Wait(0)
            end

            local foundGround, zPos = GetGroundZFor_3dCoord(x, y, i + 0.0, false)
            if foundGround == 1 then
                SetEntityCoords(entity, x, y, zPos)

                DoScreenFadeIn(250)
                while not IsScreenFadedIn() do
                    Citizen.Wait(0)
                end
                NetworkFadeInEntity(entity, true)
                return
            end
        end

        RequestCollisionAtCoord(ox, oy, oz)
        SetPedCoordsKeepVehicle(entity, ox, oy, oz - 1)
        FreezeEntityPosition(entity, true)
        while not HasCollisionLoadedAroundEntity(entity) do
            Citizen.Wait(0)
        end

        NewLoadSceneStart(ox, oy, oz, ox, oy, oz, 50.0, 0)
        while IsNetworkLoadingScene() do
            Citizen.Wait(0)
        end

        FreezeEntityPosition(entity, false)
        DoScreenFadeIn(500)
        while not IsScreenFadedIn() do
            Citizen.Wait(0)
        end
        NetworkFadeInEntity(entity, true)
    end)
end)

-- Other stuff
RegisterNetEvent('QBCore:Player:SetPlayerData')
AddEventHandler('QBCore:Player:SetPlayerData', function(val)
	QBCore.PlayerData = val
end)

RegisterNetEvent('QBCore:Player:UpdatePlayerData')
AddEventHandler('QBCore:Player:UpdatePlayerData', function()
	local data = {}
	data.position = QBCore.Functions.GetCoords(PlayerPedId())
	TriggerServerEvent('QBCore:UpdatePlayer', data)
end)

RegisterNetEvent('QBCore:Player:UpdatePlayerPosition')
AddEventHandler('QBCore:Player:UpdatePlayerPosition', function()
	local position = QBCore.Functions.GetCoords(PlayerPedId())
	TriggerServerEvent('QBCore:UpdatePlayerPosition', position)
end)

RegisterNetEvent('QBCore:Notify')
AddEventHandler('QBCore:Notify', function(text, type, length)
	QBCore.Functions.Notify(text, type, length)
end)

RegisterNetEvent('QBCore:Client:TriggerCallback') -- QBCore:Client:TriggerCallback falls under GPL License here: [esxlicense]/LICENSE
AddEventHandler('QBCore:Client:TriggerCallback', function(name, ...)
	if QBCore.ServerCallbacks[name] ~= nil then
		QBCore.ServerCallbacks[name](...)
		QBCore.ServerCallbacks[name] = nil
	end
end)

RegisterNetEvent("QBCore:Client:UseItem") -- QBCore:Client:UseItem falls under GPL License here: [esxlicense]/LICENSE
AddEventHandler('QBCore:Client:UseItem', function(item)
	TriggerServerEvent("QBCore:Server:UseItem", item)
end)
