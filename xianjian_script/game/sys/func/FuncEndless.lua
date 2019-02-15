--
-- Author: LXH
-- Date: 2018-01-19 10:06:54
--

FuncEndless = FuncEndless or {}

FuncEndless.clickAnimName = {
	["endless_bg_01"] = "UI_guankaxuanzhong_01",
	["endless_bg_02"] = "UI_guankaxuanzhong_02",
	["endless_bg_03"] = "UI_guankaxuanzhong_03",
}

FuncEndless.clickAnimPos = {
	["endless_bg_01"] = {x = 5, y = 5},
	["endless_bg_02"] = {x = 5, y = 5},
	["endless_bg_03"] = {x = 5, y = 5},
}

FuncEndless.starRewardType = {
	ONE_STAR = 1,
	TWO_STAR = 2,
	THREE_STAR = 3,
}

FuncEndless.boxRewardType = {
	FIRST = 1,
	SECOND = 2,
	THIRD = 3,
}

--排行展示顺序改为先全服 再仙盟 再好友
FuncEndless.RANK_TAG = {
	FRIEND = 3,
	GUILD = 2,
	ALL = 1,
}

FuncEndless.endlessStatus = {
    NOT_PASS = 0,
    ONE_STAR = 1,
    TWO_STAR = 2,
    THREE_STAR = 3,
}

FuncEndless.boxRewardType = {
	HASRECEIVED = 1,
	NOTRECEIVED = 0,
	CANRECEIVED = 2,
}

FuncEndless.floorMap = {

}

FuncEndless.Orientations = {
	LEFT = 1,
	RIGHT = 2,
}

FuncEndless.waveNum = {
	FIRST = 1,
	SECOND = 2,
}

FuncEndless.rankType = 8

local config_endless = nil
local config_endlessFloor = nil

function FuncEndless.init()
	config_endless = Tool:configRequire("endless.Endless")
	config_endlessFloor = Tool:configRequire("endless.EndlessFloor")
	FuncEndless.getFloorMap()
end

function FuncEndless.getFloorMap()
	local floorNums = 60
	for i = 1, 60, 1 do
		FuncEndless.floorMap[i] = floorNums
		floorNums = floorNums - 1
	end
end

--获取所有的关卡数据
function FuncEndless.getAllEndlessData()
	return config_endless
end

--通过关卡id获取该关卡的数据
function FuncEndless.getLevelDataById(_id)
	local levelData = config_endless[tostring(_id)]
	if not levelData then
		echoError("配表中未找到该关卡  ID===", _id)
	end
	return levelData
end

--根据id以及key值获取对应的属性值
function FuncEndless.getValueByIdAndKey(_id, _key)
	local levelData = FuncEndless.getLevelDataById(_id)
	local value = nil
	if levelData then
		value = levelData[tostirng(_key)]
		if not value then
			echoError("配表中未找到该属性  ID==", _id, " key==", _key)
		end
	end
	return value
end

--根据id获取五灵珠标识
function FuncEndless.getItemFlagById(_id)
	local levelData = FuncEndless.getLevelDataById(_id)
	local itemFlag = levelData.itemFlag
	return itemFlag
end

--通过层数获得该层的ids
function FuncEndless.getBossIdsByFloorId(_floorId)
	local bossIds = {}
	for k,v in pairs(config_endless) do
		if tostring(v.floor) == tostring(_floorId) then
			table.insert(bossIds, v.id)
		end
	end

	local sortFunc = function (a, b)
		return tonumber(a) < tonumber(b)
	end
	table.sort(bossIds, sortFunc)
	return bossIds
end

function FuncEndless.getFinalEndlessId()
	return table.length(config_endless)
end

--获取关卡总数目
function FuncEndless.getAllEndlessCount()
	return table.length(config_endless)
end

--通过id获取关卡所在的层数
function FuncEndless.getFloorAndSectionById(_id)
	--如果大于最大的关卡数 强制赋值为最大关卡值
	if tonumber(_id) > table.length(config_endless) then
		_id = table.length(config_endless)
	end
	local levelData = config_endless[tostring(_id)]
	local floor = nil
	local section = nil
	if not levelData then
		echoError("配表中未找到该关卡  ID===", _id)
	else
		floor = levelData.floor
		if not floor then
			echoError("配表中该关卡未配floor  ID===", _id)
		end
		section = levelData.section
		if not section then
			echoError("配表中该关卡未配section  ID===", _id)
		end
	end
	return floor, section
end

