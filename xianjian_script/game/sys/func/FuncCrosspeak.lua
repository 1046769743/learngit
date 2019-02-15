FuncCrosspeak = FuncCrosspeak or {}

local crossPeakActiveRewardData = nil;
local crossPeakActivityData = nil;
local crossPeakSegmentData = nil;
local crossPeakTimeBuyData = nil;
local crossPeakRankRewardData = nil;
local crossPeakRobotData = nil
local crossPeakPartnerMappingData = nil
local crossPeakTreasureMapping = nil
local crossPeakBox = nil
local crossPeakRollPartner = nil
local crossPeakTask = nil
local crossPeakLoseProperty = nil
local crossPeakMoneyProperty = nil
local crossPeakFastProperty = nil
local crossPeakPlayMethodOrder = nil
local crossPeakGuildRankReward = nil
local crossPeakGuildAccumulateReward  = nil
local crossPeakOptionPartner = nil

FuncCrosspeak.MATCHTYPE = {
	MATCHTYPEING = 1,
	LOADING = 2,
}

FuncCrosspeak.PLAYMODE = {
	NORMAL = 1,
	CACTUS = 2,
	ENERGY = 3,
}



function FuncCrosspeak.init()
    crossPeakActiveRewardData = require("crosspeak/CrossPeakActiveReward");
    crossPeakActivityData = require("crosspeak/CrossPeakActivity");
    crossPeakSegmentData = require("crosspeak/CrossPeakSegment")
    crossPeakTimeBuyData = require("crosspeak/CrossPeakTimeBuy")
    crossPeakRankRewardData = require("crosspeak/CrossPeakRankReward")
    crossPeakRobotData = require("crosspeak/CrossPeakRobot")
    crossPeakPartnerMappingData = require("crosspeak/CrossPeakPartnerMapping")
    crossPeakTreasureMapping = require("crosspeak/CrossPeakTreasureMapping")
    crossPeakBox = require("crosspeak/CrossPeakBox")
    crossPeakRollPartner = require("crosspeak/CrossPeakRollPartner")
    crossPeakTask = require("crosspeak/CrossPeakTask")
    crossPeakLoseProperty = require("crosspeak/CrossPeakLoseProperty")
    crossPeakMoneyProperty = require("crosspeak/CrossPeakMoneyProperty")
    crossPeakFastProperty = require("crosspeak/CrossPeakFastProperty")
    crossPeakPlayMethodOrder = require("crosspeak/CrossPeakPlayMethodOrder")
    crossPeakGuildRankReward = require("crosspeak/CrossPeakGuildRankReward")
    crossPeakGuildAccumulateReward = require("crosspeak/CrossPeakGuildAccumulateReward")
    crossPeakOptionPartner = require("crosspeak/CrossPeakOptionPartner")
end

-----------------------------------------------------------------
-- 活动配置
function FuncCrosspeak.getCrossPeakActiveData()
	return crossPeakActivityData
end
-- 活动开启时间
function FuncCrosspeak.getArossPeakOpenTime()
	return crossPeakActivityData["1"].openTime
end
function FuncCrosspeak.getArossPeakOpenDay()
	return crossPeakActivityData["1"].openDay
end
-- 获取开启时间
function FuncCrosspeak:getOpenWDay( )
	local week = FuncCrosspeak.getArossPeakOpenDay()
	if #week == 7 then
		return GameConfig.getLanguage("#tid_tiaozhuan_03")
	end
	local str = ""
	for k,v in pairs(week) do
		str = str .. FuncCrosspeak:numberToStr( v ) .. " "
	end
	return str 
end
function FuncCrosspeak:numberToStr( num )
	if num == 1 then
		return "周一"
	elseif num == 2 then
		return "周二"
	elseif num == 3 then
		return "周三"
	elseif num == 4 then
		return "周四"
	elseif num == 5 then
		return "周五"
	elseif num == 6 then
		return "周六"
	elseif num == 7 then
		return "周日"
	end
end
-- 活动文本
function FuncCrosspeak.getCrossPeakTxt()
	return crossPeakActivityData["1"].crossPeakTxt
end
-- 奖励预览
function FuncCrosspeak.getCrossPeakShowReward( )
	return crossPeakActivityData["1"].showReward
