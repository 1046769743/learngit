--[[
	Author: lichaoye，caocheng
	Date: 2017-05-11
	新签到主界面-view
]]

local NewSignView = class("NewSignView", UIBase)

local NEW_SIGN_TYPE = {
	DAILYSIGN = 1, -- 每日签到
}

function NewSignView:ctor( winName)
	NewSignView.super.ctor(self, winName)
	self._nowIdx = 0
	self._playRolling = false
	self._rollX = 0
	self._rollY = 0
end

function NewSignView:registerEvent()
	NewSignView.super.registerEvent(self)
	EventControler:addEventListener(NewSignEvent.LUCKY_UPDATE_EVENT, self.updateBroadCast, self)
	EventControler:addEventListener(NewSignEvent.TOTALSIGN_UPDATE_EVENT, self.updateTotalIcon, self)
	EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE, self.updateTotalIcon, self)
	EventControler:addEventListener(NewSignEvent.SIGN_FINISH_EVENT, self.updateSign, self)
    -- self.btn_close:setTap(c_func(self.press_btn_close, self))
end

function NewSignView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
	-- 请求一下广播列表，因为不是重点信息所以先进界面
	NewSignServer:getLuckyList()
end

-- 适配
function NewSignView:setViewAlign()
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.RightTop)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
   -- FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_ding, UIAlignTypes.MiddleTop, 1, 0)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function NewSignView:showUI(idx)
	if idx == self._nowIdx then return end
	self._nowIdx = idx
	-- self:updateTab()
	self:udpateCenter()
end
--将签到移动到福利，修改者wk
-- function NewSignView:updateTab()
-- 	for k,idx in pairs(NEW_SIGN_TYPE) do
-- 		local nowMc = self["mc_" .. idx]
-- 		nowMc:showFrame(idx == self._nowIdx and 2 or 1)
-- 		-- 不被选中检查红点
-- 		-- if nowMc:getCurFrame() == 1 then
-- 		nowMc.currentView.panel_hongdian:visible(self:hasRedPoint(idx))
-- 		-- end
-- 	end
-- end
--
function NewSignView:hasRedPoint(idx)
	local _call = {
		[NEW_SIGN_TYPE.DAILYSIGN] = function()
			return NewSignModel:isNewSignRedPoint()
		end,

	}

	return _call[idx]()
end
-- 更新中间区域
function NewSignView:udpateCenter()
	-- 目前只有抽签
	self:updateSign()
end
-- 签到界面
function NewSignView:updateSign()
	local panel = self
	-- 更多
	panel.btn_gengduo:setTap(function()
		WindowControler:showWindow("NewSignTodayRewardView");
		-- WindowControler:showWindow("NewSignGetQianView")
		-- NewSignServer:getLuckyList()
	end)
	-- 今日最佳
	panel.UI_1:setResItemData({reward = NewSignModel:getTodayBest()})
	self:registClick(panel.UI_1, NewSignModel:getTodayBest())

	-- 已抽x次
	-- panel.txt_5ci:setString(GameConfig.getLanguageWithSwap("tid_sign_1009", NewSignModel:totalSignCount()))
	-- 累抽奖励
	self:updateTotalIcon()
	-- 广播
	self:updateBroadCast()
	-- 摇奖
	self:updateTicksContainer()
	
end

