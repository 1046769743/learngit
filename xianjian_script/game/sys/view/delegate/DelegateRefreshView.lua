--[[
	Author: lichaoye
	Date: 2017-05-26
	挂机刷新界面-view
]]

local DelegateRefreshView = class("DelegateRefreshView", UIBase)

function DelegateRefreshView:ctor( winName)
	DelegateRefreshView.super.ctor(self, winName)
end

function DelegateRefreshView:registerEvent()
	DelegateRefreshView.super.registerEvent(self)
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    -- self.btn_close:setTap(c_func(self.press_btn_close, self))
    self:registClickClose("out")
end

function DelegateRefreshView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

-- 适配
function DelegateRefreshView:setViewAlign()
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyone, UIAlignTypes.LeftBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function DelegateRefreshView:updateUI()
	local panel = self
	-- 所需刷新道具
	local itemId = FuncDataSetting.getDataByConstantName("DelegateRefreshItem")
	-- itemId = 10101
	-- echo("itemIditemId",itemId)
	-- echo("FuncItem.getItemType(itemId)", FuncItem.getItemType(itemId))
	-- echo("ItemsModel:getItemNumById(itemId)", ItemsModel:getItemNumById(itemId))

	panel.UI_1:setResItemData({itemId = itemId,itemNum = 1})
	panel.UI_1:showResItemNum(false)
	-- 根据id获得道具数量
	-- ItemsModel:getItemNumById(itemId)
	self:registClick(panel.UI_1, string.format("%s,%s,0",UserModel.RES_TYPE.ITEM,itemId))

	-- 是否显示仙玉补足
	if ItemsModel:getItemNumById(itemId) >= 1 then
		-- 道具数量
		self.mc_num:showFrame(2)
		self.mc_num.currentView.txt_1:setString(string.format("%s/%s", ItemsModel:getItemNumById(itemId), 1))

		-- self._moneyBuy = false
		panel.mc_1:visible(false)
		panel.txt_2:visible(false)
		panel.mc_btn:showFrame(1)
		panel.mc_btn:visible(true)
		panel.mc_btn.currentView.btn_1:setTap(function()
			self:reFreshTask()
		end)
	else
		-- 道具数量
		self.mc_num:showFrame(1)
		self.mc_num.currentView.txt_1:setString(string.format("%s/%s", ItemsModel:getItemNumById(itemId), 1))

		self._moneyBuy = false
		panel.mc_1:visible(true)
		panel.txt_2:visible(true)
		panel.mc_btn:showFrame(2)
		panel.mc_btn:visible(self._moneyBuy)

		panel.mc_1:setTouchedFunc(function()
			self._moneyBuy = not self._moneyBuy
			panel.mc_1:showFrame(self._moneyBuy and 2 or 1)
			panel.mc_btn:visible(self._moneyBuy)
		end)

		-- 花费
		local cost = FuncDataSetting.getDataByConstantName("DelegateRefreshItemPrice")
		panel.mc_btn.currentView.btn_1:getUpPanel().txt_1:setString(cost)
		panel.mc_btn.currentView.btn_1:setTap(function()
			-- 检查钱
			if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND, tonumber(cost), true) then
				self:reFreshTask()
			end
		end)
	end
end
-- 刷新任务
function DelegateRefreshView:reFreshTask()
	DelegateServer:refreshTask({
		delegateId = DelegateModel:getCurTaskId(),
		callBack = function()
			self:startHide()
		end
	})
end

-- 给一个物品加点击
function DelegateRefreshView:registClick( UI, sReward )
	local reward = string.split(sReward, ",")
	local rewardType = reward[1]
	local rewardNum = reward[#reward]
	local rewardId = reward[#reward - 1]

	FuncCommUI.regesitShowResView(UI, rewardType, rewardNum, rewardId, sReward, true, true)
end

function DelegateRefreshView:press_btn_close()
	self:startHide()
end

return DelegateRefreshView