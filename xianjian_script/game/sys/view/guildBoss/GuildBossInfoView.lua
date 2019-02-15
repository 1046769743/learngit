-- GuildBossInfoView
--Author:      wk
--DateTime:    2018-02-28
--Description: 共闯秘境详情界面
--
local GuildBossInfoView = class("GuildBossInfoView", UIBase);

function GuildBossInfoView:ctor(winName)
    GuildBossInfoView.super.ctor(self, winName)
end

function GuildBossInfoView:loadUIComplete()
	
	

	---不显示 叶签
	self.panel_grd:setVisible(false)
	-- ---不显示 spine
	self.ctn_ren:setVisible(false)
	-- --不显示 奖励
	self.panel_pp:setVisible(false)
	-- ---不显示开放时间
	-- self.panel_time:setVisible(false)

	self.panel_grd.txt_1:setVisible(false)


	self.frameCount = 0




	

	local function initDataCallBack()
		self:setViewAlign()
		self:registerEvent()
		self:initData()
	end
	GuildBossModel:enterGuildBossMainView(initDataCallBack,GuildBossModel.hasInitData)

end 

function GuildBossInfoView:registerEvent()
	GuildBossInfoView.super.registerEvent(self)
	EventControler:addEventListener(GuildBossEvent.GUILDBOSS_REFRESH_BOSS_HP,self.refreshRightData, self)
	
	self:delayCall(function()
		EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_CLOSE_OPEN_VIEW)
	end,0.5)
	

	self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	self.btn_guize:setTouchedFunc(c_func(self.touchedRuleBtn, self))
end

function GuildBossInfoView:touchedRuleBtn()
	-- WindowControler:showWindow("GuildBossRuleView")
	local pames = {
        title = "须臾仙境规则",
        tid = "#tid_unionlevel_rule_1",
    }

	WindowControler:showWindow("TreasureGuiZeView",pames)
end

function GuildBossInfoView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_grd, UIAlignTypes.Right)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop)
 	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_pp, UIAlignTypes.LeftBottom)
end



-- -- 发送打副本请求
-- function GuildBossInfoView:joinBattle(event)
-- 	local function _callBack( serverData )
-- 		if serverData.error then
-- 			if serverData.error.code == 620501 then
-- 				WindowControler:showTips( GameConfig.getLanguage("#tid_guildBoss_010"))
-- 			end
-- 		else
-- 			-- dump(serverData.result, "发送挑战boss  返回的数据")
--         	if serverData.result.data then
-- 	        	local battleInfoData = serverData.result.data.battleInfo
-- 	        	battleInfoData.battleLabel = GameVars.battleLabels.guildBossPve
-- 		        local battleInfoData = BattleControler:turnServerDataToBattleInfo(battleInfoData)
-- 		        EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
-- 		        BattleControler:startBattleInfo(battleInfoData)
--         	end       
-- 		end
-- 	end
-- 	GuildBossServer:attackGuildBoss(event.params.formation,_callBack)
-- end


function GuildBossInfoView:initData()

	
	---不显示 叶签
	self.panel_grd:setVisible(true)
	-- ---不显示 spine
	self.ctn_ren:setVisible(true)
	-- --不显示 奖励
	self.panel_pp:setVisible(true)
	-- ---不显示开放时间
	-- self.panel_time:setVisible(true)

	-- self.bossID = GuildBossModel:getBookingBossID()  --获取 预约BossID


	self.killBossId = GuildBossModel.baseBossData.guildBossMaxPassId
	if self.killBossId == 0 then
		self.killBossId = nil
	end

	self.bossID =  GuildBossModel:getOpeningEctypeId() or GuildBossModel:getMaxUnlockEctypeId()


	-- local guildid = GuildBossModel:getOpeningEctypeId()
	echo("====22=self.bossID===1111======",self.bossID)
	-- if guildid ~= nil then
		-- if tonumber(guildid) == tonumber(self.killBossId) then
			-- echoError("====11=self.bossID===1111======",self.bossID,self.killBossId,GuildBossModel:getMaxUnlockEctypeId())
			-- self.bossID = GuildBossModel:getMaxUnlockEctypeId()
		-- end

	-- end
	-- echoError("=====self.bossID===1111======",self.bossID,self.killBossId,GuildBossModel:getMaxUnlockEctypeId())
	


	-- echoError("=====self.bossID=========",self.bossID)


	self:scheduleUpdateWithPriorityLua(c_func(self.timeUpdataFrame, self), 0)

	-- self:setEveryDayTime()
	self:updataSpine()
	self:showReward()

	self:refreshRightData()


end

