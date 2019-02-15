--
--Author:      zhuguangyuan
--DateTime:    2017-09-13 14:00:19
--Description: 锁妖塔小游戏界面
--

local TowerPuzzleGameView = class("TowerPuzzleGameView", UIBase);

function TowerPuzzleGameView:ctor(winName,npcID,npcPos)
    TowerPuzzleGameView.super.ctor(self, winName)
    self.npc = npcID or "1002"
    self.npcPos = npcPos or {}
end

function TowerPuzzleGameView:loadUIComplete()
	self:initData()
	self:initView()

	self:registerEvent()
	self:initViewAlign()

	self:updateUI()
end 

function TowerPuzzleGameView:registerEvent()
	TowerPuzzleGameView.super.registerEvent(self);
	self.UI_1.btn_1:setTap(c_func(self.viewClose, self))	

	EventControler:addEventListener(TowerEvent.TOWEREVENT_MINIGAME_TIME_OUT, self.timeOut, self)

	-- 时钟更新
    -- self.updateFrame 会间隔1秒循环调用
    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self), 0);
end

function TowerPuzzleGameView:timeOut(  )
	self.isTimeOut = true
	if not self.isSucceed then 
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_053"))
		self:viewClose()
	end
end
function TowerPuzzleGameView:onSucceed()
	self.isSucceed = true
    if not self.isTimeOut then
    	self.isBegin = false
		self.mc_1:showFrame(2)
		local currentView = self.mc_1.currentView
		-- 展示奖励
		local rewardString = self.npcEventData["reward"]
    	local str1 = rewardString[1]
    	local reward = string.split(rewardString[1],",")
    	local rewardType = reward[1];
		local rewardNum = reward[table.length(reward)];
		local rewardId = reward[table.length(reward) - 1];
    	local params = {
        	reward = str1,
	    }

	    --拼图动画
    	local completeAni = self:createUIArmature("UI_suoyaota","UI_suoyaota_pintuwancheng",self.ctn_map, false,GameVars.emptyFunc) 

	    currentView.UI_1:setResItemData(params)
	    FuncCommUI.regesitShowResView(currentView.UI_1,
        	rewardType,rewardNum,rewardId,rewardString[1],true,true)

	    -- 奖励上方的一段话
		currentView.txt_1:setString(self.string3)

		currentView.btn_1:setTouchedFunc(
			function ()
				-- WindowControler:showTips("往服务器发送数据,展示奖励界面")
				-- 往服务器发送数据
				-- 展示奖励界面
				local params = {
					eventId = self.npcData.event[1],
					x = self.npcPos.x,
					y = self.npcPos.y,
				}
			TowerServer:chooseNpcEvent(params,c_func(self.getReward,self))
	    	end
    	)
	end
end
function TowerPuzzleGameView:viewClose( )
	local params = {
					eventId = self.npcData.event[1],
					x = self.npcPos.x,
					y = self.npcPos.y,
					failed = 1,
			}
	TowerServer:chooseNpcEvent(params,c_func(self.closeEffect,self))
end

function TowerPuzzleGameView:closeEffect(event)
	if event.error then

	else
		TowerMainModel:updateData(event.result.data)
		self:startHide()
	end
end

function TowerPuzzleGameView:initData()
	self.npcEventData = FuncTower.getNpcEvent(1003)

	self.stringTitle = GameConfig.getLanguage(self.npcEventData.parameter[1])
	self.string2 = GameConfig.getLanguage(self.npcEventData.parameter[2])
	self.string3 = GameConfig.getLanguage(self.npcEventData.parameter[3])
	self.puzzleBg = FuncRes.iconTowerEvent(self.npcEventData.parameter[4])
	echo("\n\n\n\n\n--------------- ",self.stringTitle,self.string2,self.string3)

	self.isBegin = false
	self.isTimeOut = false
	self.isSucceed = false

	-- 定时器相关变量
	self.leftTime = 0
	self.frameCount = 0

	--读取npc事件的ID
	self.npcData = FuncTower.getNpcData(self.npc)
end

function TowerPuzzleGameView:initView()
	local puzzleSprite = display.newSprite(self.puzzleBg)
	self.puzzleSprite = puzzleSprite
	puzzleSprite:anchor(0.5,0.5)

	self.gameView = display.newNode():addto(self.ctn_map)

	-- TODO
	self.gameView:pos(-130,-220)
	-- puzzleSprite:addto(self.gameView)

	self:cutPuzzleImage()
	self:updateGridView()


	self.UI_1.txt_1:setString(self.stringTitle)

	self.mc_1:showFrame(1)
	self.mc_1.currentView.mc_time:showFrame(2)
	local currentView = self.mc_1.currentView.mc_time.currentView
	currentView.mc_1:showFrame(5)
	-- 计时器上方的一段话
	self.mc_1.currentView.txt_1:setString(self.string2)
	-- 点击开始
	self.mc_1.currentView.btn_1:setTap(
		function ()
        	self.isBegin = true
        	self.leftTime = 40
        	self.mc_1.currentView.btn_1:visible(false)
    	end
    )