end
----------------------------------------------------------------
-- 根据当前时间 判断是否有新玩法
function FuncCrosspeak.getWeekIndex()
	local serverTime = TimeControler:getServerTime()
    local data = os.date("*t", serverTime) 
    -- 本月第几周 的逻辑
    local wIndex = 1

    -- 月初时间
    local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
    local mothTime = serverTime - (data.day-1) * 24 * 60 * 60 - currentMiao
    local dataMoth = os.date("*t", mothTime)
    -- 获取1号是星期几
    local mothWday = dataMoth.wday - 1
    if mothWday == 0 then
    	mothWday = 7
    end
    local tmpData = 7 - mothWday + 1
    if data.day > tmpData then
    	-- 大于第一周，计算剩余的过了几周
    	wIndex = math.ceil((data.day - tmpData) / 7) + 1
	    if wIndex > 4 then
	    	wIndex = 4
	    end
	else
		-- 此时是第一周
		wIndex = 1
    end
    return wIndex
    -- 以前张强写的，有问题
    -- local mothWday = dataMoth.wday - 2
    -- if mothWday == 0 then
    -- 	mothWday = 7
    -- elseif mothWday < 0 then
    -- 	mothWday = 6
    -- end

    -- wIndex = math.floor((data.day + mothWday - 1) / 7) + 1
    -- if wIndex > 4 then
    -- 	wIndex = 4
    -- end

    -- return wIndex
end
-- 获取指定日期的前几天、后几天的时间(时间格式YYYY-MM-DD)
function FuncCrosspeak.dataChange( time,dayChange )
	if string.len(time)==10 and string.match(time,"%d%d%d%d%-%d%d%-%d%d") then
	    local year=string.sub(time,0,4);--年份
	    local month=string.sub(time,6,7);--月
	    local day=string.sub(time,9,10);--日
	    local time=os.time({year=year, month=month, day=day})+dayChange*86400 --一天86400秒
	    return (os.date('%Y',time).."-"..os.date('%m',time).."-"..os.date('%d',time))
	else
		echoError ("时间格式错误")
		return time
	end
end

function FuncCrosspeak.getPlayerModel()
	local serverTime = TimeControler:getServerTime()
    local data = os.date("*t", serverTime) 

    local key 
    if data.month < 10 then
    	key = data.year.."0"..data.month
    else
    	key = data.year..data.month
    end

    local pmData = FuncCrosspeak.getPlayModelData( key )
    
    -- 本月第几周 的逻辑
    local wIndex = FuncCrosspeak.getWeekIndex()
    echo("现在是本月的第几周 === ",wIndex,serverTime)
    return pmData.type[wIndex]
end

-- 对决模式
function FuncCrosspeak.getBattleModel( seg )
	return FuncCrosspeak.getSegmentDataByIdAndKey(seg,"battleModel")
end
-- 对决模式名称
function FuncCrosspeak.getBattleModelName( seg )
	local batm = FuncCrosspeak.getSegmentDataByIdAndKey(seg,"battleModel")
	if tonumber(batm) == 1 then
		-- 自选
		return GameConfig.getLanguage("#tid_crosspeak_035")
	elseif tonumber(batm) == 2 then
		-- draft model
		return GameConfig.getLanguage("#tid_crosspeak_036")
	else
		echoError("没有此对决玩法")
	end
end
function FuncCrosspeak.getBattleModelDes( seg )
	local batm = FuncCrosspeak.getSegmentDataByIdAndKey(seg,"battleModel")
	if tonumber(batm) == 1 then
		-- 自选
		return GameConfig.getLanguage("#tid_crosspeak_030")
	elseif tonumber(batm) == 2 then
		-- draft model
		return GameConfig.getLanguage("#tid_crosspeak_031")
	else
		echoError("没有此对决玩法")
	end
end

function FuncCrosspeak.getOptionPartnerId()
	local serverTime = TimeControler:getServerTime()
    local data = os.date("*t", serverTime) 

    local key 
    if data.month < 10 then
    	key = data.year.."0"..data.month
    else
    	key = data.year..data.month
    end

    local weekIndex = FuncCrosspeak.getWeekIndex()
    return key, weekIndex
end

function FuncCrosspeak.getPlayModelData( id )
	local data = crossPeakPlayMethodOrder[id]
	if not data then
		echoError("新玩法配置表未找到此id == ",id,"用默认的 20180 4")
		return crossPeakPlayMethodOrder["201804"]
	end
	return data
end

function FuncCrosspeak:getPlayModelName( _type )
	_type = tonumber(_type)
	if _type == 1 then
		return GameConfig.getLanguage("#tid_crosspeak_037")
	elseif _type == 2 then
		return GameConfig.getLanguage("#tid_crosspeak_038")
	elseif _type == 3 then
		return GameConfig.getLanguage("#tid_crosspeak_039")
	else
		return "未知"
	end
