--
--Author:      zhuguangyuan
--DateTime:    2017-09-14 10:22:48
--Description: 开服嘉年华 - 全目标奖励界面
--

local CarnivalWholeTargetRewardView = class("CarnivalWholeTargetRewardView", UIBase);

function CarnivalWholeTargetRewardView:ctor(winName)
    CarnivalWholeTargetRewardView.super.ctor(self, winName)
end

function CarnivalWholeTargetRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	
end 

function CarnivalWholeTargetRewardView:registerEvent()
	CarnivalWholeTargetRewardView.super.registerEvent(self);
	self.UI_di.btn_close:setTap(c_func(self.onClose, self)) 
	-- 嘉年华关闭
    EventControler:addEventListener(CarnivalEvent.CARNIVAL_CLOSE, self.onClose, self)

    -- 全目标任务开启
	EventControler:addEventListener(CarnivalEvent.CARNIVAL_WHOLE_TARGET_REWARD_OPEN, self.timeUp, self)
	-- 领取了终极大奖
	-- 由于领取按钮还是显示亮光色 
	-- 故此处暂时不需要处理
	-- 暂时刷新一次界面
    EventControler:addEventListener(CarnivalEvent.GOT_WHOLE_TASK_REWARD, self.updateUI, self)
end
function CarnivalWholeTargetRewardView:openConfirmView()
	-- if CarnivalModel:getGotWholeTargetReward() then
	-- 	WindowControler:showTips( { text = "全目标奖励已经领取！" })
	-- 	return
	-- end
	WindowControler:showTopWindow("CarnivalWholeTargetConfirmView")
end

function CarnivalWholeTargetRewardView:timeUp()
	echo("_________________ view中 监听到 全目标奖励开启——————————————————————————————————")
	self:initData()
	self:initView()
	self:updateUI()

end
function CarnivalWholeTargetRewardView:initData()
	self.currentCarnivalId = CarnivalModel:getCurrentCarnivalId()
	self.ownTargetRewardNum = CarnivalModel:getWholeTargetNum(self.currentCarnivalId)
	self.totalTargetRewardNum = FuncCarnival.getCarnivalWholeTargetRewardMaxCountById(self.currentCarnivalId)
	-- 显示可领时间
	self.leftTime = CarnivalModel:getCanGetWholeRewardLeftTime(self.currentCarnivalId)
	self.frameCount = 0
end

