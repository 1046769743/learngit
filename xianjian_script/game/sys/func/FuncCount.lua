FuncCount = FuncCount or {}

local data = nil;

-- 计数类型
FuncCount.COUNT_TYPE = {
	COUNT_TYPE_BUY_SP = "1",                  -- 购买体力
	COUNT_TYPE_GET_RENOWM_TIMES = "2",                  --  每周领取声望奖励次数  --- 已废弃 购买法力
	COUNT_TYPE_BUY_PVP = "3",                 -- 购买PVP
	COUNT_TYPE_PVPCHALLENGE = "4",            -- PVP挑战次数
	COUNT_TYPE_LEADER_KICK = "5" ,            -- 会长踢人次数
	COUNT_TYPE_JUNIOR_SHOP_FLUSH_TIMES = "6", -- 最低档商店刷新刷次
	-- COUNT_TYPE_MEDIUM_SHOP_FLUSH_TIMES = "7", -- 中档档商店刷新刷次
    COUNT_TYPE_GUILD_WISH_TIMES = "7",        -- 仙盟心愿次数
	-- COUNT_TYPE_SENIOR_SHOP_FLUSH_TIMES = "8", -- 高档档商店刷新刷次
	COUNT_TYPE_SIGN_RECEIVE_RETIO = "9",      -- 今日签到次数
	COUNT_TYPE_GET_TILI = "10",              -- 体力领取
	COUNT_TYPE_TRIAL_TYPE_TIMES_1 = "11",     -- 试炼类型1进入次数
	COUNT_TYPE_TRIAL_TYPE_TIMES_2 = "12",     -- 试炼类型2进入次数
	COUNT_TYPE_TRIAL_TYPE_TIMES_3 = "13",     -- 试炼类型3进入次数
    COUNT_TYPE_LUCKYGUY_FREETIMES = "14",     -- 幸运转盘免费次数

    COUNT_TYPE_FINISH_GUILD_TIMES = "15",        --每日完成仙盟任务次数 

	COUNT_TYPE_TOWER_RESET = "17",
	COUNT_TYPE_PVP_SHOP_REFRESH_TIMES = "18", -- 竞技场商店刷新次数
    COUNT_TYPE_ACHIEVE_SP_COUNT="19",--玩家领取的好友赠送的体力的数目
    COUNT_TYPE_BUY_ENDLESS = "20" ,      --购买无底深渊挑战和扫荡次数
    COUNT_TYPE_USER_BUY_COIN_TIMES="21",--//玩家购买铜钱的次数
    COUNT_TYPE_GAMBLE_COUNT = "22",		--须臾仙境的第8种 
    COUNT_TYPE_GAMBLE_CHANGE_FATE_COUNT = "23", --须臾仙境的第9种 
    COUNT_TYPE_HONOR_COUNT = "24", --膜拜次数
    COUNT_TYPE_WORLD_CHAT_COUNT="25",--每日世界聊天最大免费次数
    COUNT_TYPE_CHAR_SHOP_REFRESH_TIMES = "26", --侠义值商店刷新次数
    COUNT_TYPE_FREE_RECHARGE_TIMES = "27", --每日领取仙玉次数数
    COUNT_TYPE_RECHARGE_GOLD_NUMS = "28",  --每日充值数目
    -- COUNT_TYPE_GODUPGRADE_COIN_TIMES = "28", --神明铜钱强化次数
    COUNT_TYPE_RED_PACKET_TIMES = "29", --抢红包次数
    COUNT_TYPE_COST_TILI_TIMES = "30", --每日花费体力计数，会重置
    -- COUNT_TYPE_DEFENDER_COUNT = "100",  		 --守护紫萱的挑战次数

    COUNT_TYPE_EVERYDAY_SPEND_SP_TIMSE = "30",  --每日花费体力计数
    COUNT_TYPE_GUILD_TEAM_TIMSE = "31",  --仙盟组队次数


    COUNT_TYPE_PARTNER_SKILL_POINT_TIMES = "32",--伙伴技能点购买次数
    COUNT_TYPE_NEWLOTTERY_FREE_TIMES = "33",    ---免费抽卡次数
    COUNT_TYPE_NEWLOTTERY_GOLD_FREE_TIMES = "34",    ---元宝免费抽卡次数
    COUNT_TYPE_NEWLOTTERY_GOLD_FAY_TIMES = "35",    ---元宝付费抽卡次数
    COUNT_TYPE_NEWLOTTERY_MANY_REFRESH_TIMES = "36",    ---铜钱刷新次数 --toDo
    -- COUNT_TYPE_NEWLOTTERY_EVERYONEDAYITEMS  = "37",      ---元宝一次
    -- COUNT_TYPE_NEWLOTTERY_EVERYTNEDAYITEMS  = "38",      --元宝十次
    COUNT_TYPE_TRAVEL_SHOP_TIMES = "37",             --- 六界游商抽折扣次数
    
    COUNT_TYPE_ARTIFACT_QUICK_TIMES = "38", --神器快捷购买次数
    COUNT_TYPE_CHAT_BUY_ITEMS = "40",   ---聊天的购买次数

    COUNT_TYPE_DELEGATE_TASK_REFRESH_TIMES = "41",     -- 每日伙伴任务刷新次数（挂机系统）
    COUNT_TYPE_DELEGATE_TASK_VIP_SPEEDUP_TIMES = "42",     -- 每日伙伴VIP免费加速次数（挂机系统）
    COUNT_TYPE_DELEGATE_TASK_SPEEDUP_TIMES = "43",     -- 每日伙伴任务加速次数（挂机系统）
    
    COUNT_TYPE_ARTIFACt_TIMES = "44",   ---神器免费的次数
    COUNT_TYPE_ARTIFACt_SHOP_TIMES = "45",    --神器商店刷新次数
    COUNT_TYPE_ENDLESS_TIMES = "46",        --无底深渊挑战次数
    COUNT_TYPE_ARTIFACt_DAY_TIMES  = "47",   --器当天的次数


    COUNT_TYPE_TOWERSHOP_DAY_TIMES = "48",    --每日锁妖塔商店刷新次数
    COUNT_GUILD_EVERYDAY_REWARD_ONE = "49",     --每日公会红利1
    -- COUNT_GUILD_EVERYDAY_REWARD_TWO = "50",     --每日公会红利2
    -- COUNT_GUILD_EVERYDAY_REWARD_THREE = "51",   --每日公会红利3
    COUNT_GUILD_PRAY_REWARD_ONE = "52",         --每日公会祈福宝箱1
    -- COUNT_GUILD_PRAY_REWARD_TWO = "53",         --每日公会祈福宝箱2
    -- COUNT_GUILD_PRAY_REWARD_THREE = "54",       --每日公会祈福宝箱3
    COUNT_GUILD_PRAY_REWARD = "55",             --每日公会祈福次数
    COUNT_GUILD_SIGN = "56",                    ---每日签到
    COUNT_DONATION_COUNT = "57",               -- 每日公会捐献次数
    COUNT_TYPE_SHAREBOSS_CHALLENGE = "58",    --共享副本挑战次数
    COUNT_TYPE_SHAREBOSS_TRIGGER = "59",      --共享副本触发次数
    -- COUNT_TYPE_TRIAL_LIMIT_NUM = "60",        --试炼助战侠义值次数
    COUNT_TYPE_CROSS_BUY_NUM = "61",          --每日巅峰竞技场购买次数 
    COUNT_TYPE_CROSS_ZHAN_NUM = "62",          --每日巅峰竞技场挑战次数
    COUNT_TYPE_CROSS_WIN_NUM = "63",          --每日巅峰竞技场胜利次数
    COUNT_TYPE_CROSS_KILLPARTNER_NUM = "70",          --当日击杀奇侠数量  
    COUNT_TYPE_CROSS_GETBOX_NUM = "71",          --当日巅峰竞技场主界面宝箱领取数量  
    COUNT_TYPE_CROSS_TASKREFRESH_NUM = "72",          --当日巅峰竞技场小任务刷新次数


    COUNT_TYPE_WONDERLAND_FIRE_NUM = "64",        --须臾仙境火魔兽次数
    COUNT_TYPE_WONDERLAND_WRTER_NUM = "65",       --须臾仙境水魔兽次数
    COUNT_TYPE_WONDERLAND_WIND_NUM = "66",       --须臾仙境风魔兽次数
    COUNT_TYPE_WONDERLAND_RAY_NUM = "78",        --须臾仙境火魔兽次数
    COUNT_TYPE_WONDERLAND_WRTER_A_NUM = "79",       --须臾仙境水魔兽次数
    COUNT_TYPE_WONDERLAND_LIVE_NUM = "80",       --须臾仙境风魔兽次数
    COUNT_TYPE_WONDERLAND_SOIL_NUM = "81",        --须臾仙境火魔兽次数


    -- COUNT_TYPE_DELEGATE_NUM = "68",             --仙境挂机
    COUNT_TYPE_DELEGATE_SPECIAL_TASK_REFRESH_TIMES = "68",     --特殊委托免费刷新次数

    COUNT_TYPE_GVE_CHALLENGE_TIMES = "67",       --gve挑战次数

    COUNT_TYPE_WONDERSHOP_DAY_TIMES = "69",      --须臾商店

    COUNT_TYPE_GET_MONTHCARD_74_TIMES = "74",    --月卡:夕瑶送灯(周卡)刷新每日赠送
    COUNT_TYPE_GET_MONTHCARD_75_TIMES = "75",    --月卡:财神赐宝刷新每日赠送
    COUNT_TYPE_GET_MONTHCARD_76_TIMES = "76",    --月卡:三皇赠礼刷新每日赠送

    COUNT_TYPE_MALL_XINANDANG_77_TIMES = "77",   --商城 新安当刷新次数

    COUNT_TYPE_RECHARGE_PURCHASE_1001_TIMES = "1001",   --id为package_101 直购礼包购买次数
    COUNT_TYPE_RECHARGE_PURCHASE_1003_TIMES = "1003",   --id为package_102 直购礼包购买次数
    -- COUNT_TYPE_TRAVELSHOP_EVERYDAY_TIME = tostring(FuncTravelShop.getRechargeForCountId()),  -- 六界游商每日购买礼包次数
    COUNT_TYPE_TRAVELSHOP_EVERYDAY_TIME = "1002",

}


