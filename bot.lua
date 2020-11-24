if not enet then enet = require 'enet' end 
if not json then json = require 'json' end 
if not EGA then dofile('lib.lua') end --local m = lovr.filesystem.load('src/lib.lua'); m() end 

serverTick = (1/40)
local credentials = 'bottest/botpass'
local isLoggedIn = false
local isConnected = false
local isLoggingIn = false
local firstUpdate = true 

-- Connect
local host = enet.host_create(nil, 64, 2, 0, 0)
-- Ben's AWS 01:
local server = host:connect("54.196.121.96:33111", 2)

local packets = require 'packets'
local action_types = require 'action_types'

local t = os.clock()
local time 
local pings = {}
local lastPing = 99
local lastBroadcast = 99
local clientId 
local broadcasts = {}
currentState = {}
local myPlayerState = {
    pos = { x = 0.0, y = 0.0, z = 0.0 },
    rot = { x = 0.0, y = 0.0, z = 0.0, m = 0.0 },
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

function ProcessEvent(o)
	if o.type == 'login_response' then 
        isLoggingIn = false
        isLoggedIn = true
        print("logged in")
    elseif o.type == 'ping_response' then
        local v = o.ts
        local thisPing = v - lastPing
        table.insert(pings, thisPing)
        lastPing = v
        isConnected = true
        if clientId ~= o.playerId then 
            clientId = o.playerId 
        end
    elseif o.type == 'state' then
        local v = o.ts
        local thisBroadcast = v - lastBroadcast
        table.insert(broadcasts, thisBroadcast)
        lastBroadcast = v
        if currentState ~= o.data then 
        	printtable(currentState)
        end
        currentState = o.data 

    end
end

while true do 
	if os.clock() - t > serverTick then 
		t = os.clock()
		if server then 
			isConnected = true 
			local event 
			event = host:service()
			if event then 
				if event.data ~= (0 or nil) then 
					local d = json.decode(event.data)
					ProcessEvent(d)
				end
			else
				--server:send(json.encode(myPlayerState)) 
				local upd_packet = packets.update_position
				upd_packet.data = myPlayerState
				server:send(json.encode(upd_packet))
	            server:send(json.encode(packets.get_ping))
	        end
		else 
			-- catch
			print('retrying server connection')
			server = host:connect("54.196.121.96:33111", 2)	
		end
	end
	do end 
end