-- --
--Author:      zhuguangyuan
--DateTime:    2017-10-21 15:21:57
--Description: 仙盟GVE活动动态数据处理类
--

local GuildActMainModel = class("GuildActMainModel", BaseModel)

-- 怪的状态
GuildActMainModel.monsterStatus = {
	NOT_MARKED = 0,
	MARKED = 1,
	IN_BATTLE = 2,
	BATTLE_WIN = 3,
	BATTLE_LOSE = 4
}

-- 当前开启的活动
GuildActMainModel.curGuildActivityId = "1"

-- 杀进程后怪标记数组将不复存在 
-- 断线重连中处理
GuildActMainModel.markArr = {}

-- 记录本轮是否已经combo

-- 战后恢复怪 如果是本轮 则直接恢复怪后进入本轮倒计时
-- 	如果是新一轮 
-- 方案1:则不演示碰撞 直接出新一轮的怪
-- 方案2:保存前一轮的怪数据 演示碰撞 再显示新一轮的怪被标记情况
-- 采用方案1 -- 暂时不用此标记
GuildActMainModel.hasNotCombo = {} 

-- 记录最近的煮菜情况 重登后展示
GuildActMainModel.messageName = "user_gveActivity_input_ingredients_messages"
GuildActMainModel.hitEndTime = "user_gveActivity_hitEndTime"

-- 战斗重连过程中 如果接受到新一轮结算
-- 则先恢复断线前的数据,再进行结算的逻辑
GuildActMainModel.isInReconnection = false
GuildActMainModel.isInBattleResume = false

-- 日活动及周活动结算倒计时
GuildActMainModel.eventName_activityEnd = "__GVE_One_Day_Account__Time___"
GuildActMainModel.eventName_weekScoreClear = "__GVE__Account__Time___"
-- 挑战中每轮倒计时
GuildActMainModel.eventName_oneRoundTimer = "__GVE_One_Round__Time___"
-- 底层计时器 用于通知战斗新一轮挑战开始 客户端战斗快速出结果
GuildActMainModel.eventName_notifyBattleInvalidTimer = "eventName_notifyBattleInvalidTimer"

-- GuildActMainModel.isNotFirstComeOutMonster = true

-- 玩家登陆时 启动到活动开启的倒计时 到点发消息
GuildActMainModel.eventName_notifyActValidTimer = "eventName_notifyActValidTimer"


-- 断线重连需要重新处理的消息及对应函数名
GuildActMainModel.funcKeyMap = {
	-- 某个成员退出挑战
 	["notify_guild_activity_quit_challenge_5628"] 	= "onTeamSomeQuitChallenge" ,
 	-- 标记怪物 取消标记
 	["notify_guild_activity_mark_monster_5632"] 	= "onSomeoneMarkOneMaster" ,
 	["notify_guild_activity_unmark_monster_5636"] 	= "onSomeoneUnMarkOneMaster" ,
 	-- 打败怪物
 	["notify_guild_activity_defeat_monster_5640"] 	= "onSomeoneDefeatOneMaster" ,
 	-- 前四轮战斗结算 最后的战斗结算
 	["notify_guild_activity_round_account_5644"] 	= "onOneRoundAccount",
    ["notify_guild_activity_last_round_account_5646"] 		= "onLastRoundAccount" ,

    -- 被踢
 	["notify_guild_remove_player_1356"] 			= "beKickOutByGuildLeader",
 	["notify_guild_activity_start_count_down_5670"] = "syncRoundTime",
}	

