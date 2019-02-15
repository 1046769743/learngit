-- GuildActiveRukouView
-- Author: Wk
-- Date: 2017-09-30
-- 公会活动入口cell界面
local GuildActiveRukouView = class("GuildActiveRukouView", UIBase);

function GuildActiveRukouView:ctor(winName)
    GuildActiveRukouView.super.ctor(self, winName);
end

function GuildActiveRukouView:loadUIComplete()
	self:registerEvent()
end 

function GuildActiveRukouView:registerEvent()
	EventControler:addEventListener(GuildEvent.GUILD_ACTIVITY_REDPOINT_CHANGED, self.initCellView, self)
	EventControler:addEventListener(GuildBossEvent.GUILDBOSS_REFRESH_BOSS_RED, self.initCellView, self)
	EventControler:addEventListener(GuildExploreEvent.GUILDE_EXPLORE_ROKOU_RED_FRESISH, self.initCellView, self)

	
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

-- function GuildActiveRukouView:showButtonRed()
-- 	if self.rukouData ~= nil then
-- 		for k,v in pairs(self.rukouData) do
-- 			local _cell = self.scroll_1:getViewByData(v);
-- 			self:updateItem(_cell)
-- 		end
-- 	end
-- end

function GuildActiveRukouView:initCellView1()
	local view = self.panel_1
	if view.panel_1 ~= nil then
		view.panel_1:registerBtnEff()
		view.panel_1:setTouchedFunc(c_func(self.guildRestaurant, self),nil,true);
		local isShowGve = GuildActMainModel:isShowGuildActRedPoint()
		view.panel_1.panel_red:setVisible(isShowGve)
		echo("=========isShowGve=======",isShowGve)
	end
	if view.panel_2 ~= nil then
		view.panel_2:registerBtnEff()
		local isShowEctype = GuildBossModel:isShowGuildBossRedPoint()
		view.panel_2.panel_red:setVisible(isShowEctype)
		view.panel_2:setTouchedFunc(c_func(self.guildShakotanCoast, self),nil,true);
		echo("=========isShowEctype=======",isShowEctype)
	end

end


function GuildActiveRukouView:initCellView()

	self.panel_1:setVisible(false)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_1);
        self:updateItem(view,itemData)
        return view
    end


  --   local createBgFunc1 = function ( groupIndex,width,height )
		-- local view = display.newSprite("bg/food_bg_changjing1.png")
  --       view:setContentSize(cc.size(1000,500))
  --       view:setAnchorPoint(cc.p(0,1))
		-- return view
  --   end


    self.rukouData = {1}

 	local params =  {
        {
            data = self.rukouData,  ---alldata
            createFunc = createCellFunc,
            -- createBgFunc = createBgFunc1,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = -80,
            offsetY = -120,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -330, width = 1400, height =330},
            perFrame = 0,
        }
        
    }
    self.scroll_1:cancleCacheView();
    self.scroll_1:styleFill(params)
    self.scroll_1:setCanScroll( false )
    self.scroll_1:hideDragBar()
end