--通过id获取对应关卡的bossId   无底深渊改为两个levelId  该方法 废弃
function FuncEndless.getLevelIdById(_id)
	local levelData = config_endless[tostring(_id)]
	local levelId = nil
	if not levelData then
		echoError("配表中未找到该关卡  ID===", _id)
	else
		levelId = levelData.levelId
		if not levelId then
			echoError("配表中该关卡未配levelId  ID===", _id)
		end
	end
	return levelId
end

--通过id获取对应关卡的第一个bossId
function FuncEndless.getFirstLevelIdById(_id)
	local levelData = config_endless[tostring(_id)]
	local levelId = nil
	if not levelData then
		echoError("配表中未找到该关卡  ID===", _id)
	else
		levelId = levelData.firstLevelId
		if not levelId then
			echoError("配表中该关卡未配firstLevelId  ID===", _id)
		end
	end
	return levelId
end

--通过id获取对应关卡的第二个bossId
function FuncEndless.getSecondLevelIdById(_id)
	local levelData = config_endless[tostring(_id)]
	local levelId = nil
	if not levelData then
		echoError("配表中未找到该关卡  ID===", _id)
	else
		levelId = levelData.secondLevelId
		if not levelId then
			echoError("配表中该关卡未配levelId  ID===", _id)
		end
	end
	return levelId
end

--通过id获取左侧展示用的spine形象ids  是一个数组 可能会有多个spineId需要展示
function FuncEndless.getSpineIdById(_id)
	local levelData = config_endless[tostring(_id)]
	local spineId = nil
	if not levelData then
		echoError("配表中未找到该关卡  ID===", _id)
	else
		spineId = levelData.spineId
		if not spineId then
			echoError("配表中该关卡未配spineId  ID===", _id)
		end
	end
	return spineId
end

--通过id和starType获取几星通关奖励
function FuncEndless.getStarRewardByIdAndType(_id, _starType)
	local levelData = config_endless[tostring(_id)]
	local starReward = nil
	if not levelData then
		echoError("配表中未找到该关卡  ID===", _id)
	else
		starReward = levelData["starReward".._starType]
		if not starReward then
			echoError("配表中该关卡未配starReward", _starType, "ID===", _id)
		end
	end
	return starReward
end

-- --通过id获取二星通关奖励
-- function FuncEndless.getRewardForTowStarById(_id)
-- 	local levelData = config_endless[tostring(_id)]
-- 	local starReward = nil
-- 	if not levelData then
-- 		echoError("配表中未找到该关卡  ID===", _id)
-- 	else
-- 		starReward = levelData.starReward2
-- 		if not starReward then
-- 			echoError("配表中该关卡未配starReward2  ID===", _id)
-- 		end
-- 	end
-- 	return starReward
-- end

-- --通过id获取三星通关奖励
-- function FuncEndless.getRewardForThreeStarById(_id)
-- 	local levelData = config_endless[tostring(_id)]
-- 	local starReward = nil
-- 	if not levelData then
-- 		echoError("配表中未找到该关卡  ID===", _id)
-- 	else
-- 		starReward = levelData.starReward3
-- 		if not starReward then
-- 			echoError("配表中该关卡未配starReward3  ID===", _id)
-- 		end
-- 	end
-- 	return starReward
-- end

--获取所有层的数据
function FuncEndless.getAllFloorData()
	return config_endlessFloor
end

function FuncEndless.getFloorCount()
	return table.length(config_endlessFloor)
end

--获取每一层的数据
function FuncEndless.getFloorDataById(_floorId)
	local floorData = config_endlessFloor[tostring(_floorId)]
	if not floorData then
		echoError("配表中未找到该层  _floorId===", _floorId)
	end
	return floorData
end

--获取每一层的名字
function FuncEndless.getFloorNameById(_floorId)
	local floorData = config_endlessFloor[tostring(_floorId)]
	local floorName = nil
	if not floorData then
		echoError("配表中未找到该层  _floorId===", _floorId)
	else
		floorName = floorData.name
		if not floorName then
			echoError("配表中该层未配name  _floorId===", _floorId)
		end
	end
	return floorName
end

--获取每一层的section总节数
function FuncEndless.getSectionNumById(_floorId)
	local floorData = config_endlessFloor[tostring(_floorId)]
	local sectionNum = nil
	if not floorData then
		echoError("配表中未找到该层  _floorId===", _floorId)
	else
		sectionNum = floorData.section
		if not sectionNum then
			echoError("配表中该层未配section  _floorId===", _floorId)
		end
	end
	return sectionNum
