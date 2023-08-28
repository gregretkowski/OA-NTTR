env.info("STATUA TOOLS: Starting Statua Tools framework...")

if BASE == nil then
    env.info("STATUA TOOLS: ERROR! MOOSE Framework has not been loaded. Please load the MOOSE Framework prior to loding Statua Tools Framweork.")
    trigger.action.outText("STATUA TOOLS: ERROR! MOOSE Framework has not been loaded. Please load the MOOSE Framework prior to loding Statua Tools Framweork.", 60)
end

StatuaTools = {}
StatuaTools.DEBUG = false

--<<<<<<<<<<<<<<<<<<<<<<<<<[Utils]>>>>>>>>>>>>>>>>>>>>>>>>>--


env.info("STATUA TOOLS: Initializing utilities")
StatuaUtils = {}

--Create a beacon on a unit that updates every 5 minutes to bypass the
function StatuaUtils.BeaconLoop(_groupname, _frequency, _soundfile)
    TIMER:New(function()
        local beaconGroup = GROUP:FindByName(_groupname)
        local beaconUnit = beaconGroup:GetUnit(1)
        local beaconBeacon = beaconUnit:GetBeacon()
        beaconBeacon:RadioBeacon(_soundfile,_frequency,radio.modulation.AM, 100)
    end):Start(nil,300)
    env.info("BEACON LOOPER: New beacon created for " .. _groupname .. " on " .. _frequency*1000 .. " playing sound file '" .. _soundfile .. "'")
end


--Find the closest group in a set to a given coordinate. Returns 2 values: [Wrapper.GROUP of the Target],[Distance to Target in Meters]
function StatuaUtils.FindClosestLOSinSET(_coord, _coalition,_prefix,_type,_zonetable,_minrange,_maxrange)
    if StatuaTools.DEBUG then env.info("DEBUG: Coalition = " .. tostring(_coalition) .. " | Prefix = " .. tostring(_prefix) .. " | Type = " .. tostring(_type) .. " | Zones = " .. tostring(_zonetable) .. " | Minrange = " .. tostring(_minrange) .. " | Maxrange = " .. tostring(_maxrange)) end
    local groupClosest = nil
    local distClosest = 99999999
    local setTarget = SET_GROUP:New()
    if _coalition ~= nil then setTarget:FilterCoalitions(_coalition) end
    if _prefix ~= nil then setTarget:FilterPrefixes( _prefix ) end
    if _type ~= nil then setTarget:FilterCategories(_type) end
    if _zonetable ~= nil then setTarget:FilterZones(_zonetable) end
    setTarget:FilterOnce()
    setTarget:ForEachGroupAlive(function(_grp)
        local coordTarget = _grp:GetCoordinate()
        local distTarget = _coord:Get3DDistance(coordTarget)
        if distTarget < distClosest then
            if _minrange == nil or distTarget > _minrange then
                if _maxrange == nil or distTarget < _maxrange then
                    if _coord:IsLOS(coordTarget) then
                        groupClosest = _grp
                        distClosest = distTarget
                    end
                end
            end
        end
    end)
    if groupClosest ~= nil then
        if StatuaTools.DEBUG then env.info("FIND CLOSEST LOS: " .. groupClosest:GetName() .. " is the closest target within LOS of the given coordinate with a range of " .. math.floor(distClosest+0.5) .. "m") end
        return groupClosest, distClosest
    else
        if StatuaTools.DEBUG then env.info("FIND CLOSEST LOS: No targets found within LOS of the provided coordinate and that matches any given parameters.") end
    end
end

--Get nav wind
function StatuaUtils.getNavWind(_coord)
    local height = _coord:GetLandHeight()
    local dir, spd = _coord:GetWind(height+10)
    local windspd = string.format("%02d", math.floor(UTILS.MpsToKnots(spd)+0.5))
    local winddir = string.format("%03d", math.floor(dir+0.5))
    return windspd, winddir
end



--<<<<<<<<<<<<<<<<<<<<<<<<<[RECON DRONE]>>>>>>>>>>>>>>>>>>>>>>>>>--


env.info("STATUA TOOLS: Initializing Recon Drone wrapper")