--------------------------------------------------------------------------
---------------------- 初始化数据            ------------------------------
--------------------------------------------------------------------------
function GuildActMainModel:init( _data )
	GuildActMainModel.super.init(self,_data)
	self.funcMap = {

	}

	self._guildId = UserModel:guildId()
	self.configRewardData = FuncGuildActivity.getAccumulateReward()
	self:registerEvent()
	local function callBack()
		if self._isClickByGuildChairman == true then
			self._isClickByGuildChairman = false
		end
		echo("-- 初始化奖励信息和红点")
		-- self:initRewardData()
		-- self:checkReconnection()
	end

	-- 仙盟酒家系统未开启时不访问协议
	local sysName = FuncCommon.SYSTEM_NAME.GUILDACTIVITY
	local open = FuncCommon.isSystemOpen(sysName)
	if open then
		self:requestGVEData(callBack)
	end

	-- self._myTeamMonsters = {
 -- 	      ["1"]= {
 -- 	          ["id"]     = "10087",
 -- 	          ["index"]  = 1,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["10"] = {
 -- 	          ["id"]     = "10086",
 -- 	          ["index"]  = 10,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["11"] = {
 -- 	          ["id"]     = "10083",
 -- 	          ["index"]  = 11,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["12"] = {
 -- 	          ["id"]     = "10086",
 -- 	          ["index"]  = 12,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["13"] = {
 -- 	          ["id"]     = "10086",
 -- 	          ["index"]  = 13,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["14"] = {
 -- 	          ["id"]     = "10083",
 -- 	          ["index"]  = 14,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["15"] = {
 -- 	          ["id"]     = "10083",
 -- 	          ["index"]  = 15,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["16"] = {
 -- 	          ["id"]     = "10080",
 -- 	          ["index"]  = 16,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["17"] = {
 -- 	          ["id"]     = "10086",
 -- 	          ["index"]  = 17,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["18"] = {
 -- 	          ["id"]     = "10087",
 -- 	          ["index"]  = 18,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["19"] = {
 -- 	          ["id"]     = "100391",
 -- 	          ["index"]  = 19,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["2"]= {
 -- 	          ["id"]     = "10056",
 -- 	          ["index"]  = 2,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["20"] = {
 -- 	          ["id"]     = "10086",
 -- 	          ["index"]  = 20,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["3"]= {
 -- 	          ["id"]     = "100391",
 -- 	          ["index"]  = 3,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["4"]= {
 -- 	          ["id"]     = "10083",
 -- 	          ["index"]  = 4,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["5"]= {
 -- 	          ["id"]     = "10080",
 -- 	          ["index"]  = 5,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["6"]= {
 -- 	          ["id"]     = "100391",
 -- 	          ["index"]  = 6,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["7"]= {
 -- 	          ["id"]     = "100391",
 -- 	          ["index"]  = 7,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["8"]= {
 -- 	          ["id"]     = "10059",
 -- 	          ["index"]  = 8,
 -- 	          ["status"] = 0,
 -- 	      },
 -- 	      ["9"]= {
 -- 	          ["id"]     = "10080",
 -- 	          ["index"]  = 9,
 -- 	          ["status"] = 0,
 -- 	      },	
	-- }
end

function GuildActMainModel:requestGVEData(_callback)
	echo("===========UserModel:guildId()====111111111111==",UserModel:guildId())
	if UserModel:guildId() ~= "" then
		local function callBack( _data )
			self:initBaseData(_data,_callback)
		end
		self._guildId = UserModel:guildId()
		GuildActivityServer:getGVEData(self._guildId,callBack)

	end
end
function GuildActMainModel:initBaseData(_data,_callback)
	if FuncGuildActivity.isDebug then
		dump(_data, "\n\nGuildActMainModel ______获取gve信息 initData")
	end
	if _data.error then
		return
	end
	-- 初始化gve基本信息
	if not self._gveChallengeTimes then
		self._gveChallengeTimes = 0
	end
	if not self._gveScoreTotal then
		self._gveScoreTotal = 0 --周积分
	end
	if not self._havedBeenGotRewards then
		self._havedBeenGotRewards = {} --已领取奖励数组
	end
	
	if _data.result.data then
		local serverData = _data.result.data
		--==============================
		-- 活动开启相关
		if serverData.lastGveTime then	
			self._lastGveTime = serverData.lastGveTime
		end
		if self:isActivityCanOpen() then
			self:registerActivityTimeOutEvent()
		end
		--==============================
		-- 仙盟gve总体数据相关
		if serverData.food then	
			local leftTime = self:getLeftTime()
			if serverData.food.foodId and (leftTime > 0) then
				-- 注意这里可能记录的是历史开启信息
				-- 开启活动的推送信息中返回的id才是本期活动的食物id
				self._guildFoodId = serverData.food.foodId 
			else 
				self._guildFoodId = self:getToOpenFoodId() -- 没有开启活动的时候却要显示活动相关的东西 只能默认1了
				self.forceRefresh = true
			end
			local function callBack( event )
				-- dump(serverData,"serverData---------------")
				-- dump(self._guildTotalHaveIngredients,"self._guildTotalHaveIngredients---")
				if serverData.food.ingredients then
					for k,v in pairs(serverData.food.ingredients) do
						if not self._guildTotalHaveIngredients[k] then
							if self:isActivityCanOpen() then
								echoError("食材掉落错误!当前开启的活动配表中不存在该食材 ____",self._guildFoodId,k)
							end
						else
			 				self._guildTotalHaveIngredients[k].curNum = v
			 			end
			 		end
				end
			end
			self:initIngredients(callBack)
		end
		--==============================
		-- 玩家个人gve信息相关
		if serverData.gveMember then	
			-- 挑战次数
			if serverData.gveMember.gveTimes then
				self._gveChallengeTimes = serverData.gveMember.gveTimes
			end
			-- 累积积分
			if serverData.gveMember.gveScoreTotal then
				self._gveScoreTotal = serverData.gveMember.gveScoreTotal
			end

			local gveScoreExpireTime = serverData.gveMember.gveScoreExpireTime
			-- 本活动中玩家获得的食材
			if serverData.gveMember.ingredients then
				-- and gveScoreExpireTime and gveScoreExpireTime < TimeControler:getTime() then
				for k,v in pairs(serverData.gveMember.ingredients) do
					if not self._personlHaveIngredients[k] then
						if self:isActivityCanOpen() then
							if gveScoreExpireTime and gveScoreExpireTime < TimeControler:getTime() then
								echoWarn("食材掉落警告，过期食材")
							else
								echoError("食材掉落错误!当前开启的活动配表中不存在该食材 ____",self._guildFoodId,k)
							end
						end
					else
			 			self._personlHaveIngredients[k].curNum = v
			 		end
				end									
			end
			-- 本活动中玩家已经投入的食材
			if serverData.gveMember.todayAddIngredients then
				for k,v in pairs(serverData.gveMember.todayAddIngredients) do
					if not self._personlHavePutIngredients[k] then
						if self:isActivityCanOpen() then
							echoError("食材掉落错误!当前开启的活动配表中不存在该食材 ____",self._guildFoodId,k)
						end
					else
			 			self._personlHavePutIngredients[k].curNum = v
			 		end
				end									
			end

			-- 今日是否已经煮菜
			if serverData.gveMember.flagMakeFood then
				self._havedBeenCooking = serverData.gveMember.flagMakeFood
			end
			-- 已经领取的积分奖励
			if serverData.gveMember.scoreRewards then
				self._havedBeenGotRewards = serverData.gveMember.scoreRewards
			end	
			-- 累计积分过期时间（积分奖励领取列表过期时间）
			-- 注意过期后服务器数据并不清除 所以要做判断
			if serverData.gveMember.gveScoreExpireTime then
				self._gveScoreExpireTime = serverData.gveMember.gveScoreExpireTime
				if self._gveScoreExpireTime <= TimeControler:getTime() then
					echo("\n\n ___________ 积分奖励已过期 _________")
					if self._gveChallengeTimes then
						self._gveChallengeTimes = 0 
					end
					if self._gveScoreTotal then
						self._gveScoreTotal = 0
					end
					if self._personlHaveIngredients then
						for k,v in pairs(self._personlHaveIngredients) do
							v.curNum = 0
						end	
					end
					if self._personlHavePutIngredients then
						for k,v in pairs(self._personlHavePutIngredients) do
							v.curNum = 0
						end	
					end
					if self._havedBeenCooking then
						self._havedBeenCooking = nil
					end
					if self._havedBeenGotRewards then
						self._havedBeenGotRewards = {}
					end
				elseif self:isActivityCanOpen() then
					self:registerRewardExpireEvent() -- 注册奖励到时事件
				end
			end				
		end

		if _callback then
			_callback()
		end
	end
end

function GuildActMainModel:initIngredients(_callBack)
	if not self._personlHaveIngredients or table.isEmpty(self._personlHaveIngredients) or self.forceRefresh then
		-- self._myTeamIngredients = false
		local configIngredients = FuncGuildActivity.getFoodMaterial(self._guildFoodId)
		echo("\n\n_______self._guildFoodId___________",self._guildFoodId)
		self._personlHavePutIngredients = {}
		self._personlHaveIngredients = {}
		self._guildTotalHaveIngredients = {}
		for k,v in ipairs(configIngredients) do
			local name = FuncGuildActivity.getMaterialName(v.id)
			name = GameConfig.getLanguage(name)

			local item = {}
			item.id = v.id
			item.maxNum = v.num
			item.curNum = 0
			item.name = name

			local item2 = table.deepCopy(item)
			local item3 = table.deepCopy(item)
			self._personlHavePutIngredients[v.id] = item
			self._personlHaveIngredients[v.id] = item2
			self._guildTotalHaveIngredients[v.id] = item3
		end
		-- 设置玩家获得食材的最大基数 用于显示进度
		-- 选用1星的邀请数量
		if self._guildFoodId then
			local starLevel = 1
			local perdsonalMaterialsLimit = FuncGuildActivity.getXXFoodMaterialDemand( self._guildFoodId,starLevel ) 
			echo("_______self._guildFoodId___________",self._guildFoodId)
			-- dump(perdsonalMaterialsLimit, "个人能获得的食材数量限制")
			-- dump(self._personlHaveIngredients, "个人获得食材数组")
			-- dump(self._guildTotalHaveIngredients, "仙盟获得食材数组")

			for k,v in pairs(perdsonalMaterialsLimit) do
				self._personlHaveIngredients[v.id].maxNum = v.num
			end
		end
		for k,v in pairs(self._personlHavePutIngredients) do
			v.maxNum = FuncGuildActivity.getMaterialCanPutInMaxNum(v.id)
		end
		-- dump(self._personlHavePutIngredients, "个人投入食材数组")
		-- dump(self._personlHaveIngredients, "个人获得食材数组")
		-- dump(self._guildTotalHaveIngredients, "仙盟获得食材数组")
	end
	if _callBack then
		echo("_________ 食材初始化完毕 ___________ ")
		_callBack()
	end
end
-- 设置 活动有效期标记
function GuildActMainModel:setInGVEOpenPeriod()
	LS:prv():set("user__gveActivity__vaildPeriod","1")
end
-- 活动结算时间到 删除有效标记
function GuildActMainModel:delInGVEOpenPeriod()
	LS:prv():set("user__gveActivity__vaildPeriod","0")
end

-- 注册活动结束事件
function GuildActMainModel:registerActivityTimeOutEvent()
	local leftTime = self:getLeftTime()
		echo("\n\n___ 距离今日活动结束时间还有 s  ___ ",leftTime)
	if leftTime>0 then
		self:setInGVEOpenPeriod()
		TimeControler:startOneCd(GuildActMainModel.eventName_activityEnd, leftTime + 1)
		EventControler:addEventListener(GuildActMainModel.eventName_activityEnd, self.TimeOfSettlementOneDay, self)
	else
		TimeControler:removeOneCd(GuildActMainModel.eventName_activityEnd)
		self:TimeOfSettlementOneDay()
	end
end

-- 注册奖励到时事件
function GuildActMainModel:registerRewardExpireEvent()
	local leftTime = self._gveScoreExpireTime - TimeControler:getTime()
	-- echo("\n\n___ 距离清理积分时间还有 s  ___ ",leftTime)
	if leftTime>0 then
		TimeControler:startOneCd(GuildActMainModel.eventName_weekScoreClear, leftTime + 1);
		EventControler:addEventListener(GuildActMainModel.eventName_weekScoreClear, self.TimeOfSettlementWeek, self)
	else
		TimeControler:removeOneCd(GuildActMainModel.eventName_weekScoreClear)
		self:TimeOfSettlementWeek()
	end
end

-- 注册活动开启倒计时
-- 登陆不久后调用,跨天时调用
function GuildActMainModel:registerActOpenTimeEvent()
	local currentTime = TimeControler:getTime()
	local tStruct = os.date("*t",currentTime)
	local dayOk,timeOk = false,false
	local openWeekDays = FuncGuildActivity.getActivityOpenDay(activityId)
	if openWeekDays then
		for k,v in pairs(openWeekDays) do
			-- echo("\ntStruct.wday,v",tStruct.wday,v)

			local dayNum = tonumber(tStruct.wday)
			if dayNum == 1 then
				dayNum = 7
			else
				dayNum = dayNum -1
			end
			-- echo("______ daynum,tonumber(v)",dayNum,tonumber(v))
			if dayNum == tonumber(v) then
				dayOk = true
				break
			end
		end
	end

	if not dayOk then
		return
	end

	local openTime = FuncGuildActivity.getActivityOpenTime(activityId)
	local leftTime = openTime - (tStruct.hour*3600 + tStruct.min*60 + tStruct.sec) 
	if leftTime>0 then
		-- echoError("设定一个闹钟,到点给凯哥发消息")
		TimeControler:startOneCd(GuildActMainModel.eventName_notifyActValidTimer, leftTime + 1);
		EventControler:addEventListener(GuildActMainModel.eventName_notifyActValidTimer, self.registerActOpenTimeEvent, self)
	else
		TimeControler:removeOneCd(GuildActMainModel.eventName_notifyActValidTimer)
		-- echoError("_____________ 来来来,给凯哥发个消息")
		EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI,{_type = FuncCommon.SYSTEM_NAME.GUILDACTIVITY})
		self:sendGuildChatData(1)
	end
end

-- 初始化奖励信息和红点
function GuildActMainModel:initRewardData()
	-- self.configRewardData = FuncGuildActivity.getAccumulateReward()
	local isShow = self:isShowGuildActRedPoint()
end

-- 12点结算时间
-- 删除所有的gve信息 组队信息 关闭所有界面
function GuildActMainModel:TimeOfSettlementOneDay()
	-- self:requestGVEData()
	echo("\n\n ___________ 今日活动已过期 _________")

	self:delInGVEOpenPeriod()
	TimeControler:removeOneCd(GuildActMainModel.eventName_activityEnd)
	-- WindowControler:showTips( { text = "本日仙盟活动结束!活动界面将关闭!" });
	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP)
end

-- 12点结算时间
-- 删除所有的gve信息 组队信息 关闭所有界面
function GuildActMainModel:TimeOfSettlementWeek()
	-- self:requestGVEData()
	echo("\n\n ___________ 积分奖励已过期 _________")
	if self._gveChallengeTimes then
		self._gveChallengeTimes = 0 
	end
	if self._gveScoreTotal then
		self._gveScoreTotal = 0
	end
	if self._personlHaveIngredients then
		for k,v in pairs(self._personlHaveIngredients) do
			v.curNum = 0
		end	
	end
	if self._personlHavePutIngredients then
		for k,v in pairs(self._personlHavePutIngredients) do
			v.curNum = 0
		end	
	end

	if self._havedBeenCooking then
		self._havedBeenCooking = nil
	end
	if self._havedBeenGotRewards then
		self._havedBeenGotRewards = {}
	end
	self:delInGVEOpenPeriod()
	TimeControler:removeOneCd(GuildActMainModel.eventName_weekScoreClear)
	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP)
	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP_WEEK)
end

function GuildActMainModel:setReconnectionData(_data)
	self._reconnectionData = _data
	if self._reconnectionData.gveTeamInfo then
		echo("______设置重连信息_________")
		GuildActMainModel.isInReconnection = true
		WindowControler:globalDelayCall(c_func(self.reconnectionHandle,self), 1/GameVars.GAMEFRAMERATE )
	end
end

function GuildActMainModel:checkReconnection()
	echo("_______ 检测是不是重连 _____")
	if self._reconnectionData and self._reconnectionData.gveTeamInfo then
		-- GuildActMainModel.isInReconnection = false
		self._hitEndTime = self:getHitEndTimeRecords()
		-- dump(self._hitEndTime, "初始化时读取本地存储的 self._hitEndTime")
		
	    local _gveTeamInfo = self._reconnectionData.gveTeamInfo
	    if FuncGuildActivity.isDebug then
	    	dump(_gveTeamInfo, "重连的 队伍信息 ")
	    end
		local function _callback( ... )
			echo("_______ 队伍信息恢复完毕 ")
			-- dump(self.beforeTeamInRestoreNotify, "\n\n\n\n @@@@@@@@@@@@@@@@ 缓存的推送消息 ____ self.beforeTeamInRestoreNotify")
			-- self.isHandling = true
			self:handlePreviousNotify()
		    local function _callfun()
		        self:setCurrentRoundAccountTime()
		        self.isNotFirstComeOutMonster = true
		        GuildActMainModel.isInReconnection = true
				local _oldView = WindowControler:getWindow( "GuildActivityInteractView" )
				if _oldView then
					echoWarn("______ 删除挑战界面的老 怪 !")
					_oldView.mapControler:deleteMonsters()
					_oldView:startHide()
				end
		        WindowControler:showWindow("GuildActivityInteractView")
		    end
		    GuildControler:getMemberList(2,_callfun) --跳转到仙盟主城    
		end

		local _data = {}
		_data["teamInfo"] = _gveTeamInfo
		self:updateTeamInfo( _data,_callback )
	end
end

function GuildActMainModel:handlePreviousNotify()
	if not self.beforeTeamInRestoreNotify then
		return
	end
	local name1 = "notify_guild_activity_round_account_5644"
	if self.beforeTeamInRestoreNotify[name1] then
		-- dump(self.beforeTeamInRestoreNotify[name1], "___________ @@@ 结算处理 ___ ")
		local serverData = {}
		serverData["params"] = table.deepCopy(self.beforeTeamInRestoreNotify[name1]) 
		-- dump(serverData, "___________ @@@ 结算处理serverdata ___ ")
		self.beforeTeamInRestoreNotify[name1] = nil
		self:onOneRoundAccount(serverData)
	end

	name1 = "notify_guild_activity_defeat_monster_5640"
	if self.beforeTeamInRestoreNotify[name1] then
		-- echo("___________ @@@ 打败怪物处理 ___ ")
		local serverData = {}
		serverData.params = table.deepCopy(self.beforeTeamInRestoreNotify[name1]) 
		self.beforeTeamInRestoreNotify[name1] = nil
		self:onSomeoneDefeatOneMaster(serverData)
	end

	name1 = "notify_guild_activity_mark_monster_5632"
	if self.beforeTeamInRestoreNotify[name1] then
		-- echo("___________ @@@ 标记怪物处理 ___ ")
		local serverData = {}
		serverData.params = table.deepCopy(self.beforeTeamInRestoreNotify[name1]) 
		self.beforeTeamInRestoreNotify[name1] = nil
		self:onSomeoneMarkOneMaster(serverData)
	end

	name1 = "notify_guild_activity_unmark_monster_5636"
	if self.beforeTeamInRestoreNotify[name1] then
		-- echo("___________ @@@ 取消标记怪物处理 ___ ")
		local serverData = {}
		serverData.params = table.deepCopy(self.beforeTeamInRestoreNotify[name1]) 
		self.beforeTeamInRestoreNotify[name1] = nil
		self:onSomeoneUnMarkOneMaster(serverData)
	end

	name1 = "notify_guild_activity_quit_challenge_5628"
	if self.beforeTeamInRestoreNotify[name1] then
		-- echo("___________ @@@ 某玩家退出挑战 处理 ___ ")
		local serverData = {}
		serverData.params = table.deepCopy(self.beforeTeamInRestoreNotify[name1]) 
		self.beforeTeamInRestoreNotify[name1] = nil
		self:onTeamSomeQuitChallenge(serverData)
	end

	name1 = "notify_guild_activity_start_count_down_5670"
	if self.beforeTeamInRestoreNotify[name1] then
		-- echo("___________ @@@ 重新开始倒计时 处理 ___ ")
		local serverData = {}
		serverData.params = table.deepCopy(self.beforeTeamInRestoreNotify[name1]) 
		self.beforeTeamInRestoreNotify[name1] = nil
		self:syncRoundTime(serverData)
	end
end

--------------------------------------------------------------------------
---------------------- 队伍数据更新          ------------------------------
--------------------------------------------------------------------------
function GuildActMainModel:updateTeamInfo( _data,_callback )
	if not _data then
		return
	end

	-- dump(_data,"_data--------------------")
	-- echoError ("updateTeamInfo-------------")

	if not self._myTeamIngredients then
		local configIngredients = FuncGuildActivity.getFoodMaterial(self._guildFoodId)
		self._myTeamIngredients = {}
		for k,v in pairs(configIngredients) do
			self._myTeamIngredients[v.id] = 0
		end
	end
	if not self._myTeamScore then
		self._myTeamScore = 0 
	end

	if _data.addtionalMonsters then
		self._addtionalMonsters = _data.addtionalMonsters
	end
	if _data.comboRes then
		self._comboRes = _data.comboRes
	end
	if _data.comboReward then
		self._comboReward = _data.comboReward
	end
	if _data.totalReward then
		self._totalReward = _data.totalReward
	end
	if _data.teamInfo then
		if _data.teamInfo.id then
			self._myTeamId = _data.teamInfo.id
		end
		if _data.teamInfo.ingredients then
			for k,v in pairs(self._myTeamIngredients) do
				if _data.teamInfo.ingredients[k] then
					self._myTeamIngredients[k] = _data.teamInfo.ingredients[k]
				end
			end
		end
		if _data.teamInfo.members then
			self._myTeamMembers = _data.teamInfo.members
		end
		if _data.teamInfo.monsters then
			self._myTeamMonsters = _data.teamInfo.monsters
			for k,v in pairs(self._myTeamMonsters) do
				if v.mark then
					GuildActMainModel.markArr[v.index] = true
				end
			end
		end
		if _data.teamInfo.period then
			self._myTeamPeriod = _data.teamInfo.period
		end
		if _data.teamInfo.round then
			self._myTeamRound = _data.teamInfo.round
			-- self._haveBeenSentRequestRound[self._myTeamRound] = true
		end
		if _data.teamInfo.roundStartTime then
			self._myTeamRoundStartTime = _data.teamInfo.roundStartTime
		end
		if _data.teamInfo.score then
			self._myTeamScore = _data.teamInfo.score
		end
		if _data.teamInfo.hitEndTime and (self._myTeamRoundStartTime <= _data.teamInfo.hitEndTime) then
			if not self._hitEndTime then
				self._hitEndTime = {}
			end
			local preRound = nil
			if tonumber(self._myTeamRound) > 1 then
				preRound = self._myTeamRound - 1
				while (preRound > 0) and (not self._hitEndTime[tostring(preRound)]) do
					preRound = preRound - 1
				end
			end
			if preRound and self._hitEndTime[tostring(preRound)] then
				if _data.teamInfo.hitEndTime > self._hitEndTime[tostring(preRound)] then
					self._hitEndTime[tostring(self._myTeamRound)] = _data.teamInfo.hitEndTime
				end
			else
				self._hitEndTime[tostring(self._myTeamRound)] = _data.teamInfo.hitEndTime
			end
			if FuncGuildActivity.isDebug then
				dump(self._hitEndTime, "更新队伍信息时的 self._hitEndTime ")
			end
		end
	end	

	if _callback then
		_callback()
	end
end


--------------------------------------------------------------------------
---------------------- 重置数据            ------------------------------
--------------------------------------------------------------------------
function GuildActMainModel:resetTeamInfo()
	echo("______ 重置队伍信息 _______ ")
	if self._comboRes then
		self._comboRes = nil
	end
	if self._myTeamId then
		self._myTeamId = nil
	end
	if self._myTeamMembers then
		self._myTeamMembers = nil
	end
	if self._myTeamMonsters then
		self._myTeamMonsters = nil
	end
	if self._myTeamPeriod then
		self._myTeamPeriod = nil
	end
	if self._myTeamRound then
		self._myTeamRound = nil
	end
	if self._myTeamRoundStartTime then
		self._myTeamRoundStartTime = nil
	end
	self:resetMarkArr()
	GuildActMainModel.isNotFirstComeOutMonster = false
	-- 注意第五轮之后还可能有combo 所以不能在此处情况combo标记
	-- GuildActMainModel.hasNotCombo = {}
	self._hitEndTime = {}
	self:setHitEndTimeRecords(self._hitEndTime)
end
function GuildActMainModel:resetTeamReward()
	if self._totalReward then
		self._totalReward = nil
	end
	if self._myTeamIngredients then
		for k,v in pairs(self._myTeamIngredients) do
			self._myTeamIngredients[k] = 0
		end
	end 
	if self._myTeamScore then
		self._myTeamScore = 0
	end
	if self._addtionalMonsters then
		self._addtionalMonsters = nil
	end
	self:setIsInCombo( false )
	GuildActMainModel.hasNotCombo = {}

	if self._myTeamMonsters then
		self._beforeComboMonsters = nil
	end
	if self._myTeamScore then
		self._beforeComboScore = 0
	end
	if self._myTeamIngredients then
		self._beforeComboIngredients = nil
	end
end

function GuildActMainModel:resetGVEData()
	self._guildFoodId = nil
	self._guildTotalHaveIngredients = nil
	self._lastGveTime = nil
	self._gveChallengeTimes = nil
	self._gveScoreTotal = 0
	self._personlHaveIngredients = nil
	self._personlHavePutIngredients = nil
	self._havedBeenCooking = nil
	self._havedBeenGotRewards = nil
	self._gveScoreExpireTime = nil
end

function GuildActMainModel:resetMarkArr()
	GuildActMainModel.markArr = {} -- 重置标志怪数组
end

-- 断线重连 还在场景中 销毁场景 清除队伍相关数据
function GuildActMainModel:resetGveStatus() 
    local currentView = WindowControler:getCurrentWindowView()
    if not currentView  then
    	return
    end
    local cname = currentView.__cname    
    if (cname == "GuildActivityInteractView") then 
	    local function _callfun1()
			EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_CHALLENGE_END,{})
		end
		self:requestGVEData(_callfun1)
		local function _callfun()
			-- 挑战已经结束 玩家退出队伍
			GuildActMainModel.isNotFirstComeOutMonster = false
			echo("resetGveStatus-断线重连")
			self:resetTeamInfo()
			-- 注意这里也将奖励信息置空了
			self:resetTeamReward()
			EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_ACCOUNT_DATA_READY,
				{totalReward = _data.totalReward})				
		end
		self:updateTeamInfo( _data,_callfun )
    	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_CLOSE_INTERACT_VIEW)
    end
end

-- ==============================================================
-- ==============================================================
-- 更新仙盟红点
function GuildActMainModel:isShowGuildActRedPoint()
	-- TODO五测关闭仙盟酒家系统
	if true then
		return false
	end

	local isOpen = self:isActivityCanOpen()
	if not isOpen then
		return false
	end

	if self:isShowRewardRedPoint() 
		or self:isShowCookingRedPoint()
		or GuildActMainModel:getChallengeTimes() < GuildActMainModel:getMaxChallengeTimes() then
		echo("展示仙盟活动红点")
		return true
	else
		return false
	end
end
-- 更新累积奖励红点
function GuildActMainModel:isShowRewardRedPoint()
	for k,v in pairs(self.configRewardData) do
		if self:isShowOneRewardRedPoint( v.id ) then
			return true
		end
	end
	return false
end
-- 更新单个奖励红点
function GuildActMainModel:isShowOneRewardRedPoint( _rewardId )
	if not _rewardId then
		return false
	end
	if self._havedBeenGotRewards and self._havedBeenGotRewards[_rewardId] then
		return false
	end

	local haveNum = GuildActMainModel:getAccumulateScore()
	local needNum = self.configRewardData[_rewardId].foodScore
	if haveNum >= needNum then
		return true
	end
	return false
end

-- 是否显示煮菜红点
function GuildActMainModel:isShowCookingRedPoint()
	if not self._personlHaveIngredients then
		return false
	end
	
	if not self:isActivityCanOpen() then
		return false
	end

	for k,v in pairs(self._personlHaveIngredients) do
		if self:isShowOneMaterialRedPoint( k ) then
			echo("______显示红点____________",k)
			return true
		end
	end
	return false
end
-- 是否显示某个食材的红点
function GuildActMainModel:isShowOneMaterialRedPoint( _materialId )
	local wholeGuildData = GuildActMainModel:getGuildTotalIngredients(_materialId)
	local stillCanPutInNum = wholeGuildData.maxNum - wholeGuildData.curNum 
	local havePutInData = GuildActMainModel:getHavePutInIngredient(_materialId)
	local stillCanPutInNum2 = havePutInData.maxNum - havePutInData.curNum 
	if stillCanPutInNum2 < stillCanPutInNum then
		stillCanPutInNum = stillCanPutInNum2
	end

	local playerOwnData = GuildActMainModel:getCurHaveIngredients(_materialId)
	local playerOwnNum = 0
	if playerOwnData then
		playerOwnNum = playerOwnData.curNum 
	end
	if playerOwnNum < stillCanPutInNum then
		stillCanPutInNum = playerOwnNum
	end
	if stillCanPutInNum > 0 then
		-- echo("______显示红点____________",_materialId)
		return true
	else
		-- echo("______不 显示红点____________",_materialId)
		return false
	end
end

--------------------------------------------------------------------------
---------------------- 注册事件      --------------------------------------
--------------------------------------------------------------------------
function GuildActMainModel:registerEvent()
	-- 开启活动 所有仙盟内成员接受
 	EventControler:addEventListener("notify_guild_activity_champions_open_act_5604",self.onActivityOpen,self); 
 	-- 队内成员发生变化 所有队员接受
 	EventControler:addEventListener("notify_guild_activity_teamMemer_changed_5612",self.onTeamMemberChanged,self); 
 	-- 接受到邀请的成员接受
 	EventControler:addEventListener("notify_guild_activity_beinginvited_5620",self.onReceivedBeingInvitedInfo,self); 
 	--
 	-- 所有队员接受
 	-- 开始挑战 结束挑战
 	EventControler:addEventListener("notify_guild_activity_start_challenge_5624",self.onTeamLeaderStartChallenge,self); 
 	-- EventControler:addEventListener("notify_guild_activity_quit_challenge_5628",self.onTeamSomeQuitChallenge,self); 
 	-- -- 标记怪物 取消标记
 	-- EventControler:addEventListener("notify_guild_activity_mark_monster_5632",self.onSomeoneMarkOneMaster,self); 
 	-- EventControler:addEventListener("notify_guild_activity_unmark_monster_5636",self.onSomeoneUnMarkOneMaster,self); 
 	-- -- 打败怪物
 	-- EventControler:addEventListener("notify_guild_activity_defeat_monster_5640",self.onSomeoneDefeatOneMaster,self); 
 	-- -- 前四轮战斗结算 最后的战斗结算
 	-- EventControler:addEventListener("notify_guild_activity_round_account_5644",self.onOneRoundAccount,self);
  --   EventControler:addEventListener("notify_guild_activity_last_round_account_5646",self.onLastRoundAccount,self); 

  --   -- 投入食材
  --   EventControler:addEventListener("notify_guild_activity_someone_put_ingredients_5656",self.onSomeoneInputIngredients,self); 
  --   -- 被踢
 	-- EventControler:addEventListener("notify_guild_activity_be_kickout_5662",self.beKickOutByTeamLeader,self); 	
 	-- EventControler:addEventListener("notify_guild_remove_player_1356",self.beKickOutByGuildLeader, self)
 	-- EventControler:addEventListener("notify_guild_activity_start_count_down_5670",self.syncRoundTime, self)

 	EventControler:addEventListener("notify_guild_activity_quit_challenge_5628",self.mapNotifyToHandle,self); 
 	-- 标记怪物 取消标记
 	EventControler:addEventListener("notify_guild_activity_mark_monster_5632",self.mapNotifyToHandle,self); 
 	EventControler:addEventListener("notify_guild_activity_unmark_monster_5636",self.mapNotifyToHandle,self); 
 	-- 打败怪物
 	EventControler:addEventListener("notify_guild_activity_defeat_monster_5640",self.mapNotifyToHandle,self); 
 	-- 前四轮战斗结算 最后的战斗结算
 	EventControler:addEventListener("notify_guild_activity_round_account_5644",self.mapNotifyToHandle,self);
    EventControler:addEventListener("notify_guild_activity_last_round_account_5646",self.onLastRoundAccount,self); 
    -- 投入食材
 	EventControler:addEventListener("notify_guild_remove_player_1356",self.mapNotifyToHandle, self)
 	EventControler:addEventListener("notify_guild_activity_start_count_down_5670",self.mapNotifyToHandle, self)

 	EventControler:addEventListener("notify_guild_activity_be_kickout_5662",self.beKickOutByTeamLeader,self); 	
    EventControler:addEventListener("notify_guild_activity_someone_put_ingredients_5656",self.onSomeoneInputIngredients,self); 
	-- 布阵结束，开始战斗
    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.onTeamFormationComplete, self)

    -- 断网重连处理
    -- EventControler:addEventListener(LoginEvent.LOGINEVENT_RELOGINBACK, self.reconnectionHandle, self)

    -- 更新gve活动红点
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_GOT_REWARD, self.updateGveRedPoint, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP_WEEK, self.updateGveRedPoint, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_SOMEONE_INPUT_INGREDIENTS, self.updateGveRedPoint, self)
	-- 设定定时器,监听是否已到活动开启时间
	self:registerActOpenTimeEvent()
	EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.registerActOpenTimeEvent,self)
	EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE,self.registerActOpenTimeEvent,self)
end

function GuildActMainModel:updateGveRedPoint( event )
    local isShowGveRedpoint = GuildActMainModel:isShowGuildActRedPoint()
    if self.lastShowRedpoint ~= isShowGveRedpoint then
        self.lastShowRedpoint = isShowGveRedpoint
        echo("_____仙盟活动红点有变化__________",self.lastShowRedpoint)
        EventControler:dispatchEvent(GuildEvent.GUILD_ACTIVITY_REDPOINT_CHANGED,{sysType = "gve" }) 
    end
end

function GuildActMainModel:reconnectionHandle( event )
	local function callBack()
		self:initRewardData()
		self:checkReconnection()
	end
	self:requestGVEData(callBack)
end

function GuildActMainModel:mapNotifyToHandle( serverData )
	if GuildActMainModel.isInReconnection then
		echo("\n_____!!! 队伍信息恢复中 ,消息缓存 _____",serverData.name)
		self:cacheNotifyBeforeTeamInRestore( serverData.name,serverData.params )
	else
		echo("\n_____!!! 推送消息 直接处理 _____",serverData.name)
		local funcKeyName = GuildActMainModel.funcKeyMap[serverData.name]
		if funcKeyName and self[funcKeyName] then
			self[funcKeyName](self,serverData)
		end
	end
end
function GuildActMainModel:cacheNotifyBeforeTeamInRestore( _eventName,_eventParams )
	if not self.beforeTeamInRestoreNotify then
		self.beforeTeamInRestoreNotify = {}
	end
	self.beforeTeamInRestoreNotify[_eventName] = _eventParams
end

-- 布阵
function GuildActMainModel:onTeamFormationComplete( event )
	local params = event.params
    local sysId = params.systemId

    if sysId == FuncTeamFormation.formation.guildGve then
		echo("\n\n\n 布阵完成！！！！！")
		-- dump(params, "params", nesting)
		self.defaultFormation = table.deepCopy(params.formation)
		if self:isInNewGuide() then
	        EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)
	        echo("___________self.curgridIdx",self.curgridIdx,"toBeatMonsterId,", toBeatMonsterId,"toBeatLevelId",toBeatLevelId)
	        -- dump(self._myTeamMonsters, "self._myTeamMonsters", nesting)
	        local toBeatMonsterId = self._myTeamMonsters[tostring(self.curgridIdx)].id
	        local toBeatLevelId = FuncGuildActivity.getMonsterLevelIdByMonsterId( toBeatMonsterId )
	        local battleInfo = {
			    battleId     = 1,
			    battleLabel  = "15",
			    battleParams = {
			        monsterInfo = {
			            monsterId = toBeatMonsterId,
			        },
			    },
			    battleUsers = {table.deepCopy(UserModel._data),},
			    gameMode     = 1,
			    levelId      = toBeatLevelId,
			    randomSeed   = 779038974,
			}
			battleInfo.battleUsers[1].formation = self.defaultFormation
			dump(battleInfo, "battleInfo", 2)
			BattleControler:startBattleInfo(battleInfo)
	     	return
		end
	end

	if not self._myTeamRound then
		return 
	end
	local cdName = GuildActMainModel.eventName_oneRoundTimer..self._myTeamRound
	local leftTime = TimeControler:getCdLeftime( cdName )

	if leftTime < 0 then
		echo(" 倒计时结束不能战斗  __________ ")
		return
	end
	if GuildActMainModel:getIsInCombo() then
		echo("碰撞中不能打怪 __________ ")
		EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)
		return
	end

    if sysId == FuncTeamFormation.formation.guildGve then
        local formation = params.formation
        GuildActivityServer:beatMonster(
        	self._guildId,
        	self._myTeamId,
        	self.curgridIdx,
        	self._myTeamRound,
        	formation,
        	c_func(self.getServerBattleDataCallBack,self)
        )
    end
end
-- 战斗前初始化
function GuildActMainModel:getServerBattleDataCallBack(event)
	if event.error then
		if event.error.code == 563701 then
			WindowControler:showTips( GameConfig.getLanguage("#tid_guildAct_001") )
		end
		EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)
	end
    if event.result ~= nil then
    	-- dump(event.result.data,"打包子 战斗信息")
    	UserModel:cacheUserData( )
		local battleInfo = BattleControler:turnServerDataToBattleInfo( event.result.data.battleInfo )
		-- dump(battleInfo, "battleInfo", nesting)
        EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)
        BattleControler:startBattleInfo(battleInfo)
    end
end

--------------------------------------------------------------------------
---------------------- 服务器推送            ------------------------------
--------------------------------------------------------------------------
-- 活动开启
function GuildActMainModel:onActivityOpen( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：活动开启")
	end
	local _data = serverData.params.params.data
	self._guildFoodId = _data.foodId
	self._lastGveTime = _data.lastGveTime
	-- 记录本次开启的活动
	self:setLastOpenFoodId(self._guildFoodId)

	self.forceRefresh = true
	local function _callfun( ... )
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ONE_ACTIVITY_OPEN,
		{foodId = self._guildFoodId,lastGveTime = self._lastGveTime,} )
	end
	self:requestGVEData(_callfun)
end

-- 更新当前队内成员
function GuildActMainModel:onTeamMemberChanged( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：队内成员发生变化")
	end

	local _data = serverData.params.params.data

	local isFirstJoin = false
	if not self._myTeamId then
		isFirstJoin = true
	end
	local function _callfun()
		if isFirstJoin then
			EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_JOIN_TEAM_SUCCEED,{teamId = _data.teamId} )
		end
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_MEMBERS_CHANGE,{})
	end
	self:updateTeamInfo( _data,_callfun )
end

function GuildActMainModel:onReceivedBeingInvitedInfo( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：接收到邀请")
	end
	local _data = serverData.params.params.data
    local currentView = WindowControler:getCurrentWindowView()
    local cname = currentView.__cname    
    if BattleControler:isInBattle() 
    	or TutorialManager.getInstance():isInTutorial() 
    	or TutorialManager.getInstance():isHomeExistSysOpen() 
    	or TutorialManager.getInstance():isHasTriggerSystemOpen()
    	or (cname == "GatherSoulMainView")
    	or (cname == "GuildActivityInteractView")
    then

    else
    	WindowControler:showTopWindow("GuildActivityTeamInviteView",_data)  
    	
    	-- (cname == "HomeMainView") or (cname == "GuildMainView") or 
    	-- (cname == "GuildActivityEntranceView") or (cname == "GuildActivityMainView") then
        -- if self.teamView == nil then
        --     local scene =  display.getRunningScene()
        --     self.teamView = WindowsTools:createWindow("GuildActivityTeamInviteView",_data):addto(scene._topRoot,WindowControler.ZORDER_TIPS)
        --     self.teamView:pos(0,display.height - 150)
        --     self.teamView:updateUI(_data)
        -- else
        --     self.teamView:setVisible(true) 
        --     self.teamView:updateUI(_data)
        -- end
    end 
end
function GuildActMainModel:inviteViewSetVisible(_isShow)
	-- self.teamView:setVisible(_isShow) 
end

function GuildActMainModel:onTeamLeaderStartChallenge( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：队伍开始挑战")
	end
	if self._isClickByGuildChairman == true then
		self._isClickByGuildChairman = false
	end

	local _data = serverData.params.params.data
	GuildActMainModel.isNotFirstComeOutMonster = false
	GuildActMainModel.hasNotCombo = {}
	self._hitEndTime = {}
	self:setHitEndTimeRecords(self._hitEndTime)

	-- 服务器数据已更新 但是需要requestGVEData 此处暂用直接的方式变更本地数据 
	self:requestGVEData()

	local function _callfun()
		GuildActMainModel.hasNotCombo[self._myTeamRound] = true
		self:setCurrentRoundAccountTime()
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_START_CHALLENGE,{})

		local _oldView = WindowControler:getWindow( "GuildActivityInteractView" )
		if _oldView then
			echoWarn("______  删除挑战界面的老 怪 !")
			_oldView.mapControler:deleteMonsters()
		end
		-- 如果还在队伍中则进挑战界面
	    if self._myTeamId then
	    	WindowControler:showWindow("GuildActivityInteractView")
	    end
	end
	self:updateTeamInfo( _data,_callfun )
end
function GuildActMainModel:initTeamIngredients()
	local configIngredients = FuncGuildActivity.getFoodMaterial(self._guildFoodId)
	self._myTeamIngredients = {}
	for k,v in pairs(configIngredients) do
		self._myTeamIngredients[v.id] = 0
	end
end

function GuildActMainModel:onTeamSomeQuitChallenge( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：某人退出挑战")
	end
	local _data = serverData.params.params.data
	table.removebyvalue(self._myTeamMembers,_data.rid)
	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_SOMEONE_QUIT,
		{rid = _data.rid})
end

function GuildActMainModel:onSomeoneMarkOneMaster( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：某人标记一个怪")
	end
	local _data = serverData.params.params.data
	GuildActMainModel.markArr[_data.index] = true

	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_MARK_MONSTER,
		{index = _data.index, rid = _data.rid})
end

function GuildActMainModel:onSomeoneUnMarkOneMaster( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：某人取消标记一个怪")
	end
	local _data = serverData.params.params.data
	GuildActMainModel.markArr[_data.index] = nil

	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_UNMARK_MONSTER,
		{index = _data.index, rid = _data.rid})
end

function GuildActMainModel:onSomeoneDefeatOneMaster( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：某人打败了一个怪")
	end

	local _data = serverData.params.params.data
	self.originMonsterIndex = _data.index
	local _isFirstHandle = true
    self:handleMonsterKilledEffect( _data,_isFirstHandle )
end

-- 递归处理被打败的怪的数据
function GuildActMainModel:handleMonsterKilledEffect( _data,_isFirstHandle )
	if not self.monsterKilledCache then
		self.monsterKilledCache = {}
	end

	local killedData = _data
	if FuncGuildActivity.isDebug then
		dump(killedData, "====killedData")
	end
	self._myTeamMonsters[killedData.index].status = 1 --怪已被打败
	GuildActMainModel.markArr[killedData.index] = nil -- 清除标记
	-- 如果在布阵中则关闭布阵
    local currentView = WindowControler:getCurrentWindowView()
    local cname = currentView.__cname    
    if (cname == "WuXingTeamEmbattleView") and self.curgridIdx and (killedData.index == self.curgridIdx) then 
		EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)
    end 

	local monsterId = self._myTeamMonsters[killedData.index].id
	if FuncGuildActivity.isDebug then
		dump(self._myTeamMonsters[killedData.index], "self._myTeamMonsters[killedData.index]")
	end
	local monsterType = FuncGuildActivity.getMonsterTypeByMonsterId( monsterId )
	if monsterType == FuncGuildActivity.monsterType.food then
		-- 更新队内积分食材和怪状态
		-- 注意返回的是当前队内的食材和积分
		if killedData.score then
			self._myTeamScore = killedData.score
		end
		if killedData.ingredients then
			for k,v in pairs(killedData.ingredients) do
				self._myTeamIngredients[k] = v
			end
		end

		if GuildActMainModel:isInNewGuide() then
			local score = FuncGuildActivity.getMonsterScore(monsterId)
			self._myTeamScore = self._myTeamScore + score
			local ingredients = FuncGuildActivity.getMonsterMaterialList(monsterId)
			for k,v in pairs(ingredients) do
				self._myTeamIngredients[v.id] = self._myTeamIngredients[v.id] + v.num
			end
		end
		echo("______ self._myTeamScore __________ ",self._myTeamScore)
		dump(self._myTeamIngredients, "打败一个怪后的食材量", nesting)
		self.monsterKilledCache[killedData.index] = killedData
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_SOMEONE_DEFEAT_MONSTER,{data = killedData})

	elseif monsterType == FuncGuildActivity.monsterType.red then
		if tostring(self.originMonsterIndex) == tostring(killedData.index) and (not _isFirstHandle) then
			return
		end

		-- 炸自己
		local dataToHandle = {}
		dataToHandle.index = killedData.index
		dataToHandle.ingredients = {}
		dataToHandle.rid = killedData.rid
		dataToHandle.score = 0
		dataToHandle.isBoom = true
		dataToHandle.boomDelayTime = 0
		self.monsterKilledCache[dataToHandle.index] = dataToHandle
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_SOMEONE_DEFEAT_MONSTER,{data = dataToHandle})
		-- 炸左边
		local leftIndex = tostring(tonumber(killedData.index) - 1)
		if leftIndex ~= FuncGuildActivity.minIndex then
			local killLeftMonsterData = {}
			killLeftMonsterData.ingredients = killedData.ingredients
			killLeftMonsterData.rid = killedData.rid
			killLeftMonsterData.score = killedData.score
			killLeftMonsterData.index = leftIndex
			killLeftMonsterData.isBoom = true
			killLeftMonsterData.boomDelayTime = 0.1

			self:handleMonsterKilledEffect( killLeftMonsterData )
		end
		-- 炸右边
		local rightIndex = tostring(tonumber(killedData.index) + 1)
		if rightIndex ~= FuncGuildActivity.maxIndex then
			local killRightMonsterData = {}
			killRightMonsterData.ingredients = killedData.ingredients
			killRightMonsterData.rid = killedData.rid
			killRightMonsterData.score = killedData.score
			killRightMonsterData.index = rightIndex
			killRightMonsterData.isBoom = true
			killRightMonsterData.boomDelayTime = 0.1
			self:handleMonsterKilledEffect( killRightMonsterData )
		end

	elseif monsterType == FuncGuildActivity.monsterType.blue then
		killedData.isFrozenChar = true
		GuildActMainModel.frozenRid = killedData.rid
		self.monsterKilledCache[killedData.index] = killedData
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_SOMEONE_DEFEAT_MONSTER,{data = killedData})

	elseif monsterType == FuncGuildActivity.monsterType.gold then
		local rewardData = FuncGuildActivity.getMonsterItemRewardByMonsterId( monsterId )
		killedData.gotReward = rewardData 
		self.monsterKilledCache[killedData.index] = killedData
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_SOMEONE_DEFEAT_MONSTER,{data = killedData})
	end
