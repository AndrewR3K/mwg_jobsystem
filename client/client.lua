local MenuKey = Config.Keys["PGUP"]
local PromptKey = Config.Keys['G']
local Inmenu
local VORPcore = {}
OnDuty = false
Job = {}
local UIShowing = false
local lastJobChange = 0
local appready = false
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local PromptGroup2 = GetRandomIntInRange(0, 0xffffff)

-- Get Menu
TriggerEvent("menuapi:getData", function(call)
    MenuData = call
end)

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
    TriggerServerEvent("mwg_jobsystem:getJobDetails", "mwg_jobsystem:returnClientData")
    appready = true
end)

RegisterNetEvent("mwg_jobsystem:setLastJobChange", function()
    lastJobChange = GetGameTimer()
end)

RegisterNetEvent("mwg_jobsystem:returnClientData", function(JobData)
    Job = JobData
    if not UIShowing then
        OpenUI(false)
        UIShowing = true
    else
        OpenUI(true)
    end
end)

Citizen.CreateThread(function()
    PromptSetUp()
    PromptSetUp2()
    while true do
        if appready then
            local player = PlayerPedId()
            local isDead = IsPedDeadOrDying(player)
            local hour = GetClockHours()
            if Config.useJobCenter then
                local coords = GetEntityCoords(player)
                for jobCenterId, jobCenter in pairs(Config.JobCenters) do
                    if (hour >= jobCenter.close_hour or hour < jobCenter.open_hour) and jobCenter.use_hours then
                        -- if Config.JobCenters[jobCenterId].blip_handle then
                        --     RemoveBlip(Config.JobCenters[jobCenterId].blip_handle)
                        --     Config.JobCenters[jobCenterId].blip_handle = nil
                        -- end
                        local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, jobCenter.x, jobCenter.y
                            , jobCenter.z)
                        if distance < 1 then
                            local label_close = CreateVarString(10, 'LITERAL_STRING',
                                _U("closed") .. jobCenter.open_hour .. _U("am") .. jobCenter.close_hour .. _U("pm"))
                            PromptSetActiveGroupThisFrame(PromptGroup2, label_close)
                        end
                    elseif hour >= jobCenter.open_hour or not jobCenter.use_hours then
                        local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, jobCenter.x, jobCenter.y
                            , jobCenter.z)
                        -- if not Config.JobCenters[jobCenterId].blip_handle and jobCenter.create_blip then
                        --     AddBlip(jobCenterId)
                        -- end
                        if distance < 1 then
                            local label_open = CreateVarString(10, 'LITERAL_STRING', jobCenter.prompt_name)
                            PromptSetActiveGroupThisFrame(PromptGroup, label_open)
                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenJobCenter) then
                                CloseUI()
                                UIShowing = false
                                TriggerServerEvent("mwg_jobsystem:getJobs", "jobsystem:openJobUI")
                            end
                        end
                    end
                end
            else
                if not isDead and not Inmenu then
                    if IsControlJustPressed(0, MenuKey) then
                        if not OnDuty then
                            local timeSinceJobChange = math.floor(((GetGameTimer() - lastJobChange) / 1000) / 60)
                            if timeSinceJobChange >= Config.jobChangeDelay or lastJobChange == 0 then
                                MenuData.CloseAll()
                                TriggerServerEvent("mwg_jobsystem:getJobs", "jobsystem:openJobsMenu")
                                Inmenu = true
                            else
                                local nextJobChange = Config.jobChangeDelay - timeSinceJobChange
                                VORPcore.NotifyRightTip(_U("JobChangeDelay") .. nextJobChange .. _U("TimeFormat"), 4000)
                            end
                        else
                            VORPcore.NotifyRightTip(_U("OnDutyNoMenu"), 4000)
                        end
                    end
                end
            end
        end
        Citizen.Wait(10)
    end
end)

RegisterNetEvent("mwg_jobsystem:openJobsMenu", function(jobs)
    if jobs ~= nil then
        MenuData.CloseAll()

        MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
            {
                title = _U("MenuTitle"),
                subtext = _U("MenuSubTitle"),
                align = 'top-left',
                elements = jobs
            },
            function(data, menu)
                if data.current == "backup" then
                    _G[data.trigger]()
                end

                TriggerServerEvent("mwg_jobsystem:jobSelected", data.current.job_name, data.current.value)
                menu.close()
            end,
            function(data, menu)
                menu.close()
            end)
    else
        TriggerServerEvent("vorp:TipRight", "There are no jobs available!", 4000)
    end
end)

