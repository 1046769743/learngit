-- GuildBossOpenView
--Author:      wk
--DateTime:    2018-02-28
--Description: 共闯秘境预约开启界面
--
local GuildBossOpenView = class("GuildBossOpenView", UIBase);

function GuildBossOpenView:ctor(winName)
    GuildBossOpenView.super.ctor(self, winName)
end

function GuildBossOpenView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()

	---不显示 叶签
	self.scroll_1:setVisible(false)
	-- ---不显示 spine
	self.ctn_ren:setVisible(false)
	-- --不显示 奖励
	self.panel_pp:setVisible(false)
	-- ---不显示预约按钮 不显示预约文字
	self.mc_anniu:setVisible(false)
	-- ---不显示开放时间
	-- self.panel_time:setVisible(false)
	--不显示叶签按钮
	self.mc_yeqiangx1:setVisible(false)

	self.frameCount = 0
	self.yeqianHuaBian = 0


	self:initData()

end 

function GuildBossOpenView:registerEvent()
	GuildBossOpenView.super.registerEvent(self)
	EventControler:addEventListener(GuildBossEvent.GUILDBOSS_CLOSE_OPEN_VIEW,self.closeButton, self)
	self.btn_back:setTouchedFunc(c_func(self.closeButton, self),nil,true);

end

function GuildBossOpenView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_1, UIAlignTypes.Right)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_pp, UIAlignTypes.MiddleBottom)

 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_jian1, UIAlignTypes.Right)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_jian2, UIAlignTypes.Right)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen, UIAlignTypes.LeftTop)

end

function GuildBossOpenView:touchedRuleBtn()
	-- WindowControler:showWindow("GuildBossRuleView")
	local pames = {
        title = "须臾仙境规则",
        tid = "#tid_unionlevel_rule_1",
    }

	WindowControler:showWindow("TreasureGuiZeView",pames)
end

function GuildBossOpenView:initData()
	---显示 叶签
	self.scroll_1:setVisible(true)
	-- ---显示 spine
	self.ctn_ren:setVisible(true)
	-- --显示 奖励
	self.panel_pp:setVisible(true)
	-- ---显示预约按钮 显示预约文字
	self.mc_anniu:setVisible(true)
	-- ---显示开放时间
	-- self.panel_time:setVisible(true)

	self:setEveryDayTime()

	self:newInitScrollCfg()

	self.btn_wen:setTouchedFunc(c_func(self.touchedRuleBtn, self))

	-- self.mc_anniu:getViewByFrame(2).rich_1:setVisible(false)
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTimeFrame, self), 0)
end






--显示设置每日时间
function GuildBossOpenView:setEveryDayTime()
	local rich_1 = self.panel_time.txt_1
	local str = GuildBossModel:getEveryTime()
	rich_1:setString(str)
end

--最右边 新的叶签滚动条
function GuildBossOpenView:newInitScrollCfg()
	self.bottomScrollList = self.scroll_1

	self.alldata = GuildBossModel:getUnlockListData() ---获取关卡的列表
	self.yuyueID = GuildBossModel:getBookingBossID()  --获取预约ID

	dump(self.alldata,"共闯秘境===获取关卡的列表")
	echo("=========self.yuyueID============",self.yuyueID)

	local function createCellFunc(itemBaseData)
        local itemView = UIBaseDef:cloneOneView(self.mc_yeqiangx1)        		
		self:updateCellView(itemView, itemBaseData)
		return itemView

    end

    local function reuseUpdateCellFunc(itemBaseData, itemView)
        self:updateCellView(itemView, itemBaseData)
    end

	local scrollParams = {
		{
			data = self.alldata,	        
	        createFunc = createCellFunc,
	        updateCellFunc = reuseUpdateCellFunc,
	        offsetX = 40,
	        offsetY = 20,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -90, width = 160, height = 90},
		}
	}
	self.bottomScrollList:styleFill(scrollParams)
	self.bottomScrollList:hideDragBar()
	self.infeedNum = self.yuyueID or 1
	echo("=========self.infeedNum===========",self.infeedNum)
	self.scroll_1:gotoTargetPos(tonumber(self.infeedNum),1,2)
	if tonumber(self.infeedNum) <= 3 then
		self.infeedNum = 3
	end
	-- self.maxBossID =  GuildBossModel:getMaxUnlockEctypeId()
	self.bottomScrollList:onScroll(c_func(self.qusetNowScrollType,self))
	self:setTwoButton()
	
