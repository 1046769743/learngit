--
-- Author: LXH
-- Date: 2018-03-09 09:43:09
--

local ItemOptionRewardView = class("ItemOptionRewardView", UIBase);

function ItemOptionRewardView:ctor(winName, rewardArr)
    ItemOptionRewardView.super.ctor(self, winName)
    self.rewardArr = rewardArr
end

function ItemOptionRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ItemOptionRewardView:registerEvent()
	ItemOptionRewardView.super.registerEvent(self)
	self:registClickClose(-1, c_func(self.close, self))
end

function ItemOptionRewardView:close()
	self:startHide() 
end

function ItemOptionRewardView:initData()
	self.itemNum = #self.rewardArr
	self.scrollItemList = self.mc_1.currentView.scroll_1
	self.scrollTime = 0.1
end

function ItemOptionRewardView:initView()
	-- 设置背景
	FuncCommUI.addBlackBg(self.widthScreenOffset, self._root)
	self.txt_2:setVisible(false)
	-- TODO
end

function ItemOptionRewardView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.UI_1, UIAlignTypes.Middle)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.txt_1, UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_1, UIAlignTypes.Middle)
end

function ItemOptionRewardView:updateUI()
	self.UI_1:setVisible(true)
	-- 添加获得奖励背景动画
	self.UI_1.ctn_1:removeAllChildren()
    self.UI_1.ctn_3:removeAllChildren()
    FuncCommUI.addCommonBgEffect(self.UI_1.ctn_1, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, nil, true, false, -85)
	-- FuncCommUI.playSuccessArmature(self.UI_1, FuncCommUI.SUCCESS_TYPE.GET, 1)
	if self.itemNum > 10 then
		self.mc_1:showFrame(1)
		self:updateScrollView()
	else
		self.mc_1:showFrame(2)
		self:updateCompRewardView()
	end
	
end


function ItemOptionRewardView:updateCompRewardView()
	self.mc_1.currentView.mc_1:showFrame(self.itemNum)
	local itemPanels = self.mc_1.currentView.mc_1.currentView
	for i=1, self.itemNum do
        local itemView = itemPanels["panel_" .. i]
        itemView:setVisible(false)
        local rewardStr = self.rewardArr[i].reward

        local intervalTime = 2 / GameVars.ARMATURERATE
        local delayTime = intervalTime * i

        self:delayShowItem(itemView, rewardStr, delayTime)
    end
end

function ItemOptionRewardView:delayShowItem(itemView, rewardStr, delayTime)
	local callBack = function()
        local params = {
            reward = rewardStr
        }
        itemView.UI_1:setResItemData(params)
        itemView.UI_1:showResItemName(true,true,1)
        -- itemView.UI_1:showResItemRedPoint(false)
        itemView:setVisible(true)
        itemView.UI_1:pos(7,-5)
        FuncCommUI.playRewardItemAnim(itemView.ctn_1, itemView.UI_1)
    end

    self:delayCall(c_func(callBack, self),delayTime)
end
-- 更新滚动条
function ItemOptionRewardView:updateScrollView()
	self.mc_1.currentView.panel_1:setVisible(false)
	-- 创建方法
	local creatFunc = function(itemData)		
		local view = UIBaseDef:cloneOneView(self.mc_1.currentView.panel_1)
		self:updateItem(itemData, view)
		return view
	end

	-- local reuseCellFunc = function (view, itemData)
	-- 	self:updateItem(itemData, view)
	-- end

	-- scroll参数
	local _params = {
		{
			data = self.rewardArr,
			createFunc = creatFunc,
			-- updateCellFunc = reuseCellFunc,
			perNums = 5,
			offsetX = 50,
			offsetY = 0,
			widthGap = -70,
			heightGap = 20,
			itemRect = {x = 0, y = -132, width = 260, height = 132},
			perFrame = 1,
		}
	}

	self.scrollItemList:styleFill(_params)
	self.scrollItemList:hideDragBar()
	self.scrollItemList:setOnCreateCompFunc(c_func(self.onScrollCreateComp, self))
end

function ItemOptionRewardView:updateItem(itemData, view)
	local params = {
			reward = itemData.reward
		}
	view.UI_2:setResItemData(params)
	view.UI_2:showResItemName(true, true, 1)
	view:setVisible(false)	
	-- itemView.UI_1:showResItemRedPoint(false)	
	-- view.UI_2:pos(7,-5)
	-- FuncCommUI.playRewardItemAnim(view.ctn_1, view.UI_2)
end

function ItemOptionRewardView:onScrollCreateComp()
	self.isShowing = true
	self:delayCall(c_func(self.playRewardAnim, self), 1 / GameVars.GAMEFRAMERATE)
end

function ItemOptionRewardView:playRewardAnim()
	if not self.isShowing then
		return
	end
	echo("self.index===", self.index, #self.rewardArr)
	self.scrollItemList:setCanScroll(false)
	if self.index == nil then
		self.index = 1
	else
		self.index = self.index + 1
	end

	-- 是否展示完毕
	if self.index > #self.rewardArr then
		self.isShowing = false
		self.scrollItemList:setCanScroll(true)
		return
	end

	local rewardData = nil
	local itemView = nil
	local callBack = function()
		itemView:setVisible(true)	
		self.scrollItemList:gotoTargetPos(self.index, 1, 2, self.scrollTime)	
		self:playRewardAnim()
	end
	
	rewardData = self.rewardArr[self.index]
	echo("rewardData.index", rewardData.index)
	itemView = self.scrollItemList:getViewByData(rewardData)
	if itemView then
		echo("2222")
		FuncCommUI.playRewardItemAnim(itemView.ctn_1, itemView.UI_2, callBack, 9, -6)
	end

	
end

function ItemOptionRewardView:deleteMe()
	-- TODO

	ItemOptionRewardView.super.deleteMe(self);
end

return ItemOptionRewardView;
