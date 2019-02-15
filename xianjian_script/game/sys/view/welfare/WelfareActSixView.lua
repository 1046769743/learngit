-- 开fu抢购  单独开发 读表rushBuy
local WelfareActSixView = class("WelfareActSixView", UIBase);

function WelfareActSixView:ctor(winName)
    WelfareActSixView.super.ctor(self, winName);
    self.currentFrame  = 30
end

function WelfareActSixView:loadUIComplete()
	self:registerEvent();

	self:initData()
	-- self:initBtns()
	self:updateUI(self.todayData)
	
	-- 倒计时
	-- self.txt_time2:visible(false)
	-- self.txt_time1:visible(false)

	self:updateTime()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

	self:delayCall(function()
		ActKaiFuModel:setFirstShowRed(false)
	end,0.1)
end 

function WelfareActSixView:registerEvent()
	WelfareActSixView.super.registerEvent();
	
	EventControler:addEventListener(ActivityEvent.ACTEVENT_KAIFU_QIANGGOU_DATA, self.refreshUI, self)
	EventControler:addEventListener(ActivityEvent.ACTEVENT_KAIFU_QIANGGOU_REFRESH_RED, self.initData, self)
	EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, self.refreshUI, self)

end

function WelfareActSixView:updateTime()
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local leftTime = self:getLeftTime()
		self.txt_3:setString(fmtSecToLnDHHMMSS(leftTime))
	end
	self.currentFrame = self.currentFrame + 1
end

function WelfareActSixView:getLeftTime( )
	local allDays = table.length(self.allData)
	local data = LoginControler:getServerInfo()
	local openTime = data.openTime
	local currentTime = TimeControler:getServerTime()
	local openTimeData = os.date("*t", openTime)
	local totalTime = 0
	local currentMiao = openTimeData.hour * 60 * 60 + openTimeData.min * 60 + openTimeData.sec
	if openTimeData.hour >= 4 then
		totalTime = (allDays-1)*60*60*24 + (24*60*60-currentMiao) + 4*60*60
	else
		totalTime = (allDays-1)*60*60*24 + (4*60*60-currentMiao)
	end
	local leftTime = totalTime - currentTime + openTime
	-- echo("=============",leftTime,allDays)
	return leftTime
end

function WelfareActSixView:initData()
	-- 所有活动数据
	self.allData = FuncActivity.getRushBuyConfig()
	-- 已经进行到第几天
	local serverInfo = LoginControler:getServerInfo()
	self.days = UserModel:getCurrentDaysByTimes(serverInfo.openTime)
    -- 当前选中的id
    self.currentId = tostring(self.days)
	-- 今天的数据
	echo("self.days === ",self.days)

	local data = {}
	for k,v in pairs(self.allData) do
		data[tonumber(v.id)] = v
	end
	self.dataArr = data
	self.todayData = FuncActivity.getRushBuyById( self.days )
	self.panel_yeqian:visible(false)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_yeqian);
        self:initBtns(view,itemData)
        return view        
    end

    local refreshCellFunc = function(itemData,view)
		self:initBtns( view,itemData )
		return view
	end

	local params =  {
        {
            data = data,  ---alldata
            createFunc = createCellFunc,
            updateCellFunc = refreshCellFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = -5,
            itemRect = {x = 0, y =0, width = 116, height =50},
            perFrame = 3,
        }
        
    }
	self.scroll_1:styleFill(params)
	self.scroll_1:hideDragBar()
end

