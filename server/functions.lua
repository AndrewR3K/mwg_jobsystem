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
    local TotalXp = totalxp
    if add then
        TotalXp = TotalXp + xp
    else
        TotalXp = TotalXp - xp
    end

    if TotalXp < JobLevels[level].minxp then
        TotalXp = JobLevels[level].minxp
    end

    exports.oxmysql:query("UPDATE character_jobs SET totalxp = ? WHERE identifier = ? and charid = ? and jobid = ?;",
        { TotalXp, identifier, charIdentifier, jobid }, function(result)
        if result.affectedRows == 1 then
            cb(true, TotalXp)
        end
    end)
end
