--
--Author:      zhuguangyuan
--DateTime:    2018-01-18 10:12:23
--Description: 仙盟副本主界面
--


local GuildBossMainView = class("GuildBossMainView", UIBase);

function GuildBossMainView:ctor(winName)
    GuildBossMainView.super.ctor(self, winName)
end

function GuildBossMainView:loadUIComplete()
	self:setViewVisible(false)
	-- self:registerEvent()
	self:initViewAlign()
	local function initDataCallBack()
		self:setViewVisible(true)
		self:initData()
		self:initView()
		GuildBossModel.hasInitData = false
	end
	GuildBossModel:enterGuildBossMainView(initDataCallBack,GuildBossModel.hasInitData)
end 

function GuildBossMainView:setViewVisible(visible)
	local arr = self._root:getChildren()
	for k, v in pairs(arr) do
		v:setVisible(visible)
	end
end

function GuildBossMainView:registerEvent()
	GuildBossMainView.super.registerEvent(self)
	self.UI_1.btn_1:setTouchedFunc(c_func(self.close, self))
	self.btn_wen:setTouchedFunc(c_func(self.touchedRuleBtn, self))

	-- 底层仙盟boss数据发生变动
	EventControler:addEventListener(GuildBossEvent.GUILDBOSS_DATA_UPDATE, self.updateBossRelatedStatus, self)
	EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.joinBattle, self)
	EventControler:addEventListener(GuildBossEvent.GUILDBOSS_ONE_ECTYPE_PASS, self.onOneEctypePass, self)

	EventControler:addEventListener(GuildBossEvent.GUILDBOSS_TIMER_RESET_DAY_COUNT, self.resetOpenTimes, self)
	EventControler:addEventListener(GuildBossEvent.GUILDBOSS_TIMER_ECTYPE_TIME_OUT, self.oneEctypeTimeOut, self)

	-- 一个副本开启了 刷新界面
	EventControler:addEventListener(GuildBossEvent.GUILDBOSS_ONE_ECTYPE_OPEN, self.onOneEctypeOpen, self)
end

function GuildBossMainView:updateBossRelatedStatus(event)
	-- dump(event.params, "底层仙盟boss数据发生变动 发来的消息的参数")
	-- self:updateUI()
end

function GuildBossMainView:touchedRuleBtn()
	-- WindowControler:showWindow("GuildBossRuleView")

	local pames = {
        title = "须臾仙境规则",
        tid = "#tid_unionlevel_rule_1",
    }

	WindowControler:showWindow("TreasureGuiZeView",pames)
end

function GuildBossMainView:onOneEctypePass( event )
	echo("_______收到顺利过关消息_____________")
	local ectypeId = event.params.ectypeId
	self.allEctypeDataList = GuildBossModel:getAllUnlockEctypes(true)
	-- if not self.selectedEctypeId then
		self.selectedEctypeId = GuildBossModel:getMaxUnlockEctypeId() 
	-- end

	local function _callBack()
		self:doSelectOneEctype( self.selectedEctypeId )
	end
	self:initScrollCfg(c_func(_callBack))
end

-- 跨天重置 可以开启副本的次数
function GuildBossMainView:resetOpenTimes( event )
	-- local data = self.allEctypeDataList[tonumber(self.selectedEctypeId)]
	-- if data and data.status ~= FuncGuildBoss.ectypeStatus.BATTLEING then 

	-- end

	-- echo("__________ 收到model的消息 跨天重置 可以开启副本的次数_____________")
	-- self.battlingEctypeExpireTime = false
	-- self.allEctypeDataList = GuildBossModel:getAllUnlockEctypes(false)
	-- if not self.selectedEctypeId then
	-- 	self.selectedEctypeId = GuildBossModel:getOpeningEctypeId() or GuildBossModel:getMaxUnlockEctypeId()
	-- end

	-- local function _callBack()
	-- 	self:doSelectOneEctype( self.selectedEctypeId )
	-- end
	-- self:initScrollCfg(c_func(_callBack))
end

-- 一个副本的时间到了
function GuildBossMainView:oneEctypeTimeOut( event )
	echo("__________ 收到model的消息 一个副本的时间到了 _____________")
	self.battlingEctypeExpireTime = false
	self.allEctypeDataList = GuildBossModel:getAllUnlockEctypes(false)
	if not self.selectedEctypeId then
		self.selectedEctypeId = GuildBossModel:getMaxUnlockEctypeId()
	end
	-- self.bottomScrollList:refreshScroll(1)
	-- self:doSelectOneEctype( self.selectedEctypeId )

	local function _callBack()
		self:doSelectOneEctype( self.selectedEctypeId )
	end
	self:initScrollCfg(c_func(_callBack))
