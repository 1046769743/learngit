--
--Author:      zhuguangyuan
--DateTime:    2018-01-18 10:14:09
--Description: 仙盟副本数据处理类
--

local GuildBossModel = class("GuildBossModel", BaseModel)

function GuildBossModel:ctor()
end

GuildBossModel.hasInitData = true

function GuildBossModel:init(d)
	GuildBossModel.super:init(self, d)
	self:registerEvent()
	self.frameCount = 1
	-- 仙盟副本基本数据
	self.baseBossData = {}

	--邀请加入的队伍的列表
	self.inviteAddTeamList = {}


	self.challengeTimesLimit = FuncDataSetting.getDataByConstantName("GuildBossAttackTimes") or 2
	self.openTimesLimit = FuncDataSetting.getDataByConstantName("GuildBossOpenNum") or 2

	self.eventNameDay = "guildBoss_refresh_OneDay_guildBossData_timer"
	self.eventNameOneEctype = "guildBoss_refresh_OneEctype_guildBossData_timer"
	

	self.delayTimeToCheckRedPoint = 0.5
	TimeControler:startOneCd("guildBoss_check_redpoint",self.delayTimeToCheckRedPoint)


	

	local isOpen,timeArr = FuncGuildBoss.isOnTime()
	if isOpen then
		TimeControler:startOneCd("sendToWorldChat_Boss_Open",3)
	else
		self:sendWorldApp()  --定时发送共闯开启
	end


end



function GuildBossModel:sendWorldApp()
	-- if not self.tempNode then
	-- 	local scene = WindowControler:getCurrScene()
	-- 	self.tempNode = display.newNode():addto(scene._topRoot)
		-- self.tempNode:scheduleUpdateWithPriorityLua(c_func(self.updateTimeFrame,self),0)
	-- end
	local isOpen,timeArr = FuncGuildBoss.isOnTime()
	local cdTime = nil
	for i=1,#timeArr do
		if timeArr[i] and timeArr[i] ~= 0 and timeArr[i] > 0 then
			cdTime = timeArr[i]
			break
		end
	end
	if cdTime ~= nil then
		TimeControler:startOneCd("sendToWorldChat_Boss_Open",cdTime)
	end

end
function GuildBossModel:getChatSendData()
	local function _callfun()
		local playdata = nil
		local datalast = GuildModel:getGuildMembersInfo()
		for k,v in pairs(datalast) do
			if tonumber(v.right) == tonumber(FuncGuild.MEMBER_RIGHT.LEADER) then
				playdata = v
			end
		end
		if playdata then
			local  bossID = self:getOpeningEctypeId()
			if bossID ~= nil then
				local bossConfigData = FuncGuildBoss.getBossDataById(bossID)
				local ectypeName = FuncTranslate._getLanguage(bossConfigData.name)
				ectypeName = "["..ectypeName.."_line]"
				local tips = GameConfig.getLanguageWithSwap("#tid_unionlevel_talk_1", playdata.name,ectypeName)
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
								vip     = playdata.vip,
								linkType = FuncChat.EventEx_Type.guildBoss,
							}
						}
					}
				}
				self:updateGuildActivityRedPoint()
				ChatServer:requestLeagueMessage(chatdata)
				TimeControler:removeOneCd( "sendToWorldChat_Boss_Open" )
				self:sendWorldApp()
			end
		end
		self.sendGuildChat = true
	end
	GuildControler:getMemberList("",_callfun)
end

function GuildBossModel:sendGuildChatData(_type)
	-- echo("=======_type======",_type)
	if _type == 3 then
		return 
	end
	-- if not self.sendGuildChat then
		if self:getOpeningEctypeId() ~= nil then
			self:getChatSendData()
		else
			local function callBack()
				self:getChatSendData()
			end
			self:getAllUnlockEctypes(nil,callBack)
		end	
	-- end

end
function GuildBossModel:updateTimeFrame()
	-- if  self.frameCount % (GameVars.GAMEFRAMERATE * 3) == 0 then
	if 1 then   ---屏蔽共闯
		return 
	end
		local isaddGuild = GuildModel:isInGuild()
		if not isaddGuild then
			return
		end
		local isOpen = FuncGuildBoss.isOnTime()
		if isOpen then
			self:sendGuildChatData(1)
		else
			self:sendGuildChatData(3)
		end
	-- end
	-- self.frameCount = self.frameCount + 1
end


function GuildBossModel:registerEvent()
    -- 更新仙盟副本红点
    EventControler:addEventListener(GuildBossEvent.GUILDBOSS_ONE_ECTYPE_OPEN, self.updateGuildActivityRedPoint, self)
    EventControler:addEventListener(GuildBossEvent.GUILDBOSS_TIMER_ECTYPE_TIME_OUT, self.updateGuildActivityRedPoint, self)
    EventControler:addEventListener(GuildBossEvent.GUILDBOSS_ONE_ECTYPE_PASS, self.updateGuildActivityRedPoint, self)
    EventControler:addEventListener(GuildBossEvent.GUILDBOSS_TIMER_RESET_DAY_COUNT, self.updateGuildActivityRedPoint, self)
    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.updateGuildActivityRedPoint, self)
	EventControler:addEventListener("guildBoss_check_redpoint", self.updateGuildActivityRedPoint, self)
	EventControler:addEventListener("notify_guildBoss_open_one_ectype_6210", self.onOneEctypeOpened, self)

	EventControler:addEventListener("notify_guildBoss_HP_6212", self.updataBossHP, self)

	EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.joinBattle, self)


	--共闯秘境的邀请推送
	EventControler:addEventListener("notify_guildBoss_invite_team_6230", self.inviteAddTeam, self)


	EventControler:addEventListener("notify_crosspeak_match_success",self.matchSucceed, self)


	EventControler:addEventListener(BattleEvent.BATTLEEVENT_ONBATTLEENTER,self.onbattle, self)
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_CLOSE_REWARD,self.closeBattle, self)

	-- EventControler:addEventListener("notify_crosspeak_battleOperation", self.notifyCloseServerRealTime, self)


	EventControler:addEventListener("sendToWorldChat_Boss_Open", self.updateTimeFrame, self)
	
