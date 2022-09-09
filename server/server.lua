JobList = {}
JobLevels = {}

GetAllJobs(function(jobs)
    for _, v in ipairs(jobs) do
        JobInfo = {
            id = v.id,
            name = v.name,
            description = v.description,
            onDutyEvent = v.onDutyEvent,
            offDutyEvent = v.offDutyEvent,
            expGainEvent = v.expGainEvent,
            expLossEvent = v.expLossEvent,
            levelUpEvent = v.levelUpEvent
        }
        JobList[v.id] = JobInfo
    end
end)

GetAllLevels(function(levels)
    for _, v in ipairs(levels) do
        LevelInfo = {
            level = v.level,
            minxp = v.minxp
        }
        JobLevels[v.level] = LevelInfo
    end
end)