end

function GuildBossMainView:onOneEctypeOpen( event )

	self.allEctypeDataList = GuildBossModel:getAllUnlockEctypes(false)
	-- dump(self.allEctypeDataList, "开启副本 底层处理之后发送消息 view 重新获取底层数据")
	-- if not self.selectedEctypeId then
		self.selectedEctypeId = GuildBossModel:getOpeningEctypeId() 
	-- end
	-- self.bottomScrollList:refreshScroll(1)
	-- self:doSelectOneEctype( self.selectedEctypeId )
	local function _callBack()
		self:doSelectOneEctype( self.selectedEctypeId )
	end
	self:initScrollCfg(c_func(_callBack))
	self.frameCount = 0
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self), 0)

		-- WindowControler:showTips( { text = "秘境已成功开启" })

		-- -- 发送仙盟频道通知
		-- local bossConfigData = FuncGuildBoss.getBossDataById(_ectypeId)
		-- local ectypeName = FuncTranslate._getLanguage(bossConfigData.name)
		-- local tips = GameConfig.getLanguageWithSwap("#tid_unionlevel_talk_1", UserModel:name(),ectypeName)
		-- tips = tips.."_link"
		-- local  param={};  
		-- param.content = tips 
		-- param.type = 1
		-- ChatServer:sendLeagueMessage(param);

		-- -- 刷新界面
		-- self.allEctypeDataList = GuildBossModel:getAllUnlockEctypes(true)
		-- self.bottomScrollList:refreshScroll(1)
		-- self:doSelectOneEctype( self.selectedEctypeId )
		-- local function _callBack()
		-- 	self:doSelectOneEctype( self.selectedEctypeId )
		-- end
		-- self:initScrollCfg(c_func(_callBack))

		-- self:updateUI(true)

	-- local function _callBack()
	-- 	self:doSelectOneEctype( self.selectedEctypeId )
	-- end
	-- self:initScrollCfg(c_func(_callBack))
end

-- =======================================================================================
-- 初始化数据
-- =======================================================================================
function GuildBossMainView:initData()
	self.challengeTimesLimit = FuncDataSetting.getDataByConstantName("GuildBossAttackTimes") or 2
	self.openTimesLimit = FuncDataSetting.getDataByConstantName("GuildBossOpenNum") or 2
	-- 所有的已经解锁的副本数据
	self.allEctypeDataList = GuildBossModel:getAllUnlockEctypes(false)
	dump(self.allEctypeDataList, "所有的已经解锁的副本数据  ====")

	-- 默认选中的副本id
	self.maxUnlockEctypeId = GuildBossModel:getMaxUnlockEctypeId() --GuildBossModel:getmaxUnlockEctypeId()
	self.selectedEctypeId = GuildBossModel:getOpeningEctypeId() -- or self.maxUnlockEctypeId or 1
	if not self.selectedEctypeId then
		self.selectedEctypeId = self.maxUnlockEctypeId
	end
	echo("______ 初始化数据时 self.selectedEctypeId _____________",self.selectedEctypeId)

	-- 默认选中的标签
	self.tagType = {
        TAG_XIANG_QING = 1,      
        TAG_PAI_HANG = 2,       
    }
    self.selectedTag = nil
end


function GuildBossMainView:onBattleExitResume(cacheData )
    dump(cacheData,"战斗恢复view GuildBossMainView")
    GuildBossMainView.super.onBattleExitResume(cacheData)
    self.tagType = {
        TAG_XIANG_QING = 1,      
        TAG_PAI_HANG = 2,       
    }
    self:updateTagUI(self.tagType.TAG_PAI_HANG)
    if (not self.battlingEctypeExpireTime)
    	or (self.battlingEctypeExpireTime - TimeControler:getServerTime() < 0) 
    then
		TimeControler:removeOneCd( GuildBossModel.eventNameOneEctype )
		-- EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_TIMER_ECTYPE_TIME_OUT,{})
		GuildBossModel:oneEctypeTimeOut()
		return
	end
end

