--[[
	Author: lxh
	Date:2018-08-08
	Description: 开服累充界面
]]

local WelfareLeiChongView = class("WelfareLeiChongView", UIBase);

function WelfareLeiChongView:ctor(winName)
    WelfareLeiChongView.super.ctor(self, winName)
end

function WelfareLeiChongView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WelfareLeiChongView:registerEvent()
	WelfareLeiChongView.super.registerEvent(self);

	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
	EventControler:addEventListener(ActivityEvent.ACTEVENT_CONDITION_NUMCHANGE_EVENT, self.reFreshUI, self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR_COMPLETE, self.reFreshUI, self)
end

function WelfareLeiChongView:reFreshUI( )
	if not self.actData then 
		return 
	end
	self:initListUI( )
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end

function WelfareLeiChongView:onTaskFinished(event)
	if not self.actData then 
		return 
	end

	local params = event.params
	local onlineId = params.onlineId
    local tastId = params.taskId
	if onlineId == self.actData:getOnlineId() then
		self:initListUI()
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	end
end

function WelfareLeiChongView:initData()
	-- TODO
end

function WelfareLeiChongView:initView()
	-- TODO
end

function WelfareLeiChongView:initViewAlign()
	-- TODO
end

function WelfareLeiChongView:updateUI()
	-- TODO
end

function WelfareLeiChongView:updateWinthActInfo(actData)
	self.actData = actData
	self.actInfo = actData:getActInfo()
	self.actOnlineId = self.actData:getOnlineId()
	self.mc_1:showFrame(2)
	self.ctn_1:removeAllChildren()
	--策划说写死的 神器 五灵轮
	local artifactId = "403"
	local artifactInfo =  FuncArtifact.byIdgetCCInfo(artifactId)
    local  sprite = ViewSpine.new(artifactInfo.spine,nil,nil,nil);
    sprite:playLabel("stand");
	self.ctn_1:addChild(sprite)  --宝物图片

	self.txt_1:setString(GameConfig.getLanguage(artifactInfo.combineName))
	local node = display.newNode()
	node:setContentSize(cc.size(300, 300))
	node:anchor(0.5, 0.5)
	node:addTo(self.ctn_1, 1)

	local artifactData = ArtifactModel:byIdgetData(artifactId)
	artifactInfo.qualityData = artifactData

	node:setTouchedFunc(function ()
			WindowControler:showWindow("RankListArtifactDetailView", artifactInfo)
		end)
    self.currentFrame = 30
	self:updateTime( )
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

	self:initListUI()
end

function WelfareLeiChongView:initListUI( )	
	local listData = {}
	for i,v in pairs(self.actInfo.taskList) do
		table.insert(listData, v)
	end
	--排序 需要有沉底逻辑
	table.sort(listData,c_func(self.sortFunc,self))

    self.listData = listData
	self:initList(listData)
end

function WelfareLeiChongView:sortFunc(taskIdA, taskIdB)
	local getA = ActTaskModel:isTaskFinished(self.actOnlineId, taskIdA, self.actInfo)
	local getB = ActTaskModel:isTaskFinished(self.actOnlineId, taskIdB, self.actInfo)
	if getA == getB then
		local finishNumA,allNumA = ActConditionModel:getTaskConditionProgress(self.actOnlineId, taskIdA)
		local finishNumB,allNumB= ActConditionModel:getTaskConditionProgress(self.actOnlineId, taskIdB)
		if finishNumA >= allNumA and finishNumB >= allNumB then
			-- 都可以领取
			if tonumber(taskIdA) < tonumber(taskIdB) then
				return true
			end
			return false
		elseif finishNumA < allNumA and finishNumB < allNumB then 
			-- 都不可以领取
			if tonumber(taskIdA) < tonumber(taskIdB) then
				return true
			end
			return false
		else
			if finishNumA >= allNumA then
				return true
			else
				return false
			end
		end

	else
		if not getA then
			return true
		end
		return false
	end
	return false
end

--加载滚动条
function WelfareLeiChongView:initList(listData)
	self.panel_tiao:visible(false)
	local createCellItemFunc = function ( itemData)
		local view = UIBaseDef:cloneOneView(self.panel_tiao)
		self:updateCellItem(view, itemData)
		return view
	end
	local updateCellItemFunc = function (itemData,itemView)
        self:updateCellItem(itemView, itemData)
    end
	local scrollParams = {
		{
			data = listData,
			createFunc = createCellItemFunc,
            updateCellFunc = updateCellItemFunc,
			offsetX = 0,
            offsetY = -5,
			perFrame = 1,
			itemRect = {x = 0, y = -135, width = 540, height = 135},
			perNums= 1,
			heightGap = 0
		}
	}
	self.scroll_1:styleFill(scrollParams)
    self.scroll_1:hideDragBar()

    if not self._lastIndex then
    	self._lastIndex = 1
    end
    self.scroll_1:gotoTargetPos(self._lastIndex, 1, 1)
end

