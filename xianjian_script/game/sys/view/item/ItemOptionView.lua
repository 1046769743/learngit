--
-- Author: LXH
-- Date: 2018-03-08 10:42:08
--

local ItemOptionView = class("ItemOptionView", UIBase);

function ItemOptionView:ctor(winName, itemId, itemNum, params)
    ItemOptionView.super.ctor(self, winName)
    self.itemId = itemId
    self.itemNum = itemNum
    self.params = params
end

function ItemOptionView:loadUIComplete()
	self:initData()
    self:initView()
	self:updateUI()
	self:registerEvent()
end 

function ItemOptionView:registerEvent()
	ItemOptionView.super.registerEvent(self);

	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_item_010"))
	self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_common_2008"))
	self.UI_1.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
	self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.clickConfirmBtn, self))
	self.btn_x1:setTouchedFunc(c_func(self.changeOptionNum, self, FuncItem.OPTION_BTN_TYPE.LEFT))
	-- self.btn_x2:setTouchedFunc(c_func(self.changeOptionNum, self, FuncItem.OPTION_BTN_TYPE.MIDDLE_LEFT))
	-- self.btn_x3:setTouchedFunc(c_func(self.changeOptionNum, self, FuncItem.OPTION_BTN_TYPE.MIDDLE_RIGHT))
	self.btn_x4:setTouchedFunc(c_func(self.changeOptionNum, self, FuncItem.OPTION_BTN_TYPE.RIGHT))

	self:registLeftLongTouchEvent()
	self:registRightLongTouchEvent()
	EventControler:addEventListener(HappySignEvent.HAPPYSIGN_OPTION_REWARD_CALLBACK, self.startHide, self)
	EventControler:addEventListener(CarnivalEvent.CARNIVAL_OPTION_REWARD_CALLBACK, self.startHide, self)
end

function ItemOptionView:registLeftLongTouchEvent()
	local funcs1 = {}
	local decRepeatCount = 1
	local decNum = 1
	local shortTouchLefttBtn = function ()
		decRepeatCount = 1
		decNum = 1
		if self.optionNum == 1 then
			WindowControler:showTips(GameConfig.getLanguage("tid_item_012"))
		else
			self.optionNum = self.optionNum - decNum
		end
		self.panel_pp.txt_1:setString(self.optionNum)
	end
	local longTouchLefttBtn = function ()
		if self.optionNum == 1 then
			WindowControler:showTips(GameConfig.getLanguage("tid_item_012"))
		else
			if decRepeatCount > 5 and decRepeatCount <= 10 then
				decNum = 2
			elseif decRepeatCount > 10 and decRepeatCount <= 20 then
				decNum = 5
			elseif decRepeatCount > 20 then
				decNum = 10
			end
			self.optionNum = self.optionNum - decNum
			if self.optionNum < 1 then
				self.optionNum = 1
			end
			decRepeatCount = decRepeatCount + 1
		end
		self.panel_pp.txt_1:setString(self.optionNum)
	end
	funcs1.endFunc = shortTouchLefttBtn
    funcs1.repeatFunc = longTouchLefttBtn

    self.btn_x2:setLongTouchFunc(funcs1, nil, false, 0.2, 0, 0.5)
end

function ItemOptionView:registRightLongTouchEvent()	
	local funcs2 = {}
	local addRepeatCount = 1
	local addNum = 1
	local shortTouchRightBtn = function ()
		--长按后重置数值
		addRepeatCount = 1
		addNum = 1
		if self.optionNum == self.itemNum then
			WindowControler:showTips(GameConfig.getLanguage("tid_item_013"))
		else
			self.optionNum = self.optionNum + addNum
		end
		self.panel_pp.txt_1:setString(self.optionNum)
	end
	local longTouchRightBtn = function ()
		if self.optionNum == self.itemNum then
			WindowControler:showTips(GameConfig.getLanguage("tid_item_013"))
		else
			if addRepeatCount > 5 and addRepeatCount <= 10 then
				addNum = 2
			elseif addRepeatCount > 10 and addRepeatCount <= 20 then
				addNum = 5
			elseif addRepeatCount > 20 then
				addNum = 10
			end
			self.optionNum = self.optionNum + addNum
			if self.optionNum > self.itemNum then
				self.optionNum = self.itemNum
			end
			addRepeatCount = addRepeatCount + 1
		end
		self.panel_pp.txt_1:setString(self.optionNum)
	end
	funcs2.endFunc = shortTouchRightBtn
    funcs2.repeatFunc = longTouchRightBtn
	
	self.btn_x3:setLongTouchFunc(funcs2, nil, false, 0.2, 0, 0.5)
end


function ItemOptionView:initData()
	if not self.params and self.itemId then
		self.optionNum = 1
		local itemData = FuncItem.getItemData(self.itemId)
    	self.optionId = itemData.useEffect		
	else
		self.optionId = self.params.optionId
	end
	
	self.reward_list = FuncItem.getOptionInfoById(self.optionId)
end