function GuildBossMainView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guildBoss_003")) 
	self.panel_res:visible(false)
	self.btn_back:visible(false)
	self.totalPanel = self.mc_xx:getViewByFrame(1)
	self.monsterPanel = self.totalPanel.mc_6ge
	self.detailPanel = self.totalPanel.panel_xinxi
	self.ertypePanel = self.totalPanel.panel_latiao

	local function _callBack()
		self:doSelectOneEctype( self.selectedEctypeId )
	end
	self:initScrollCfg(c_func(_callBack))

	self.frameCount = 0
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self), 0)

	-- 注册页签点击函数
	self.panel_yeqian.mc_yeqian1:setTouchedFunc(c_func(self.updateTagUI, self, self.tagType.TAG_XIANG_QING))
	self.panel_yeqian.mc_yeqian2:setTouchedFunc(c_func(self.updateTagUI, self, self.tagType.TAG_PAI_HANG))
	self:updateTagUI(self.tagType.TAG_XIANG_QING)
end



---[[  ---旧的仙盟BOSS  下部滚动条
-- 初始化底部滚动条
function GuildBossMainView:initScrollCfg(_callBack)
	if not self.ertypePanel then
		return 
	end
	self.ertypePanel.panel_1:setVisible(false)
	self.bottomScrollList = self.ertypePanel.scroll_1
	self.bottomScrollList:setOnCreateCompFunc( _callBack )

	local function createCellFunc(itemBaseData)
        local itemView = UIBaseDef:cloneOneView(self.ertypePanel.panel_1)        		
		self:updateOneItemView(itemView, itemBaseData)
		return itemView
    end

    local function reuseUpdateCellFunc(itemBaseData, itemView)
        self:updateOneItemView(itemView, itemBaseData)
        return itemView
    end

	self.scrollParams = {
		{
			data = self.allEctypeDataList,	        
	        createFunc = createCellFunc,
	        -- updateCellFunc = reuseUpdateCellFunc,
	        offsetX = 8,
	        offsetY = -125,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -6, width = 230, height = 133},
		}
	}
	if not self.mapIdToScrollData then
		self.mapIdToScrollData = {}
	end
	if not self.mapIdToScrollView then
		self.mapIdToScrollView = {}
	end
	if self.allEctypeDataList then
		self.bottomScrollList:styleFill(self.scrollParams)
	end
	self.bottomScrollList:hideDragBar()
end


--]]

function GuildBossMainView:updateScrollView()
	self.bottomScrollList:refreshScroll(1)
end

-- 更新底层滚动条的一个小框(副本)
function GuildBossMainView:updateOneItemView( itemView, itemBaseData )
	itemView.panel_eye:setVisible(false)
	itemView.panel_zhan:setVisible(false)
	itemView.panel_suo:setVisible(false)

	itemView.panel_yjs:setVisible(false)
	itemView.panel_kq:setVisible(false)

	local bossConfigData = FuncGuildBoss.getBossDataById(itemBaseData.id)
	local name = FuncTranslate._getLanguage(bossConfigData.name)
	itemView.txt_name:setString(name)

	if itemBaseData.status == FuncGuildBoss.ectypeStatus.BATTLEING then		
		self.battleingItemView = itemView
		self.battleingItemData = itemBaseData
		self.battlingEctypeExpireTime = itemBaseData.expireTime
		itemView.panel_zhan:setVisible(true)

		--根据得到的血量和总血量去计算
	    local percent = self:calculateHp( itemBaseData )
		itemView.panel_progress:visible(true)
		itemView.panel_progress.progress_1:setPercent(percent)
		itemView.panel_progress.txt_1:setString(percent.."%")

		local timeStr = TimeControler:turnTimeSec(itemBaseData.expireTime - TimeControler:getServerTime(), TimeControler.timeType_dhhmmss)
		itemView.txt_time:visible(true)
		itemView.txt_time:setString(timeStr)
	else
		itemView.txt_time:visible(false)
		itemView.panel_progress:visible(false)
		if itemBaseData.status == FuncGuildBoss.ectypeStatus.UNLOCK then
			local max = GuildBossModel:getMaxUnlockEctypeId()
			if tostring(itemBaseData.id) == tostring(max) and not GuildBossModel:getOpeningEctypeId() then
				itemView.panel_kq:setVisible(true)
			else
				itemView.panel_yjs:setVisible(true)
			end
		elseif itemBaseData.status == FuncGuildBoss.ectypeStatus.LOCK then
			itemView.panel_suo:setVisible(true)
		end
	end

	-- 选中框状态
	if tostring(itemBaseData.id) == tostring(self.selectedEctypeId) then
        itemView.panel_xuan:setVisible(true)
        self:doSelectOneEctype( self.selectedEctypeId )
    else
        itemView.panel_xuan:setVisible(false)
    end

	itemView:setTouchedFunc(c_func(self.doSelectOneEctype, self, itemBaseData.id))
