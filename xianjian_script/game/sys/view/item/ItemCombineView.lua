--[[
	Author: TODO
	Date:2017-09-23
	Description: TODO
]]

local ItemCombineView = class("ItemCombineView", UIBase);

function ItemCombineView:ctor(winName, data)
    ItemCombineView.super.ctor(self, winName)
    self.itemDatas = data
    self.combineNum = 1
end

function ItemCombineView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ItemCombineView:registerEvent()

	ItemCombineView.super.registerEvent(self)
	local btn_confirm = self.UI_1.mc_1:getViewByFrame(1).btn_1
	self:registClickClose("out", c_func(self.clickButtonClose, self))
	self.UI_1.btn_close:setTouchedFunc(c_func(self.clickButtonClose, self))
	btn_confirm:setTouchedFunc(c_func(self.clickButtonConfirm, self))
	self.btn_jia:setTap(c_func(self._changeNum, self, 1))
    self.btn_jian:setTap(c_func(self._changeNum, self, -1))	
end

function ItemCombineView:initData()
	self.changeNums = 0
	self.maxCount = UserModel:maxCombineNums(self.itemDatas.itemPieceId)
	-- echo("\n\nself.maxCount", self.maxCount)
end

function ItemCombineView:initView()
	-- dump(self.itemDatas, "\n\nself.itemDatas")
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_item34001")) 
	local itemUI = self.UI_goods
	local data = {
		itemId = self.itemDatas.itemPieceId,
		itemNum = self.itemDatas.itemPieceNums
	}
	itemUI:setResItemData(data)
	itemUI:showResItemName(false)
	itemUI:showResItemRedPoint(false)
	itemUI:showResItemNum(false)
	local numShow = self.changeNums + 1
	self.txt_shuzhi1:setString(GameConfig.getLanguage("#tid_item34002")..self.itemDatas.itemPieceNums)
	self.txt_shuzhi2:setString(GameConfig.getLanguage("#tid_item34003")..numShow)
    local itemPieceName = FuncItem.getItemName(self.itemDatas.itemPieceId)
    local itemQuality = FuncItem.getItemQuality(self.itemDatas.itemPieceId)
   	self.mc_daojuming:showFrame(itemQuality)
    self.mc_daojuming.currentView.txt_daojuming:setString(itemPieceName)
   
    -- 滑动条
    self.slider_r:setMinMax(0, self.maxCount - 1)
    if self.maxCount == 1 then
    	self.slider_r:setPercent(100)
    	self.slider_r:setTouchEnabled(false)
    else
    	self.slider_r:setPercent(0)
    	self.slider_r:setTouchEnabled(true)
    end
    


end

function ItemCombineView:initViewAlign()
	-- TODO
end

function ItemCombineView:updateUI()
	local sliderChange = function (...)
        self:delayCall(function ()
            local num = math.floor((self.slider_r:getPercent() * (self.maxCount - 1) * 2 / 100 + 1) / 2)
            self.changeNums = num
            local numShow = self.changeNums + 1
            self.txt_shuzhi2:setString(GameConfig.getLanguage("#tid_item34003")..numShow)           
        end,0.1)
    end
    self.slider_r:onSliderChange(sliderChange)
end

-- function ItemCombineView:refreshData()
-- 	echo("\n\nself.changeNums2======", self.changeNums)
-- 	self.txt_shuzhi2:setString("合成数量: "..self.changeNums + 1)
--  	-- self.itemDatas.reward = {string.format("%s,%s,%s", FuncDataResource.RES_TYPE.ITEM, self.itemDatas.itemId, self.changeNums)}
-- end

function ItemCombineView:_changeNum(_num) 
    if _num > 0 then
        if tonumber(self.changeNums) >= tonumber(self.maxCount - 1) then
            WindowControler:showTips(GameConfig.getLanguage("#tid_item34004"))
        else
            self:changeNum(1)
        end
    else
        if tonumber(self.changeNums) == 0 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_item34005"))       	
        else
            self:changeNum(-1)
        end
    end
    
end

function ItemCombineView:changeNum(count)

    local num = self.changeNums + count
    self.changeNums = num
    local numShow = self.changeNums + 1
    -- echo("\n\nself.changeNums1====", self.changeNums)
    self.slider_r:setPercent(self.changeNums / (self.maxCount - 1) * 100)
    self.txt_shuzhi2:setString(GameConfig.getLanguage("#tid_item34003")..numShow)
    -- self:refreshData()   
end

function ItemCombineView:deleteMe()
	-- TODO
	ItemCombineView.super.deleteMe(self);
end

function ItemCombineView:clickButtonConfirm()
	local itemId = self.itemDatas.itemId
	local rewardNum = self.changeNums + 1
	local customItemCallBack = function(event)
        if event.result ~= nil then            
            local rewardStr = string.format("%s,%s,%s", FuncDataResource.RES_TYPE.ITEM, itemId, rewardNum)
            local data = {}
            data.reward = {rewardStr}
            data.itemId = itemId
            WindowControler:showWindow("ItemPieceComposeView",data);
        end
    end

    ItemServer:composeItemPieces(itemId, rewardNum, c_func(customItemCallBack))
	self:startHide()
end

function ItemCombineView:clickButtonClose()
	self:startHide()
end

return ItemCombineView;