end

-- 计时器
function TowerPuzzleGameView:updateFrame()
    if self.isBegin and self.leftTime == -1 then
    	self.isBegin = false
    	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_MINIGAME_TIME_OUT,{})
        return
    end

    if self.frameCount % GameVars.GAMEFRAMERATE == 0 and self.isBegin then 
		local decade = nil
		local unit = nil 
		if self.leftTime == 0 then
			decade = 1
			unit = 1
		else
			decade,unit = math.modf(self.leftTime/10)
			decade = decade + 1
			unit = math.floor(unit*10 + 0.1) + 1
		end

		echo("\n\n------ decade,unit ------ ",decade,unit)

		if dedade ~= 0 then	
			self.mc_1.currentView.mc_time:showFrame(2)
			local currentView = self.mc_1.currentView.mc_time.currentView
			currentView.mc_1:showFrame(decade)
			currentView.mc_2:showFrame(unit)
		else
			self.mc_1.currentView.mc_time:showFrame(1)
			local currentView = self.mc_1.currentView.mc_time.currentView
			currentView.mc_1:showFrame(unit)
		end
        self.leftTime = self.leftTime - 1; 
    end 
    self.frameCount = self.frameCount + 1;
end


function TowerPuzzleGameView:initViewAlign()
	-- TODO
end

function TowerPuzzleGameView:updateUI()
	-- TODO
end



function TowerPuzzleGameView:cutPuzzleImage()
	local col = 3
	local row = 3

	self.cellImgArr = {}
	-- self.puzzleSprite:setScale(0.4)
	local contentSize = self.puzzleSprite:getContentSize()
	local width = contentSize.width / col
	local height = contentSize.height / row
	local width = 384 / col
	local height = 384 / row
	for i=1,row do
		for j=1,col do
			local x = (j-1) * width
			local y = (i-1) * height

			local cellImg = cc.Sprite:create(self.puzzleBg,cc.rect(x,y,width,height))
			local angle = RandomControl.getOneRandomInt(4,0) * 90
			echo("\ni,j,angle ------------ ",i,j,angle)
			local cellInfo = {}

			local posx = x
			-- TODO
			local posy = 350 - (i-1) * height
			cellImg:pos(posx,posy)
			self:initCellImgTouchEvent(cellImg,i,j)

			cellImg:anchor(0.5,0.5)
			cellInfo.xIdx = i
			cellInfo.yIdx = j
			cellInfo.angle = angle
			cellInfo.img = cellImg

			local id = i .. "_" .. j
			cellImg:addto(self.gameView)
			self.cellImgArr[id] = cellInfo
		end
	end
end

function TowerPuzzleGameView:initCellImgTouchEvent(cellImg,xIdx,yIdx)
	if cellImg then
		cellImg:setTouchedFunc(c_func(self.onClickCellImg,self,xIdx,yIdx))
	end
end

-- 点击计算旋转角度，并更新显示
function TowerPuzzleGameView:onClickCellImg(xIdx,yIdx)
	if not self.isBegin then
		return
	end
	local id = xIdx .. "_" .. yIdx
	local cellInfo = self.cellImgArr[id]
	cellInfo.angle = cellInfo.angle + 90
	if cellInfo.angle > 360 then
		cellInfo.angle = cellInfo.angle - 360
	end
	self.cellImgArr[id].angle = cellInfo.angle

	echo("\ni,j,angle ------------ ",xIdx,yIdx,self.cellImgArr[id].angle)

	self:updateGridView()
end

-- 遍历展示所有的小块
function TowerPuzzleGameView:updateGridView()
	local flag = true
	for key,info in pairs(self.cellImgArr) do
		local cellImg = info.img
		local angle = info.angle
		echo("\ni,j,angle ------------ ",info.xIdx, info.yIdx,info.angle)
		cellImg:setRotation(angle)
		if angle ~= 360 and angle ~= 0 then
			flag = false
		end
	end
	if flag == true then
		self:onSucceed()
	end
end


function TowerPuzzleGameView:deleteMe()
	-- TODO
	self:unscheduleUpdate()
	TowerPuzzleGameView.super.deleteMe(self);
	
end

function TowerPuzzleGameView:getReward(event)
	if event.error then

	else
		TowerMainModel:updateData(event.result.data)
        local goodsReward = {}
        -- WindowControler:showWindow("RewardSmallBgView", event.result.data.reward)
        WindowControler:showWindow("TowerGetRewardView",event.result.data.reward,goodsReward)
        self:startHide()
	end
end

return TowerPuzzleGameView;