end


-- =======================================================================================
-- 刷新选中不同副本时的界面
-- =======================================================================================
-- 选不同副本 
function GuildBossMainView:doSelectOneEctype( _ectypeId )
	echo("_______!!!!!! 刷新选中副本________________",_ectypeId)
    local selectedEctypeData = self.allEctypeDataList[tonumber(self.selectedEctypeId)]
    local selectedEctypeView = self.bottomScrollList:getViewByData(selectedEctypeData)
	if selectedEctypeView then
		selectedEctypeView.panel_xuan:setVisible(false)
	end
	self.selectedEctypeId = _ectypeId

    selectedEctypeData = self.allEctypeDataList[tonumber(self.selectedEctypeId)]
    if not selectedEctypeData then
    	echoError("没有找到选中的副本,",_ectypeId,#self.allEctypeDataList)
    	return
    end
    selectedEctypeView = self.bottomScrollList:getViewByData(selectedEctypeData)
	if selectedEctypeView then
		selectedEctypeView.panel_xuan:setVisible(true)
	end

	-- 选中的副本缓动到最左边
	self.bottomScrollList:gotoTargetPos(tonumber(self.selectedEctypeId),1,0,0.3)

	-- 更新页签
	if selectedEctypeData.status == FuncGuildBoss.ectypeStatus.BATTLEING then
		self.detailPanel.txt_tp:visible(true)
		self.detailPanel.txt_dtime:visible(true)
		self.detailPanel.panel_hp:visible(true)
		local timeStr = TimeControler:turnTimeSec(selectedEctypeData.expireTime - TimeControler:getServerTime(), TimeControler.timeType_dhhmmss)
		self.detailPanel.txt_dtime:setString(timeStr)
		local percent = self:calculateHp(selectedEctypeData)
		self.detailPanel.panel_hp.progress_jindu:setPercent(percent)
		self.detailPanel.panel_hp.txt_1:setString(percent.."%")

		self.panel_yeqian["mc_yeqian"..self.tagType.TAG_PAI_HANG]:visible(true)
		if self.selectedTag == self.tagType.TAG_XIANG_QING then
			self:updateDetailUI()
		else
			self:updateRankingListUI()
		end
	else
		self.detailPanel.txt_tp:visible(false)
		self.detailPanel.txt_dtime:visible(false)
		self.detailPanel.panel_hp:visible(false)

		self.panel_yeqian["mc_yeqian"..self.tagType.TAG_PAI_HANG]:visible(false)
		self.detailPanel.mc_nr:showFrame(1)
		self:updateDetailUI(self.tagType.TAG_XIANG_QING)
	end

	-- 更新挑战按钮 怪 血量和倒计时
	self:updateBattleBtn(selectedEctypeData)
	self:updateMonsterUI(selectedEctypeData)
	-- 更新副本名
	local bossConfigData = FuncGuildBoss.getBossDataById(self.selectedEctypeId)
	local ectypeName = FuncTranslate._getLanguage(bossConfigData.name)
	self.detailPanel.txt_name:setString(ectypeName)
end

-- 更新战按钮
function GuildBossMainView:updateBattleBtn(_selectedEctypeData)
	-- dump(_selectedEctypeData, "_selectedEctypeData")
	echo("__________更新战按钮_______________")
	-- 选中的是已经开启的副本
	local openingId = GuildBossModel:getOpeningEctypeId()
	if tonumber(openingId) == tonumber(self.selectedEctypeId) then
		self.detailPanel.mc_ccc:showFrame(1)
		local currentView = self.detailPanel.mc_ccc:getCurFrameView()
		local battleBtn = currentView.btn_1

		local leftChallengeTimes = GuildBossModel:getLeftChallengeTimes(UserModel:rid()) --self:getLeftChallengeTimes( _selectedEctypeData, )
		currentView.txt_cz2:setString(leftChallengeTimes.."/"..self.challengeTimesLimit)
 		if leftChallengeTimes > 0 then
			battleBtn:setTap(c_func(self.enterTeamFormationView, self, self.selectedEctypeId))
 		else
 			local function showClickTips( ... ) 
 				WindowControler:showTips( GameConfig.getLanguage("#tid_guildBoss_004"))
 			end
 			battleBtn:setTap(c_func(showClickTips))
 		end
	else
		self.detailPanel.mc_ccc:showFrame(2)
		local currentView = self.detailPanel.mc_ccc:getCurFrameView()
		-- 选中副本为未解锁副本
		if _selectedEctypeData.status == FuncGuildBoss.ectypeStatus.LOCK then
			currentView.mc_1:showFrame(1)
			local txt = currentView.mc_1:getCurFrameView().txt_1
			txt:setString(GameConfig.getLanguage("#tid_guildBoss_005")) 
		-- 选中副本为待开启副本
		elseif _selectedEctypeData.status == FuncGuildBoss.ectypeStatus.UNLOCK then
			-- 盟主或者副盟主可以开启副本
			
			local guildBossOpen = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"guildBossOpen")
			if guildBossOpen == 1 then
				currentView.mc_1:showFrame(2)
				local openBtn = currentView.mc_1:getCurFrameView().btn_1
				if not GuildBossModel:getOpeningEctypeId() then
					FilterTools.clearFilter(openBtn)
					local openleftTimes = GuildBossModel:getOpenleftTimes()
					if openleftTimes > 0 then
						openBtn:setTap(c_func(self.openOneEctype,self,self.selectedEctypeId))
					else
						local function _callBack( ... )
							WindowControler:showTips( GameConfig.getLanguage("#tid_guildBoss_006"))
						end
						openBtn:setTap(c_func(_callBack))
					end
				else
					openBtn:visible(false)
				end
			else
				currentView.mc_1:showFrame(1) 
				local txt = currentView.mc_1:getCurFrameView().txt_1
				txt:setString(GameConfig.getLanguage("#tid_guildBoss_007"))
			end
		end
	end
