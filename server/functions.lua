JobList = {}
JobLevels = {}

local VorpCore = {}
TriggerEvent("getCore", function(core)
    VorpCore = core
end)

function GetAllJobs()
    exports.oxmysql:query("SELECT * FROM jobs ORDER BY `name` ASC;",
        function(result)
            if result then
                for _, job in ipairs(result) do
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
    exports.oxmysql:query("SELECT * from job_levels ORDER BY `level` ASC;", function(result)
        if result then
            for _, level in ipairs(result) do
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

function GetCharJobDetails(source, cb)
    if source == nil then return nil end

    local User = VorpCore.getUser(source)
    local Character = User.getUsedCharacter

    exports.oxmysql:query("SELECT `character_jobs`.`jobid`, `character_jobs`.`totalxp`, `character_jobs`.`level`, `jobs`.`name` FROM `character_jobs` INNER JOIN `jobs` ON `character_jobs`.jobid=`jobs`.id WHERE `identifier`=? and `charid`=? and `active`=1 LIMIT 1;"
        , { Character.identifier, Character.charIdentifier }, function(result)
        if result[1] then
            local nextLevel, nextLevelXp
            if JobLevels[result[1].level + 1] ~= nil then
                nextLevel = JobLevels[result[1].level + 1].level
                nextLevelXp = JobLevels[result[1].level + 1].minxp
            else
                nextLevel = result[1].level
                nextLevelXp = JobLevels[result[1].level].minxp
            end
            local CharJobDetails = {
                jobName = result[1].name,
                jobID = result[1].jobid,
                totalXp = result[1].totalxp,
                level = result[1].level,
                nextLevel = nextLevel,
                nextLevelXp = nextLevelXp,
                currentLevelMinXp = JobLevels[result[1].level].minxp
            }
            cb(CharJobDetails)
        else
            cb(nil)
        end
    end)
end

function UpdateVORPCharacter(id, charid, job, grade)
    exports.oxmysql:query("UPDATE `characters` SET job=?, jobgrade=? WHERE `identifier`=? AND `charidentifier`=?",
        { job, grade, id, charid }, function(result)
        if result.affectedRows < 1 then
            print(string.format("Unable to update job info for %s.", id))
        end
    end)

end
