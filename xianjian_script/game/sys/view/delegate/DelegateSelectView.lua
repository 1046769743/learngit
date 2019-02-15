--[[
	Author: lichaoye
	Date: 2017-05-26
	挂机选人界面-view
]]
-- 5.21 pangkangning四测新版本大改，原先的已经不能使用

local DelegateSelectView = class("DelegateSelectView", UIBase)

function DelegateSelectView:ctor( winName,taskData)
	DelegateSelectView.super.ctor(self, winName)
	self.__data = taskData
	self._inTeam = {} -- 在队列中的人
end

function DelegateSelectView:registerEvent()
	DelegateSelectView.super.registerEvent(self)
	EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))

    self.panel_1.btn_2:setTap(c_func(self.paiQianInfoClick, self))
    self.UI_1.mc_1:visible(false)
end

function DelegateSelectView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateTypeUI()
	self:updateUI()
end

-- 适配
function DelegateSelectView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2.scroll_1,UIAlignTypes.Middle,1,1)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2.scale9_1,UIAlignTypes.Middle,1,1)
end
function DelegateSelectView:updateTypeUI( )
	if self.__data.taskType == FuncDelegate.Type_Special then
		self._isSpecial = true
		self.panel_1.txt_4:visible(false)
		self.panel_1.mc_5:visible(false)
		self.panel_1.txt_3:visible(false)
		self.panel_1.mc_3:visible(false)
		-- 初始化奇侠头像
		local p = self.__data.specialAppointPartner
		for i=1,2 do
			local view = self.panel_1["panel_pai"..i]
			if i <= #p then
				self:updateHeadIcon(view, {id=p[i]})
				view.UI_head.panel_lv:visible(false)
			else
				view:visible(false)
			end
		end
	else
		self._isSpecial = false
		self.panel_1.txt_pai:visible(false)
		for i=1,2 do
			self.panel_1["panel_pai"..i]:visible(false)
		end
	end
end

function DelegateSelectView:updateUI()
	self.panel_2:visible(false)
	self.panel_7:visible(false)
	-- dump(self.__data,"s===")
	-- 标题
	self.UI_1.txt_1:setString(GameConfig.getLanguage(self.__data.taskName))
	-- 委托按钮
	local status = DelegateModel:getCurTaskStatus(self.__data.id)
	if status == DelegateModel.TASK_STATUS.WAIT then
		self.panel_1.mc_weituoanniu:showFrame(1)
		local tmpView = self.panel_1.mc_weituoanniu.currentView
		tmpView.btn_1:setTap(c_func(self.yijianpaiqianClieck, self)) -- 一键派遣
		tmpView.btn_2:setTap(c_func(self.paiqianClieck, self)) -- 确定
		self:checkIsEngoch()
		-- 奇侠显示与否
		local count = 0
		if self._isSpecial then
			count = #self.__data.specialAppointPartner
		else
			count = self.__data.partnerNum
		end
		-- 根据推荐奇侠显示头像的个数
		for i=1,5 do
			local view = self.panel_1["panel_jia"..i]
			view:visible(false)
			if i <= count then
				view:visible(true)
				view.UI_head:visible(false)
				if not view._init then
					view:setTouchedFunc(c_func(self.headClick,self,view))
					view._init = true
				end
			end
		end
		self:updateList()
    elseif status == DelegateModel.TASK_STATUS.INHAND then --未完成
		self.panel_1.mc_weituoanniu:showFrame(2)
		local tmpView = self.panel_1.mc_weituoanniu.currentView
		if not tmpView.btn_1._init then
			tmpView.btn_1:setTap(c_func(self.zhaohuiClieck, self)) -- 召回
			tmpView.btn_2:setTap(c_func(self.jiasuClieck, self)) -- 加速
			tmpView.btn_1._init = true
		end
		self:updatePaiQian()
		-- 更新倒计时
		self:updateWaitTime()
    elseif status == DelegateModel.TASK_STATUS.FINISH then --可领取
		self.panel_1.mc_weituoanniu:showFrame(3)
		local tmpView = self.panel_1.mc_weituoanniu.currentView
		if not tmpView.btn_1._init then
			tmpView.btn_1:setTap(c_func(self.lingquClieck, self)) -- 领取奖励
			tmpView.btn_1._init = true
		end
		self:updatePaiQian()
    end
    -- 更新奖励
    local count = 0
	if self._isSpecial then
		count = #self.__data.specialReward
	else
		count = #self.__data.baseReward
	end
    if count < 0 then
    	echoError ("配置委托奖励错误---",self.__data.id)
    	return
    end
    if count > 3 then
    	count = 3
    	echoError ("配置委托奖励超过3个---",self.__data.id)
    end
    self.panel_1.mc_2:showFrame(count)
    for i=1,count do
    	local data = nil
		if self._isSpecial then
			data = self.__data.specialReward[i]
		else
			data = self.__data.baseReward[i]
		end
    	local itemView = self.panel_1.mc_2.currentView["UI_"..i]
		itemView:setResItemData({reward = data})
		itemView:showResItemName(false)
        local needNum, hasNum, isEnough, resType, resId = UserModel:getResInfo(data)
        FuncCommUI.regesitShowResView(itemView, resType, needNum, resId,data, true, true)
        itemView:setTouchSwallowEnabled(true)
    end
    -- 奇侠经验
    self.panel_1.txt_jy:setString(self.__data.expReward)
    if self._isSpecial then
    	self.panel_1.mc_3:visible(false)
    	return
    end
    -- 额外奖励
    local eCount = #self.__data.extraReward
    if eCount > 3 then
    	eCount = 3
    	echoError ("配置委托额外奖励超过3个---",self.__data.id)
    end
    self.panel_1.mc_3:showFrame(eCount)
    for i=1,eCount do
    	local data = self.__data.extraReward[i]
    	local itemView = self.panel_1.mc_3.currentView["UI_"..i]
		itemView:setResItemData({reward = data})
		itemView:showResItemName(false)
        local needNum, hasNum, isEnough, resType, resId = UserModel:getResInfo(data)
        FuncCommUI.regesitShowResView(itemView, resType, needNum, resId,data, true, true)
        itemView:setTouchSwallowEnabled(true)
    end
    -- 需求战力
    self:updateAbility(status)
