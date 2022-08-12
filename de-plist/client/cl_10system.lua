local QBCore = exports['qb-core']:GetCoreObject()
local InSpectatorMode, ShowInfos = false, false
local TargetSpectate, LastPosition, cam
local polarAngleDeg = 0
local azimuthAngleDeg = 90
local radius = -3.5
local PlayerJob = {}
local lastData = {}

CreateThread(function() 
    if QBCore.Functions.GetPlayerData().job then
        PlayerJob = QBCore.Functions.GetPlayerData().job
    end
end)

function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
	-- convert degrees to radians
	local polarAngleRad   = polarAngleDeg   * math.pi / 180.0
	local azimuthAngleRad = azimuthAngleDeg * math.pi / 180.0

	local pos = {
		x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
		y = entityPosition.y + radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
		z = entityPosition.z + radius * math.cos(azimuthAngleRad)
	}

	return pos
end
Citizen.CreateThread(function()

    while true do

      Wait(0)

      if InSpectatorMode then

          local targetPlayerId = GetPlayerFromServerId(TargetSpectate)
          local playerPed	  = PlayerPedId()
          local targetPed	  = GetPlayerPed(targetPlayerId)
          local coords	 = GetEntityCoords(targetPed)

          for i=0, 64, 1 do
              if i ~= PlayerId() then
                  local otherPlayerPed = GetPlayerPed(i)
                  SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  true)
              end
          end

            radius = 0.4

          local xMagnitude = GetDisabledControlNormal(0, 1)
          local yMagnitude = GetDisabledControlNormal(0, 2)

          polarAngleDeg = polarAngleDeg + xMagnitude * 10

          if polarAngleDeg >= 180 then
              polarAngleDeg = 0
          end

          --azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10

          --if azimuthAngleDeg >= 180 then
          --    azimuthAngleDeg = 0
          --end

          local nextCamLocation = polar3DToWorld3D(coords, radius, polarAngleDeg, azimuthAngleDeg)
          SetCamCoord(cam, nextCamLocation.x, nextCamLocation.y,  nextCamLocation.z)
          PointCamAtEntity(cam,  targetPed)
          SetEntityCoords(playerPed,  coords.x, coords.y, coords.z + 10)

      end
  end
end)

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 323, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    TriggerServerEvent("10system:add")
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    TriggerServerEvent("10system:add")
    if PlayerJob.name ~= "police" and PlayerJob.name ~= "ambulance" then
        --print("hide")
        SendNUIMessage({action = "hide"})
    end
end)

RegisterNetEvent('QBCore:Player:SetPlayerData')
AddEventHandler('QBCore:Player:SetPlayerData', function(pData)
    if PlayerJob.onduty ~= pData.job.onduty then
        TriggerServerEvent("10system:add")
    end
    PlayerJob = pData.job
end)

RegisterNetEvent('Tokovoip:setPlayerData')
AddEventHandler('Tokovoip:setPlayerData', function(playerServerId, key, data)
    if key == 'talking' then
        SendNUIMessage({
            action = "radioState",
            serverId = playerServerId,
            isTalking = data
        })
    end
    if key == 'recording' then
        SendNUIMessage({
            action = "camrecord",
            serverId = playerServerId,
            isRecording = data
        })
    end
end)

local last = false
RegisterCommand('ptoggle', function()
    last = not last
    SendNUIMessage({
        action = "radioState",
        serverId = GetPlayerServerId(PlayerId()),
        isTalking = last
    })
end)

RegisterNetEvent('10system:update')
AddEventHandler('10system:update', function(data)
    local id = GetPlayerServerId(PlayerId())
    for i,v in ipairs(data) do 
		if v.src == id then
			data[i].me = true
		end
		
		if(data[i].channel == -1 or data[i].channel == false) then
			data[i].channel = "OFF"
		end
    end
    SendNUIMessage({action = "update", data = data})
end)

