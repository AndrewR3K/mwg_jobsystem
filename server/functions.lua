JobList = {}
JobLevels = {}

local VorpCore = {}
TriggerEvent("getCore", function(core)
    VorpCore = core
end)

function GetAllJobs()
    CreateThread(function()
        local results = MySQL.query.await('SELECT * FROM `js_jobs` ORDER BY `name` ASC;')
        if results then
            for _, job in pairs(results) do
                JobInfo = {
                    id = job.id,
                    name = job.name,
                    description = job.description,
                    onDutyEvent = job.onDutyEvent,
                    offDutyEvent = job.offDutyEvent,
                    expGainEvent = job.expGainEvent,
                    expLossEvent = job.expLossEvent,
                    levelUpEvent = job.levelUpEvent,
                    maxLevelEvent = job.maxLevelEvent
                }
                JobList[tostring(job.id)] = JobInfo
            end
        end
    end)
end

function GetAllLevels()
    CreateThread(function()
        local results = MySQL.query.await("SELECT * from js_job_levels ORDER BY `level` ASC;")
        if results then
            for _, level in ipairs(results) do
                LevelInfo = {
                    level = level.level,
                    minxp = level.minxp
                }
                JobLevels[level.level] = LevelInfo
            end
        end
    end)
end

-- Sets Job Experience. Detects Level up and prevents decreasing XP below minxp for characters current level.
function SetXp(identifier, charIdentifier, jobid, level, totalxp, xp, add, cb)
    CreateThread(function()
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

        local result = MySQL.query.await("UPDATE js_character_jobs SET `totalxp` = ?, `level` = ? WHERE identifier = ? and charid = ? and jobid = ?;"
            , { _totalxp, _level, identifier, charIdentifier, jobid })

        if result.affectedRows == 1 then
            cb(_totalxp, _level, xploss)
        end
    end)
end

function GetCharJobDetails(source, cb)
    CreateThread(function()
        if source == nil then return nil end

        local User = VorpCore.getUser(source)
        local Character = User.getUsedCharacter

        local results = MySQL.query.await("SELECT `js_character_jobs`.`jobid`, `js_character_jobs`.`totalxp`, `js_character_jobs`.`level`, `js_jobs`.`name` FROM `js_character_jobs` INNER JOIN `js_jobs` ON `js_character_jobs`.jobid=`js_jobs`.id WHERE `identifier`=? and `charid`=? and `active`=1 LIMIT 1;"
            , { Character.identifier, Character.charIdentifier })

        if results[1] then
            local nextLevel, nextLevelXp
            if JobLevels[results[1].level + 1] ~= nil then
                nextLevel = JobLevels[results[1].level + 1].level
                nextLevelXp = JobLevels[results[1].level + 1].minxp
            else
                nextLevel = results[1].level
                nextLevelXp = JobLevels[results[1].level].minxp
            end
            local CharJobDetails = {
                jobName = results[1].name,
                jobID = results[1].jobid,
                totalXp = results[1].totalxp,
                level = results[1].level,
                nextLevel = nextLevel,
                nextLevelXp = nextLevelXp,
                currentLevelMinXp = JobLevels[results[1].level].minxp
            }
            cb(CharJobDetails)
        else
            cb(nil)
        end
    end)
end