end

-- 发送开启副本请求
function GuildBossMainView:openOneEctype( _ectypeId )
	if self.havedSentRequest then
		return
	end	
	if GuildBossModel:getOpeningEctypeId() then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guildBoss_008"))
		return 
	end
	local function callBack( serverData )
		if serverData.error then
			return
		end
		-- local openingEctypeData = serverData.result.data
		-- dump(openingEctypeData, "发送开启请求返回的数据")
		-- GuildBossModel:updateData(openingEctypeData,false) 
		WindowControler:showTips( GameConfig.getLanguage("#tid_guildBoss_009"))

		-- 发送仙盟频道通知
		local bossConfigData = FuncGuildBoss.getBossDataById(_ectypeId)
		local ectypeName = FuncTranslate._getLanguage(bossConfigData.name)
		local tips = GameConfig.getLanguageWithSwap("#tid_unionlevel_talk_1", UserModel:name(),ectypeName)
		tips = tips.."_link"
		local  param={};  
		param.content = tips 
		param.type = 1
		ChatServer:sendLeagueMessage(param);

		-- -- 刷新界面
		-- self.allEctypeDataList = GuildBossModel:getAllUnlockEctypes(true)
		-- self.bottomScrollList:refreshScroll(1)
		-- self:doSelectOneEctype( self.selectedEctypeId )
		-- local function _callBack()
		-- 	self:doSelectOneEctype( self.selectedEctypeId )
		-- end
		-- self:initScrollCfg(c_func(_callBack))

		-- -- self:updateUI(true)
		self.havedSentRequest = false
	end
	GuildBossServer:openOneEctype(_ectypeId,callBack)
	self.havedSentRequest = true
end

-- 进入布阵界面
function GuildBossMainView:enterTeamFormationView(_params)
	local params = {}
	params[FuncTeamFormation.formation.guildBoss] = {
		
 	}
 	WindowControler:showWindow("WuXingTeamEmbattleView", FuncTeamFormation.formation.guildBoss, params)
end

-- 发送打副本请求
function GuildBossMainView:joinBattle(event)
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
		        EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
		        BattleControler:startBattleInfo(battleInfoData)
        	end       
		end
	end
	if event.params.systemId == FuncTeamFormation.formation.guildBoss then
		GuildBossServer:attackGuildBoss(event.params.formation,_callBack)
	end
