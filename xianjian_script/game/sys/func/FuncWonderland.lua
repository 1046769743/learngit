-- FuncWonderland
-- 须于仙境
FuncWonderland = FuncWonderland or {}




FuncWonderland.attribute = {
	[1] = "风",
	[2] = "雷",
	[3] = "水",
	[4] = "火",
	[5] = "土",
}





FuncWonderland.ErrorStrID = {
	ERROR_1 = 1,
	ERROR_2 = 2,
	ERROR_3 = 3,
	ERROR_4 = 4,
	ERROR_5 = 5,
}
FuncWonderland.ErrorString = {
	[1] = "",
	[2] = "通关本层后才可以挑战下一层",
	[3] = "挑战次数不足",
	[4] = "扫荡次数不足",
	[5] = GameConfig.getLanguage("#tid_wonderland_error_103"),
}

-- 不同副本，获取排行榜的类型  PaiHanbang_Type
FuncWonderland.PaiHanbang_Type = {
	[1] = 5,   
	[2] = 6,
	[3] = 7,
	[4] = 13,
	[5] = 14,
	[6] = 15,
	[7] = 16,
	[8] = 17,
	[9] = 18,
}

FuncWonderland.MaxFloor = 20

FuncWonderland.MathModel = {
	Integer = 1 ,		--整数
	ThousandTimes = 2,  ---万分比
}



local wonderland = nil
local WonderLandData  = nil
local WonderLandNpcSkill = nil
local WonderLandBuff = nil

function FuncWonderland.init(  )
   wonderland = Tool:configRequire("wonderland.WonderLandTitle") 
   WonderLandData = Tool:configRequire("wonderland.WonderLand")
   WonderLandNpcSkill = Tool:configRequire("wonderland.WonderLandNpc")
   WonderLandBuff = Tool:configRequire("wonderland.WonderLandBuff")
end 

----获得玩法的类型
--数据结构
--[[
	local data = {
		[1] = {id = ,name = ,des = ,},
		[2] = {id = ,name = ,des = ,},
	}
]]
function FuncWonderland.getdifferTypeData()

	-- local time = LoginControler:getServerInfo().openTime
	local dayNum = FuncWonderland.isOnTime()  --开服的天数


	local notFiveBuf = FuncDataSetting.getDataByHid("WonderlandUnfivesoulSequence")
	local fiveBuf = FuncDataSetting.getDataByHid("WonderlandfivesoulSequence")


	local index1 = math.fmod(dayNum, table.length(notFiveBuf.arr))  ---第几个位置
	local index2 = math.fmod(dayNum, table.length(fiveBuf.arr))  ---第几个位置
	if index1 == 0 then
		index1 = table.length(notFiveBuf.arr)
	end
	if index2 == 0 then
		index2 = table.length(fiveBuf.arr)
	end
	echo("======第几天开启第几个===========",dayNum,index1,index2)

	local notFiveBufId = notFiveBuf.arr[index1]
	local fiveBufId = fiveBuf.arr[index2]

	local openData = {[1] = {id = notFiveBufId,open = true,index = index1},[2] = {id = fiveBufId,open = true,index = index2}}
	local notfiveArrBuf = {}
	-- dump(notFiveBuf,"3333333333333")
	for i=1,#notFiveBuf.arr do
		local isHave = nil

		for x=1,#openData do
			if notFiveBuf.arr[i] ==  openData[x].id then
				isHave = notFiveBuf.arr[i]
			end
		end


		local index = openData[1].index  
		if i > index then
			time = i - index
		else
			local num  = #notFiveBuf.arr
			local day =  num - index 
			if index == table.length(notFiveBuf.arr) then
				time = i
			else
				time = i + day
			end

		end

		if not isHave then
			local openarr =  {
				id = notFiveBuf.arr[i],
				open = false,
				time = time,
				index = i
			}
			table.insert(notfiveArrBuf,openarr)
		end
	end



	local fiveArrBuf = {}

	for i=1,#fiveBuf.arr do
		local isHave = nil
		for x=1,#openData do
			if fiveBuf.arr[i] ==  openData[x].id then
				isHave = fiveBuf.arr[i]
			end
		end
		local index = openData[2].index  ---五灵开启的Id
		if i > index then
			time = i - index
		else
			local num  = #fiveBuf.arr
			local day =  num - index 
			if index == table.length(fiveBuf.arr) then
				time = i
			else
				time = i + day
			end
		end
		
		if not isHave then
			local openarr =  {
				id = fiveBuf.arr[i],
				open = false,
				time = time,
			}
			table.insert(fiveArrBuf,openarr)
		end
	end


	table.sort(notfiveArrBuf, function(a,b)
		return tonumber(a.time) < tonumber(b.time)
	end)

	for i=1,#notfiveArrBuf do
		table.insert(openData,notfiveArrBuf[i])
	end

	table.sort(fiveArrBuf, function(a,b)
		return tonumber(a.time) < tonumber(b.time)
	end)

	for i=1,#fiveArrBuf do
		table.insert(openData,fiveArrBuf[i])
	end


	for i=1,#openData do
		local id = openData[i].id
		local data = wonderland[id]
		openData[i].data = data
	end


	return openData
