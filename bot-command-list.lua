print('bot-command-list:')


myPlayerState.pos.x = myPlayerState.pos.x + 1
if myPlayerState.pos.x > 10 then myPlayerState.pos.x = -5 end

if currentState.players ~= nil then 
	for k,v in pairs(currentState.players) do 
		--print(k,v)
		if tonumber(k) == clientId then 
			printtable(v)
			if v.pos then 
				if v.pos.x ~= myPlayerState.pos.x then print('DISCREPENCY') end
			end
		end
	end
	
end

print('my pos : x ' .. myPlayerState.pos.x .. ' y ' .. myPlayerState.pos.y .. ' z ' .. myPlayerState.pos.z)
print("updates sent: " .. updates .. ' / received: ' .. statesGot)