--加载滚动条 组件
function WelfareLeiChongView:updateCellItem(view, itemData)
	local panel = view
	local actTaskId = itemData
	local actTaskData = FuncActivity.getActivityTaskConfig(actTaskId) 
	local des = actTaskData.desc
	local conditionNum = actTaskData.conditionNum

	for i = 1, 4 do
		panel["panel_"..i].UI_1:setVisible(false)
	end

	--在哪个位置加光效
	local effectPos = actTaskData.effectPosition

	-- 奖励
	local rewards = actTaskData.reward

	for i,v in pairs(rewards) do
		local commUI = panel["panel_"..i].UI_1
		commUI:setVisible(true)
		commUI:setRewardItemData({reward = v})
        -- 注册点击事件
        local resNum, _, _, resType, resId = UserModel:getResInfo(v)
    	FuncCommUI.regesitShowResView(commUI, resType, resNum, resId, v, true, true)
    	self:updateItemEffect(v,effectPos,panel["panel_"..i],i)
	end

	-- 完成进度
	local actOnlineId = self.actData:getOnlineId()
	local finishNum,allNum = ActConditionModel:getTaskConditionProgress(actOnlineId, actTaskId)

	local finishNumWan = FuncCommUI.turnOneNumToStr(finishNum )
	local allNumWan = FuncCommUI.turnOneNumToStr(allNum)
	local hasGotTimes = 0
 	local txt_process = "<color=008c0d>"..finishNumWan.."/"..allNumWan.."<->"
 	panel.rich_1:setString(GameConfig.getLanguageWithSwap(des, txt_process))
	
	-- 判断是否已领取
	local mc_btn = panel.mc_btn
	local isGet = ActTaskModel:isTaskFinished(actOnlineId, actTaskId, self.actData:getActInfo())
	if not isGet then
		local btn = nil
		local isCanGet = false

		local isConditionOk = (finishNum >= allNum)

		if isConditionOk then
			-- 可领取
			mc_btn:showFrame(1)
			btn = mc_btn.currentView.btn_1
			isCanGet = true
		else
			-- 前往
			mc_btn:showFrame(2)
			btn = mc_btn.currentView.btn_1
		end
		btn:setTap(c_func(self.btnTap,self,isCanGet,actOnlineId,actTaskId))
	else
		mc_btn:showFrame(3)
	end
end

--添加item上的闪光特效
function WelfareLeiChongView:updateItemEffect(itemData, effectPos, panel, index)
    local ctnUp = panel.ctn_shang
    local ctnDown = panel.ctn_xia
    if effectPos then
        if effectPos[index] and tonumber(index) == tonumber(effectPos[index]) then
            -- 需要特效且该特效不存在时才新建特效
            -- if not ctnUp:getChildByName("ani1") then
            ctnUp:removeAllChildren()
            ctnDown:removeAllChildren()
            local ani1, ani2 = self:addAnimation(itemData, ctnUp, ctnDown)
                -- ani1:setName("ani1")
                -- ani2:setName("ani2")
            -- end
            -- ctnUp:getChildByName("ani1"):setVisible(true)
            -- ctnDown:getChildByName("ani2"):setVisible(true)

        else
            -- if ctnUp:getChildByName("ani1") then
                ctnUp:removeAllChildren()
                ctnDown:removeAllChildren()
                -- ctnUp:getChildByName("ani1"):setVisible(false)
                -- ctnDown:getChildByName("ani2"):setVisible(false)
            -- end                           
        end
    else
        ctnUp:removeAllChildren()
        ctnDown:removeAllChildren()
        -- if ctnUp:getChildByName("ani1") then
        --     ctnUp:getChildByName("ani1"):setVisible(false)
        --     ctnDown:getChildByName("ani2"):setVisible(false)
        -- end
    end
end

function WelfareLeiChongView:addAnimation(reward, ctnUp, ctnDown)
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
    -- echo("\nreward==", reward, frame)
    local ani1 = self:createUIArmature("UI_shop", _effectType[frame].up, ctnUp, true, nil)
    local ani2 = self:createUIArmature("UI_shop", _effectType[frame].down, ctnDown, true, nil)
    ani1:setScale(0.8)
    ani1:pos(0, 0)
    ani2:setScale(0.8)
    ani2:pos(0, 0)
    return ani1, ani2
end

--点击了领取或者前往按钮
function WelfareLeiChongView:btnTap(isCanGet,onlineId, taskId)
	if isCanGet then
		ActTaskModel:tryFinishTask(onlineId, taskId)
	else
		-- 前往
		ActTaskModel:jumpToTaskLinkView(taskId)
	end
end

--倒计时
function WelfareLeiChongView:updateTime( )
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local leftTime = self.actData:getDisplayLeftTime()
		self.txt_3:setString(fmtSecToLnDHHMMSS(leftTime))
	end
	self.currentFrame = self.currentFrame + 1
end

function WelfareLeiChongView:deleteMe()
	-- TODO

	WelfareLeiChongView.super.deleteMe(self);
end

return WelfareLeiChongView;