end

-- 更细怪spine界面
function GuildBossMainView:updateMonsterUI(_selectedEctypeData)
	local bossConfigData = FuncGuildBoss.getBossDataById(_selectedEctypeData.id)
	local bossSpineIds = bossConfigData.spineId

	if table.length(bossSpineIds) == 1 then
		self.monsterPanel:showFrame(1)
		self.monsterPanel.currentView.panel_ren.ctn_1:removeAllChildren()
		local spineArr = string.split(bossSpineIds[1],",")
		local sourceCfg = FuncTreasure.getSourceDataById(spineArr[1])
		local spineName = sourceCfg.spine
		local bossView = ViewSpine.new(spineName, {}, spineName):addto(self.monsterPanel.currentView.panel_ren.ctn_1)
		if spineArr[2] then
			bossView:setScale(tonumber(spineArr[2]))
		end
		bossView:playLabel("stand", true)
	else
		self.monsterPanel:showFrame(2)
		for i = 1, 6 do
			self.monsterPanel.currentView.panel_ren["panel_ren"..i].ctn_1:removeAllChildren()
		end
		for i,v in ipairs(bossSpineIds) do
			-- self.monsterPanel.currentView.panel_ren["panel_ren"..i].ctn_1:removeAllChildren()
			local spineArr = string.split(v,",")
			local sourceCfg = FuncTreasure.getSourceDataById(spineArr[1])
			local spineName = sourceCfg.spine
			local bossView = ViewSpine.new(spineName, {}, spineName):addto(self.monsterPanel.currentView.panel_ren["panel_ren"..i].ctn_1)
			if spineArr[2] then
				bossView:setScale(tonumber(spineArr[2]))
			end
			bossView:playLabel("stand", true)
		end
	end

	local richtext = self.totalPanel.panel_hz.mc_1.currentView.rich_1
	if _selectedEctypeData.status == FuncGuildBoss.ectypeStatus.BATTLEING then
		richtext:setString(_selectedEctypeData.openerName..GameConfig.getLanguage("#tid_guildBoss_011"))
	else
		richtext:setString(GameConfig.getLanguage("#tid_guildBoss_012")) 
	end
end


--控件UI适配
function GuildBossMainView:initViewAlign()

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan, UIAlignTypes.RightTop)
  --  	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.Right)
  --  	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
  --  	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuo, UIAlignTypes.Left)
  --  	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zongpower, UIAlignTypes.Right)

  --  	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuo.mc_btn, UIAlignTypes.Right)
  --  	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_fen, UIAlignTypes.Left)
  --  	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_chou, UIAlignTypes.Left)



end

-- 临界点刷新所有界面
function GuildBossMainView:updateUI()
end


-- =======================================================================================
-- 刷新页签相关界面
-- =======================================================================================
-- 刷新页签选中界面
function GuildBossMainView:updateTagUI(_tagType)
	if _tagType and (_tagType ~= self.selectedTag) then

		if self.selectedTag then
			self.panel_yeqian["mc_yeqian"..self.selectedTag]:showFrame(1)
		end
		self.selectedTag = _tagType
		self.panel_yeqian["mc_yeqian"..self.selectedTag]:showFrame(2)
	end
	if self.selectedTag == self.tagType.TAG_XIANG_QING then
		self:updateDetailUI()
	else
		self:updateRankingListUI()
	end
end

-- 刷新详情界面
function GuildBossMainView:updateDetailUI()
	self.detailPanel.mc_nr:showFrame(1)
	local currentView = self.detailPanel.mc_nr:getCurFrameView()

	local bossConfigData = FuncGuildBoss.getBossDataById(self.selectedEctypeId)
	local numOfRankReward = table.length(bossConfigData.rankReward1)
	local numOfJoinReward = table.length(bossConfigData.battleReward)
	currentView.mc_l1:showFrame(numOfRankReward)
	currentView.mc_l2:showFrame(numOfJoinReward)
	for i = 1,2 do
		local panelView = currentView["mc_l"..i]:getCurFrameView()
		local UIName = "UI_"
		local rewardNum = numOfRankReward
		local reward_table = bossConfigData.rankReward1
		if i==2 then
			UIName = "UI_s"
			reward_table = bossConfigData.battleReward
			rewardNum = numOfJoinReward
		end
		for i = 1, rewardNum do
			local reward = string.split(reward_table[i], ",")
			local rewardType1 = reward[1]
			local rewardNum1 = reward[3]
			local rewardId1 = reward[2]
			local commonUI = panelView[UIName..i]
			commonUI:setResItemData({reward = reward_table[i]})
			commonUI:showResItemName(false)
			commonUI:showResItemRedPoint(false)
			
	        FuncCommUI.regesitShowResView(commonUI,rewardType1, rewardNum1, rewardId1, reward_table[i], true, true)
	        if UIName == "UI_s" then
	        	commonUI:showResItemNum(true)
	        else
	        	commonUI:showResItemNum(false)
	        end
		end
	end
