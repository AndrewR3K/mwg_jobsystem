local VorpCore = {}
TriggerEvent("getCore", function(core)
    VorpCore = core
end)

RegisterServerEvent("mwg_jobsystem:setJob", function(newjob, newjobid)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter
    local Parameters = {
        ['identifier'] = Character.identifier,
        ['charid'] = Character.charIdentifier,
        ['jobid'] = newjobid,
    }

    exports.oxmysql:query("SELECT totalxp FROM character_jobs WHERE identifier = ? and charid = ? and jobid = ?"
        , { Character.identifier, Character.charIdentifier, newjobid },
        function(result)
            if result[1] then
                GetLevelByXP(result[1].totalxp, function(level)
                    TriggerEvent("vorp:setJob", _source, newjob, level)
                    VorpCore.NotifyRightTip(_source, _U("jobgiven") .. newjob, 5000)
                    Wait(500)
                    VorpCore.NotifyRightTip(_source, _U("gradegiven") .. level, 5000)
                end)
            else
                SetJob(Character.identifier, Character.charIdentifier, newjobid, function()
                    TriggerEvent("vorp:setJob", _source, newjob, 1)
                    VorpCore.NotifyRightTip(_source, _U("jobgiven") .. newjob, 5000)
                    Wait(500)
                    VorpCore.NotifyRightTip(_source, _U("gradegiven") .. 1, 5000)
                end)
            end
        end)
end)

RegisterServerEvent("mwg_jobsystem:registerJob", function(jobName, description, onDutyEvent, offDutyEvent)
    exports.oxmysql:query("SELECT name FROM jobs WHERE name = ?", { jobName },
        function(result)
            -- Check if job does not exists in table
            if not result[1] then
                -- Create job in table
                exports.oxmysql:query("INSERT INTO jobs (`name`, `description`, `onDutyEvent`, `offDutyEvent`) VALUES (?, ?, ?, ?);"
                    , { jobName, description, onDutyEvent, offDutyEvent })
            end
        end)
end)

RegisterServerEvent("mwg_jobsystem:addJobExperience", function(experienceToAdd)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter
    local CharIdentifier = Character.charIdentifier
    local Identifier = Character.identifier

    GetCharacterJob(Identifier, function(JobName, Level)
        SetXp(JobName, Identifier, CharIdentifier, experienceToAdd, Level, true, function(success, totalXp)
            if (success) then
                LevelCheck(Level, totalXp, function(newLevel)
                    if (newLevel) then
                        TriggerEvent("vorp:setJob", _source, JobName, newLevel)
                        TriggerClientEvent("mwg_jobsystem:levelup", _source, newLevel, JobName)
                        VorpCore.NotifyRightTip(_source, _U("ExpGain") .. experienceToAdd, 4000)
                        -- Update UI XP Bar and level
                    else
                        VorpCore.NotifyRightTip(_source, _U("ExpGain") .. experienceToAdd, 4000)
                        -- Update UI XP Bar
                    end
                end)
            end
        end)
    end)
end)

RegisterServerEvent("mwg_jobsystem:removeJobExperience", function(experienceToRemove)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter
    local CharIdentifier = Character.charIdentifier
    local Identifier = Character.identifier

    GetCharacterJob(Identifier, function(JobName, Level)
        SetXp(JobName, Identifier, CharIdentifier, experienceToRemove, Level, false, function(success, totalXp)
            if (success) then
                VorpCore.NotifyRightTip(_source, _U("ExpLoss") .. experienceToRemove, 4000)
                -- Update UI XP & Level
            end
        end)
    end)
end)

-- For Testing Only
RegisterServerEvent("mwg_jobsystem:setLevel", function(jobLevel)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter
    local CharIdentifier = Character.charIdentifier
    local Identifier = Character.identifier

    GetCharacterJob(Identifier, function(JobName, jobLevel)
        SetXp(JobName, Identifier, CharIdentifier, 9999999, jobLevel, false, function(success, totalXp)
            if (success) then
                VorpCore.NotifyRightTip(_source, "Your level has been set.")
                -- Update UI XP & Level
            end
        end)
    end)
end)
-- For Testing Only

RegisterServerEvent("mwg_jobsystem:levelUp", function(ped)
    -- Get Current Job (target: ped)
    -- Find Player in Charater_Jobs table
    -- Get Current Level
    -- Upgrade Level
    -- Update UI
    -- Send Notification
end)

RegisterServerEvent("mwg_jobsystem:getJobs", function(cb)
    local _source = source
    GetAllJobs(function(result)
        if (cb == "jobsystem.openjobmenu") then
            local job_list = {}
            for k, v in ipairs(result) do -- Keep them in the proper order
                job_list[k] = {
                    label = v.name,
                    value = string.lower(v.name),
                    desc = v.description,
                    job_id = v.id,
                }
            end
            TriggerClientEvent("mwg_jobsystem:openJobsMenu", _source, job_list)
        end
    end)
end)

RegisterServerEvent("mwg_jobsystem:onduty", function()
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter
    exports.oxmysql:query("SELECT onDutyEvent FROM jobs WHERE name = ? LIMIT 1;", { Character.job }, function(result)
        if result then
            TriggerClientEvent(result[1].onDutyEvent, _source)
        end
    end)
end)

RegisterServerEvent("mwg_jobsystem:offduty", function()
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter
    exports.oxmysql:query("SELECT offDutyEvent FROM jobs WHERE name = ? LIMIT 1;", { Character.job }, function(result)
        if result then
            TriggerClientEvent(result[1].offDutyEvent, _source)
        end
    end)
end)