function WelfareActSixView:initBtns(view,itemData)
	-- dump(itemData,"itemData = = = = = = = =")
	local day = tonumber(itemData.id)
	local frame = 1
	local btn = view.mc_1.currentView.txt_1
	btn:setTouchedFunc(c_func(self.checkOpenBtnTap,self,day))
	local dayStr = Tool:transformNumToChineseWord(day)
	view.mc_1.currentView.txt_1:setString("第"..dayStr.."天")
	view.mc_1:showFrame(2)
	view.mc_1.currentView.txt_1:setString("第"..dayStr.."天")
	view.mc_1:showFrame(1)
	echo("ActKaiFuModel:getFirstShowRed() ============= ",ActKaiFuModel:getFirstShowRed())
	if ActKaiFuModel:getFirstShowRed() then
		view.panel_hongdian:visible(ActKaiFuModel:smallRed(day))
	else
		view.panel_hongdian:visible(false)
	end
	view.mc_1.currentView.panel_suo:visible(false)
	if tonumber(self.days) == tonumber(itemData.id) then
		view.panel_hongdian:visible(false)
		view.mc_1:showFrame(2)
	elseif tonumber(itemData.id) > (tonumber(self.days) + 1) then
		view.mc_1.currentView.panel_suo:visible(true)
	end
end

-- 1 已经结束 2 正在进行 3 将要进行 4 不可显示
function WelfareActSixView:checkOpen(day)
	local serverInfo = LoginControler:getServerInfo()
	local openDays = UserModel:getCurrentDaysByTimes(serverInfo.openTime)
	if day < openDays then
		return 1
	end
	if day == openDays then
		return 2
	end
	if day == (openDays+1) then
		return 3
	end
	if day > (openDays+1) then
		return 4,day - openDays
	end
end
function WelfareActSixView:checkOpenBtnTap(day)
	local state,num = self:checkOpen(tonumber(day))
	if state == 4 then
		WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_activity_5149",num-1))
	else
		local data = FuncActivity.getRushBuyById( day )
		self:updateUI(data)
		self:updateBtnsShow(day)
	end
end

function WelfareActSixView:updateBtnsShow(selectActId)
	for i,v in pairs(self.dataArr) do
		local view = self.scroll_1:getViewByData(v)
		if view then
			local frame = 1
			if tonumber(v.id) == selectActId then
				frame = 2
				view.panel_hongdian:visible(false)
			end
			view.mc_1:showFrame(frame)
			if frame == 1 and tonumber(v.id) > (tonumber(self.days) + 1) then
				view.mc_1.currentView.panel_suo:visible(true)
			end
		end
	end
end


function WelfareActSixView:updateUI(data,refresh)
	if not data then
		return 
	end
    -- if tostring(self.currentId) == data.id and not refresh then
    --     return
    -- end
    self.currentId = data.id
    -- self:initBtns()

	local data1 = {}
	data1.id = data.id
	data1.index = 1
	data1.reward = data.reward1[1]
	data1.yuanjia = data.price1
	data1.xianjia = data.discountPrice1
	data1.number = data.number1
	local panel1 = self.panel_x1
	self:updatePanel(panel1,data1)

	local data2 = {}
	data2.id = data.id
	data2.index = 2
	data2.reward = data.reward2[1]
	data2.yuanjia = data.price2
	data2.xianjia = data.discountPrice2
	data2.number = data.number2
	local panel2 = self.panel_x2
	self:updatePanel(panel2,data2)
 
end

