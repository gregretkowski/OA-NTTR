
		--[BSD CTLD Initialize]--

--Setup
_SETTINGS:SetPlayerMenuOff()

bsd_ctld = CTLD:New(coalition.side.BLUE,{"Helicargo"},"unit jocko")
bsd_ctld.useprefix = false
bsd_ctld.enableslingload = true 
bsd_ctld.dropcratesanywhere = true
bsd_ctld.forcehoverload = false
bsd_ctld.movetroopsdistance = 6500 
bsd_ctld.CrateDistance = 65 
bsd_ctld.maximumHoverHeight = 45
bsd_ctld.hoverautoloading = false
bsd_ctld.pilotmustopendoors = false
bsd_ctld.droppedbeacontimeout = 7200
bsd_ctld.usesubcats = true
bsd_ctld.cratecountry = country.id.CJTF_BLUE
bsd_ctld.enableLoadSave = false -- allow auto-saving and loading of files
bsd_ctld.saveinterval = 60 -- save every 10 minutes
bsd_ctld.buildtime = 40
--bsd_ctld.filename = "CTLDAssetsSave.csv" -- example filename

--bsd_ctld.filepath = ctldsavefilepath()
bsd_ctld.basetype = "uh1h_cargo"



-- bsd_ctld:AddCTLDZone("Tarawa",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,true,240,20)
-- bsd_ctld:AddCTLDZone("Invincible",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,true,270,30)


--Initialize Units
intCTLDUnits = 0
intCTLDCargos = 0
intCTLDVehicles = 0
intCTLDZones = 0


function funcSetUnits()
	bsd_ctld:AddTroopsCargo("Std Squad x8",{"standardInf"},CTLD_CARGO.Enum.TROOPS,8,100,nil,"Infantry")
	bsd_ctld:AddTroopsCargo("Std Squad x16",{"standardInf-16"},CTLD_CARGO.Enum.TROOPS,16,100,nil,"Infantry")
	bsd_ctld:AddTroopsCargo("Std Fireteam x4",{"fireteamInf"},CTLD_CARGO.Enum.TROOPS,4,100,nil,"Infantry")
	bsd_ctld:AddTroopsCargo("Support Squad x8",{"supportInf"},CTLD_CARGO.Enum.TROOPS,8,120,nil,"Infantry")
	bsd_ctld:AddTroopsCargo("Antitank Squad x8",{"antitankInf"},CTLD_CARGO.Enum.TROOPS,8,140,nil,"Infantry")
	bsd_ctld:AddTroopsCargo("MANPAD Squad x8",{"manpadInf"},CTLD_CARGO.Enum.TROOPS,8,140,nil,"Infantry")

    bsd_ctld:AddTroopsCargo("JTAC x1",{"JTAC"},CTLD_CARGO.Enum.TROOPS,1,150,nil,"Specialists")
  	bsd_ctld:AddTroopsCargo("Mortar Team (2)",{"mortars-2"},CTLD_CARGO.Enum.TROOPS,4,373,nil,"Specialists")
  	bsd_ctld:AddTroopsCargo("Mortar Team (4)",{"mortars-2"},CTLD_CARGO.Enum.TROOPS,8,373,nil,"Specialists")
  	bsd_ctld:AddTroopsCargo("ATGM Team x3",{"atgmTeam"},CTLD_CARGO.Enum.TROOPS,3,250,nil,"Specialists")
  	--bsd_ctld:AddTroopsCargo("Sniper Team x2",{"sniperTeam"},CTLD_CARGO.Enum.TROOPS,2,120,nil,"Specialists")
	bsd_ctld:AddTroopsCargo("ANGLICO x1",{"ANGLICO"},CTLD_CARGO.Enum.TROOPS,1,150,nil,"Specialists")

 	bsd_ctld:AddTroopsCargo("ZODIAC",{"ZODIAC"},CTLD_CARGO.Enum.TROOPS,1,1200,nil,"Light Vehicles")
 	--bsd_ctld:AddTroopsCargo("mspot",{"mortarSpotter"},CTLD_CARGO.Enum.TROOPS,1,150,nil," ")
	intCTLDUnits = 1
	env.info("CTLD/CSAR: Troops loaded")
end


function funcSetCargo()
	bsd_ctld:AddStaticsCargo("fuelbarrels-480-1",480,nil,"Sling Loads")
	bsd_ctld:AddStaticsCargo("netcargo-1000-1",1000,nil,"Sling Loads")
	--bsd_ctld:AddStaticsCargo("L118arty-1260-1",1260,nil,"Sling Loads")
	bsd_ctld:AddStaticsCargo("ammocrate-1500-1",1500,nil,"Sling Loads")
	bsd_ctld:AddStaticsCargo("fuelAPFC-2100-1",2100,nil,"Sling Loads")
	--bsd_ctld:AddStaticsCargo("hmmwv-3200-1",3200,nil,"Sling Loads")
	bsd_ctld:AddStaticsCargo("isocrate-3200-1",3200,nil,"Sling Loads")
	intCTLDCargos = 1
	env.info("CTLD/CSAR: Cargos loaded")
end


