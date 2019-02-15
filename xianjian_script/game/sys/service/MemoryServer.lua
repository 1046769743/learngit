
local MemoryServer = class("MemoryServer")

function MemoryServer:sendActivation(memoryId,callBack)
	Server:sendRequest({memoryId = memoryId},MethodCode.memory_card_activity_6801,callBack )
end
function MemoryServer:shareMemoryCard(memoryId,callBack)
	Server:sendRequest({memoryId = memoryId},MethodCode.memory_card_share_6803,callBack )
end


return MemoryServer