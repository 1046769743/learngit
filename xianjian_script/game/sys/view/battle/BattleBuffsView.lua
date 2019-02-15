--
-- Author: pangkangning
-- Note:回合刷新buff玩法
-- Date: 2018-07-24 
--
local BattleBuffsView = class("BattleBuffsView", UIBase)

local rewardType = {
	gold = 1, --金币
	white = 2,--白虫子
	green = 3,--绿虫子
	blue = 4, --蓝虫子
	stone = 5 , --强化石
}

function BattleBuffsView:ctor(winName)
    BattleBuffsView.super.ctor(self, winName)
	self.buffsArr = {}
end

function BattleBuffsView:loadUIComplete(  )
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_3,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buffs,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_4,UIAlignTypes.RightTop)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_USE_BUFF, self.onUseBuff, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BUZHEN_CANCLE, self.onBuZhenCanel, self)
    -- 刷怪后刷新
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_WAVE_REFRESH, self.updateWaveAndCount, self)
    
    -- 答题事件刷新
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ANSWER_UPDATE, self.updateAnswerView, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_TRIAL_ITEM_UPDATE, self.updateTrialView, self)
    -- 回合上线到达
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_WAVE_MAX, self.onWaveMax, self)
    
end

function BattleBuffsView:initControler( view,controler )
    self._battleView = view
    self.controler = controler
	self:visible(true)
	self.panel_3:visible(false) --坚持更多回合
	self.panel_buffs:visible(false)--buff所在panel
	self.panel_4:visible(false) --获得金币数
	self.panel_2:visible(false) --下波刷怪
	self.panel_1:visible(false) --答题玩法
	-- 如果是试炼、则显示试炼相关的ui
	if BattleControler:checkIsTrail() ~= Fight.not_trail then
		self.panel_4:visible(true)
		local bCount,mCount,rewardType = self.controler:getTrialSimpleReward()
		-- 存储奖励个数
		self.trialArr = {rType=rewardType,mCount = mCount,bCount=bCount}
		self.panel_4.mc_1:showFrame(rewardType)
		self.panel_4.txt_1:setString(0)
		local p = self.controler.levelInfo.battleInfo.battleParams
		local data = FuncTrail.byIdgetdata(p.trialId)
		local str = GameConfig.getLanguage(data.targetDes)
		self:addExAnim(str)
	end
end
-- 添加特效
function BattleBuffsView:addExAnim(str )
	if not self._anim then
		-- 播放坚持更多回合特效
		self._anim = self:createUIArmature("UI_zhandoud","UI_zhandoud_jianchigengduo", self, false,GameVars.emptyFunc)
		self._anim:pos(GameVars.halfResWidth,-GameVars.halfResHeight + 135)
	end
	self._anim:playWithIndex(0,0)

	self.panel_3.txt_1:setString(str)

	local node1 = UIBaseDef:cloneOneView(self.panel_3)
	node1.txt_1:setString(str)
	node1:pos(-200,25)
	FuncArmature.changeBoneDisplay(self._anim,"node1",node1)

	local node2 = UIBaseDef:cloneOneView(self.panel_3)
	node2.txt_1:setString(str)
	node2:pos(-200,25)
	FuncArmature.changeBoneDisplay(self._anim,"node2",node2)
end
function BattleBuffsView:onWaveMax( )
	local str = GameConfig.getLanguage("#tid_trial_30156")
	self:addExAnim(str)
end

function BattleBuffsView:onBuZhenCanel( )
	self.panel_buffs:visible(false)
end


-- 回合开始
function BattleBuffsView:onRoundStart(event)
    if self.controler:isQuickRunGame() then
        return
    end
	local camp = event.params
	if self.controler.logical:checkIsAutoAttack(camp) then
		return
	end
	if camp == Fight.camp_1 then
		self:updateBuffView()
		self:updateWaveAndCount()
		self:updateAnswerView()
	end
end
-- 更新试炼掉落物品变化相关
function BattleBuffsView:updateTrialView(event)
	if not self.trialArr then
		return
	end
	local pos,showCount
	if event.params then
		pos = event.params.myView:convertToWorldSpace(cc.p(0,0))
		showCount = event.params.data:dropCount()
		if showCount == 0 then
			showCount = 19
		end
	else
		pos = self.panel_1.mc_dui:convertToWorldSpace(cc.p(0,0))
		pos = cc.p(pos.x+30,pos.y-40)
		showCount = 7
		echo("盗宝者答对题目动画====")
		local rqArr = self.controler:getQUseArr()
		for i=1,4 do
			if rqArr[i] then
				local p = self.panel_1["panel_"..i]
				self:_playShowAnim(p,cc.p(20,-23))
			end
		end
	end
	local data = self.controler:getTrialResult()
	local count = data.bossNum * self.trialArr.bCount + data.monsterNum * self.trialArr.mCount
	-- self.panel_4.txt_1:setString(count)
	-- self:addDropAnim(x,y)
	self:playDropItemAnim(pos.x,pos.y,count,showCount)
