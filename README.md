# Job System

#### Description
This is a job system for VORP that provides a simple way to register various jobs and provides an XP system that job creators can use to grant various perks for working the job. This was an idea given to me by some of my community since we aren't hardcore RPers we wanted to have perks based on jobs that can be done with no other players in the server. This can however be adapted to be used by those more extreme servers however it does allow the user to swap jobs on the fly.


#### FEATURES
- Configurable Job Centers with a cool 1899 inspired UI
- Close Job Centers by a time (configurable in Config.lua see below)
    - When Job Centers are closed the blips are removed
    - Red prompt saying CLOSED and hours of operation are displayed
- Configurable job menu open to all users (Only available while Off-Duty)
    - Menu: Tip notification to say why you can't open
    - Job Centers: Prompt shows RED message stating your on duty
- Configurable delay between job changes
    - Menu: Tip shows message with time left until you can change jobs
    - Job Centers: Red prompt stating You must wait xx Minutes
- Each job that gets registered has its own level system
    - By default levels are capped at 50. The UI supports up to 3 digit levels. (MAX: 999)
- Various events/functions that can be used in the job creators scripts
    - See below for a list of events and how to register them in the sample job.
- Nice notifications for when XP is gained (XP Gain and Loss to be configured by job creator)
    - Level up Notifications are displayed on the top of the screen.
- Utilizes Vorp Core notifications for level ups and xp gain
- Custom UI to display current job and progression.
    - Displayed at the top center of the screen.
    - Removed when in Job Center UI
    - Removed when Level up Display is shown
- Added support for VORP Crafting job locks
    - Sets the job in the characters table for VORP
    - Allows the use of Character.job and Character.jobgrade in your scripts

#### To Do
- Add Boss System
    - Configurable Job Applications
    - UI to see pending job applications
    - Hire/Reject on the spot
    - Message System - Employer to Candidate to schedule an interview or discuss further. Access via Job Center.
- Message Board API - Create an example of this system in my sample job which sends the messages over to Job System for storage based on jobs. Possibly lock down by location. (Blacksmith at Valentine vs Blacksmith at Blackwater)
- Payment System API
    - Payment to individual employees handled by the job creator
    - Individual ledgers per job


#### Configuration
Check the Config.lua file for Job Center locations. You can add additional job centers in directly in the config. I have them named to easily know which one you're working on however the key is not used for anything in the script and can be anything.
```lua
    defaultlang = "en_lang",
    jobChangeDelay = 10, -- Time in minutes between job changes. 0 disables this
    useJobCenters = true, -- True to use the new job centers. False to use the original menus
    JobCenters = {
        blackwater = {
            enabled = true, -- Job Center Enabled
            blip_name = "Blackwater Job Center", -- Name of the blip
            create_blip = true, -- Create a blip or not
            blip_hash = 587827268, -- Which blip to use (This is a newspaper looking one)
            prompt_name = "blackwater job center", -- Name on the prompt
            use_hours = true, -- True closes and opens the job centers. (Times defined below)
            open_hour = 7, -- 7am
            close_hour = 21, -- 9pm
            x = -873.091064453125, -- Coordinates for the job center
            y = -1334.35595703125, -- Coordinates for the job center
            z = 43.9649658203125 -- Coordinates for the job center
        }
    }
```

#### INSTALATION
- run the included SQL file `db.sql`.
- add `ensure mwg_jobsystem` to your `resources.cfg`.
- restart server, enjoy.
- Note: All of your job scripts must be ensured after this one.

#### Sample Job
*Updated 9/18/2022*
The [MWG Test Job](https://github.com/DavFount/mwg_testjob) is to serve as an example on how to work with the Job System.

#### For Job Creators
##### Events
All events have the job name passed to the client. This will allow you to easily check which job the event was triggered for. 
- **On Duty:** Add an event listener client side in your job to catch all On-Duty events. Make sure to check the players job before doing anything.
- **Off Duty:** Add an event listener client side in your job to catch all Off-Duty events. Make sure to check the players job before doing anything.
- **Job Expierence Gained:** Add an event listener if you'd like to catch any time a player gains Job Experience. Be sure to check the playres job.
- **Job Expierence Lost:** Add an event listener if you'd like to catch any time a player losses Job Experience.  Be sure to check the players job.
- **Level Up:** Add an event listener to catch level up events. Make sure to check the players job.
- **Max Level:** This event is triggered when there are no more levels left. Add an event listener to catch this event. Be sure to check the players job.

##### API
###### Server Side - 
```lua
local JobSystem = {}
TriggerEvent("getMWGJobSystem", function(jobsystem)
    JobSystem = jobsystem
end)

-- Keep the description short. The UI does scroll in the Job Center but it should be brief.
JobSystem.registerJob(JobName, JobDescription)

JobSystem.getJobInfo(source) -- Source should be the players ID
--[[
jobName
jobID
totalXp
level
nextLevel
nextLevelXp
currentLevelMinXp
]]
```

###### Client Side -
```lua
local JobSystem = {}
TriggerEvent("getMWGJobSystem", function(jobsystem)
    JobSystem = jobsystem
end)

local jobDetails = JobSystem.getJobInfo(source)
--[[
jobName
jobID
totalXp
level
nextLevel
nextLevelXp
currentLevelMinXp
]]

local OnDuty = JobSystem.isOnDuty -- True or False if user is on duty.
```

#### Screen Shots
**Menu + UI:**
![Screenshot1](https://github.com/DavFount/mwg_jobsystem/blob/master/Screenshots/UI_Menu.jpg?raw=true)
**UI With XP:**
![Screenshot2](https://github.com/DavFount/mwg_jobsystem/blob/master/Screenshots/UI_With_XP.jpg?raw=true)
**Max Level UI:**
![Screenshot3](https://github.com/DavFount/mwg_jobsystem/blob/master/Screenshots/MaxLevel.jpg?raw=true)
**Level Up Notification:**
![Screenshot4](https://github.com/DavFount/mwg_jobsystem/blob/master/Screenshots/LevelUp.jpg?raw=true)
**New Job Center UI:** Scrollable with hidden scroll bar.
![Screenshot5]()
![Screenshot6]()
**On Duty Check:**
![Screenshot7]()
**After Hours:**
![Screenshot8]()
#### DEPENDENCIES
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [menuapi](https://github.com/outsider31000/menuapi)


#### SUPPORT
Feel free to create an issue if you need assitance or have issues. You can ask for support in the vorp discord under public-script-support. I give you permission to tag me for support of any MwG script only.

#### Credits
- The entire Vorp Dev Team
- Vorp Stores for prompt and hours checks