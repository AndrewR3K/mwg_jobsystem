# Job System

#### Description
This is a job system for VORP that provides a simple way to register various jobs and provides an XP system that job creators can use to grant various perks for working the job. This was an idea given to me by some of my community since we aren't hardcore RPers we wanted to have perks based on jobs that can be done with no other players in the server. This can however be adapted to be used by those more extreme servers however it does allow the user to swap jobs on the fly.


#### FEATURES
- Configurable job menu open to all users (Only available while Off-Duty)
- Each job that gets registered has its own level system
- Various events/functions that can be used from the job creators to check levels
- Nice notifications for when XP is gained (xp gain is set by the job creator)
- Utilizes Vorp Core notifications for level ups and xp gain
- Registering your job requires an on and off duty event on your job script so when someone goes on or off duty it updates your script
- Custom UI to display current job and progression.

#### Configuration
```lua
    defaultlang = "en_lang",

    -- To change the key used to open the menu. Reference the KEYS table in the config file and change the value on line one of the client.lua file.
```

#### INSTALATION
- run the included SQL file `db.sql`.
- add `ensure mwg_jobsystem` to your `resources.cfg`.
- restart server, enjoy.
- Note: All of your job scripts must be ensured after this one.

#### Sample Job
The [MWG Test Job](https://github.com/DavFount/mwg_testjob) is to serve as an example on how to work with the Job System.

#### Screen Shots
**Menu + UI:**
![Screenshot1](https://github.com/DavFount/mwg_jobsystem/blob/master/Screenshots/UI_Menu.jpg?raw=true)
**UI With XP:**
![Screenshot2](https://github.com/DavFount/mwg_jobsystem/blob/master/Screenshots/UI_With_XP.jpg?raw=true)
**Max Level UI:**
![Screenshot3](https://github.com/DavFount/mwg_jobsystem/blob/master/Screenshots/MaxLevel.jpg?raw=true)
**Level Up Notification:**
![Screenshot4](https://github.com/DavFount/mwg_jobsystem/blob/master/Screenshots/LevelUp.jpg?raw=true)
#### DEPENDENCIES
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [menuapi](https://github.com/outsider31000/menuapi)


#### SUPPORT
Feel free to create an issue if you need assitance or have issues. You can also visit my [official support discord](https://discord.gg/BSmJQbtBQ8).

#### Credits
- The entire Vorp Dev Team