function ItemOptionView:initView()
	self.panel_1:setVisible(false)
	if not self.optionNum then
		self.panel_pp:setVisible(false)
		self.btn_x1:setVisible(false)
		self.btn_x2:setVisible(false)
		self.btn_x3:setVisible(false)
		self.btn_x4:setVisible(false)
	else
		self.panel_pp:setVisible(true)
		self.btn_x1:setVisible(true)
		self.btn_x2:setVisible(true)
		self.btn_x3:setVisible(true)
		self.btn_x4:setVisible(true)
		self.panel_pp.txt_1:setString(self.optionNum)
	end
	
	local createFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_1)
		self:updateItemView(view, itemData)
		return view
	end

	local reuseUpdateCellFunc = function (itemData, view)
		self:updateItemView(view, itemData)
	end

	local params = {
		{
			data = self.reward_list,
            createFunc= createFunc,
            perFrame = 1,
            perNums = 1,
            offsetX = -50,
            offsetY = 0,
            heightGap = -26,
            widthGap = 0,
            itemRect = {x = 0, y = -105, width = 449, height = 105},
            updateCellFunc = reuseUpdateCellFunc,
		}
	}

	self.scroll_1:styleFill(params)
	self.scroll_1:hideDragBar()
end

function ItemOptionView:updateUI()
	
end

function ItemOptionView:updateItemView(_view, _itemData)
	local itemRewardView = _view.UI_1
	_view.data = _itemData  
    itemRewardView:setResItemData({reward = _itemData})
    itemRewardView:showResItemName(false)
  
    local str_table = string.split(_itemData, ",")
    local itemName = ""
    local quality = 1
    local rewardType = str_table[1]
    if #str_table == 2 then
    	itemName = FuncDataResource.getResNameById(tonumber(rewardType))
    else
    	local itemId = str_table[2]

    	itemName = FuncDataResource.getResNameById(rewardType, itemId)
    	quality = FuncDataResource.getQualityById(rewardType, itemId)
    end
    _view.mc_daojuming:showFrame(quality)
    _view.mc_daojuming.currentView.txt_daojuming:setString(itemName)
    if self.optionData and self.optionData == _itemData then
    	_view.panel_dui.panel_1:setVisible(true)
    else
    	_view.panel_dui.panel_1:setVisible(false)
    end
    
    _view.panel_dui:setTouchedFunc(c_func(self.doClickOption, self, _view))
	local rewardNum = str_table[#str_table]
	local rewardId = str_table[#str_table - 1]
	FuncCommUI.regesitShowResView(itemRewardView,
	            rewardType, rewardNum, rewardId, _itemData, true, true)
end

function ItemOptionView:doClickOption(_view)
	local data = _view.data
	if not self.optionData then
		self.optionData = data
		_view.panel_dui.panel_1:setVisible(true)
	else
		if self.optionData == data then
			return 
		else
			local lastView = self.scroll_1:getViewByData(self.optionData)
			if lastView then
				lastView.panel_dui.panel_1:setVisible(false)
			end
			self.optionData = data
			_view.panel_dui.panel_1:setVisible(true)
		end
	end
end

function ItemOptionView:clickConfirmBtn()
	if not self.optionData then
		WindowControler:showTips(GameConfig.getLanguage("tid_item_011"))
	else
		local index = self:getIndexByData(self.reward_list, self.optionData)
		if not self.params then
			local itemNum = self.optionNum			
			ItemServer:customItems(self.itemId, itemNum, c_func(self.showRewards, self, self.optionData, itemNum), index)
		else
			if self.params.isHappySign then
				EventControler:dispatchEvent(HappySignEvent.GET_HAPPYSIGN_OPTION_REWARD, {index = index})
			elseif self.params.isCarnival then
				EventControler:dispatchEvent(CarnivalEvent.GET_CARNIVAL_OPTION_REWARD, {index = index, taskId = self.params.taskId})
			end			
		end		
	end
end

function ItemOptionView:getIndexByData(_reward_table, reward)
	for i = 1, #_reward_table, 1 do
		if reward == _reward_table[i] then
			return i 
		end
	end
end

function ItemOptionView:showRewards(_reward, num)
	local itemArray = {}
	local str_table = string.split(_reward, ",")
	local itemType = nil
	local itemId = nil
	local itemNum = 0
	local reward_str = ""
	if #str_table == 2 then
		itemId = str_table[1]
		itemNum = str_table[2]
		reward_str = itemId..","..num
	else
		itemType = str_table[1]
		itemId = str_table[2]
		itemNum = str_table[3]
		reward_str = itemType..","..itemId..","..num
	end

	table.insert(itemArray, reward_str)
	WindowControler:showWindow("RewardSmallBgView", itemArray)
	self:startHide()
end

function ItemOptionView:changeOptionNum(_type)
	if _type == FuncItem.OPTION_BTN_TYPE.LEFT then
		if self.optionNum == 1 then
			WindowControler:showTips(GameConfig.getLanguage("tid_item_012"))
		else
			self.optionNum = 1
		end
	elseif _type == FuncItem.OPTION_BTN_TYPE.MIDDLE_LEFT then
		if self.optionNum == 1 then
			WindowControler:showTips(GameConfig.getLanguage("tid_item_012"))
		else
			self.optionNum = self.optionNum - 1
		end
		
	elseif _type == FuncItem.OPTION_BTN_TYPE.MIDDLE_RIGHT then
		if self.optionNum == self.itemNum then
			WindowControler:showTips(GameConfig.getLanguage("tid_item_013"))
		else
			self.optionNum = self.optionNum + 1
		end
	elseif _type == FuncItem.OPTION_BTN_TYPE.RIGHT then
		if self.optionNum == self.itemNum then
			WindowControler:showTips(GameConfig.getLanguage("tid_item_013"))
		else
			self.optionNum = self.itemNum
		end		
	end
	self.panel_pp.txt_1:setString(self.optionNum)
end

function ItemOptionView:deleteMe()
	ItemOptionView.super.deleteMe(self);
end

return ItemOptionView;