function WelfareActSixView:updatePanel(panel,data)
	panel.UI_1:setRewardItemData({reward = data.reward})
	-- panel.UI_1:showResItemNum(false)
    -- 注册点击事件
    local resNum2,_,_ ,resType2,resId2 = UserModel:getResInfo( data.reward )
	FuncCommUI.regesitShowResView(panel.UI_1,resType2,resNum2,resId2,data.reward,true,true)

	local itemName = FuncDataResource.getResNameById(resType2,resId2)
	-- local itemFrame = 1
 --    if tonumber(resType2) == 1 then
 --        itemFrame = FuncItem.getItemQuality( resId2 ) + 2
 --    end
	panel.txt_1:setString(itemName)

	-- 原价
	panel.txt_y2:setString(data.yuanjia)
	-- 现价
	panel.txt_2:setString(data.xianjia)

	local str = "仅限%s件(剩余%s件)"
	local leftNum = ActKaiFuModel:getQianggouDataByidAndIndex(data.id,data.index )
	if self.reFreshData and self.reFreshData.index == data.index then
		if self.leftNum then
			leftNum = self.leftNum
		end
        self.leftNum = nil
        self.reFreshData = nil
	end
    
    if leftNum <= 0 then
    	leftNum = 0
    end

	local openState = self:checkOpen(tonumber(self.currentId)) 
	echo("openState ============== ",openState)
    if openState == 3 then
    	panel.txt_ci:setString(string.format(str,data.number,data.number))
    else
    	panel.txt_ci:setString(string.format(str,data.number,leftNum))
    end
	
	-- 判断是否可以购买
    local btnState = self:checkBuyCondition(data)
    echo("当前按钮状态 === ",btnState,leftNum)
	-- 购买
	local mc_btn = panel.mc_btn

    
    if btnState == 1 then
        mc_btn:showFrame(1)
        local btn = mc_btn.currentView.btn_1
        FilterTools.setGrayFilter(btn)
        btn:setTap(c_func(self.btnTap,self,data))
    elseif btnState == 2 then
        -- 暂时用 代替 -- 已经买过不会再让买
        mc_btn:showFrame(2)
        local btn = mc_btn.currentView.btn_1
        FilterTools.setGrayFilter(btn)
        btn:setTap(c_func(self.btnTap,self,data))
    elseif btnState == 3 then
        mc_btn:showFrame(3)
    elseif btnState == 4 then
        mc_btn:showFrame(1)
        local btn = mc_btn.currentView.btn_1
        FilterTools.clearFilter(btn)
        -- FilterTools.setGrayFilter(btn)
        btn:setTap(c_func(self.btnTap,self,data))
    elseif btnState == 0 then
        mc_btn:showFrame(1)
        local btn = mc_btn.currentView.btn_1
        FilterTools.clearFilter(btn)
        btn:setTap(c_func(self.btnTap,self,data))
    end
end
-- 是否可购买 
-- 0 可以   1 还未开放 2 已经购买过  3 已经售罄 4 仙玉不足
function WelfareActSixView:checkBuyCondition(data)
    return ActKaiFuModel:checkBuyCondition(self.currentId,data.index)
end
function WelfareActSixView:btnTap(data)
	local state = self:checkBuyCondition(data)
	--夕瑶月卡剩余时间
	local timeDay = MonthCardModel:getCardLeftDay(FuncMonthCard.card_xiyao)
	if state == 0 then
		if data.index == 2 and timeDay <= 0 then
			WindowControler:showWindow("WelfareActViewPopupWindow")
			return
		end
		ActivityServer:kaiFuQianggouData({day = tostring(data.id),rewardId = data.index}, c_func(self.btnTapCallBack,self,data))
		-- ActivityServer:getKaiFuQianggouData({}, c_func(self.btnTapCallBack,self))
	elseif state == 1 then 
		WindowControler:showTips(GameConfig.getLanguage("#tid_activity_tip_002"))
	elseif state == 2 then 
		WindowControler:showTips(GameConfig.getLanguage("#tid_activity_tip_003"))
	elseif state == 3 then 
		WindowControler:showTips(GameConfig.getLanguage("#tid_activity_tip_004"))
	elseif state == 4 then
		WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"))
	end
end
function WelfareActSixView:btnTapCallBack(data,event)
	if event.result then
		ActKaiFuModel:getQianggouData( )
		-- 购买完成之后 处理UI
		if data and data.reward then
			FuncCommUI.startFullScreenRewardView({data.reward})
		end
		dump(event.result.data, "qingg----", 6)
		local leftNum = event.result.data.remainNum
		self.leftNum = leftNum
		self.reFreshData = data
		self:refreshUI( )
	else
		local code = event.error.code
		if code == 650302 then
			-- 已经购买完了
			WindowControler:showTips("商品已售罄")
			ActKaiFuModel:getQianggouData( )
		end
	end
end

function WelfareActSixView:refreshUI( )
	if self.currentId then
		local data = FuncActivity.getRushBuyById( self.currentId )
		self:updateUI(data,true)
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	end
end

return WelfareActSixView;
