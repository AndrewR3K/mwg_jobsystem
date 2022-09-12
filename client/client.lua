local Key = Config.Keys["PGUP"]
local Inmenu
local VORPcore = {}
OnDuty = false
Job = {}
local UIShowing = false

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
    while true do
        local player = PlayerPedId()
        local isDead = IsPedDeadOrDying(player)
        if IsControlJustPressed(0, Key) and not isDead and not Inmenu and not OnDuty then
            MenuData.CloseAll()
            TriggerServerEvent("mwg_jobsystem:getJobs", "jobsystem.openJobsMenu")
        elseif OnDuty then
            VORPcore.NotifyRightTip(_U("OnDutyNoMenu"), 4000)
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