end

--获取每一层的star  能获取宝箱的星级数
function FuncEndless.getFloorStarById(_floorId)
	local floorData = config_endlessFloor[tostring(_floorId)]
	local star_table = nil
	if not floorData then
		echoError("配表中未找到该层  _floorId===", _floorId)
	else
		star_table = floorData.star
		if not star_table then
			echoError("配表中该层未配star  _floorId===", _floorId)
		end
	end
	return star_table
end

--通过id和type获取宝箱里的奖励数据
function FuncEndless.getBoxRewardByIdAndType(_floorId, _type)
	local floorData = config_endlessFloor[tostring(_floorId)]
	local boxReward = nil
	if not floorData then
		echoError("配表中未找到该层  _floorId===", _floorId)
	else
		boxReward = floorData["boxReward".._type]
		if not boxReward then
			echoError("配表中该关卡未配boxReward", _type, "_floorId===", _floorId)
		end
	end
	return boxReward
end

function FuncEndless.getFloorBgById(_floorId)
	local floorData = config_endlessFloor[tostring(_floorId)]
	local floorName = nil
	if not floorData then
		echoError("配表中未找到该层  _floorId===", _floorId)
	else
		floorBg = floorData.bg
		if not floorBg then
			echoError("配表中该层未配bg  _floorId===", _floorId)
		end
	end
	return floorBg
end


function FuncEndless.getFloorLandById(_floorId)
	local floorData = config_endlessFloor[tostring(_floorId)]
	local floorLand= nil
	if not floorData then
		echoError("配表中未找到该层  _floorId===", _floorId)
	else
		floorLand = floorData.land
		if not floorLand then
			echoError("配表中该层未配land  _floorId===", _floorId)
		end
	end
	return floorLand
end

--根据关卡id获取展示的spineId和缩放比例, 如果缩放比例未配默认为1
function FuncEndless.getSpineIdAndScaleByEndlessId(_endlessId)
	local endlessData = FuncEndless.getLevelDataById(_endlessId)
	local spineString = endlessData.displaySpineId
	local spineId = nil
	local scale = 1
	if not spineString then
		echoError("配表中未找到该关卡的 displaySpineId===", _endlessId)
	else
		local str_table = string.split(spineString, ",")
		spineId = str_table[1]
		if str_table[2] then
			scale = str_table[2]
		end
	end
	return spineId, scale
end

--根据关卡id获取展示的spine朝向  1朝左  2朝右  如果不配默认赋值为1
function FuncEndless.getSpineOrientationsByEndlessId(_endlessId)
	local endlessData = FuncEndless.getLevelDataById(_endlessId)
	local orientation = endlessData.orientations
	if not orientation then
		orientation = FuncEndless.Orientations.LEFT
		echoError("配表中未找到该关卡的 orientations===", _endlessId)
	end
	return orientation
end

--根据重数id获取汉字
function FuncEndless.getFloorStrByFloorId(_floorId)
	local floorData = FuncEndless.getFloorDataById(_floorId)
	local floorStr = floorData.floorName
	local str_txt = ""
	if not floorStr then
		echoError("配表中未找到该重的 floorName===", _floorId)
	else
		str_txt = GameConfig.getLanguage(floorStr)
	end
	return str_txt
end

--根据endlessId获取扫荡奖励
function FuncEndless.getSweepRewardByEndlessId(_endlessId)
	local endlessData = FuncEndless.getLevelDataById(_endlessId)
	local sweepReward = endlessData.sweepReward
	if not sweepReward then
		sweepReward = {}
		echoError("配表中未找到该关卡的 sweepReward===", _endlessId)
	end
	return sweepReward
end

--获取关卡在场景中位置
function FuncEndless.getBossPositionByEndlessId(_endlessId)
	local endlessData = FuncEndless.getLevelDataById(_endlessId)
	local position = endlessData.position
	if not position then
		--未配位置 将其放置在屏幕中间 以便查找问题
		position = {568, -320}
		echoError("配表中未找到该关卡的 position===", _endlessId)
	end
	return position
end

--根据无底深渊关卡id获取布阵时每波可上阵的人数
function FuncEndless.getFormationNumByEndlessId(_endlessId)
	local endlessData = config_endless[tostring(_endlessId)]
	local num = 0
	if not endlessData.number then
		echoError("配表中未找到该关卡的上阵人数 number===", _endlessId)
	else
		num = endlessData.number
	end
	return num
end
