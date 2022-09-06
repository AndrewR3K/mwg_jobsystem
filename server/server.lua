local JobsList = {}

GetAllJobs(function(result)
    JobsList = result
    if JobsList ~= nil then
        print(JobsList[1].name)
    else
        print('No jobs found!')
    end
end)