end


--返回时第几天
function FuncWonderland.isOnTime()

	--服务器的开服时间
	local openTime = LoginControler:getServerInfo().openTime  
	dump(openTime,"开启=======服务器的开服时间=====")
	--服务器时间
	local serveTime = TimeControler:getServerTime()

	--到四点的时间
	local time = FuncCommon.byTimegetleftTime(openTime)

	local differenceTime = serveTime - openTime
	if differenceTime <= time then
		return 1
	else
		
		--天数
		local dayNum = math.floor((differenceTime-time)/(24*3600))
		if dayNum > 0 then   --大于一天
			return dayNum + 2
		else
			return 1 + 1
		end
	end
	return 1
end




--获得须臾的副本描述
function FuncWonderland.getDisBymiaoshu(_type)
	local data = wonderland[tostring(_type)]
	if data == nil then
		data = wonderland[tostring(1)]
		echoError("========须臾仙境不存在该副本类型===_type===",_type,"默认用=== _type =  1")
	end
	local dis = GameConfig.getLanguage(data.miaoshu)
	return  dis
end

function FuncWonderland.getTypeByFloorData(_type)
	if _type == nil then
		_type = 1
		echoError("========须臾仙境不存在该副本类型========",_type,"默认用=== _type =  1 ==")
	end
	-- dump(WonderLandData,"111111111111111")
	local data =   WonderLandData[tostring(_type)]
	local newdata = {}
	for k,v in pairs(data) do
		v.id = tonumber(k)
		newdata[tonumber(k)] = v
	end
	return newdata
end


--根据副本类型和层数获得  关卡数据
function FuncWonderland.getCheckpointData(_type,floor)
	local data = WonderLandData[tostring(_type)]
	if data == nil then
		echoError("====须臾仙境不存在该副本类型 _type临时用类型  _type = 1 ====",_type)
		data = WonderLandData[tostring(1)]
	end
	local floordata = data[tostring(floor)]
	-- if floordata == nil then
	-- 	echoError("====须臾仙境不存在该层数 floor===临时用层数  floor = 1 ====",floor)
	-- 	floordata = data[tostring(1)]
	-- end
	return floordata
end