end
-- 掉落动画
function BattleBuffsView:playDropItemAnim(x,y,count,showCount)
	local tmpArr = {}
	for i=1,19 do
		table.insert(tmpArr,i)
	end
	local showArr = RandomControl.getNumsByGroup(tmpArr,showCount)
	-- 哪个bone显示
	local _setBoneVisible = function( anim,inArr)
		for i=1,19 do
			local str = "w"..i
			if i < 10 then
				str = "w0"..i
			end
			if table.isValueIn(inArr,i) then
				anim:getBone(str):visible(true)
				anim:getBoneDisplay(str):playWithIndex(self.trialArr.rType - 1)
			else
				anim:getBone(str):visible(false)
			end
		end
		anim:getBoneDisplay("x01"):playWithIndex(self.trialArr.rType - 1)
		anim:getBoneDisplay("x02"):playWithIndex(self.trialArr.rType - 1)
		anim:getBoneDisplay("x03"):playWithIndex(self.trialArr.rType - 1)
	end

	local str = "UI_shilian_zhandou_diaoluo"
	local gameUi = self.controler.gameUi
	local _anim
	_anim = gameUi:createUIArmature("UI_shilian_zhandou",str, self.panel_4, false,function( )
		_anim:playWithIndex(1,0)
		_setBoneVisible(_anim,showArr)
		transition.execute(_anim,cc.Sequence:create(
			cc.MoveTo:create(40/GameVars.GAMEFRAMERATE,cc.p(30,-20)),
			cc.DelayTime:create(10/GameVars.GAMEFRAMERATE)),{ onComplete = function()
	        	_anim:removeFromParent()
	        	self.panel_4.txt_1:setString(count)
	        	self.panel_4.mc_1:runAction(cc.Repeat:create(
	        		cc.Sequence:create(cc.ScaleTo:create(0.2,1.1),cc.ScaleTo:create(0.2,1.0)),2))
        	end})
	end)
	_anim:playWithIndex(0,0)
	_setBoneVisible(_anim,showArr)
    local pos = self.panel_4:convertToNodeSpace(cc.p(x,y))
    _anim:pos(cc.p(pos.x,pos.y))
end
function BattleBuffsView:addDropAnim(x,y,count)
	-- 添加飘的特效
    local pNode = FuncArmature.getParticleNode( "buff_tuowei" ):addTo(self.panel_4)
    pNode:setStartColor(cc.c4b(0,234/255, 1,1))
    pNode:setEndColor(cc.c4b(0,234/255,1,1))
    local size = self.panel_4:getContainerBox()
    local pos = self.panel_4:convertToNodeSpaceAR(cc.p(x,y))
    pNode:pos(cc.p(pos.x*Fight.cameraWay,pos.y))
    transition.moveTo(pNode,
        {x =size.width/2, y = -size.height/2, time =1,
        -- easing = "exponentialIn",
        onComplete = function( )
        	pNode:removeFromParent()
        	self.panel_4.txt_1:setString(count)
        end
    })
end

-- 更新答题ui
function BattleBuffsView:updateAnswerView( )
	if not self.controler.levelInfo:chkIsAnswerType() then
		return
	end
	local rqData = self.controler:getRefreshQuestion()
	local rqArr = self.controler:getQUseArr()
	local view = self.panel_1
	if not rqData then
		view:visible(false)
		return
	end
	view:visible(true)
	view.mc_dui:visible(false)
	local count = #rqData.formulary
	if count == 5 then
		view.mc_3:visible(false)
		view.panel_4:visible(false)
		view.panel_3.mc_1:showFrame(1)
	elseif count == 7 then
		view.mc_3:visible(true)
		view.panel_4:visible(true)
		view.panel_4.mc_1:showFrame(1)
	end
	for i=1,count do
		local value = rqData.formulary[i]
		local num1,num2 = math.modf(i/2)
		if num2 == 0 then
			-- 偶数是符号位
			local tmpView = view["mc_"..num1]
			tmpView:showFrame(Fight.answer_frame[value])
		else
			local tmpView = view["panel_"..num1+1]
			if not value or value == "" then
				tmpView.mc_1:showFrame(1)
			else
				tmpView.mc_1:showFrame(2)
				if rqArr[i] then
					if rqArr[i] == 1 then
						self.controler:resetQUseArr()
						-- 添加特效
						self:_playShowAnim(tmpView,cc.p(20,-23))
					end
					-- 颜色是绿色
					tmpView.mc_1:showFrame(3)
					tmpView.mc_1.currentView.txt_1:setString(value)
				else
					-- 普通颜色
					tmpView.mc_1.currentView.txt_1:setString(value)
				end
			end
		end
	end
	if rqData.result then
		view.mc_dui:visible(true)
		if rqData.result == Fight.answer_right then
			view.mc_dui:showFrame(1)
		else
			view.mc_dui:showFrame(2)
		end
	else
		view.mc_dui:visible(false)
	end
