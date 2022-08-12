local QBCore = exports['qb-core']:GetCoreObject()

 local CallSigns = {}
 local radio = {}
 local talking = {}
 local record = {}
 local duty = false

 RegisterServerEvent("10system:action")
 AddEventHandler("10system:action", function(data)
     if data.action == "error" then
         TriggerEvent('10system:sendError', data.code)
     end
 end)

 RegisterServerEvent("10system:add")
 AddEventHandler("10system:add", function()
     local data = {}
     for k,v in pairs(QBCore.Functions.GetPlayers()) do
         local xPlayer = QBCore.Functions.GetPlayer(v)

          local name = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
          local rank = xPlayer.PlayerData.job.grade.name
          local grade = xPlayer.PlayerData.job.grade.level
          local jobName = xPlayer.PlayerData.job.name
          local jobLabel = xPlayer.PlayerData.job.label
          local callSign = CallSigns[xPlayer.PlayerData.citizenid .. "|" .. jobName] or "Not set"
          local Channel = radio[tostring(v)] or "Off "
          local pTalking = talking[tostring(v)]
          local pRecording = record[tostring(v)] or false
          local bGang = false
          for key, value in pairs(QBCore.Shared.Gangs) do
                  if(key == jobName) then
                          bGang = true
                  end
          end
          if jobName ~= "unemployed" then
                  table.insert(data, {
                          src = v,
                          callsign = callSign,
                          name = name,
                          jobName = jobName,
                          jobLabel = jobLabel,
                          rank = rank,
                          bGang = bGang,
                          grade = grade,
                          channel = Channel,
                          ptalking = pTalking,
                          precord = pRecording,
                          duty = xPlayer.PlayerData.job.onduty
                  })
          end
     end

     TriggerClientEvent("10system:update", -1, data)
 end)

 RegisterServerEvent("TokoVoip:addPlayerToRadio")
 AddEventHandler("TokoVoip:addPlayerToRadio", function(sid, data)
  sid = tostring(sid)
  radio[sid] = data
  TriggerEvent("10system:add")
 end)
 
RegisterServerEvent("TokoVoip:talkingstatus")
AddEventHandler("TokoVoip:talkingstatus", function(sid, status)
    for k,v in pairs(QBCore.Functions.GetPlayers()) do
        if radio[tostring(v)] == radio[tostring(sid)] then
            TriggerClientEvent("Tokovoip:setPlayerData", v, sid, 'talking', status)
        end
    end
end)
RegisterServerEvent("TokoVoip:recordingstatus")
AddEventHandler("TokoVoip:recordingstatus", function(sid, status)
    sid = tostring(sid)
    record[sid] = status
    TriggerClientEvent("Tokovoip:setPlayerData", -1, sid, 'recording', status)
    TriggerEvent("10system:add")
end)
 RegisterServerEvent("10system:rank")
 AddEventHandler("10system:rank", function(data)
     local xPlayer = QBCore.Functions.GetPlayer(source)
     CallSigns[xPlayer.PlayerData.citizenid .. "|" .. xPlayer.PlayerData.job.name] = data
     SaveResourceFile(GetCurrentResourceName(), "database.json", json.encode(CallSigns))
     TriggerEvent("10system:add")
 end)

 CreateThread(function()
     local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "database.json"))

     if result then
         CallSigns = result
     end
 end)

 local securityPassed = false
 local securityFailed = false