end
function FuncCrosspeak:getPlayModelDes( _type )
	_type = tonumber(_type)
	if _type == 1 then
		return GameConfig.getLanguage("#tid_crosspeak_032")
	elseif _type == 2 then
		return GameConfig.getLanguage("#tid_crosspeak_033")
	elseif _type == 3 then
		return GameConfig.getLanguage("#tid_crosspeak_034")
	else
		return "未知"
	end
end

----------------------------------------------------------------
-- 段位配置
function FuncCrosspeak.getCrossPeakSegmentData()
	return crossPeakSegmentData
end
function FuncCrosspeak.getSegmentDataById( id )
	id = tostring(id)
	local data = crossPeakSegmentData[id]
	if data then
		return data
	else
		echoError("段位配置表未找到此id == ",id,"用默认的 1")
		return crossPeakSegmentData["1"]
	end
end
function FuncCrosspeak.getSegmentDataByIdAndKey(id,key)
	local data = FuncCrosspeak.getSegmentDataById(id)
	if data[key] then
		return data[key]
	else
		echoWarn("段位配置表id == ",id," 中未找到key == ",key)
		return nil	
	end
end
function FuncCrosspeak.getSegmentMinScore( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"scoreMin")
end
function FuncCrosspeak.getSegmentMaxScore( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"scoreMax")
end
function FuncCrosspeak.getSegmentName( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"segmentName")
end
function FuncCrosspeak.getSegmentIcon( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"segmentIcon")
end
function FuncCrosspeak.getSegmentReward( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"seasonSegmentReward")
end
function FuncCrosspeak.getSegmentUpReward( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"segmentUpReward")
end
function FuncCrosspeak.getSegmentFightNumMax( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"fightNumMax")
end
function FuncCrosspeak.getSegmentFightInStageMax( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"fightInStageMax")
end
function FuncCrosspeak.getSegmentLevelId( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"levelId")
end
function FuncCrosspeak.getAllSegmentNum( )
	return table.length(crossPeakSegmentData)
end
function FuncCrosspeak.getSegmentLevelName( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"levelName")
end
-- 排行榜显示排名
function FuncCrosspeak.getSegmentRankName( id )
	return FuncCrosspeak.getSegmentDataByIdAndKey(id,"rankName")
end
-------------------------------------------------------------------------------

----------------------------------------------------------------
-- 购买次数配置
function FuncCrosspeak.getCrossPeakTimeBuyData()
	return crossPeakTimeBuyData
end
-- 通过购买次数获取消耗仙玉数量
function FuncCrosspeak.getCostGoldByTimes( times )
    local data = crossPeakTimeBuyData[tostring(times)]
    if data.timePrice then
        return data.timePrice
    end
	return 10
end
-- 最大购买次数
function FuncCrosspeak.getMaxBuyTimes( )
	return table.length(crossPeakTimeBuyData)
end

-----------------------------------------------------------------
-- 排行奖励
function FuncCrosspeak.getCrossPeakRankReward()
	return crossPeakRankRewardData
end
-- 通过排名 获得奖励
function FuncCrosspeak.getRewardByRank( rank )
	local data = FuncCrosspeak.getCrossPeakRankReward()
 	for i,v in pairs(data) do
 		if v.rankStart <= rank and v.rank >= rank then
 			return v.reward
 		end
 	end
 	return {}
end 


-- 活跃度奖励
function FuncCrosspeak.getCrossPeakActiveReward()
	return crossPeakActiveRewardData
end
function FuncCrosspeak.getCrossPeakActiveRewardById( id )
	return crossPeakActiveRewardData[tostring(id)]
end
-- 根据积分获取对应的段位信息

-- 根据积分获取对应的段位
function FuncCrosspeak.getCurrentSegment(score)
	local data = FuncCrosspeak.getCrossPeakSegmentData()
	for i,v in pairs(data) do
		local scoreMin = FuncCrosspeak.getSegmentMinScore( v.id )
		local scoreMax = FuncCrosspeak.getSegmentMaxScore( v.id )
		if scoreMin <= score and scoreMax >= score then
			return v.id
		end
	end
	echoError("当前积分==",score," 没在表里找到对应的段位，返回默认段位 1")
	return "1"
end

-- 获取机器人配置相关
function FuncCrosspeak.getRobotDataById( id )
	local data = crossPeakRobotData[tostring(id)]
	if data then
		return data
	else
		echoError("机器人配置表未找到此id == ",id,"用默认的 1")
		return crossPeakRobotData["1"]
	end