-- 广播
function NewSignView:updateBroadCast()
	self.rich_1:visible(false)
	local function updateItem( view, itemData, idx )
		-- echo("什么情况",FuncNewSign.getBroadCast( itemData.type, itemData.name, itemData.reward ))
		view:setString(FuncNewSign.getBroadCast( itemData.type, itemData.name, itemData.reward ))
	end

	local function createFunc( itemData, idx )
		local view = UIBaseDef:cloneOneView(self.rich_1)

		updateItem(view, itemData, idx)
		return view
	end

	local function updateCellFunc( itemData, view, idx )
		updateItem(view, itemData, idx)
	end

	local broadList = NewSignModel:getBroadList()
	-- dump(broadList, "broadList")
	-- local broadList = {
	-- 	{
	-- 		name = "大小",
	-- 		type = 2,
	-- 		reward = "1,1019,1",
	-- 		time = 1,
	-- 	}
	-- }

	-- table.sort(broadList, function(a, b)
	-- 	return tonumber(a.time) < tonumber(b.time)
	-- end)

	local scrollParams = {
		{
			data = broadList,
			createFunc = createFunc,
			updateCellFunc = updateCellFunc,
			perFrame = 1,
			offsetX = 0,
			offsetY = 15,
			itemRect = {x = 0,y = 0,width = 323,height = 27},
		}
	}
	-- echo("拉取信息")
	local scrollList = self.scroll_1

	scrollList:styleFill(scrollParams)
end

-- 签筒
function NewSignView:updateTicksContainer()
	local panel = self
	local ctn = panel.ctn_chou
	ctn:removeAllChildren()
	-- echo("去到哪里", NewSignModel:isTodaySigned())
	-- 特效
	if NewSignModel:isTodaySigned() then -- 已经签过
		-- 摇动
		self:AccelerateEnabled(false)
		-- 加一个假的晃动动画
		-- self:addswing(false)

		self:createUIArmature("UI_sign", "UI_sign_chouwan", ctn, true, nil)
		-- 触摸层
		local panel_click = display.newNode()
		panel_click:anchor(0.5, 0)
		panel_click:size(178, 185)
		panel_click:addTo(ctn)
		panel_click:setTouchedFunc(function() 
			WindowControler:showTips(GameConfig.getLanguage("#tid_sign_1011"))
		end)
	else
		-- 摇动
		self:AccelerateEnabled(true)
		-- 停止动画
		-- self:addswing(true)
		self:createUIArmature("UI_sign", "UI_sign_tishi", ctn, true, nil)
		-- 触摸层
		local panel_click = display.newNode()
		panel_click:anchor(0.5, 0)
		panel_click:size(204, 330)
		panel_click:addTo(ctn)
		panel_click:setTouchedFunc(function()
			echo("抽签弹奖励")
			self:startRoll(1)
		end)
	end
end

-- 加一个假的晃动动画
function NewSignView:addswing( enable )
	local panel = self
	if enable then
		panel.mc_chou:runAction(cc.RepeatForever:create(
			cc.Sequence:create({
				cc.DelayTime:create(2),
				cc.RotateBy:create(0.1, -10),
				cc.RotateBy:create(0.2, 20),
				cc.RotateBy:create(0.2, -10),
			})
		))
	else
		panel.mc_chou:stopAllActions()
	end
end

-- 抽奖 @@tType 1普通抽2摇一摇
function NewSignView:startRoll(tType)
	if self._playRolling then return end
	self._playRolling = true
	AudioModel:playSound(MusicConfig.s_sign_yaoqian, false)
	-- 开启抽奖直接停掉
	self:AccelerateEnabled(false)
	NewSignServer:drawRequest({
		tType = tType,
		callBack = function(params)
			-- self._playRolling = false
			-- WindowControler:showWindow("NewSignGetQianView",params)
			
		end
	})

	local panel = self
	local ctn = panel.ctn_chou
	ctn:removeAllChildren()

	local rollAnim = self:createUIArmature("UI_sign", "UI_sign_chouqian", ctn, false, function()
		self:updateTicksContainer()
	end)

	rollAnim:registerFrameEventCallFunc(45, 1, function()
		self._playRolling = false
		if NewSignModel:getSignReward() then
	    	WindowControler:showWindow("NewSignGetQianView",params)
	    else
		    WindowControler:showTips(GameConfig.getLanguage("#tid_sign_1012"))
		end
	end)
end