RegisterNetEvent('10system:open')
AddEventHandler('10system:open', function()
    SendNUIMessage({action = "open"})
    SetNuiFocus(true, true)
end)

RegisterNetEvent('10system:sendError')
AddEventHandler('10system:sendError', function(text)
    SendNUIMessage({action = "error", errorText = text})
end)

RegisterNUICallback("close", function(data,cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback("action", function(data,cb)
    TriggerServerEvent('10system:action',data.data)
    cb('ok')
end)

RegisterNUICallback("ToggleOpen", function(data,cb)
    if not data.toggle then
        TriggerServerEvent("10system:add")
    else
        TriggerServerEvent("10system:remove")
    end
    cb('ok')
end)
local PressCamera = false
RegisterNUICallback("Camera", function(data,cb)
    PressCamera = not PressCamera
    spectatePlayer(data.cameratoggle)
    --[[if PressCamera then
        local target = data.cameratoggle
        if not InSpectatorMode then
            LastPosition = GetEntityCoords(PlayerPedId())
        end

        local playerPed = PlayerPedId()

        SetEntityCollision(playerPed, false, false)
        SetEntityVisible(playerPed, false)

        Citizen.CreateThread(function()
            if not DoesCamExist(cam) then
                cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            end

            SetCamActive(cam, true)
            RenderScriptCams(true, false, 0, true, true)

            InSpectatorMode = true
            TargetSpectate  = target
        end)
    else
        InSpectatorMode = false
        TargetSpectate  = nil
        local playerPed = PlayerPedId()
        
        SetCamActive(cam, false)
        RenderScriptCams(false, false, 0, true, true)
        
        SetEntityCollision(playerPed, true, true)
        SetEntityVisible(playerPed, true)
        SetEntityCoords(playerPed, LastPosition.x, LastPosition.y, LastPosition.z)
    end--]]
end)
RegisterNUICallback("rank", function(data,cb)
    TriggerServerEvent('10system:rank',data.rank)
end)
function CloseSecurityCamera()
    DestroyCam(createdCamera, 0)
    RenderScriptCams(0, 0, 1, 1, 1)
    ClearTimecycleModifier("scanline_cam_cheap")
    SetFocusEntity(GetPlayerPed(PlayerId()))
    FreezeEntityPosition(GetPlayerPed(PlayerId()), false)
end
function ChangeSecurityCamera(x, y, z, r)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamCoord(cam, x, y, z)
    SetCamRot(cam, r.x, r.y, r.z, 2)
    RenderScriptCams(1, 0, 0, 1, 1)
end
function IsOnline(target)
    print(json.encode(GetActivePlayers()))
    for v, i in ipairs(GetActivePlayers()) do
        if(v == target) then
            return true
        end
    end
    return false
end

RegisterCommand("plist",function()

	if PlayerJob.name == "police" or PlayerJob.name == "ambulance" then
		TriggerEvent("10system:open")
	end
end)

RegisterKeyMapping('plist', 'Open Job Player List', 'keyboard', 'Insert')
local spectate = false
local endScreen = false
function spectatePlayer(plyToSpec)
    print(plyToSpec)
    endScreen = false
    spectate = true
    FreezeEntityPosition(GetPlayerPed(-1),  true)
    RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(plyToSpec), 1))
    NetworkSetInSpectatorMode(1, GetPlayerPed(plyToSpec))
    while true do
        Citizen.Wait(0)
        if spectate then
            FreezeEntityPosition(GetPlayerPed(-1),  true)
            RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(plyToSpec), 1))
            NetworkSetInSpectatorMode(1, GetPlayerPed(plyToSpec))
        end
    end
end

CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = GetPlayerPed(-1)
		if IsControlJustReleased(1, Keys["="]) then
            if PlayerJob.name == "police" or PlayerJob.name == "ambulance" then
                TriggerEvent("10system:open")
            end
			Citizen.Wait(500)
		end
	end
end)