end

function GuildBossOpenView:qusetNowScrollType(event)
	if event.name == "scrollEnd" then
		local groupIndex,posIndex =  self.bottomScrollList:getGroupPos(2)
		if not self.isMovingPartner then
			self.isMovingPartner = true
		else
			self.infeedNum = posIndex
			if self.infeedNum <= 3 then
				self.infeedNum = 3
			end
		end
	end	
end

--设置上下两个按钮
function GuildBossOpenView:setTwoButton()
    self.btn_jian1:setTouchedFunc(c_func(self.scrollMoveDown,self))

    self.btn_jian2:setTouchedFunc(c_func(self.scrollMoveUp,self))

end

--进度条滑动
function GuildBossOpenView:scrollMoveDown()
	self.infeedNum = self.infeedNum +1
	self.isMovingPartner = false
	 if self.infeedNum >= table.length(self.alldata) then
		self.infeedNum = table.length(self.alldata)
	end
    -- echo("=========self.infeedNum=====111===",self.infeedNum)
    self.scroll_1:gotoTargetPos(self.infeedNum,1,2,0.2)
end

function GuildBossOpenView:scrollMoveUp()
    
    self.isMovingPartner = false
   self.infeedNum = self.infeedNum - 1
	if self.infeedNum <= 3 then
		self.infeedNum = 4
	end

    -- echo("=========self.infeedNum=====2222===",self.infeedNum)
    self.scroll_1:gotoTargetPos(self.infeedNum,1,2,0.2)
end

---设置Cell
function GuildBossOpenView:updateCellView(itemView, itemBaseData)


	self.yeqianHuaBian = self.yeqianHuaBian + 1
	if self.yeqianHuaBian == 1 then
		itemView:getViewByFrame(1).panel_sheng:setVisible(false)
		itemView:getViewByFrame(2).panel_sheng:setVisible(false)
	end

	if itemBaseData.status == FuncGuildBoss.ectypeStatus.UNLOCK then
		itemView:getViewByFrame(1).panel_yeqiansuo:setVisible(false)
		itemView:getViewByFrame(2).panel_yeqiansuo:setVisible(false) 
	elseif itemBaseData.status == FuncGuildBoss.ectypeStatus.LOCK then
		itemView:getViewByFrame(1).panel_yeqiansuo:setVisible(true)
		itemView:getViewByFrame(2).panel_yeqiansuo:setVisible(true)
	else
		itemView:getViewByFrame(1).panel_yeqiansuo:setVisible(false)
		itemView:getViewByFrame(2).panel_yeqiansuo:setVisible(false)
	end



	local bossID = itemBaseData.id
	local bossName = FuncGuildBoss.getBossNameById(bossID)
	local nameStr = GameConfig.getLanguage(bossName)

	itemView:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString(nameStr)
	itemView:getViewByFrame(1).btn_1:getDownPanel().txt_1:setString(nameStr)
	itemView:getViewByFrame(2).btn_1:getUpPanel().txt_1:setString(nameStr)
	itemView:getViewByFrame(2).btn_1:getDownPanel().txt_1:setString(nameStr)

	itemView:showFrame(1)
	if self.yuyueID ~= nil then
		if tonumber(self.yuyueID) == tonumber(bossID) then
			itemView:showFrame(2)
			self:updataSpine(self.yuyueID)
			self:showReward(self.yuyueID)
		end
	else
		if tonumber(bossID) == 1 then
			itemView:showFrame(2)
			self:updataSpine(bossID)
			self:showReward(bossID)
		end
	end

	

	-- if itemBaseData.status  == FuncGuildBoss.ectypeStatus.LOCK then
		itemView:setTouchedFunc(c_func(self.selectBossIDCell, self, itemBaseData))
	-- elseif itemBaseData.status  == FuncGuildBoss.ectypeStatus.UNLOCK then
	-- 	itemView:setTouchedFunc(c_func(self.openNextBossID, self, itemBaseData))
	-- end
