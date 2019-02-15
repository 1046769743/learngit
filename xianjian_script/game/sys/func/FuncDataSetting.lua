
FuncDataSetting = FuncDataSetting or {}

local dataSetting = nil


function FuncDataSetting.init( 	 )
	dataSetting = Tool:configRequire("DataSetting")
end

-- 通过 hid 获得设置数据
function FuncDataSetting.getDataByHid(hid)
    return dataSetting[hid]
end

-- 通过 ConstantName 获得设置数据
function FuncDataSetting.getDataByConstantName(constantName)
	local value = dataSetting[constantName].num
	if (not value) or value ==""  then
		return numEncrypt:getNum0()
	end
    return numEncrypt:getNum(value)
end

-- 通过 ConstantName 获得数组类型设置数据
function FuncDataSetting.getDataArrayByConstantName(constantName)
	local data = dataSetting[constantName]
	if data then
		return data.arr
	end
end

-- 通过 ConstantName 获得字符串类型设置数据
function FuncDataSetting.getDataStringByConstantName(constantName)
	local data = dataSetting[constantName]
	if data then
		return data.str
	end
end

-- 通过 ConstantName 获得原始数据 也就是未解密的
function FuncDataSetting.getOriginalData(constantName)  
	local data = dataSetting[constantName]
	if not data then
		echoError("DataSetting key:",constantName,"对应的数据不存在")
		return  0
	end
    return data.num
end

-- 通过 加密串 获得设置数据 --除了战斗系统以外 其他系统应该直接调用  FuncDataSetting.getDataByConstantName
function FuncDataSetting.getDataByEncStr(encStr)
	local value = encStr
	if (not value) or value ==""  then
		return numEncrypt:getNum0()
	end
    return numEncrypt:getNum(value)
end


function FuncDataSetting.filterStr(str)
	if str and string.len(str) > 1 and string.getChar(str,string.len(str)) == ";" then
		str = string.sub(str,1,string.len(str) - 1)
	end

	return str
end

function FuncDataSetting.getPVELimitDropOrder(itemId)
	local limitDropStr = dataSetting["PVELimitDrop"].str
	limitDropStr = FuncDataSetting.filterStr(limitDropStr)

	local limitDropArr = {}
	if limitDropStr then
		limitDropArr = string.split(limitDropStr,";")
	end

	if #limitDropArr > 0 then
		for i=1,#limitDropArr do
			if tostring(itemId) == limitDropArr[i] then
				return i
			end
		end
	end

	return #limitDropArr + 1
end

function FuncDataSetting.getDataVector( constantName )

	local data = dataSetting[constantName]
	data = data.vec
	local result = {}
	for k,v in pairs( data ) do
		result[v.k] = numEncrypt:getNum(v.v)
	end

	return result
end


--[[
财神出现需要杀死的小怪数量
]]
function FuncDataSetting.getXiaoGuaiCntShowCaiShen()
	local data = dataSetting["TrialGodNum"]
	--dump(data)
	data = data.num
	return data
	--return 1
end

--[[
试炼的回合数
]]
function FuncDataSetting.getTrialExpTimeCnt(  )
	local data = dataSetting["TrialExpTime"]
	return data.num
end



--[[
金币试炼boss死亡掉落
敌人类型，掉落数量，掉落类型，掉落ID
]]
function FuncDataSetting.getTrialDrop( type )
	local data = dataSetting["TrialGodReward"]
	local rwdArr = string.split2d(data.str,";",",")
	local rwd
	for k,v in pairs(rwdArr) do
		if tostring( v[1] ) == tostring(type) then
			rwd = v[3]..","..v[4]..","..v[2]
		end
	end
	return rwd
end


--[[
临时方法
]]
function FuncDataSetting.getTrialTmpeDropCnt(type)
	if tostring(type) == "1" then
		return 8
	elseif tostring(type) == "2" then
		return 5
	elseif tostring(type) == "3" then
		return 1
	else
		return 0
	end
end


--[[
荣耀哥们的位置
]]
function FuncDataSetting.getHonorNpcPos(  )
	local data = dataSetting["HomeNpcPos1"]
	local ret = string.split(data.str, ";");
	return ret;
end