end

-- function GuildBossModel:notifyCloseServerRealTime( event )
--  	if event.params.params.type == TeamFormationServer.hType_finishBattle then           
--         --挑战扣次数
--         echoError("111111111111111111111111")
-- 		self:setRemovechallengCount(-1)
--     end
-- end

function GuildBossModel:onbattle()
	if self.notifyView then
		self.notifyView:setVisible(false)
	end
end

function GuildBossModel:closeBattle()
	local Windownames =  WindowControler:getWindow( "GuildBossBeInvitedView" )
	if not Windownames then
		if self.notifyView then
			local num = table.length(self.inviteAddTeamList)
			if num == 0 then
				self.notifyView:setVisible(false)
			else
				self.notifyView:setVisible(true)
			end
		end

	end

end


function GuildBossModel:inviteAddTeam(event)
	local data = event.params.params.data

	dump(data,"邀请推送的数据======")
	-- local Windownames =  WindowControler:getWindow( "GuildBossBeInvitedView" )
	-- if not Windownames  then
	data[1].time = TimeControler:getServerTime()
	local haveData = false
	for k,v in pairs(self.inviteAddTeamList) do
		if v[1]._id == data[1]._id then
			self.inviteAddTeamList[k] = data
			haveData = true
		end
	end
	if not haveData then
		table.insert(self.inviteAddTeamList,data)
	end
	self:createInviteListView()
	-- end
end


function GuildBossModel:createInviteListView()

	-- local Windownames =  WindowControler:getWindow( "GuildBossInviteView" ) 
	-- local battleView = WindowControler:getWindow( "BattleView" )
	-- local wulingView = WindowControler:getWindow( "WuXingTeamEmbattleView" )
	-- local Windownames =  WindowControler:getWindow( "GuildBossBeInvitedView" )

	local windowArr = {"GuildBossInviteView","BattleView","WuXingTeamEmbattleView","GuildBossBeInvitedView","GuildWelfareMainView"}
	for k,v in pairs(windowArr) do
		local Windownames =  WindowControler:getWindow( v )
		if Windownames then
			return 
		end
	end
	--显示到主城和战斗界面	
	if self.notifyView == nil then
		self.notifyView = WindowControler:createWindowNode("GuildBossNotifyView")
		self.notifyView:setName("GuildBossNotifyView")
		local scene = display.getRunningScene()
		scene._topRoot:addChild(self.notifyView)
		self:setMove(self.notifyView)
	end
	self.notifyView:setVisible(true)
	self.notifyView:initData()
	local posData = LS:pub():get(StorageCode.guildBoss_notify_pos)
	local x = GameVars.width/2 
	local y = GameVars.height/2

	local  panelPosx,panelPosy =  self:gettopRootIsHaveView()


	if posData ~= nil then
		local data = string.split(posData,",")
		x = tonumber(data[1])
		y = tonumber(data[2]) 
		if panelPosx then
			if x >= panelPosx[1] and x <= panelPosx[2] and y >= panelPosy[1] and y <= panelPosy[2] then
				if x >= GameVars.height/2  then
					x = panelPosx[1] - 35 
				else
					x = panelPosx[2] + 35 
				end
				if y >= GameVars.height/2  then
					y = panelPosy[1] - 35 
				else
					y = panelPosy[2] + 35 
				end 

			end
		else
    		if x >= GameVars.width -100 then
    			x = GameVars.width - 100
    		elseif x <= 0 then
    			x = 20
    		end
    		if y >= GameVars.height - 20 then
    			y = GameVars.height - 20
    		elseif y <= 100 then
    			y = 100
    		end
    	end
	end
	self.notifyView:setPosition(cc.p(x,y))

end

function GuildBossModel:setMove(view)
	local scene = display.getRunningScene()
	-- local redPacketView = scene._topRoot:getChildByName("redPacketView") 
		

	local function onTouchBegan(touch, event)
			-- dump(touch,"开始 ======")
			self.notifyMove = false
            return true
        end

        local function onTouchMove(touch, event)
        	-- dump(touch,"移动 ======")
        	self.notifyMove = true
        	if self.notifyView then
        		local x = touch.x
        		local y = touch.y
        		local  panelPosx,panelPosy =  self:gettopRootIsHaveView()
				if panelPosx then
					if x >= panelPosx[1] and x <= panelPosx[2] and y >= panelPosy[1] and y <= panelPosy[2] then
						return
					end
				end		
        		if x >= GameVars.width -100 then
        			x = GameVars.width - 100
        		elseif x <= 0 then
        			x = 20
        		end
        		if y >= GameVars.height - 20 then
        			y = GameVars.height - 20
        		elseif y <= 100 then
        			y = 100
        		end
        		self.notifyView:setPosition(cc.p(x,y))

        	end
        end

        local function onTouchEnded(touch, event)  
        	-- dump(touch,"结束 ======")
        	if not self.notifyMove then
        		self:openNotifyList()
        	else
        		LS:pub():set(StorageCode.guildBoss_notify_pos,touch.x..","..touch.y)
        	end
        end

        view:setTouchedFunc(GameVars.emptyFunc, nil, true, 
        onTouchBegan, onTouchMove,
        GameVars.emptyFunc, onTouchEnded)