end

-- 获取相应的缓存
function GuildActMainModel:getMonsterKilledCache(_index)
	local index = tostring(_index)
	if not self.monsterKilledCache then
		return 
	end
	return self.monsterKilledCache[index]
end

-- 清除相应的缓存
-- 不传入index则清除全部
function GuildActMainModel:clearMonsterKilledCache(_index)
	if not _index then
		self.monsterKilledCache = nil
		return
	end
	local index = tostring(_index)
	if not self.monsterKilledCache then
		return 
	end
	if self.monsterKilledCache[index] then
		self.monsterKilledCache[index] = nil
	end
end


function GuildActMainModel:onOneRoundAccount( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：一轮战斗结算")
	end
	local _data = serverData.params.params.data
	-- combo前的数据
	if self._myTeamMonsters then
		self._beforeComboMonsters = table.deepCopy(self._myTeamMonsters) 
		for k,v in pairs(self._beforeComboMonsters) do
			local monsterType = FuncGuildActivity.getMonsterTypeByMonsterId( v.id )
			if monsterType == FuncGuildActivity.monsterType.gold 
				or monsterType == FuncGuildActivity.monsterType.blue then
				echo("_________蓝色怪和金色怪combo前消掉__________")
				v.status = 1
			end
		end
	end
	if self._myTeamScore then
		self._beforeComboScore = self._myTeamScore
	end
	if self._myTeamIngredients then
		self._beforeComboIngredients = table.deepCopy(self._myTeamIngredients)
	end
	echo("_______________ GuildActMainModel:onOneRoundAccount( serverData ) 设置为碰撞中______________________________ ")
	self:setIsInCombo( true )
	GuildActMainModel.hasNotCombo[self._myTeamRound] = true
	-- dump(GuildActMainModel.hasNotCombo, "收到结算数据时________GuildActMainModel.hasNotCombo")
	self:resetMarkArr()
	GuildActMainModel.frozenRid = nil
	local function _callfun()
		-- 设置本轮到期时间
		self:setCurrentRoundAccountTime()
		-- 如果在布阵中则关闭布阵
	    local currentView = WindowControler:getCurrentWindowView()
	    local cname = currentView.__cname    
	    if (cname == "WuXingTeamEmbattleView")then 
			EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)
	    end 
		-- 如果在战斗中则直接跳过
		if BattleControler:isInBattle() then
			WindowControler:showTips( GameConfig.getLanguage("#tid_guildAct_002"))
			return
		else
			EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_ACCOUNT_DATA_READY,{})	
		end
	end
	self:updateTeamInfo( _data,_callfun )
