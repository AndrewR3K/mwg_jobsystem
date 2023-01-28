local VorpCore = {}
TriggerEvent("getCore", function(core)
    VorpCore = core
end)

AddEventHandler("mwg_jobsystem:setJob", function(source, jobid)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter

    CreateThread(function()
        -- Clear active job if there is one
        MySQL.query.await("UPDATE js_character_jobs SET active=0 WHERE identifier=? and charid=?; ",
            { Character.identifier, Character.charIdentifier })

        -- Set new Job
        MySQL.query.await("UPDATE js_character_jobs SET active=1 WHERE identifier = ? and charid = ? and jobid = ?;"
            , { Character.identifier, Character.charIdentifier, jobid })

        TriggerEvent("mwg_jobsystem:getJobDetails", "mwg_jobsystem:returnClientData", _source)
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

    CreateThread(function()
        TriggerClientEvent("mwg_jobsystem:setLastJobChange", _source)

        local results = MySQL.query.await("SELECT * FROM js_character_jobs WHERE identifier = ? and charid = ? and jobid = ?"
            , { Character.identifier, Character.charIdentifier, newjobid })

        if results[1] then
            -- Set Job to active in MwG Job System
            TriggerEvent("mwg_jobsystem:setJob", _source, newjobid)
            -- Set Job with VORP (Updates Character.job)
            TriggerEvent("vorp:setJob", _source, string.lower(newjob), results[1].level)
            -- vorp_crafting support for job locks
            TriggerClientEvent("vorp:setjob", _source, string.lower(newjob))
            VorpCore.NotifyRightTip(_source, _U("jobgiven") .. newjob, 5000)
            Wait(500)
            VorpCore.NotifyRightTip(_source, _U("gradegiven") .. results[1].level, 5000)
        else
            -- Create entry in character_jobs table
            MySQL.query.await("INSERT INTO js_character_jobs (`identifier`, `charid`, `jobid`, `totalxp`, `level`, `active`) VALUES (?, ?, ?, 0, 1, 1);"
                , { Character.identifier, Character.charIdentifier, newjobid })

            TriggerEvent("mwg_jobsystem:setJob", _source, newjobid)
            -- vorp_crafting support for job locks
            TriggerEvent("vorp:setJob", _source, string.lower(newjob), 1)
            TriggerClientEvent("vorp:setjob", _source, string.lower(newjob))
            VorpCore.NotifyRightTip(_source, _U("jobgiven") .. newjob, 5000)
            Wait(500)
            VorpCore.NotifyRightTip(_source, _U("gradegiven") .. 1, 5000)
        end
    end)
end)

RegisterServerEvent("mwg_jobsystem:quitJob", function(jobid)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter

    CreateThread(function()
        local result = MySQL.query.await("UPDATE js_character_jobs SET active=0 WHERE identifier = ? and charid = ? and jobid = ?;"
            , { Character.identifier, Character.charIdentifier, jobid })

        if result.affectedRows > 0 then
            -- Update Client Info
            TriggerEvent("mwg_jobsystem:getJobDetails", "mwg_jobsystem:returnClientData", _source)
            -- Set Job with VORP (Updates Character.job)
            TriggerEvent("vorp:setJob", _source, "", 0)
            -- vorp_crafting support for job locks
            TriggerClientEvent("vorp:setjob", _source, "")
            VorpCore.NotifyRightTip(_source, _U("jobremoved"), 5000)
        end
    end)
end)

RegisterServerEvent("mwg_jobsystem:getJobs", function(callback)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter
    local jobData = {}
    local charJobInfo = {}
    local JobActive = false
    local level = 0

    CreateThread(function()
        local results = MySQL.query.await("SELECT jobid, level, active FROM js_character_jobs WHERE identifier = ? and charid = ?;"
            , { Character.identifier, Character.charIdentifier })

        if results[1] then
            for _, v in pairs(results) do
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
                    JobActive = true
                else
                    menuItemLabel = string.format("%s (Level: %s)", v.name, charJobInfo[tostring(v.id)].level)
                    level = charJobInfo[tostring(v.id)].level
                    JobActive = false
                end
            else
                menuItemLabel = v.name
                JobActive = false
            end

            table.insert(jobData, {
                label = menuItemLabel,
                value = v.id,
                desc = v.description,
                job_name = v.name,
                active = JobActive,
                level = level
            })
        end

        TriggerClientEvent(callback, _source, jobData)

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
            if JobLevels[newLevel + 1] == nil then
                TriggerClientEvent("mwg_jobsystem:maxLevelEvent", _source)
            end

            TriggerClientEvent("mwg_jobsystem:levelUpEvent", _source, newLevel)
            TriggerEvent("vorp:setJob", _source, string.lower(Character.job), newLevel)
        end

        if addxp then
            TriggerClientEvent("mwg_jobsystem:ExpGainEvent", _source, xp, newTotalXp, newLevel)
            VorpCore.NotifyRightTip(_source, _U("ExpGain") .. xp, 4000)
        else
            TriggerClientEvent("mwg_jobsystem:ExpLossEvent", _source, xp, newTotalXp, newLevel)
            VorpCore.NotifyRightTip(_source, _U("ExpLoss") .. xploss, 4000)
        end
    end)
end)
