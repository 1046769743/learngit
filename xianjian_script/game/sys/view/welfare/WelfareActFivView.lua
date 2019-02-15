-- 限时抢购
local WelfareActFivView = class("WelfareActFivView", UIBase);

function WelfareActFivView:ctor(winName)
    WelfareActFivView.super.ctor(self, winName);
end

function WelfareActFivView:loadUIComplete()
	self:registerEvent();
	-- self.panel_x1:setVisible(false)
	
end 

function WelfareActFivView:registerEvent()
	WelfareActFivView.super.registerEvent();
	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
end

function WelfareActFivView:onTaskFinished(event )
	if not self.actData then return end
	local params = event.params
	local onlineId = params.onlineId
    local tastId = params.taskId
	if onlineId == self.actData:getOnlineId() then
		local actInfo = self.actData:getActInfo()
		for i,v in pairs(self.listData) do
            local panel = self["panel_x"..i]
            -- local panel = UIBaseDef:cloneOneView(self.panel_x1)
            if panel then
                self:updatePanel(panel,v)
            end
		end
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	end
end

function WelfareActFivView:updateWinthActInfo(actData)
	self:registerEvent();
	self.actData = actData
	local actInfo = actData:getActInfo()

	local title = actInfo.title
	-- local titTxt = self.panel_1.txt_1


	self.currentFrame = 30
	self:updateTime( )
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

    self.listData = actInfo.taskList
	for i,v in pairs(actInfo.taskList) do
		-- local panel = UIBaseDef:cloneOneView(self.panel_x1)
		-- self:updatePanel(panel,v,i)
		self:updatePanel(self["panel_x"..i],v,i)
	end
	
end

function WelfareActFivView:updateTime( )
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local leftTime = self.actData:getDisplayLeftTime()
		self.txt_3:setString(fmtSecToLnDHHMMSS(leftTime))
	end
	self.currentFrame = self.currentFrame + 1
end

function WelfareActFivView:updatePanel(panel,actTaskId,index)
	local actTaskData = FuncActivity.getActivityTaskConfig(actTaskId) 

	local reward = actTaskData.reward[1]
	panel.UI_1:setRewardItemData({reward = reward})
    panel.UI_1:showResItemNum(false)
    -- 注册点击事件
    local resNum1,_,_ ,resType1,resId1 = UserModel:getResInfo( reward )
	FuncCommUI.regesitShowResView(panel.UI_1,resType1,resNum1,resId1,reward,true,true)

	local itemName = FuncItem.getItemName(resId1)
	local itemFrame = FuncItem.getItemQuality( resId1 )
	-- 先写死
	itemFrame = 1
	-- panel.mc_1:showFrame(itemFrame)
	-- panel.mc_1.currentView.txt_1:setString(itemName.."*"..resNum1)
	panel.txt_1:setString(itemName.."*"..resNum1)


	-- 原价 
	local yuanjia = actTaskData.conditionAssist[1]
	-- 先默认 消耗仙玉
	local yuanjiaT = string.split(yuanjia,",")
	local costType = yuanjiaT[1]
	local costNum = yuanjiaT[2]

	panel.txt_y2:setString(costNum)

	-- 现价
	local xianjia = actTaskData.conditionParam[1]
	local xianjiaT = string.split(xianjia,",")
	local costType1 = xianjiaT[1]
	local costNum1 = xianjiaT[2]
	panel.txt_2:setString(costNum1)

	local onlineId = self.actData:getOnlineId()

	-- 判断等级
	panel.mc_btn:showFrame(1)
	local btn = panel.mc_btn.currentView.btn_1
	local btnTxt = btn:getUpPanel().txt_1
	if FuncActivity.checkTaskLevel(actTaskId) then
		-- 剩余次数
		local leftTime = actTaskData.times - ActTaskModel:getTaskReceiveTimes(onlineId, actTaskId, self.actData:getActInfo())
		local _str = GameConfig.getLanguage("#tid_activity_tip_001")..leftTime
		-- if leftTime <= 0 then
		-- 	_str = "<color=FF0000>".._str.. "<->"
		-- end

		panel.txt_ci:setString(_str)

		-- 购买事件
	    
	    if leftTime > 0 then
	        -- 判断 钻石
	        btnTxt:setString("购买")
	        if UserModel:getGold() >= tonumber(costNum1) then
	            FilterTools.clearFilter(btn)
	            -- btn:setTap(function ()
	            --     ActTaskModel:tryFinishTask(onlineId, actTaskId)
	            -- end)
	            btn:setTap(c_func(self.qianggouTap,self,onlineId, actTaskId,index))
	        else
	            FilterTools.setGrayFilter(btn)
	            btn:setTap(function ()
	                WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"))
	            end)
	        end
	    else
	        FilterTools.setGrayFilter(btn)
	        btnTxt:setString("已购买")
	        btn:setTap(function ()
	            WindowControler:showTips("商品已售完")
	        end)
	    end
	else
		FilterTools.setGrayFilter(btn)
		btnTxt:setString("购买")
        btn:setTap(function ()
            WindowControler:showTips(GameConfig.getLanguage("tid_char_1003"))
        end)
	end
end

function WelfareActFivView:qianggouTap(onlineId, actTaskId,index)
	if index == 2 then
		-- 开服抢购第二个需要特权开启
		
		local privilegeData = UserModel:privileges() 
	    local additionType = FuncCommon.additionType.switch_canTakePartIn_snapUp 
	    local curTime = TimeControler:getServerTime()
	    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,nil )
    	if isHas then
    		ActTaskModel:tryFinishTask(onlineId, actTaskId)
    	else
    		WindowControler:showTips("需激活夕瑶赠灯才能抢购")
    	end
    else
    	ActTaskModel:tryFinishTask(onlineId, actTaskId)	
	end
end

return WelfareActFivView;