end
-- 更新派遣的奇侠
function DelegateSelectView:updatePaiQian( )
	-- 更新派遣的奇侠
	local partners = DelegateModel:getWorkingPartner(self.__data.id)
	-- 根据推荐奇侠显示头像的个数
	for i=1,5 do
		local view = self.panel_1["panel_jia"..i]
		if i <= #partners then
			view:visible(true)
			view.UI_head:visible(true)
			self:updateHeadIcon(view,partners[i])
		else
			view:visible(false)
		end
	end
end
function DelegateSelectView:updateWaitTime( )
	local tmpView = self.panel_1.mc_weituoanniu.currentView
	local cTime = DelegateModel:getCurFinishTime(tostring(self.__data.id)) - TimeControler:getServerTime()
	if cTime > 0 then
        local str = TimeControler:turnTimeSec( cTime, TimeControler.timeType_dhhmmss )
		tmpView.txt_2:setString(str)
		-- 更新按钮上的消耗仙玉
		local costStr = FuncDelegate.getSpeedUpCast(cTime)
		tmpView.btn_2:getUpPanel().txt_2:setString(costStr)
        self:delayCall(function( )
            self:updateWaitTime()
        end,1)
    else
    	self:updateUI()
	end
end
-- 更新头像显示
function DelegateSelectView:updateHeadIcon( view ,partner)
	view.UI_head.ctn_1:removeAllChildren()
	-- 修改头像
	-- 伙伴的Icon
    local _ctn = view.UI_head.ctn_1
    local _spriteIcon = FuncPartner.getPartnerIconByIdAndSkin(partner.id,partner.skin)
    _ctn:addChild(_spriteIcon)
    _spriteIcon:scale(1.2)

    -- 星级（不知道有没有0星，但是出现了，先在这里做个容错吧）
    if not partner.star or tonumber(partner.star) == 0 then
    	view.UI_head.mc_dou:visible(false)
    else
    	view.UI_head.mc_dou:visible(true)
    	view.UI_head.mc_dou:showFrame(partner.star)
    end		
    -- 品质
    local quality = partner.quality or 1
	local _frame = FuncPartner.getPartnerQuality(tostring(partner.id))[tostring(quality)].color
	view.UI_head.mc_kuang:showFrame(_frame)
	-- view.UI_head.panel_lv:visible(false)
	view.UI_head.panel_lv.txt_3:setString(partner.level)