--获得层数的spine
function FuncWonderland.getfloorSpine(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local spineTab = data.spineId
	return spineTab
end

--根据副本类型和层数获得  关卡ID
function FuncWonderland.getLevelIdByfloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local levelId = data.levelId
	return levelId
end
--根据副本类型和层数获得 关卡buffs加成
function FuncWonderland.getBuffsByfloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local buffs = data.buffs
	return buffs
end
--根据副本类型和层数获得 关卡tags
function FuncWonderland.getTagsByfloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local tags = data.tags
	return tags
end

--根据副本类型和层数获得副本  名称
function FuncWonderland.getNameByfloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local name = data.name
	return GameConfig.getLanguage(name)
end


--根据副本类型和层数获得副本   首领仙术图标
function FuncWonderland.getSkillIconByfloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local skillIcon = data.skillIcon
	return skillIcon
end


--根据副本类型和层数获得副本   仙术TIPS描述
function FuncWonderland.getSkillTipsByfloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local skillTips = data.skillTips
	return skillTips
end


--根据副本类型和层数获得副本   推荐奇侠
function FuncWonderland.getSkillPantnerByfloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local partnerIcon = data.partnerIcon
	return partnerIcon
end

--根据副本类型和层数获得副本   首次通关奖励
function FuncWonderland.getSkillFirstByfloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local firstreward = data.firstReward
	return firstreward
end

--根据副本类型和层数获得副本   扫荡奖励
function FuncWonderland.getSkillSweepByfloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local sweepreward = data.sweepReward
	return sweepreward
end



--获取每日的挑战次数
function FuncWonderland.getChallengCount()
	local count = FuncDataSetting.getDataByConstantName("AttackWonderLandTimes")
	return count 
end
 
--根据副本类型和层数获得副本   获得npc  Id  ---enemyInfo表中id
function FuncWonderland.getNpcByFloor(_type,floor)
	local data = FuncWonderland.getCheckpointData(_type,floor)
	local npc = data.npc
	return npc
end

--获取最大排行榜数
function FuncWonderland.getMaxlistNum()
	return 50
end

-- 判断是否是须臾仙境配置的npc
function FuncWonderland.isWonderLandNpc(_enermyId)
	for k,v in pairs(WonderLandData) do
		for kk,vv in pairs(v) do
			if tostring(_enermyId) == tostring(vv.npc) then
				return true
			end
		end
	end
	return false
end

function FuncWonderland.getWonderLandNpcSkill()
	return WonderLandNpcSkill
end

function FuncWonderland.getWonderLandAtrr(_type, floor)
  local data =  FuncWonderland.getCheckpointData(_type,floor)
  local buffs = data.buffs
  
  if buffs == nil and tags == nil then
    return
  end

  local buffData = WonderLandBuff[tostring(buffs)]
  local attr = buffData.attr
  return attr
end

function FuncWonderland.getWonderLandMiaoShu(_type,floor)
	local data =  FuncWonderland.getCheckpointData(_type,floor)
	local miaoshu = data.miaoshu
	local buffs = data.buffs
	local tags = data.tags
	if buffs ~= nil and tags ~=  nil then
		local pames = {}
		local attName = ""
		for i=1, #tags do
			local tempStr = string.split(tags[i],",");
			local attributeName = GameConfig.getLanguage(FuncCommon.getTagNameByTypeAndId(tempStr[1], tempStr[2]))
			local buffData = WonderLandBuff[tostring(buffs)]
			local attr = buffData.attr[1]
			local key = attr.key
			local attributeData = FuncChar.getAttributeById(key)
			local attrName = GameConfig.getLanguage(attributeData.name)
			local mode = tonumber(attr.mode)
			local value = tonumber(attr.value)
			if mode == FuncWonderland.MathModel.Integer then
				value = value
			elseif mode == FuncWonderland.MathModel.ThousandTimes then
				value = (value/100).."%"
			end
			-- if i == #tags then
			-- 	attributeName = "、"..attributeName
			-- end
			attName = attName..attributeName
			pames[1] = attName
			pames[2] = value
		end
		-- dump(unpack(pames),"==5555555==")
		miaoshu = GameConfig.getLanguageWithSwap(miaoshu,unpack(pames))
	else
		if miaoshu ~= nil then
			miaoshu = GameConfig.getLanguage(miaoshu)
		else
			miaoshu = ""
		end
	end
	-- echo("=-=====tempStr========",miaoshu)
	return miaoshu
end

-- 根据buff获取buff数据
function FuncWonderland.getWonderLandBuffById(_id )
	local data = WonderLandBuff[tostring(_id)]
	if data == nil then
		echoError("====须臾仙境不存在该buff数据 临时用类型  _id = 1 ====",_id)
		data = WonderLandBuff[tostring(1)]
	end
	return data
end
--根据关卡ID获得怪物NPCID
function FuncWonderland:getNPCByLevelID(levelID)
	-- echo("=======须臾的关卡ID=======",levelID)
	for k,v in pairs(WonderLandData) do
		for key,value in pairs(v) do
			if value.levelId == levelID then
				return value.npc
			end
		end
	end
	return nil
end