local quickBuyCountCost
local quickBuyMapCount


function FuncCount.init()
    data = Tool:configRequire("common/Count");
    quickBuyCountCost = Tool:configRequire("common/QuickBuyCountCost");
    quickBuyMapCount = Tool:configRequire("common/QuickBuyMapCount");
end

function FuncCount.getHour(id)
    local t = data[tostring(id)];
    if t == nil then 
        echo("FuncCount.getHour id nil " .. tostring(id));
    else 
        local value = t["h"];
        if value == nil then 
            echo("FuncCount.getHour id h is nil " .. tostring(id));
        else 
            return value;
        end 
    end 
end

function FuncCount.getMinute(id)
	local default = 0
	local t = data[tostring(id)]
	if not t then
		return default
	else
		local value = t['m']
		return tonumber(value) or 0
	end
end


--获取
function FuncCount.getBuyCountCostData(countId  )
    local data = quickBuyCountCost[countId]
    if not data then
        echoError("没有countId:",countId,"对应的quickBuyCountCost数据")
    end
    return data
end


function FuncCount.getCountCostMapData( countId )
    local data =  quickBuyMapCount[countId]
    if not data then
        echoError("没有countId:",countId,"对应的quickBuyMapCount数据")
    end
    return data
end

--根据购买次数 获取 对应的coujntId 资源奖励
function FuncCount.getBuyCountMapResInfo( countId,buyCount,index )
    index = index or 1
    local data = FuncCount.getCountCostMapData( countId )
    local resStr = data.resId[1]
    return resStr..","..buyCount
end