end

function GuildActMainModel:onLastRoundAccount( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：最后一轮战斗结算")
	end
	local _data = serverData.params.params.data

	if not self._myTeamId then
		WindowControler:showWindow("GuildActivityKillMonsterRewardView",_data.totalReward)
		return
	end

	self._beforeComboMonsters = table.deepCopy(self._myTeamMonsters) 
	for k,v in pairs(self._beforeComboMonsters) do
		local monsterType = FuncGuildActivity.getMonsterTypeByMonsterId( v.id )
		if monsterType == FuncGuildActivity.monsterType.gold 
			or monsterType == FuncGuildActivity.monsterType.blue then
			echo("_________蓝色怪和金色怪combo前消掉__________")
			v.status = 1
		end
	end

	self._beforeComboScore = self._myTeamScore
	self._beforeComboIngredients = table.deepCopy(self._myTeamIngredients)
	GuildActMainModel.hasNotCombo[self._myTeamRound] = true
	-- dump(GuildActMainModel.hasNotCombo, "收到结算数据时________GuildActMainModel.hasNotCombo")

	local function _callfun1()
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_CHALLENGE_END,{})
	end
	self:requestGVEData(_callfun1)

	local function _callfun()
		-- 挑战已经结束 玩家退出队伍
		GuildActMainModel.isNotFirstComeOutMonster = false
		echo("onLastRoundAccount=最后一轮结算")
		dump(_data.totalReward,"_data.totalReward--------------")
		self:resetTeamInfo()
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_ACCOUNT_DATA_READY,
			{totalReward = _data.totalReward})
		dump(_data,"_data-------------")
	end
	self:updateTeamInfo( _data,_callfun )