function CarnivalWholeTargetRewardView:initView()
	self.UI_di.mc_1:setVisible(false)
	self.UI_di.txt_1:setString(GameConfig.getLanguage("#tid_jianianhua_003"))
	self.panel_1:setVisible(false)
	local function createPanelFunc(data)
		local itemView = UIBaseDef:cloneOneView( self.panel_1 )

		-- 展示奖品 点击可显示tips
		local rewardType = FuncCarnival.getCarnivalWholeTargetRewardTypeById(self.currentCarnivalId)
		local rewardId = FuncCarnival.getCarnivalWholeTargetRewardIdById(self.currentCarnivalId)
		local rewardNum = 1
		
		local str1 = rewardType..","..rewardId..","..rewardNum
		local params = {
			reward = str1,
		}
		itemView.UI_1:setResItemData(params)
		itemView.UI_1:setTouchEnabled(true)
		itemView.UI_1:showResItemNum(false)  -- 隐藏数量
		local resNum,_,_ ,resType,resId = UserModel:getResInfo( str1 )
       	FuncCommUI.regesitShowResView(itemView.UI_1,resType,resNum,resId,str1)

		-- 显示完成情况
		local str1 = self.ownTargetRewardNum.."/"..self.totalTargetRewardNum
		local str2 = self.ownTargetRewardNum/self.totalTargetRewardNum * 100
		local baseCount = FuncCarnival.getCarnivalWholeTargetRewardBaseCountById(self.currentCarnivalId)
		local str3 = self.ownTargetRewardNum * baseCount
		str1 = "任务完成："..str1
		str2 = "当前进度："..str2.."%"
		if self.currentCarnivalId == FuncCarnival.CarnivalId.SECOND_PERIOD then
			str3 = "可领碎片："..str3
		else
			str3 = "可领命魂："..str3
		end
		
		itemView.txt_1:setString(str1)
		itemView.txt_2:setString(str2)
		itemView.txt_3:setString(str3)

		if self.leftTime > 0 then
			echo("_____________111_____________")
			FilterTools.setGrayFilter(itemView.mc_get)
			itemView.mc_get:showFrame(1)
			itemView.mc_get:getCurFrameView().btn_1:setTap(function()
				local str1 = TimeControler:turnTimeSec( self.leftTime, TimeControler.timeType_dhhmmss );
				local day = string.split(str1,"天")
				local leftDay = nil
				if day[2] then
					leftDay = day[1].."天"
					WindowControler:showTips({text = leftDay..GameConfig.getLanguage("#tid_jianianhua_004")})
				else
					local leftTime = string.split(day[1],":") 
					echo("_____leftTime_______",leftTime[1],leftTime[2],leftTime[3])
					local left = leftTime[3].."秒"
					if tonumber(leftTime[1]) > 0 then
						left = leftTime[1].."小时"
					elseif tonumber(leftTime[2]) > 0 then
						left = leftTime[2].."分钟"
					end
					WindowControler:showTips({text = left..GameConfig.getLanguage("#tid_jianianhua_004")})
				end
			end) 
		else
			itemView.rich_time:setVisible(false)
			if CarnivalModel:getGotWholeTargetReward() then
				itemView.mc_get:showFrame(2)
			else
				itemView.mc_get:showFrame(1)
				itemView.mc_get:getCurFrameView().btn_1:setTap(c_func(self.openConfirmView, self)) 
			end
		end

		-- 显示规则
		local strRule = GameConfig.getLanguage("#tid_activity_5651")
		-- echo(strRule)
		local width = itemView.txt_guize.params.dimensions.width
		local fontName = GameVars.systemFontName --"gameFont1"
		local fontSize = itemView.txt_guize.params.size 
		local height = FuncCommUI.getStringHeightByFixedWidth(strRule, fontSize, fontName, width)
		itemView.txt_guize:setTextHeight(height)
		itemView.txt_guize:setString(strRule)
		return itemView
	end
	self.scrollParams = {
		{
	        data = {"data  ---- "},
	        createFunc = createPanelFunc,
	        perNums= 1,
	        offsetX = -33,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x=0,y=-713,width = 541,height = 713}, 
	        perFrame = 1
    	}
	}
end

function CarnivalWholeTargetRewardView:initViewAlign()
	-- TODO
end

function CarnivalWholeTargetRewardView:updateUI()
	self.scroll_1:cancleCacheView()
	self.scroll_1:styleFill(self.scrollParams)
	-- 显示可领取全目标奖励倒计时
    self:scheduleUpdateWithPriorityLua(c_func(self.downTime, self), 0);
end

-- 更新倒计时界面
function CarnivalWholeTargetRewardView:downTime()
	if self.leftTime < 0 then
        return
    end
    if self.frameCount % GameVars.GAMEFRAMERATE == 0 then 
	    local str = TimeControler:turnTimeSec( self.leftTime, TimeControler.timeType_dhhmmss );
	    str = str.."<color = 653C20>".."后可领取".."<->"
	    local itemViewArr = self.scroll_1:getAllView()
	    itemView = itemViewArr[1]
	    itemView.rich_time:setString(str) 

        self.leftTime = self.leftTime - 1;
    end 
    self.frameCount = self.frameCount + 1
end

function CarnivalWholeTargetRewardView:onClose()
	self:startHide()
end
function CarnivalWholeTargetRewardView:deleteMe()
	-- TODO

	CarnivalWholeTargetRewardView.super.deleteMe(self);
end

return CarnivalWholeTargetRewardView;
