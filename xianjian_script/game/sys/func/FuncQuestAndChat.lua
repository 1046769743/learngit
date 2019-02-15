-- FuncQuestAndChat.lua



FuncQuestAndChat = {}


FuncQuestAndChat.leafBladeTitle = {
	[1] = "目标",
	[2] = "日常",
	[3] = "轶事",
	[4] = "情缘",
}

FuncQuestAndChat.leafBladeType = {
	quest = 1,
	evertDay = 2,
	mission = 3,
	love = 4,
}

function FuncQuestAndChat.init()

end


function FuncQuestAndChat.getWithAndHight(arrTable)
	local num = table.length(arrTable)
	local with  = 262
	local newWith = with
	local offx = 90
	if num == 1  then
		offx = 0
	elseif num == 2  then
		offx = 30
		newWith = 120
	elseif num == 3  then
		offx = 0
		newWith = 80
	end
   	return offx,newWith
end





 

return FuncQuestAndChat  
