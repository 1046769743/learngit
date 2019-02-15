--新活动入口主界面   从福利抽出来的

local NewActivityMainView = class("NewActivityMainView", UIBase);

function NewActivityMainView:ctor(winName,selectActId)
    NewActivityMainView.super.ctor(self, winName);
    self.selectActId = selectActId 

end

function NewActivityMainView:loadUIComplete()
	self:registerEvent();
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_2, UIAlignTypes.RightTop)
	self.mc_title:showFrame(2)
	-- FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_bg.scale9_jiugongge,UIAlignTypes.Right,0,1)
	-- FuncCommUI.setScrollAlign(self.widthScreenOffset,self.scroll_2,UIAlignTypes.Right,0,1)
	-- key 是 uiNumber
	self.mcFrames = {
		[1] = {frame = 3}, -- 造物有礼
		[2] = {frame = 2}, -- 兑换
		[6] = {frame = 4}, -- 奇侠唤醒
		[5] = {frame = 6}, -- 限时抢购
		[4] = {frame = 8}, -- 寻仙双倍
		[8] = {frame = 12}, -- 每日充值
		[10] = {frame = 15}, --单笔充值
		[11] = {frame = 16}, --累计充值
		["lingshishangdian"] = {frame = 1},-- 灵石商店
		["kaifuhuodong"] = {frame = 7},-- 开服活动
		["ziyuanzhaohui"] = {frame = 9},-- 资源找回
		["meirichouqian"] = {frame = 11},
		["lingqutili"] = {frame = 10},
		["chongzhifanli"] = {frame = 13}
	}

	self.otherActId = {
		[1] = "lingshishangdian", -- 灵石商店
		[2] = "meirichouqian", -- 抽签
		[3] = "kaifuhuodong", -- 开服活动
		[5] = "ziyuanzhaohui", -- 资源找回
		[4] = "lingqutili",  -- 领取体力
		[6] = "chongzhifanli", --充值返利
	}
	self:initBtnData()
	self:initBtns()
end 

function NewActivityMainView:registerEvent()
	NewActivityMainView.super.registerEvent();
	self.btn_close:setTap(c_func(self.closeUI,self))
	
	-- EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, 
	-- 		self.checkRedPoint, self)
	EventControler:addEventListener(ActivityEvent.REFRESH_RED_POINT, self.checkRedPoint, self)

	EventControler:addEventListener(ActivityEvent.ACTEVENT_KAIFU_TIMEOVER, 
			self.reFreshUI, self)
	

	EventControler:addEventListener(ActivityEvent.ACTEVENT_KAIFU_QIANGGOU_DATA,
	 self.qianggouDataCallBack, self)
	-- 活动结束或者跨天都需要重刷界面
	EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.reFreshUI,self)
	EventControler:addEventListener(ActivityEvent.ONE_ACT_TIME_OVER,self.closeUI,self)
end

function NewActivityMainView:reFreshUI( )
	self.selectActId = nil
	self:initBtnData()
	self:initBtns()
	self.scroll_2:refreshCellView(1)
	self:updateBtnsShow(self.selectActId)
end

function NewActivityMainView:checkRedPoint( )
	for i,v in pairs(self.actsT) do
		local panel = self.scroll_2:getViewByData(v)
		if panel then
			self:updateCellRightItem(panel,v)
		end
	end
	for i,v in pairs(self.otherActT) do
		local panel = self.scroll_2:getViewByData(v)
		if panel then
			self:updateCellOtherItem(panel,v)
		end
	end
end

