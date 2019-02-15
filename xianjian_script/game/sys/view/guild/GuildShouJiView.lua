
-- 仙盟宝库界面
local GuildShouJiView = class("GuildShouJiView", UIBase);

function GuildShouJiView:ctor(winName)
    GuildShouJiView.super.ctor(self, winName);
end

function GuildShouJiView:loadUIComplete()
	self:registerEvent()

	self.node = display.newNode()
    self.node:setContentSize(cc.size(138,128))
    self.node:pos(490,-470)
    self.node:anchor(0,0)
    self.node:addto(self,1)
    self.node:setTouchEnabled(true)
    -- self.node:setTouchSwallowEnabled(true)
    self.node:zorder(100000)
	--[[
      -- -- 测试代码
      local color = color or cc.c4b(255,0,0,120)
        local layer = cc.LayerColor:create(color)
        self.node:addChild(layer)
        layer:setContentSize(cc.size(138,128) )
    ]]--
end 

function GuildShouJiView:registerEvent()
	EventControler:addEventListener(GuildEvent.REFRESH_TREASURE_MAIN_VIEW, self.updateErJiPanel, self)
	-- EventControler:addEventListener(GuildEvent.GUILD_SHOUJI_LIST_REFRESH, self.refreshListData, self)
	-- EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.refreshListData, self); 
end

function GuildShouJiView:updateUI( erjiIndex )
	self.erjiIndex = erjiIndex
	self:initErJiYeQian()
    self:ErJiYeQianTap(self.erjiIndex)
end

function GuildShouJiView:initErJiYeQian()
	local panel = self.mc_1
	panel:showFrame(1)
	for i = 1,#FuncGuild.getAllExchangeData() do
		local mc = self["mc_g"..i]
		local btn = mc.currentView.btn_1
		-- btn:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_guild_exchange_00"..i))
		btn:setTap(c_func(self.ErJiYeQianTap,self,i))
	end
end

----二级页签点击事件
function GuildShouJiView:ErJiYeQianTap( _type )
	self.erjiIndex = _type
	self:refreshErJiYeQianState()
	self:updateErJiPanel()
end