end
function GuildBossModel:openNotifyList()
	if self.notifyView then
		self.notifyView:setVisible(false)
	end
	WindowControler:showWindow("GuildBossBeInvitedView");
end

function GuildBossModel:offShowNotifyView()
	if self.notifyView then
		local num = table.length(self.inviteAddTeamList)
		if num == 0 then
			self.notifyView:setVisible(false)
		end
	end
end

function GuildBossModel:onShowNotifyView()
	if self.notifyView then
		self.notifyView:setVisible(true)
	else  ---没有的情况下，就重新创建一个
		self:createInviteListView()
	end
end


--判断_topRoot 上有没有红包的控件， 有返回位置 pos 
function GuildBossModel:gettopRootIsHaveView()
	local scene = display.getRunningScene()
	local panel = scene._topRoot:getChildByName("GuildBossNotifyView")
	if panel then
		local posx = panel:getPositionX()
		local posy = panel:getPositionY()
		-- local box = panel.:getContainerBox()
		return  {posx - 30,posx + 30},{posy - 30,posy + 30}
	end
	return
end



function GuildBossModel:getInviteAddTeamList()
	return self.inviteAddTeamList or {}
end

function GuildBossModel:setInviteAddTeamList(data)
	self.inviteAddTeamList  = data
end

function GuildBossModel:removeInviteAddTeamList(data)
	-- self.inviteAddTeamList  = data
	if self.inviteAddTeamList ~= nil then
		for i=1,#self.inviteAddTeamList do
			local playData = self.inviteAddTeamList[i]
			if playData then
				local d =  playData[1]
				if d._id == data._id then
					table.remove(self.inviteAddTeamList,i)
				end
			end
		end
	end
end


function GuildBossModel:updateGuildActivityRedPoint()
    local isShow = GuildBossModel:isShowGuildBossRedPoint()
    if self.lastShowRedpoint ~= isShow then
        self.lastShowRedpoint = isShow
        GuildModel:sendHomeMainViewRed()
        EventControler:dispatchEvent(GuildEvent.GUILD_ACTIVITY_REDPOINT_CHANGED,{sysType = "guildBoss" }) 
    end
end


-- 发送打副本请求
function GuildBossModel:joinBattle(event)
	local function _callBack( serverData )
		if serverData.error then
			if serverData.error.code == 620501 then
				WindowControler:showTips( GameConfig.getLanguage("#tid_guildBoss_010"))
			end
		else
			-- dump(serverData.result, "发送挑战boss  返回的数据")
        	if serverData.result.data then
	        	local battleInfoData = serverData.result.data.battleInfo
	        	battleInfoData.battleLabel = GameVars.battleLabels.guildBossPve
		        local battleInfoData = BattleControler:turnServerDataToBattleInfo(battleInfoData)
		        EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW, {onlyHideView = true})
		        BattleControler:startBattleInfo(battleInfoData)
        	end       
		end
	end
	local params = event.params
    local sysId = params.systemId
    if sysId == FuncTeamFormation.formation.guildBoss then
		GuildBossServer:attackGuildBoss(event.params.formation,_callBack)
	end
end

--更新怪物的血量
function GuildBossModel:updataBossHP(event)
	local data = event.params
	-- dump(data,"仙盟Boss血量同步 ======推送")
	local arrData = {guildBoss = data.params.data}
	GuildBossModel:updateData(arrData,true)
	self:updateGuildActivityRedPoint()
	EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_REFRESH_BOSS_HP)
	
end
 
