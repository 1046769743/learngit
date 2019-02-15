--[[
	Author: caocheng
	Date:2017-07-26
	Description:锁妖塔的选择弹窗
]]

local TowerChooseTipsView = class("TowerChooseTipsView", UIBase);

function TowerChooseTipsView:ctor(winName,tipsType,pararms)
    TowerChooseTipsView.super.ctor(self, winName)
    self.viewType = tipsType
    if pararms~= nil then
    	self.pararms = pararms
    	dump(pararms, "pararms")
    end
end

function TowerChooseTipsView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:updateUI()
end 

function TowerChooseTipsView:registerEvent()
	TowerChooseTipsView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self))
end

function TowerChooseTipsView:initData()
	self.currentFloor = TowerMainModel:getCurrentFloor()
	self.historyFloor = TowerMainModel:getMaxClearFloor()
	self.perfectFloor = TowerMainModel:getPerfectFloor()
end

function TowerChooseTipsView:initView()
	local titleName = ""
	local titleText = ""
	local richtext = ""
	-- 默认显示第二帧 单纯提示
	self.mc_1:showFrame(2)
	local contentView = self.mc_1:getCurFrameView() 

	if self.viewType == FuncTower.VIEW_TYPE.RESER_VIEW then
		titleName = GameConfig.getLanguage("#tid_tower_ui_015") 
		self.rich_1:visible(false)
		local leftTimes = TowerMainModel:getCollectionTimes()
		local hasCanCollectFloor = TowerMainModel:getCollectionFloor()
		if leftTimes <= 0 or hasCanCollectFloor <=0 then
			contentView.txt_1:setString(GameConfig.getLanguage("tid_tower_prompt_104"))
			self.UI_1.mc_1:showFrame(1)
			self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.resetFloor, self))
		else
			contentView.txt_1:setString(GameConfig.getLanguage("tid_tower_ui_114"))
			self.UI_1.mc_1:showFrame(3)
			self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_117"))
			self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.gotoCollect,self))

			self.UI_1.mc_1.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_116"))
			self.UI_1.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.resetFloor,self))
		end
	elseif self.viewType == FuncTower.VIEW_TYPE.SWEEP_VIEW then
		titleName = GameConfig.getLanguage("#tid_tower_ui_016")
		contentView.txt_1:setString(GameConfig.getLanguage("tid_tower_prompt_105"))
		self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.sweepFloor, self))
	elseif self.viewType == FuncTower.VIEW_TYPE.NEXTFLOOR_VIEW then
		titleName = GameConfig.getLanguage("#tid_tower_ui_017")
		local str= GameConfig.getLanguage("#tid_tower_ui_018")
		richtext = "<color=da611a>"..str.."<->"
		self.UI_1.mc_1:showFrame(3)
		local nextFloor = self.currentFloor+1
		local _str = string.format(GameConfig.getLanguage("#tid_tower_ui_021"),tostring(nextFloor))
		contentView.txt_1:setString(_str)
		self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_019"))
		self.UI_1.mc_1.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_020"))
		self.UI_1.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.press_btn_close,self))
		self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.enterNextFloor,self))
	elseif self.viewType ==  FuncTower.VIEW_TYPE.SWEEP_TIPS_VIEW then
		titleName = GameConfig.getLanguage("#tid_tower_ui_017")
		local str= GameConfig.getLanguage("#tid_tower_ui_022") 
		contentView.txt_1:setString(str)
		self.UI_1.mc_1:showFrame(3)
		self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_023") )
		self.UI_1.mc_1.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_024") )
		self.UI_1.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.enterTowerMap,self))
		self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.sweepFloor,self))
	elseif self.viewType ==  FuncTower.VIEW_TYPE.GET_SOUL_TIPS_VIEW then
		titleName = GameConfig.getLanguage("#tid_tower_ui_017")
		local str= GameConfig.getLanguage("#tid_tower_ui_025") 
		contentView.txt_1:setString(str)
		self.UI_1.mc_1:showFrame(3)
		self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_019"))
		self.UI_1.mc_1.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_020"))
		self.UI_1.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.press_btn_close,self))
		self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.getSoulProperty,self))
	elseif self.viewType ==  FuncTower.VIEW_TYPE.RECONFIRM_TIPS_CLOSE_SHOP then
		titleName = GameConfig.getLanguage("#tid_tower_ui_026")
		local str= GameConfig.getLanguage("#tid_tower_ui_027")
		contentView.txt_1:setString(str)
		self.UI_1.mc_1:showFrame(3)
		self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_019"))
		self.UI_1.mc_1.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_020"))
		self.UI_1.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.press_btn_close,self))
		self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.closeMapShop,self))
	elseif self.viewType ==  FuncTower.VIEW_TYPE.COLLECT then 
		titleName = GameConfig.getLanguage("#tid_tower_ui_026")
		local str= GameConfig.getLanguage("#tid_tower_UI_collection_10")
		contentView.txt_1:setString(str)
		self.UI_1.mc_1:showFrame(1)
		self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_UI_collection_11"))
		self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.gotoCollect,self))
	elseif self.viewType ==  FuncTower.VIEW_TYPE.RECONFIRM_TIPS_TO_HANDLE_EVENTS then 
		titleName = GameConfig.getLanguage("#tid_tower_ui_017")
		local str= GameConfig.getLanguage("#tid_tower_UI_collection_10")
		contentView.txt_1:setString(str)
		self.UI_1.mc_1:showFrame(1)
		self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_UI_collection_11"))
		self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.gotoHandleEvents,self))
	-- 搜刮加速确认
	else
		self.mc_1:showFrame(1)
		self.contentView = self.mc_1:getCurFrameView() 
		self.UI_1.mc_1:showFrame(3)
		local tishiTips
		if self.viewType ==  FuncTower.VIEW_TYPE.ACCELERATE_CONFIRM then 
			titleName = GameConfig.getLanguage("#tid_tower_ui_109")
			tishiTips= GameConfig.getLanguage("#tid_tower_ui_106")
			self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.gotoAccelerate,self))
			self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
		elseif self.viewType ==  FuncTower.VIEW_TYPE.BUY_GOODS_CONFIRM then 
			titleName = GameConfig.getLanguage("#tid_tower_ui_110")
			tishiTips= GameConfig.getLanguage("#tid_tower_ui_107")
			self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.gotoBuyGoods,self))
			self.contentView.txt_2:setString(self.pararms.needNum)
		elseif self.viewType ==  FuncTower.VIEW_TYPE.ZHANBU_CONFIRM then 
			titleName = GameConfig.getLanguage("#tid_tower_ui_111")
			tishiTips= GameConfig.getLanguage("#tid_tower_ui_108")
			self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.gotoReDivination,self))
			self.contentView.txt_2:setString(self.pararms.needNum)
		end
		self.contentView.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_105"))
		self.contentView.txt_3:setString(tishiTips)
		
		self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_112"))
		self.UI_1.mc_1.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_113"))
		self.UI_1.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.press_btn_close,self))
	end

	self.UI_1.txt_1:setString(titleName)
	self.rich_1:setString(richtext)
