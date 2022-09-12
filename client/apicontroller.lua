AddEventHandler('getMWGJobSystem', function(cb)
    local jobsystemData = {}

    jobsystemData.getJobInfo = function(source)
        if source == nil then return nil end
        return Job
    end

    jobsystemData.isOnDuty = function(source)
        if source == nil then return nil end
        return OnDuty
    end
    cb(jobsystemData)
end)