end

-- 某人向大锅中投入了食材
function GuildActMainModel:onSomeoneInputIngredients( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：某人向大锅中投入食材")
	end

	-- 仙盟大锅内的食材
	-- 某人可能打过,但是收到了不属于自己的食材推送,这个bug得查
	local notTodayFoods = false  
	local _data = serverData.params.params.data	
 	if _data.ingredients then
 		for k,v in pairs(_data.ingredients) do
 			if self._guildTotalHaveIngredients and self._guildTotalHaveIngredients[k] then
 				self._guildTotalHaveIngredients[k].curNum = v
 			else
 				notTodayFoods = true
 				dump(_data.ingredients, "盟友投入的食材", nesting)
 				dump(self._guildTotalHaveIngredients, "本盟的食材", nesting)
 				echoError("______ 队友投入了不同的食材??? _________")
 				break
 			end
 		end
	end
	if notTodayFoods then
		return
	end
	 -- 投入的食材
 	if _data.useIngredients and (_data.rid == UserModel:rid()) then
		for k,v in pairs(_data.useIngredients) do
			if self._personlHaveIngredients then
				self._personlHaveIngredients[k].curNum = self._personlHaveIngredients[k].curNum - v
				if self._personlHaveIngredients[k].curNum < 0 then
					self._personlHaveIngredients[k].curNum = 0 
				end
				-- 更新玩家已经投入的数量
				self._personlHavePutIngredients[k].curNum = self._personlHavePutIngredients[k].curNum + v 
			end
		end
	end
	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_SOMEONE_INPUT_INGREDIENTS,
		{data = _data})	
end

-- 被队长踢出队伍
function GuildActMainModel:beKickOutByTeamLeader( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：被队长剔除队伍")
	end

	self._myTeamId = nil
	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_BE_KICKOUT_BY_TEAMLEADER,{})	
end