end
-- 播放特效
function BattleBuffsView:_playShowAnim(view,pos)
	if not view.showAnim then
		view.showAnim = self:createUIArmature("UI_zhandoud", "UI_zhandoud_shuaixn",
			view,false,GameVars.emptyFunc)
		if pos then
			view.showAnim:pos(pos)
		end
	end
	view.showAnim:visible(true)
	view.showAnim:stopAllActions()
	view.showAnim:gotoAndPlay(0)
	view.showAnim:delayCall(function()
		view.showAnim:visible(false)
	end,27/GameVars.GAMEFRAMERATE)
end
-- 更新buff显示
function BattleBuffsView:updateBuffView(bId)
	local tmpArr = self.controler:getBattleBuffs()
	local isHave = false
	for k,v in pairs(tmpArr) do
		if v then
			isHave = true
			break
		end
	end
	if not isHave then
		self.panel_buffs:visible(false)
		return
	end
	self.panel_buffs:visible(true)
	for k,v in pairs(self.buffsArr) do
		if bId and v._buffInfo.bId == bId then
			v:resetBuffPos(true)
		end
		v:removeFromParent()
	end
	self.buffsArr = {}
	if #tmpArr > 5 then
		echoError ("掉落buff超过5个，程序大大只能显示5个，请关卡策划检查配表")
	end
	local _addBuff = function(i,buffInfo)
		local p = self.panel_buffs["ctn_buff"..i]
		local _x,_y = p:getPosition()
		local view = ViewBuff.new(self.controler,buffInfo,_x,_y):addTo(p)
		table.insert(self.buffsArr,view)
		-- 播放特效
		if not bId then
			self:_playShowAnim(p)
		end
	end
	-- local idx = 0
	for i=1,5 do
		local buffInfo = tmpArr[i]
		if buffInfo then
			-- idx = idx + 1
			if not bId then
				self:delayCall(c_func(_addBuff,i,buffInfo),i/8)
			else
				_addBuff(i,buffInfo)
			end
		end
	end
end
-- 使用一个buff
function BattleBuffsView:onUseBuff(event)
	self:updateBuffView(event.params)
end

-- 更新当前波数及对应剩余的怪
function BattleBuffsView:updateWaveAndCount(event)
	if not self.controler.levelInfo:chkIsWaveRefresh() then
		return
	end
	local tmpData = self.controler.levelInfo:getRefreshAi()
	self.panel_2:visible(true)
	local enemyArr = tmpData.enemyArr
	local currWave = self.controler.reFreshControler:getCurrentWaveIndex()
	local tmpArr = {}
	local isHave = false
	local tmpWave = currWave
	-- 取有怪的一波
	for i=currWave,#enemyArr do
		for k,v in pairs(enemyArr[i]) do
			if v and v.hid then 
				if (not tmpArr[v.hid]) then
		            local icon = self.controler:getIconByAttr(v)
					tmpArr[v.hid] = {icon = icon ,count = 1}
					isHave = true
					tmpWave = i
				else
					tmpArr[v.hid].count = tmpArr[v.hid].count + 1
				end
			end
		end
		if isHave then
			-- 取到了就返回了
			break
		end
	end
	self.panel_2.mc_1:showFrame(2)
	self.panel_2.mc_1.currentView.txt_1:setString(tmpWave.."/"..#enemyArr)
	local headArr = {}
	for k,v in pairs(tmpArr) do
		table.insert(headArr,{icon = v.icon,count = v.count,hid = k})
	end
	table.sort(headArr,function( a,b )
		return a.hid < b.hid
	end)
	if #headArr > 3 then
		echoError ("找战斗策划，RefreshEnemy刷怪里面的怪物种类超过3",tmpData.id)
	end
	for i=1,3 do
		local view = self.panel_2["UI_"..i]
		if i > #headArr then
			view:visible(false)
		else
			view:visible(true)
			view.ctn_1:removeAllChildren()
		    local iconSpr = display.newSprite( FuncRes.iconHero(headArr[i].icon))
		    iconSpr:setScale(1.2)
			view.ctn_1:addChild(iconSpr)
			view.mc_dou:visible(false)
			view.panel_lv.txt_3:setString(headArr[i].count)
			view.panel_lv:scale(2.2)
			view.panel_lv:pos(-22,-50)
		end
	end
	if event and event.params then
		local count = event.params
		-- 创建头像，然后让头像做飞出特效
		for k,v in pairs(event.params) do
			local view = UIBaseDef:cloneOneView(self.panel_2.UI_1):addto(self.panel_2)
			view.ctn_1:removeAllChildren()
		    local iconSpr = display.newSprite( FuncRes.iconHero(v.data:getIcon()))
		    iconSpr:setScale(1.2)
			view.ctn_1:addChild(iconSpr)
			view.mc_dou:visible(false)
			view.panel_lv:visible(false)
			self:delayCall(function( )
				self:iconMoveOut(view)
			end,k*0.2)
		end
	end
end
-- 头像刷新飞出
function BattleBuffsView:iconMoveOut( view )
	local tmpT = 0.2 --动画时间
	local a1 = cc.FadeOut:create(tmpT)
	local a2 = cc.MoveBy:create(tmpT, cc.p(300,0))
	view:runAction(cc.Sequence:create(cc.Spawn:create(a1,a2),cc.CallFunc:create(function( )
		view:removeFromParent()
	end)))
end
return BattleBuffsView