ReconDrone = {}
--Place a recon marker
--[Target Wrapper.GROUP] [Timeout for solid lines] [Timeout for dotted lines]
function ReconDrone.ReconMark(self, _group,_drawingTimeoutHot,_drawingTimeoutCold)
    local unitTarget = _group:GetUnit(1)
    local _coord = _group:GetCoordinate()
    local _Tnow = timer.getAbsTime()
    local _local_time = UTILS.SecondsToClock(_Tnow)
    local _timestamp = string.format("%s", _local_time)
    local _unittype = unitTarget:GetTypeName()
    local _speed = unitTarget:GetVelocityKMH()
    local _heading = unitTarget:GetHeading()
    local _count = _group:GetUnits()
    local stringStationary = "STATIONARY"
    if _speed > 0 then 
        stringStationary = tostring(math.floor(_speed+0.5)) .. "kph"
        local coordEnd = _coord:Translate(200,_heading,false,false)
        _coord:ArrowToAll(coordEnd, -1, {1,0,0}, 1, {1,0,0}, 0.15, 1, true)
        MARKER:New( _coord,  "T:" .. _timestamp .. "\nTYPE: " ..  _unittype .. "\nSIZE - " .. #_count .. "\nSPEED - " .. stringStationary .. "\nHDG - " .. math.floor(_heading+0.5)):ReadOnly():ToAll()
        TIMER:New(function()
            local allMarks = world.getMarkPanels()
            for k, MarkPanel in pairs(allMarks) do 
                local MarkCoord = COORDINATE:New(MarkPanel.pos.x, MarkPanel.pos.y, MarkPanel.pos.z)
                if MarkCoord:IsInRadius(_coord, 1) or MarkCoord:IsInRadius(coordEnd, 1) then trigger.action.removeMark(MarkPanel.idx) end
            end
            
        _coord:ArrowToAll(coordEnd, -1, {0.5,0,0}, 1, {0.5,0,0}, 0.15, 3, true)
            MARKER:New( _coord,  "T:" .. _timestamp .. "\nTYPE: " ..  _unittype .. "\nSIZE - " .. #_count .. "\nSPEED - " .. stringStationary .. "\nHDG - " .. math.floor(_heading+0.5)):ReadOnly():ToAll()
            TIMER:New(function()
                local allMarks = world.getMarkPanels()
                for k, MarkPanel in pairs(allMarks) do 
                    local MarkCoord = COORDINATE:New(MarkPanel.pos.x, MarkPanel.pos.y, MarkPanel.pos.z)
                    if MarkCoord:IsInRadius(_coord, 1) or MarkCoord:IsInRadius(coordEnd, 1) then trigger.action.removeMark(MarkPanel.idx) end
                end
            end):Start(_drawingTimeoutCold)
        end):Start(_drawingTimeoutHot)
    else
        local coordLine1 = _coord:Translate(200,45,false,false)
        local coordLine2 = _coord:Translate(200,135,false,false)
        local coordLine3 = _coord:Translate(200,225,false,false)
        local coordLine4 = _coord:Translate(200,315,false,false)
        coordLine1:LineToAll(coordLine3,-1,{1,0,0},1,1,true)
        coordLine2:LineToAll(coordLine4,-1,{1,0,0},1,1,true)
        MARKER:New( _coord,  "T:" .. _timestamp .. "\nTYPE: " ..  _unittype .. "\nSIZE - " .. #_count .. "\nSPEED - " .. stringStationary .. "\nHDG - " .. math.floor(_heading+0.5)):ReadOnly():ToAll()
        TIMER:New(function()
            local allMarks = world.getMarkPanels()
            for k, MarkPanel in pairs(allMarks) do 
                local MarkCoord = COORDINATE:New(MarkPanel.pos.x, MarkPanel.pos.y, MarkPanel.pos.z)
                if MarkCoord:IsInRadius(_coord, 1) or MarkCoord:IsInRadius(coordLine1, 1) or MarkCoord:IsInRadius(coordLine2, 1) then trigger.action.removeMark(MarkPanel.idx) end
            end
            coordLine1:LineToAll(coordLine3,-1,{0.5,0,0},1,3,true)
            coordLine2:LineToAll(coordLine4,-1,{0.5,0,0},1,3,true)
            MARKER:New( _coord,  "T:" .. _timestamp .. "\nTYPE: " ..  _unittype .. "\nSIZE - " .. #_count .. "\nSPEED - " .. stringStationary .. "\nHDG - " .. math.floor(_heading+0.5)):ReadOnly():ToAll()
            TIMER:New(function()
                local allMarks = world.getMarkPanels()
                for k, MarkPanel in pairs(allMarks) do 
                    local MarkCoord = COORDINATE:New(MarkPanel.pos.x, MarkPanel.pos.y, MarkPanel.pos.z)
                    if MarkCoord:IsInRadius(_coord, 1) or MarkCoord:IsInRadius(coordLine1, 1) or MarkCoord:IsInRadius(coordLine2, 1) then trigger.action.removeMark(MarkPanel.idx) end
                end
            end):Start(_drawingTimeoutCold)
        end):Start(_drawingTimeoutHot)
    end
end

--Create new FPV drone
--[Wrapper.GROUP] [Max range to detect units] [Total time taken to detect units] [How many segments to work through during the time] [How long drawings last] [How many times to conduct scans (0 = infinite)] [1 = Red | 2 = Blue]
function ReconDrone.NewFPVDrone(self, _group, _range, _time, _segments, _drawingTimeoutHot, _drawingTimeoutCold, _scancount, _coalition)
    env.info("RECON DRONE: New FPV Drone Created | Group: " .. _group:GetName() .. " | Range: " .. _range .. " | Time: " .. _time .. " | Segments: " .. _segments .. " | Hot Timeout: " .. _drawingTimeoutHot .. " | Cold Timeout: " .. _drawingTimeoutCold .. " | Number of Scans: " .. _scancount .. " | Coalition: " .. _coalition .. " |")
    local coordGroup = _group:GetCoordinate()
    local timeStep = _time / _segments
    local rangeStep = _range / _segments
    local function funcStartScan()
        MESSAGE:New("DRONE OPERATOR: Starting an FPV drone recon. We will mark targets we find over the next " .. math.floor((_time/60)+0.5) .. " minutes.", 20, ""):ToAll()
        USERSOUND:New( "squelch2.ogg" ):ToAll()
        for i = 1, _segments do
            TIMER:New(function()
                env.info("RECON DRONE: " .. _group:GetName() .. " running scan #" .. i .. ". " .. (rangeStep*i)-rangeStep .. "/" .. rangeStep*i .. "m")
                local booFoundEnemy = false
                local setEnemy = SET_GROUP:New():FilterCategoryGround():FilterCoalitions(_coalition):FilterOnce()
                setEnemy:ForEachGroupAlive(function(_tgt)
                    local coordTgt = _tgt:GetCoordinate()
                    local distGroup = coordTgt:Get3DDistance(coordGroup)
                    if distGroup > (rangeStep*i)-rangeStep and distGroup <= rangeStep*i then
                        booFoundEnemy = true
                        env.info("RECON DRONE: " .. _tgt:GetName() .. " is in range at " .. distGroup .. "/" .. rangeStep*i .. "m. Adding map marks...")
                        ReconDrone:ReconMark(_tgt,_drawingTimeoutHot,_drawingTimeoutCold)
                    end
                end)
                if booFoundEnemy then
                    MESSAGE:New("DRONE OPERATOR: Marking some targets found between " .. math.floor((((rangeStep*i)-rangeStep)/1000)+0.5) .. "km and " .. math.floor(((rangeStep*i)/1000)+0.5) .. "km", 20, ""):ToAll()
                    USERSOUND:New( "squelch2.ogg" ):ToAll()
                else              
                    MESSAGE:New("DRONE OPERATOR: No targets were found between " .. math.floor((((rangeStep*i)-rangeStep)/1000)+0.5) .. "km and " .. math.floor(((rangeStep*i)/1000)+0.5) .. "km", 20, ""):ToAll()
                    USERSOUND:New( "squelch2.ogg" ):ToAll()
                end

                if i == _segments then
                    env.info("RECON DRONE: Sequence complete for " .. _group:GetName())
                    MESSAGE:New("DRONE OPERATOR: FPV drone recon completed.", 20, ""):ToAll()
                    USERSOUND:New( "squelch2.ogg" ):ToAll()
                end
            end):Start(timeStep*i)
        end
    end
    if _scancount == 0 then
        TIMER:New(function()
            funcStartScan()
        end):Start(nil,_time)
    else
        TIMER:New(function()
            funcStartScan()
        end):SetMaxFunctionCalls(_scancount):Start(nil,_time)
    end
end

--Test recon drone functions
function funcTestRecon()
    setReconTest = SET_GROUP:New():FilterPrefixes("droneTeam"):FilterOnce()
    setReconTest:ForEachGroupAlive(function(_grp)    
        ReconDrone:NewFPVDrone(_grp, 10000, 60, 5, 30, 120, 1, "red")
    end)
end




		--<<<<<<<<<<<<<<<<<<<<<<<<<[MORTAR TEAM]>>>>>>>>>>>>>>>>>>>>>>>>>--


env.info("STATUA TOOLS: Initializing Mortar Team wrapper")

MortarTeam = {}
MortarTeamList = {}
SpotterList = {}
MortarTeam.MessageOutput = true
MortarTeam.MessageOutputExtra = false
MortarTeam.SoundOutput = "squelch2.ogg"
MortarTeam.ArtyCalls = false

--Internal function to make new mortar group
--| Wrapper.GROUP | Max firing range (km) | Min firing range (km) (0 if n/a) | Shots to fire per engagement | Radius of shot spread (m) | Time between last shot and last hit | Use a spotter for detection (true/false) | Enemy coalition (nil if using spotter) | Refresh rate for detection (nil if using spotter)
function MortarTeam.NewMortars(self, _group,_rangeMax,_rangeMin,_shots,_radius,_airtime,_useSpotter,_enemy,_refresh)
    local groupVar = {}
    groupVar.mortarGroup = _group
    groupVar._arty = ARTY:New(_group):SetMaxFiringRange(_rangeMax):SetMinFiringRange(_rangeMin)
    if not MortarTeam.ArtyCalls then groupVar._arty:SetReportOFF() end
    groupVar.artyState = 0 --| 0 = idle | 1 = watching | 2 = engaging | 3 = winchester |
    groupVar.maxRange = _rangeMax
    groupVar.minRange = _rangeMin
    groupVar.useSpotter = _useSpotter
    groupVar.shots = _shots
    groupVar.radius = _radius
    groupVar.assignedSpotter = nil
    env.info("MORTAR TEAM: " .. _group:GetName() .. " added as a mortar group. Range Max/Min: " .. _rangeMax .. "km/" .. _rangeMin .. "m | Shots: " .. _shots .. " | Radius: " .. _radius .. "m | Airtime: " .. _airtime .. "s | Use Spotter: " .. tostring(_useSpotter) .. " | Enemy Coal: " .. _enemy .. " | Refresh Rate: " .. _refresh .. "s")
    
    function groupVar._arty:OnAfterOpenFire(Controllable, From, Event, To, target)
        if MortarTeam.MessageOutput and not MortarTeam.ArtyCalls then 
            MESSAGE:New(_group:GetName() .. ": Opening fire on requested target with " .. _shots .. " shells. ETA to impact is " .. _airtime .. " seconds.", 20, ""):ToAll() 
            USERSOUND:New( "squelch2.ogg" ):ToAll()
        end
    end

    function groupVar._arty:OnAfterCeaseFire(Controllable, From, Event, To, target)
        env.info("MORTAR TEAM: " .. _group:GetName() .. " CEASE FIRE. Airtime = " .. _airtime .. "s")
        TIMER:New(function()
            --env.info("DEBUG: " .. _group:GetName() .. " mission complete. groupVar.assignedSpotter = " .. tostring(groupVar.assignedSpotter))
            if groupVar.assignedSpotter ~= nil then
                SpotterList[groupVar.assignedSpotter].spotState = 0
                env.info("MORTAR TEAM: Setting spotter " .. SpotterList[groupVar.assignedSpotter].group:GetName() .. " to idle.")
                groupVar.assignedSpotter = nil
            end
            if groupVar.artyState ~= 3 then
                groupVar.artyState = 0
                env.info("MORTAR TEAM: " .. _group:GetName() .. " fire mission complete. Now in idle state.")
                if MortarTeam.MessageOutput then 
                    MESSAGE:New(_group:GetName() .. ": Ready for new assignment.", 20, ""):ToAll() 
                    USERSOUND:New( "squelch2.ogg" ):ToAll()
                end
            end
        end):Start(_airtime)
    end
    function groupVar._arty:OnAfterWinchester(Controllable, From, Event, To)
        groupVar.artyState = 3
        env.info("MORTAR TEAM: " .. _group:GetName() .. " now in winchester state.")
        if MortarTeam.MessageOutput then 
            MESSAGE:New(_group:GetName() .. ": We are winchester and require additional shells.", 20, ""):ToAll()
            USERSOUND:New( "squelch2.ogg" ):ToAll()
        end
    end
    function groupVar._arty:OnAfterRearmed(Controllable, From, Event, To)
        groupVar.artyState = 0
        env.info("MORTAR TEAM: " .. _group:GetName() .. " rearmed. Now in idle state.")
        if MortarTeam.MessageOutput then 
            MESSAGE:New(_group:GetName() .. ": Rearmed and ready for assignment.", 20, ""):ToAll() 
            USERSOUND:New( "squelch2.ogg" ):ToAll()
        end
    end
    if not _useSpotter then
        env.info("MORTAR TEAM: " .. _group:GetName() .. " is not using a spotter. Starting search timer repeating every " .. _refresh .. "s")
        groupVar.targetWatching = nil
        TIMER:New(function()
            if groupVar.artyState == 0 then
                local distClosest = 9999999
                local tgtClosest = nil
                local coordArty = _group:GetCoordinate()
                local setEnemy = SET_GROUP:New():FilterCategoryGround():FilterCoalitions(_enemy):FilterOnce()
                setEnemy:ForEachGroupAlive(function(_tgt)
                    local coordTgt = _tgt:GetCoordinate()
                    local distTgt = coordTgt:Get3DDistance(coordArty)
                    local speedTgt = _tgt:GetVelocityKMH()
                    if distTgt < distClosest and speedTgt == 0 and coordArty:IsLOS(coordTgt, 10) then tgtClosest = _tgt end
                end)
                if tgtClosest ~= nil then
                    env.info("MORTAR TEAM: " .. _group:GetName() .. " spotted " .. tgtClosest:GetName() .. " as stationary and is watching for changes.")
                    if MortarTeam.MessageOutput then 
                        MESSAGE:New(_group:GetName() .. ": Spotted stationary target. Monitoring the target for " .. _refresh .. " seconds.", 20, ""):ToAll() 
                        USERSOUND:New( "squelch2.ogg" ):ToAll()
                    end
                    groupVar.targetWatching = tgtClosest
                    groupVar.artyState = 1
                end
            elseif groupVar.artyState == 1 then
                if groupVar.targetWatching ~= nil and groupVar.targetWatching:IsAlive() then
                    env.info("MORTAR TEAM: " .. _group:GetName() .. " will now engage " .. groupVar.targetWatching:GetName())
                    if MortarTeam.MessageOutput then 
                        MESSAGE:New(_group:GetName() .. ": Target is still stationary. We will now engage it.", 20, ""):ToAll() 
                        USERSOUND:New( "squelch2.ogg" ):ToAll()
                    end
                    groupVar._arty:AssignTargetCoord(groupVar.targetWatching:GetCoordinate(), 1, _radius, _shots)
					groupVar._arty:Start()
                    groupVar.artyState = 2
                else
                    groupVar.artyState = 0
                    env.info("MORTAR TEAM: " .. _group:GetName() .. " lost sight of the target and returned to idle state." )
                    if MortarTeam.MessageOutput then 
                        MESSAGE:New(_group:GetName() .. ": Target has moved, searching for more targets.", 20, ""):ToAll() 
                        USERSOUND:New( "squelch2.ogg" ):ToAll()
                    end
                end
            end
        end):Start(_refresh,_refresh)
    end
    return groupVar
end

--Function call to make new Mortar Group
function MortarTeam.New(self, _group,_rangeMax,_rangeMin,_shots,_radius,_airtime,_useSpotter,_enemy,_refresh)
    env.info("MORTAR TEAM: Adding " .. _group:GetName() .. " to the mortar team list." )
    local entry = MortarTeam:NewMortars(_group,_rangeMax,_rangeMin,_shots,_radius,_airtime,_useSpotter,_enemy,_refresh)
    table.insert(MortarTeamList, entry)
end


--Automatically locate a nearby READY mortar team to engage a coordinate
function MortarTeam:AssignTarget(_coord,_spotter)
    env.info("MORTAR TEAM: Looking for a mortar team to assign to the target using spotter ID " .. _spotter )
    local distClosest = 9999999
    local mortarClosest = nil
    for i = 1, #MortarTeamList do
        env.info("DEBUG: Checking " .. MortarTeamList[i].mortarGroup:GetName() )
        local mortarGroup = MortarTeamList[i].mortarGroup
        local coordMortar = mortarGroup:GetCoordinate()
        if coordMortar ~= nil then
            local distMortar = coordMortar:Get3DDistance(_coord)
            env.info("DEBUG: Distance = " .. distMortar )
            if distMortar < distClosest and MortarTeamList[i].artyState == 0 and MortarTeamList[i].maxRange*1000 > distMortar and MortarTeamList[i].minRange*1000 < distMortar and MortarTeamList[i].useSpotter then
                mortarClosest = i
                env.info("DEBUG: This group is the closest with index " .. i )
            end
        end
    end
    if mortarClosest ~= nil then
        MortarTeamList[mortarClosest].assignedSpotter = _spotter
        MortarTeamList[mortarClosest].artyState = 2
        MortarTeamList[mortarClosest]._arty:AssignTargetCoord(_coord, 1, MortarTeamList[mortarClosest].radius, MortarTeamList[mortarClosest].shots)
        MortarTeamList[mortarClosest]._arty:Start()
        return mortarClosest
    else
        return nil
    end
end

--Internal function to make new spotter group
function MortarTeam.NewSpotter(self, _group,_rangeMax,_invMin,_ROE,_enemy,_refresh,_id)
    local groupVar = {}
    _group:OptionROE(_ROE)
	_group:OptionAlarmStateRed()
	_group:SetCommandInvisible(true)
    groupVar.group = _group
    groupVar.spotState = 0 --| 0 = idle | 1 = watching | 2 = engaging |
    groupVar.id = _id
    groupVar.targetWatching = nil
    env.info("MORTAR TEAM: " .. _group:GetName() .. " added as a spotter group. Range Max: " .. _rangeMax .. "km | Inv Min: " .. _invMin .. " | ROE: " .. _ROE .. "m | Enemy Coal: " .. _enemy .. " | Refresh Rate: " .. _refresh .. "s | Table ID : " .. _id)
    
    TIMER:New(function()
        local coordSpot = _group:GetCoordinate()
        if groupVar.spotState == 0 and coordSpot ~= nil then
            local distClosest = 9999999
            local tgtClosest = nil
            local setEnemy = SET_GROUP:New():FilterCategoryGround():FilterCoalitions(_enemy):FilterOnce()
            setEnemy:ForEachGroupAlive(function(_tgt)
                local coordTgt = _tgt:GetCoordinate()
                local distTgt = coordTgt:Get3DDistance(coordSpot)
                local speedTgt = _tgt:GetVelocityKMH()
                if distTgt < distClosest and speedTgt == 0 and coordSpot:IsLOS(coordTgt, 10) and distTgt < _rangeMax*1000 then tgtClosest = _tgt end
            end)
            if tgtClosest ~= nil then
                env.info("MORTAR TEAM: " .. _group:GetName() .. " spotted " .. tgtClosest:GetName() .. " as stationary and is watching for changes.")
                if MortarTeam.MessageOutputExtra then 
                    MESSAGE:New(_group:GetName() .. ": Spotted stationary target. Monitoring the target for " .. _refresh .. " seconds.", 20, ""):ToAll() 
                    USERSOUND:New( "squelch2.ogg" ):ToAll()
                end
                groupVar.targetWatching = tgtClosest
                groupVar.spotState = 1
            end
        elseif groupVar.spotState == 1 and coordSpot ~= nil  then
            if groupVar.targetWatching ~= nil and groupVar.targetWatching:IsAlive() then
                local coordTarget = groupVar.targetWatching:GetCoordinate()
                local mortarID = MortarTeam:AssignTarget(coordTarget,groupVar.id)
                if mortarID ~= nil then
                    env.info("MORTAR TEAM: " .. _group:GetName() .. " will now use " .. MortarTeamList[mortarID].mortarGroup:GetName() .. " to engage " .. groupVar.targetWatching:GetName())
                    if MortarTeam.MessageOutputExtra then 
                        MESSAGE:New(_group:GetName() .. ": Target is still stationary. We will now call on " .. MortarTeamList[mortarID].mortarGroup:GetName() .. " to engage it.", 20, ""):ToAll() 
                        USERSOUND:New( "squelch2.ogg" ):ToAll()
                    elseif MortarTeam.MessageOutput then 
                        MESSAGE:New(_group:GetName() .. ": Has ID on a stationary target. Requesting fire from " .. MortarTeamList[mortarID].mortarGroup:GetName() .. " for engagement.", 20, ""):ToAll() 
                        USERSOUND:New( "squelch2.ogg" ):ToAll()
                    end
                    groupVar.spotState = 2
                else
                    groupVar.spotState = 0
                    env.info("MORTAR TEAM: " .. _group:GetName() .. " could not find a mortar team to engage " .. groupVar.targetWatching:GetName())
                    if MortarTeam.MessageOutputExtra then 
                        MESSAGE:New(_group:GetName() .. ": Could not find a mortar team to engage our target.", 20, ""):ToAll() 
                        USERSOUND:New( "squelch2.ogg" ):ToAll()
                    end
                end
            else
                groupVar.spotState = 0
                env.info("MORTAR TEAM: " .. _group:GetName() .. " lost sight of the target and returned to idle state." )
                if MortarTeam.MessageOutputExtra then 
                    MESSAGE:New(_group:GetName() .. ": Target has moved, searching for more targets.", 20, ""):ToAll() 
                    USERSOUND:New( "squelch2.ogg" ):ToAll()
                end
            end
        end
    end):Start(_refresh,_refresh)
    return groupVar
end

--Function call to make new spotter group
--(Wrapper.GROUP, Max detection range, Use LOS to detect, Min distance to be invsible, ROE: "WeaponHold" | 'ReturnFire' | "WeaponFree"]
function MortarTeam.Spotter(self, _group,_rangeMax,_invMin,_ROE,_enemy,_refresh)
    env.info("MORTAR TEAM: Adding " .. _group:GetName() .. " to the spotter list." )
    local _id = #SpotterList + 1
    local entry = MortarTeam:NewSpotter(_group,_rangeMax,_invMin,_ROE,_enemy,_refresh,_id)
    table.insert(SpotterList, entry)
end

--Function to call to assign infantry as a mobile mortar team
function MortarTeam.Crew(self, _group, _template, _rangeMax,_rangeMin,_shots,_radius,_airtime,_useSpotter,_enemy,_refresh)
    local self = {}
    env.info("MORTAR TEAM: " .. _group:GetName() .. " added as a mortar crew. Template: " .. _template .. " | Range Max/Min: " .. _rangeMax .. "km/" .. _rangeMin .. "m | Shots: " .. _shots .. " | Radius: " .. _radius .. "m | Airtime: " .. _airtime .. "s | Use Spotter: " .. tostring(_useSpotter) .. " | Enemy Coal: " .. _enemy .. " | Refresh Rate: " .. _refresh .. "s")
    self.IsStationary = false
    self.IsSetup = false
    self.Index = math.random(1,1000)
    self.mortar = nil
    self.SpawnMortar = SPAWN:NewWithAlias(_template, _template .. self.Index)
    self.SpawnMortar:OnSpawnGroup(function(_group)
        self.mortar = _group
        MortarTeam:New(_group,_rangeMax,_rangeMin,_shots,_radius,_airtime,_useSpotter,_enemy,_refresh)
    end)
    TIMER:New(function()
        local coordGroup = _group:GetCoordinate()
        if coordGroup ~= nil then
            local speedGroup = _group:GetVelocityKMH()
            if speedGroup < 1 then
                if not self.IsStationary then
                    self.IsStationary = true
                    if MortarTeam.MessageOutput then 
                        MESSAGE:New(_group:GetName() .. ": We are setting up mortars now at our present position. ETA " .. _refresh .. "seconds.", 20, ""):ToAll() 
                        USERSOUND:New( "squelch2.ogg" ):ToAll()
                    end
                    env.info("MORTAR TEAM: " .. _group:GetName() .. " stopped and is setting up mortars.")
                elseif self.IsStationary and not self.IsSetup then
                    env.info("MORTAR TEAM: " .. _group:GetName() .. " will spawn mortars now.")
                    self.SpawnMortar:SpawnFromCoordinate(coordGroup)
                    self.IsSetup = true
                    if MortarTeam.MessageOutput then 
                        MESSAGE:New(_group:GetName() .. ": We have set the mortars and ready for fire missions.", 20, ""):ToAll() 
                        USERSOUND:New( "squelch2.ogg" ):ToAll()
                    end
                end
            elseif self.IsSetup then             
                env.info("MORTAR TEAM: " .. _group:GetName() .. " is moving and will destroy mortars.")
                self.mortar:Destroy()
                self.IsSetup = false
                self.IsStationary = false
                if MortarTeam.MessageOutput then 
                    MESSAGE:New(_group:GetName() .. ": Mortars have been dismantled as we are relocating.", 20, ""):ToAll() 
                    USERSOUND:New( "squelch2.ogg" ):ToAll()
                end
            else
                self.IsSetup = false
                self.IsStationary = false
            end
        end
    end):Start(_refresh,_refresh)
    return self
end





--<<<<<<<<<<<<<<<<<<<<<<<<<[JTAC Autolase]>>>>>>>>>>>>>>>>>>>>>>>>>--


env.info("STATUA TOOLS: Initializing JTAC wrapper")
JtacLaser = {}
JtacLaser.tableJTACs = {}
JtacLaser.tableCodes = UTILS.GenerateLaserCodes()
JtacLaser.callsignTable = {
    "DARKHORSE",
  "LIGHTHOUSE",
  "WARHAMMER",
  "SNAKE EYES",
  "OVERWATCH",
  "EAGLE EYE",
  "GHOST RIDER",
  "PATHFINDER",
  "WATCHTOWER",
  "WATCHDOG",
  "THUNDER",
  "FIREBIRD",
  "BULLDOG",
  "PERISCOPE",
  "HAWKEYE",
  "NOMAD"
}

JtacLaser.Active = false

--Get a new callsign for the JTAC
function JtacLaser.GetCallsign(_group)
    local newCallsign = _group:GetName()
    if #JtacLaser.callsignTable ~= 0 then
        local indexCallsign = math.random(#JtacLaser.callsignTable)
        newCallsign = JtacLaser.callsignTable[indexCallsign]
        table.remove(JtacLaser.callsignTable, indexCallsign)
    end
    return newCallsign
end

--Check all active JTACs in the AO
function JtacLaser.CheckJTAC(_coalition)
    env.info("JTAC: Checking JTAC status. Table size = "..#JtacLaser.tableJTACs)
    local foundActive = false
    if #JtacLaser.tableJTACs > 0 then
        for i = 1, #JtacLaser.tableJTACs do
            env.info("JTAC: Checking group with callsign "..JtacLaser.tableJTACs[i].Callsign.." | Alive = " .. tostring(JtacLaser.tableJTACs[i].Alive))
            if JtacLaser.tableJTACs[i].Alive then
                local groupJTAC = JtacLaser.tableJTACs[i].Group 
                local nameJTAC = groupJTAC:GetName()
                env.info("JTAC: Group name = "..tostring(nameJTAC))
                if nameJTAC ~= nil then
                    JtacLaser.tableJTACs[i].CheckStatus()
                    foundActive = true
                end
            end
        end
    end
    if not foundActive then
        MESSAGE:New("There are no active JTACs in the AO.", 10, ""):ToCoalition(_coalition)
    end
end

--Start the JTAC class
function JtacLaser.Activate(_coalition)
    JtacLaser.Active = true
    if _coalition == "blue" then _coalition = coalition.side.BLUE else _coalition = coalition.side.RED end
    JtacLaser.MenuBase = MENU_COALITION:New( _coalition, "JTAC",CASroot )
    MENU_COALITION_COMMAND:New( _coalition,"Check all JTAC Status",JtacLaser.MenuBase,JtacLaser.CheckJTAC,_coalition)
end


--Internal function to create a new JTAC unit
function JtacLaser:NewJTAC(_group, _coalition, _searchrate, _laserate, _code, _range)
    if JtacLaser.Active then
        local obj = {}
        obj.Group = _group
        obj.Groupname = _group:GetName()
        obj.Callsign = JtacLaser.GetCallsign(_group)
        local unitTable = _group:GetUnits()
        obj.Unit = unitTable[1]
        obj.Code = _code
        --obj.Laser = SPOT:New(obj.Unit)
        obj.Searchrate = _searchrate
        obj.Laserate = _laserate
        obj.RangeMax = _range
        obj.Coalition = _coalition
        obj.CoalitionSide = coalition.side.BLUE
        if _coalition == "red" then obj.CoalitionSide = coalition.side.RED end
        obj.EnemyCoalition = "red"
        obj.EnemyGroup = nil
        obj.EnemyDist = nil
        obj.EnemyHdg = nil
        if obj.Coalition == "red" then obj.EnemyCoalition = "blue" end
        obj.State = 0 -- [0 = idle]  [1 = watching] [2 = lasing]
        obj.Alive = true
        obj.LaseTimer = nil
        obj.isLasing = false
        obj.LaseIR = nil
        obj.LaseSpot = nil
        obj.HotLase = false

        --Generate new code
        function obj.NewCode()
            if obj.State == 2 then obj.ToggleLaser(true) end
            local oldCode = obj.Code
            while oldCode == obj.Code do
                obj.Code = JtacLaser.tableCodes[math.random(#JtacLaser.tableCodes)]
            end
            MESSAGE:New(obj.Callsign .. " new laser code " .. obj.Code,20):ToCoalition(obj.CoalitionSide)
        end

        --Disable the JTAC wrapper
        function obj.KillJTAC()
            env.info("JTAC: " .. obj.Groupname .. " no longer exists. All functions have been ended.")
            MESSAGE:New(obj.Callsign .. " is no longer active in the AO.",20):ToCoalition(obj.CoalitionSide)
            obj.Alive = false
            obj.MenuLaserToggle:Remove()
            obj.MenuStatus:Remove()
            obj.MenuNewCode:Remove()
            obj.MenuSubcat:Remove()
            obj.SearchTimer:Stop()
            if obj.LaseTimer ~= nil then 
                obj.LaseTimer:Stop()
                --obj.Laser:LaseOff()
                obj.LaseIR:destroy()
                obj.LaseSpot:destroy()
            end
        end

        --Toggle Laser to be Always On
        function obj.AlwaysLase()
            if not obj.HotLase then
                obj.HotLase = true
                MESSAGE:New(obj.Callsign .. " will paint all targets automatically.",20):ToCoalition(obj.CoalitionSide)
            else
                obj.HotLase = false
                MESSAGE:New(obj.Callsign .. " will only paint targets if requested.",20):ToCoalition(obj.CoalitionSide)
            end
        end

        --Check status of the current JTAC unit
        function obj.CheckStatus()
            --local mgrsJTAC = obj.Group:GetCoordinate():ToStringMGRS(SETTINGS:SetMGRS_Accuracy(3))
            local mgrsJTAC = string.gsub(obj.Group:GetCoordinate():GetName(), "MGRS %w%w%w%s", "")
            if obj.State == 0 then
                MESSAGE:New(obj.Callsign .. " positioned at " .. mgrsJTAC .. " does not have any targets." , 20):ToCoalition(obj.CoalitionSide)
            end
            if obj.State == 1 then
                local mgrsTarget = string.gsub(obj.EnemyGroup:GetCoordinate():GetName(), "MGRS %w%w%w%s", "")
                MESSAGE:New(obj.Callsign .. " positioned at " .. mgrsJTAC .. " is OBSERVING a " .. obj.EnemyGroup:GetTypeName() .. " for " .. math.floor((obj.EnemyDist/1000)+0.5) .. "km at heading " .. obj.EnemyHdg .. " from our position. Target grid is " .. mgrsTarget .. ", over.", 30):ToCoalition(obj.CoalitionSide) 
            end
            if obj.State == 2 then
                local mgrsTarget = string.gsub(obj.EnemyGroup:GetCoordinate():GetName(), "MGRS %w%w%w%s", "")
                MESSAGE:New(obj.Callsign .. " positioned at " .. mgrsJTAC .. " is PAINTING a " .. obj.EnemyGroup:GetTypeName() .. " with code " .. obj.Code .. " for " .. math.floor((obj.EnemyDist/1000)+0.5) .. "km at heading " .. obj.EnemyHdg .. " from our position. Target grid is " .. mgrsTarget .. ", over.", 30):ToCoalition(obj.CoalitionSide) 
            end
        end

        --Laser Timer
        obj.LaseTimer = TIMER:New(function()
            if obj.Group:GetName() ~= nil and obj.Group:IsAlive() then
                if obj.EnemyGroup:GetName() ~= nil and obj.EnemyGroup:IsAlive() then
                    local coordLaser = obj.EnemyGroup:GetCoordinate()
                    if obj.Unit:GetCoordinate():IsLOS(coordLaser) and obj.State == 2 and obj.Unit:GetCoordinate():Get3DDistance(coordLaser) < obj.RangeMax then
                        if not obj.isLasing then
                            --obj.Laser:LaseOn(obj.EnemyGroup, obj.Code)
                            obj.LaseIR = Spot.createInfraRed(obj.Unit:GetDCSObject(),{x=0,y=1,z=0},coordLaser:GetVec3())
                            obj.LaseSpot = Spot.createLaser(obj.Unit:GetDCSObject(),{x=0,y=1,z=0},coordLaser:GetVec3(),obj.Code)
                            obj.isLasing = true
                        else
                            obj.LaseIR:setPoint(coordLaser:GetVec3())
                            obj.LaseSpot:setPoint(coordLaser:GetVec3())
                        end
                    elseif obj.State == 2 then
                        obj.LaseTimer:Stop()
                        --obj.Laser:LaseOff()
                        obj.LaseIR:destroy()
                        obj.LaseSpot:destroy()
                        obj.State = 0
                        obj.isLasing = false
                        MESSAGE:New(obj.Callsign .. " lost visual with the target. Returning to search pattern.",20):ToCoalition(obj.CoalitionSide)
                    end
                else
                    obj.LaseTimer:Stop()
                    --obj.Laser:LaseOff()
                    TIMER:New(function()
                        obj.LaseIR:destroy()
                        obj.LaseSpot:destroy()
                        obj.State = 0
                        obj.isLasing = false
                        MESSAGE:New("This is " .. obj.Callsign .. ", our target has been destroyed. Returning to search pattern.",20):ToCoalition(obj.CoalitionSide)
                    end):Start(5)
                end
            else
                obj.KillJTAC()
            end
        end)

        --Toggle the laser on if able
        function obj.ToggleLaser(_man)
            if _man and obj.HotLase then
                obj.HotLase = false
                MESSAGE:New(obj.Callsign .. " will no longer automatically lase targets.",20):ToCoalition(obj.CoalitionSide)
            end
            if obj.State == 1 and obj.EnemyGroup:GetName() ~= nil then
                obj.State = 2
                obj.LaseTimer:Start(nil,obj.Laserate)
                local mgrsTarget = string.gsub(obj.EnemyGroup:GetCoordinate():GetName(), "MGRS %w%w%w%s", "")
                MESSAGE:New(obj.Callsign .. " Laser ON for a " .. obj.EnemyGroup:GetTypeName() .. " with code " .. obj.Code .. " at heading " .. obj.EnemyHdg .. " for " .. math.floor((obj.EnemyDist/1000)+0.5) .. " km. Target grid is " .. mgrsTarget .. ", over.",20):ToCoalition(obj.CoalitionSide)
            elseif obj.State == 2 then
                obj.State = 1
                obj.LaseTimer:Stop()
                --obj.Laser:LaseOff()
                obj.LaseIR:destroy()
                obj.LaseSpot:destroy()
                obj.isLasing = false
                MESSAGE:New(obj.Callsign .. " received. Laser OFF and returning to observation only.",20):ToCoalition(obj.CoalitionSide)
            elseif obj.State == 0 then
                MESSAGE:New(obj.Callsign .. " does not have anything to lase!",20):ToCoalition(obj.CoalitionSide)
            end
        end

        --Set up menu on spawn
        obj.MenuSubcat = MENU_COALITION:New( coalition.side.BLUE, obj.Callsign,JtacLaser.MenuBase )
        obj.MenuStatus = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Check Status",obj.MenuSubcat,obj.CheckStatus)
        obj.MenuLaserToggle = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Toggle Laser ON/OFF",obj.MenuSubcat,obj.ToggleLaser,true)
        obj.MenuHotLaser = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Toggle Autolase",obj.MenuSubcat,obj.AlwaysLase)
        obj.MenuNewCode = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Get New Code",obj.MenuSubcat,obj.NewCode)

        MESSAGE:New(obj.Callsign .. " is JTAC and active in the field. We are searching for targets.",20):ToCoalition(obj.CoalitionSide)

        --Search timer loop
        obj.SearchTimer = nil
        obj.Tracktimer = nil
        obj.SearchTimer = TIMER:New(function()
            local nilCheck = obj.Group:GetName()
            if nilCheck ~= nil and obj.Group:IsAlive() then
                if obj.State == 0 then
                    local coordJTAC = obj.Group:GetCoordinate()
                    local enemyGroup, enemyDist = StatuaUtils.FindClosestLOSinSET(coordJTAC,obj.EnemyCoalition,nil,"ground",nil,nil,obj.RangeMax)
                    if enemyGroup ~= nil then
                        obj.EnemyGroup = enemyGroup
                        obj.EnemyDist = enemyDist
                        obj.State = 1
                        obj.EnemyHdg = math.floor((obj.Group:GetCoordinate():HeadingTo(obj.EnemyGroup:GetCoordinate()))+0.5)
                        if obj.HotLase then
                            MESSAGE:New(obj.Callsign .. " contact! We have visual with a " .. obj.EnemyGroup:GetTypeName() .. " and will begin painting the target.", 20):ToCoalition(obj.CoalitionSide)
                            TIMER:New(function() obj.ToggleLaser(false) end):Start(5)
                        else
                            local mgrsTarget = string.gsub(obj.EnemyGroup:GetCoordinate():GetName(), "MGRS %w%w%w%s", "")
                            MESSAGE:New(obj.Callsign .. " contact! We have visual with a " .. obj.EnemyGroup:GetTypeName() .. " at heading " .. obj.EnemyHdg .. " for " .. math.floor((obj.EnemyDist/1000)+0.5) .. " km. Target grid is " .. mgrsTarget .. ". Please advise if target requires laser designation.",30):ToCoalition(obj.CoalitionSide)
                        end
                    end
                elseif obj.State == 1 then
                    local enemyGroup, enemyDist = StatuaUtils.FindClosestLOSinSET(obj.Group:GetCoordinate(),obj.EnemyCoalition,nil,"ground",nil,nil,obj.RangeMax)
                    if enemyGroup == nil then
                        obj.EnemyGroup = nil
                        obj.EnemyDist = nil
                        obj.EnemyHdg = nil
                        obj.State = 0
                        MESSAGE:New(obj.Callsign .. " lost visual with the target. No other threats located in the area. Resuming observation.",20):ToCoalition(obj.CoalitionSide)
                    elseif enemyGroup:GetName() ~= obj.EnemyGroup:GetName() then
                        obj.EnemyGroup = enemyGroup
                        obj.EnemyDist = enemyDist
                        obj.State = 1
                        obj.EnemyHdg = obj.Group:GetCoordinate():HeadingTo(obj.EnemyGroup:GetCoordinate())
                        local mgrsTarget = string.gsub(obj.EnemyGroup:GetCoordinate():GetName(), "MGRS %w%w%w%s", "")
                        MESSAGE:New(obj.Callsign .. " contact update! We have visual with a " .. obj.EnemyGroup:GetTypeName() .. " at heading " .. obj.EnemyHdg .. " for " .. math.floor((obj.EnemyDist/1000)+0.5) .. " km. Target grid is " .. mgrsTarget .. ". Please advise if target requires laser designation.",30):ToCoalition(obj.CoalitionSide)
                    end
                end
            else
                obj.KillJtac()
            end
        end)
        obj.SearchTimer:Start(_searchrate,_searchrate)
        env.info("JTAC LASER: New JTAC group created with " .. _group:GetName() .. " using unit " .. obj.Unit:GetName() .. " as the JTAC unit. Coalition: " .. _coalition .. " | Search Rate: " .. _searchrate .. "s | Lase Rate: " .. _laserate .. "s | Code: " .. _code)
        setmetatable(obj, self)
        self.__index = self
        return obj
    else
        env.info("JTAC LASER: ERROR! Can't create a new JTAC until you activate the class!")
    end
end

--Function to call to create a new JTAC

function JtacLaser.CreateJTAC(_group, _coalition, _searchrate, _laserate, _code, _range)
    TIMER:New(function()
        local newJTAC = JtacLaser:NewJTAC(_group, _coalition, _searchrate, _laserate, _code, _range)
        table.insert(JtacLaser.tableJTACs, newJTAC)
    end):Start(1)
end





--<<<<<<<<<<<<<<<<<<<<<<<<<[Weapon Crew]>>>>>>>>>>>>>>>>>>>>>>>>>--


env.info("STATUA TOOLS: Initializing Weapon Crew wrapper")
WeaponCrew = {}
WeaponCrew.idSet = 1
function WeaponCrew.NewCrew(_crew,_weaponstring,_refresh,_setupmult,_msgsetup,_msgmoving,_camopantsRange)
    local obj = {}
    obj.Group = _crew
    obj.GroupName = _crew:GetName()
    obj.WepID = WeaponCrew.idSet
    WeaponCrew.idSet = WeaponCrew.idSet + 1
    obj.WepGroup = nil
    obj.SpawnWep = SPAWN:NewWithAlias(_weaponstring,_weaponstring .. "_" .. obj.WepID)
    obj.SpawnWep:OnSpawnGroup(function(_grp) 
        obj.WepGroup = _grp 
        if _camopantsRange ~= nil then
            CamoPants.New(_grp,10,_camopantsRange,true,_camopantsRange*3,120)
        end
        env.info("WEAPON CREW: " .. obj.GroupName .. " set up a weapon group " .. _grp:GetName())
    end)
    obj.Moving = true
    obj.Setup = 0
    obj.UpdateTimer = TIMER:New(function()
        if obj.Group:GetName() ~= nil and obj.Group:IsAlive() then
            local speedGroup = obj.Group:GetVelocityKMH()
            if speedGroup < 1 and obj.Moving then
                obj.Setup = obj.Setup + 1
                if obj.Setup == _setupmult then
                    obj.Moving = false
                    local hdgGroup = obj.Group:GetHeading()
                    local coordGroup = obj.Group:GetCoordinate()
                    coordGroup:Translate(3,hdgGroup,false,true)
                    obj.SpawnWep:SpawnFromCoordinate(coordGroup)
                    if _msgsetup ~= nil then
                        MESSAGE:New(_msgsetup,30):ToAll()
                    end
                end
            elseif speedGroup > 1 and not obj.Moving then
                obj.Setup = 0
                obj.Moving = true
                if obj.WepGroup ~= nil then
                    obj.WepGroup:Destroy()
                    obj.WepGroup = nil
                    if _msgmoving ~= nil then
                        MESSAGE:New(_msgmoving,30):ToAll()
                    end
                    env.info("WEAPON CREW: " .. obj.GroupName .. " dismantled their weapon as they are moving.")
                end
            end
        else
            obj.UpdateTimer:Stop()
            env.info("WEAPON CREW: " .. obj.GroupName .. " was killed or extracted.")
            if obj.WepGroup ~= nil then
                obj.WepGroup:Destroy()
                obj.WepGroup = nil
                env.info("WEAPON CREW: " .. obj.GroupName .. "'s weapon was dismantled.")
            end
        end
    end)
    obj.UpdateTimer:Start(_refresh,_refresh)
    env.info("WEAPON CREW: New crew created with " .. obj.GroupName .. " using " .. _weaponstring .. " as the weapon.")
end





--<<<<<<<<<<<<<<<<<<<<<<<<<[Camo Pants]>>>>>>>>>>>>>>>>>>>>>>>>>--


env.info("STATUA TOOLS: Initializing Camo Pants controller")
CamoPants = {}
function CamoPants.New(_group,_updateRate,_rangeUnmask,_shootUnmask,_shootUnmaskRange,_shootUnmaskTime)
    local obj = {}
    local enemyCoalition = "red"
    local isHidden = false
    local cooldownShoot = false
    local cooldownShootCheck = false

    --Invisibility based on range
    if _group:GetCoalition() == coalition.side.RED then enemyCoalition = "blue" end
    obj.timerCamo = TIMER:New(function()
        if _group:GetName() ~= nil and _group:IsAlive() then
            if not cooldownShoot then
                local coordGroup = _group:GetCoordinate()
                local enemyGroup, enemyDist = StatuaUtils.FindClosestLOSinSET(coordGroup,enemyCoalition,nil,nil,nil,nil,_rangeUnmask)
                if enemyGroup ~= nil and isHidden then
                    _group:SetCommandInvisible(false)
                    isHidden = false
                    env.info("CAMO PANTS: " .. _group:GetName() .. " was detected by " .. enemyGroup:GetName() .. ": " .. math.floor(enemyDist+0.5) .. "/" .. _rangeUnmask)
                elseif not isHidden then
                    _group:SetCommandInvisible(true)
                    isHidden = true
                    env.info("CAMO PANTS: " .. _group:GetName() .. " is hidden again.")
                end
            end
        else
            obj.timerCamo:Stop()
        end
    end)
    obj.timerCamo:Start(nil,_updateRate)

    --Visible after shooting
    if _shootUnmask then
        local function CheckShooting()
            local coordGroup = _group:GetCoordinate()
            local enemyGroup, enemyDist = StatuaUtils.FindClosestLOSinSET(coordGroup,enemyCoalition,nil,nil,nil,nil,_shootUnmaskRange)
            if enemyGroup ~= nil and isHidden then
                cooldownShoot = true
                _group:SetCommandInvisible(false)
                isHidden = false
                env.info("CAMO PANTS: " .. _group:GetName() .. " fired their weapon and was detected by " .. enemyGroup:GetName() .. ": " .. math.floor(enemyDist+0.5) .. "/" .. _shootUnmaskRange)
                TIMER:New(function() 
                    cooldownShoot = false
                    isHidden = true
                    if _group:GetName() ~= nil and _group:IsAlive() then
                        _group:SetCommandInvisible(true)
                        env.info("CAMO PANTS: " .. _group:GetName() .. " is hidden again.")
                    end
                end):Start(_shootUnmaskTime)
            end
        end

        _group:HandleEvent( EVENTS.ShootingStart  )
        function _group:OnEventShootingStart( EventData )
            if not cooldownShootCheck then
                cooldownShootCheck = true              
                TIMER:New(function() cooldownShootCheck = false end):Start(5)
                
                if not cooldownShoot and isHidden then
                    CheckShooting()
                end
            end
        end

        _group:HandleEvent( EVENTS.Shot  )
        function _group:OnEventShot( EventData )    
            if not cooldownShoot and isHidden then
                CheckShooting()
            end
        end
    end
    env.info("CAMO PANTS: " .. _group:GetName() .. " was assigned parameters for dynamic invisibility.")
end



--<<<<<<<<<<<<<<<<<<<<<<<<<[Simple Slot Blocking]>>>>>>>>>>>>>>>>>>>>>>>>>--

env.info("STATUA TOOLS: Initializing Slot Blocking constructor")

-- STATUASB = {}
-- STATUASB.Net = NET:New()
-- function STATUASB:BlockTest(_slotname)
--     local _client = CLIENT:FindByName(_slotname)
--     env.info("DEBUG: Attempting to block slot " .. _slotname)
--     STATUASB.Net:BlockPlayer(_client,nil,nil,"Cockblocked!")
-- end

-- function testblock(_name)
--     STATUASB:BlockTest(_name)
-- end



-- !XX! !XX! !XX! >>>>TESTING FUNCTION<<<< !XX! !XX! !XX!--

-- TIMER:New(function()
--     env.info("DEBUG: Spawning test group.")
--     trigger.action.outText("DEBUG: Spawning test group.",20)
--     local spawnTest = SPAWN:New("testgroup"):OnSpawnGroup(function(_grp)
--         --What to do on group spawn
--         WeaponCrew.NewCrew(_grp,"testSniper",10,3,"Sniper team is set up and ready for action!","Sniper team has packed up and is on the move.",500)
--         CamoPants.New(_grp,10,500,true,1500,120)
--     end)
--     spawnTest:Spawn()
-- end):Start(5)





env.info("STATUA TOOLS: Statua Tools framework loaded successfully!")