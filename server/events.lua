local VorpCore = {}
TriggerEvent("getCore", function(core)
    VorpCore = core
end)

AddEventHandler("mwg_jobsystem:setJob", function(source, jobid)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter


    exports.oxmysql:query("UPDATE character_jobs SET active=0 WHERE identifier=? and charid=?; ",
        { Character.identifier, Character.charIdentifier }, function(_)
        exports.oxmysql:query("UPDATE character_jobs SET active=1 WHERE identifier = ? and charid = ? and jobid = ?;",
            { Character.identifier, Character.charIdentifier, jobid }, function(_)

            TriggerEvent("mwg_jobsystem:getJobDetails", "mwg_jobsystem:returnClientData", _source)
        end)
    end)
end)

RegisterServerEvent("mwg_jobsystem:getJobDetails", function(cb, providedSource)
    local _source
    if providedSource == nil then
        _source = source
    else
        _source = providedSource
    end

    GetCharJobDetails(_source, function(jobDetails)
        TriggerClientEvent(cb, _source, jobDetails)
    end)
end)

RegisterServerEvent("mwg_jobsystem:jobSelected", function(newjob, newjobid)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter

    TriggerClientEvent("mwg_jobsystem:setLastJobChange", _source)

    exports.oxmysql:query("SELECT * FROM character_jobs WHERE identifier = ? and charid = ? and jobid = ?"
        , { Character.identifier, Character.charIdentifier, newjobid },
        function(result)
            if result[1] then
                TriggerEvent("mwg_jobsystem:setJob", _source, newjobid)
                -- Set Job with VORP (Updates Character.job)
                TriggerEvent("vorp:setJob", _source, string.lower(newjob), result[1].level)
                -- vorp_crafting support for job locks
                TriggerClientEvent("vorp:setjob", _source, string.lower(newjob))
                VorpCore.NotifyRightTip(_source, _U("jobgiven") .. newjob, 5000)
                Wait(500)
                VorpCore.NotifyRightTip(_source, _U("gradegiven") .. result[1].level, 5000)
            else
                exports.oxmysql:query("INSERT INTO character_jobs (`identifier`, `charid`, `jobid`, `totalxp`, `level`, `active`) VALUES (?, ?, ?, 0, 1, 1);"
                    , { Character.identifier, Character.charIdentifier, newjobid }, function(_)
                    -- Set Job with VORP (Updates Character.job)
                    TriggerEvent("mwg_jobsystem:setJob", _source, newjobid)
                    -- vorp_crafting support for job locks
                    TriggerEvent("vorp:setJob", _source, string.lower(newjob), 1)
                    TriggerClientEvent("vorp:setjob", _source, string.lower(newjob))
                    VorpCore.NotifyRightTip(_source, _U("jobgiven") .. newjob, 5000)
                    Wait(500)
                    VorpCore.NotifyRightTip(_source, _U("gradegiven") .. 1, 5000)
                end)
            end
        end)
end)

RegisterServerEvent("mwg_jobsystem:getJobs", function()
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter

    exports.oxmysql:query("SELECT jobid, level, active from character_jobs WHERE identifier = ? and charid = ?;"
        , { Character.identifier, Character.charIdentifier }, function(result)
        local jobMenuData = {}
        local charJobInfo = {}
        if result[1] then
            for _, v in pairs(result) do
                charJobInfo[tostring(v.jobid)] = {
                    level = v.level,
                    active = v.active
                }
            end
        end

        for _, v in pairs(JobList) do
            local menuItemLabel
            if charJobInfo[tostring(v.id)] then
                if charJobInfo[tostring(v.id)].active then
                    menuItemLabel = string.format("%s (Active)", v.name)
                else
                    menuItemLabel = string.format("%s (Level: %s)", v.name, charJobInfo[tostring(v.id)].level)
                end
            else
                menuItemLabel = v.name
            end

            table.insert(jobMenuData, {
                label = menuItemLabel,
                value = v.id,
                desc = v.description,
                job_name = v.name,
            })
        end
        TriggerClientEvent("mwg_jobsystem:openJobsMenu", _source, jobMenuData)
    end)
end)

RegisterServerEvent("mwg_jobsystem:modifyJobExperience", function(jobid, level, totalxp, xp, addxp)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter
    local CharIdentifier = Character.charIdentifier
    local Identifier = Character.identifier

    SetXp(Identifier, CharIdentifier, jobid, level, totalxp, xp, addxp, function(newTotalXp, newLevel, xploss)
        -- Update UI
        TriggerEvent("mwg_jobsystem:getJobDetails", "mwg_jobsystem:returnClientData", _source)

        if newLevel > level then
            local maxLevelEvent = JobList[tostring(jobid)].maxLevelEvent
            if JobLevels[newLevel + 1] == nil and maxLevelEvent then
                TriggerClientEvent(maxLevelEvent, _source)
            end

            local levelUpEvent = JobList[tostring(jobid)].levelUpEvent
            if levelUpEvent then
                TriggerClientEvent(levelUpEvent, _source, newLevel)
            end
            -- Triggers Notification and UI Update
            TriggerClientEvent("mwg_jobsystem:levelup", _source, newLevel)
            -- TriggerEvent("vorp:setjob", _source, Character.job, newLevel)
            UpdateVORPCharacter(Character.identifier, Character.charIdentifier, Character.job, newLevel)
        end

        if addxp then
            VorpCore.NotifyRightTip(_source, _U("ExpGain") .. xp, 4000)
        else
            VorpCore.NotifyRightTip(_source, _U("ExpLoss") .. xploss, 4000)
        end

        local expGainEvent = JobList[tostring(jobid)].expGainEvent
        if expGainEvent and addxp then
            TriggerClientEvent(expGainEvent, _source, xp, newTotalXp, newLevel)
        end

        local expLossEvent = JobList[tostring(jobid)].expLossEvent
        if expLossEvent and not addxp then
            TriggerClientEvent(expLossEvent, _source, xp, newTotalXp, xploss, newLevel)
        end
    end)
end)

RegisterServerEvent("mwg_jobsystem:onduty", function(jobid)
    local _source = source
    local onDutyEvent = JobList[tostring(jobid)].onDutyEvent
    if onDutyEvent then
        TriggerClientEvent(onDutyEvent, _source)
    end
end)

RegisterServerEvent("mwg_jobsystem:offduty", function(jobid)
    local _source = source
    local offDutyEvent = JobList[tostring(jobid)].offDutyEvent
    if offDutyEvent then
        TriggerClientEvent(offDutyEvent, _source)
    end
end)
