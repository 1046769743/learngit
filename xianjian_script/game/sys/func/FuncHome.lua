--[[
	guan
]]

FuncHome = FuncHome or {}

local homeBtn = nil
local homeBubble = nil
local enemyInfo = nil
FuncHome.systemname = {
	welfare = 1,
	firstCharge = 2,
	carnival = 3,
	happySign = 4,
	 -- = 5,
}
FuncHome.active_systemname = {
	[1] = "welfare",   ---福利
	[2] = "firstCharge",   --首冲
	[3] = "carnival",   ---嘉年华
	[4] = "happySign",  --七天登录
	-- 5 = , -- = 5,
}
FuncHome.SYSTEM_NAME = {
        TREASURE = "treasure", --法宝
        CHAR = "char",        --主角
        GOD = "god",           --神明
        PARTNER = "partner",     --伙伴
        BAG = "bag",           --包裹
        ROMANCE = "romance",   --奇缘
        CHALLENGE = "pvp",           --挑战
        GUILD = "guild",       --公会
        WORLD = "world",       --寻仙
        EQUIPMENT = "partnerEquipment",       --装备
        PRACTICE = "practice", --修炼仙术
        LOVE = "love",    --情缘
        CIMELIA = "cimelia", --神器
        ARRAY = "array", --布阵
    }

FuncHome.RIGHTBUTTON_NAME = {
	[1] = "welfare",
	[2] = "carnival",
	[3] = "happySign",
	[4] = "firstCharge",
	[5] = "showLevelReward",
	[6] = "everydayTarget",
	[7] = "monthCard",
	[8] = "mall",
	[9] = "traveler",  --六界游商
	[10] = "activityEntrance",  -- 新活动入口
	[11] = "roulette", --幸运转盘
}


---主界面得上的按钮系统名称
FuncHome.homemButtonArr = {
	[1] = "mainlineQuest",
	[2] = "mail",
	[3] = "friend",
	[4] = "feedback",
	[5] = "chat"
}

FuncHome.homemLeftButtonArr = {
	[1] = "mainlineQuest2",
	[2] = "chat",
}



---更多按钮的系统 ，以后往这里加
FuncHome.RIGHTBUTTON_MORE = {
	FuncCommon.SYSTEM_NAME.ARRAY,
	FuncCommon.SYSTEM_NAME.MEMORYCARD,
	FuncCommon.SYSTEM_NAME.TREASURE_NEW,
	FuncCommon.SYSTEM_NAME.FIVESOUL,
}




FuncHome.RIGHTBUTTON_INDEX = {
	-- lottery = 1,
	-- shop1 = 2,
	welfare = 1,
	carnival = 2,
	happySign = 3,
	firstCharge = 4,
	everydayTarget = 6,
	mall = 8,
	monthCard = 7,
	traveler = 9,
	activityEntrance = 10,
	roulette = 11,
}

--开启历练中仙妖劫的动画
FuncHome.OPEN_PVP_ACTION_FILE  = {
	[1] = {[1] = 10206,[2] = 20103},
	[2] = {[1] = 10306,[2] = 20301},
	[3] = {[1] = 10406,[2] = 20401},
	[4] = {[1] = 10506,[2] = 20501},
	[5] = {[1] = 10606,[2] = 20601},
	[6] = {[1] = 10706,[2] = 20701},
	-- [7] = {[1] = 10806,[2] = 20801},
	-- [8] = {[1] = 10906,[2] = 20901},
}


--限时活动入口
FuncHome.Timelimit_activity = {
	crossPeak = {funName = function (questId)
		WindowControler:showWindow("CrosspeakNewMainView")
	end},
	guildactivity = {funName = function ()
		-- local function callBack()
		-- 	WindowControler:showWindow("GuildActivityMainView")
		-- end
		-- GuildActMainModel:requestGVEData(callBack)
		GuildActMainModel:enterGuildActMainView()
	end},
	shareBoss = {funName = function ()
		ShareBossControler:enterShareBossMainView()
	end},
}



--仙盟主城玩家的大小    
FuncHome.OtherScal = 0.85
FuncHome.MinScal = 0.85
FuncHome.HomeOtherPlayerNum = 15   --主城的其他玩家数量

function FuncHome.init()
	homeBtn = Tool:configRequire("home.HomeUpBtns");
	homeBubble = Tool:configRequire("home.Bubble")
	enemyInfo = Tool:configRequire("level.EnemyInfo")
end

function FuncHome.getValue(id, key)
	local valueRow = homeBtn[tostring(id)];
	if valueRow == nil then 
		echo("error: FuncHome.getValue id " .. 
			tostring(id) .. " is nil;");
		return nil;
	end 

	local value = valueRow[tostring(key)];
	if value == nil then 
		echo("error: FuncHome.getValue key " .. 
			tostring(key) .. " is nil");
	end 
    return value;
end

function FuncHome.getFuncId(id)
	return FuncHome.getValue(id, "funcId");
end

function FuncHome.getIconSp(id)
	local iconName = FuncHome.getValue(id, "icon");
    local iconPath = FuncRes.iconIconHome(iconName);
    local iconSp = display.newSprite(iconPath);
    return iconSp;
end

function FuncHome.getDes(id)
	local tid = FuncHome.getValue(id, "des");
	return GameConfig.getLanguage(tid);
end
--获取气泡显示数据
function FuncHome.getBubbleData()
	return homeBubble or {}
end



function FuncHome.getBossInfo(bossID)
    local data = enemyInfo[tostring(bossID)]
    return data
end



function FuncHome.getBubbleListData()
	local homeBubbles = table.copy(homeBubble) 
	local newarr = {}
	for k,v in pairs(homeBubbles) do
		local valuer = table.copy(v)
		local pro = valuer["1"].priorSystem
		if pro ~= nil then
			if valuer["1"] ~= nil then
				newarr[pro] = valuer["1"] 
			end
		end
	end

	-- dump(newarr,"气泡的数据结构")
	return newarr
	
end