function NewActivityMainView:initBtnData()
	local allActs = FuncActivity.getOnlineFuLiActs()
	local actT = {}
	local _uiNums = {1,8,10,11}
	for i,v in pairs(allActs) do
		-- 需要将每日任务paichu
		-- echo("name = = = = id = = = == = ",v:getActDesc(),v:getActId())
		--关于充值的活动才加进去
		-- if (v:getActId() == "78") or (v:getActId() == "90") or (v:getActId() == "96") or (v:getActId() == "97") or (v:getActId() == "99") or (v:getActId() == "100") then
		local actInfo = FuncActivity.getActConfigById(tostring(v:getActId()))
		if actInfo.isActivity and actInfo.isActivity == 1 then	
			if table.indexof(_uiNums,v:getActInfo().uiNumber) then
				table.insert(actT,v)
			end
		end
	end
	local sortFunc = function ( a,b )
		local aData = FuncActivity.getActConfigById(a:getActId())
		local bData = FuncActivity.getActConfigById(b:getActId())
		local aOrder = aData.order
		local bOrder = bData.order
		if aOrder < bOrder then
			return true
		end
		return false
	end
	table.sort(actT,sortFunc)
	self.actsT = actT

	local serverInfo = LoginControler:getServerInfo()
	local days = UserModel:getCurrentDaysByTimes(serverInfo.openTime)

	self.otherActT = {}
	if ActKaiFuModel:isHasQianggouData( ) and 
		FuncActivity.checkoutRushBuyOver(days ) then
		-- table.insert(self.otherActT,3)
	end
	if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SIGN) then
		-- 每日签到
		-- table.insert(self.otherActT,2)
	end
	if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHOP_7) then 
		-- 灵石商店
		-- table.insert(self.otherActT,1)
	end
	if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SPFOOD) then
		-- 领取体力
		-- table.insert(self.otherActT,4)
	end

	if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.RETRIEVE) then
		-- 资源找回
		-- table.insert(self.otherActT,5)
	end

	table.insert(self.otherActT,6)
	-- 判断 选中的ActId是否开启
	if self.selectActId then
		local isOpen = false
		for i,v in pairs(self.actsT) do
			if self.selectActId == v:getActId() then
				self.selectV = v
				isOpen = true
				break
			end
		end
		for i,v in pairs(self.otherActT) do
			if self.selectActId == self.otherActId[v] then
				self.selectV = nil
				isOpen = true
				break
			end
		end
		if not isOpen then
			self:initSelectId( )
		end
	else
		self:initSelectId( )
	end
end

function NewActivityMainView:initSelectId( )
	if table.length(self.actsT) > 0 then
		self.selectV = self.actsT[1]
		self.selectActId = self.actsT[1]:getActId()
	else
		self.selectV = nil
		self.selectActId = self.otherActId[self.otherActT[1]] 
	end
end

function NewActivityMainView:initBtns()
	self.mc_1:visible(false)
	local createCellFunc = function ( itemData)
		local view = UIBaseDef:cloneOneView(self.mc_1)
		self:updateCellRightItem(view, itemData)
		return view
	end
	local updateCellFunc = function (itemData,itemView)
        self:updateCellRightItem(itemView, itemData);
        return itemView
    end
    local createCellFunc1 = function ( itemData)
		local view = UIBaseDef:cloneOneView(self.mc_1)
		self:updateCellOtherItem(view, itemData)
		return view
	end
	local updateCellFunc1 = function (itemData,itemView)
        self:updateCellOtherItem(view, itemData);
        return itemView
    end

	local scrollParams = {
		{
			data = self.actsT,
			createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
			offsetX = -23,
            offsetY = 10,
			perFrame = 1,
			itemRect = {x = -32,y = -60,width = 140,height = 65},
			perNums= 1,
			heightGap = 0
		},
		{
			data = self.otherActT,
			createFunc = createCellFunc1,
            updateCellFunc = updateCellFunc1,
			offsetX = -23,
            offsetY = 0,
			perFrame = 1,
			itemRect = {x = -32,y = -60,width = 140,height = 65},
			perNums= 1,
			heightGap = 0
		},
		-- {
		-- 	data = {4},
		-- 	createFunc = createCellFunc1,
  --           updateCellFunc = updateCellFunc1,
		-- 	offsetX = 20,
  --           offsetY = 10,
		-- 	perFrame = 1,
		-- 	itemRect = {x = 0,y = -85,width = 150,height = 85},
		-- 	perNums= 1,
		-- 	heightGap = 0
		-- }

	}
	self.scroll_2:styleFill(scrollParams);
    self.scroll_2:hideDragBar()

    self:changeUI()
end

function NewActivityMainView:updateCellOtherItem(view, itemData )
	-- 处理特殊的逻辑
	local id = self.otherActId[itemData]
	if view then
		local btn = view.currentView.btn_1
	    btn:setTap(c_func(self.btnClickTap,self,itemData))
		local frame = 1
		if self.selectActId == id then
			frame = 2	
		end
	    
	    self:btnShowFrame(view, itemData,frame )
	end
end


function NewActivityMainView:updateCellRightItem(view, itemData )
	local actId = itemData:getActId()
	local actInfo = itemData:getActInfo()
	local frame = 1
	local btn = view.currentView.btn_1
	btn:setTap(c_func(self.btnClickTap,self,itemData))

    if self.selectActId == actId then
		frame = 2
	end
	self:btnShowFrame(view, itemData,frame )
end