function GuildBossInfoView:refreshRightData()
	self.bossID =  GuildBossModel:getOpeningEctypeId()
	self:setRankData()
	-- self:timeUpdataFrame()
	self:setrankListData()
	self:setChallengCount()
	self:setButton()
end

 
--设置参战次数
function GuildBossInfoView:setChallengCount()
	local chalCount = GuildBossModel:getLeftChallengeTimes(UserModel:rid())
	local sumcount = FuncGuildBoss.getBossAttackTimes()
	local text = self.panel_grd.panel_txt.txt_2
	text:setString(chalCount.."/"..sumcount)
	if tonumber(chalCount) <= 0  then
		text:setColor(cc.c3b(255,0, 0))
	else
		text:setColor(cc.c3b(0,255, 0))
	end
end

function GuildBossInfoView:setButton()
	local count = GuildBossModel:getLeftChallengeTimes(UserModel:rid())
	local isshow = false
	self.panel_grd.btn_2:setTouchedFunc(c_func(self.startBatter, self))
	if count > 0 then
		isshow = true
	end
	self.panel_grd.btn_2:getUpPanel().panel_red:visible(isshow)
end


--开战
function GuildBossInfoView:startBatter()
	local leftChallengeTimes = GuildBossModel:getLeftChallengeTimes(UserModel:rid()) --self:getLeftChallengeTimes( _selectedEctypeData, )
	-- echo("========leftChallengeTimes=======",leftChallengeTimes)
	if leftChallengeTimes > 0 then
		self:gotoGuildBossInviteView()
		-- self:enterTeamFormationView()
	else
		WindowControler:showTips( GameConfig.getLanguage("#tid_guildBoss_004"))
	end

end

-- -- 进入布阵界面  
-- function GuildBossInfoView:enterTeamFormationView(_params)
-- 	local params = {}
-- 	params[FuncTeamFormation.formation.guildBoss] = {
-- 		raidId = FuncGuildBoss.getLevelIdById(self.bossID),
--  	}
--  	WindowControler:showWindow("WuXingTeamEmbattleView", FuncTeamFormation.formation.guildBoss, params)
-- end

---创建房间
function GuildBossInfoView:gotoGuildBossInviteView()
	local function _callback( event )
		if event.result then
			dump(event.result,"========创建房间返回数据========")
			local dataList = event.result.data.inviteList
			GuildBossModel:setInviteList(dataList)
			WindowControler:showWindow("GuildBossInviteView",self.bossID,true)
		else

		end
	end

	
	local params = {}
	GuildBossServer:createGuildBossTeam(params,_callback)
end






--设置排行数据
function GuildBossInfoView:setRankData()
	self.bossID =  GuildBossModel:getOpeningEctypeId() or GuildBossModel:getMaxUnlockEctypeId()
	local top_panel = self.panel_grd.panel_1
	-- echo("=======self.bossIDself.bossIDself.bossID========",self.bossID)
	local bossName  =  FuncGuildBoss.getBossNameById(self.bossID)--BOSS名字
	top_panel.txt_1:setString(GameConfig.getLanguage(bossName))
	local _itemBaseData = GuildBossModel:getUnlockListData()
	local battlingId = GuildBossModel:getOpeningEctypeId()
	-- dump(_itemBaseData,"22222222222222222")
	-- echo("battlingId=====",battlingId)
	local percent = self:calculateHp( _itemBaseData[tonumber(battlingId)])
	-- echo("======percent=======",percent)
	if percent ~= nil then
		top_panel.panel_1.txt_1:setString(percent.."%")
		top_panel.panel_1.progress_1:setPercent(percent)
		if percent <= 0 then
			top_panel.panel_1:setVisible(false)

			self.panel_grd.btn_2:setVisible(false)
			self.panel_grd.panel_txt:setVisible(false)
			self.panel_grd.txt_1:setVisible(true)
			-- self.panel_grd.panel_1.txt_2:setVisible(false)
			-- self.panel_grd.panel_1.txt_3:setVisible(false)
		end
	end
end