end
-- 根据enemyInfo获取映射表对应的数据
function FuncCrosspeak.getPartnerMapping(enemyId)
	local data = crossPeakPartnerMappingData[tostring(enemyId)]
	if data then
		return data
	else
		echoError("伙伴映射配置表未找到此id == ",enemyId,"用默认的 300037")
		return crossPeakPartnerMappingData["300037"]
	end
end
-- 根据伙伴的id、仙界对决阶级获取映射表对应的数据
function FuncCrosspeak.getPartnerMappingByPartnerId(partnerId,seg)
	for k,v in pairs(crossPeakPartnerMappingData) do
		if v.partnerId == partnerId and v.contact then
			for m,n in pairs(v.contact) do
				if n == seg then
					return v
				end
			end
		end
	end
	echoError("配置表中的partnerId未找到此id == ",partnerId,"用默认的 300037")
	return crossPeakPartnerMappingData["300037"]
end
-- 根据阶级、法宝获取对应的映射数据
function FuncCrosspeak.getTreasureMappingByLvId( level,treasureId )
	local data = crossPeakTreasureMapping[tostring(level)]
	if data and data[tostring(treasureId)] then
		data = data[tostring(treasureId)]
	else
		echoError ("没有获取到对应的法宝信息,使用默认的法宝代替,level,treasureId,avatar:",level,treasureId,avatar)
		for k,v in pairs(crossPeakTreasureMapping) do
			for m,n in pairs(v) do
				data = n
				break
			end
		end
	end
	return data
end
-- 根据擂台阶数和法宝id获取对应的映射战斗法宝、法宝区分男女
function FuncCrosspeak.getTreasureMapping( level,treasureId,avatar)
	local data = FuncCrosspeak.getTreasureMappingByLvId(level,treasureId)

	if tostring(avatar) == "101" then --男
		return data.mapping1
	else
		return data.mapping2
	end
end
-- 获取 映射主角对应法宝额外的属性值
function FuncCrosspeak.getTreasureMappingExtAttr( level,treasureId)
	local data = FuncCrosspeak.getTreasureMappingByLvId(level,treasureId)
	local tmpArr = {}
	tmpArr.crit = data.crit
	tmpArr.resist = data.resist
	tmpArr.critR = data.critR
	tmpArr.block = data.block
	tmpArr.wreck = data.wreck
	tmpArr.blockR = data.blockR
	tmpArr.injury = data.injury
	tmpArr.maxenergy = data.maxenergy
	return tmpArr
end


-- 根据id获得宝箱数据
function FuncCrosspeak.getBoxDataById( boxId )
	boxId = tostring(boxId)
	local data = crossPeakBox[boxId]
	if data then
		return data
	else
		echoError("crossPeakBox表中未找到此id == ",id,"用默认的 1")
		return nil
	end
end
function FuncCrosspeak.getBoxDataByIdAndKey(boxId,key)
	local data = FuncCrosspeak.getBoxDataById( boxId )
	if data and data[key] then
		return data[key]
	else
		echoError("crossPeakBox表中未找到此id == ",id,"用默认的 1")
		return nil
	end
end
-- 宝箱图标
function FuncCrosspeak.getBoxIcon(boxId)
	return FuncCrosspeak.getBoxDataByIdAndKey(boxId,"boxPic")
end
-- 宝箱名称
function FuncCrosspeak.getBoxName(boxId)
	return FuncCrosspeak.getBoxDataByIdAndKey(boxId,"boxName")
end
-- 宝箱解锁时长
function FuncCrosspeak.getBoxUnlockTime(boxId)
	return FuncCrosspeak.getBoxDataByIdAndKey(boxId,"unlockNeedTime")
end
-- 宝箱奖励说明
function FuncCrosspeak.getBoxRewardTips(boxId)
	return FuncCrosspeak.getBoxDataByIdAndKey(boxId,"boxTips")
end
-- 奇侠
function FuncCrosspeak.getPartersByLevelId(levelId)
	local data = crossPeakRollPartner[tostring(levelId)]
	local T = {}
	for i,v in pairs(data) do
		local partners = v.templatePartner
		for ii,vv in pairs(partners) do
			table.insert(T,vv)
		end
	end

	return T
end

------------------------------------------------------------------
--------------------------仙盟相关--------------------------------
------------------------------------------------------------------
function FuncCrosspeak.getGuildRankData( )
	return crossPeakGuildRankReward
end
function FuncCrosspeak.getGuildAccumulateData( )
	return crossPeakGuildAccumulateReward
end


function FuncCrosspeak.getCrossPeakPartnerMapping( )
	return crossPeakPartnerMappingData