-- 摇动抽奖
function NewSignView:AccelerateEnabled(enable)
	-- echo("cc.bPlugin_",cc.bPlugin_)
	-- 创建一个layer用于监听重力事件
	local listener = cc.EventListenerAcceleration:create(function(event, x, y, z, timestamp)
		echo("x: " .. x)
		echo("y: " .. y)
		echo("z: " .. z)
		echo("timestamp: " .. timestamp)
		x = x * 10
		y = y * 10
		-- if math.abs(x) > 10 or math.abs(y) > 10 then
		-- 	-- 开启抽奖
		-- 	self:startRoll(2)
	 --    end

	    if math.abs(x) > 10 then
	    	self._rollX = self._rollX + 1
	    end
	    if math.abs(y) > 10 then
	    	self._rollY = self._rollY + 1
	    end
	    local LIMIT = 3
	    if self._rollX > LIMIT and self._rollY > LIMIT then
	    	self._rollX = 0
	    	self._rollY = 0
	    	-- 开启抽奖
	    	self:startRoll(2)
	    end
	end)
	
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

	if enable then
		self._rollX = 0
    	self._rollY = 0
		cc.Device:setAccelerometerEnabled(true)
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	else
		eventDispatcher:removeEventListener(listener)
		cc.Device:setAccelerometerEnabled(false)
	end
end
-- 更新累充奖励
function NewSignView:updateTotalIcon()
	local panel = self
	--红点
	-- self:updateTab()
	-- 累抽奖励
	local details = NewSignModel:nowTotalReceiveDetail()
	-- dump(details, "details")
	for i=1,3 do
		self:updateRewardIcon(panel["panel_Cell" .. i], details[i])
	end
end
-- 处理累积奖励
function NewSignView:updateRewardIcon(view, detail)
	local panel = view.panel_1
	local anictnUp = view.panel_1.ctn_s1
	local anictnDown = view.panel_1.ctn_s2

	anictnDown:removeAllChildren()
	anictnUp:removeAllChildren()

	-- vip标签(暂时屏蔽)
	if detail.data.vip == 0 then
		panel.mc_xz:visible(false)
	else
		panel.mc_xz:visible(false)
		-- panel.mc_xz:showFrame(detail.data.vip)
	end

	local totalSignCount = NewSignModel:totalSignCount()
	-- 领取的字
	panel.mc_ci:showFrame(totalSignCount < tonumber(detail.data.day) and 1 or 2)
	panel.mc_ci.currentView.txt_1:setString(totalSignCount .. "/" .. detail.data.day)
	-- 图标
	panel.UI_1:setResItemData({reward = detail.data.reward[1]})

	-- 形状
	local frame = FuncCommon.getShapByReward( detail.data.reward[1] )
	
	panel.UI_1:setTouchedFunc(function() end)

    if tonumber(detail.isGet) == 0 then -- 未领取
    	-- 打钩
    	panel.mc_2:visible(false)
    	-- 继续领取
    	panel.panel_lq:visible(false)
    	-- 是否可领取
    	if totalSignCount >= tonumber(detail.data.day) then
    		self:addGetAnimation(detail.data.reward[1], anictnDown, anictnUp)

    		panel.UI_1:setTouchedFunc(function()
    			-- 领取
    			NewSignServer:getTotalReward({
    				day = detail.data.day,
    				callBack = function()
    					-- local params
    					local reward
    					if NewSignModel:isVipEnable( detail.data.vip ) then
    						-- params = {
    						-- 	vip = UserModel:vip(),
    						-- 	vtype = 1,
    						-- 	reward = detail.data.reward[1],
	    					-- }
	    					reward = detail.data.reward
	    				else
	    					-- params = {
	    					-- 	vip = detail.data.vip,
	    					-- 	vtype = 2,
	    					-- 	reward = detail.data.reward[1],
		    				-- }
		    				reward = detail.data.reward
    					end
    					-- WindowControler:showWindow("NewSignGetTotalView",params)
    					EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
    					WindowControler:showWindow("RewardSmallBgView",reward)
    				end
    			})
    		end)
    		-- 点击领取
    		panel.panel_lqlv:visible(true)
    	else
    		self:registClick(panel.UI_1, detail.data.reward[1])
    		-- 点击领取
    		panel.panel_lqlv:visible(false)
    	end
	elseif tonumber(detail.isGet) == 1 then -- 普通领取
		-- 打钩
		panel.mc_2:visible(true)
		if frame == 1 then
			panel.mc_2:showFrame(1)
		else
			panel.mc_2:showFrame(3)
		end
		-- 继续领取
		-- panel.panel_lq:visible(true)
		-- 是否可领取
		if NewSignModel:isVipEnable( detail.data.vip ) then
			self:addGetAnimation(detail.data.reward[1], anictnDown, anictnUp)
			panel.UI_1:setTouchedFunc(function()
				-- VIP领取
				NewSignServer:getTotalReward({
    				day = detail.data.day,
    				callBack = function()
    					-- local params = {
    						-- vip = UserModel:vip(),
    						-- vtype = 3,
    						-- reward = detail.data.reward[1],
	    				-- }
	    				local reward = detail.data.reward,
    					-- WindowControler:showWindow("NewSignGetTotalView",params)
    					WindowControler:showWindow("RewardSmallBgView",reward)
    				end
    			})
			end)
			-- 点击领取(暂时处理)
    		panel.panel_lqlv:visible(false)
    		-- 继续领取
			panel.panel_lq:visible(false)
		else
			-- panel.UI_1:setTouchedFunc(function()
			-- 	-- 弹vip提示
			-- 	WindowControler:showWindow("NewSignTipsView",detail.data.vip)
			-- end)
			-- 继续领取（暂时处理）
			panel.panel_lq:visible(false)
			-- 点击领取
    		panel.panel_lqlv:visible(false)
		end
    elseif tonumber(detail.isGet) == 2 then -- 已vip领取
    	-- 打钩
    	panel.mc_2:visible(true)
    	if frame == 3 then
        	panel.mc_2:showFrame(2)
        else
        	panel.mc_2:showFrame(1)
        end
    	-- 继续领取
    	panel.panel_lq:visible(false)
    	-- 点击领取
		panel.panel_lqlv:visible(false)

    	panel.UI_1:setTouchedFunc(function()
    		WindowControler:showTips(GameConfig.getLanguage("tid_activity_1002"))
    	end)
    end
