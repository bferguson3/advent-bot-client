print('bot-command-list:')


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