function NewActivityMainView:btnShowFrame(view,itemData,frame)
	if type(itemData) == "table" then
		local actInfo = itemData:getActInfo()
		view:showFrame(frame)
		local title = GameConfig.getLanguage(actInfo.title)
		view.currentView.btn_1:setBtnStr(title,"txt_1")
		-- 红点
		-- if frame == 1 then
            local act =  itemData:getActId()
            local aa = itemData:getActType()
            local red = false
            
            if actInfo.uiNumber == 10 then
            	red = itemData:checkDanBiRedPoint()
            else
            	local ids = itemData:getNewActTastIds()
            	red = itemData:hasTodoThings(ids)
            end
			view.currentView.panel_red:visible(red)
		-- end
	else
		local title
        local red = false
		if itemData == 1 then
			-- 灵石商店
			title = "灵石商店"
            -- if frame == 1 then
                red = NewLotteryModel:fuliIsShowRed()
            -- end
		elseif itemData == 3 then
			-- 开服活动
			title = "开服抢购"
            -- if frame == 1 then
            	red = ActKaiFuModel:kaifuRed()
            -- end
        elseif itemData == 5 then
        	title = "资源找回"
        	-- if frame == 1 then
            	red = RetrieveModel:getRedRot()
            -- end
        elseif itemData == 2 then
			-- 开服活动
			title = "每日签到"
            -- if frame == 1 then
            	red = NewSignModel:isNewSignRedPoint()
            -- end
        elseif itemData == 4 then
			-- 开服活动
			title = "领取体力"
            -- if frame == 1 then
            	red = WelfareModel:getTiliRed()
            -- end
        elseif itemData == 6 then
        	-- 开服活动
			title = "充值返利"
            -- if frame == 1 then
            	red = false
            -- end
		end
		view:showFrame(frame)
		view.currentView.btn_1:setBtnStr(title,"txt_1")
        -- if frame == 1 then
			view.currentView.panel_red:visible(red)
		-- end
	end
end

function NewActivityMainView:btnClickTap(v )
	local id 
	if type(v) == "table" then
		id = v:getActId()
	else
		id = self.otherActId[v]
	end
	if self.selectActId == id then
		return
	end

	if id == self.otherActId[3] then
		-- 如果是开服抢购 先请求服务器
		self:disabledUIClick(  )
		ActKaiFuModel:getQianggouData( )
		self.selectActId = id
		self.selectV = v
	else
		self.selectActId = id
		self.selectV = v
		self:updateBtnsShow(self.selectActId)
	end
end
function NewActivityMainView:qianggouDataCallBack(event)
	self:resumeUIClick(  )
	if self.selectActId == self.otherActId[3] then
		self:updateBtnsShow(self.selectActId)
	end
end
function NewActivityMainView:updateBtnsShow(selectActId)
	for i,v in pairs(self.actsT) do
		local view = self.scroll_2:getViewByData(v)
		if view then
			local frame = 1
			if v:getActId() == selectActId then
				frame = 2
			end
			self:btnShowFrame(view,v,frame)
		end
	end
	for i,v in pairs(self.otherActT) do
		local view = self.scroll_2:getViewByData(v)
		if view then
			local frame = 1
			if self.otherActId[v] == selectActId then
				frame = 2
			end
			self:btnShowFrame(view,v,frame)
		end
	end

	self:changeUI()
end

function NewActivityMainView:changgeBtnSelect( )
	for i,v in pairs(self.actsT) do
		local view = self.scroll_2:getViewByData(v)
		if view then
			if v:getActId() == self.selectActId then
				view:showFrame(2)
			else
				view:showFrame(1)
			end
		end
	end
	for i,v in pairs(self.otherActT) do
		local view = self.scroll_2:getViewByData(v)
		if view then
			if self.otherActId[v] == self.selectActId then
				view:showFrame(2)
			else
				view:showFrame(1)
			end
		end
	end
end

function NewActivityMainView:changeUI()
    if type(self.selectV) == "table" then
        local selectActInfo = self.selectV:getActInfo()
	    local uiNumber = selectActInfo.uiNumber
	    local frame = self.mcFrames[uiNumber].frame
	    if frame then
		    self.mc_xxg:showFrame(frame)
		    local UI = self.mc_xxg.currentView.UI_1
		    UI:updateWinthActInfo(self.selectV)
	    end
    else
    	echo("当前显示第几帧::::::", self.selectActId)
        local frame = self.mcFrames[self.selectActId].frame
        if "kaifuhuodong" == self.selectActId then
        	if ActKaiFuModel:isHasQianggouData( ) then
        		self.mc_xxg:showFrame(frame)
        	end
        else
        	self.mc_xxg:showFrame(frame)
        end
    end
    self:changgeBtnSelect( )
end

function NewActivityMainView:closeUI()
	ActTaskModel:checkTodoNums()
    self:startHide();
end




return NewActivityMainView;