end

-- 刷新排行榜
function GuildBossMainView:updateRankingListUI()
	local selectedItemData = self.allEctypeDataList[tonumber(self.selectedEctypeId)]
	local damageData = selectedItemData.totalDamages
	if damageData and table.length(damageData)>0 then
		self.detailPanel.mc_nr:showFrame(2)
		local currentView = self.detailPanel.mc_nr:getCurFrameView()

		local sortedRankDatas = {}
		for k, v in pairs(damageData) do
			table.insert(sortedRankDatas, v)
		end
		table.sort(sortedRankDatas, function (a, b)
			return a.damage > b.damage
		end)
		for i,v in ipairs(sortedRankDatas) do
			v.rank = i
		end
		self:updateRankScrollView(self.selectedEctypeId, sortedRankDatas,currentView)
	else
		self.detailPanel.mc_nr:showFrame(3)
	end
end
-- 更新排行榜滚动条
function GuildBossMainView:updateRankScrollView(_ectypeId, _sortedRankDatas,_rankView)
	local rankDatas = _sortedRankDatas
	local _rankItemView = _rankView.panel_2
	_rankView.panel_2:setVisible(false)
	local _rankScroll = _rankView.scroll_1

	local createCellFunc = function (_rankData)
        local view = UIBaseDef:cloneOneView(_rankItemView)        
		self:updateRankCellView(view, _rankData, _ectypeId)
		return view
    end

    local reuseUpdateCellFunc = function (_rankData, view)
        self:updateRankCellView(view, _rankData, _ectypeId)
        return view;  
    end

	local _rankParmas = {
		{
			data = rankDatas,	        
	        createFunc = createCellFunc,
	        offsetX = 0,
	        offsetY = -12,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -48, width = 512, height = 58},
	        updateCellFunc = reuseUpdateCellFunc,
		}
	}
	_rankScroll:styleFill(_rankParmas)
	_rankScroll:refreshCellView(1)
	_rankScroll:hideDragBar()
end
-- 展示一个排行item
function GuildBossMainView:updateRankCellView(_rankItemView, _rankData, _ectypeId)
	-- 伤害
	local damage = _rankData.damage
	if #(tostring(damage)) > 8 then
		damage = math.floor(damage / 10000).." 万"
	end
	-- 玩家名字
	local name = _rankData.name
	if name == "" then
		name = "少侠"
	end
	if tostring(_rankData.rid) == tostring(UserModel:rid()) then
		_rankItemView.rich_name:setString("<color = c52a00>"..name.."<->")
		_rankItemView.rich_pm:setString("<color = c52a00>"..damage.."<->")
	else
		_rankItemView.rich_name:setString("<color = 7d563c>"..name.."<->")
		_rankItemView.rich_pm:setString("<color = 0d8a0d>"..damage.."<->")
	end
	
	-- 排行
	local rankRewards = FuncGuildBoss.getRankRewardsById(_ectypeId)
	local grade = 1
	local count = 1
	local rank = _rankData.rank
	if rank <= FuncGuildBoss.rankRange.THIRD then
		_rankItemView.mc_num:showFrame(rank)
		count = table.length(rankRewards[rank])
		_rankItemView.mc_xx:showFrame(count)
		grade = rank
	else
		_rankItemView.mc_num:showFrame(4)
		_rankItemView.mc_num.currentView.txt_1:setString(tostring(rank))
		if rank >= FuncGuildBoss.rankRange.FORTH_LOWER and rank <= FuncGuildBoss.rankRange.FORTH_UPPER then
			grade = FuncGuildBoss.grade.FORTH						
		elseif rank >= FuncGuildBoss.rankRange.FIFTH_LOWER and rank <= FuncGuildBoss.rankRange.FIFTH_UPPER then
			grade = FuncGuildBoss.grade.FIFTH			
		elseif rank >= FuncGuildBoss.rankRange.SIXTH then
			grade = FuncGuildBoss.grade.SIXTH
		end
	end

	-- 排行奖励
	_rankItemView.mc_xx:setVisible(true)
	local currentRankReward = rankRewards[grade]
	count = table.length(currentRankReward)
	_rankItemView.mc_xx:showFrame(count)
	for i = 1, count do
		local reward = string.split(currentRankReward[i], ",")
		local rewardType = reward[1]
		local rewardNum = reward[table.length(reward)]
		local rewardId = reward[table.length(reward) - 1]

		local commonUI = _rankItemView.mc_xx.currentView["UI_" .. tostring(i)]
		commonUI:setResItemData({reward = currentRankReward[i]})
		commonUI:showResItemName(false)
		commonUI:showResItemRedPoint(false)
        FuncCommUI.regesitShowResView(commonUI,
            rewardType, rewardNum, rewardId, currentRankReward[i], true, true)
	end