end
function DelegateSelectView:updateList()
	local panel = self.panel_2
	panel.panel_1:visible(false)

	

	local function createFunc( itemData, idx )
		local view = UIBaseDef:cloneOneView(panel.panel_1)

		self:updateItem(view, itemData, idx)
		return view
	end

	local function updateCellFunc( itemData, view, idx )
		self:updateItem(view, itemData, idx)
	end

	local partners = DelegateModel:getAllPartners(self.__data.id)
	-- table.copy(PartnerModel:getAllPartner())
	-- dump(partners)
	-- table.copy(LineUpModel:getDetailList())
	-- table.remove(partners, 1)

	-- 保存一下这个已经排好的序列的顺序
	for i,v in ipairs(partners) do
		v._oriIdx = i
		v._inTeam = 0
	end

	local scrollList = panel.scroll_1

	local function sortFunc( a, b )
		if a._inTeam == b._inTeam then
			return a._oriIdx < b._oriIdx
		end

		return a._inTeam > b._inTeam
	end

	function scrollList:_reSort(noSort)
		if not noSort then
			table.sort(partners, sortFunc)
		end

		local scrollParams = {
			{
				data = partners,
				createFunc = createFunc,
				updateCellFunc = updateCellFunc,
				perFrame = 1,
				perNums = 1,
				offsetX = 40,
				offsetY = 8,
				itemRect = {x = 0,y = -100,width = 110,height = 110},
			}
		}

		self:styleFill(scrollParams)
	end

	scrollList:_reSort(true)
end
-- 更新派遣情况，同时重新排列视图顺序
function DelegateSelectView:updateList_select()
	local scroll = self.panel_2.scroll_1
	
	-- 刷新排列视图
	scroll:_reSort()

	for i,v in ipairs(scroll:getAllView()) do
		if v._updateSelect then
			v._updateSelect()
		end
	end
	self:updateAbility()

	self:checkIsEngoch()
end
function DelegateSelectView:updateItem( view, itemData, idx, notList )
	local panel = view
	if not notList then
		panel._idx = idx
		-- 蒙灰
		panel.panel_hui:visible(itemData.canGo ~= 1)
		-- 派遣
		panel.panel_pai:visible(itemData.sendOut == 1)
		-- 推荐
		if self._isSpecial then
			panel.panel_tj:visible(itemData.recommend == 1 and itemData.sendOut == 0)
		else
			panel.panel_tj:visible(false)
		end
		panel.panel_xuan:visible(false)
		local isInTema = self:isInTeam(itemData)
		-- 是否被选中
		panel.panel_dui:visible(isInTema)
		if isInTema then
			panel.panel_hui:visible(isInTema)
		end

		-- 更新是否被选中的方法
		function panel._updateSelect()
			panel.panel_dui:visible(self:isInTeam(itemData))
		end
		-- 品质
		local _frame = FuncPartner.getPartnerQuality(tostring(itemData.id))[tostring(itemData.quality)].color
		panel.mc_2:showFrame(_frame) 
	else
		panel.panel_hui:visible(false)
		-- 名字
		panel.txt_3:setString(GameConfig.getLanguage(itemData.name))
	end
	-- panel.panel_hui:visible(false)
	
	-- 伙伴的表格
	local partnerData = PartnerModel:getPartnerDataById(itemData.id)
	local _partnerInfo = FuncPartner.getPartnerById(itemData.id)

	panel.panel_lv.txt_3:setString(partnerData.level)
    -- 伙伴的Icon
    local _ctn = panel.mc_2.currentView.ctn_1
    local _spriteIcon = FuncPartner.getPartnerIconByIdAndSkin(partnerData.id,partnerData.skin)
    _ctn:removeAllChildren()
    _ctn:addChild(_spriteIcon)
    _spriteIcon:scale(1.2)

    -- 星级（不知道有没有0星，但是出现了，先在这里做个容错吧）
    if not itemData.star or tonumber(itemData.star) == 0 then
    	panel.mc_dou:visible(false)
    else
    	panel.mc_dou:visible(true)
    	panel.mc_dou:showFrame(itemData.star)
    end

    if not notList then
    	-- 点击
	    panel:setTouchedFunc(function()
	    	if itemData.sendOut == 1 then -- 派遣中 
	    		WindowControler:showTips(GameConfig.getLanguage("#tid_delegate_2007"))
	    	elseif itemData.canGo == 0 then -- 不可派遣
	    		local sendTimes = FuncDataSetting.getDataByConstantName("DelegatePartnerSendNum")
	    		local _str = string.format(GameConfig.getLanguage("#tid_delegate_2008"), sendTimes) 
	    		WindowControler:showTips(_str)
	    	elseif itemData.canGo == -1 then -- 不满足上阵条件 
	    		WindowControler:showTips(GameConfig.getLanguage("#tid_delegate_2009"))
	    	else -- 初步可派
    			if not self:isInTeam(itemData) then
    				self:setPartnerInTeam(itemData)
    			else
    				-- 不做操作或移出队列
    				self:removePartnerFromTeam( itemData )
    			end
		    end
	    end)
    end
