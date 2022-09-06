function GetAllJobs(cb)
    exports.oxmysql:query("SELECT `name`, `description`, `id` FROM jobs ORDER BY `name` ASC;",
        function(result)
            if result then
                cb(result)
            else
                cb(nil)
            end
        end)
end

function GetJob(jobName, cb)
    exports.oxmysql:query("SELECT id from jobs WHERE `name` = ? LIMIT 1;"
        , { jobName },
        function(result)
            if result[1] then
                cb(result[1].id)
            else
                local format = string.format("[SQL Error] Unable to find a job by the name %s", jobName)
                error(format)
            end
        end)
end

function SetJob(identifier, charIdentifier, jobid, cb)
    exports.oxmysql:query("INSERT INTO character_jobs (`identifier`, `charid`, `jobid`, `totalxp`) VALUES (?, ?, ?, 0);"
        , { identifier, charIdentifier, jobid })

    cb()
end

function GetLevelByXP(xp, cb)
    exports.oxmysql:query("SELECT level from job_levels WHERE `minxp` <= ? ORDER BY `level` DESC LIMIT 1;",
        { xp },
        function(result)
            if result[1] then
                cb(result[1].level)
            else
                local format = string.format("Unable to find a level with %s xp.", xp)
                error(format)
            end
        end)
end

function GetLevelByID(id, cb)
    exports.oxmysql:query("SELECT * from job_levels WHERE `level` = ? ORDER BY `level` DESC LIMIT 1;",
        { id },
        function(result)
            if result[1] then
                cb(result[1])
            else
                local format = string.format("Unable to find a level with the id of %s.", id)
                error(format)
            end
        end)
end

function GetXp(jobName, identifier, charIdentifier, cb)
    GetJob(jobName, function(jobid)
        exports.oxmysql:query("SELECT totalxp FROM character_jobs WHERE identifier = ? and charid = ? and jobid = ? LIMIT 1;"
            , { identifier, charIdentifier, jobid },
            function(result)
                if result[1] then
                    cb(jobid, result[1].totalxp)
                else
                    local format = string.format("SELECT totalxp FROM character_jobs WHERE identifier = %s and charid = %s and jobid = %s LIMIT 1;"
                        , identifier, charIdentifier, jobid)
                    error(format)
                end
            end)
    end)
end

function SetXp(jobName, identifier, charIdentifier, newXp, level, add, cb)
    GetXp(jobName, identifier, charIdentifier, function(jobid, oldXp)
        if add then
            TotalXp = oldXp + newXp
        else
            TotalXp = oldXp - newXp
        end

        GetLevelByID(level, function(result)
            if result then
                if TotalXp < result.minxp then
                    TotalXp = result.minxp
                end
                exports.oxmysql:query('UPDATE character_jobs SET totalxp = ? WHERE identifier = ? and charid = ? and jobid = ?;'
                    , { TotalXp, identifier, charIdentifier, jobid }, function(result)
                    if result.affectedRows == 1 then
                        cb(true, TotalXp)
                    else
                        local format = string.format('[SQL Error] UPDATE character_jobs SET totalxp = %s WHERE identifier = "%s" and charid = %s and jobid = %s;'
                            , newXp, identifier, charIdentifier, jobid)
                        error(format)
                    end
                end)
            end
        end)
    end)
end

function LevelCheck(currentLevel, totalXp, cb)
    local newLevel
    GetLevelByXP(totalXp, function(level)
        newLevel = level
        if newLevel > currentLevel then
            cb(newLevel)
        else
            cb(nil)
        end
    end)
end

function GetCharacterJob(identifier, cb)
    exports.oxmysql:query("SELECT job, jobgrade FROM characters WHERE `identifier` = ?;", { identifier },
        function(result)
            if result[1] then
                cb(result[1].job, result[1].jobgrade)
            end
        end)
end