end

-- function GuildBossOpenView:openNextBossID(itemBaseData)
-- 	echo("=======通关前一章====方可预约开启====")
-- end

function GuildBossOpenView:selectBossIDCell(itemBaseData)
	local boosID = itemBaseData.id
	if self.selectBossID == boosID then
		return 
	end
	dump(itemBaseData,"控件数据 ======")
	self:updataSpine(boosID)
	self:showReward(boosID)
	local alldata = self.alldata
	for k,v in pairs(alldata) do
		local _cell = self.bottomScrollList:getViewByData(v);
		if _cell ~= nil then
			if v.id == boosID then
				_cell:showFrame(2)
			else
				_cell:showFrame(1)
			end
		end
	end


end

--设置预约按钮
function GuildBossOpenView:setYuYueButton(bossID)
	-- self.yuyueID = GuildBossModel:getBookingBossID()  --获取预约ID
	echo("====self.yuyueID=========",self.yuyueID,bossID)

	self.mc_anniu:setVisible(true)

	-- local isboss = GuildModel:judgmentIsForZBoos()
	local guildBossOpen = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"guildBossOpen")
	if guildBossOpen == 1 then
	-- echo("======isboss=========",isboss)
		local isYuYue,times = GuildBossModel:yuYueIsOpen()  ---是否预约了
		self.mc_anniu:setVisible(false)
		echo("========isYuYue=========",isYuYue)
		if self.yuyueID ~= nil then
			if isYuYue then
				self.mc_anniu:showFrame(2)
				self.mc_anniu:setVisible(true)
				if tonumber(self.yuyueID) == tonumber(bossID) then
					self:yuyueDaya(times)
				else
					self.mc_anniu:setVisible(true)
					local str = GameConfig.getLanguage("#tid_guildBossOpen_006")
					local name = FuncGuildBoss.getBossNameById(self.yuyueID)
					_text  = string.gsub(str, "#1", GameConfig.getLanguage(name))
					self.mc_anniu:getViewByFrame(2).rich_1:setString(_text)
				end
			end
		end
		return 
	end

	if self.yuyueID ~= nil then
		if tonumber(self.yuyueID) == tonumber(bossID) then

			local isYuYue,times = GuildBossModel:yuYueIsOpen()  ---是否预约了
			echo("=====预约按钮===isYuYue======",isYuYue)
			if isYuYue then
				self.mc_anniu:setVisible(true)
				self.mc_anniu:showFrame(2)
				self:yuyueDaya(times)
			else
				local guildBoss = GuildBossModel.baseBossData.guildBoss
				self.mc_anniu:setVisible(true)
				self.mc_anniu:showFrame(1)
				self.mc_anniu:getViewByFrame(1).btn_jiaozi:setTouchedFunc(c_func(self.sendYuYueToServe, self, bossID))
				if guildBoss.dead ~= nil then
					if guildBoss.dead == 0 then
						self.mc_anniu:setVisible(false)
					end
				end
				
			end
		else
			local isYuYue ,times = GuildBossModel:yuYueIsOpen()  ---是否预约了
			if isYuYue then
				self.mc_anniu:showFrame(2)
				local str = GameConfig.getLanguage("#tid_guildBossOpen_006")
				local name = FuncGuildBoss.getBossNameById(self.yuyueID)
				_text  = string.gsub(str, "#1", GameConfig.getLanguage(name))
				self.mc_anniu:getViewByFrame(2).rich_1:setString(_text)
				if tonumber(bossID) > tonumber(self.yuyueID) then
					if self.alldata[tonumber(bossID)] ~= nil then
						if self.alldata[tonumber(bossID)].status == FuncGuildBoss.ectypeStatus.LOCK then
							local str = GameConfig.getLanguage("#tid_guildBossOpen_004")
							self.mc_anniu:getViewByFrame(2).rich_1:setString(str)
						end
					end
				end
			else
				if self.alldata[tonumber(bossID)].status == FuncGuildBoss.ectypeStatus.LOCK then
					self.mc_anniu:showFrame(2)
					local str = GameConfig.getLanguage("#tid_guildBossOpen_004")
					self.mc_anniu:getViewByFrame(2).rich_1:setString(str)
				else
					if tonumber(bossID) > tonumber(self.yuyueID) then
						self.mc_anniu:showFrame(1)
						self.mc_anniu:getViewByFrame(1).btn_jiaozi:setTouchedFunc(c_func(self.sendYuYueToServe, self, bossID))
					else
						self.mc_anniu:setVisible(false)
					end
				end
			end
		end
	else
		local maxID = GuildBossModel:getMaxUnlockEctypeId()
		echo("======maxID========",maxID,bossID)
		self.mc_anniu:setVisible(true)
		if tonumber(bossID) > tonumber(maxID) then
			self.mc_anniu:showFrame(2)
			local str = GameConfig.getLanguage("#tid_guildBossOpen_004")
			self.mc_anniu:getViewByFrame(2).rich_1:setString(str)
		else
			local serverTime = TimeControler:getServerTime()
			local guildBoss  = GuildBossModel.baseBossData.guildBoss 

			dump(guildBoss,"11111111111")
			echo("======maxID========",maxID,bossID,guildBoss)
			if guildBoss ~= nil  then

				-- if guildBoss.expireTime ~= nil then
					--if serverTime < guildBoss.expireTime then
				if table.length(guildBoss) ~= 0 then
					if guildBoss.dead == 0 then
						self.mc_anniu:setVisible(false)
					else
						self.mc_anniu:setVisible(true)
					end
				else
					self.mc_anniu:setVisible(true)
				end
			end
			self.mc_anniu:showFrame(1)
			self.mc_anniu:getViewByFrame(1).btn_jiaozi:setTouchedFunc(c_func(self.sendYuYueToServe, self, bossID))
		end
	end





	--[[
	if tonumber(self.yuyueID) == tonumber(bossID) then
		local hppercent = FuncGuildBoss.calculateHp( self.alldata[tonumber(bossID)] )
		if hppercent and hppercent <= 100 then
			local guildBoss  = GuildBossModel.baseBossData.guildBoss 
			if guildBoss ~= nil  and table.length(guildBoss) ~= 0  then 
				self.mc_anniu:setVisible(false)
			else
				self.mc_anniu:setVisible(true)
			end
		end
	else
		self.mc_anniu:setVisible(true)
		if tonumber(bossID) ~= tonumber(1) then
			-- self:unscheduleUpdate()
			self.mc_anniu:showFrame(2)
			local str = GameConfig.getLanguage("#tid_guildBossOpen_004")
			self.mc_anniu:getViewByFrame(2).rich_1:setString(str)
			return 
		end
	end

	local isYuYue,times = GuildBossModel:yuYueIsOpen()  ---是否预约了
	if isYuYue then
		if tonumber(self.yuyueID) == tonumber(bossID) then
			self.mc_anniu:showFrame(2)
			self:yuyueDaya(times)
		else
	else
		self.mc_anniu:showFrame(1)
		self.mc_anniu:getViewByFrame(1).btn_jiaozi:setTouchedFunc(c_func(self.sendYuYueToServe, self, bossID))
	end
	]]
