local VorpCore = {}
TriggerEvent("getCore", function(core)
    VorpCore = core
end)

RegisterServerEvent("mwg_jobsystem:registerJob",
    function(jobName, description, onDutyEvent, offDutyEvent, expGainEvent, expLossEvent, levelUpEvent)
        exports.oxmysql:query("SELECT name FROM jobs WHERE name = ?", { jobName },
            function(result)
                -- Check if job does not exists in table
                if not result[1] then
                    -- Create job in table
                    exports.oxmysql:query("INSERT INTO jobs (`name`, `description`, `onDutyEvent`, `offDutyEvent`, `expGainEvent`, `expLossEvent`, `levelUpEvent`) VALUES (?, ?, ?, ?, ?, ?, ?);"
                        , { jobName, description, onDutyEvent, offDutyEvent, expGainEvent, expLossEvent, levelUpEvent },
                        function(result)
                            JobInfo = {
                                id = result.insertId,
                                name = jobName,
                                description = description,
                                onDutyEvent = onDutyEvent,
                                offDutyEvent = offDutyEvent,
                                expGainEvent = expGainEvent,
                                expLossEvent = expLossEvent,
                                levelUpEvent = levelUpEvent
                            }
                            JobList[tostring(result.insertId)] = JobInfo
                        end)
                end
            end)
    end)

RegisterServerEvent("mwg_jobsystem:setJob", function(source, jobid)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter


    exports.oxmysql:query("UPDATE character_jobs SET active=0 WHERE identifier=? and charid=?; ",
        { Character.identifier, Character.charIdentifier }, function(_)
        exports.oxmysql:query("UPDATE character_jobs SET active=1 WHERE identifier = ? and charid = ? and jobid = ?;",
            { Character.identifier, Character.charIdentifier, jobid }, function(_)

            TriggerEvent("mwg_jobsystem:updateClientInfo", _source, jobid)
        end)
    end)
end)

-- Called from server to update UI Info
RegisterServerEvent("mwg_jobsystem:updateClientInfo", function(source, jobid)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter

    exports.oxmysql:query("SELECT `character_jobs`.`jobid`, `character_jobs`.`totalxp`, `character_jobs`.`level`, `jobs`.`name` FROM `character_jobs` INNER JOIN `jobs` ON `character_jobs`.jobid=`jobs`.id WHERE `identifier`=? and `charid`=? and `jobid`=? LIMIT 1;"
        , { Character.identifier, Character.charIdentifier, jobid }, function(result)

        if result[1] then
            local CharJobDetails = {
                jobName = result[1].name,
                jobID = result[1].jobid,
                totalXp = result[1].totalxp,
                level = result[1].level,
                nextLevel = JobLevels[result[1].level + 1].level,
                nextLevelXp = JobLevels[result[1].level + 1].minxp
            }

            TriggerClientEvent("mwg_jobsystem:returnClientData", _source, CharJobDetails)
        end
    end)
end)

-- Called from client to get job UI Info
RegisterServerEvent("mwg_jobsystem:loadClientData", function()
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter

    exports.oxmysql:query("SELECT `character_jobs`.`jobid`, `character_jobs`.`totalxp`, `character_jobs`.`level`, `jobs`.`name` FROM `character_jobs` INNER JOIN `jobs` ON `character_jobs`.jobid=`jobs`.id WHERE `identifier`=? and `charid`=? and `active`=1 LIMIT 1;"
        , { Character.identifier, Character.charIdentifier }, function(result)
        if result[1] then
            local CharJobDetails = {
                jobName = result[1].name,
                jobID = result[1].jobid,
                totalXp = result[1].totalxp,
                level = result[1].level,
                nextLevel = JobLevels[result[1].level + 1].level,
                nextLevelXp = JobLevels[result[1].level + 1].minxp
            }
            TriggerClientEvent("mwg_jobsystem:returnClientData", _source, CharJobDetails)
        end
    end)
end)


RegisterServerEvent("mwg_jobsystem:selectJob", function(newjob, newjobid)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter

    exports.oxmysql:query("SELECT * FROM character_jobs WHERE identifier = ? and charid = ? and jobid = ?"
        , { Character.identifier, Character.charIdentifier, newjobid },
        function(result)
            if result[1] then
                TriggerEvent("mwg_jobsystem:setJob", _source, newjobid)
                VorpCore.NotifyRightTip(_source, _U("jobgiven") .. newjob, 5000)
                Wait(500)
                VorpCore.NotifyRightTip(_source, _U("gradegiven") .. result[1].level, 5000)
            else
                exports.oxmysql:query("INSERT INTO character_jobs (`identifier`, `charid`, `jobid`, `totalxp`, `level`, `active`) VALUES (?, ?, ?, 0, 1, 1);"
                    , { Character.identifier, Character.charIdentifier, newjobid }, function(_)
                    TriggerEvent("mwg_jobsystem:setJob", _source, newjobid)
                    VorpCore.NotifyRightTip(_source, _U("jobgiven") .. newjob, 5000)
                    Wait(500)
                    VorpCore.NotifyRightTip(_source, _U("gradegiven") .. 1, 5000)
                end)
            end
        end)
end)

RegisterServerEvent("mwg_jobsystem:getJobs", function(cb)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter

    exports.oxmysql:query("SELECT * from character_jobs WHERE identifier = ? and charid = ?;"
        , { Character.identifier, Character.charIdentifier }, function(result)
        local jobMenuData = {}
        local charJobLevels = {}
        if result[1] then
            for _, v in pairs(result) do
                charJobLevels[tostring(v.jobid)] = v.level
            end
        end

        for _, v in pairs(JobList) do
            local menuItemLabel
            if charJobLevels[tostring(v.id)] then
                menuItemLabel = string.format("%s (Level: %s)", v.name, charJobLevels[tostring(v.id)])
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
        TriggerEvent("mwg_jobsystem:updateClientInfo", _source, jobid)

        if newLevel > level then
            if JobList[jobid].levelUpEvent then
                TriggerClientEvent(JobList[jobid].levelUpEvent)
            end
            TriggerClientEvent("mwg_jobsystem:levelup", _source, newLevel)
        end

        if addxp then
            VorpCore.NotifyRightTip(_source, _U("ExpGain") .. xp, 4000)
        else
            VorpCore.NotifyRightTip(_source, _U("ExpLoss") .. xploss, 4000)
        end

        if JobList[jobid].expGainEvent and addxp then
            TriggerClientEvent(JobList[jobid].expGainEvent, _source, xp, newTotalXp, newLevel)
        end

        if JobList[jobid].expLossEvent and not addxp then
            TriggerClientEvent(JobList[jobid].expLossEvent, _source, xp, newTotalXp, xploss, newLevel)
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
    local offDutyEvent = JobList[tostring(jobid)].onDutyEvent
    if offDutyEvent then
        TriggerClientEvent(offDutyEvent, _source)
    end
end)