end

function TowerChooseTipsView:updateFrame()
	local leftTime = TowerMainModel:getFinishTime() - TimeControler:getServerTime()
	if leftTime>0 then
		self.accNeedGoldNum = 10
		local s1 = FuncDataSetting.getDataByConstantName("TowerCollectionStatic1") 
		local s2 = FuncDataSetting.getDataByConstantName("TowerCollectionStatic2")  
		self.accNeedGoldNum = (leftTime/s1 + 1)*s2
		self.accNeedGoldNum = math.floor(self.accNeedGoldNum)
		self.contentView.txt_2:setString(self.accNeedGoldNum)
	else
		self:unscheduleUpdate()
		self:startHide()
	end
end
function TowerChooseTipsView:updateUI()

end

function TowerChooseTipsView:deleteMe()
	TowerChooseTipsView.super.deleteMe(self);
end

function TowerChooseTipsView:enterNextFloor()
	local curFloor = TowerMainModel:getCurrentFloor()
	if curFloor == TowerMainModel:getMaxFloor() then
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_001"))
		return
	end
	if self.pararms.curFloor and (curFloor <= self.pararms.curFloor) then
		self.pararms.curFloor = nil
		local isLock = TowerMainModel:checkIsCanEnterFloor(curFloor +1)
        if TowerMainModel:checkIsArriveNextStage() or isLock then
	        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CONFIRM_TO_CLICK_LOCK)
            self:startHide()
        else
	        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CONFIRM_TO_ENTER_NEXT_FLOOR)
			self:startHide()
			-- TowerServer:goNextFloor(self.pararms,c_func(self.goToNextFloor,self))
		end
	else
		self:startHide()
	end
