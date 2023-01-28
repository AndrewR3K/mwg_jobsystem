AddEventHandler('getMWGJobSystem', function(cb)
    local jobsystemData = {}

    jobsystemData.registerJob = function(name, desc)
        CreateThread(function()
            if name == nil or desc == nil then return nil end

            local result = MySQL.query.await("SELECT `id` FROM `js_jobs` WHERE `name`=? LIMIT 1;", { name })

            if result[1] == nil then
                exports.oxmysql:query("INSERT INTO `js_jobs` (`name`,`description`) VALUES (?, ?);"
                    , { name, desc }, function(result)
                    JobInfo = {
                        id = result.insertId,
                        name = name,
                        description = desc,
                    }
                    JobList[tostring(result.insertId)] = JobInfo
                end)
            end
        end)
    end

    jobsystemData.getJobInfo = function(source, cb)
        if source == nil then return nil end
        GetCharJobDetails(source, function(jobDetails)
            cb(jobDetails)
        end)
    end

    cb(jobsystemData)
end)
