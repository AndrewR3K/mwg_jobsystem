AddEventHandler('getMWGJobSystem', function(cb)
    local jobsystemData = {}

    jobsystemData.registerJob = function(name, desc, onDuty, offDuty, expGain, expLoss, levelUp, maxLevel)
        if name == nil or desc == nil then return nil end

        exports.oxmysql:query("SELECT `id` FROM `jobs` WHERE `name`=? LIMIT 1;", { name }, function(result)
            if result[1] == nil then
                exports.oxmysql:query("INSERT INTO `jobs` (`name`,`description`,`onDutyEvent`,`offDutyEvent`,`expGainEvent`,`expLossEvent`,`levelUpEvent`,`maxLevelEvent`) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
                    , { name, desc, onDuty, offDuty, expGain, expLoss, levelUp, maxLevel }, function(result)
                    JobInfo = {
                        id = result.insertId,
                        name = name,
                        description = desc,
                        onDutyEvent = onDuty,
                        offDutyEvent = offDuty,
                        expGainEvent = expGain,
                        expLossEvent = expLoss,
                        levelUpEvent = levelUp,
                        maxLevelEvent = maxLevel
                    }
                    JobList[tostring(result.insertId)] = JobInfo
                end)
            else
                -- Job Found Update Events
                exports.oxmysql:query("UPDATE `jobs` SET `onDutyEvent`=?,`offDutyEvent`=?,`expGainEvent`=?,`expLossEvent`=?,`levelUpEvent`=?, `maxLevelEvent`=? WHERE `name`=?;"
                    , { onDuty, offDuty, expGain, expLoss, levelUp, maxLevel, name }, function(result)
                    if result.changedRows == 1 then
                        GetAllJobs()
                    end
                end)
            end
        end)
    end

    jobsystemData.getJobInfo = function(source)
        if source == nil then return nil end
        GetCharJobDetails(source, function(jobDetails)
            return jobDetails
        end)
    end

    cb(jobsystemData)
end)
