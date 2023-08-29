env.info("Support Aircraft Loading", false)

-----------------
-- AWACS SPAWN --
-----------------
SPAWN:New('AWACS_DARKSTAR #IFF:(12)5020FR'):InitLimit(1,0):SpawnScheduled(60,1):InitRepeatOnLanding()
--SPAWN:New('blueEWR_AWACS_DARKSTAR #IFF:(12)5016FR-1'):InitLimit(1,99):SpawnScheduled(60,1):InitRepeatOnLanding()
--SPAWN:New('AWACS_BEAR'):InitLimit(1,99):SpawnScheduled(60,1):InitRepeatOnEngineShutDown()
--SPAWN:New('zzTEST_BVR_BLUEFOR'):InitLimit(4,0):SpawnScheduled(2,1):InitRepeatOnEngineShutDown()


------------------
-- TANKER SPAWN --
------------------
--[[
Shell = 3
Arco = 2
Texaco = 1
]]--

local Tanker_KC135_Texaco3 = SPAWN
   :New( "ARLNS_KC-135_01 #IFF:(12)5014FR" )
   :InitLimit( 1, 0 )
   :InitRepeatOnLanding()
   :InitRadioFrequency(324.05)
   :SpawnScheduled( 15, 1 )
   :OnSpawnGroup(
     function( Texaco3 )
     Texaco3:CommandSetCallsign(1,3)
     end 
     )

local Tanker_KC135MPRS_Shell3 = SPAWN
   :New( "ARLNS_KC-135MPRS_01 #IFF:(12)5012FR" )
   :InitLimit( 1, 0 )
   :InitRepeatOnLanding()
   :InitRadioFrequency(319.8)
   :SpawnScheduled( 15, 1 )
   :OnSpawnGroup(
     function( Shell3 )
     Shell3:CommandSetCallsign(3,3)
     end 
     )
     
local Tanker_KC135MPRS_Shell2 = SPAWN
   :New( "AR635_KC-135MPRS_01 #IFF:(12)5013FR" )
   :InitLimit( 1, 0 )
   :InitRepeatOnLanding()
   :InitRadioFrequency(317.775)
   :SpawnScheduled( 15, 1 )
   :OnSpawnGroup(
     function( Shell2 )
     Shell2:CommandSetCallsign(3,2)
     end 
     )
     
local Tanker_KC135_Texaco2 = SPAWN
   :New( "AR635_KC-135_01 #IFF:(12)5011FR" )
   :InitLimit( 1, 0 )
   :InitRepeatOnLanding()
   :InitRadioFrequency(352.6)
   :SpawnScheduled( 15, 1 )
   :OnSpawnGroup(
     function( Texaco2 )
     Texaco2:CommandSetCallsign(1,2)
     end 
     )
 
local Tanker_KC135_Texaco1 = SPAWN
   :New( "AR641A_KC-135_01 #IFF:(12)5015FR" )
   :InitLimit( 1, 0 )
   :InitRepeatOnLanding()
   :InitRadioFrequency(295.4)
   :SpawnScheduled( 15, 1 )
   :OnSpawnGroup(
     function( Texaco1 )
     Texaco1:CommandSetCallsign(1,1)
     end 
     )
     
local Tanker_KC135MPRS_Shell1 = SPAWN
   :New( "AR641A_KC-135MPRS_01 #IFF:(12)5016FR" )
   :InitLimit( 1, 0 )
   :InitRepeatOnLanding()
   :InitRadioFrequency(295.4)
   :SpawnScheduled( 15, 1 )
   :OnSpawnGroup(
     function( Shell1 )
     Shell1:CommandSetCallsign(3,1)
     end 
     )

local Tanker_C130J_Arco3 = SPAWN
   :New( "AR230V_KC-130J_01 #IFF:(12)5017FR" )
   :InitLimit( 1, 0 )
   :InitRepeatOnLanding()
   :InitRadioFrequency(323.2)
   :SpawnScheduled( 15, 1 )
   :OnSpawnGroup(
     function( Arco3 )
     Arco3:CommandSetCallsign(2,3)
     end 
     )

local Tanker_C130J_Arco1 = SPAWN
   :New( "AR230V_KC-135_01 #IFF:(12)5018FR" )
   :InitLimit( 1, 0 )
   :InitRepeatOnLanding()
   :InitRadioFrequency(343.6)
   :SpawnScheduled( 15, 1 )
   :OnSpawnGroup(
     function( Arco1 )
     Arco1:CommandSetCallsign(2,1)
     end 
     )
     
env.info("Support Aircraft Complete", false)