end

function GuildBossOpenView:yuyueDaya(times)
	if times < 0 then
		times = 0
	end
	times = TimeControler:turnTimeSec(times, TimeControler.timeType_hhmmss)
	local pames = {[1] = times}
	local miaoshu = "#tid_guildBossOpen_003"
	local str = GameConfig.getLanguageWithSwap(miaoshu,unpack(pames))
	self.mc_anniu:getViewByFrame(2).rich_1:setString(str)

end
	
function GuildBossOpenView:updateTimeFrame()
	if self.selectBossID == self.yuyueID then
		if GuildBossModel.bookingBossTime ~= nil then
			if  self.frameCount % GameVars.GAMEFRAMERATE == 0 then
				local times = GuildBossModel.bookingBossTime - TimeControler:getServerTime()
				if times <= 0 then
				-- 	return
				-- elseif times == 0 then
					--TODO   跳转到开启界面
					self:clickButtonBack()
					GuildControler:showGuildBossUI()
					return 	
				end
				times = TimeControler:turnTimeSec(times, TimeControler.timeType_hhmmss)
				local pames = {[1] = times}
				local miaoshu = "#tid_guildBossOpen_003" --GameConfig.getLanguage("#tid_guildBossOpen_003")
				local str = GameConfig.getLanguageWithSwap(miaoshu,unpack(pames))

				self.mc_anniu:getViewByFrame(2).rich_1:setString(str)
			end
		else
			if  self.frameCount % GameVars.GAMEFRAMERATE == 0 then
				local serveTime = TimeControler:getServerTime()
				local isonTime = FuncGuildBoss.isOnTime(serveTime)
				-- echo("==========serveTime=========", TimeControler:turnTimeSec(serveTime, TimeControler.timeType_hhmmss))
				if isonTime then
					self:clickButtonBack()
					GuildControler:showGuildBossUI()
					return 
				end
			end
		end
	else
		if  self.frameCount % GameVars.GAMEFRAMERATE == 0 then
			local serveTime = TimeControler:getServerTime()
			local isonTime = FuncGuildBoss.isOnTime(serveTime)
			if isonTime then
				self:clickButtonBack()
				GuildControler:showGuildBossUI()
				return 
			end
		end
	end
	self.frameCount = self.frameCount + 1
