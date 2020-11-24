print('bot-command-list:')

myPlayerState.pos.x = 4
myPlayerState.pos.y = 2

if currentState.players ~= nil then 
	local p = currentState.players[tostring(clientId)].pos
	if p ~= nil then 
		print("My pos: x " .. p.x .. " y " .. p.y .. " z " .. p.z) end 
end