end
-- 更新战力显示
function DelegateSelectView:updateAbility(state)
	if self.__data.sendTotalPower and self.__data.taskType == FuncDelegate.Type_Normal then
		local total = 0
		if state and state ~= DelegateModel.TASK_STATUS.WAIT then
			-- 这个是获取已经派遣的角色战力
			local partners = DelegateModel:getWorkingPartner(self.__data.id)
			for k,v in pairs(partners) do
				total = total + PartnerModel:getPartnerAbility(v.id)
			end
		else
			for k,v in pairs(self._inTeam) do
				total = total + PartnerModel:getPartnerAbility(v.id)
			end
		end
		self.panel_1.mc_5:visible(true)
		self.panel_1.txt_4:visible(true)
		if total < self.__data.sendTotalPower then
			self.panel_1.mc_5:showFrame(2)
		else
			self.panel_1.mc_5:showFrame(1)
		end
		local str = total.."/"..self.__data.sendTotalPower
		self.panel_1.mc_5.currentView.txt_1:setString(str)
	else
		self.panel_1.mc_5:visible(false)
		self.panel_1.txt_4:visible(false)
	end
end
-- 计算总战力===
function DelegateSelectView:chkTotalAblity( parnters )
	if self.__data.sendTotalPower then
		if self.__data.taskType == FuncDelegate.Type_Normal then
			local total = 0
			for k,v in pairs(parnters) do
				total = total + PartnerModel:getPartnerAbility(v)
			end
			if total >= self.__data.sendTotalPower then
				return true
			else
				return false
			end 
		end
	end
	return true
end
-- 获取出站的伙伴的个数
function DelegateSelectView:getTaskNum( )
	local pNums
	if self._isSpecial then
		pNums = #self.__data.specialAppointPartner
	else
		pNums = tonumber(self.__data.partnerNum)
	end
	return pNums
