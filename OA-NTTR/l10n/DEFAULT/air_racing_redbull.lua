local wpPrefix = 'w-'

local wpCount = 0
for i=1,10000,1 do
	local z = wpPrefix..i
	local zn = trigger.misc.getZone(z)
	if not zn then
		wpCount = i - 1
		break
	end
end

local function mag(vec)
	return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
end
	
--[[
local function makeVec3(vec, y)
	if not vec.z then
		if vec.alt and not y then
			y = vec.alt
		elseif not y then
			y = 0
		end
		return {x = vec.x, y = y, z = vec.y}
	else
		return {x = vec.x, y = vec.y, z = vec.z}
	end
end
--]]

local function getDist(point1, point2)
	return mag({x = point1.x - point2.x, y = point1.y - point2.y, z = point1.z - point2.z})
end

local function getPointOnSurface(point)
	return {x = point.x, y = land.getHeight({x = point.x, y = point.z}), z= point.z}
end
--[[
timer.scheduleFunction(function(param, time)
	for i=1,wpCount,1 do
		local z = wpPrefix..i
		local zn = trigger.misc.getZone(z)
		
		local p = getPointOnSurface(zn.point)
		
		trigger.action.smoke(p, (i%3)+1)
	end
	
	return time+290
end,{},timer.getTime()+2)
]]--

local data = {}
data.playerBest = {}
data.pdata = {}
data.bestPl = nil

--nextWp = 1
--doneWp = 0
--startTime = 0
--endTime = 0
timer.scheduleFunction(function(param,time)
	local players = coalition.getPlayers(2)
	for i,v in ipairs(players) do
		local pl = v
		
		local pname = pl:getPlayerName()
		local ptype = pl:getDesc().typeName
		
		if param.pdata[pname] then

			local nextWp = param.pdata[pname].nextWp
			local doneWp = param.pdata[pname].doneWp
			local startTime = param.pdata[pname].startTime
			local endTime = param.pdata[pname].endTime
					
			local pd = pl:getPoint()
			for i=nextWp,wpCount,1 do
				local z = wpPrefix..i
				local zn = trigger.misc.getZone(z)
				local p = getPointOnSurface(zn.point)
				local d = getDist(pd, p)
				if d <= zn.radius then
					doneWp = doneWp + 1
					
					if i == 1 then
						--first wp
						startTime = time
						trigger.action.outText('['..doneWp..'/'..wpCount..']['..z..'] started.\n\nName: '..pname..'\nAircraft: '..ptype,5)
						nextWp = i + 1
					elseif i == wpCount then
						--last wp
						endTime = time
						
						local penalties = wpCount-doneWp
						local runTime = (endTime-startTime) + (penalties*10)
						trigger.action.outText('['..doneWp..'/'..wpCount..']['..z..'] ended.\n\nName: '..pname..'\nTime: '..runTime..' sec ('..penalties..' penalties)\nAircraft: '..ptype,60)
						
						if param.playerBest[pname] == nil then
							trigger.action.outText('New personal best (since mission start).\nPlayer: '..pname..'\nTime: '..runTime,60)
							param.playerBest[pname] = {time = runTime, type = ptype}
						elseif runTime < param.playerBest[pname].time then
							trigger.action.outText('New personal best (since mission start).\nPlayer: '..pname..'\nTime: '..runTime..'\n-'..param.playerBest[pname].time - runTime..'sec',60)
							param.playerBest[pname] = {time = runTime, type = ptype}
						end
						
						if param.bestPl == nil or runTime < param.bestPl.time then
							param.bestPl = {name = pname, time = runTime, aircraft = ptype}
							trigger.action.outText('New leader(since mission start).\nPlayer: '..pname..'\nTime: '..runTime..'\nAircraft: '..ptype,60)
						end

						nextWp = wpCount + 1
					elseif i ~= nextWp then
						nextWp = i + 1 -- missed wp
						trigger.action.outTextForUnit(pl:getID(),'['..doneWp..'/'..wpCount..']['..z..'] WP missed.\n\nName: '..pname..'\nTime: '..time-startTime..' sec\nAircraft: '..ptype,5)
					else
						nextWp = nextWp + 1
						trigger.action.outTextForUnit(pl:getID(),'['..doneWp..'/'..wpCount..']['..z..']\n\nName: '..pname..'\nTime: '..time-startTime..' sec\nAircraft: '..ptype,5)
					end
					
					break
				end
			end
			
			param.pdata[pname].nextWp = nextWp
			param.pdata[pname].doneWp = doneWp
			param.pdata[pname].startTime = startTime
			param.pdata[pname].endTime = endTime
		end
	end
	
	return time+0.1
end,data,timer.getTime()+2)

local ev = {}
function ev:onEvent(event)
	if (event.id==20 or event.id==15) and event.initiator and event.initiator.getPlayerName then
		local pname = event.initiator:getPlayerName()
		if pname then
		    env.info("Player ["..pname.."] initialized.")
			data.pdata[pname] = {nextWp = 1, doneWp = 0, startTime = 0, endTime = 0}
		end
	end
end

world.addEventHandler(ev)

missionCommands.addCommand('Show RedBull leaderboard', nil, function()
	local sorted = {}

	for i,v in pairs(data.playerBest) do table.insert(sorted,{i,v}) end
	
	table.sort(sorted, function(a,b) return a[2].time< b[2].time end)
	
	local outstr = "RedBull Leaderboard"
	for i,v in ipairs(sorted) do
		outstr = outstr..'\n'..i..'. '..v[1]..' ['..v[2].type..'] '..v[2].time..' sec'
	end
	
	trigger.action.outText(outstr, 30)
end)