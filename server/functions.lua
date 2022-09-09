-- Called once on server start to get all jobs. New Jobs registered after will be added to the table.
function GetAllJobs(cb)
    exports.oxmysql:query("SELECT `name`, `description`, `id` FROM jobs ORDER BY `name` ASC;",
        function(result)
            if result then
                cb(result)
            end
        end)
end

-- Called once on server start to get all levels. (Adding levels requires restart of script or server)
function GetAllLevels(cb)
    exports.oxmysql:query("SELECT * from job_levels ORDER BY `level` ASC;", function(result)
        if result then
            cb(result)
        end
    end)
end

-- Identifier, CharIdentifier, jobid, level, totalxp, xp
function SetXp(identifier, charIdentifier, jobid, level, totalxp, xp, add, cb)

    local _totalxp = totalxp
    local xploss
    if add then
        _totalxp = _totalxp + xp
    else
        _totalxp = _totalxp - xp
        if _totalxp < JobLevels[level].minxp then
            _totalxp = JobLevels[level].minxp
        end
        xploss = totalxp - _totalxp
    end

    local _level = level
    for _, v in ipairs(JobLevels) do
        if _totalxp >= v.minxp and v.level > level then
            _level = v.level
        end
    end

    exports.oxmysql:query("UPDATE character_jobs SET `totalxp` = ?, `level` = ? WHERE identifier = ? and charid = ? and jobid = ?;"
        , { _totalxp, _level, identifier, charIdentifier, jobid }, function(result)
        if result.affectedRows == 1 then
            cb(_totalxp, _level, xploss)
        end
    end)
end
