FuncGuild= FuncGuild or {}

local groudLvData = nil
local groupRightData = nil
local guildDonate = nil
local guildBuild = nil
local guildBuildUp = nil
local guildLv = nil
local guildType = nil
local guildEvent = nil
local guildExchange = nil
local guildRedPacket = nil
local guildDigReward = nil
local guildActive = nil

FuncGuild.isDebug = false

local guildTask = nil
local guildGlory = nil
local popularityRank = nil


FuncGuild.guildNameType = {
	[1] = "盟",
	[2] = "门",
	[3] = "阁",
	[4] = "教",
	[5] = "山庄",
	[6] = "世家",
}
FuncGuild.MEMBER_RIGHT = {
	LEADER = 1,  --盟主
	SUPER_MASTER = 2,  --副盟主
	MASTER = 3,   --精英
	PEOPLE = 4,   --成员
}
FuncGuild.MEMBER_NAME = {
	[1] = "盟主",
	[2] = "副盟主",
	[3] = "精英",
	[4] = "成员",
}

FuncGuild.guildIconType = {
	BORDERTYPE  = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4,
	},
	BGTYPE = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4,
	},
	ICONTYPE = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4,
	},
}
FuncGuild.guildBuildType = {
	TAIQINGDUAN = 1,
	OFFICES = 2,
	PRAyERHALL = 3,
	DEARLIGHTHUOSE = 4,
	TASKHALL = 5,
	MOUNTAINBARRIER = 6,
	EXPPAVILION = 7,
}
FuncGuild.guildBuildName = {
	[1] = "#tid_group_name_101",  --太清殿
	[2] = "#tid_group_name_102", --"账房",
	[3] = "#tid_group_name_103", --"祈福堂",
	[4] = "#tid_group_name_104", --"璇光殿",
	[5] = "#tid_group_name_105", --"任务大厅",
	[6] = "#tid_group_name_106", --"护山结界",
	[7] = "#tid_group_name_107", --"历练阁",
}

FuncGuild.titlename = {
	[1] = "祈福",
	[2] = "心愿",
	[3] = "收集",
	[4] = "交换",
}

FuncGuild.members_right = {
	[11] = "guild_img_zhangmen",
	[12] = "guild_img_fuzhangmen",

	[21] = "guild_img_menzhu",
	[22] = "guild_img_fumenzhu",

	[31] = "guild_img_gezhu",
	[32] = "guild_img_fugezhu",

	[41] = "guild_img_jiaozhu",
	[42] = "guild_img_fujiaozhu",

	[51] = "guild_img_zhuangzhu",
	[52] = "guild_img_fumenzhu",

	[61] = "guild_img_jiazhu",
	[62] = "guild_img_fujiazhu",

	[3] = "guild_img_jingying",
	[4] = "guild_img_chengyuan",
}

FuncGuild.Help_Type = {
	QIFU = 1,  --祈福
	TAIQINGDIAN = 2,  --太清殿
	ZAHNGFANG = 3,--账房   ---- 干掉
	SHOP = 4,  --商店
	WUJIGE = 5,  -- 无极阁
	TASK = 6,---任务
	TREASURY = 7, -- 宝库   ---替换账房
}

FuncGuild.MapPointTab = {
	right = {x = 2860,y = -440},
	left = { x = 940, y = -440 }
}

--叶签类型
FuncGuild.Leaf_Sign_Type = {
	INFO = 1,  --详情
	MEMBERS = 2,  --成员
	APPLY = 3,--申请
	ACTIVE = 4,  --活动
}

--叶签类型
FuncGuild.Leaf_Sign_Type_Str = {
	[1] = "详情",  --详情
	[2] = "成员",  --成员
	[3] = "申请",--申请
	[4] = "活动",  --活动
}


FuncGuild.GuildIcon = 101 ---获得仙盟贡献值

--红包领取状态
FuncGuild.redPacket_State_Type = {
	GET = 1,  --可领取
	IN_GET_ALL = 2,  ---以抢光	
	IN_GET = 3,  --已领取
	
}

--红包抢取状态
FuncGuild.RedPacket_Grab_Type = {
	GET = 1,--抢到
	NOT_GET = 2,--未抢到
}



--仙盟主城玩家的大小
FuncGuild.OtherScal = 0.85
FuncGuild.MinScal = 0.85

FuncGuild.pageNum = 10 ---每一页的数据量

FuncGuild.disbandStr = GameConfig.getLanguage("#tid_guild_add_001")
FuncGuild.TIPSSTR = GameConfig.getLanguage("#tid_guild_creat_001")

FuncGuild.ErrorCode = {
	[1] = 135901,
	[1] = 135902,	

}




FuncGuild.Exchange_Type = {
	Out_Item = 1, --换出道具
	Into_Item = 2, --换入道具

}

