if not enet then enet = require 'enet' end 
if not json then json = require 'json' end 
if not EGA then dofile('lib.lua') end --local m = lovr.filesystem.load('src/lib.lua'); m() end 

serverTick = (1/40)
local credentials = 'bot/pass'
local isLoggedIn = false
local isConnected = false
local isLoggingIn = false
local firstUpdate = true 

-- Connect
local host = enet.host_create(nil, 64, 2, 0, 0)
-- Ben's AWS 01:
local server= host:connect("54.196.121.96:33111", 2)

local packets = require 'packets'
local action_types = require 'action_types'

local t = os.clock()
local time 
local pings = {}
local lastPing = 99
local lastBroadcast = 99
clientId = 0
TICK = false
local broadcasts = {}
currentState = {}
myPlayerState = {
    pos = { x = 0.0, y = 2.0, z = 0.0 },
    rot = { x = 0.0, y = 0.0, z = 1.0, m = 0.0 },
    lHandPos = { x = 0.0, y = 0.0, z = 0.0 },
    lHandRot = { x = 0.0, y = 0.0, z = 0.0, m = 0.0 },
    lHandObj = '',
    rHandPos = { x = 0.0, y = 0.0, z = 0.0 },
    rHandRot = { x = 0.0, y = 0.0, z = 0.0, m = 0.0 },
    rHandObj = '',
    faceTx = '',
    bodyTx = '',
    action = ''
}

UPDATE_ME = false
local cycles = 0

function ANSI_CLR()
    print(string.format("%c[2J%c[0%c[99A%c[99D", 0x1b, 0x1b, 0x1b, 0x1b))
end

function ANSI_RESET()
    print(string.format("%c[0m", 0x1b))
end

local timealive = { h = 0, m = 0, s = 0 }
start = os.time()
timeElapsed = 0.0
totalSeconds = 0



-- Main display fucntion 
function UpdateScreen()

    ANSI_CLR()
    
    local li
    if isLoggedIn then li = string.format("%c[42m", 0x1b) else li = string.format("%c[41m", 0x1b) end 
    timealive.s = os.time() - start 
    if timealive.s % 60 == 0 then ms_offset = 0.0 end 
    timealive.m = timealive.s / 60; timealive.s = timealive.s % 60 
    timealive.h = timealive.m / 60; timealive.m = timealive.m % 60 
    print("Time alive: " .. math.floor(timealive.h) .. 'h:' .. math.floor(timealive.m) .. 
        'm:' .. math.floor(timealive.s) .. "s || Cycles: " .. cycles .. " || Id : " .. clientId .. ' || ' .. li.. 'O')
    ANSI_RESET()
    
    -- Bot commands file 
    dofile('bot-command-list.lua')
end

statesGot = 0

function ProcessEvent(o)
    print(o.type)
    if o.type == 'login_response' then 
        -- Receipt that server likes our user/pass
        isLoggingIn = false
        isLoggedIn = true
        server:send(json.encode(packets.get_ping))
    elseif o.type == 'ping_response' then
        -- Save average, keep clientId 
        local v = o.ts
        local thisPing = v - lastPing
        table.insert(pings, thisPing)
        lastPing = v
        isConnected = true
        if clientId ~= o.playerId then 
            clientId = o.playerId 
        end
    elseif o.type == 'state' then
        -- World state
        local v = o.ts
        local thisBroadcast = v - lastBroadcast
        table.insert(broadcasts, thisBroadcast)
        lastBroadcast = v
        currentState = o.data 
        statesGot = statesGot + 1
    end
end

lastTime = os.clock()
updates = 0
dT = os.clock()
totalTime = 0
pingTime = 0

while true do 
	--if os.clock() - t > serverTick then 
    dT = os.clock()*100 - lastTime
    totalTime = totalTime + dT
    pingTime = pingTime + dT 
    --print(pingTime)
    --print(dT, totalTime)
    if pingTime > 10 then 
        
        pingTime = pingTime - 10
        dT = 0
        if os.time() ~= lastTime then lastTime = os.time(); TICK = true; end 
        totalSeconds = os.time() - start
		t = os.clock()
        UPDATE_ME = true 
        UpdateScreen()
        -- Are we online?
		if server then 
			local event 
            -- Get event and process if not nil
			event = host:service()
			if event then 
				if event.data ~= 0 and event.data ~= nil then 
                    local d = json.decode(event.data)
                    ProcessEvent(d)
                    cycles = cycles + 1
				end
			end
            -- Special case for getting login 
            if not isLoggedIn then
                isLoggingIn = true
                local loginPacket = packets.login_request
                local userCreds = split(credentials, '/')
                loginPacket.data.username = userCreds[1]
                loginPacket.data.password = userCreds[2]
                server:send(json.encode(loginPacket))
                print('login sent')
            elseif isLoggedIn and UPDATE_ME then 
                -- Always send update packet for BOTs
                local updatePacket = packets.update_position
                updatePacket.data = myPlayerState
                server:send(json.encode(updatePacket))
                updates = updates + 1
            end
            -- Always send ping to keep alive 
		    
            --print('pingin')
		else 
            --if not isLoggedIn then 
			--     print('Connecting...')
			--     server = host:connect("54.196.121.96:33111", 2)
            --end
		end
        --server:send(json.encode(packets.get_ping))
    else 
        os.execute("sleep 0.15")
        pingTime = 11
    end
    lastTime = os.clock()*100
end