function GuildActiveRukouView:updateItem(view,itemData)
	if view.panel_1 ~= nil then
		local sysName = FuncCommon.SYSTEM_NAME.GUILDACTIVITY
		local open = FuncCommon.isSystemOpen(sysName)
		if open then
			view.panel_1.panel_off:visible(false)
			-- FilterTools.clearFilter( view.panel_1 ) -- view.panel_1:setVisible(true)
		else
			view.panel_1.panel_off:visible(true)
			-- TODO 五测临时屏蔽仙盟酒家系统
			view.panel_1:visible(false)
			-- FilterTools.setGrayFilter( view.panel_1 ,120 ) -- view.panel_1:setVisible(false)
		end
		view.panel_1:setTouchedFunc(c_func(self.guildRestaurant, self,open),nil,true);
		
		local isShowGve = GuildActMainModel:isShowGuildActRedPoint()
		view.panel_1.panel_red:setVisible(isShowGve)
		self:setRewardUI(1,view.panel_1)
	end
	if view.panel_2 ~= nil then
		view.panel_2:setVisible(false)
		-- local isShowEctype = GuildBossModel:isShowGuildBossRedPoint()
		-- view.panel_2.panel_red:setVisible(isShowEctype)
		-- view.panel_2:setTouchedFunc(c_func(self.guildShakotanCoast, self),nil,true);
		-- local textArr = FuncGuild.setOpenTimeText()
		-- view.panel_2.txt_2:setString("每日"..textArr[1][1].."-"..textArr[1][2]..","..textArr[2][1].."-"..textArr[2][2])
		-- self:setRewardUI(2,view.panel_2)
	end
	if view.panel_3 ~= nil then
		-- local isShowEctype = GuildBossModel:isShowGuildBossRedPoint()
		local isred = GuildExploreModel:getEntranceRed()
		view.panel_3:setTouchedFunc(c_func(self.guildExplore, self),nil,true);

		-- WindowControler:showTips(GameConfig.getLanguage("#tid_Explore_des_133"))

		-- view.panel_3.rich_1:setString(GuildBossModel:getEveryTime())
		-- local textArr = FuncGuild.setOpenTimeText()
		-- view.panel_3.txt_2:setString("每日"..textArr[1][1].."-"..textArr[1][2]..","..textArr[2][1].."-"..textArr[2][2]

		local openTime = LoginControler:getServerInfo().openTime
		local isOpenServerTime = UserModel:getCurrentDaysByTimes(openTime)
		local num = FuncGuildExplore.getSettingDataValue( "ExploreSysOpen","num" ) or 2
		if tonumber(isOpenServerTime) < tonumber(num)then
			view.panel_3.txt_2:setString(GameConfig.getLanguage("#tid_Explore_des_133"))
			isred = false
			view.panel_3.panel_off:visible(true)
		else
			view.panel_3.txt_2:setString("每日8:30-22:30开启")--GameConfig.getLanguage("#tid_Explore_des_133"))
			view.panel_3.panel_off:visible(false)
		end
		view.panel_3.panel_red:setVisible(isred)

		self:setRewardUI(3,view.panel_3)
	end
	

end

function GuildActiveRukouView:setRewardUI(systemId,view)
	local data = FuncGuild.getGuildActive(systemId)
	-- dump(data,"11111111111111")
	for i=1,3 do
		local ui = view["UI_"..i]
		local reward = data.icon[i]
		ui:setResItemData({reward = reward})
		ui:showResItemNum(false)
		local res = string.split(reward, ",")
        local rewardType = res[1]      ----类型
        local rewardNum = res[3]   ---总数量
        local rewardId = res[2]          ---物品ID
        -- rewardView:setScxa
        FuncCommUI.regesitShowResView(ui,
                rewardType, rewardNum, rewardId, reward, true, true);
                
	end
end

function GuildActiveRukouView:guildExplore()
	local isopen = FuncGuildExplore.isOnTime()
	local openTime = LoginControler:getServerInfo().openTime 
	local isOpenServerTime = UserModel:getCurrentDaysByTimes(openTime)
	local num = FuncGuildExplore.getSettingDataValue( "ExploreSysOpen","num" ) or 2
	echo("=====openTime==开服时间====",isOpenServerTime,num)
	if tonumber(isOpenServerTime) >= tonumber(num) then
		if isopen then
			GuildExploreServer:startGetServerInfo()
		else
			WindowControler:showTips("未到开启时间")
		end
	else
		WindowControler:showTips("开服第二天开启")
	end
end



--仙盟酒家
function GuildActiveRukouView:guildRestaurant(isOpen)
	-- -- if not isOpen then
	-- 	WindowControler:showTips("33级开启活动")
	-- 	return 
	-- end
	-- local function callBack()
	-- 	WindowControler:showWindow("GuildActivityMainView")
	-- end
	-- GuildActMainModel:requestGVEData(callBack)

	GuildActMainModel:enterGuildActMainView()



end

--共闯秘境
function GuildActiveRukouView:guildShakotanCoast()
	-- WindowControler:showWindow("GuildBossMainView")
	GuildControler:showGuildBossUI()
end

function GuildActiveRukouView:refreshRed()
	-- if self.rukouData == nil then
	-- 	return 
	-- end
	-- local view = self.scroll_1:getViewByData(self.rukouData[1]);
	local view = self.panel_1
	if view ~= nil then
		if view.panel_1 ~= nil then
			local isShowGve = GuildActMainModel:isShowGuildActRedPoint()
			echo("____________ 展示仙盟酒家红点 ",isShowGve)
			view.panel_1.panel_red:setVisible(isShowGve)
		end
		if view.panel_2 ~= nil then
			local isShowEctype = GuildBossModel:isShowGuildBossRedPoint()
			view.panel_2.panel_red:setVisible(isShowEctype)
		end
	end
end


function GuildActiveRukouView:press_btn_close()
	self:startHide()
end


return GuildActiveRukouView;
