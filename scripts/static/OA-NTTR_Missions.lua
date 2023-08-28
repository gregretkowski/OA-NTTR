env.info("Missions Loading", false)

function SEF_CSARMISSION(distance)

ZoneTable = { ZONE:New(distance)}

TemplateTable = { "CSARspawn"}

Spawn_Vehicle_1 = SPAWN:New( "CSARspawn" )
  :InitLimit( 1, 1 )
  :InitRandomizeTemplate( TemplateTable ) 
  :InitRandomizeZones( ZoneTable )
  :Spawn()
end

function SEF_CSARDESPAWN() -- Add Find & delete all groups starting with "Pilot" inside ZoneTable

DownedPilot=SET_GROUP:New():FilterPrefixes("Pilot"):FilterActive(true):FilterZones(ZoneTable):FilterOnce()

if (DownedPilot) then
   DownedPilot:ForEach(
      function (pilot)
         pilot:Destroy(true)
      end
   )
  end

end

CSARmiz = MENU_MISSION:New("Creech CSAR Missions", CASroot)
local CSARspawn = MENU_MISSION_COMMAND:New("Spawn Close CSAR Mission (5-15nm)", CSARmiz, SEF_CSARMISSION, "CSARclose")
local CSARspawn = MENU_MISSION_COMMAND:New("Spawn Medium CSAR Mission (15-50nm)", CSARmiz, SEF_CSARMISSION, "CSARmedium")
local CSARspawn = MENU_MISSION_COMMAND:New("Spawn Far CSAR Mission (50-100nm)", CSARmiz, SEF_CSARMISSION, "CSARfar")

local CSARdespawn = MENU_MISSION_COMMAND:New("Despawn All CSAR Missions", CSARmiz, SEF_CSARDESPAWN, "CSARclose", "CSARmedium", "CSARfar")


--////Marianas Mission Options

  --MarianasCSARmission = missionCommands.addCommandForCoalition(coalition.side.BLUE, "Spawn CSAR mission", MarianasOptions, function() SEF_CSARMISSION() end, nil)

env.info("Missions Complete", false)