RegisterNetEvent("jobsystem:openJobUI", function(jobs)
    SendNUIMessage({
        type = "jobUI",
        jobs = jobs
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent("mwg_jobsystem:levelup", function(level)
    CloseUI()
    VORPcore.NotifySimpleTop(_U("LevelUpTitle") .. level, _U("LevelUpSubtitle") .. Job.jobName, 4000)

    Wait(6000)
    OpenUI(false)
    UIShowing = true
end)

AddEventHandler("mwg_jobsystem:addxp", function(xp)
    TriggerServerEvent("mwg_jobsystem:modifyJobExperience", Job.jobID, Job.level, Job.totalXp, xp, true)
end)

AddEventHandler("mwg_jobsystem:remxp", function(xp)
    TriggerServerEvent("mwg_jobsystem:modifyJobExperience", Job.jobID, Job.level, Job.totalXp, xp, false)
end)

RegisterCommand("onduty", function(source, args, rawCommand)
    OnDuty = true
    TriggerServerEvent("mwg_jobsystem:onduty", Job.jobID)
end)

RegisterCommand("offduty", function(source, args, rawCommand)
    OnDuty = false
    TriggerServerEvent("mwg_jobsystem:offduty", Job.jobID)
end)

function CloseUI()
    SendNUIMessage({
        type = 'close'
    })
    SetNuiFocus(false, false)
end

function OpenUI(UpdateOnly)
    if UpdateOnly then
        SendNUIMessage({
            type = 'update',
            jobData = Job
        })
    else
        SendNUIMessage({
            type = 'open',
            jobData = Job
        })
    end

    SetNuiFocus(false, false)
end

function PromptSetUp()
    local str = _U("SubPrompt")
    OpenJobCenter = PromptRegisterBegin()
    PromptSetControlAction(OpenJobCenter, PromptKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(OpenJobCenter, str)
    PromptSetEnabled(OpenJobCenter, 1)
    PromptSetVisible(OpenJobCenter, 1)
    PromptSetStandardMode(OpenJobCenter, 1)
    PromptSetGroup(OpenJobCenter, PromptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, OpenJobCenter, true)
    PromptRegisterEnd(OpenJobCenter)
end

function PromptSetUp2()
    local str = _U("SubPrompt")
    CloseJobCenter = PromptRegisterBegin()
    PromptSetControlAction(CloseJobCenter, PromptKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(CloseJobCenter, str)
    PromptSetEnabled(CloseJobCenter, 1)
    PromptSetVisible(CloseJobCenter, 1)
    PromptSetStandardMode(CloseJobCenter, 1)
    PromptSetGroup(CloseJobCenter, PromptGroup2)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, CloseJobCenter, true)
    PromptRegisterEnd(CloseJobCenter)

end

function AddBlip(JobCenter)
    if Config.JobCenters[JobCenter].create_blip then
        local blip_style = GetHashKey(Config.JobCenters[JobCenter].blip_style)
        -- Create Blip with Sytle Hash
        Config.JobCenters[JobCenter].BlipHandle = Citizen.InvokeNative(0x554D9D53F696D002, blip_style,
            Config.JobCenters[JobCenter].x, Config.JobCenters[JobCenter].y, Config.JobCenters[JobCenter].z)
        -- Set Sprite
        Citizen.InvokeNative(0x74F74D3207ED525C, Config.JobCenters[JobCenter].BlipHandle,
            Config.JobCenters[JobCenter].blip_hash, true)
        -- Set Sprite Scale
        Citizen.InvokeNative(0xD38744167B2FA257, Config.JobCenters[JobCenter].BlipHandle, 0.2)
        -- Set Blip Name
        Citizen.InvokeNative(0x9CB1A1623062F402, Config.JobCenters[JobCenter].BlipHandle,
            Config.JobCenters[JobCenter].blip_name)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if Inmenu == true then
        ClearPedTasksImmediately(PlayerPedId())
        PromptDelete(OpenJobCenter)
        MenuData.CloseAll()
    end

    CloseUI()
    for _, v in pairs(Config.JobCenters) do
        if v.blip_handle then
            RemoveBlip(v.blip_handle)
        end
    end
end)

RegisterNUICallback('jobUIClose', function(args, cb)
    if args.action == "close" then
        SetNuiFocus(false, false)
    elseif args.action == "setJob" then
        local job = args.job
        TriggerServerEvent("mwg_jobsystem:jobSelected", job.job_name, job.value)
    elseif args.action == "quitJob" then
        local job = args.job
        TriggerServerEvent("mwg_jobsystem:quitJob", job.value)
    end

    SetNuiFocus(false, false)
    cb('ok')
end)