----点击二级页签 更新中间部分显示区域
function GuildShouJiView:updateErJiPanel()
	local costdata =  FuncGuild.getAllExchangeData()[self.erjiIndex].cost
	local rewardId = FuncGuild.getAllExchangeData()[self.erjiIndex].reward

	-- local view = self.mc_1
	-- view:showFrame(1)

	-- if #costdata == 5 then
		for i=1,#costdata do
			local  reward = costdata[i]
			local mc = self.mc_1
			mc:showFrame(self.erjiIndex)
			local btn_1 = mc.currentView["panel_"..i].panel_jiahao
			local uiview = mc.currentView["panel_"..i].UI_1
			uiview:setResItemData({reward = reward })
			uiview.panelInfo.mc_kuang:setVisible(false)
			local data = string.split(reward,",")
			-- dump(data,"data = = = = = == = ")
			local needNum = tonumber(data[3])
			local haveNum = ItemsModel:getItemNumById(data[2])
			uiview:setResItemNum(haveNum)
			-- echo("====haveNum============",haveNum,needNum)
			uiview.panelInfo.txt_goodsshuliang:setVisible(false)
			if haveNum >= needNum then
				-- uiview.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0x00,0xff,0x00))
				-- FilterTools.clearFilter(uiview.panelInfo.mc_kuang)
				FilterTools.clearFilter(uiview.panelInfo.ctn_1)
				btn_1:visible(false)
				uiview:setTouchedFunc(c_func(self.getItemDataPath, self,data[2]),nil,true);
			else
				-- FilterTools.setGrayFilter(uiview.panelInfo.mc_kuang)
				FilterTools.setGrayFilter(uiview.panelInfo.ctn_1)
				-- uiview.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0xff,0x00,0x00))
				btn_1:visible(true)
				uiview:setTouchedFunc(c_func(self.PopupWindow, self,nil),nil,true); ------  跳到藏宝图
			end

		end
	-- elseif #costdata == 3 then
	-- 		for i=1,#costdata do
	-- 		local  reward = costdata[i]
	-- 		local mc = self.mc_1
	-- 		mc:showFrame(2)
	-- 		local btn_1 = mc.currentView["panel_"..i].btn_1
	-- 		local uiview = mc.currentView["panel_"..i].UI_1
	-- 		uiview:setVisible(true)
	-- 		uiview:setResItemData({reward = reward })
	-- 		uiview.panelInfo.mc_kuang:setVisible(true)
	-- 		local data = string.split(reward,",")
	-- 		local needNum = tonumber(data[3])
	-- 		local haveNum = ItemsModel:getItemNumById(data[2])
	-- 		uiview:setResItemNum(haveNum)
	-- 		if haveNum >= needNum then
	-- 			uiview.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0x00,0xff,0x00))
	-- 			FilterTools.clearFilter(uiview.panelInfo.mc_kuang)
	-- 			FilterTools.clearFilter(uiview.panelInfo.ctn_1)
	-- 			btn_1:visible(false)
	-- 			uiview:setTouchedFunc(c_func(self.getItemDataPath, self,data[2]),nil,true);
	-- 		else
	-- 			FilterTools.setGrayFilter(uiview.panelInfo.mc_kuang)
	-- 			FilterTools.setGrayFilter(uiview.panelInfo.ctn_1)
	-- 			uiview.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0xff,0x00,0x00))
	-- 			btn_1:visible(true)
	-- 			uiview:setTouchedFunc(c_func(self.PopupWindow, self,nil),nil,true); ------  跳到藏宝图
	-- 		end
	-- 	end
	-- end

	self.ctn_1:removeAllChildren()
	local boxAni = self:createUIArmature("UI_xianmeng_keji","UI_xianmeng_keji_box01",self.ctn_1, true, GameVars.emptyFunc)
	----宝箱是否可以领取
	local isok = GuildModel:boxExchaneIsOk(self.erjiIndex)
	if isok then
		self.node:setTouchedFunc(c_func(self.clickExchange,self, self.erjiIndex),nil,true);
	else
		boxAni:pause()
		self.node:setTouchedFunc(c_func(self.showRewardData,self, rewardId),nil,true);
	end
	self:refreshRedPoint()
end

----刷新二级页签选中状态
function GuildShouJiView:refreshErJiYeQianState()
	for i = 1,#FuncGuild.getAllExchangeData() do
		local mc = self["mc_g"..i]
        if self.erjiIndex == i then
            mc:showFrame(2)
        else
            mc:showFrame(1)
        end
    end
end

--显示奖励相关资源
function GuildShouJiView:showRewardData(rewardID)
	local rewardData = FuncItem.getRewardData(rewardID)
	local newReward = {}
	for i=1,#rewardData.info do
		local data = string.split(rewardData.info[i],",")
		newReward[i] = data[2]..","..data[3]..","..data[4]

	end

	local _table = {
		title = "奖励预览",
		des = "",
		reward = newReward,
		callback = nil,--回调函数
		isPickup = nil,--是否可领取  -- 0 --预览不可领取  1领取   2已领取 --nil不显示
		parameter = nil,
	}

	WindowControler:showWindow("GuildBlessingRewardView",_table);
end

---点击宝箱兑换物品
function GuildShouJiView:clickExchange(rewardID)
	GuildModel:clickExchange(rewardID)
end

--更新红点
function GuildShouJiView:refreshRedPoint()
	local data = FuncGuild.getAllExchangeData()
	local num = table.length(data)
	for i = 1,num do
		local isShowRed = GuildModel:boxExchanegIsShowRed(i)
		local mcView = self["mc_g"..i]
		mcView:getViewByFrame(1).panel_red:visible(isShowRed)
	end
end

---- 跳到藏宝图
function GuildShouJiView:PopupWindow(  )
	WindowControler:showWindow("GuildDigMapMainView")
end

----弹出获取途径
function GuildShouJiView:getItemDataPath(itemID)
	WindowControler:showWindow("GetWayListView",itemID)
end

function GuildShouJiView:press_btn_close()
	self:startHide()
end


return GuildShouJiView;