end
function FuncCrosspeak.getCrossPeakPartnerData(id )
	local data = crossPeakPartnerMappingData[id]
	if not data then
		echoError("crossPeakPartnerMappingData 表中未找到 id== ",id)
		return nil
	end
	return data
end
function FuncCrosspeak.getCrossPeakPartnerBySourceId(id )
	local data = crossPeakPartnerMappingData[id]
	if not data then
		echoError("crossPeakPartnerMappingData 表中未找到 id== ",id)
		return nil
	end
	return data["partnerId"]
end
function FuncCrosspeak.getCrossPeakPartnerSourceId( partnerId )
	for k,v in pairs(crossPeakPartnerMappingData) do
		if v.partnerId == partnerId then
			return v.partnerTemplateId
		end
	end

	return nil
end
-- 通过ID获得机器人信息
function FuncCrosspeak.getRobotData(id)
	local data = crossPeakRobotData[tostring(id)]
	if not data then
		echoError("crossPeakRobotData 表中未找到 id== ",id)
		return nil
	end
	return data
end

-- 通过id获得任务信息
function FuncCrosspeak.getTastDataById( id )
	local data = crossPeakTask[id]
	if not data then
		echoError("crossPeakTask 表中未找到 id== ",id)
		return nil
	end
	return data
end
-- 根据连败次数获取对应的加成
function FuncCrosspeak.getLosingProperty(id )
	local data = crossPeakLoseProperty[tostring(id)]
	if not data then
		echoError("crossPeakLoseProperty 表中未找到 id== ",id," 使用最大加成7代替")
		return crossPeakLoseProperty["7"]
	end
	return data
end
-- 根据映射id回去对应的属性加成数据
function FuncCrosspeak.getMoneyProperty(mappingId )
	local data = crossPeakMoneyProperty[tostring(mappingId)]
	if not data then
		echoError("crossPeakMoneyProperty 表中未找到 id== ",mappingId)
		return nil
	end
	return data
end
-- 根据回合获取回合加成的属性数据[返回nil说明没有属性加成]
function FuncCrosspeak:getFasterPropertyByRound( round )
	local data = crossPeakFastProperty[tostring(round)]
	return data
end

-- 配的奇侠数据
function FuncCrosspeak.getParternerData(enemyId)
	local enemyInfoCfg = Tool:configRequire("level.EnemyInfo")
	local enemyData = enemyInfoCfg[enemyId]
	local mapData = FuncCrosspeak.getCrossPeakPartnerData(enemyId)
	local data = {}
	data.level = enemyData.lv
	data.partnerId = mapData.partnerId
	data.star = mapData.star or 1 
	data.quality = mapData.quality or 1

	--属性加成
	local attrT = {}
	local _d = {}
	_d.key = 2
	_d.value = enemyData.hp
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 10
	_d.value = enemyData.atk
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 11
	_d.value = enemyData.def
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 12
	_d.value = enemyData.magdef
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 13
	_d.value = enemyData.crit
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 14
	_d.value = enemyData.resist
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 15
	_d.value = enemyData.critR
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 16
	_d.value = enemyData.block
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 17
	_d.value = enemyData.wreck
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 18
	_d.value = enemyData.blockR
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 19
	_d.value = enemyData.injury
	table.insert(attrT,_d)

	local _d = {}
	_d.key = 20
	_d.value = enemyData.avoid
	table.insert(attrT,_d)

	data.attr = attrT
	return data
end

function FuncCrosspeak.getCrossPeakOptionPartnerBySegment(_segment)
	local optionPartners = {}
	local opPart = {}
	local optionPartnerId, week = FuncCrosspeak.getOptionPartnerId()
	local data = crossPeakOptionPartner[tostring(optionPartnerId)]
	if tonumber(week) > 4 then
		week = 4
	end

	local curWeekData = data["optionPartner"..week]
	if curWeekData[tonumber(_segment)] then
		local str_table = string.split(curWeekData[tonumber(_segment)], ",")
		for i,v in ipairs(str_table) do
			local partnerId = FuncCrosspeak.getCrossPeakPartnerBySourceId(v )
			table.insert(optionPartners, partnerId)
			local d = {sid = v,id = partnerId}
			table.insert(opPart, d)
		end
	end

	return optionPartners,opPart
end

function FuncCrosspeak.getCrossPeakNpcIdByPlayType(_type, seg)
	if tonumber(_type) == FuncCrosspeak.PLAYMODE.CACTUS and tonumber(seg) > 1 then
		local data = FuncDataSetting.getDataByHid("CrossPeakCactusId")
		return data.str
	end

	return "0"
end