-- 被盟主踢出仙盟
function GuildActMainModel:beKickOutByGuildLeader( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：被盟主踢出仙盟")
	end

	local _type = FuncCount.COUNT_TYPE.COUNT_TYPE_EVERYDAY_SPEND_SP_TIMSE
	CountModel._data[tostring(_type)].count = 0

	self:resetGVEData()
	self:resetTeamInfo()
	if BattleControler:isInBattle() then
		self._isClickByGuildChairman = true
	else
		self:TimeOfSettlementOneDay()
	end
end

function GuildActMainModel:syncRoundTime( serverData )
	if FuncGuildActivity.isDebug then
		dump(serverData.params,"服务器推送：开始新一轮选怪战斗倒计时")
	end
	self:setIsInCombo( false )
	local _data = nil
	if serverData.params then
		_data = serverData.params.params.data
	end
	if not self._hitEndTime then
		self._hitEndTime = {}
	end
	self._hitEndTime[tostring(_data.round)] = _data.hitEndTime
	-- 记录hitEndTime 到本地
	self:setHitEndTimeRecords(self._hitEndTime)
	self:setCurrentRoundAccountTime()
end

function GuildActMainModel:getHitEndTime(_curRound)
	if self._hitEndTime and self._hitEndTime[tostring(_curRound)] then
		return self._hitEndTime[tostring(_curRound)]
	end
	return nil
end











--------------------------------------------------------------------------
---------------------- 工具函数           ---------------------------------
--------------------------------------------------------------------------
-- 判断盟主或者副盟主能否开启活动
function GuildActMainModel:isActivityCanOpen( _activityId )
	local activityId = _activityId or "1"
	local dayOk = false
	local timeOk =  false 
	local guildLevelOk =  false

	local currentTime = TimeControler:getTime()
	local tStruct = os.date("*t",currentTime)
	-- dump(tStruct,"时间结构 currentTime 0 = ",7)

	local sysName = FuncCommon.SYSTEM_NAME.GUILDACTIVITY
	local isOpen = FuncCommon.isSystemOpen(sysName)
	if not isOpen  then
		return  false,"33级开启活动"
	end

	local openWeekDays = FuncGuildActivity.getActivityOpenDay(activityId)
	if openWeekDays then
		for k,v in pairs(openWeekDays) do
			-- echo("\ntStruct.wday,v",tStruct.wday,v)

			local dayNum = tonumber(tStruct.wday)
			if dayNum == 1 then
				dayNum = 7
			else
				dayNum = dayNum -1
			end
			-- echo("______ daynum,tonumber(v)",dayNum,tonumber(v))
			if dayNum == tonumber(v) then
				dayOk = true
				break
			end
		end
	end

	local openTime = FuncGuildActivity.getActivityOpenTime(activityId)
	echo("\n openTime ",openTime)

	openTime = openTime/3600
	-- 23点关闭系统
	local closeTime = 23
	if tStruct.hour >= openTime and tStruct.hour < closeTime then
		timeOk = true
	end

	local curLevel = GuildModel:getGuildLevel()
	local configLevel = FuncGuildActivity.getActivityOpenMinLevel(activityId)
	echo("@@@@@_________ curLevel,configLevel __________",curLevel,configLevel)

	if curLevel >= configLevel then
		guildLevelOk =  true
	end
	local str = "1"
	if not guildLevelOk then
		 -- WindowControler:showTips( GameConfig.getLanguage("#tid_guildAct_003") )
		 str = GameConfig.getLanguage("#tid_guildAct_003")
		 return false,str
	elseif not dayOk then
		 -- WindowControler:showTips( GameConfig.getLanguage("#tid_guildAct_004"))
		 str = GameConfig.getLanguage("#tid_guildAct_004")
		 return false,str
	elseif not timeOk then
		 -- WindowControler:showTips( GameConfig.getLanguage("#tid_guildAct_005"))
		 str = GameConfig.getLanguage("#tid_guildAct_005")
		 return false,str
	end

	return true
end
-- 距离活动结束还剩余的时间
function GuildActMainModel:getLeftTime()
	local currentTime = TimeControler:getTime()
	local curTimeStruct = os.date("*t",currentTime)
	local openTimeStruct = os.date("*t",self._lastGveTime)
	local leftTime = 0
	-- 原来的手动开启改为到时自动开启 判断是否是可开启活动当天
	-- if openTimeStruct.yday == curTimeStruct.yday then
	if self:isActivityCanOpen() then
		leftTime = (3600*(23-curTimeStruct.hour) - 60*curTimeStruct.min - curTimeStruct.sec)
	else
		leftTime = 0
	end
	return leftTime
end
-- 检查 是否处于活动开启状态
function GuildActMainModel:getInGVEOpenPeriod()
	local isGotWholeTargetReward = LS:prv():get("user__gveActivity__vaildPeriod","0")
	if isGotWholeTargetReward == "1" then
		return true
	end
	return false
end


--=====================================================================
-- 
function GuildActMainModel:setCurrentRoundAccountTime()
	local cdName = GuildActMainModel.eventName_oneRoundTimer..self._myTeamRound
	if not self._oneRoundDuration then
		self._oneRoundDuration = FuncDataSetting.getOneAccountTime()
	end

	self._accountLeftTime = (self._myTeamRoundStartTime + self._oneRoundDuration + 20) - TimeControler:getTime()
	echo("________初识设置时间 self._accountLeftTime ________",self._accountLeftTime)
	if self._hitEndTime and (self._hitEndTime[tostring(self._myTeamRound)]) then
		local ht = self._hitEndTime[tostring(self._myTeamRound)]
		self._accountLeftTime = (ht + self._oneRoundDuration) - TimeControler:getTime()
		echo("________再次设置时间 self._accountLeftTime ________",self._accountLeftTime)
		-- EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_SYN_TIME,{} )
	end
	if tonumber(self._accountLeftTime) <= 0 then
		echo("__________ 这种异常只有再重连的  时候才会发生")
		-- GuildActMainModel:settleOneRoundAccounts(self._guildId,self._myTeamId,self._myTeamRound)
		TimeControler:removeOneCd(cdName)
		return
	end
	TimeControler:removeOneCd(cdName)
	TimeControler:startOneCd(cdName, self._accountLeftTime)
	EventControler:addEventListener(cdName, self.onOneRoundTimeOut, self)

	local battleCdName = GuildActMainModel.eventName_notifyBattleInvalidTimer
	self._accountLeftTime = self._accountLeftTime - 5 
	if self._accountLeftTime > 0 then
		TimeControler:startOneCd(battleCdName, self._accountLeftTime)
		EventControler:addEventListener(battleCdName, self.notifyBattleInvalid, self)
	else
		self:notifyBattleInvalid()
	end
end

function GuildActMainModel:onOneRoundTimeOut( event )
	local preRound = event.name
	preRound = string.split(preRound, GuildActMainModel.eventName_oneRoundTimer)
	echo("________ 一轮选怪战斗时间到 round ___________,self._myTeamRound",preRound[2],self._myTeamRound)
	TimeControler:removeOneCd(GuildActMainModel.eventName_oneRoundTimer..preRound[2])
	if tostring(self._myTeamRound) == tostring(preRound[2]) then
		echoWarn("____ 正常监听倒计时结束",self._accountLeftTime)
		GuildActMainModel:settleOneRoundAccounts(self._guildId,self._myTeamId,preRound[2])
	end
end

-- 通知战斗快速给结果
function GuildActMainModel:notifyBattleInvalid()
	echo("\n\n ==================== 通知战斗快速给结果 ___________")
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GVE_TIME_OUT) 
end
--=====================================================================
--combo
--=====================================================================
-- self._beforeComboMonsters = table.deepCopy(self._myTeamMonsters) 
-- self._beforeComboScore = self._myTeamScore
-- self._beforeComboIngredients = table.deepCopy(self._myTeamIngredients)
-- 累积战斗积分
function GuildActMainModel:addChallengesScore(_score)
	self._beforeComboScore = self._beforeComboScore + _score
end
-- 累积战斗食材
function GuildActMainModel:addChallengesIngredients(_materialId,_num)
	if not self._beforeComboIngredients[tostring(_materialId)] then
		echo("____________ 开启的食物id ",self:getCurFoodId())
		dump(self._beforeComboIngredients, "碰撞前的食材", nesting)
		echoError("食材初始化和杀怪获得食材不一致!检查配表") 
	end
	self._beforeComboIngredients[tostring(_materialId)] = self._beforeComboIngredients[tostring(_materialId)] + _num
end
-- 获取combo前的怪数组
function GuildActMainModel:getPreComboMonsters()
	return self._beforeComboMonsters
end

-- 获取本轮战斗积分
function GuildActMainModel:getChallengesScore()
	-- echo(" 获取积分时是否在碰撞状态_______ ", self:getIsInCombo())
	-- echo("self._beforeComboScore", self._beforeComboScore)
	-- echo("self._myTeamScore", self._myTeamScore)
	if self:isInNewGuide() then
		return self._myTeamScore --self.teachGotScore
	end

	if self:getIsInCombo() == true and self._beforeComboScore then
		-- 在combo状态中
		return self._beforeComboScore or 0
	else
		return self._myTeamScore or 0
	end
end

-- 获取本轮战斗某食材
function GuildActMainModel:getOneChallengeGotMaterials(_materialId)
	-- echo(" 获取食材时是否在碰撞状态______________ ", self:getIsInCombo())
	-- dump(self._beforeComboIngredients, "self._beforeComboIngredients")
	-- dump(self._myTeamIngredients, "self._myTeamIngredients")
	if not self._myTeamIngredients then
		if self:isInNewGuide() then
			self:setDefaultMonsterArr()
		else
			local configIngredients = FuncGuildActivity.getFoodMaterial(self._guildFoodId)
			self._myTeamIngredients = {}
			for k,v in pairs(configIngredients) do
				self._myTeamIngredients[v.id] = 0
			end
		end
	end

	if self:getIsInCombo() == true and self._beforeComboIngredients then
		return self._beforeComboIngredients[tostring(_materialId)] or 0
	else
		return self._myTeamIngredients[tostring(_materialId)] or 0
	end
end

-- 将一次挑战获得的奖励加到用户身上
function GuildActMainModel:addTeamRewardToPlayer(_totalReward)
	echo("服务器做了相关逻辑")
	-- self:requestGVEData()
	self:resetTeamInfo()
	-- if self._gveChallengeTimes > 3 then
	-- 	echo("挑战次数超过三次，不能再加积分和奖励")
	-- 	return
	-- end
	
	-- if _totalReward.score and self._gveScoreTotal then
	-- 	self._gveScoreTotal = self._gveScoreTotal + _totalReward.score
	-- end
	-- if _totalReward.ingredients then
	-- 	for k,v in pairs(_totalReward.ingredients) do
	-- 		if self._personlHaveIngredients[k] then
	-- 			self._personlHaveIngredients[k].curNum = self._personlHaveIngredients[k].curNum + v  
	-- 		end
	-- 	end
	-- end
end

--=====================================================================
-- 获取预览活动id(将要开启的活动id)
function GuildActMainModel:getToOpenFoodId()
	-- 食物序列
	local foodIds = FuncGuildActivity.getActivityFoodSequence(GuildActMainModel.curGuildActivityId)
	local total = #foodIds
	local openFoodId = nil

	local openTimeSec = LoginControler:getServerInfo().openTime
	local nowTimeSec = TimeControler:getServerTime()

	local openDate = os.date("*t", openTimeSec)
	local nowDate = os.date("*t",nowTimeSec)

	local openTime = os.time({year=openDate.year,day=openDate.day, month=openDate.month,hour=4, minute=0, second=0})
	local nowTime = os.time({year=nowDate.year,day=nowDate.day, month=nowDate.month,hour=4, minute=0, second=0})

	local diffDay = (nowTime - openTime) / (24*3600)
	local index = diffDay % total

	openFoodId = foodIds[index+1]

	return openFoodId
end

-- 获取预览活动id(将要开启的活动id)
function GuildActMainModel:getToOpenFoodId_old()
	-- 食物序列
	local foodIds = FuncGuildActivity.getActivityFoodSequence(GuildActMainModel.curGuildActivityId)
	local numOfFoods = table.length(foodIds)
	-- 活动开放星期几序列
	local openWeekDays = FuncGuildActivity.getActivityOpenDay(GuildActMainModel.curGuildActivityId)
	local numOfDaysInAWeek = table.length(openWeekDays)

	-- 计算自开服以来有多少天是可以开活动的
	local d1 = LoginControler:getServerInfo().openTime
    local d2 = CarnivalModel:getBornTime(d1)
    local c1 = TimeControler:getServerTime()
    local durTime = c1 - d2 
    local durFormat = TimeControler:turnTimeSec( durTime,TimeControler.timeType_dhhmmss )
    local dd = string.split(durFormat,"天")
    if not dd[2] then
    	serverOpenDays = 1
    else
    	serverOpenDays = dd[1]
    end
	local t1 = math.floor(serverOpenDays/7)
	local t2 = serverOpenDays%7
	-- echo("\n\n\n\n\n\n\n\n\n\n____ serverOpenDays,t1,t2 _________",serverOpenDays,t1,t2)

	local validOpenDays = t1*numOfDaysInAWeek 
	local openTimeData = os.date("*t", LoginControler:getServerInfo().openTime)
	local openTimeRelevantWeekDay = openTimeData.wday
	for i=0,t2 do
		local targetDay = (openTimeRelevantWeekDay + i) % 7
		local dayNum = tonumber(targetDay)
		if dayNum == 1 then
			dayNum = 7
		elseif dayNum == 0 then
			dayNum = 6
		else
			dayNum = dayNum -1
		end
		if table.isValueIn(openWeekDays,dayNum) then
			validOpenDays = validOpenDays + 1
		end
	end

	-- 计算到今天应该开哪个活动
	local m2 = validOpenDays%numOfFoods
	if m2 == 0 then
		m2 = 6
	end
	local toOpenId = tostring(foodIds[m2])
	echo("____ m2,toOpenId _________",m2,toOpenId)
	return toOpenId
end

-- 根据玩家当前所处服务器时间 获取应该开启的foodId
function GuildActMainModel:getScheduleFoodIdByServerTime()
	local curServerId = LoginControler:getServerId()
	local serInfo = LoginControler:getServerInfoById(curServerId)
	dump(serInfo, "serverInfo", nesting)
	local openTime = serInfo.openTime
	-- local foodActNum = 
end

function GuildActMainModel:getLastOpenFoodId()
	local lastguildFoodId = LS:prv():get("user__gveActivity__lastOpenFoodId","0")
	echo("__________获取上一次开启的id__________",lastguildFoodId)
	return lastguildFoodId
end
function GuildActMainModel:setLastOpenFoodId( _guildFoodId )
	echo("__________设置上一次开启的id__________",_guildFoodId)
	LS:prv():set("user__gveActivity__lastOpenFoodId",_guildFoodId)
end

-- 获取开启的活动要煮菜的菜id
function GuildActMainModel:getCurFoodId()
	if self._guildFoodId then
		return self._guildFoodId 
	end
	return nil
end

function GuildActMainModel:getHavedBeenCookingMark()
	return self._havedBeenCooking or 0
end
function GuildActMainModel:getHavedBeenGotRewards()
	return self._havedBeenGotRewards or {}
