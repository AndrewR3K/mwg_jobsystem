local Key = Config.Key
local Inmenu
local VORPcore = {}
local OnDuty = false
local Job = {}

-- Get Menu
TriggerEvent("menuapi:getData", function(call)
    MenuData = call
end)

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
    TriggerServerEvent("mwg_jobsystem:loadClientData")
end)

RegisterNetEvent("mwg_jobsystem:returnClientData", function(JobData)
    for k, v in pairs(JobData) do
        print(string.format("%s: %s", k, v))
    end
    Job = JobData
end)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local isDead = IsPedDeadOrDying(player)
        if IsControlJustPressed(0, Key) and not isDead and not Inmenu and not OnDuty then
            MenuData.CloseAll()
            TriggerServerEvent("mwg_jobsystem:getJobs", "jobsystem.openJobsMenu")
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

                TriggerServerEvent("mwg_jobsystem:selectJob", data.current.job_name, data.current.value)
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
    VORPcore.NotifySimpleTop(_U("LevelUpTitle") .. level, _U("LevelUpSubtitle") .. Job.jobName, 4000)
end)

RegisterNetEvent("mwg_jobsystem:addxp", function(xp)
    TriggerServerEvent("mwg_jobsystem:modifyJobExperience", Job.jobID, Job.level, Job.totalXp, xp, true)
end)

RegisterNetEvent("mwg_jobsystem:remxp", function(xp)
    TriggerServerEvent("mwg_jobsystem:modifyJobExperience", Job.jobID, Job.level, Job.totalXp, xp, false)
end)

RegisterCommand("onduty", function(source, args, rawCommand)
    OnDuty = true
    TriggerServerEvent("mwg_jobsystem:onduty")
end)

RegisterCommand("offduty", function(source, args, rawCommand)
    OnDuty = false
    TriggerServerEvent("mwg_jobsystem:offduty")
end)

RegisterCommand("jobinfo", function(source, args, rawCommand)
    for k, v in pairs(Job) do
        print(string.format("%s: %v", k, v))
    end
end)