end

function TowerChooseTipsView:goToNextFloor(event)
	TowerMainModel:saveGridAni(false)
	TowerMainModel:enterNextData(event.result.data)	
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR)
	self:startHide()
end

function TowerChooseTipsView:sweepFloor()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_SWEEP_TOWER)
	self:startHide()
end
-- 确认搜刮
function TowerChooseTipsView:gotoCollect()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_COLLECT_TOWER,{})
	self:startHide()
end

function TowerChooseTipsView:enterTowerMap()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ENTER_TOWERMAPVIEW)
	self:startHide()
end

function TowerChooseTipsView:resetFloor()
	TowerServer:resetTower(c_func(self.resetTower,self))
end

function TowerChooseTipsView:resetTower(event)
	if event.error then 
		local errorInfo= event.error
		if tonumber(errorInfo.code) == 260701 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_028"))
 		end	
 		if tonumber(errorInfo.code) == 260702 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_029"))
 		end	
 	else
 		-- 重新加载数据
 		TowerMainModel:reLoadTowerData(event.result.data)
 		local maxfloor = FuncTower.getMaxFloor()
 		for i=1,maxfloor do
 			TowerMainModel:recordHasAutoOpenPreview( i,nil )
 			-- TowerMainModel:recordHasCheckTowerShopGoods(i,false)
 		end

 		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_RESET_TOWER)
 		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_RESET_TOWER_SUCCESS)
 		-- TowerMainModel:setPerfectTime(0)
 		self:startHide()	
 	end	
end

function TowerChooseTipsView:getSoulProperty()
	-- 确认收取
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_GOT_SOUL_COMFIRMED,{soulId = self.pararms.soulId})
	self:startHide()
end

function TowerChooseTipsView:closeMapShop()
	-- 确认关闭商店
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CLOSE_MAP_SHOP_CONFIRMED,{shopId = self.pararms.shopId})
	self:startHide()
end

-- 去处理搜刮事件
function TowerChooseTipsView:gotoHandleEvents()
	EventControler:dispatchEvent(TowerEvent.TOWER_GO_TO_HANDLE_EVENTS_CONFIRMED,{})
	self:startHide()
end

-- 确认加速
function TowerChooseTipsView:gotoAccelerate()
	if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND ,self.accNeedGoldNum,true) then
		EventControler:dispatchEvent(TowerEvent.TOWER_GO_TO_ACCELERATE_COLLECTION_CONFIRMED,{})
	end
	self:startHide()
end

-- 确认购买商品
function TowerChooseTipsView:gotoBuyGoods()
	if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND ,self.pararms.needNum,true) then
		EventControler:dispatchEvent(TowerEvent.TOWER_GO_TO_BUY_GOODS_CONFIRMED,{params = self.pararms.params})
	end
	self:startHide()
end

-- 确认重新占卜
function TowerChooseTipsView:gotoReDivination()
	if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND ,self.pararms.needNum,true) then
		EventControler:dispatchEvent(TowerEvent.TOWER_GO_TO_RE_DIVINATION_CONFIRMED,{params = self.pararms.params})
	end
	self:startHide()
end

function TowerChooseTipsView:press_btn_close()
	self:startHide()
end

return TowerChooseTipsView;