end


-- =======================================================================================
-- 刷新倒计时和血量相关界面
-- =======================================================================================
-- 更新倒计时和血量
-- 隔一段时间拉取一下服务器数据
function GuildBossMainView:updateFrame()
	-- 没有开启中的副本则不刷
	if (not self.battlingEctypeExpireTime) then
		return 
	end
	if (self.battlingEctypeExpireTime - TimeControler:getServerTime() < 0) then
		self:unscheduleUpdate()
		TimeControler:removeOneCd( GuildBossModel.eventNameOneEctype )
		EventControler:dispatchEvent(GuildBossEvent.GUILDBOSS_TIMER_ECTYPE_TIME_OUT,{})
		GuildBossModel:oneEctypeTimeOut()
		return
	end

	-- 每10秒更新血量和排行
    if self.frameCount % (GameVars.GAMEFRAMERATE * 20) == 0 then
    	self.allEctypeDataList = GuildBossModel:getAllUnlockEctypes(true)
    end
	-- 每秒更新时间
    if self.frameCount % GameVars.GAMEFRAMERATE == 0 then
    	local timeStr = TimeControler:turnTimeSec(self.battleingItemData.expireTime - TimeControler:getServerTime(), TimeControler.timeType_dhhmmss)
		local battlingId = GuildBossModel:getOpeningEctypeId()
		if not battlingId then
			self:unscheduleUpdate()
			return
		end
    	local percent = self:calculateHp( self.allEctypeDataList[tonumber(battlingId)] )

    	-- 更新时间
    	if GuildBossModel:getOpeningEctypeId() == self.selectedEctypeId then
			self.detailPanel.txt_tp:visible(true)
			self.detailPanel.txt_dtime:visible(true)
			self.detailPanel.txt_dtime:setString(timeStr)

			self.detailPanel.panel_hp:visible(true)
			self.detailPanel.panel_hp.progress_jindu:setPercent(percent)
			self.detailPanel.panel_hp.txt_1:setString(percent.."%")
			self:updateTagUI()

    	else
			self.detailPanel.txt_tp:visible(false)
			self.detailPanel.txt_dtime:visible(false)
			self.detailPanel.panel_hp:visible(false)
    	end

    	if not self.battleingItemView then	
			self.battleingItemView = self.bottomScrollList:getViewByData(self.battleingItemData)
		end
		if self.battleingItemView then
			self.battleingItemView.txt_time:setString(timeStr)
			self.battleingItemView.panel_progress.progress_1:setPercent(percent)
			self.battleingItemView.panel_progress.txt_1:setString(percent.."%")
		end
    end
    self.frameCount = self.frameCount + 1
end

-- 计算血量
function GuildBossMainView:calculateHp( _itemBaseData )
	if _itemBaseData.status ~= FuncGuildBoss.ectypeStatus.BATTLEING then
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
	-- echo("___当前上海量____ curDamage __________",curDamage)
	local currentHp = totalHp - curDamage
	local percent = tonumber(string.format("%0.1f", tostring(currentHp * 100 / totalHp))) --math.ceil(currentHp * 100 / totalHp)
	return percent
end

function GuildBossMainView:close()
	self:startHide()
end

function GuildBossMainView:deleteMe()
	GuildBossMainView.super.deleteMe(self);
end

return GuildBossMainView;