end


function NewSignView:setBetButton()
	



end

-- 给一个物品加点击
function NewSignView:registClick( UI, sReward )
	local reward = string.split(sReward, ",")
	local rewardType = reward[1]
	local rewardNum = reward[#reward]
	local rewardId = reward[#reward - 1]

	FuncCommUI.regesitShowResView(UI, rewardType, rewardNum, rewardId, sReward, true, true)
end

function NewSignView:updateUI()
	self:showUI(NEW_SIGN_TYPE.DAILYSIGN)
end

-- 给可领取物品加一个特效
function NewSignView:addGetAnimation( reward, ctndown, ctnup )
	-- ctndown:removeAllChildren()
	-- ctnup:removeAllChildren()
	local _effectType = {
		[1] = {
			down = "UI_shop_fangxiaceng",
			up = "UI_shop_fangshangceng",
		},
		[2] = {
			down = "UI_shop_yuanxiaceng",
			up = "UI_shop_yuanshangceng",
		},
		[3] = {
			down = "UI_shop_lenxiaceng",
			up = "UI_shop_lenshangceng",
		},
	}
	local frame = FuncCommon.getShapByReward(reward)
	local anim1 = self:createUIArmature("UI_shop", _effectType[frame].down, ctndown, true, nil)
	anim1:setScale(0.8)
	local anim2 = self:createUIArmature("UI_shop", _effectType[frame].up, ctnup, true, nil)
	anim2:setScale(0.8)

end

function NewSignView:press_btn_close()
	self:AccelerateEnabled(false)
	EventControler:dispatchEvent(NewSignEvent.SIGN_OUT_EVENT)
	self:startHide()
end
function NewSignView:refreshUI()
	-- body
end
return NewSignView