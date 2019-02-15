-- QuestAndChatModel

local QuestAndChatModel = class("QuestAndChatModel", BaseModel);
--初始化
function QuestAndChatModel:init()
	
	self.openView = true

	self.selectViewName = nil
end



function QuestAndChatModel:getAllData(arrData)
	local havequest = false
	local haveMission = false
	local haveEveryDay = false
	if arrData.systemView == FuncCommon.SYSTEM_NAME.MISSION then
		if arrData.data ~= nil then
			haveMission = true
		end
	elseif  arrData.systemView == FuncCommon.SYSTEM_NAME.LOVE then

	end


	local newtable = {}
	table.insert(newtable,1)
    local isOpenEvery = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERY_DAY_QUEST)
	if isOpenEvery then
		newtable = {}
		table.insert(newtable,2)
		table.insert(newtable,1)
    end



	if haveMission then
		newtable = {}
		table.insert(newtable,3)
	end

	return newtable
end


--获取叶签的红点
function QuestAndChatModel:getTitleRed(_type)

	local  _tabKind = TargetQuestModel.TAB_KIND.ALL;
    local allMainLineQuestIds = TargetQuestModel:getAllShowMainQuestId(_tabKind);
    local allDailyQuestIds = DailyQuestModel:getTrackData() --DailyQuestModel:getAllShowDailyQuestId();
    local  questred1 = DailyQuestModel:isHaveMainFinishQuest()
   	local dayQuest = TargetQuestModel:isHaveFinishQuest()

	local redArr = {
		[1] = dayQuest or false ,
		[2] = questred1 or false ,
		[3] = false,
	}

	return redArr[tonumber(_type)]
end

--设置追踪目标界面上显示  true打开      false 关闭
function QuestAndChatModel:setOpenView(_boor)
	self.openView = _boor
end
function QuestAndChatModel:getOpenView()
	return self.openView 
end


--设置追踪目标界面选中的界面
function QuestAndChatModel:setselectViewName(_type)
	self.selectViewName = _type
end
function QuestAndChatModel:getselectViewName()
	return self.selectViewName 
end



QuestAndChatModel:init()

return QuestAndChatModel
