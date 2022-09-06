local Key = Config.Key
local Inmenu
local VORPcore = {}

-- Get Menu
TriggerEvent("menuapi:getData", function(call)
    MenuData = call
end)

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local isDead = IsPedDeadOrDying(player)
        if IsControlJustPressed(0, Key) and not isDead and not Inmenu then
            MenuData.CloseAll()
            TriggerServerEvent("mwg_jobsystem:getJobs", "jobsystem.openjobmenu")
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

                local jobname = data.current.value
                TriggerServerEvent("mwg_jobsystem:setJob", jobname, data.current.job_id)
                menu.close()
            end,
            function(data, menu)
                menu.close()
            end)
    else
        TriggerServerEvent("vorp:TipRight", "There are no jobs available!", 4000)
    end
end)

RegisterNetEvent("mwg_jobsystem:levelup", function(level, job)
    VORPcore.NotifySimpleTop(_U("LevelUpTitle") .. level, _U("LevelUpSubtitle") .. job, 4000)
end)

RegisterCommand("onduty", function(source, args, rawCommand)
    TriggerServerEvent("mwg_jobsystem:onduty")
end)

RegisterCommand("offduty", function(source, args, rawCommand)
    TriggerServerEvent("mwg_jobsystem:offduty")
end)