function funcSetVehicles()
	bsd_ctld:AddCratesCargo("MATV TOW (2x)",{"TOW"},CTLD_CARGO.Enum.VEHICLE,2,1300,nil,"Vehicles")
	bsd_ctld:AddCratesCargo("MATV MG (2x)",{"MG"},CTLD_CARGO.Enum.VEHICLE,2,1000,nil,"Vehicles")
	bsd_ctld:AddCratesCargo("M939 SUPPLY (2x)",{"M939"},CTLD_CARGO.Enum.VEHICLE,2,1500,nil,"Vehicles")
	bsd_ctld:AddCratesCargo("Deployable FOB/FARP (6x)",{"FOB"},CTLD_CARGO.Enum.FOB,6,1500,nil,"Equipment")
	bsd_ctld:AddCratesCargo("NASAM SYSTEM (6x)",{"NASAM"},CTLD_CARGO.Enum.FOB,6,1000,nil,"Equipment")
	
	intCTLDVehicles = 1
	env.info("CTLD/CSAR: Vehicles loaded")
end

local setLoadzone = SET_ZONE:New():FilterPrefixes('Loadzone'):FilterOnce()
setLoadzone:ForEachZone(function(_zone)	
	local nameZone = _zone:GetName()
	bsd_ctld:AddCTLDZone(nameZone,CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
	env.info("CTLD/CSAR: " .. nameZone .. " added as a Logistics Zone.")
end)


schedCTLDInit = SCHEDULER:New( nil, function()
	funcSetUnits()
	funcSetCargo()
	funcSetVehicles()
	env.info("CTLD/CSAR: Initializing things...")
end, {}, 1)


--Verify units
schedCTLDVerify = SCHEDULER:New( nil, function()
	if intCTLDCargos == 0 then
		MESSAGE:New("CTLD/CSAR ERROR: Cargos failed to initialize! Check that all required CTLD cargo objects have been set up in the mission editor.",30,""):ToAll()
		env.info("CTLD/CSAR: Cargos failed to load")
	end
	
	if intCTLDUnits == 0 then
		MESSAGE:New("CTLD/CSAR ERROR: Troops failed to load! Check that all required late activated troop transport groups have been set up in the mission editor.",30,""):ToAll()
		env.info("CTLD/CSAR: Troops failed to load")
	end
	
	if intCTLDVehicles == 0 then
		MESSAGE:New("CTLD/CSAR ERROR: Vehicles failed to load! Check that all required late activated vehicle groups have been set up in the mission editor.",30,""):ToAll()
		env.info("CTLD/CSAR: Vehicles failed to load")
	end
	
	if intCTLDVehicles == 1 and intCTLDUnits == 1 and intCTLDCargos == 1 then
		MESSAGE:New("CTLD/CSAR Verification successful",7,""):ToAll()
		env.info("CTLD/CSAR: Everything loaded successfully")
	end
	env.info("CTLD/CSAR: Initialization complete")
end, {}, 3)


--Aircraft Declarations
bsd_ctld:UnitCapabilities("SA342L", false, true, 0, 2, 15, 1000)
bsd_ctld:UnitCapabilities("SA342M", false, true, 0, 2, 15, 1000)
bsd_ctld:UnitCapabilities("SA342Minigun", false, true, 0, 2, 15, 1000)
bsd_ctld:UnitCapabilities("UH-1H", true, true, 1, 10, 25, 3000)
bsd_ctld:UnitCapabilities("UH-60L", true, true, 1, 12, 25, 4000)
bsd_ctld:UnitCapabilities("Mi-8MT", true, true, 2, 24, 30, 8000)
bsd_ctld:UnitCapabilities("Mi-24P", true, true, 1, 6, 30, 2000)

bsd_ctld:SetTroopDropZoneRadius(5)


bsd_ctld:__Start(5)
-- bsd_ctld:__Load(12) no persistence in s4




		--[Deployment Actions]--

local tableFarpIDs = {
	[1] = "ALPHA",
	[2] = "BRAVO",
	[3] = "CHARLIE",
	[4] = "DELTA",
	[5] = "ECHO",
	[6] = "FOXTROT",
	[7] = "GOLF",
	[8] = "HOTEL",
	[9] = "INDIA",
	[10] = "JULIET",
	[11] = "KILO",
	[12] = "LIMA",
	[13] = "MIKE",
	[14] = "NOVEMBER",
	[15] = "OSCAR",
	[16] = "PAPA",
	[17] = "QUEBEC",
	[18] = "ROMEO",
	[19] = "SIERRA",
	[20] = "TANGO",
	[21] = "UNIFORM",
	[22] = "VICTOR",
	[23] = "WHISKEY",
	[24] = "XRAY",
	[25] = "YANKEE",
	[26] = "ZULU"
  }
local indexFARP = 0
		
		
--On After Drop
ctldhookCrateDrop = 0
function bsd_ctld:OnAfterCratesDropped(From, Event, To, Group, Unit, Cargotable)

	--Hooks
	if ctldhookCrateDrop == 1 then
		funcCtldHookCrateDrop(From, Event, To, Group, Unit, Cargotable)
	end
	
	if ctldhookCrateZone == 1 then
		funcCrateZone(From, Event, To, Group, Unit, Cargotable)
	end
end	


--On After Build
ctldhookCrateBuild = 0
   function bsd_ctld:OnAfterCratesBuild(From, Event, To, Group, Unit, Vehicle)
	--Hook
	if ctldhookCrateBuild == 1 then
		funcCtldHookCrateBuild(From, Event, To, Group, Unit, Vehicle)
	end
     local points = 5
     if Unit then
		local PlayerName = "INVALID"
		if Unit:GetPlayerName() ~= nil then
       		PlayerName = Unit:GetPlayerName()
		end
       groupName = Vehicle:GetName()
       env.info("CTLD/CSAR: " .. groupName .. " built from crate dropped by " .. Group:GetName() .. ".")
       if string.match(groupName, "ARTY") then -- This is where we detect if the built crate is of a certain type that other stuff needs to happen.
       
        env.info("CTLD/CSAR: " .. groupName .. " was given the ARTY class.")
        nameString = groupName .. math.random(1,34545)
       
        nameString = ARTY:New(GROUP:FindByName(groupName))
        
        local coord = Vehicle:GetCoordinate()
        coord:MarkToAll("ARTY ENGAGE, BATTERY \"" .. groupName .. "\", radius 1,shots 15", true)
        
        nameString:SetMarkAssignmentsOn()
        
        nameString:Start()
       
       end
       if string.match(groupName, "FOB") then -- This is where we detect if the built crate is of a certain type that other stuff needs to happen.
          FOBZone = ZONE_UNIT:New(Vehicle:GetName(),Vehicle:GetUnit(1),100)
          bsd_ctld:AddCTLDZone(Vehicle:GetName(),CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true) -- Note: since there are no blue flares, this will be a white flare when requested.
          local FOBFarp = SPAWNSTATIC:NewFromStatic("farpinvis", country.id.USA )
          FOBFarp:SpawnFromCoordinate(Vehicle:GetCoordinate(), math.random(1,359), "FOB/FARP")
          MESSAGE:New("FOB/FARP Successfully deployed by " .. PlayerName .. ". Check your F10 map for its location.",30,""):ToAll()
		  USERSOUND:New( "squelch.ogg" ):ToAll()
		  indexFARP = indexFARP + 1
		  local nameFARP = PlayerName
		  if indexFARP < 27 then
		  	nameFARP = tableFarpIDs[indexFARP]
		  end
		  Vehicle:GetCoordinate():TextToAll(" FARP " .. nameFARP .. " ", -1, {1,1,1}, 1, {0.2,0.2,1}, 0.2, 10, true, "CTLD FARP")
		  env.info("DEBUG: " .. PlayerName .. " deployed a CTLD FOB. It has been given the name FARP " .. nameFARP)
                   
       end
    end
end   
	
	
--Troop Deployment
ctldhookTroopsDeploy = 0
lastgroup = nil
JtacLaser.Activate("blue")

function bsd_ctld:OnAfterTroopsDeployed(From, Event, To, Group, Unit, Troops)	
	name = Troops:GetName()

	 --Script Hooks
	if ctldhookTroopsDeploy == 1 then
		funcCtldHookTroopsDeploy(From, Event, To, Group, Unit, Troops)
		env.info("CTLD/CSAR: " .. name .. " activated the Deploy hook.")
	end
	
	if ctldhookActionZone == 1 then
		funcActionZone(From, Event, To, Group, Unit, Troops)
		env.info("CTLD/CSAR: " .. name .. " activated the Action Zone hook.")
	end
	
	if ctldhookDropZone == 1 then
		funcDropZone(From, Event, To, Group, Unit, Troops)
		env.info("CTLD/CSAR: " .. name .. " activated the Drop Zone hook.")
	end
	
	if ctldhookWPZone == 1 then
		funcWPZone(From, Event, To, Group, Unit, Troops)
		env.info("CTLD/CSAR: " .. name .. " activated the wpzone hook.")
	end
      
    TroopsGroupName = name
      
    TroopsGroup = Troops
	local PlayerName = "INVALID"
	if Unit ~= nil then
		if Unit:GetPlayerName() ~= nil then
			PlayerName = Unit:GetPlayerName()
		end
	end
     env.info(name .. "troops deployed by " .. PlayerName)
	 
	 --------DEPLOYED SPECIALISTS--------
  --JTAC
  if string.match(name,"JTAC") then
    JtacLaser.CreateJTAC(Troops, "blue", 30, 0.25, 1688, 10000)
    CamoPants.New(Troops,10,200,false)
  end

  --ANGLICO
  if string.match(name,"ANGLICO") then
    local A  = MESSAGE:New(string.format("ANGLICO team deployed and operational!"),15,""):ToAll()  
	USERSOUND:New( "squelch.ogg" ):ToAll()
	env.info("DEBUG: New ANGLICO handler created for " .. name)
    CamoPants.New(Troops,10,200,false)
  end

  --Mortar Team
  if string.match(name,"mortarTeam") then
	TIMER:New(function()
		MortarTeam:Crew(Troops, "Mortar Team", 6.5, 0.03, 10, 1, 60, true, 'red', 30)
	end):Start(20)
	if Unit and Unit:IsAlive() then
		bsd_ctld:PreloadTroops(Unit, "mspot")
		MESSAGE:New("The spotter for this mortar team is still in your aircraft. Drop him somewhere with good line of sight to call in targets for the mortars."):ToGroup(Group)
		USERSOUND:New( "beep.ogg" ):ToGroup(Group)
	end
  end

  --Mortar Spotter
  if string.match(name,"mortarSpotter") then
	TIMER:New(function()
		MortarTeam:Spotter(Troops,10,1,'ReturnFire','red',30)
	end):Start(20)
    CamoPants.New(Troops,10,200,false)
  end

  --Check if drone operator
  if string.match(name,"droneTeam") then
	TIMER:New(function()
		ReconDrone:NewFPVDrone(Troops, 6000, 600, 5, 120, 900, 1, "red")
	end):Start(20)
    CamoPants.New(Troops,10,200,false)
  end

   --Check if Sniper team
   if string.match(name,"sniperTeam") then
	WeaponCrew.NewCrew(Troops,"weaponSniper",10,3,"Sniper team is set up and ready.","Sniper team has packed up and is on the move.",200)
    CamoPants.New(Troops,10,200,true,1000,120)
  end

  --Check if ATGM team
  if string.match(name,"atgmTeam") then
   WeaponCrew.NewCrew(Troops,"weaponATGM",10,3,"ATGM team is set up and ready.","ATGM team has packed up and is on the move.",1000)
   CamoPants.New(Troops,10,600,true,1000,120)
 end

  --Check for wpzone marks
  local allMarks = world.getMarkPanels()
  for i, mark in pairs(allMarks) do
--    if string.find(string.lower(mark.text), "pickup") then
--       pickupmark = true
--       MESSAGE:New("PICKUP ZONE FOUND: " ,30,""):ToAll()
--       pickupCoord = COORDINATE:New(mark.pos.x, mark.pos.y, mark.pos.z)
--    end 
    if string.find(string.lower(mark.text), "wpzone") then  
		env.info("DEBUG: Checking if wpzone map marker is in range for " .. name)
       Coord = COORDINATE:New(mark.pos.x, mark.pos.y, mark.pos.z)
       UnitCoord = Unit:GetCoordinate()       
       TroopsCoord = TroopsGroup:GetUnit(1):GetCoordinate() 
       --MESSAGE:New("name: " .. name ,30,""):ToAll()
       
       markdistance = TroopsCoord:Get2DDistance(Coord)
       UnitDistance = TroopsCoord:Get2DDistance(UnitCoord)
       --MESSAGE:New("DISTANCE: " .. markdistance .. "," .. UnitDistance,30,""):ToAll()
       if markdistance < bsd_ctld.movetroopsdistance and UnitDistance < bsd_ctld.movetroopsdistance then
		env.info("DEBUG: wpzone mark is in range for " .. name)
          Followroute = TroopsGroup:TaskRouteToVec2(Coord:GetVec2(),15,FORMATION.Vee)     
          if Followroute ~= nil then
             --TroopsGroup:SetTask(Followroute,0)
             --env.info("SetTask called..")
          end  
       end
    elseif string.find(string.lower(mark.text), "return") then
		env.info("DEBUG: Checking if return map marker is in range for " .. name)
       Coord = COORDINATE:New(mark.pos.x, mark.pos.y, mark.pos.z)
       UnitCoord = Unit:GetCoordinate()
       _grp = Unit:GetGroup()
       TroopsGroupName = TroopsGroup:GetName()
       _length = string.len(mark.text)
       return_time = string.sub(mark.text,7,_length) --return123
       if string.len(return_time) < 1 then return_time = 60 end
        MESSAGE:New("Troops: returning in " .. return_time .. " seconds " .. TroopsGroupName ,20,""):ToGroup(_grp)    
        TroopsCoord = TroopsGroup:GetUnit(1):GetCoordinate()      
        markdistance = TroopsCoord:Get2DDistance(Coord)
        UnitDistance = TroopsCoord:Get2DDistance(UnitCoord)

--        if pickupmark == true then PickupDistance = TroopsCoord:Get2DDistance(UnitCoord)
--          MESSAGE:New("pickupmarktrue: " ,30,""):ToAll()
--         end
        
         --MESSAGE:New("DISTANCE: " .. markdistance .. "," .. UnitDistance,30,"")

        if markdistance < bsd_ctld.movetroopsdistance and UnitDistance < bsd_ctld.movetroopsdistance then
			env.info("DEBUG: return map marker is in range for " .. name .. " who will return in " .. return_time .. " seconds")
          TroopsGroup:RouteGroundTo(Coord,15,"Diamond",1)

                      local returnLZ = SCHEDULER:New( nil,
            function()

--              if pickupmark == true and PickupDistance < 700 then 
--                 returnCoord = pickupCoord
--              else 
--                 returnCoord = TroopsCoord 
--              end
				env.info("DEBUG: " .. name .. " now returning to the lz")
              TroopsGroup:RouteGroundTo(UnitCoord,15,"Diamond",1)
              if lastgroup == TroopsGroupName then 
              else
                MESSAGE:New("Troops: Returning to LZ!"  .. TroopsGroupName ,20,""):ToGroup(_grp)
                
              end
              end, {}, return_time )  
--                                    
        end
    end
 end  --elseif
end
   

		--[CSAR]--
		
--Setup

--Check raft mod included
local intCSARMod = 0
setCSARmod = SET_GROUP:New():FilterCoalitions("blue"):FilterPrefixes( "CSARinflatable" ):FilterOnce():ForEachGroup(function(_grp) 
	intCSARMod = 1 
	env.info("CTLD/CSAR: CSAR raft located")
end)

-- my_scoring = SCORING:New("CSAR")
-- my_scoring:SetMessagesScore(false)
-- my_scoring:SetMessagesDestroy(false)
-- my_scoring:SetMessagesHit(false)
-- my_scoring:SwitchFratricide(false)
-- my_scoring:SwitchTreason(false)

BlueCsar = CSAR:New("blue","Downed Pilot","Blue Cross")
BlueCsar.csarOncrash = true
BlueCsar.enableForAI = true
BlueCsar.allowDownedPilotCAcontrol = true
--BlueCsar.invisiblecrew = false
BlueCsar.coordtype = 2
BlueCsar.verbose = 0
BlueCsar.pilotmustopendoors = false
BlueCsar.useprefix = false
if intCSARMod == 1 then 
	BlueCsar.wetfeettemplate = "CSARinflatable" 
else 
	trigger.action.outText("CTLD/CSAR: Late activated liferaft group with the name of 'CSARinflatable' was not found. CSARs over water will use infantry instead.", 20) 
end
BlueCsar.mashprefix = {"MASH"}
BlueCsar:__Start(1)


--CASEVAC
function BlueCsar:OnAfterPilotDown(from, event, to, spawnedgroup, frequency, groupname, coordinates_text)
	USERSOUND:New( "CSAR.ogg" ):ToCoalition( coalition.side.BLUE )

 if groupname == "CASEVAC" then
  env.info("CTLD/CSAR: OnAfterPilotDown/Casevac")
  local coords1 = spawnedgroup:GetUnit(1):GetOffsetCoordinate(0,0,4) 
  local coords2 = spawnedgroup:GetUnit(1):GetOffsetCoordinate(10,0,0) 
  local coords3 = spawnedgroup:GetUnit(1):GetOffsetCoordinate(10,0,10) 
  local humvee = SPAWNSTATIC:NewFromStatic("hmmwvS")
  --inf = SPAWNSTATIC:NewFromStatic("friendlystaticinf") -- :InitDead(true)
  humvee:SpawnFromCoordinate(coords1,math.random(1,359),"convoy-humveeS" .. math.random(1,1232))
  humvee:SpawnFromCoordinate(coords2,math.random(1,359),"convoy-humveeS".. math.random(1,1232))
  --local infguy = inf:SpawnFromCoordinate(coords3,math.random(1,359),"convoy-infS")
  local Heading = math.random(1,359)
  mcoord = coords1
  staticinf = SPAWNSTATIC:NewFromStatic( "usinfS", country.id.USA )
  local infguy = staticinf:SpawnFromCoordinate( mcoord, Heading + 3, "convoyinf-" .. math.random(1,3000)  )
  local offset1 = math.random(-9,9)
  local offset2 = math.random(-12,7)
  mcoord = infguy:GetOffsetCoordinate(offset1,0,offset1)
  local infguy = staticinf:SpawnFromCoordinate( mcoord, Heading + 3, "convoyinf-" .. math.random(1,3000) )
  for i=1,4 do
    offset1 = math.random(-9,9)
    offset2 = math.random(-12,7)
    Heading = math.random(1,359)
    mcoord = infguy:GetOffsetCoordinate(offset1,0,offset2)
    local infguy = staticinf:SpawnFromCoordinate( mcoord, Heading + 3, "convoyinf-" .. math.random(1,3000) )
  end
  

 end

 spawnedgroup:SetCommandImmortal(true)
 spawnedgroup:SetCommandInvisible(true)
 spawnedgroup:OptionROEHoldFire()
 

end --function


--Greenie Board
-- function BlueCsar:OnAfterRescued(From, Event, To, HeliUnit, HeliName, NumberSaved)
--   -- add score to player
--   local ActionType = "CSAR"
--   local Number = NumberSaved or 1
--   local Player = HeliUnit:GetPlayerName()
--   local HeliType = HeliUnit:GetTypeName()

--   GreenieBoard_UH(Player,ActionType,HeliType,Number)
  

-- end

-- function GreenieBoard_UH(Player, ActionType, HeliType, Number)

--   local Tnow = os.time()
--   local text = Tnow .. "," .. Player .. "," .. ActionType .. ",".. HeliType .."," .. Number .. "\n"
--   local FileName = "D:\\Saved Games\\DCS\\Missions\\CSARgreenieboard.csv"
--   local File = io.open(FileName, 'a')
--   File:write(text)    
--   File:close()

-- end




		--[Mission Editor Functions]--
		
--Add extractable groups
  CTLDTroops = SET_GROUP:New():FilterPrefixes("CTLD"):FilterOnce()   
  CTLDTroops:ForEachGroup(function(grp)
    groupname = grp:GetName()
    
    unit_table = grp:GetUnits()
    unitcount = #unit_table
    env.info("unitcount:" .. unitcount)
    Zone_namestring = "Zone_" .. groupname
  
    Zone_ = ZONE_GROUP:New(Zone_namestring,grp,1)
      
    InjectTroops = CTLD_CARGO:New(nil,groupname,{groupname},CTLD_CARGO.Enum.TROOPS,true,true,unitcount,nil,false,100)
   
    bsd_ctld:InjectTroops(Zone_,InjectTroops,nil,true)
    env.info("CTLD/CSAR: " .. grp:GetName() .. " INJECTED!")
  end)

--CTLDInjectedTroops()
function CTLDTroops:OnAfterAdded(From, Event, To, ObjectName, Object)

    local Zone_namestring = "Zone_" .. ObjectName
    local  unit_table = Object:GetUnits()
    local unitcount = #unit_table
  
    local Zone_group = ZONE_GROUP:New(Zone_namestring,Object,15)
    
    local InjectTroops = CTLD_CARGO:New(nil,ObjectName,{ObjectName},CTLD_CARGO.Enum.TROOPS,true,true,unitcount,nil,false,100)
    bsd_ctld:InjectTroops(Zone_group ,InjectTroops,nil,true)
    
  
end


--Add wpzones
ctldhookWPZone = 0
ctldtableWPzones = {}
local schedDelay = SCHEDULER:New(nil, function()
	local setWpzone = SET_ZONE:New():FilterPrefixes('wpzone'):FilterOnce()
	setWpzone:ForEachZone(function(_zone)
		ctldhookWPZone = 1
		local nameZone = _zone:GetName()
		table.insert(ctldtableWPzones, nameZone)
		env.info("CTLD/CSAR: " .. nameZone .. " added as a wpzone.")
	end)
end, {}, 2)

function funcWPZone(From, Event, To, Group, Unit, Troops)
	for i = 1, #ctldtableWPzones do		
		local wpzone = ZONE:New(ctldtableWPzones[i])
		if Troops:IsAnyInZone(wpzone) then
			local coordwpzone = wpzone:GetCoordinate()
			Troops:RouteGroundTo(coordwpzone, 60, 'Diamond', 1)
			env.info("CTLD/CSAR: Troops detected inside " .. ctldtableWPzones[i] .. " and routed to the center.")
		end
	end
end


--Add crate
function bsdctldAddCrate(namecrate, weight)
	bsd_ctld:AddStaticsCargo(namecrate,weight)
	env.info("CTLD/CSAR: " .. namecrate .. " added as a crate with a weight of " .. weight .. "kg.")
end


--Add troops
function bsdctldAddTroops(itemname, groupname, unitcount, unitweight)
	bsd_ctld:AddTroopsCargo(itemname,{groupname},CTLD_CARGO.Enum.TROOPS,unitcount,unitweight)
	env.info("CTLD/CSAR: " .. groupname .. " added as a troops under the name of " .. itemname .. " containing " .. unitcount .. " units, each with a weight of " .. unitweight .. "kg.")
end


--Add vehicle
function bsdctldAddVehicle(itemname, groupname, cratecount, crateweight, categoryname)
	local category = nil
	if categoryname ~= nil then 
		category = categoryname
	else
		category = "Equipment"
	end
	bsd_ctld:AddCratesCargo(itemname,{groupname},CTLD_CARGO.Enum.VEHICLE,cratecount,crateweight,nil,category)
	env.info("CTLD/CSAR: " .. groupname .. " added as a vehicle set under the name of " .. itemname .. ". It will take  " .. cratecount .. " crates to build, each crate weighing " .. crateweight .. "kg. It has been placed under the category " .. category .. ".")
end


--Inject Crates
function bsdctldInjectCrate(zonename, cratename, weight)
	local injectzone = ZONE:New(zonename)
	bsd_ctld:InjectStaticFromTemplate(injectzone, cratename, weight)
	env.info("CTLD/CSAR: " .. cratename .. " injected into " .. zonename .. " with a weight of " .. weight .. " kg.")
end


--Inject Troops
function bsdctldInjectTroops(zonename, groupname, weight)
	local groupInject = GROUP:FindByName(groupname)
	local injectzone = ZONE:New(zonename)
	local tableUnits = groupInject:GetUnits()
	local countUnits = #tableUnits
	local injecttroops = CTLD_CARGO:New(nil,"Injected Troops",{groupname},CTLD_CARGO.Enum.TROOPS,true,true,countUnits,nil,false,weight)
    bsd_ctld:InjectTroops(injectzone ,injecttroops,nil,true)
	env.info("CTLD/CSAR: " .. groupname .. " injected into " .. zonename .. " with an individual unit weight of " .. weight .. " kg.")
end


--Action Zone
ctldhookActionZone = 0
ctldtableActionzone = {}
function bsdctldAddActionZone(lzname, zonename, flag, namefilter, troopcount, nextzone, waittime, nextflag)
	local lzzone = ZONE:New(lzname)
    local actzone = ZONE:New(zonename)
    local actflag = USERFLAG:New(flag)
    local actcounter = 0
	local intactcounter = 0
    local acttable = {lzname = lzname, zonename = zonename, flag = flag, namefilter = namefilter, troopcount = troopcount, nextzone = nextzone, waittime = waittime, nextflag = nextflag, lzzone = lzzone, actzone = actzone, actflag = actflag, actcounter = actcounter, intactcounter = intactcounter}
    table.insert(ctldtableActionzone, acttable)
    ctldhookActionZone = 1
    env.info("CTLD/CSAR: New action zone added. Zone: " .. zonename .. " | Flag: " .. flag .. " | Name Filter: " .. tostring(namefilter) .. " | Troop Count: " .. tostring(troopcount) .. " | Next Zone: " .. tostring(nextzone) .. " | Wait Time: " .. tostring(waittime) .. " | Next Flag: " .. tostring(nextflag))
end

function funcActionZone(From, Event, To, Group, Unit, Troops)
    for i = 1, #ctldtableActionzone do
        if ctldtableActionzone[i]["namefilter"] == false or string.match(Troops:GetName(), ctldtableActionzone[i]["namefilter"]) then
			if Troops:IsAnyInZone(ctldtableActionzone[i]["lzzone"]) then
				local coordlz = Unit:GetCoordinate()
				local coordactzone = ctldtableActionzone[i]["actzone"]:GetCoordinate()
				Troops:RouteGroundTo(coordactzone, 60, 'Diamond', 1)
				env.info("CTLD/CSAR: Troops detected inside LZ " .. ctldtableActionzone[i]["lzname"] .. " and routed to Action Zone " .. ctldtableActionzone[i]["zonename"] .. ".")
				   
				--Next Zone
				function funcNextZone()
					local coordactzone2 = nil
					local nextzonestring = "invalid"
					if ctldtableActionzone[i]["nextzone"] ~= true then
						local actzone2 = ZONE:New(ctldtableActionzone[i]["nextzone"])
						coordactzone2 = actzone2:GetCoordinate()
						nextzonestring = ctldtableActionzone[i]["nextzone"]
					else
						coordactzone2 = coordlz
						nextzonestring = "LZ"
					end
					local actflag2 = USERFLAG:New(ctldtableActionzone[i]["nextflag"])
					local schedWait = SCHEDULER:New(nil, function()
						local setActTroops = SET_GROUP:New():FilterCategoryGround():FilterCoalitions("blue"):FilterOnce()
						setActTroops:ForEachGroupAlive(function(_grp)
							if _grp:IsAnyInZone(ctldtableActionzone[i]["actzone"]) then
								_grp:RouteGroundTo(coordactzone2, 60, 'Diamond', 1)
								env.info("CTLD/CSAR: " .. _grp:GetName() .. " have been routed to " .. ctldtableActionzone[i]["nextzone"] .. ". Flag " .. ctldtableActionzone[i]["nextflag"] .. " set to 1.")
							end
						end)
						actflag2:Set(1)
					end, {}, ctldtableActionzone[i]["waittime"])
					env.info("CTLD/CSAR: Troops will move on to " .. nextzonestring .. " in " .. ctldtableActionzone[i]["waittime"] .. " seconds.")
				end
		
				--Troop Counter Reached
				if ctldtableActionzone[i]["troopcount"] ~= false and ctldtableActionzone[i]["intactcounter"] == 0 then
					ctldtableActionzone[i]["intactcounter"] = 1
					local schedobjActCount = ZONE:New( "Loadzone-1" )
					local schedmastobjActCount = SCHEDULER:New( schedobjActCount )
					local schedActCount = schedmastobjActCount:Schedule( nil, function()
						if ctldtableActionzone[i]["actcounter"] >= ctldtableActionzone[i]["troopcount"] then
							schedmastobjActCount:Stop(schedActCount)
							ctldtableActionzone[i]["actflag"]:Set(1)
							env.info("CTLD/CSAR: " .. ctldtableActionzone[i]["zonename"] .. " has reached a count of " .. ctldtableActionzone[i]["actcounter"] .. "/" .. ctldtableActionzone[i]["troopcount"]" troops. Flag " .. ctldtableActionzone[i]["flag"] .. " has been set to 1.")
							if ctldtableActionzone[i]["nextzone"] ~= false then funcNextZone() end
						end            
					end, {}, 5, 5)
				end
				
				--Troops Arrived
				if ctldtableActionzone[i]["troopcount"] == false then
					local schedobjAction = ZONE:New( "Loadzone-1" )
					local schedmastobjAction = SCHEDULER:New( schedobjAction )
					local schedAction = schedmastobjAction:Schedule( nil, function()
						if Troops:IsAnyInZone(ctldtableActionzone[i]["actzone"]) then
							schedmastobjAction:Stop(schedAction)
							ctldtableActionzone[i]["actflag"]:Set(1)
							env.info("CTLD/CSAR: " .. Troops:GetName() .. " have reached " .. ctldtableActionzone[i]["zonename"] .. ". Flag " .. ctldtableActionzone[i]["flag"] .. " has been set to 1.")
							if ctldtableActionzone[i]["nextzone"] ~= false then funcNextZone() end
						end            
					end, {}, 5, 5)
				else
					local schedobjAction = ZONE:New( "Loadzone-1" )
					local schedmastobjAction = SCHEDULER:New( schedobjAction )
					local schedAction = schedmastobjAction:Schedule( nil, function()
						if Troops:IsAnyInZone(ctldtableActionzone[i]["actzone"]) then
							schedmastobjAction:Stop(schedAction)
							ctldtableActionzone[i]["actcounter"] = ctldtableActionzone[i]["actcounter"] + Troops:CountAliveUnits()
							env.info("CTLD/CSAR: " .. Troops:GetName() .. " have reached " .. ctldtableActionzone[i]["zonename"] .. ". Troops counted: " .. ctldtableActionzone[i]["actcounter"] .. "/" .. ctldtableActionzone[i]["troopcount"])
						end            
					end, {}, 5, 5)
				end
			end
		end
	end
end



--Drop Zone
ctldhookDropZone = 0
ctldtableDropzone = {}
function bsdctldAddDropZone(zonename, flag, namefilter, consume)	
	local dropzone = ZONE:New(zonename)	
	local dropflag = USERFLAG:New(flag)
	local intdrop = 0
	local id = zonename
	
	local droptable = {dropzone = dropzone, dropflag = dropflag, namefilter = namefilter, consume = consume, intdrop = intdrop, flag = flag, zonename = zonename}
	table.insert(ctldtableDropzone, droptable)
	env.info("CTLD/CSAR: " .. zonename .. " added as a Drop Zone. Flag: " .. flag .. " | Name Filter: " .. tostring(namefilter) .. " | Consume: " .. tostring(consume))
	ctldhookDropZone = 1
end

function funcDropZone(From, Event, To, Group, Unit, Troops)
	for i = 1, #ctldtableDropzone do
		if ctldtableDropzone[i]["namefilter"] == false or string.match(Troops:GetName(), ctldtableDropzone[i]["namefilter"]) then
			if Troops:IsAnyInZone(ctldtableDropzone[i]["dropzone"]) then
				ctldtableDropzone[i]["intdrop"] = ctldtableDropzone[i]["intdrop"] + Troops:CountAliveUnits()
				ctldtableDropzone[i]["dropflag"]:Set(ctldtableDropzone[i]["intdrop"])
				env.info("CTLD/CSAR: " .. Troops:GetName() .. " dropped in " .. ctldtableDropzone[i]["zonename"] .. ". Flag " .. ctldtableDropzone[i]["flag"] .. " set to " .. ctldtableDropzone[i]["intdrop"] .. ".")
				if ctldtableDropzone[i]["consume"] == true then
					Troops:Destroy()
					env.info("CTLD/CSAR: " .. Troops:GetName() .. " have been consumed.")
				end
			end
		end
	end
end


--Crate Zone
ctldhookCrateZone = 0
ctldtableCrateZone = {}
function bsdctldAddCrateZone(zonename, flag, namefilter, consume)
	local cratezone = ZONE:New(zonename)
	local crateflag = USERFLAG:New(flag)
	local intcrate = 0
	ctldhookCrateZone = 1
	local cratetable = {zonename = zonename, flag = flag, namefilter = namefilter, consume = consume, cratezone = cratezone, crateflag = crateflag, intcrate = intcrate}
	table.insert(ctldtableCrateZone, cratetable)
	env.info("CTLD/CSAR: " .. zonename .. " added as a Crate Zone. Flag: " .. flag .. " | Name Filter: " .. tostring(namefilter) .. " | Consume: " .. tostring(consume))
end

function funcCrateZone(From, Event, To, Group, Unit, Cargotable)
	local stringCrate = Cargotable[1].Name
	local objCrate = Cargotable[1].Positionable
	for i = 1, #ctldtableCrateZone do
		if ctldtableCrateZone[i]["namefilter"] == false or string.match(stringCrate, ctldtableCrateZone[i]["namefilter"]) then
			if objCrate:IsInZone(ctldtableCrateZone[i]["cratezone"]) then
				ctldtableCrateZone[i]["intcrate"] = ctldtableCrateZone[i]["intcrate"] + 1
				ctldtableCrateZone[i]["crateflag"]:Set(ctldtableCrateZone[i]["intcrate"])
				env.info("CTLD/CSAR: " .. stringCrate .. " dropped in " .. ctldtableCrateZone[i]["zonename"] .. ". Flag " .. ctldtableCrateZone[i]["flag"] .. " set to " .. ctldtableCrateZone[i]["intcrate"] .. ".")
				if ctldtableCrateZone[i]["consume"] == true then
					objCrate:Destroy()
					env.info("CTLD/CSAR: " .. stringCrate .. " has been consumed.")
				end
			end
		end
	end
end


MESSAGE:New("BSD CTLD/CSAR LOADED ",10,""):ToAll()

