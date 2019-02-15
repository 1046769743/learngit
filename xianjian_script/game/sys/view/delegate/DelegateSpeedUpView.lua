--[[
	Author: lichaoye
	Date: 2017-05-26
	挂机加速界面-view
]]

local DelegateSpeedUpView = class("DelegateSpeedUpView", UIBase)

function DelegateSpeedUpView:ctor( winName)
	DelegateSpeedUpView.super.ctor(self, winName)
end

function DelegateSpeedUpView:registerEvent()
	DelegateSpeedUpView.super.registerEvent(self)
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    self.btn_close:setTap(c_func(self.press_btn_close, self))
    -- self:registClickClose("out")
end

function DelegateSpeedUpView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

-- 适配
function DelegateSpeedUpView:setViewAlign()
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyone, UIAlignTypes.LeftBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function DelegateSpeedUpView:updateUI()
	local panel = self
	local vip = FuncDelegate.getSpeedUpVip()
	local num = FuncDelegate.getSpeedUpNum()
	local time = FuncDelegate.getSpeedUpTime()
	local str = GameConfig.getLanguageWithSwap("#tid_delegate_3001", vip, num, time)
	-- 时间
	panel.txt_jiasu:setString(str)
	-- 所需刷新道具
	local itemId = FuncDataSetting.getDataByConstantName("DelegateSpeedItem")
	panel.UI_1:setResItemData({itemId = itemId,itemNum = 1})
	panel.UI_1:showResItemNum(false)

	self:registClick(panel.UI_1, string.format("%s,%s,0",UserModel.RES_TYPE.ITEM,itemId))

	-- 是否显示仙玉补足
	if ItemsModel:getItemNumById(itemId) >= 1 then
		-- 道具数量
		panel.mc_num:showFrame(2)
		panel.mc_num.currentView.txt_1:setString(string.format("%s/%s", ItemsModel:getItemNumById(itemId), 1))

		-- self._moneyBuy = false
		panel.mc_1:visible(false)
		panel.txt_2:visible(false)
		panel.mc_2:showFrame(2)
		panel.mc_2:visible(true)
		panel.mc_2.currentView.btn_1:setTap(function()
			-- 一定够
			self:speedUp()
		end)
	else
		-- 道具数量
		panel.mc_num:showFrame(1)
		panel.mc_num.currentView.txt_1:setString(string.format("%s/%s", ItemsModel:getItemNumById(itemId), 1))

		self._moneyBuy = false
		panel.mc_1:visible(true)
		panel.txt_2:visible(true)
		panel.mc_2:showFrame(3)
		panel.mc_2:visible(self._moneyBuy)

		panel.mc_1:setTouchedFunc(function()
			self._moneyBuy = not self._moneyBuy
			panel.mc_1:showFrame(self._moneyBuy and 2 or 1)
			panel.mc_2:visible(self._moneyBuy)
		end)

		-- 花费
		local cost = FuncDataSetting.getDataByConstantName("DelegateSpeedItemPrice")
		panel.mc_2.currentView.btn_1:getUpPanel().txt_1:setString(cost)
		panel.mc_2.currentView.btn_1:setTap(function()
			-- 检查钱
			-- if UserModel:gold() > tonumber(cost) then
			-- 	self:speedUp()
			-- else
			-- 	WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"))
			-- end
			if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND, tonumber(cost), true) then
				self:speedUp()
			end
		end)
	end

	-- 有免费次数
	if DelegateModel:isFreeSpeedUp() then
		panel.mc_1:visible(false)
		panel.txt_2:visible(false)
		panel.mc_2:showFrame(1) -- 免费加速
		panel.mc_2:visible(true)
		panel.mc_2.currentView.btn_1:setTap(function()
			self:speedUp()
		end)
	end
end

function DelegateSpeedUpView:speedUp()
	DelegateServer:speedUpTask({
		delegateId = DelegateModel:getCurTaskId(),
		callBack = function()
			local text = GameConfig.getLanguageWithSwap("#tid_delegate_3003", math.ceil(FuncDelegate.getSpeedUpTime()))
			WindowControler:showTips(text)
			self:startHide()
		end
	})
end

-- 给一个物品加点击
function DelegateSpeedUpView:registClick( UI, sReward )
	local reward = string.split(sReward, ",")
	local rewardType = reward[1]
	local rewardNum = reward[#reward]
	local rewardId = reward[#reward - 1]

	FuncCommUI.regesitShowResView(UI, rewardType, rewardNum, rewardId, sReward, true, true)
end

function DelegateSpeedUpView:press_btn_close()
	self:startHide()
end

return DelegateSpeedUpView