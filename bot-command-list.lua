print('bot-command-list:')


if currentState.players ~= nil then 
	local p = currentState.players[tostring(clientId)]
	if p ~= nil then 
		printtable(p)
	end
end

-- Milisecond offset is stored in ms_offset
if TICK then 
	TICK = false
	--myPlayerState.pos.y = myPlayerState.pos.y + 1
	myPlayerState.pos.x = myPlayerState.pos.x + 1
	if myPlayerState.pos.x > 10 then myPlayerState.pos.x = -5 end 
end 

print('my pos : x ' .. myPlayerState.pos.x .. ' y ' .. myPlayerState.pos.y .. ' z ' .. myPlayerState.pos.z)
print("updates : " .. updates)