FuncGuild.Tranlast = {
	[1] = "#tid_guild_exchange_101",  -- GameConfig.getLanguage(
	[2] = "#tid_guild_exchange_102",
	[3] = "#tid_guild_exchange_103",
	[4] = "#tid_guild_exchange_104",
	[5] = "#tid_guild_exchange_105",
	[6] = "#tid_guild_exchange_106",
	[7] = "#tid_guild_exchange_107",
	[8] = "#tid_guild_exchange_108",
	[9] = "#tid_guild_exchange_109",
	[10]= "#tid_guild_exchange_110",
	[11]= "#tid_guild_exchange_111",
	[12]= "#tid_guild_exchange_112",
	[13]= "#tid_guild_exchange_113",
	[14]= "#tid_guild_exchange_114",
	[15]= "#tid_guild_exchange_115",
	[16]= "#tid_guild_exchange_116",
	[17]= "#tid_guild_exchange_117",
	[18]= "#tid_guild_exchange_118",
	[19]= "#tid_guild_exchange_119"

}


---事件的类型
FuncGuild.GuildEventType = {
	Donate = 9, ---捐献
	Promote = 10, --精研提升
	Blessing = 11, --祈福
	Pay = 12, --缴纳
	FinishTask = 13,--任务完成
}





-- 条件类型(
FuncGuild.Conditions_Type = {
	TOP_UP = "1", --累积充值,
	MAIN_LINE =	"2",   	--通关主线关卡,
	PARTNER ="3",   	--首次获得X星奇侠,
	PVP = "4",   	--登仙台排名,
	TOWER =	"5",   	--锁妖塔完美通关,
	WONDERLAND = "6",  	--须臾仙境最高层数,
	ENDLESS = "7",   	--无底深渊到达第几重,
	CROSSPEAK =	"8",   	--仙界对决段位,
	CIMELIA = "9",   	--激活神器数量,
	PVP_END = "10",   	--登仙台结算排名,
	DAILY_TOP_UP = "11",   	--每日充值,
	TASK = "12",  	 --每日任务完成数量,
	DAILY_CROSSPEAK = "13",   	--每日参与X次仙界对决
}

--显示条件次数为  .."/1"
FuncGuild.RedPacket_Conditions = {"2","3","4","5","6","7","8","10"}

-- =================== 无极阁 ==============================
-- 无极阁右侧标签主题数量
FuncGuild.infinitePavilionThemeMaxNum = 6
-- 标签index 到 主题id 的映射表
FuncGuild.indexToThemeIdMap = {"1","2","3","4","5",'6'}
-- 全局属性 附加的奇侠目标类型
FuncGuild.appendTarget = {
    CHAR = 0,      --主角
    OFFENSIVE = 1, -- 攻击型
    DEFENSIVE = 2, -- 防御型
    ASSISTED = 3,  -- 辅助型
}
FuncGuild.appendTargetName = {
     [0] = "主角",      --主角
     [1] = "攻击奇侠", -- 攻击型
     [2] = "防御奇侠", -- 防御型
     [3] = "辅助奇侠",  -- 辅助型
}
-- 技能点属性生效区域
-- 全局还是特定玩法
FuncGuild.effectZoneType = {
	GLOBAL = "1",   	-- 全局生效,类似情缘全局属性
	PVP = "2", 			-- 等仙台生效
	SHAREBOSS = "12",    -- 幻境协战中生效
	GUILDBOSS = "21",    -- 仙盟副本中生效
	WONDERLAND = "17",   -- 须臾仙境中生效
	ENDLESS = "20",      -- 无底深渊中生效
}

-- 影响其他系统的资源产出和资源消耗
FuncGuild.affectTarget = {
    Addition = 1,      	-- 资源产量增加类型 
    Reduction = 0,      -- 购买消耗减少类型 
}

-- FuncGuild.amountType = {
-- 	addition_trialA = 1 ,  -- 山神试炼奖励
-- 	addition_trialB = 2 ,  -- 火神试炼奖励
-- 	addition_trialC = 3 ,  -- 盗宝者试炼奖励
-- 	addition_PVPEveryDayReward = 4 ,  -- 等仙台每日奖励
-- 	addition_buyCoin = 5 ,  -- 购买铜钱获取量
-- 	-- addition_wandLand = 6 ,  -- 须臾仙元产量

-- 	decrement_refreshShop_stone = 7 ,  -- 灵石商店刷新消耗
-- 	decrement_refreshShop_1 = 8 ,  -- 杂货商店刷新消耗
-- 	decrement_refreshShop_pvp = 9 ,  -- 等仙台商店刷新消耗
-- 	decrement_refreshShop_trial = 10 ,  -- 试炼商店刷新消耗
-- 	decrement_refreshShop_artifact = 11 ,  -- 神器商店刷新消耗
-- 	decrement_refreshShop_tower = 12 ,  -- 锁妖塔商店刷新消耗
-- 	decrement_refreshShop_wonder = 13 ,  -- 须臾仙境商店刷新消耗
-- }

-- 无极阁技能组的名字
FuncGuild.themeName = {
	GameConfig.getLanguage("#tid_guild_skillname_1"),
	GameConfig.getLanguage("#tid_guild_skillname_2"),
	GameConfig.getLanguage("#tid_guild_skillname_3"),
	GameConfig.getLanguage("#tid_guild_skillname_4"),
	GameConfig.getLanguage("#tid_guild_skillname_5"),
	GameConfig.getLanguage("#tid_guild_skillname_6"),
}
-- 无极阁技能组 内阶段
FuncGuild.stageName = {
	"一","二","三","四","五",
	"六","七","八","九","十",
}	

--仙盟任务类型（1=缴纳材料、2=消耗体力、3=组队玩法 ,4 = 排行榜）
FuncGuild.guildTask_type = {
	ITEM = 1,
	SP = 2,
	TEAM = 3,
	RAINK = 4,
}

FuncGuild.guildTAsk_type_name = {
	[1] = "#tid_guildtask_name_1001",
	[2] = "#tid_guildtask_name_1004",
	[3] = "#tid_guildtask_name_1005",
	[4] = "#tid_guildtask_name_1006",
}


FuncGuild.guildTAsk_Event_list = {
	[1001] = "#tid_guildtask_101",
	[1002] = "#tid_guildtask_101",
	[1003] = "#tid_guildtask_101",
	[1004] = "#tid_guildtask_102",
	[1005] = "#tid_guildtask_103",
	[2001] = "#tid_guildtask_104",
	[2002] = "#tid_guildtask_105",
	[2003] = "#tid_guildtask_106",

}


FuncGuild.guildDig_Reward_From = {
	DIGREWARD = 1,
	DUIHUAN = 2,
}

FuncGuild.guild_Treasure_Main_view_First = {
	TREASURE = 1,
	WISH = 2,
}



function FuncGuild.init(  )
	-- groudLvData = require("guild.GroupLv");
	groupRightData = Tool:configRequire("guild.GuildRight");
	guildDonate = Tool:configRequire("guild.GuildDonate");
	guildDonateBox = Tool:configRequire("guild.GuildDonateBox");
	guildBuild = Tool:configRequire("guild.GuildBuild");
	guildBuildUp = Tool:configRequire("guild.GuildBuildUp");
	guildLv = Tool:configRequire("guild.GuildLv");
	guildType = Tool:configRequire("guild.GuildType");
	guildEvent = Tool:configRequire("guild.GuildEvent");
	
	guildExchange =  Tool:configRequire("guild.GuildExchange");
	guildRedPacket = Tool:configRequire("guild.GuildRedPacket");

	guildSkillGroup = Tool:configRequire("guild.GuildSkillGroup");
	guildSkillDetail = Tool:configRequire("guild.GuildSkill");
	GuildSkillProperty = Tool:configRequire("guild.GuildSkillProperty");
	guildTask = Tool:configRequire("guild.GuildTask");
	guildGlory = Tool:configRequire("guild.GuildGlory");
	popularityRank = Tool:configRequire("guild.PopularityRank");
	guildRedPacket = Tool:configRequire("guild.GuildRedPacket");

	guildDigReward = Tool:configRequire("guild.DigReward")


	guildActive = Tool:configRequire("guild.GuildActivity");

	FuncGuild.settranslate()
end

function FuncGuild.settranslate()
	for i=1,#FuncGuild.Tranlast do
		FuncGuild.Tranlast[i] =  GameConfig.getLanguage(FuncGuild.Tranlast[i])
	end

end


function FuncGuild.getguildType()
	return guildType
end
-- function FuncGuild.getGroudLvData(id, key)
-- 	local value = groudLvData[tostring(id)][tostring(key)];
--     return numEncrypt:getNum(value);
-- end
function FuncGuild.getBuildPos(buildid)
	local posstr  = guildBuild[tostring(buildid)]
	-- dump(posstr,"444444444",8)
	-- local pos = string.split(posstr.pos, ";")
	return posstr.pos
end

function FuncGuild.getGuildEvent(eventID)
	local str  = guildEvent[tostring(eventID)]
	return str
end




--根据仙盟等级获得数据
function FuncGuild.getGuildLevelByPreserve(level)
  	local data = guildLv[tostring(level)]
  	if data == nil then
  		echoError("没有传入仙盟等级数据--",level)
    	data = guildLv["1"]  --当数据为空时，默认给一个1等级
  	end
  	return data
end
--获得所有建筑
function FuncGuild.getguildBuildAllData()
	return guildBuild
end

--获得建筑升级列表
function FuncGuild.getguildBuildUpAllData()
	return guildBuildUp
end

function FuncGuild.getGroupRightData(id,key)
	local value = groupRightData[tostring(id)][tostring(key)];
    return numEncrypt:getNum(value);
end

--仙盟捐献数据
function FuncGuild.getGuildDonate(id)
	local value = guildDonate[tostring(id)]
	return value
end

--仙盟缴纳玄盒数据
function FuncGuild.getGuildDonateBoxData(id)
	local value = guildDonateBox[tostring(id)]
	return value
end


--创建仙盟的花费
function FuncGuild.createGuidCostNumber()
	return FuncDataSetting.getDataByConstantName("GuildCreateCost")
end

--剔除仙盟成员的花费
function FuncGuild.deleteGuidplayerCost()
	return 1000
end

--获得签到文本
function FuncGuild.getSignLanguage()
	return GameConfig.getLanguage("#tid_group_101")
end

---获得创建天数
function FuncGuild.getGuildCreateDay()
	return FuncDataSetting.getDataByConstantName("GuildEstablishTime")
end

---获得仙盟中的人数
function FuncGuild.getGuildMemNUm()
	return FuncDataSetting.getDataByConstantName("GuildPeople")
end

--获得剩余次数
function FuncGuild.getDonationNumber()
	return FuncDataSetting.getDataByConstantName("GuildDonateNum")
end
--获得默认宣言
function FuncGuild.getdefaultDec()
	return GameConfig.getLanguage("#tid_group_102")
end

--获得默认公告
function FuncGuild.getdefaultNotice()
	return GameConfig.getLanguage("#tid_group_103")
end

--获得每条心愿的时间
function FuncGuild.getWishTime()
	return FuncDataSetting.getDataByConstantName("GuildBlessingTime")
end

--获得申请的次数
function FuncGuild.getAppNum()
	return FuncDataSetting.getDataByConstantName("GuildApplyNum")
end

function FuncGuild.getBoundsTime()
	return 5 * 30
end

--自动退出公会的惩罚时间
function FuncGuild.closeGuildTime()
	return FuncDataSetting.getOriginalData("GuildPunishment")
end

--某个玩家退出公会的时间
function FuncGuild.outofGuildTime()
	local time = FuncDataSetting.getDataByConstantName("GuildNothingExpel")
	local day = math.floor(time/(3600*24))
	return day
end

--每天踢人的数量
function FuncGuild.getDayGuildOutPeople()
	return 10
end

--获得仙盟玩法规则
function FuncGuild.getRulseStr(_type)
	local str = ""
	if _type == FuncGuild.Help_Type.QIFU then
		str = GameConfig.getLanguage("#tid_group_rule_103")
	elseif _type == FuncGuild.Help_Type.TAIQINGDIAN then
		str = GameConfig.getLanguage("#tid_group_rule_102")
	elseif _type == FuncGuild.Help_Type.TREASURY then
		str = GameConfig.getLanguage("#tid_group_rule_101")
	elseif _type == FuncGuild.Help_Type.WUJIGE then
		str = GameConfig.getLanguage("#tid_group_rule_104")
	elseif _type == FuncGuild.Help_Type.TASK then
		str = GameConfig.getLanguage("#tid_group_rule_105")
	end
	return str
end


function FuncGuild.getCreateTime( time )
	-- local time = time  ---仙盟的创建时间
    -- local weekday = os.date("%w",time)   --[0-6] 周日 到周六
    -- local toForeTime = FuncCommon.byTimegetleftTime(time) ---离四点还有多少时间  - 3600  离3点还有多少时间
    local sumTIme = FuncGuild.getGuildCreateDay()   ----间隔时间
    local dataTime = os.date("*t",time)

    -- dump(dataTime,"222222222222222")
    local addTiem = 3
    if dataTime.hour < 3 then
    	-- addTiem = addTiem - 1
    else
    	addTiem = addTiem + 1
    end
    local timeArr = {
		day = dataTime.day+addTiem, 
		month = dataTime.month,
		year = dataTime.year, 
		hour= 3 ,
		min= 0, 
		second = 0,
	}
	local tamps = os.time(timeArr)   ---结束时间

	-- echo("=========time==tamps=====",time,tamps)

	return tamps - TimeControler:getServerTime()

end




---根据是十进制的数，转化成二进制的数组形式
function FuncGuild.byCountTypeGetTable(sumNum,_typeNum)
	local _table = {}
	local count = 3
	if _typeNum ~= nil then
		count = _typeNum
	end
	for i=1,count do
		_table[i] = 0
	end
	if sumNum and sumNum ~= 0  then
		local twotable = {}
		for i=1,#_table do
			local remainder = 0  -- 余数
			remainder = math.fmod(sumNum, 2)
			sumNum = math.floor(sumNum/2)
			twotable[i] = remainder
		end
		for i=1,#twotable do
			_table[i] = twotable[i]
		end
	end

	return _table
end


function FuncGuild.byIdAndPosgetName(guildType,postype)
	-- echo("===========guildType===========",guildType,postype)
	local guildname = FuncGuild.guildNameType[guildType]
	local beizhu = "主"
	local _typeid = 4
	if guildType == 1 then
		guildname = "掌"
		beizhu = "门"
	end
	_typeid = guildType * 10 + postype
	local str = ""
	if postype == FuncGuild.MEMBER_RIGHT.LEADER then   --主
		str =  guildname..beizhu

	elseif postype == FuncGuild.MEMBER_RIGHT.SUPER_MASTER  then   ---副
		str =  "副"..guildname..beizhu

	elseif postype == FuncGuild.MEMBER_RIGHT.MASTER  then   --精英
		str =  FuncGuild.MEMBER_NAME[postype]
		_typeid = 3
	elseif postype == FuncGuild.MEMBER_RIGHT.PEOPLE  then   --成员
		str =  FuncGuild.MEMBER_NAME[postype]
		_typeid = 4
	end

	local sptite = 	FuncGuild.members_right[_typeid]
	return str,sptite

end




local mainMap = {
	[1] ={ {x = 250,y = -436},{x= 410,y = -606}},
	[2] ={ {x = 275,y = -414},{x= 750,y = -510}},
	[3] ={ {x = 750,y = -517},{x= 1100,y = -436}},

}

function FuncGuild.guildMapPlayerPos(_pos)
	local startP = mainMap[1][1]
	local endP = mainMap[1][2]
	local lineTab = {}
	for i=1,#mainMap do
		lineTab[i] = Equation.creat_1_1_b(mainMap[i][1],mainMap[i][2],false)
		local distance = Equation.pointLineDistance(_pos,lineTab[i])
		if distance <= 1 then
			return true
		end
	end
	return false
end


-- FuncGuild.MapPointTab = {
-- 	right = {x = 2860,y = -440},
-- 	left = { x = 940, y = -440 }
-- }

function FuncGuild.walkingArea(posx,posy)
	local isArea = false
	local x = FuncGuild.MapPointTab.left.x
	local y = FuncGuild.MapPointTab.left.y
	if posx <= x - 40 and posy >= y - 40 then
		isArea = true 
	elseif posy <= y - 40  and   posx <= x - 230  and  posy > y - 80  then
		isArea = true
	elseif   posx <= x - 500 and posy <= y - 90   then
		isArea = true
	end


	return isArea
end

--获得所有兑换的数据
function FuncGuild.getAllExchangeData()

	local arr = {}
	local alldata =   table.copy(guildExchange)
	for k,v in pairs(alldata) do
		v.id = k
		arr[tonumber(k)] = v
	end
	return arr
end

--获得宝箱名称
function FuncGuild.getExchangeName(exchangeID)
	local data = guildExchange[tostring(exchangeID)]
	if data == nil then
		echoTag('tag_guild_exchange',true,"不存在兑换ID===",exchangeID,"wk")
		data = guildExchange[tostring(1)]
	end
	return data.name
end


--获得兑换消耗
function FuncGuild.getExchangeCostData(exchangeID)
	local data = guildExchange[tostring(exchangeID)]
	if data == nil then
		echoTag('tag_guild_exchange',true,"不存在兑换ID===",exchangeID,"wk")
		data = guildExchange["1"]
	end
	return data.cost
end

--获得对应奖励
function FuncGuild.getExchangeRewardData(exchangeID)
	local data = guildExchange[tostring(exchangeID)]
	if data == nil then
		echoTag('tag_guild_exchange',true,"不存在兑换ID 获得对应奖励===",exchangeID,"wk")
		data = guildExchange[tostring(1)]
	end
	return data.reward
end


--再来一次奖励
function FuncGuild.getagainRewardData(exchangeID)
	local data = guildExchange[tostring(exchangeID)]
	if data == nil then
		echoTag('tag_guild_exchange',true,"不存在兑换ID 再来一次奖励===",exchangeID,"wk")
		data = guildExchange[tostring(1)]
	end
	return data.again
end

--再来一次奖励
function FuncGuild.getagainDescData(exchangeID)
	local data = guildExchange[tostring(exchangeID)]
	if data == nil then
		echoTag('tag_guild_exchange',true,"不存在兑换ID 再来一次奖励===",exchangeID,"wk")
		data = guildExchange[tostring(1)]
	end
	return data.description
end








--获取所有获取红包列表
function FuncGuild.getRedPacketAllList()

	-- dump(guildRedPacket,"===所有红包数据=====")
	local allData  = guildRedPacket
	local dailyQuest = {}
	local achievementData  = {}
	for k,v in pairs(allData) do
		if v.refresh == 0 then  --不刷新  --成就
			v.id = tonumber(v.id)
			table.insert(achievementData,v)
		else  --刷新 --日常
			v.id = tonumber(v.id)
			table.insert(dailyQuest,v)
		end
	end

	local function sortFunc(a, b)
		if a.id < b.id then
			return true
		else
			return false
		end
	end
	table.sort(achievementData, sortFunc)
	table.sort(dailyQuest, sortFunc)
	return dailyQuest,achievementData
end

function FuncGuild.getRedPacketType(id,key)
	local data = guildRedPacket[tostring(id)]
	if data == nil then
		echo('guild_red_packet',true,"不存在该红包id ===",id,"wk")
		-- return nil
	end 
	local ret = data[key];
	return ret
end

--根据红包ID获取红包信息
function FuncGuild.getpacketDataById(packetID)
	local data = guildRedPacket[tostring(packetID)]
	if data == nil then
		echoTag('guild_red_packet',true,"不存在该红包id ===",id,"wk")
	end 
	return data
end

function FuncGuild.getMaxRedPacketCount()
	local count = FuncDataSetting.getDataByConstantName("RedPacketLimit") or 20

	return count
end

--每日双倍个人奖励的次数
function FuncGuild.getGuildTaskDoubleCount()
	local num = FuncDataSetting.getDataByConstantName("GuildTaskDouble")
	return num
end

--每日每人最大完成任务次数
function FuncGuild.getGuildTaskMaxCount()
	local num = FuncDataSetting.getDataByConstantName("GuildTaskMax")
	return num
end


--仙盟任务资源分类
function FuncGuild.ClassguildTask()
	local arrData = {}
	for k,v in pairs(guildTask) do
		local _type = tonumber(v.type)
		if arrData[_type] then
			table.insert(arrData[_type],v)
		else
			arrData[_type] = {}
			table.insert(arrData[_type],v)
		end
	end
	

	return arrData
end


-- ============== 仙盟科技用到的函数 ======================================
-- 获取一组的数据
function FuncGuild.getGroupDataByGroupId( groupId )
	if guildSkillGroup and guildSkillGroup[tostring(groupId)] then
		return guildSkillGroup[tostring(groupId)]
	end
end

-- 获取一组的阶段总数量
function FuncGuild.getGroupTotalStagesByGroupId( groupId )
	local stagesNum = 0
	if guildSkillGroup and guildSkillGroup[tostring(groupId)] then
		for k,v in pairs(guildSkillGroup[tostring(groupId)]) do
			stagesNum = stagesNum + 1 
		end
	end
	return stagesNum
end

-- 获取一组的某阶段的数据
function FuncGuild.getGroupDataByGroupAndStageId( groupId,stageId )
	if guildSkillGroup and guildSkillGroup[tostring(groupId)] then
		for k,v in pairs(guildSkillGroup[tostring(groupId)]) do
			if k == tostring(stageId) then
				return guildSkillGroup[tostring(groupId)][tostring(stageId)]
			end
		end
	end
end

-- 获取一个技能的数据
function FuncGuild.getSkillDataBySkillId( skillId )
	if guildSkillDetail and guildSkillDetail[tostring(skillId)] then
		return guildSkillDetail[tostring(skillId)]
	end
end

-- 获取一个技能所在阶段
function FuncGuild.getSkillStage( skillId )
	local curSkillData = FuncGuild.getSkillDataBySkillId( skillId )
	if curSkillData and curSkillData.level then
		return curSkillData.level
	end
end

-- 获取技能属性数据
function FuncGuild.getSkillEffectDataById( effectId )
	if GuildSkillProperty then
		return GuildSkillProperty[tostring(effectId)]
	end
end

-- 初始化 获取 每个主题下所有技能
function FuncGuild.initAllThemeAndTheirSkills()
	local allThemeSkills = {}
	for themeId,v in pairs(guildSkillGroup) do
		allThemeSkills[themeId] = {}
		for stageId,vv in pairs(v) do
			if vv.skillId then
				for kkk,oneSkillId in pairs(vv.skillId) do
					allThemeSkills[themeId][oneSkillId] = 1
				end
			end
		end
	end
	return allThemeSkills
end


--------------------------------------------------------------------------
---------------------- 对外 属性和战力接口       -------------------------
-- 类似 情缘全局属性接口
--------------------------------------------------------------------------
function FuncGuild.getGuildAddProperty(partnerData,guildSkillsData)
    -- dump(partnerData,"\n\n\n\n\n\n\n伙伴系统传进来的伙伴数据==属性")
    if not partnerData then
        return {}
    end
    local propertyTotal = {}
    if guildSkillsData then
    	local targetZone = FuncGuild.effectZoneType.GLOBAL
        local searchPropertyData = FuncGuild.getCalculatePropertyData(guildSkillsData,targetZone)
        local dataArr = {}
        local isChar = FuncPartner.isChar(partnerData.id)
        if isChar then
            -- dump(searchPropertyData.char, "searchPropertyData.char")
            dataArr = searchPropertyData.char or {}
        else
            local partnerType =  FuncPartner.getPartnerById(partnerData.id).type
            if partnerType == FuncGuild.appendTarget.OFFENSIVE then 
                -- dump(searchPropertyData.offensive, "searchPropertyData.offensive")
                dataArr = searchPropertyData.offensive or {}
            elseif partnerType == FuncGuild.appendTarget.DEFENSIVE then  
                -- dump(searchPropertyData.defensive, "searchPropertyData.defensive")
                dataArr = searchPropertyData.defensive or {}
            elseif partnerType == FuncGuild.appendTarget.ASSISTED then
                -- dump(searchPropertyData.assisted, "searchPropertyData.assisted")
                dataArr = searchPropertyData.assisted or {}
            end  
        end
        if dataArr and table.length(dataArr)>0 then
            for k,v in pairs(dataArr) do
                local tempProperty = {}
                tempProperty.key = v.key
                tempProperty.value = v.value
                tempProperty.mode = v.mode
                table.insert(propertyTotal,tempProperty)
            end
        end
    end

    return propertyTotal
end


-- ===========================================================================================
-- 获取计算用的属性数据
-- usermodel中的仙盟技能数组,及生效区域(effectZoneType 生效区域 全局还是特定玩法)
 -- "guildSkills" = {
 --     "1" = 104
 --     "2" = 204
 --     "3" = 304
 -- }
function FuncGuild.getCalculatePropertyData(guildSkillsData,effectZoneType)
	local allConfigData = FuncGuild.getAllPropertyDataByType(guildSkillsData,effectZoneType)
    -- 读取已经获得的技能点的配置数据
    -- 分类统计
    local calculateData = {
        char = {},
        offensive = {},
        defensive = {},
        assisted = {},
        power = 0, -- 战力
    }
    for k,v in pairs(allConfigData) do
        -- dump(v, "===============vvvvvvvvvv")
        if v and table.length(v) > 0 then
            for kk,vv in pairs(v) do
                local proTemp = vv 
                if proTemp.target == FuncGuild.appendTarget.CHAR then  
                    calculateData.char[#calculateData.char + 1] = proTemp
                elseif proTemp.target == FuncGuild.appendTarget.OFFENSIVE then  
                    calculateData.offensive[#calculateData.offensive + 1] = proTemp
                elseif proTemp.target == FuncGuild.appendTarget.DEFENSIVE then  
                    calculateData.defensive[#calculateData.defensive + 1] = proTemp
                elseif proTemp.target == FuncGuild.appendTarget.ASSISTED then
                    calculateData.assisted[#calculateData.assisted + 1] = proTemp
                end  
            end
        end
    end
    if FuncGuild.isDebug then
        dump(calculateData.char, "calculateData.char")    
        dump(calculateData.offensive, "calculateData.offensive")    
        dump(calculateData.defensive, "calculateData.defensive")    
        dump(calculateData.assisted, "calculateData.assisted")    
    end
    return calculateData
end


--[[获取仙盟无极阁技能修炼 对全局或者特定玩法的属性加成数据
传入usermodel下仙盟技能修炼进展数组
  "guildSkillsData" = {
      "1" = 104
      "2" = 204
      "3" = 304
  }
返回二维数组 
 "配置的所有先序数据allConfigData == " = {
     1 = {
         1 = {
             "key"    = 11
             "mode"   = 2
             "target" = 3
             "value"  = 100
         }
     }
 }]]
function FuncGuild.getAllPropertyDataByType(guildSkillsData,effectZoneType)
	local allConfigData = {}
	if guildSkillsData and table.length(guildSkillsData)>0 then
		if FuncGuild.isDebug then
			echo("______effectZoneType ___________",effectZoneType)
			dump(guildSkillsData, "usermodel中的仙盟技能数组")
		end
		for themeId,curSkillId in pairs(guildSkillsData) do
			local skillData = FuncGuild.getSkillDataBySkillId( curSkillId )
			while skillData do
				effectId = skillData.effect1
				if effectId then
					local effectData = FuncGuild.getSkillEffectDataById(effectId)
					if not effectData.type and effectZoneType == FuncGuild.effectZoneType.GLOBAL then
						table.insert(allConfigData,table.deepCopy(effectData.effect))
					elseif effectData.type then
						for k,systemId in pairs(effectData.type) do
							if tostring(systemId) == tostring(effectZoneType) then
								table.insert(allConfigData,table.deepCopy(effectData.effect))
							end	
						end
					end
				end
				local lastSkillId = skillData.condition
				skillData = FuncGuild.getSkillDataBySkillId( lastSkillId ) 
			end
		end
	end
    if FuncGuild.isDebug then
        dump(allConfigData, "配置的所有先序数据allConfigData == ")
    end
    return allConfigData
end

-- 将属性数据格式化 显示
function FuncGuild.countFinalAttrForShow( _type,dataArr )
    local showDataArr = {}
    showDataArr.type = _type
    showDataArr.value = {}
    if dataArr and table.length(dataArr) > 0 then
        for k,v in pairs(dataArr) do
            if not showDataArr.value[v.key] then
                showDataArr.value[v.key] = {}
            end
            if not showDataArr.value[v.key][v.mode] then
                showDataArr.value[v.key][v.mode] = 0
            end
            showDataArr.value[v.key][v.mode] = showDataArr.value[v.key][v.mode] + v.value
        end
    end
    dump(showDataArr, "=== 属性展示数据 === showDataArr")
    return showDataArr
end

function FuncGuild:getguildGloryData()
	local newData = {}
	for k,v in pairs(guildGlory) do
		v.id = k
		table.insert(newData,v)
	end
	local function sortFunc(a, b)
		if a.id < b.id then
			return true
		else
			return false
		end
	end
	table.sort(newData, sortFunc)

	return newData
end

--根据类型获取数据
function FuncGuild.getDataByType(_type)
	local data = FuncGuild.ClassguildTask()
	local newdata = {}
	if _type == FuncGuild.guildTask_type.RAINK then
		newdata = FuncGuild:getguildGloryData()
	else
		newdata = data[tonumber(_type)]
	end
	return newdata[1]
end

-- ===========================================================================================
-- 获取计算用的 资源加成或者耗费减少数据
-- usermodel中的仙盟技能数组
 -- "guildSkills" = {
 --     "1" = 104
 --     "2" = 204
 --     "3" = 304
 -- }
function FuncGuild.getCalculateResourceData(guildSkillsData)
	local allConfigData = {}
	if guildSkillsData and table.length(guildSkillsData)>0 then
		if FuncGuild.isDebug then
			dump(guildSkillsData, "usermodel中的仙盟技能数组")
		end
		for themeId,curSkillId in pairs(guildSkillsData) do
			local skillData = FuncGuild.getSkillDataBySkillId( curSkillId )
			while skillData do
				local additionIdArr = skillData.effect2
				if additionIdArr then
					for k,additionId in pairs(additionIdArr) do
						local additionData = FuncCommon.getAdditionDataByAdditionId( additionId )
						if tonumber(additionData.from) == 2 then
							allConfigData[#allConfigData+1] = {
								key = tonumber(additionData.type),
								value = additionData.subNumber,
								valueMode = additionData.subType,
								valueChangeMode = additionData.subMode,
								desc = additionData.titleTid ,
							}
						end	
					end
				end
				local lastSkillId = skillData.condition
				skillData = FuncGuild.getSkillDataBySkillId( lastSkillId ) 
			end
		end
	end
    if FuncGuild.isDebug then
        dump(allConfigData, "配置的所有先序数据allConfigData == ")
    end
    -- 读取已经获得的技能点的配置数据
    -- 分类统计
    local calculateData = {
        amount_produce_increase = {},
        amount_cost_reduce = {}
    }
    for k,v in pairs(allConfigData) do
        if v and table.length(v) > 0 then
            local proTemp = v 
            if proTemp.valueChangeMode == FuncGuild.affectTarget.Addition then 
                calculateData.amount_produce_increase[#calculateData.amount_produce_increase + 1] = proTemp
            elseif proTemp.valueChangeMode == FuncGuild.affectTarget.Reduction then   
                calculateData.amount_cost_reduce[#calculateData.amount_cost_reduce + 1] = proTemp
            end  
        end
    end
    if FuncGuild.isDebug then
        dump(calculateData.amount_produce_increase, "calculateData.amount_produce_increase")    
        dump(calculateData.amount_cost_reduce, "calculateData.amount_cost_reduce")    
    end
    return calculateData
end

function FuncGuild.countFinalResourceAttrForShow( _typeName,dataArr )
    local showDataArr = {}
    showDataArr.typeName = _typeName
    showDataArr.value = {}
    if dataArr and table.length(dataArr) > 0 then
        for k,v in pairs(dataArr) do
        	-- dump(v, "desciption==============")
            if not showDataArr.value[v.key] then
                showDataArr.value[v.key] = {
	                desc = v.desc,
	                value = 0,
	                key = v.key,
					valueMode = v.valueMode,
					valueChangeMode = v.valueChangeMode,
            	}
            end
            showDataArr.value[v.key].value = showDataArr.value[v.key].value + v.value
        end
    end
    -- dump(showDataArr, "=== 属性展示数据 === showDataArr")
    return showDataArr
end

function FuncGuild.getGuildTaskDataById(id)
	local data = guildTask[tostring(id)]
	if data  == nil then
		data = guildGlory[tostring(id)]
	end
	return  data or guildTask["1001"]
end

function FuncGuild.getpopularityRankId( rank )
	for k,v in pairs(popularityRank) do
		local endnum = v["end"]
		if endnum == nil then
			endnum = 10000000
		end
		if rank >= v.start and rank < endnum then
			return id
		end
	end
end
function FuncGuild.getOutDDHHSSTime(_time)
    local str = ""
    -- if _time == 0 then
    --     str = "在线"
    --     return str
    -- else
        local serveTime = TimeControler:getServerTime()
        local remainTime  = serveTime -_time
        echo("======remainTime=========",remainTime,_time)
        local day =  math.floor(remainTime/(3600*24))
        if day ~= 0 then
            str = day.."天"
        else
            local hours = math.floor(remainTime/3600)
            if hours ~= 0 then
                str = hours.."小时"
            else
                local minutes =  math.floor(remainTime/60)
                if minutes ~= 0 then
                   str = minutes.."分钟" 
               	else
               		local sce = math.fmod(remainTime, 60)
               		str = sce.."秒" 
                end
            end
        end
    -- end
    if str == "" then
        str = "1分钟"
    end
    return str
end

function FuncGuild.setOpenTimeText()
	local openTime  = FuncGuildBoss.getGuildBossOpenTime()
	-- dump(openTime,"11111111111111")
	local textArr = {}
	for i=1,#openTime do
		textArr[i] = {}
		for _x=1,2 do
			local text = ""
			local _h = math.floor(openTime[i][_x]/3600)
			local _m = math.floor((openTime[i][_x] - _h * 3600)/60)
			if _m >= 10 then
				text = _h..":".._m
			else
				text = _h..":0".._m
			end
			textArr[i][_x] = text
		end
	end
	return textArr

end

-- 表的长度
function FuncGuild.getDigRewardLength()
	return table.length(guildDigReward)
end

-- 随机挖宝地图位置点
function FuncGuild.getDigMapPosition( id )
	local data = guildDigReward[tostring(id)].position1
	-- local positionArr = string.split(data,",")
	return data
end

-- 获取表中最好的奖励
function FuncGuild.getBestGoodsFromConfigs( id )
	local data = guildDigReward[tostring(id)].show
	return data
end


---获取仙盟活动表数据
function FuncGuild.getGuildActive(id)
	local data = guildActive[tostring(id)]
	return data
end