end
function GuildActMainModel:getGveScoreExpireTime()
	return self._gveScoreExpireTime
end
-- 获取玩家已经挑战的次数
function GuildActMainModel:getChallengeTimes()
	return self._gveChallengeTimes or 0
end

-- 获取本玩家已经投入锅内的食材数量
function GuildActMainModel:getHavePutInIngredient( _materialId )
	if self._personlHavePutIngredients then
		return self._personlHavePutIngredients[tostring(_materialId)] or {}
	else
		return {}
	end -- getHavePutInMaterialNum
end

-- 获取玩家当前拥有的食材的数量
function GuildActMainModel:getCurHaveIngredients(_materialId)
	if self._personlHaveIngredients then
		return self._personlHaveIngredients[tostring(_materialId)] or {}
	else
		return {}
	end
end

function GuildActMainModel:getGuildTotalIngredients(_materialId)
	if self._guildTotalHaveIngredients then
		return self._guildTotalHaveIngredients[tostring(_materialId)] or {}
	else
		return {}
	end
end

-- 获取玩家的累积积分
function GuildActMainModel:getAccumulateScore()
	return self._gveScoreTotal or 0
end
-- 获取奖励的状态
function GuildActMainModel:getAccumulateRewardStatus( _rewardId )
	if not self._havedBeenGotRewards then
		self._havedBeenGotRewards = {}
	end
	if not table.isEmpty( self._havedBeenGotRewards) then
		-- dump(self._havedBeenGotRewards, "已经领取的积分奖励", 3)
		for k,v in pairs(self._havedBeenGotRewards) do
			if k == _rewardId then
				return FuncGuildActivity.rewardStatus.HAVE_GOT
			end
		end
	end
	local needNum = self.configRewardData[tostring(_rewardId)].foodScore
	local haveNum = GuildActMainModel:getAccumulateScore() -- 注意这里有调用了一个函数 
	if haveNum >= needNum then
		return FuncGuildActivity.rewardStatus.CAN_GET
	end

	return FuncGuildActivity.rewardStatus.CAN_NOT_GET
end

-- 队伍信息
----------------------------------------------------
function GuildActMainModel:getMyTeamId()
	return self._myTeamId 
end
function GuildActMainModel:getCurTeamMembers()
	if not self._myTeamId then
		return {}
	end
	return self._myTeamMembers
end

-- 获取这是第几轮战斗
function GuildActMainModel:getChallengeRound()
	return self._myTeamRound
end
-- 获取本轮战斗开始时间
function GuildActMainModel:getChallengeStartTime()
	return self._myTeamRoundStartTime
end
function GuildActMainModel:getMonsterList( )
	return self._myTeamMonsters
end
function GuildActMainModel:getMonsterByIndex(_index)
	return self._myTeamMonsters[tostring(_index)]
end

-- 出怪的时候获取一个怪的数据
function GuildActMainModel:getRandomMonsterData( _gridIdx )
	if self._myTeamMonsters == nil then
		return nil
	end

	if not _gridIdx then
		return self._myTeamMonsters["1"]
	end
	return self._myTeamMonsters[tostring(_gridIdx)]
end
-- 战斗后恢复怪的时候获取一个怪的数据
function GuildActMainModel:getOldMonsterData( _gridIdx )
	if not _gridIdx then
		return self._beforeComboMonsters["1"]
	end
	return self._beforeComboMonsters[tostring(_gridIdx)]
end

-- 获取一个补充怪的id
function GuildActMainModel:getOneNewMonsterId()
	local mId = nil
	if self._addtionalMonsters then
		mId = self._addtionalMonsters[1]
	end
	table.remove(self._addtionalMonsters, 1)
	return mId
end

function GuildActMainModel:getRecordInvitedMembers()
	return self._InvitedMembers or {}
end

--==================================================================
-- 记录已经邀请过的玩家
function GuildActMainModel:recordInvitedMembers( _ridList,_inviteTime )
	if not self._InvitedMembers then
		self._InvitedMembers = {}
	end
	if _ridList and not table.isEmpty(_ridList) then
		for k,v in pairs(_ridList) do
			if not table.isKeyIn(self._InvitedMembers,v) then
				local val = {}
				val.rid = v
				val.inviteTime = _inviteTime
				-- table.insert(self._InvitedMembers, val)
				self._InvitedMembers[v] = val
			else
				self._InvitedMembers[v].inviteTime = _inviteTime
			end
		end
	end
	-- dump(self._InvitedMembers, "记录已经邀请过的玩家")
end


function GuildActMainModel:setCurChooseMonsterGridIndex( _index )
	self.curgridIdx = _index
end

function GuildActMainModel:getCurChooseMonsterGridIndex()
	return self.curgridIdx 
end

-- 校验score ingredients monsters
function GuildActMainModel:checkSIM(_clientMonsterList)
	local isMonstersOK = true
	local isScoreOK = true
	local isIngredientsOK = true

	local newKilledMonster = 0
	if FuncGuildActivity.isDebug then
		dump(self._myTeamMonsters, "self._myTeamMonsters")
		dump(_clientMonsterList, "_clientMonsterList")
	end
	for k,v in pairs(self._myTeamMonsters) do
		local clientMonsterData = _clientMonsterList[k]
		if v.status == 1 then
			echo("_______combo时有新怪被击杀_________")
			newKilledMonster = newKilledMonster + 1
		end
		if (v.status == 0) and tostring(clientMonsterData.id) ~= tostring(v.id) then
			isMonstersOK = false
			if FuncGuildActivity.isDebug then
				echoError("_____ isMonstersOK 校验错误！ ______kkk==_",k)
				WindowControler:showTips( { text = "怪 校验错误！" })
			end
			EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_CHECK_SIM_ERROR,{} )
			break
		end
	end
	
	if tonumber(self._beforeComboScore) ~= tonumber(self._myTeamScore) then
		if newKilledMonster > 0 and tonumber(self._beforeComboScore) < tonumber(self._myTeamScore) then
			echo("_______combo时有新怪被击杀___积分增加______")
		else
			isScoreOK = false
			if FuncGuildActivity.isDebug then
				echoWarn("_____ isScoreOK 校验错误！ ,self._beforeComboScore,self._myTeamScore _______",self._beforeComboScore,self._myTeamScore)
				WindowControler:showTips( { text = "积分 校验错误！" })
			end
		end
	end

	for k,v in pairs(self._myTeamIngredients ) do
		local clientNum = self._beforeComboIngredients[k]
		if clientNum ~= v then
			if newKilledMonster > 0 and tonumber(clientNum) < tonumber(v) then
				echo("_______combo时有新怪被击杀___食材增加______")
			else
				isIngredientsOK = false
				if FuncGuildActivity.isDebug then 
					echoWarn("_____ isIngredientsOK 校验错误！ _______")
					WindowControler:showTips( { text = "食材 校验错误！" })
				end
				break
			end
		end
	end

	echo("____ isScoreOK,isIngredientsOK,isMonstersOK _____",isScoreOK,isIngredientsOK,isMonstersOK )
	return (isScoreOK and isIngredientsOK and isMonstersOK)
end

function GuildActMainModel:getFoodStar()
	return FuncGuildActivity.getFoodStar( self._guildFoodId,self._guildTotalHaveIngredients ) or 0
end


function GuildActMainModel:setIsInCombo( _isInCombo )
	if FuncGuildActivity.isDebug then
		echo("________ 设置是否在碰撞 __________",_isInCombo)
	end
	self._isInCombo = _isInCombo
end
function GuildActMainModel:getIsInCombo()
	return self._isInCombo or false
end

function GuildActMainModel:getTotalReward()
	return self._totalReward
end

function GuildActMainModel:setHitEndTimeRecords(_list)
	echo("\n\n\n\n___________ 记录hitEndTime到本地 ——————————————————————————")
	if (not LSChat:byNameGetTable(GuildActMainModel.hitEndTime)) then
		LSChat:createTable(GuildActMainModel.hitEndTime)
	end

	if FuncGuildActivity.isDebug then
		dump(_list, "存信息 记录hitEndTime到本地 ____", 5)
	end
	if _list then
		_list = json.encode( _list ) 
		LSChat:setData(GuildActMainModel.hitEndTime,"_list",_list)
	end
end
function GuildActMainModel:getHitEndTimeRecords()
	local listtable = LSChat:byNameGetTable(GuildActMainModel.hitEndTime)
	if listtable ~= nil then
		local list = LSChat:getData(GuildActMainModel.hitEndTime,"_list")
		if tostring(list) ~= "nil" then
			-- dump(_list, "LSChat:getallData._list_________ ", 5)
			local _list = json.decode( list ) 
			return _list
		end
	end
	return {}
end

--=================================================================================
-- 客户端和服务端交互接口
--=================================================================================
-- 开启GVE定时活动 
-- 废弃
function GuildActMainModel:openActivity(_guildId)
	-- if self.havedSentRequest then
	-- 	return
	-- end	
	-- local function callBack( serverData )
	-- 	self.havedSentRequest = false
	-- 	if serverData.error then
	-- 		return
	-- 	end
	-- 	WindowControler:showTips( GameConfig.getLanguage("#tid_guildAct_006"))
	-- 	-- dump(serverData.result, "服务器返回：开启GVE定时活动")	
	-- 	if GuildModel:judgmentIsForZBoos() then
	-- 		local  param={};  
	-- 		local linkContent = "<color = FF0000>".."【仙盟酒家】".."<->" 
	-- 		param.content = GameConfig.getLanguageWithSwap("#tid_food_tip_2010",linkContent)
	-- 		param.type = 1
	-- 		ChatServer:sendLeagueMessage(param);
	-- 	end
	-- end
	-- GuildActivityServer:openActivity(_guildId,callBack)
	-- self.havedSentRequest = true
end

-- -- 获取盟内所有队伍的列表
-- function GuildActMainModel:getTeamList(_guildId)
-- 	local memberList = nil
-- 	local function callBack( serverData )
-- 		dump(serverData.result, "服务器返回：获取盟内所有队伍的列表")

-- 		-- 服务器返回房间列表
-- 		memberList = serverData.result.data.teams
-- 		-- dump(memberList,"服务器返回房间列表")
-- 		return memberList 
-- 	end
-- 	GuildActivityServer:getTeamList(_guildId,callBack)
-- 	return memberList 
-- end

-- 创建队伍
function GuildActMainModel:createTeam(_guildId)
	if self.havedSentRequest then
		return
	end
	local function callBack( serverData )
		self.havedSentRequest = false
		if serverData.error then
			return
		end
		-- dump(serverData.result, "服务器返回：创建队伍")
		self._myTeamId = serverData.result.data.teamInfo.id
		self._myTeamMembers = serverData.result.data.teamInfo.members
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_CREATE_SUCCEED,{teamId = self._myTeamId} )
	end
	GuildActivityServer:createTeam(_guildId,callBack)
	self.havedSentRequest = true
end

-- 加入队伍
function GuildActMainModel:joinTeam(_guildId,_teamId)
	if self.havedSentRequest then
		return
	end
	local function callBack( serverData )
		self.havedSentRequest = false
		if serverData.error then
			if serverData.error.code == 560901 then
				EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_ONE_TEAM_DISMISS,{} )
				WindowControler:showTips( GameConfig.getLanguage("#tid_guildAct_008"));
			end
			return
		end
		-- dump(serverData.result, "服务器返回：加入队伍")
		-- self._myTeamId = _teamId
		-- EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_JOIN_TEAM_SUCCEED,{teamId = _teamId} )
	end
	GuildActivityServer:joinTeam(_guildId,_teamId,callBack)
	self.havedSentRequest = true
end

-- 离开队伍
function GuildActMainModel:leaveTeam(_guildId,_teamId)
	if self.havedSentRequest then
		return
	end
	local function callBack( serverData )
		self.havedSentRequest = false
		if serverData.error then
			return
		end		
		-- dump(serverData.result, "服务器返回：离开队伍")
		self._myTeamId = nil
		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_LEAVE_TEAM_SUCCEED,{teamId = nil} )
	end
	GuildActivityServer:leaveTeam(_guildId,_teamId,callBack)
	self.havedSentRequest = true
end

