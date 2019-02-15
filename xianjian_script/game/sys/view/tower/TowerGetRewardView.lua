--[[
	Author: Long Xiaohua
	Date:2017-08-02
	Description: TODO
]]

local TowerGetRewardView = class("TowerGetRewardView", UIBase);

function TowerGetRewardView:ctor(winName, compItems, towerItems, showBuffShop,shopParams,perfectRewardData)
    TowerGetRewardView.super.ctor(self, winName)

    if compItems == nil and towerItems == nil then
    	echoError("传入的compItems和towerItems均为  nil")
    end

    if (compItems and table.length(compItems) == 0) and (towerItems and table.length(towerItems) == 0) then
    	echoError("传入的compItems和towerItems均为空 table")
    end
    self.compDatas = compItems
    self.towerDatas = towerItems
    self.showBuffShop = showBuffShop
    if self.showBuffShop then
    	self.params = shopParams
    end
    self.perfectRewardData = perfectRewardData
    if self.perfectRewardData and TowerConfig.SHOW_TOWER_DATA then
    	dump(self.perfectRewardData, "desciption")
    end
end

function TowerGetRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerGetRewardView:registerEvent()
	TowerGetRewardView.super.registerEvent(self)
	self:registClickClose(-1, c_func(self.close, self))
end

function TowerGetRewardView:close()
	if self.showBuffShop then
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CLOSE_GETREWARDVIEW,{data = self.params})
	end	
	if self.towerDatas and table.length(self.towerDatas) then
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_HAVE_TOWERITEM)
	end
	if self.perfectRewardData and table.length(self.perfectRewardData) > 0 then
		echo("________ 发送完美通关检查消息 ---- ________")
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CHECK_IS_PERFECT,{})
	end
	self:startHide() 
end

function TowerGetRewardView:initData()
	-- 设置类型，通过该类型来分辨奖品的类别
	local data1 = {}
	local data2 = {}
	if self.compDatas and #self.compDatas > 0 then
		for i,v in ipairs(self.compDatas) do
			local reward_table = string.split(v, ",")
			if #reward_table == 2 then
				table.insert(data1, reward_table)
			elseif #reward_table == 3 then
				table.insert(data2, reward_table)
			end
		end
	end
	
	local data3 = {}
	if #data1 > 0 then
		for i,v in ipairs(data1) do
			if data3[tostring(v[1])] == nil then
				data3[tostring(v[1])] = tonumber(v[2])
			else
				data3[tostring(v[1])] = tonumber(v[2]) + tonumber(data3[tostring(v[1])])
			end
		end
	end
	
	local data4 = {}
	if #data2 > 0 then
		for i,v in ipairs(data2) do
			if data4[tostring(v[2])] == nil then
				data4[tostring(v[2])] = tonumber(v[3])
			else
				data4[tostring(v[2])] = tonumber(v[3]) + tonumber(data4[tostring(v[2])])
			end
		end
	end

	self.compDatas_managed = {}
	if table.length(data3) then
		for k,v in pairs(data3) do
			local rewardStr = string.format("%s,%d", k, v)
			table.insert(self.compDatas_managed, rewardStr)
		end
	end
	
	if table.length(data4) then
		for k,v in pairs(data4) do
			local rewardStr = string.format("%d,%s,%d", FuncDataResource.RES_TYPE.ITEM, k, v)
			table.insert(self.compDatas_managed, rewardStr)
		end
	end

	self.datas = {}
	if self.compDatas_managed and table.length(self.compDatas_managed) > 0 then
		for i, v in ipairs(self.compDatas_managed) do
			-- 给compItem加一个类型并插入到组合后的数据中
			-- local compElem = {v, self.subType.COMPITEM_TYPE}
			table.insert(self.datas, v)
		end
	end
	
	if self.towerDatas and table.length(self.towerDatas) > 0 then
		for i, v in ipairs(self.towerDatas) do
			-- 给towerItem加一个类型并插入到组合后的数据中
			-- local compElem = {v, self.subType.TOWERITEM_TYPE}
			table.insert(self.datas, v)
		end
	end
	
	self.itemNum = table.length(self.datas)	
end

function TowerGetRewardView:initView()
	-- 设置背景
	FuncCommUI.addBlackBg(self.widthScreenOffset, self._root)
	self.txt_2:setVisible(false)
	-- TODO
end

function TowerGetRewardView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.UI_1, UIAlignTypes.Middle)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.txt_2, UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_1, UIAlignTypes.Middle)
end

function TowerGetRewardView:updateUI()
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


function TowerGetRewardView:updateCompRewardView()
	self.mc_1.currentView.mc_1:showFrame(self.itemNum)
	local itemPanels = self.mc_1.currentView.mc_1.currentView
	for i=1, self.itemNum do
        local itemView = itemPanels["panel_" .. i]
        itemView:setVisible(false)
        local rewardStr = self.datas[i]

        local intervalTime = 2 / GameVars.ARMATURERATE
        local delayTime = intervalTime * i

        self:delayShowItem(itemView, rewardStr, delayTime)
    end
end

function TowerGetRewardView:delayShowItem(itemView, rewardStr, delayTime)
	local callBack = function()
        local params = {
            reward = rewardStr
        }
        itemView.UI_1:setResItemData(params)
        itemView.UI_1:showResItemName(true,true)
        itemView.UI_1:showResItemNameWithQuality()
        itemView.UI_1:showResItemRedPoint(false)
        itemView:setVisible(true)
        itemView.UI_1:pos(7,-5)
        -- FuncCommUI.playRewardItemAnim(itemView.ctn_1, itemView.UI_1)
    end

    self:delayCall(c_func(callBack, self),delayTime)
end
-- 更新滚动条
function TowerGetRewardView:updateScrollView()
	self.mc_1.currentView.UI_2:setVisible(false)
	-- 取得组合后的数据
	local rewards = self.datas
	-- 创建方法
	local creatFunc = function(reward)
		local params = {
			reward = reward
		}		

		local view = UIBaseDef:cloneOneView(self.mc_1.currentView.UI_2)
		view:setResItemData(params)
		view:showResItemName(true, true)
		view:showResItemNameWithQuality()	
		itemView.UI_1:showResItemRedPoint(false)	
		view:setVisible(true)
		view:pos(7,-5)
		-- view:updateUI()
		return view
	end

	-- scroll参数
	local _params = {
		{
			data = rewards,
			createFunc = creatFunc,
			perNums = 5,
			offsetX = 10,
			offsetY = 10,
			widthGap = 40,
			heightGap = 20,
			itemRect = {x = -166, y = -120, width = 136, height = 136},
			perFrame = 1,
		}
	}

	self.mc_1.currentView.scroll_1:styleFill(_params)
end

function TowerGetRewardView:deleteMe()
	-- TODO

	TowerGetRewardView.super.deleteMe(self);
end

return TowerGetRewardView;
