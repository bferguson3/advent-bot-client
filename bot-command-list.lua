print('bot-command-list:')

if currentState.players ~= nil then 
	for k,v in pairs(currentState.players) do 
		if tonumber(k) == clientId then 
			--printtable(v)
			if v.pos then 
				if v.pos.x ~= myPlayerState.pos.x then print('DISCREPENCY') end
			end
		end
	end
end

myPlayerState.pos.x = myPlayerState.pos.x + 1
if myPlayerState.pos.x > 5 then myPlayerState.pos.x = -10 end
myPlayerState.pos.z = 3

print('my pos : x ' .. myPlayerState.pos.x .. ' y ' .. myPlayerState.pos.y .. ' z ' .. myPlayerState.pos.z)
print("updates sent: " .. updates .. ' / received: ' .. statesGot)