--quest rootid
function FuncDataSetting.getQuestOpenArray()
	local data = dataSetting["QuestOpen"]
	local ret = string.split(data.str, ";");
	table.remove(ret, #ret);
	return ret;
end

--开启筛选的等级
function FuncDataSetting.getOpenQuestTabLvl()
	local data = dataSetting["QuestTab"]
	return data.num;
end

--需要判断是否领取条件的
function FuncDataSetting.getQuestCompleteIds()
	local data = dataSetting["QuestComplete"];
	local ret = string.split(data.str, ";");
	return ret;
end

--得到每日任务要显示到推荐中的等级
function FuncDataSetting.getDailyRecommandOpenLvl()
	local data = dataSetting["QuestEveryOpen"];
	return data.num;
end



--[[
获取多人布阵的倒计时时间
]]
function FuncDataSetting.getMultiFormationTimeOut()
	local data = dataSetting["FormatTimeOver"]
	return data.num
end
--[[
	神器抽每抽1次给予的神器精华数量
]]
function FuncDataSetting.getJinHuaNumbers()
	local data = dataSetting["CimeliaLotteryCimeliaCoin"]
	return data.num
end

--[[
获取爬塔的次数
]]
function FuncDataSetting.getTowerResetNum()
	local data = dataSetting["TowerResetTimes"]
	return data.num
end

--[[
获取仙盟GVE combo不同个数的怪的时候的奖励系数(倍数)
]]
function FuncDataSetting.getComboTimesMultiple( _comboNum )
	echo("---- ",_comboNum)
	local data = dataSetting["FoodCombo"].vec
	-- dump(data,"++++ data")
	for i,v in ipairs(data) do
		if v.k == tostring(_comboNum) then
			echo("_______ 返回系数 _________ ",v.v)
			return v.v
		end
	end
	return 1
end

--[[
获取仙盟GVE 五轮战斗中每轮选怪并战斗的总时间
]]
function FuncDataSetting.getOneAccountTime()
	local data = dataSetting["FoodTurnCountDown"].num
	return data or 60
end


--[[
获取重置消耗
]]
function FuncDataSetting.getResetExpend(time)
	local data = dataSetting["FiveSoulResetting"]
	local expendNum = 0
	local ret = string.split(data.str, ";");
	for k,v in pairs(ret) do
		local tempStr = string.split(v,",");
		if tonumber(time+1)>= tonumber(tempStr[1]) and tonumber(tempStr[2]) > expendNum then
			expendNum = tonumber(tempStr[2])
		end
	end
	return expendNum
end

--[[
获取五灵养成限制
]]
function FuncDataSetting.getMatrixMethodDetail(level)
	local data = dataSetting["FiveSoulUnlock"]
	local ret = string.split(data.str, ";");
	for k,v in pairs(ret) do
		if tonumber(level) == tonumber(v) then
			return true
		end
	end
	return false
end
-- 获取解锁挂机任务需要完成的普通挂机任务个数
function FuncDataSetting.getUnLockSpecialTaskNum(  )
	local data = dataSetting["DelegateTaskSpecialNum"]
	if not data then
		echoError ("没有获取到锁挂机任务需要完成的普通挂机任务个数,返回默认个数10")
		return 10
	end
	return data.num
end
-- 获取仙灵委托每日可完成的普通委托次数
function FuncDataSetting.getNormalTaskNum(  )
	local data = dataSetting["DelegateTaskDayNum"]
	if not data then
		echoError ("没有获得每日可完成的委托次数，返回默认的5")
		return 5
	end
	return data.num
end
-- 获取普通委托免费刷新次数
function FuncDataSetting.getNormalRefreshTaskNum(  )
	local data = dataSetting["DelegateTaskSpeedTime"]
	if not data then
		echoError ("获取普通委托刷新次数，返回默认的1")
		return 1
	end
	return data.num
end
function FuncDataSetting.geSpecialRefreshPrice(  )
	local data = dataSetting["DelegateTaskSpecilRefreshPrice"]
	if not data then
		echoError ("获取特殊委托刷新价格")
		return 40
	end
	return data.num
end
-- 获取刷新的任务个数
function FuncDataSetting.getNormalRefreshTaskNum(  )
	local data = dataSetting["DelegateTaskSpeedTime"]
	if not data then
		echoError ("没有获得每日可完成的委托次数，返回默认的1")
		return 1
	end
	return data.num
end
-- 获取刷新普通任务的价格
function FuncDataSetting.getNormalRefreshPrice(  )
	local data = dataSetting["DelegateTaskSingleRefreshPrice"]
	if not data then
		echoError ("没有获得刷新任务价格，返回默认的20")
		return 1
	end
	return data.num
end




-- 情景卡首次分享活动得仙玉数量
function FuncDataSetting.getMemoryShareRewardNum(  )
	local data = dataSetting["MemoryShare"]
	if not data then
		echoError ("没有获取到情景卡首次分享仙玉数,返回默认个数100")
		return 100
	end
	return data.num
end





-- 巅峰竞技场宝箱加速消耗
-- 仙气对应的时间
function FuncDataSetting.getCrosspeakXianqiNum(  )
	local data = dataSetting["CrossPeakTimePerGodGas"]
	if not data then
		echoError ("没有配仙气对应的时间  返回默认个数120")
		return 120
	end
	return data.num
end
-- 仙玉对应的时间
function FuncDataSetting.getCrosspeakXianyuNum(  )
	local data = dataSetting["CrossPeakTimePerGold"]
	if not data then
		echoError ("没有配仙玉对应的时间  返回默认个数120")
		return 120
	end
	return data.num
end
--每日最大开启宝箱数量
function FuncDataSetting.getCrosspeakMaxBoxNum(  )
	local data = dataSetting["CrossPeakOpenBoxNum"]
	if not data then
		echoError ("没有每日最大开启宝箱数量  返回默认 5")
		return 5
	end
	return data.num
end
--每日小任务刷新上限
function FuncDataSetting.getCrosspeakRenwuRefreshNum()
	local data = dataSetting["CrossPeakRefreshMaxNum"]
	if not data then
		echoError ("没有每日最大刷新上限  返回默认 1")
		return 5
	end
	return data.num
end
-- 巅峰竞技场 客户端匹配时长
function FuncDataSetting.getCrosspeakMatchMaxTime()
	local data = dataSetting["CrossPeakMatchTimeMax"]
	if not data then
		echoError ("没有最大匹配时长  返回默认 30")
		return 30
	end
	return data.num
end

--  获取名册系统中的每个阵位的保底属性加成 string
function FuncDataSetting.getHandbookBaseProperty()
	local data = dataSetting["HandbookHoleProperty"]
	if not data then
		echoError ("\n\n can not found HandbookHoleProperty")
	end
	local arr = {}
	local strArr = string.split(data.str,";")
	for k,oneProStr in pairs(strArr) do
		local onePro = string.split(oneProStr,",")
		if table.length(onePro)>1 then
			local tem = {
				key = tonumber(onePro[1]),
				value = onePro[2],
				mode = tonumber(onePro[3]),
			}
			arr[#arr + 1] = tem
		end
	end
	-- dump(arr, "奇侠名册阵位基本属性数据", nesting)
	return arr
end

function FuncDataSetting.getMonthCardShopFlushTime()
	local data = dataSetting["MonthCardShopFlushTime"]
	if not data then
		echoError ("\n\nno MonthCardShopFlushTime")
	end
	return data.num
end

--  获取仙盟酒家配置的新手引导时的20个怪
function FuncDataSetting.getFoodTeachMonsterArr()
	local data = dataSetting["FoodGuideMonster"]
	if not data then
		echoError ("\n\nno FoodGuideMonster")
	end
	return data.arr
end

-- 获取仙界对决仙人掌初始位置和对应EnemyInfo的id
function FuncDataSetting.getCrossPeakObstaclePlay(  )
	local a,b = dataSetting["CrossPeakCactusPosition"],dataSetting["CrossPeakCactusId"]
	if not a or not b then
		echoError ("not CrossPeakCactus,use default value 1,216016")
		return 1,216016
	end
	return a.num,b.str
end


--获取幸运轮盘单次花费点券
function FuncDataSetting.getLuckyGuyOnceCost(  )
	local data = dataSetting["RouletteOnceCost"]
	return data.num
end

--获取幸运轮盘5次花费点券
function FuncDataSetting.getLuckyGuyFiveCost(  )
	local data = dataSetting["RouletteFiveCost"]
	return data.num
end

--获取幸运轮盘买一个经验药水需要多少仙玉
function FuncDataSetting.getLuckyGuyGreenStonePrice(  )
	local data = dataSetting["RouletteGreenStonePrice"]
	return data.num
end

--获取幸运轮盘买一个经验药赠送多少点券
function FuncDataSetting.getLuckyGuyGreenStoneHandselCoin(  )
	local data = dataSetting["RouletteGreenStoneHandselCoin"]
	return data.num
end

--获取幸运轮盘单次抽取幸运值增长
function FuncDataSetting.getLuckyGuyIncreasePerTime(  )
	local data = dataSetting["RouletteLuckIncreasePerTime"]
	return data.num
end

--获取幸运轮盘单次抽取获得双倍幸运值概率万分比
function FuncDataSetting.getLuckyGuyDoubleIncreaseChance(  )
	local data = dataSetting["RouletteLuckDoubleIncreaseChance"]
	return data.num
end