-- 踢人
function GuildActMainModel:kickOutOnePerson(_guildId,_teamId,_trid)
	if self.havedSentRequest then
		return
	end
 	local function callBack( serverData )
 		self.havedSentRequest = false
		if serverData.error then
			return
		end		
		-- dump(serverData.result, "服务器返回：踢人")
		-- 服务器推送信息给队内成员，做界面刷新
		-- 注意判断被踢者是不是自己
	end
	GuildActivityServer:kickOutOnePerson(_guildId,_teamId,_trid,callBack)
	self.havedSentRequest = true
end

-- 邀请盟友
function GuildActMainModel:inviteAllies(_guildId,_teamId,_trids)
	local function callBack( serverData )
		if serverData.error then
			return
		end		
		-- dump(serverData.result, "服务器返回：邀请盟友")
	end
	GuildActivityServer:inviteAllies(_guildId,_teamId,_trids,callBack)
end

-- 队伍挑战开始
function GuildActMainModel:startChallenge(_guildId,_teamId)
	local function callBack( serverData )
		if serverData.error then
			return
		end		
		-- dump(serverData.result, "服务器返回：队伍挑战开始")
	end
	GuildActMainModel.isInBattle = true
	GuildActivityServer:startChallenge(_guildId,_teamId,callBack)
end

-- 主动退出挑战
function GuildActMainModel:quitChallenge()
	local function callBack( serverData )
		if serverData.error then
			return
		end
		echo("quitChallenge-主动退出挑战")
		self:resetTeamInfo()
		self:resetTeamReward()
		local function callBack( event )
			EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_CHALLENGE_END,{})	
		end
		self:requestGVEData(callBack)

		-- dump(serverData.result, "服务器返回：主动结束挑战,退出房间")
	end
	GuildActivityServer:quitChallenge(self._guildId,self._myTeamId,callBack)
end

-- 标记怪
function GuildActMainModel:markMonster(_index)
	local function callBack( serverData )
		if serverData.error then
			return
		end		
		-- dump(serverData.result, "服务器返回：标记怪")
	end
	GuildActivityServer:markMonster(self._guildId,self._myTeamId,_index,self._myTeamRound,callBack)
end

-- 取消标记怪
function GuildActMainModel:markMonsterCancel(_index)
	local function callBack( serverData )
		self.havedSentRequest = false
		if serverData.error then
			return
		end		
		-- dump(serverData.result, "服务器返回：取消标记怪")
	end
	GuildActivityServer:markMonsterCancel(self._guildId,self._myTeamId,_index,self._myTeamRound,callBack)
end

-- -- 打包子，战斗请求
-- function GuildActMainModel:beatMonster(_guildId,_teamId,_index,_round,_formation)
-- 	local function callBack( serverData )
-- 		if serverData.error then
-- 			return
-- 		end		
-- 	end
--     GuildActivityServer:beatMonster(_guildId,_teamId,_index,_round,_formation,callBack)
-- end

-- 一轮战斗结算
function GuildActMainModel:settleOneRoundAccounts(_guildId,_teamId,_round)
	local function callBack( serverData )
		if serverData.error then
			return
		end		
		-- dump(serverData.result, "服务器返回：一轮战斗结算")
	end
	GuildActivityServer:settleOneRoundAccounts(_guildId,_teamId,_round,_callBack)
end

-- 投入食材
function GuildActMainModel:putInMaterials(_guildId,_foodItems,callBack)
	-- local function callBack( serverData )
	-- 	if serverData.error then
	-- 		return
	-- 	end		
	-- 	dump(serverData.result, "服务器返回：投入食材")
	-- end
	GuildActivityServer:putInMaterials(_guildId,_foodItems,callBack)
end

-- 领取积分奖励
function GuildActMainModel:getAccumulateReward(_guildId,_rewardIds)
	if self.havedSentRequest then
		return
	end

	local function callBack( serverData )
		self.havedSentRequest = false
		if serverData.error then
			return
		end
		-- dump(serverData.result, "服务器返回：获取积分奖励")
		if serverData.error then
			return
		else
		local data = serverData.result.data
		self._havedBeenGotRewards = data.gveMember.scoreRewards
	  	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_GOT_REWARD,{rewardIds = _rewardIds})
		end
	end
	GuildActivityServer:getAccumulateReward(_guildId,_rewardIds,callBack)
	self.havedSentRequest = true
end

-- 获取仙盟内可以被邀请的成员
-- 即还没有加入任何一队的成员
function GuildActMainModel:getCanInviteMembers(_guildId)
	local function callBack( serverData )
		if serverData.error then
			return
		end		
		-- dump(serverData.result, "服务器返回：获取可邀请成员")
	end
	GuildActivityServer:getCanInviteMembers(_guildId,callBack)
end

function GuildActMainModel:sentCurPosition( _targetPosition )
	local _posX = _targetPosition.x
	local _posY = _targetPosition.y
	local function _callBack( serverData )
		if serverData.error then
			return
		end
		-- echo("发送地点回调 __________ ")
	end
	if self._myTeamId then
		GuildActivityServer:sentCurPosition(self._guildId,self._myTeamId,_posX,_posY,_callBack)
	end
end


-- 开始一轮倒计时
function GuildActMainModel:sentStartCountDown(_callBack)
	local function _callBack1( serverData )
		-- 注意这个在error之前调用 防止服务器错误造成卡住
		if _callBack then
			_callBack()
		end
		if serverData.error then
			return
		end
		-- dump(serverData.params, "发送倒计时返回数据")
		-- body
	end
	GuildActivityServer:sentStartCountDown(self._guildId,self._myTeamId,self._myTeamRound,_callBack1)
end

-- 进入布阵界面
function GuildActMainModel:goTeamFormationView()
    -- local params = {}
    -- params[FuncTeamFormation.formation.pve_elite] = {
    --     npcs = formation,
    --     raidId = self.currentUnfoldRaidId,
    -- }
    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.guildGve)
end


-- ========================================================================================
-- 新手引导做特殊处理 获得的食材和积分都不计入正式所得
-- DateTime:    2018-05-14 15:06:50
-- ========================================================================================
-- 判断是不是正在新手引导中
function GuildActMainModel:isInNewGuide()
	local c1 = not UserExtModel:gveGuideFlag() or (UserExtModel:gveGuideFlag() == "")
	-- echo("判断是不是正在新手引导中 ___________c1 ,c2,flag ",c1,c2,UserExtModel._data.gveGuideFlag)
	-- local isInGuide = c1 and c2
	-- return isInGuide	
	return c1 and TutorialManager.getInstance():isInTutorial()
end

-- function GuildActMainModel:get( ... )
-- 	-- body
-- end
-- 初始化用用教学的怪
function GuildActMainModel:setDefaultMonsterArr()
	local defaultMonsterArr = FuncDataSetting.getFoodTeachMonsterArr()
	self._myTeamMonsters = {}
	self._addtionalMonsters = {}
	self.teachConfigIngredients = {}
	-- self.teachGotIngredients = {}
	self._myTeamIngredients = {}
	self._myTeamScore = 0
	self._myTeamRound = 1
	local lenlimit = table.length(defaultMonsterArr)
	for i=1,lenlimit do
		self._addtionalMonsters[i] = defaultMonsterArr[i]
		local temp = {
			  ["id"]     = defaultMonsterArr[i] ,
 	          ["index"]  = i,
 	          ["status"] = 0,
		}
		-- table.insert(self._myTeamMonsters, temp)
		self._myTeamMonsters[tostring(i)] = temp

		-- local monsterData = 
		local ingredients = table.deepCopy(FuncGuildActivity.getMonsterMaterialList(defaultMonsterArr[i])) --table.deepCopy(monsterData.beatFoodItem)
		dump(ingredients, "desciption", nesting)
		for k,oneIngredients in pairs(ingredients) do
			if not self._myTeamIngredients[tostring(oneIngredients.id)] then
				self._myTeamIngredients[tostring(oneIngredients.id)] = 0
				table.insert(self.teachConfigIngredients, oneIngredients)
			end
		end

		-- dump(monsterData.beatFoodItem, "monsterData.beatFoodItem", nesting)
	end
	-- dump(self._myTeamMonsters, "self._myTeamMonsters", nesting)
	-- dump(self.teachConfigIngredients, "self.teachConfigIngredients", nesting)
end

-- 获取配置怪对应食材
-- 只有场景中显示食材用
function GuildActMainModel:getTeachMaterials()
	return self.teachConfigIngredients
end

-- 更新食材获得 积分获得
-- 杀怪获得
function GuildActMainModel:updateTeachMaterials(monsterId)
	local monsterData = FuncGuildActivity.getMonsterMaterialList(monsterId)
	local materialId = tostring(monsterData.beatFoodItem.id)
	local addNum = monsterData.beatFoodItem.num
	self._myTeamIngredients[materialId] = self._myTeamIngredients[materialId] + addNum

	if monsterData.beatScore then
		self.teachGotScore = self.teachGotScore + monsterData.beatScore
	end
end

-- 保存地图坐标
function GuildActMainModel:saveMapPos(pos)
	self.cacheMapPos = pos
end

-- 获取地图坐标
function GuildActMainModel:getMapPos()
	return self.cacheMapPos or {x=1240,y=0}
end

-- 保存主角坐标
function GuildActMainModel:saveCharPos(pos)
	self.cacheCharPos = pos
end

-- 获取主角坐标
function GuildActMainModel:getCharPos()
	return self.cacheCharPos or {}
end

-- =============================
-- 手动开启改为自动开启还要发仙盟频道消息
function GuildActMainModel:getChatSendData()
	local function _callfun()
		local playdata = nil
		local datalast = GuildModel:getGuildMembersInfo()
		for k,v in pairs(datalast) do
			if tonumber(v.right) == tonumber(FuncGuild.MEMBER_RIGHT.LEADER) then
				playdata = v
			end
		end
		if playdata then
			local  isOpen = self:isActivityCanOpen()
			if isOpen then
				local linkContent = "仙盟酒家" 
				linkContent = "["..linkContent.."_line]"
				local tips = GameConfig.getLanguageWithSwap("#tid_food_tip_2010", linkContent)
				tips = tips.."_link"
				local chatdata = {
					params = {
						params = {
							data = {
								avatar  = playdata.avatar,
								content = tips,
								level   = playdata.level,
								name    = playdata.name,
								rid     = playdata._id,
								right   = playdata.right,
								time    = TimeControler:getServerTime(),
								type    = 1,
								vip     = 0,--playdata.vip,
								linkType = FuncChat.EventEx_Type.guildAct,
							}
						}
					}
				}
				ChatServer:requestLeagueMessage(chatdata)
			end
		end
		self.sendGuildChat = true
	end
	GuildControler:getMemberList("",_callfun)
end

function GuildActMainModel:sendGuildChatData(_type)
	-- echo("=======_type======",_type)
	-- if _type == 3 then
	-- 	return 
	-- end
	-- if not self.sendGuildChat then
			-- echoError("____ 发送仙盟频道消息",self:isActivityCanOpen())

		if self:isActivityCanOpen() then
			-- echoError("____ 发送仙盟频道消息222")
			self:getChatSendData()
		end
		-- else
		-- 	local function callBack()
		-- 		self:getChatSendData()
		-- 	end
		-- 	-- self:getAllUnlockEctypes(nil,callBack)
		-- end	
	-- end
end

-- 进入仙盟酒家主界面
function GuildActMainModel:enterGuildActMainView()
    if not GuildModel:isInGuild() then
        return
    end
    local sysName = FuncCommon.SYSTEM_NAME.GUILDACTIVITY
    local open,conditionValue, conditionType,lockTip = FuncCommon.isSystemOpen(sysName)
    if not open then
        WindowControler:showTips(lockTip)
        return 
    end
    local function callBack()
        WindowControler:showWindow("GuildActivityMainView")
    end
    GuildActMainModel:requestGVEData(callBack)
end

--[[
	获取最大挑战次数
]]
function GuildActMainModel:getMaxChallengeTimes()
	local times = FuncDataSetting.getDataByConstantName("FoodJoinNumMax")
	return times
end

--[[
	获取最大round
]]
function GuildActMainModel:getMaxRound()
	local maxRound = FuncDataSetting.getDataByConstantName("FoodTurnNumMax")
	return maxRound
end


return GuildActMainModel