-- 计算血量
function GuildBossInfoView:calculateHp( _itemBaseData )

	-- dump(_itemBaseData,"33333333333333333333")
	if _itemBaseData == nil then
		return
	end
	if (_itemBaseData ~= nil) and (_itemBaseData.status ~= FuncGuildBoss.ectypeStatus.BATTLEING) then
		return 
	end
	-- 副本总血量等于关卡中的怪物的总血量
	local totalHp, curDamage = 0,0
	local levelId = FuncGuildBoss.getLevelIdById(_itemBaseData.id)
	local enemyIds = FuncGuildBoss.getEnemyIdByLevelId(levelId)
	
	for i, v in ipairs(enemyIds) do
		if v ~= "" then
			
			local oneEnemyHp = FuncGuildBoss.getBossHpById(v, _itemBaseData.id)
			totalHp = totalHp + tonumber(oneEnemyHp)
		end
	end
	-- echo("__总血量_____totalHp__________",totalHp)

	-- 当前伤害量
	local curDamage = 0
	if _itemBaseData.bossHp ~= nil and _itemBaseData.bossHp ~= {} then
		for k,v in pairs(_itemBaseData.bossHp) do
			local id_table = string.split(k, "_")
			-- 由于多人参战,服务器返回的血量可能会溢出(超出总血量),
			-- 此处做最低限定,防止显示异常
			local upperHp = FuncGuildBoss.getBossHpById(id_table[1], _itemBaseData.id)
			if tonumber(upperHp) < tonumber(v) then
				v = upperHp
			end
			curDamage = curDamage + tonumber(v)
		end
	end
	
	local currentHp = totalHp - curDamage
	--echo("___当前上海量____ curDamage __________",totalHp,curDamage,currentHp * 100 / totalHp,string.format("%0.2f", tostring(currentHp * 100 / totalHp)))
	local percent = tonumber(string.format("%0.2f", tostring(currentHp * 100 / totalHp))) --math.ceil(currentHp * 100 / totalHp)
	return percent
end

--时间倒计时
function GuildBossInfoView:timeUpdataFrame()
	local guildBoss = GuildBossModel.baseBossData.guildBoss
	local bookingBossTime = GuildBossModel.baseBossData.guildBoss.expireTime
	if bookingBossTime ~= nil then
		-- if guildBoss.expireTime ~= nil then
			local time = bookingBossTime  - TimeControler:getServerTime()
			-- if time > 3600 then
			-- 	bookingBossTime = bookingBossTime 
				time = bookingBossTime  - TimeControler:getServerTime()
			-- end
			-- echo("========11111==========",bookingBossTime,TimeControler:getServerTime(),time)
			if time > 0 then
				local timeStr = TimeControler:turnTimeSec(time, TimeControler.timeType_dhhmmss)
				-- self.panel_grd.panel_1.txt_3:setVisible(true)
				-- self.panel_grd.panel_1.txt_3:setString(timeStr)
			elseif time <= 0 then
				EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_REFRESH_BOSS_RED)
				
				local Windownames =  WindowControler:getWindow( "WuXingTeamEmbattleView" )
		        if Windownames == nil then
		            WindowControler:showTips(GameConfig.getLanguage("#tid_guildBossOpen_005"))
		        end
				
				self:clickButtonBack()
			end
		-- end
	else
		-- self.panel_grd.panel_1.txt_3:setVisible(false)
	end
end

--排行滚动条数据
function GuildBossInfoView:setrankListData()
	local rankData =  GuildBossModel:getRankData(self.bossID) --排行榜数据

	-- dump(rankData,"=======排行滚动条数据======")
	-- echo("==========self.bossID11111=========",self.bossID)
	local panel = self.panel_grd
	local function createCellFunc(itemBaseData)
        local itemView = UIBaseDef:cloneOneView(panel.panel_3)        		
			self:updateRankPlayerView(itemView, itemBaseData)
		return itemView

    end

    local function reuseUpdateCellFunc(itemBaseData, itemView)
        self:updateRankPlayerView(itemView, itemBaseData)
    end

	local scrollParams = {
		{
			data = rankData,	        
	        createFunc = createCellFunc,
	        updateCellFunc = reuseUpdateCellFunc,
	        offsetX = 3,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 0,
	        perNum = 1,
	        itemRect = {x = 0, y = -50, width = 415, height = 50},
		}
	}


	panel.scroll_1:styleFill(scrollParams)
	panel.scroll_1:hideDragBar()
	local cellview = panel.panel_3


	if rankData ~= nil and table.length(rankData) ~= 0 then
		local myselfData = nil 
		for k,v in pairs(rankData) do
			if v.rid == UserModel:rid() then
				myselfData = v
			end
		end
		if myselfData ~= nil then
			self:cellInitData(cellview,myselfData,true)
		else
			cellview:setVisible(false)
		end
	else
		cellview:setVisible(false)
	end
end

function GuildBossInfoView:updateRankPlayerView(itemView, itemBaseData)
	if itemBaseData.rid == UserModel:rid() then
		itemView.panel_ziji:setVisible(true)
	else
		itemView.panel_ziji:setVisible(false)
	end
	self:cellInitData(itemView,itemBaseData)
end


