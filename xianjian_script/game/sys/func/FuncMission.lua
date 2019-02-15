FuncMission = FuncMission or {}

local missionData = nil;
local missionMapData = nil;
local missionQuestData = nil;

FuncMission.MISSIONTYPE = {
	BIWUQIECUO = 1,
	MIJINGDUOBAO = 2,
}
FuncMission.QUESTTYPE = {
	JIANDAN = 1,
	YIBAN = 2,
	KUNNAN = 3,
}
FuncMission.MISSIONTYPE = {
	HOUZI = 1,		--蜀山夺宝
	PVP = 2,		--比武切磋
	QUEST = 3,		--问答
	BINGDONG = 4,	--琼华封妖
	BAOZHA = 5,		--天雷绝杀
}
FuncMission.questCostTime = 20
FuncMission.answerCostTime = 15
FuncMission.refreshQuestTime = 5
function FuncMission.init()
    missionData = Tool:configRequire("mission/Mission");
    missionMapData = Tool:configRequire("mission/MissionMapping");
    missionQuestData = Tool:configRequire("mission/MissionQuest")
end

function FuncMission.getMissionData( )
	return missionData
end
function FuncMission.getOpenMissionData()
	local data = {}
	for i,v in pairs(missionData) do
		if tonumber(v.switch) == 0 then
			table.insert(data, v)
		end
	end
	return data
end
function FuncMission.getMissionDataById( id )
	local cfgs = missionData[tostring(id)]
	if not cfgs  then
		echoError("mission表 没有这个id数据:",tostring(id))
	end
	return cfgs
end
function FuncMission.getMissionTypeById( id )
	local data = FuncMission.getMissionDataById( tostring(id) )
	return data.type
end
-- 六界轶事 根据宝箱获得系统奖励的列表
function FuncMission.getMissionReward(boxIndex)
	return FuncDataSetting.getDataByHid("MissionBonus"..boxIndex)
end
function FuncMission.getMissionBoxId( boxIndex )
	return "MissionBonus"..boxIndex
end

-- 可能获得得奖励列表
function FuncMission.getProbableReward(id)
	local data = FuncMission.getMissionDataById( id )
	return data.bonus
end

-- 获取确定的必得奖励
function FuncMission.getConfirmReward(id)
	local data = FuncMission.getMissionDataById( id )
	return data.reward
end

-- 通过任务获取任务地点
function FuncMission.getMissionSpaceName(id)
	local data = FuncMission.getMissionDataById( id )
	local space = string.split(data.space[1],",")[1]
	local name = FuncChapter.getSpaceDataByName(space).name
	-- echo("地标名字name === ",name)
	return GameConfig.getLanguage(name)
end
-- 通过任务获取任务Icon
function FuncMission.getMissionSpaceIcon1(id)
	local data = FuncMission.getMissionDataById( id )
	local space = string.split(data.space[1],",")[1]
	local iconName = "mission_"..space.."dwn.png"
	
	return display.newSprite("icon/mission/"..iconName)
end
function FuncMission.getMissionSpaceIcon2(id)
	local data = FuncMission.getMissionDataById( id )
	local space = string.split(data.space[1],",")[1]
	local iconName = "mission_"..space..".png"
	
	return display.newSprite("icon/mission/"..iconName)
end
-- 选中的icon
function FuncMission.getMissionSpaceSelecctIcon()
	local iconName = "mission_renwuxuanzhong.png"
	
	return display.newSprite("icon/mission/"..iconName)
end
-- 通过任务获取任务name
function FuncMission.getMissionName(id)
	local data = FuncMission.getMissionDataById( id )
	return GameConfig.getLanguage(data.name)
end
-- 任务描述
function FuncMission.getMissionDes(id)
	local data = FuncMission.getMissionDataById( id )
	return GameConfig.getLanguage(data.describe)
end
-- 任务目标
function FuncMission.getMissionGoal(id,jindu)
	local data = FuncMission.getMissionDataById( id )
	local total = data.goalParam
	if not jindu then
		jindu = 0
	end
	if jindu >= total then
		return "已完成"
	end
	return GameConfig.getLanguageWithSwap(data.goal,jindu,total)
end
--任务是否完成
function FuncMission.getMissionGoalFinish(id,jindu)
	local data = FuncMission.getMissionDataById( id )
	local total = data.goalParam
	if not jindu then
		jindu = 0
	end
	if jindu >= total then
		return true
	end
	return false
end
-- 获取关卡id
function FuncMission.getMissionLevelId( id,index)
	local data = FuncMission.getMissionDataById( id )
	if data.paramStr1[index] then
		return data.paramStr1[index]
	end
	echoError ("没有获取到对应的levelId，使用默认id",data.paramStr1[1])
	return data.paramStr1[1]
end
-- 获取宝物id
function FuncMission.getMissionParamId( id,index)
	local data = FuncMission.getMissionDataById( id )
	if data.paramStr3[index] then
		return data.paramStr3[index]
	end
	echoError ("没有获取到对应的宝物id，使用默认id",data.paramStr3[1])
	return data.paramStr3[1]
end

-- 轶事问答
function FuncMission.getMissionQuest( )
	return missionQuestData
end
function FuncMission.getMissionQuestById( id )
	if not id then
		echoError("传的id 为空",id)
		return nil
	end
	local data = missionQuestData[tostring(id)]
	if not data then
		echoError("missionquest 中未找到id== ",id)
		return nil
	end
	return data
end
function FuncMission.getMissionQuestByType( _type)
	local T = {}
	for i,v in pairs(missionQuestData) do
		if tonumber(v.questtype) == tonumber(_type) then
			table.insert( T, v )
		end
	end
	local funcSort = function ( a,b )
		if tonumber(a.id) < tonumber(b.id) then
			return true
		end
		return false
	end
	table.sort(T,funcSort)
	return T 
end