end




function GuildBossOpenView:sendYuYueToServe(bossID)

	local function callBack( serverData )
		if serverData.error then
			if serverData.error.code == 620303 then
				echo("=======预约请求返回错误=====")
				WindowControler:showTips( GameConfig.getLanguage("#tid_guildBossOpen_002"))
			end
		else
			local openingEctypeData = serverData.result.data
			dump(openingEctypeData, "发送预约请求返回的数据===")
			GuildBossModel:updateData(openingEctypeData)
			WindowControler:showTips( GameConfig.getLanguage("#tid_guildBossOpen_001"))
			self.yuyueID = openingEctypeData.dateBossId
			self:setYuYueButton(bossID)
		end

		EventControler:dispatchEvent(GuildEvent.GUILD_ACTIVITY_REDPOINT_CHANGED,{sysType = "guildBoss" }) 
		-- 发送仙盟频道通知
		-- local bossConfigData = FuncGuildBoss.getBossDataById(bossID)
		-- local ectypeName = FuncTranslate._getLanguage(bossConfigData.name)
		-- local tips = GameConfig.getLanguageWithSwap("#tid_unionlevel_talk_1", UserModel:name(),ectypeName)
		-- tips = tips.."_link"
		-- local  param={};  
		-- param.content = tips 
		-- param.type = 1
		-- ChatServer:sendLeagueMessage(param);

	end
	GuildBossServer:openOneEctype(bossID,callBack)
end


--显示奖励UI  BOSSID   diifID
function GuildBossOpenView:showReward(bossID)
	local panel = self.panel_pp
	panel.panel_baog1:setVisible(false)
	local alldata = FuncGuildBoss.getBossReward(bossID)

	local function createCellFunc(itemBaseData)
        local itemView = UIBaseDef:cloneOneView(panel.panel_baog1)        		
		self:updateItemView(itemView, itemBaseData)
		return itemView

    end

    local function reuseUpdateCellFunc(itemBaseData, itemView)
        self:updateItemView(itemView, itemBaseData)
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
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -80, width = 80, height = 80},
		}
	}
	panel.scroll_1:styleFill(scrollParams)
	panel.scroll_1:hideDragBar()
	panel.scroll_1:setCanScroll( false )
	self.selectBossID = bossID


end

---获取奖励UICell
function GuildBossOpenView:updateItemView(itemView, itemData)
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
function GuildBossOpenView:updataSpine(bossID)
	self:setYuYueButton(bossID)
	-- echo("========bossID====",bossID)
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



function GuildBossOpenView:closeButton()
	self:startHide()
end

function GuildBossOpenView:clickButtonBack()
	-- self:startHide()
	self:unscheduleUpdate()
end

function GuildBossOpenView:deleteMe()
	GuildBossOpenView.super.deleteMe(self);
end

return GuildBossOpenView;