end
-- 把一个伙伴放到队列中
function DelegateSelectView:setPartnerInTeam( partner )
	if self._isSpecial then
		if partner.recommend ~= 1 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_delegate_3017"))
			return
		end
	end
	-- 队伍容纳人数
	local tData = self.__data
	local pNums = self:getTaskNum()
	if #self._inTeam < pNums then
		table.insert(self._inTeam, partner)
	else
		-- 直接把最后一个人换掉
		self._inTeam[#self._inTeam]._inTeam = 0
		self._inTeam[#self._inTeam] = partner
	end
	partner._inTeam = 1

	self:updateUpHero()
	self:updateList_select()
end
-- 更新界面上上阵的伙伴
function DelegateSelectView:updateUpHero( ... )
	local nums = self:getTaskNum()
	for i=1,nums do
		local partner = self._inTeam[i]
		local view = self.panel_1["panel_jia"..i]
		if partner then
			if not view.partner or view.partner.id ~= partner.id then
				self:updateHeadIcon(view, partner)
			end
			view.partner = partner
			view.UI_head:visible(true)
		else
			view.partner = nil
			view.UI_head:visible(false)
			view.UI_head.ctn_1:removeAllChildren()
		end
	end
end
-- 把一个伙伴移除队列
function DelegateSelectView:removePartnerFromTeam( partner )
	local idx = nil
	for k,v in pairs(self._inTeam) do
		if tonumber(v.id) == tonumber(partner.id) then
			idx = k
		end
	end
	if idx then
		table.remove(self._inTeam, idx)
		self:updateUpHero()
	end
	partner._inTeam = 0

	self:updateList_select()
end
-- 检查是否已经在队列中
function DelegateSelectView:isInTeam( partner )
	for k,v in pairs(self._inTeam) do
		if tonumber(v.id) == tonumber(partner.id) then
			return true
		end
	end

	return false
end
-- 点击了头像，是上阵还是下阵
function DelegateSelectView:headClick(view)
	self.panel_2:visible(true)
	if view.partner then
		self:removePartnerFromTeam(view.partner)
	end
end
-- 关闭界面
function DelegateSelectView:press_btn_close( )
	self:startHide()
end
-- 一键派遣
function DelegateSelectView:yijianpaiqianClieck( )
	local pNums = self:getTaskNum()
	if #self._inTeam >= pNums then
		WindowControler:showTips(GameConfig.getLanguage("#tid_delegate_3021"))
		return 
	end
	local partners = DelegateModel:getAllPartners(self.__data.id)
	if self._isSpecial then
		local isHave = false
		-- 特殊委托只能上派遣的指定奇侠
		for k,v in pairs(self.__data.specialAppointPartner) do
			local partner = partners[k]
			if partner.recommend == 1 and 
			partner._inTeam == 0 and 
			partner.canGo == 1  then
				self:setPartnerInTeam(partner) --只有推荐的奇侠才能上阵
				isHave = true
			end
		end
		if not isHave then
			WindowControler:showTips(GameConfig.getLanguage("#tid_delegate_3019"))
		end
	else
		local nums = self:getTaskNum()
		for i=1,nums do
			if i <= #partners then
				local partner = partners[i]
				if partner._inTeam == 0 and partner.canGo == 1  then
					self:setPartnerInTeam(partner)
				end
			end
		end
	end
	self.panel_2:visible(true)

	local pNums = self:getTaskNum()
	if pNums > #self._inTeam then
		WindowControler:showTips(GameConfig.getLanguage("#tid_delegate_2016"))
	end
end
-- 检查人数是否足够
function DelegateSelectView:checkIsEngoch( )
	local tmpView = self.panel_1.mc_weituoanniu.currentView
	local pNums = self:getTaskNum()
	if pNums > #self._inTeam then
		FilterTools.setGrayFilter(tmpView.btn_2)
	else
		FilterTools.clearFilter(tmpView.btn_2)
	end
end
-- 确定
function DelegateSelectView:paiqianClieck( )
	-- 队伍容纳人数
	local pNums = self:getTaskNum()
	if pNums > #self._inTeam then 
		local str = string.format(GameConfig.getLanguage("#tid_delegate_2005"), pNums)
		WindowControler:showTips(str)
	else
		-- 组织伙伴数据
		local partners = {}
		for i,v in ipairs(self._inTeam) do
			table.insert(partners, v.id)
		end
		-- 出发成功之后开始这个任务刷新上一个界面
		DelegateServer:startTask({
			delegateId = self.__data.id,
			partners = partners,
			callBack = function()
				self:startHide()
			end
		})
	end
end
-- 召回
function DelegateSelectView:zhaohuiClieck( )
	WindowControler:showWindow("DelegateRecallTipsView",1,function()
		DelegateServer:recallTask({
			delegateId = self.__data.id,
			callBack = function(params) 
				WindowControler:showTips( GameConfig.getLanguage("#tid_delegate_2003"))
				self:startHide()
			end
		})
	end)
end
-- 加速
function DelegateSelectView:jiasuClieck( )
	-- 判断仙玉是否充足
	local cTime = DelegateModel:getCurFinishTime(tostring(self.__data.id)) - TimeControler:getServerTime()
	if cTime > 0 then
		local cost = FuncDelegate.getSpeedUpCast(cTime)
	    if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, cost, true) then
	        return
	    end
		DelegateServer:speedUpTask({
			delegateId = self.__data.id,
			callBack = function(params)
				self:startHide()
			end
		})
	end
end
-- 领取奖励
function DelegateSelectView:lingquClieck( )
	local partners = DelegateModel:getWorkingPartner(self.__data.id)
	DelegateServer:finishTask({
		delegateId = self.__data.id,
		callBack = function(params) 
            params.partners = partners
            WindowControler:showWindow("DelegateRewardView", params)
			self:startHide()
		end
	})
end
-- 派遣奇侠介绍
function DelegateSelectView:paiQianInfoClick( )
	local str = ""
	if self._isSpecial then
		str = GameConfig.getLanguage("#tid_delegate_2011")
	else
		str = GameConfig.getLanguage("#tid_delegate_2010")
	end
	WindowControler:showTips(str)


	-- if self.panel_7:isVisible() then
	-- 	return
	-- end
	-- self.panel_7:visible(true)
	-- self.panel_7.txt_2:visible(false)
	-- self.panel_7.txt_3:visible(false)
	-- if self._isSpecial then
	-- 	self.panel_7.txt_1:setString(GameConfig.getLanguage("#tid_delegate_2011"))
	-- else
	-- 	self.panel_7.txt_1:setString(GameConfig.getLanguage("#tid_delegate_2010"))
	-- end
	-- self:delayCall(function( )
	-- 	self.panel_7:visible(false)
	-- end,3)
end


return DelegateSelectView
