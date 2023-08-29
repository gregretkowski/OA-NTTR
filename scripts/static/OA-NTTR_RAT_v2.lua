env.info("RAT Loading", false)


-- Defines parameter for both RAT:_Debug() and RAT:ATC_Messages()
local debug = false

local excludedAirfields = {"Nellis", "Creech", "Groom Lake", "Tonopah Test Range", "Tonopah"}

-- Spawns a single aircraft using a random template and livery, with various optional parameters.
local function SpawnRATGroup(alias, coalition, templates, departureNames, destinationNames, terminalType, minDist, maxDist, maxFL, minFL, DestZone, SetTakeoff, Interval)

   local template = templates[math.random(#templates)]
   local templateName = template["name"]

   --env.info("alias="..alias.."; template="..templateName.."; skin="..livery)

   local ratGrp = RAT:New(templateName, alias)


   -- Use skin if available
   if (template["skins"] ~= nil) then
      local livery = template["skins"][math.random(#template["skins"])]
      
      if (livery ~= nil) then
         --env.info("")
         ratGrp:Livery(livery)
      end
   end
   
   -- Hard-coded parameters
   ratGrp:ExcludedAirports(excludedAirfields)
   ratGrp:_Debug(debug)
   ratGrp:EnableATC(true)
   ratGrp:ATC_Messages(debug)
   ratGrp:SetCoalition(coalition)
   ratGrp:CheckOnRunway(true, 75)
   ratGrp:CheckOnTop(true, 5)
   ratGrp:RespawnAfterCrashON()
   ratGrp:RespawnInAirAllowed(true)
   ratGrp:SetEPLRS(true) 
   ratGrp:PlaceMarkers(false)
   ratGrp:TimeDestroyInactive(600)
   ratGrp:SetClimbRate(2500)
   --ratGrp:RadioFrequency(257.8)
   ratGrp:RespawnAfterLanding(15)
   --ratGrp:RadioMenuON()
   --ratGrp:_ATCQueue()
   
   
   --ratGrp:SetTakeoff("takeoff-coldorhot")
   --ratGrp:Uncontrolled()
   --ratGrp:ActivateUncontrolled(3, 60, 60, .5)
   --ratGrp:DestinationZone()
   
   -- Optional parameters
   if (departureNames ~= nil) then
      ratGrp:SetDeparture(departureNames)
   end
   
   if (destinationNames ~= nil) then
      ratGrp:SetDestination(destinationNames)
   end
   
   if (terminalType ~= nil) then
      ratGrp:SetTerminalType(terminalType)
   end
   
   if (minDist ~= nil) then
      ratGrp:SetMinDistance(minDist)
   end
   
   if (maxDist ~= nil) then
      ratGrp:SetMaxDistance(maxDist)
   end
   
   if (maxFL ~= nil) then
      ratGrp:SetMaxCruiseAltitude(maxFL)
   end
   
    if (minFL ~= nil) then
      ratGrp:SetMinCruiseAltitude(minFL)
   end
   
   if (DestZone ~= nil) then
      ratGrp:DestinationZone()
   end
   
   if (SetTakeoff ~= nil) then
      ratGrp:SetTakeoff(SetTakeoff)
   end
   
   --ratGrp:Spawn()
   local scheduler = SCHEDULER:New(ratGrp):ScheduleOnce(Interval,function(arg) arg:Spawn() end, ratGrp)
   
  env.info("RAT Interval Spawned "..Interval)
   
end

-- Spawns the specified number of aircraft based on provided parameters.
local function SetupRATGroup(alias, coalition, templates, departureNames, destinationNames, terminalType, minDist, maxDist, maxFL, minFL, DestZone, SetTakeoff, Interval, spawnCnt)

   for i = 1, spawnCnt, 1 do
      -- alias must be unique for each spawn
      local uniqueAlias = alias.."#"..i
      SpawnRATGroup(uniqueAlias, coalition, templates, departureNames, destinationNames, terminalType, minDist, maxDist, maxFL, minFL, DestZone, SetTakeoff, Interval*(i-1))
   end
end


-- ********************************************************************************
-- CIVILIAN LARGE TRANSPORTS   
-- ********************************************************************************
local civLargeTemplates = 
{
   {name="RAT_GREY_A-320", skins={"Air Berlin", "Alitalia", "American Airlines", "Delta Airlines", "Emirates", "Frontier", "Kuwait Airways", "Qatar", "United", "British Airways"}}, --RAT_GREY_A-320
   {name="RAT_GREY_A-330", skins={"BOURKHAN", "DELTA", "Egypt Air", "Emirates", "GulfAir", "IRoI", "OmanAir", "Qatar", "Turkish Airlines", "US Airways"}}, --RAT_GREY_A-330
   {name="RAT_GREY_A-380", skins={"Air France", "BA", "China Southern", "Emirates", "KA", "LH", "LHF", "Qantas Airways", "QTR", "SA", "TA"}}, --RAT_GREY_A-380
   {name="RAT_GREY_B-727", skins={"Air France", "Alitalia", "American Airlines", "Delta Airlines", "Hapag Lloyd", "Lufthansa", "Northwest", "Singapore Airlines", "Southwest", "UNITED", "ZERO G"}}, --RAT_GREY_B-727
   {name="RAT_GREY_B-737", skins={"Air Algerie", "Air Berlin", "Air France", "airBaltic", "Airzena", "AM", "American_Airlines", "British Airways", "C40s", "Disney", "EA", "easyjet", "FINNAIR", "Jet2", "kulula", "Lufthansa BA", "OMAN AIR", "Polskie Linie Lotnicze LOT", "QANTAS", "RYANAIR", "TNT", "UPS"}}, --RAT_GREY_B-737
   {name="RAT_GREY_B-747", skins={"AF", "AF-One", "AI", "CP", "KLM", "LH", "QA", "TA"}}, --RAT_GREY_B-747
   {name="RAT_GREY_B-757", skins={"AA", "BA", "C-32", "Delta", "DHL", "easyJet", "Swiss", "Thomson"}}, --RAT_GREY_B-757
   {name="RAT_GREY_DC-10", skins={"SWISSAIR HB-IHL"}}, --RAT_GREY_DC-10
   {name="RAT_GREY_Yak-40", skins=nil}, --RAT_GREY_Yak-40
}

SetupRATGroup(
   "Civilian Inbound @IFF:1203",
   "neutral", -- coalition
   civLargeTemplates, -- templates
   {"RAT_LAS_IB_SOUTH","RAT_LAS_IB_NORTHWEST", "RAT_LAS_IB_SOUTHEAST", "RAT_LAS_IB_NORTHEAST"}, -- departures
   {"McCarronDespawn"}, -- destinations
   --{"McCarran_Despawn"}, -- destinations
   nil, -- terminal types
   nil, -- min distance
   nil, -- max distance
   10668, -- max FL (in meters)
   7925, -- min FL (in meters)
   true, -- DestinationZone
   "air", -- SetTakeoff
   180, -- Spawn interval
   10 -- spawn count
)

SetupRATGroup(
   "Civilian Outbound @IFF:1202",
   "neutral", -- coalition
   civLargeTemplates, -- templates
   {"McCarran International"}, -- departures
   {"RAT_LAS_OB_EAST", "RAT_LAS_OB_NORTHEAST", "RAT_LAS_OB_SOUTHEAST", "RAT_LAS_OB_NORTHWEST", "RAT_LAS_OB_SOUTHWEST"},  -- destinations
   nil, -- terminal types
   nil, -- min distance
   nil, -- max distance
   7620, -- max FL (in meters)
   6096, -- min FL (in meters)
   true, -- DestinationZone
   "hot", -- SetTakeoff
   180, -- Spawn interval
   10 -- spawn count
)


--[[
-- ********************************************************************************
-- CIVILIAN SMALL TRANSPORTS   
-- ********************************************************************************
local civSmallTemplates = 
{
   {name="RAT_GREY_Cessna-P210", skins={"D-EKVW", "Muster", "N9672H", "SEagle_blue", "SEagle_red", "V5-BUG", "VH-JGA"}}, --RAT_GREY_Cessna-P210
   {name="RAT_GREY_Yak-52", skins=nil}, --RAT_GREY_Yak-52
   {name="RAT_GREY_Yak-40", skins=nil}, --RAT_GREY_Yak-40
   {name="RAT_GREY_P51D", skins=nil}, --RAT_GREY_P51D
}

SetupRATGroup(
   "Civilian Small Alias @IFF:1201",
   "neutral", -- coalition
   civSmallTemplates, -- templates
   {"Kingsfield", "Ercan", "Lakatamia", "Gecitkale", "Pinarbashi", "Gazipasa", "Gaziantep", "Sanliurfa", "Adana Sakirpasa", "Aleppo", "Kiryat Shmona", "Eyn Shemer", "Megiddo", "Wujah Al Hajar", "Haifa", "Hatay"}, -- departures
   {"Kingsfield", "Ercan", "Lakatamia", "Gecitkale", "Pinarbashi", "Gazipasa", "Gaziantep", "Sanliurfa", "Adana Sakirpasa", "Aleppo", "Kiryat Shmona", "Eyn Shemer", "Megiddo", "Wujah Al Hajar", "Haifa", "Hatay"}, -- destinations
   nil, -- terminal types
   nil, -- min distance
   241, -- max distance
   80, -- max FL
   2 -- spawn count
)

-- ********************************************************************************
-- RED LARGE TRANSPORTS   
-- ********************************************************************************
local redLargeTransportTemplates = 
{ 
   {name="RAT_RED_AN-26B", skins=nil},
   {name="RAT_RED_AN-30M", skins=nil},
   {name="RAT_RED_IL-76MD", skins=nil},
   {name="RAT_RED_TU-95MS", skins=nil},
   {name="RAT_RED_TU-160", skins=nil},
   {name="RAT_RED_H-6J", skins=nil},
}

SetupRATGroup(
   "Red Large Transport Alias",
   "sameonly", -- coalition
   redLargeTransportTemplates, -- templates
   nil, -- departures
   nil, -- destinations
   AIRBASE.TerminalType.OpenBig, -- terminal types
   50, -- min distance
   nil, -- max distance
   nil, -- max FL
   5 -- spawn count
)

-- ********************************************************************************
-- RED HELICOPTERS
-- ********************************************************************************
local redHeloTemplates = 
{ 
   {name="RAT_RED_HELO_MI-24V", skins=nil},
   {name="RAT_RED_HELO_KA-50", skins=nil},
   {name="RAT_RED_HELO_MI-8", skins=nil},
}

SetupRATGroup(
   "Red Helo Alias",
   "sameonly", -- coalition
   redHeloTemplates, -- templates
   nil, -- departures
   nil, -- destinations
   AIRBASE.TerminalType.HelicopterUsable, -- terminal types
   75, -- min distance
   190, -- max distance
   nil, -- max FL
   5 -- spawn count
)

-- ********************************************************************************
-- BLUE HELICOPTERS
-- ********************************************************************************
local blueHeloTemplates = 
{ 
   {name="RAT_BLUE_HELO_CH-47D", skins=nil}, --RAT_BLUE_HELO_CH-47D
   {name="RAT_BLUE_HELO_CH-53", skins=nil}, --RAT_BLUE_HELO_CH-53
   {name="RAT_BLUE_HELO_UH-60A", skins=nil}, --RAT_BLUE_HELO_UH-60A
   {name="RAT_BLUE_HELO_AH-64A", skins=nil}, --RAT_BLUE_HELO_AH-64A
}

SetupRATGroup(
   "Blue Helo Alias @IFF:(12)5004",
   "sameonly", -- coalition
   blueHeloTemplates, -- templates
   nil, -- departures
   nil, -- destinations
   AIRBASE.TerminalType.HelicopterUsable, -- terminal types
   50, -- min distance
   190, -- max distance
   nil, -- max FL
   2 -- spawn count
)

-- ********************************************************************************
-- BLUE LARGE TRANSPORTS
-- ********************************************************************************
local blueLargeTransportTemplates = 
{ 
   {name="RAT_BLUE_A400M", skins=nil}, --RAT_BLUE_A400M
   {name="RAT_BLUE_V-22", skins=nil}, --RAT_BLUE_V-22
   {name="RAT_BLUE_C-17A", skins=nil}, --RAT_BLUE_C-17A
   {name="RAT_BLUE_C-2A", skins=nil}, --RAT_BLUE_C-2A
   {name="RAT_BLUE_C-5", skins=nil}, --RAT_BLUE_C-5
   {name="RAT_BLUE_P-3C", skins=nil}, --RAT_BLUE_P-3C
}

SetupRATGroup(
   "Blue Large Airbase Alias @IFF:(12)5001",
   "sameonly", -- coalition
   blueLargeTransportTemplates, -- templates
   {"Ramat David","Akrotiri"}, -- departures
   nil, -- destinations
   AIRBASE.TerminalType.OpenBig, -- terminal types
   50, -- min distance
   nil, -- max distance
   nil, -- max FL
   2 -- spawn count
)

SetupRATGroup(
   "Blue Large Transport Alias @IFF:(12)5002",
   "sameonly", -- coalition
   blueLargeTransportTemplates, -- templates
   {"RAT_WEST","RAT_NORTH", "RAT_SOUTH"}, -- departures
   nil, -- destinations
   AIRBASE.TerminalType.OpenBig, -- terminal types
   50, -- min distance
   nil, -- max distance
   nil, -- max FL
   2 -- spawn count
)

-- ********************************************************************************
-- BLUE CARRIER TRANSPORT
-- ********************************************************************************
local blueCarrierTemplates = 
{ 
   {name="RAT_BLUE_C-2A", skins=nil}, --RAT_BLUE_C-2A
   {name="RAT_BLUE_HELO_CH-53", skins=nil}, --RAT_BLUE_HELO_CH-53
}

SetupRATGroup(
   "Blue Carrier Transport Alias @IFF:(12)5003",
   "sameonly", -- coalition
   blueCarrierTemplates, -- templates
   {"RAT_WEST","RAT_NORTH", "RAT_SOUTH", "Ramat David","Akrotiri"}, -- departures
   {"CVN-72 A. Lincoln","LHA-1 Tarawa"}, -- destinations
   AIRBASE.TerminalType.OpenMedOrBig, -- terminal types
   nil, -- min distance
   nil, -- max distance
   nil, -- max FL
   2 -- spawn count
)
]]-- 
   
env.info("RAT Complete", false)