function GuildBossInfoView:cellInitData(cellview,data,file)
	if file then
		-- cellview.panel_ziji:setVisible(true)
	else
		cellview.panel_ziji:setVisible(false)
	end

	local itemView = cellview
	local ranknum = data.rank
	if ranknum <= 3 then
		itemView.mc_1:showFrame(ranknum)
	else
		itemView.mc_1:showFrame(4)
		itemView.mc_1:getViewByFrame(4).mc_1:getViewByFrame(1).txt_1:setString(ranknum)
	end
	local name = data.name
	local total = data.damage
	itemView.mc_x:getViewByFrame(1).txt_1:setString(name)
	itemView.mc_x:getViewByFrame(1).txt_2:setString(total)


	local reward = GuildBossModel:getBossRankReward(self.bossID,ranknum)  ---奖励数据

	-- dump(reward,"========奖励数据=====")
	itemView.UI_1:setVisible(false)
	local function createCellFunc(itemBaseData)
        local cellView = UIBaseDef:cloneOneView(itemView.UI_1)        		
		self:rewardCellView(cellView, itemBaseData)
		return cellView

    end

    local function reuseUpdateCellFunc(itemBaseData, cellView)
        self:rewardCellView(cellView, itemBaseData)
    end

	local scrollParams = {
		{
			data = reward,	        
	        createFunc = createCellFunc,
	        updateCellFunc = reuseUpdateCellFunc,
	        offsetX = 30,
	        offsetY = 5,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 0,
	        perNum = 1,
	        itemRect = {x = 0, y = -20, width = 40, height = 20},
		}
	}

	itemView.scroll_1:styleFill(scrollParams)
	itemView.scroll_1:hideDragBar()
	itemView.scroll_1:setCanScroll( false )
end

function GuildBossInfoView:rewardCellView( cellView, itemBaseData )

	local reward = itemBaseData 
	cellView:setResItemData({reward = reward})
	cellView:showResItemName(false)
	cellView:showResItemRedPoint(false)
	cellView:showResItemNum(false)

end










--显示设置每日时间
function GuildBossInfoView:setEveryDayTime()
	local rich_1 = self.panel_time.rich_1
	local str = GuildBossModel:getEveryTime()
	rich_1:setString(str)
end





--显示奖励UI  BOSSID   diifID
function GuildBossInfoView:showReward()
	local bossID = self.bossID
	local panel = self.panel_pp
	panel.panel_baog1:setVisible(false)
	local alldata = FuncGuildBoss.getBossReward(bossID)

	local function createCellFunc(itemBaseData)
        local itemView = UIBaseDef:cloneOneView(panel.panel_baog1)        		
		self:updateRankRewardView(itemView, itemBaseData)
		return itemView

    end

    local function reuseUpdateCellFunc(itemBaseData, itemView)
        self:updateRankRewardView(itemView, itemBaseData)
    end

	local scrollParams = {
		{
			data = alldata,	        
	        createFunc = createCellFunc,
	        updateCellFunc = reuseUpdateCellFunc,
	        offsetX = -48,
	        offsetY = 10,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 0,
	        perNum = 1,
	        itemRect = {x = 0, y = -80, width = 80, height = 80},
		}
	}
	panel.scroll_1:styleFill(scrollParams)
	panel.scroll_1:hideDragBar()
	panel.scroll_1:setCanScroll( false )

end

---获取奖励UICell
function GuildBossInfoView:updateRankRewardView(itemView, itemData)
	local frame = itemData._type
	local reward = itemData.reward
	itemView.UI_1:setResItemData({reward = reward})
	itemView.mc_wd:showFrame(frame)
	itemView.UI_1:showResItemName(false)
	itemView.UI_1:showResItemRedPoint(false)
	itemView.UI_1:showResItemNum(false)
	local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(reward)
    FuncCommUI.regesitShowResView(itemView, resType, needNum, resId,reward,true,true)
end



-- 更新BOSSspine界面
function GuildBossInfoView:updataSpine()
	local bossID = self.bossID
	echo("========bossID====",bossID)
	local bossConfigData = FuncGuildBoss.getBossDataById(bossID)
	local bossSpineIds = bossConfigData.spineId
	local ctn_ren = self.ctn_ren
	ctn_ren:removeAllChildren()
	local spineArr = string.split(bossSpineIds[1],",")
	local sourceCfg = FuncTreasure.getSourceDataById(spineArr[1])
	local spineName = sourceCfg.spine
	local bossView = ViewSpine.new(spineName, {}, spineName):addto(ctn_ren)
	bossView:setScale(1.4)
	bossView:playLabel("stand", true)
end











function GuildBossInfoView:clickButtonBack()
	self:startHide()
end

function GuildBossInfoView:deleteMe()
	GuildBossInfoView.super.deleteMe(self);
end

return GuildBossInfoView;