-- 更新底层动态数据
-- 待更新的服务器数据,是否强制刷新从配表读`取的数据
function GuildBossModel:updateData(_data,_forceRefresh)
	-- dump(_data,"仙盟Boss  ========")
	-- 最近打通的最大副本id
	if _data and _data.guildBossId then
		if not self.baseBossData.guildBossMaxPassId then
			self.baseBossData.guildBossMaxPassId = _data.guildBossId
		elseif tonumber(self.baseBossData.guildBossMaxPassId) < tonumber(_data.guildBossId) then
			-- WindowControler:showTips(GameConfig.getLanguage("#tid_guildBoss_001"))
			self.baseBossData.guildBossMaxPassId = _data.guildBossId
			self:updateData(nil,true)
			-- 一个副本打通了
			EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_ONE_ECTYPE_PASS,{ectypeId = self.baseBossData.guildBossMaxPassId})
		end
	end
	-- 开启次数过期
	if _data and _data.guildBossCountExpireTime then
		if _data.guildBossCountExpireTime > TimeControler:getServerTime() then
			self.baseBossData.guildBossCountExpireTime = _data.guildBossCountExpireTime
			if _data.guildBossCount then
				self.baseBossData.guildBossCount = _data.guildBossCount
			end
		else
			self.baseBossData.guildBossCount = 0
		end
	end

	if not self.configBossList or _forceRefresh then
		self.configBossList = {}
		local maxEctypeId = GuildBossModel:getMaxUnlockEctypeId()
		echo("========最大==maxEctypeId=======",maxEctypeId)
		for i = 1,tonumber(maxEctypeId) do
			self.configBossList[i] = {}
			self.configBossList[i].id = tostring(i)
			self.configBossList[i].status = FuncGuildBoss.ectypeStatus.UNLOCK 
		end
		if tonumber(maxEctypeId) < FuncGuildBoss.maxEctypeNum then
			self.configBossList[maxEctypeId+1] = {}
			self.configBossList[maxEctypeId+1].id = tostring(maxEctypeId+1)
			self.configBossList[maxEctypeId+1].status = FuncGuildBoss.ectypeStatus.LOCK 
		end
	end
	-- dump(self.configBossList,"1111111111111111111111111")

	--预约共闯秘境BossID数据

	if _data and _data.dateBossId ~= nil then
		self.bookingBossId = _data.dateBossId
	else
		self.bookingBossId = nil
	end
	--预约共闯秘境玩家的数据
	if _data and _data.dateBossRid ~= nil then
		self.bookingBossRid = _data.dateBossRid
	end
	--预约共闯秘境时间数据   预约开启的时间
	if _data and _data.dateBossTime ~= nil then
		self.bookingBossTime = _data.dateBossTime
		local serveTime = TimeControler:getServerTime()
			-- echoError("======serveTime=======",serveTime,self.bookingBossTime,self.bookingBossTime + 3600)
		if serveTime >= self.bookingBossTime then
			self.bookingBossId = nil
		end
	end




	-- 正在开启的副本的数据
	if _data and _data.guildBoss then 
		local lastId = nil 
		if self.baseBossData.guildBoss then
			lastId = self.baseBossData.guildBoss.id
		end
		self.baseBossData.guildBoss = _data.guildBoss
		local nowId = self.baseBossData.guildBoss.id

		local bossData = _data.guildBoss

		echo("________ lastId,nowId _________",lastId,nowId)
		if (table.length(bossData) > 0) 
			and bossData.expireTime
			and bossData.expireTime > TimeControler:getServerTime() 
			then
			
			if not self.configBossList[tonumber(bossData.bossId)] then
				echoError("正在开启的副本超出已解锁范围!",bossData.bossId)
			else
				bossData.status = FuncGuildBoss.ectypeStatus.BATTLEING
				bossData.openerRid = bossData._id
				bossData._id = nil
				bossData.openerName = bossData.findUserName
				bossData.findUserName = nil
				bossData.id = bossData.bossId
				bossData.bossId = nil
				-- 	     'bossHp'                 => 'Guild\GuildBoss\GuildBossHp',//仙盟boss血量
				--       'expireTime'             => \Arsenal\Schema::NUM,//过期时间
				--       'challengeCounts'        => 'Guild\GuildBoss\ChallengeCounts',//挑战计数(各个玩家)
				--       'totalDamages'           => 'Guild\GuildBoss\TotalDamages',    //挑战总伤害
				self.configBossList[tonumber(bossData.id)] = bossData
				EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_DATA_UPDATE)
			end
		elseif lastId and (not nowId) then
			echo("_________ 发送过关消息!_________")
			self:updateData(nil,true)
			EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_ONE_ECTYPE_PASS,{ectypeId = lastId})
		else
			echo("_________副本已经过期!_________")
		end
	end

	-- 注册定时器及监听函数
	if (not self.initDayTimer) and self.baseBossData.guildBossCountExpireTime then
		self.initDayTimer = true 
		local todayLeftTime = self.baseBossData.guildBossCountExpireTime - TimeControler:getServerTime()
		if todayLeftTime < 0 then 
			self:oneDayTimeOut()
		else
			TimeControler:startOneCd(self.eventNameDay,todayLeftTime)
			EventControler:addEventListener(self.eventNameDay, self.oneDayTimeOut, self)
		end
	end
	if (not self.initOneEctypeTimer) and self.baseBossData.guildBoss and self.baseBossData.guildBoss.expireTime then
		self.initOneEctypeTimer = true
		-- local ectypeLeftTime = self.baseBossData.guildBoss.expireTime - TimeControler:getServerTime()
		-- if ectypeLeftTime < 0 then 
		-- 	self:oneEctypeTimeOut()
		-- else
		-- 	TimeControler:startOneCd(self.eventNameOneEctype,ectypeLeftTime)
		-- 	EventControler:addEventListener(self.eventNameOneEctype, self.oneEctypeTimeOut, self)
		-- end
	end

	-- dump(self.configBossList, "更新后的数据===============self.configBossList")
	-- dump(self.baseBossData, "更新后的数据===============self.baseBossData")
end




-- 四点刷新开启副本次数
function GuildBossModel:oneDayTimeOut()
	echo("____________ guildBoss 一天时间到 ___________________________")
	TimeControler:removeOneCd( self.eventNameDay )
	self.baseBossData.guildBossCount = 0
	self.baseBossData.guildBossCountExpireTime = self:getRefreshTime()
	self.initDayTimer = false
end

-- 参考嘉年华系统
-- 获取下一次刷新时间(北京时间凌晨4点)
-- 相对于开启活动时间(北京时间凌晨4点)的出生日期
-- 活动在出生日期后的第2天四点开启，则出生日期 + 3600*24*1 即可得到开启活动的时间戳
-- 活动在出生日期后的第3天四点开启，则出生日期 + 3600*24*2 即可得到开启活动的时间戳
function GuildBossModel:getRefreshTime(yyyy)
	local bornTime = yyyy 
	if bornTime == nil then
		bornTime = TimeControler:getServerTime() + TimeControler.timeDifference 
	end
	local timeStruct = os.date("*t",bornTime)
 	local hour = tonumber(timeStruct.hour)
	local str = TimeControler:turnTimeSec( bornTime, TimeControler.timeType_dhhmmss );
	-- echo("\n\n\n------当前传入 bornTime 的时间----",str)
	local int_day = math.floor(bornTime/(60*60*24))
	if int_day>0 then
	    local dayAndTime = string.split(str,"天")
	    timeArr = string.split(dayAndTime[2],":")
	    if tonumber(timeArr[1]) < 4 then
	    	dayAndTime[1] = dayAndTime[1] - 1 
	    end
	    bornTime = dayAndTime[1]*3600*24 + 4*3600
	else
	    timeArr = string.split(str,":")
	   	if tonumber(timeArr[1]) < 4 then
	    	bornTime = -4*3600
	    end
    end
	local str2 = TimeControler:turnTimeSec( bornTime, TimeControler.timeType_dhhmmss );
	-- echo("\n\n\n------算得 bornTime 的时间----",str2)

    bornTime = bornTime - TimeControler.timeDifference
    -- 下一天刷新
    bornTime = bornTime + 3600*24
    return bornTime
end


-- 副本驻留时间到
function GuildBossModel:oneEctypeTimeOut()
	echo("____________ guildBoss 副本驻留时间到 ___________________________")
	local function _callBack( serverData )
		if serverData.error then
			return
		end
		local openingEctypeData = serverData.result.data
		if FuncGuildBoss.isDebug then
			dump(openingEctypeData, "============驻留时间到时请求返回的数据")
		end
		local _forceRefresh = true -- 清理之前的开启副本数据
		GuildBossModel:updateData(openingEctypeData,_forceRefresh)
		EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_TIMER_ECTYPE_TIME_OUT,{})
	end
    GuildBossServer:getOpenBossData(_callBack)
end

--- 一个副本开启后 拉取数据 更新本地
function GuildBossModel:onOneEctypeOpened( event )
	echo("____________ guildBoss 副本成功开启后的推送消息 ___________________________")

	local data = event.params.data
	TimeControler:removeOneCd( self.eventNameOneEctype )

	local function _callBack( serverData )
		if serverData.error then
			return
		end
		local openingEctypeData = serverData.result.data
		if FuncGuildBoss.isDebug then
			dump(openingEctypeData, "============接受到副本开启消息后 请求返回的数据")
		end
		local _forceRefresh = true  -- 澄清历史数据
		self.initOneEctypeTimer = false -- 重启一个定时器
		GuildBossModel:updateData(openingEctypeData,_forceRefresh)
		EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_ONE_ECTYPE_OPEN,{})
	end
    GuildBossServer:getOpenBossData(_callBack)
end

-- ===================================================================================
-- ===================================================================================
-- 获取解锁的最大id
function GuildBossModel:getMaxUnlockEctypeId()
	-- 获取仙盟boss基本数据
	-- if not self.baseBossData or table.length(self.baseBossData) <= 0 then
	-- 	self.baseBossData = GuildModel:getGuildBossData()
	-- 	self:updateData(self.baseBossData)
	-- 	dump(self.baseBossData, "self.baseBossData")
	-- end
	if not self.baseBossData.guildBossMaxPassId then
		return 1
	end
	local maxId = self.baseBossData.guildBossMaxPassId + 1
	if maxId > FuncGuildBoss.maxEctypeNum then
		maxId = FuncGuildBoss.maxEctypeNum
	end
	return maxId or 1
end

--获得预定BOSSID
function GuildBossModel:getBookingBossID()

	-- local maxBossID = GuildBossModel:getMaxUnlockEctypeId()
	-- if self.baseBossData.guildBoss and
	-- 	self.baseBossData.guildBoss.expireTime then
	-- 	local time = TimeControler:getServerTime()
	-- 	if time <= self.baseBossData.guildBoss.expireTime then
	-- 		return self.baseBossData.guildBoss.id
	-- 	end
	-- end

	return self.bookingBossId --or maxBossID
end

-- 获取开启状态的副本id
function GuildBossModel:getOpeningEctypeId()
	if self.baseBossData then
		if self.baseBossData.guildBoss and
			self.baseBossData.guildBoss.id then
			return self.baseBossData.guildBoss.id
		else
			return nil
		end
	else
		return nil
	end
end


--获取开启的仙盟bossID
function GuildBossModel:getOpenBossID()
	local killBossId = self.baseBossData.guildBossMaxPassId   --被击杀的bossID
	if killBossId == 0 then
		killBossId = nil
	end
	local guildBossId = self:getMaxUnlockEctypeId()
	-- echo("====00=self.bossID===000000======",guildBossId)
	--获取最大解锁ID
	-- local bossID =   self:getMaxUnlockEctypeId()
	local guildBoss = self.baseBossData.guildBoss
	local serveTime = TimeControler:getServerTime()

	-- dump(guildBoss,"1222222")
	if guildBoss ~= nil then
		if guildBoss.expireTime ~= nil then
			if serveTime < guildBoss.expireTime then
				if guildBoss.dead ~= nil then
					if guildBoss.dead == 1 then
						guildBossId = self:getMaxUnlockEctypeId()

					else
						guildBossId = guildBoss.id
					end
				end
			else
				if self.bookingBossId  ~= nil then
					guildBossId = self.bookingBossId
				else
					guildBossId = self:getMaxUnlockEctypeId()
				end
			end
		end
	end
	-- echoError("====11=self.bossID===1111======",guildBossId)
	return guildBossId
	
end



-- 获取已经开启的副本次数
function GuildBossModel:getHaveOpenTimes()
	-- 注意判断当前数据是否过期
	if not self.baseBossData.guildBossCountExpireTime 
		or self.baseBossData.guildBossCountExpireTime < TimeControler:getServerTime() 
		then
		return 0
	else
		return self.baseBossData.guildBossCount or 0
	end
end

-- 获取所有解锁副本的基本数据(包含一个未解锁的副本)
-- 是否重置配置数据后再更新从服务器获得的数据
function GuildBossModel:getAllUnlockEctypes(_forceRefresh,_cellfun)
	local function _callBack( serverData )
		if serverData.error then
			return
		end
		local openingEctypeData = serverData.result.data
		-- dump(openingEctypeData, "定时拉取的数据 ====== openingEctypeData")
		GuildBossModel:updateData(openingEctypeData)
		if _cellfun then
			_cellfun()
		end
	end
    GuildBossServer:getOpenBossData(_callBack)
end



-- 有副本开启时检查是否剩余挑战次数
-- 没有副本开启时
	-- 若是盟主或者副盟主,有副本可开启则显示红点
	-- 其他成员则不显示红点
function GuildBossModel:isShowGuildBossRedPoint()

	local ectypeId = self:getOpeningEctypeId() 
	if ectypeId ~= nil then
		local guildBoss = self.baseBossData.guildBoss
		if guildBoss ~= nil then
			if guildBoss.dead == 1 then
				return false
			end
		end
	end
	local isShow = false
	local time = TimeControler:getServerTime()

	local isonTime = FuncGuildBoss.isOnTime(time)
	if isonTime then
		isShow = self:getShowCellfun()
	end

	return isShow
end
function GuildBossModel:getShowCellfun()
	local isShow = false
	if GuildBossModel:getOpeningEctypeId() then
		local challengeTimes = self:getLeftChallengeTimes( UserModel:rid() )
		if challengeTimes > 0 then
			isShow = true
		end
	end
	return isShow
end

function GuildBossModel:setRemovechallengCount(count)
	if self.baseBossData and self.baseBossData.guildBoss then
		local challengeTimesVec = self.baseBossData.guildBoss.challengeCounts
		local rid = UserModel:rid()
		-- dump(self.baseBossData.guildBoss.challengeCounts,"111111111111111111111111")
		if self.baseBossData and self.baseBossData.guildBoss and self.baseBossData.guildBoss.challengeCounts then
			if challengeTimesVec[tostring(rid)] then

				local count = self.baseBossData.guildBoss.challengeCounts[tostring(rid)].counts 
				if count == nil then
					self.baseBossData.guildBoss.challengeCounts[tostring(rid)].counts = 1
				else
					self.baseBossData.guildBoss.challengeCounts[tostring(rid)].counts = self.baseBossData.guildBoss.challengeCounts[tostring(rid)].counts  + count
				end
			else
				self.baseBossData.guildBoss.challengeCounts[tostring(rid)] = {}
				self.baseBossData.guildBoss.challengeCounts[tostring(rid)].counts = 1
				self.baseBossData.guildBoss.challengeCounts[tostring(rid)].expireTime = TimeControler:getServerTime() + 24*3600
			end
		end
	end
	-- dump(self.baseBossData.guildBoss.challengeCounts,"222222222222222222222")
end

-- 获取剩余挑战次数
function GuildBossModel:getLeftChallengeTimes( rid )

	local leftChallengeTimes = self.challengeTimesLimit
	local challengeTimesVec = self.baseBossData.guildBoss.challengeCounts
	local _challengeTimes = 0
	if challengeTimesVec  then
		
		if challengeTimesVec[tostring(rid)] ~= nil then
			_challengeTimes = challengeTimesVec[tostring(rid)].counts or 0 
			if challengeTimesVec[tostring(rid)].expireTime ~= nil then
				if TimeControler:getServerTime() >= challengeTimesVec[tostring(rid)].expireTime then
					_challengeTimes = 0
				end
			else
				_challengeTimes = 0
			end
		end
	 	leftChallengeTimes = self.challengeTimesLimit - _challengeTimes
	 	if leftChallengeTimes < 0 then
	 		leftChallengeTimes = _challengeTimes - self.challengeTimesLimit
	 	end
	end
	-- echo("=========leftChallengeTimes==========",_challengeTimes,self.challengeTimesLimit,leftChallengeTimes)
	return leftChallengeTimes
end

-- 获取剩余副本开启次数
function GuildBossModel:getOpenleftTimes()
	local haveOpenTimes = self:getHaveOpenTimes()
	local leftTimes = self.openTimesLimit - haveOpenTimes
	return leftTimes
end


-- 进入仙盟副本主界面 
function GuildBossModel:enterGuildBossMainView(_outerCallBack,_refresh)
	-- if (not _refresh) and _outerCallBack then
	-- 	_outerCallBack()
	-- 	return 
	-- else
		-- 获取仙盟boss基本数据
		if not self.baseBossData or table.length(self.baseBossData) <= 0 then
			self.baseBossData = GuildModel:getGuildBossData()
		end

		local function _innerCallBack( serverData )
			if serverData.error then
				return
			end
			local openingEctypeData = serverData.result.data
			-- if FuncGuildBoss.isDebug then
				-- dump(openingEctypeData, "============进入界面拉去的 数据")
			-- end
			GuildBossModel:updateData(openingEctypeData)
			if _outerCallBack then
				_outerCallBack()
			end
	    	-- WindowControler:showWindow("GuildBossMainView")
	    	EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_REFRESH_BOSS_RED)
		end
	    GuildBossServer:getOpenBossData(_innerCallBack)
	-- end
end


--获取关卡列表  wk
function GuildBossModel:getUnlockListData()
	return self.configBossList or {}
end

-- 刷新排行榜
function GuildBossModel:getRankData(bossID)
	-- dump(self.configBossList,"1111111111111111111111111")
	local sortedRankDatas = {}
	local selectedItemData = self.configBossList[tonumber(bossID)]
	if selectedItemData ~= nil then
		local damageData = selectedItemData.totalDamages
		if damageData and table.length(damageData)>0 then
			for k, v in pairs(damageData) do
				table.insert(sortedRankDatas, v)
			end
			table.sort(sortedRankDatas, function (a, b)
				return a.damage > b.damage
			end)
			-- for i,v in ipairs(sortedRankDatas) do
			-- 	v.rank = i
			-- end
			for k,v in pairs(sortedRankDatas) do
				v.rank = k
			end
		end
	end

	return sortedRankDatas
end




---获取开启时间  wk
function GuildBossModel:getEveryTime()
	local time = FuncGuildBoss.getGuildBossOpenTime()
	local str = " "
	for i=1,#time do
		-- local qian = tonumber(time[i][1])/3600
		-- local hou = tonumber(time[i][2])/3600
		local qian_h = math.floor(time[i][1]/3600)
		local qian_m = math.floor((time[i][1] - qian_h * 3600)/60)
		local hou_h = math.floor(time[i][2]/3600)
		local hou_m = math.floor((time[i][2]- hou_h * 3600)/60)

		-- echo("=====qian_h=======",time[i][1],time[i][2],qian_h,qian_m,hou_h,hou_m)
		if tonumber(qian_m) == 0 then
			qian_m = "00"
		end
		if tonumber(hou_m) == 0 then
			hou_m = "00"
		end

		local timestr = qian_h..":"..qian_m.." -"..hou_h..":"..hou_m
		if i == 1 then
  			str =  timestr
  		else
  			str = str..","..timestr
  		end

	end
	-- str = "每日<color = 00ff00>"..str.."<-> 开启"
	return str
end


---是否预约了wk
function GuildBossModel:yuYueIsOpen()
	-- self.bookingBossId
	-- self.bookingBossTime
	if self.bookingBossTime ~= nil then
		local serveTime = TimeControler:getServerTime()
		if serveTime < self.bookingBossTime then
			return true,self.bookingBossTime - serveTime
		end
	end
	return false
end

function GuildBossModel:getBossRankReward(bossID,_rank)
-- 排行
	local rankRewards = FuncGuildBoss.getRankRewardsById(bossID)
	local grade = 1
	local rank = _rank or 1
	if rank <= FuncGuildBoss.rankRange.THIRD then
		grade = rank
	else
		if rank >= FuncGuildBoss.rankRange.FORTH_LOWER and rank <= FuncGuildBoss.rankRange.FORTH_UPPER then
			grade = FuncGuildBoss.grade.FORTH						
		elseif rank >= FuncGuildBoss.rankRange.FIFTH_LOWER and rank <= FuncGuildBoss.rankRange.FIFTH_UPPER then
			grade = FuncGuildBoss.grade.FIFTH			
		elseif rank >= FuncGuildBoss.rankRange.SIXTH then
			grade = FuncGuildBoss.grade.SIXTH
		end
	end
	-- 排行奖励
	local currentRankReward = rankRewards[grade]
	return currentRankReward
end


--设置邀请列表的数据
function GuildBossModel:setInviteList(dataList)
	self.inviteDataList = nil
	-- if self.inviteDataList ~= nil then
	-- 	for k,v in pairs(self.inviteDataList) do
	-- 		for _k,_v in pairs(dataList) do
	-- 			if v.id == _k then
	-- 				v.guildBossCount = _v.guildBossCount
	-- 				v.logoutTime = _v.logoutTime
	-- 			end
	-- 		end
	-- 	end

	-- else
		self.inviteDataList = {}
		for k,v in pairs(dataList) do
			if k ~= UserModel:rid() then
				v.id = k
				table.insert(self.inviteDataList,v)
			end
		end
	-- end
end

-- -邀请设置时间CD
function GuildBossModel:setinviteListAppTime(playerId,_time)
	if self.inviteDataList ~= nil then
		local cdTime   =  60--FuncDataSetting.getDataByConstantName("GuildBossInviteCd") or 60
		for k,v in pairs(self.inviteDataList) do
			if playerId == v.id then
				if _time then
					v.appTime = cdTime + TimeControler:getServerTime()
				else
					v.appTime = nil 
				end
			end
		end
	end
end

function GuildBossModel:getInviteList()
	if self.inviteDataList then
		local onLine = {}
		local ofLine = {} 
		for k,v in pairs(self.inviteDataList) do
			if v.logoutTime == 0 then
				table.insert(onLine,v)  --在线的
			else
				table.insert(ofLine,v)  --离线的
			end
		end

		local sortFunc1 = function ( a,b )
			local data1 = GuildModel:getMemberInfo(a.id)
			local data2 = GuildModel:getMemberInfo(b.id)
        	if data1.ability > data2.ability then
        		return true
        	end
            return false
        end

        table.sort(onLine,sortFunc1)


        local  count = FuncGuildBoss.getBossAttackTimes()

        local sortFunc2 = function ( a,b )
        	if a.guildBossCount < count or  b.guildBossCount < count then
        		return true
        	else
        		return false
        	end
        end

        -- dump(ofLine,"333333333333333")
        -- table.sort(ofLine,sortFunc2)


        self.inviteDataList = {}
        for k,v in pairs(onLine) do
        	table.insert(self.inviteDataList,v)
        end
        for k,v in pairs(ofLine) do
        	table.insert(self.inviteDataList,v)
        end

	end
	return self.inviteDataList or {}
end

--[[
	local sortFunc = function ( a,b )
			local data1 = GuildModel:getMemberInfo(a.id)
			local data2 = GuildModel:getMemberInfo(b.id)
            if	data1.logoutTime < data2.logoutTime  then
            	if data1.ability > data2.ability then
            		return true
            	end
            	return true
            else
            	if a.guildBossCount < 2 or  b.guildBossCount < 2 then
            		return true
            	end
            end
            return false
        end

        table.sort(self.inviteDataList,sortFunc)
]]




--开始战斗
function GuildBossModel:startBattle(bossId)
	echo("==多人战斗的bossID==bossId=======",bossId)
	local function _callback(event)
		if event.result then
			dump(event.result,"共闯秘境 ，开始战斗返回=====")

		else

		end
	end
	local params = {}
	GuildBossServer:startBattle(params,_callback)
end

-- 开始战斗消息
function GuildBossModel:matchSucceed(event)
	if event.error == nil then
		dump(event.params," ===共闯秘境，开始战斗消息 =======")
		local battleLabel = event.params.params.data.battleLabel
		if  battleLabel == GameVars.battleLabels.guildBossGve then
			ServerRealTime:startConnect( event.params.params.data,c_func(self.onBattleStartForFormation,self)  )
		end
	end
end



function GuildBossModel:onBattleStartForFormation( event )
	echo("onBattleStartForFormation----")
	if not event.result then
		echoError("___战斗开始报错")
		-- EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_MATCH_FAILED_EVENT)
		return
	end
	-- 补发battleReady
	ServerRealTime:sendRequest({startIndex=0  } ,MethodCode.battle_battleReady,function(result)

		if result.result then
			local data = event.result.data

			--挑战扣次数
			-- self:setRemovechallengCount(1)

			-- 显示刷新
			-- EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_MATCH_SUCCEED_EVENT)
			
			self.battleId = data.battleId
			--这里需要开始修改流程
			--设置队友的数据  用于布阵中的显示
			if data.battleUsers[1].rid ~= UserModel:rid()  then
				self.guildBossMateInfo = data.battleUsers[1]
				self.guildBossSelfInfo = data.battleUsers[2]
			else
				self.guildBossSelfInfo = data.battleUsers[1]
				self.guildBossMateInfo = data.battleUsers[2]
			end
			
			local params = {}
			params[FuncTeamFormation.formation.guildBossGve] = {
				raidId = FuncGuildBoss.getLevelIdById(data.battleParams.guildBossInfo.bossId),
				groupId = data.battleParams.groupId,
				battleId = data.battleId
		 	}
			WindowControler:showWindow("WuXingTeamEmbattleView", FuncTeamFormation.formation.guildBossGve, params, false, false)
			EventControler:dispatchEvent(GuildBossEvent.CLOSE_INVITE_VIEW)
			if data.battleLabel == GameVars.battleLabels.guildBossGve then
		        -- 多人的时候开启语音
		        ChatShareControler:joinRealTimeRoom(data.battleId)
			end
		else
			echoError("___战斗准备报错")
		end
	end )
	-- 显示刷新
	-- EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_MATCH_SUCCEED_EVENT)
	--这里需要开始修改流程
	
	-- local serverData = data
	-- -- serverData.battleLabel = GameVars.battleLabels.crossPeakPvp
	-- local battleInfo = BattleControler:turnServerDataToBattleInfo(serverData)
	-- BattleControler:startBattleInfo(battleInfo);
end

function GuildBossModel:getGuildBossMateInfo()
	return self.guildBossMateInfo
end

function GuildBossModel:getGuildBossSelfInfo()
	return self.guildBossSelfInfo
end

function GuildBossModel:getGuildBossBattleId()
	return self.battleId
end

function GuildBossModel:onBattleStart(data)
	echo("onBattleStart----")
	local serverData = json.decode(data.info)
	local battleInfo = BattleControler:turnServerDataToBattleInfo(serverData.battleInfo)
	EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW, {onlyHideView = true})
	BattleControler:startBattleInfo(battleInfo);
	self:setRemovechallengCount(1)
end

return GuildBossModel