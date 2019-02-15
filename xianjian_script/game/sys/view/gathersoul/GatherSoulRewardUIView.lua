-- GatherSoulRewardUIView
-- Author: Wk
-- Date: 2017-07-22
-- 神器分解成功系统界面
local GatherSoulRewardUIView = class("GatherSoulRewardUIView", UIBase);

function GatherSoulRewardUIView:ctor(winName)
    GatherSoulRewardUIView.super.ctor(self, winName);
    -- self.reward = reward
end

function GatherSoulRewardUIView:loadUIComplete()
	-- self:initData()
end 
function GatherSoulRewardUIView:initData(reward)
	self.reward = reward
	self.UI_1:setResItemData({reward = reward})
	self.UI_1:showResItemName(false)

	-- itemNameWithNotNum ---物品的名称
	-- echoError("======name=====",self.UI_1.itemNameWithNotNum)
	local name = self.UI_1.itemNameWithNotNum
	self.panel_zi.mc_zi:showFrame(tonumber(self.UI_1.__quality) + 2)
	self.panel_zi.mc_zi.currentView.txt_1:setString(name)

	local data = string.split(self.reward,",")
	local rewardType = data[1]      ----类型
	local rewardNum = data[3]   ---总数量
	local rewardId = data[2] 			---物品ID

	local  _txt = self.UI_1.panelInfo.txt_goodsshuliang
	local y = _txt:getPositionY()
	_txt:setPosition(cc.p(-18,y + 4))

	self:addeffect()

	if not TutorialManager.getInstance():isInTutorial() then
		FuncCommUI.regesitShowResView(self.UI_1,
            rewardType, rewardNum, rewardId, reward, true, true);
	end

	if rewardType == FuncDataResource.RES_TYPE.PARTNER then
		self.UI_1:showResItemNum(false)
	else
		self.UI_1:showResItemNum(true)
	end
end

function GatherSoulRewardUIView:addeffect()
	local data = string.split(self.reward,",")
	local _type = data[1]
	local itemId = data[2]
	local flaName = "UI_wupin_tx"
	local armatureName = nil



	if _type == FuncDataResource.RES_TYPE.PARTNER then
		armatureName = "UI_wupin_tx_01"
	else
		local item_type = FuncItem.getItemType(itemId)
		if item_type == FuncItem.itemType.ITEM_TYPE_PIECE then
			armatureName = "UI_wupin_tx_03"
		else
 			armatureName = "UI_wupin_tx_02"
 		end
	end

	local ctn = self
	local aim = self:createUIArmature(flaName, armatureName ,ctn, true ,function ()
	end )

	if _type == FuncDataResource.RES_TYPE.PARTNER then
		aim:setScale(1.18)
		aim:setPosition(cc.p(-1,11))
	else
		
		local item_type = FuncItem.getItemType(itemId)
		if item_type == FuncItem.itemType.ITEM_TYPE_PIECE then
			aim:setScale(1.15)
			aim:setPosition(cc.p(2,5))
		else
 			aim:setScale(1.1)
			aim:setPosition(cc.p(0,5))
 		end

	end
	
	
end



return GatherSoulRewardUIView;
