-- Author: pangkangning
-- Date: 2018-04-13
-- 战斗内弹框

local battleBubble = require("level.BattleBubble");

ViewTalkBubble = class("ViewTalkBubble",function ( )
	return display.newNode()
end)

function ViewTalkBubble:ctor(info)
    self:updateVisible(false)
	self._rootNode = display.newNode():addto(self)
end
function ViewTalkBubble:setTarget( heroes,barType )
	self.barType = barType or 1

	self.target = heroes

	self._viewHeight = (heroes.data.viewSize[2]) * (Fight.wholeScale + heroes.viewScale - heroes._viewScale) -- 比例这样处理是因为,viewsize在之前已经作用过viewScale了

	local bubbleView = UIBaseDef:createPublicComponent( "UI_battle_public","mc_talk" )
	bubbleView:setScaleX(Fight.cameraWay )
	self._bubbleView = bubbleView
	bubbleView:addto(self._rootNode):pos(0,0)

	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_TALKBUBBLE,self.onTalkBubble,self)

	self:adjustBarPos()
	self:loadTalkInfo()
end
-- 初始化气泡内容
function ViewTalkBubble:loadTalkInfo( )
	self._talkInfo = {}
	if BattleControler:checkIsCrossPeak() or BattleControler:checkIsPVP() or BattleControler:checkIsMultyBattle() then
		return
	end
	-- 初始化战斗内气泡数据(先检查伙伴partner、在检查EnemyInfo表内,最后检查sourceId)
	local talkInfo = {}
	if tonumber(self.target.data.hid) then
		local tmp1 = FuncPartner.getPartnerTalkById(self.target.data.hid)
		if tmp1 then
			talkInfo = table.copy(tmp1)
		end
	end
	local tmp2 = self.target.data:talk()
	for k,v in pairs(tmp2) do
		table.insert(talkInfo,v)
	end
	local treasures = self.target.data.treasures
	for k,v in pairs(treasures) do
		local sourceId = FuncBattleBase.getSourceByTreasureId(v.data.hid)
		local tmp3 = FuncTreasure.getSourceTalkById(sourceId)
		if tmp3 then
			for m,n in pairs(tmp3) do
				table.insert(talkInfo,n)
			end
		end
	end

	for k,v in pairs(talkInfo) do
		if battleBubble[tostring(v)] then
			table.insert(self._talkInfo,table.deepCopy(battleBubble[tostring(v)]))
		end
	end
	self._currTakId = nil --当前显示的tip

end

-- 更新气泡显示与否
function ViewTalkBubble:updateVisible(b )
	self:visible(b)
end
-- 检查阵营内是否有对应的sourceId(只判断存活的，不判断死亡的奇侠)
function ViewTalkBubble:_checkIsHaveSourceId(pId,IsTeam )
	local arr = IsTeam == true and self.target.campArr or self.target.toArr
	for k,v in pairs(arr) do
		local sourceId = v.data:getCurrTreasureSourceId()
		if tostring(sourceId) == tostring(pId) then
			return true
		end
	end
	return false
end
-- 检查是否满足[因为是条件与关系，以下只检查不满足的就返回false即可]
-- 返回的第二个参数是此时需要移除这条气泡信息
function ViewTalkBubble:checkIsSatisfy(talkInfo,params)
	-- 是否暴击
	if talkInfo.isCrit then
		if not params.isCrit then
			return false
		end
	end
	-- 血量判定
	if talkInfo.hpType and talkInfo.hpPer then
        local hpPer = self.target.data:getAttrPercent(Fight.value_health)
		local per = hpPer * 100
		-- < 
		if talkInfo.hpType == 1 and talkInfo.hpPer < per then
			return false
		end
		-- >
		if talkInfo.hpType == 0 and talkInfo.hpPer > per then
			return false
		end
	end
	-- 队友存在
	if talkInfo.partnerId then
		if not self:_checkIsHaveSourceId(talkInfo.partnerId,true) then
			return false
		end
	end
	-- 队友不存在
	if talkInfo.notPartnerId then
		if self:_checkIsHaveSourceId(talkInfo.notPartnerId,true) then
			return false,true
		end
	end
	-- 敌人存在
	if talkInfo.enemyId then
		if not self:_checkIsHaveSourceId(talkInfo.enemyId,false) then
			return false
		end
	end
	-- 敌人不存在
	if talkInfo.noEnemyId then
		if self:_checkIsHaveSourceId(talkInfo.noEnemyId,false) then
			-- 既然判断了不存在，则需要删除这条log
			return false,true
		end
	end
	-- 关卡id
	if talkInfo.levelId then
		if tostring(self.target.controler.levelInfo.hid) ~= tostring(talkInfo.levelId) then
			return false
		end
	end
	-- 指定剧情
	if talkInfo.bubbleId then
		if params.tType ~= Fight.talkTip_OnTipEnd then
			return false
		end
		if (not params.bubbleId) or tostring(talkInfo.bubbleId) ~= tostring(params.bubbleId) then
			return false
		end
	end
	-- 指定击杀
	if talkInfo.killerId then
		if params.tType ~= Fight.talkTip_onKill then
			return false
		end
		-- "1"代表击杀任意单位
		if talkInfo.killerId ~= 1 and tostring(talkInfo.killerId) ~= tostring(params.killerId) then
			return false
		end
	end
	-- 某角色死亡角色
	if talkInfo.deadId then
		if params.tType ~= Fight.talkTip_onDied then
			return false
		end
		-- "1"代表自己死亡
		if talkInfo.deadId ~= 1 and tostring(talkInfo.deadId) ~= tostring(params.deadId) then
			return false
		end
	end
	-- 死亡buff(未实现)
	if talkInfo.buffs then
	end
	-- 
	if talkInfo.skillType then
		-- 技能释放前
		if talkInfo.skillType == 0 then
			if params.tType ~= Fight.talkTip_beforeSkill then
				return false
			end
		end
		-- 技能释放后
		if talkInfo.skillType == 1 then
			if params.tType ~= Fight.talkTip_afterSkill then
				return false
			end
		end
	end
	-- 是否是使用某技能
	if talkInfo.skillId then
		if (not params.skillId) or tostring(params.skillId) ~= tostring(talkInfo.skillId) then
			return false
		end
	end
	-- 入场结束
	if talkInfo.enterEnd then
		if params.tType ~= Fight.talkTip_enterEnd then
			return false,true
		end 
	end
	-- 回合类型
	if talkInfo.roundType and talkInfo.roundCount then
		if params.roundCount ~= talkInfo.roundCount then
			return false
		end
		-- 回合开始前
		if talkInfo.roundType == 0 then
			if params.tType ~= Fight.talkTip_beforeRound then
				return false
			end
		end
		if talkInfo.roundType == 1 then
			if params.tType ~= Fight.talkTip_afterRound then
				return false
			end
		end
	end
	-- 触发概率
	if talkInfo.ratio then
		-- 概率未触发
		local ran = RandomControl.getOneRandom()
		if ran * 10000 > talkInfo.ratio then
			return false
		end
	end
	return true
end

-- 战斗内气泡处理
function ViewTalkBubble:onTalkBubble( event )
	local params = event.params
	for i=#self._talkInfo,1,-1 do
		local v = self._talkInfo[i]
		local a,b = self:checkIsSatisfy(v,params)
		if a then
			table.remove(self._talkInfo,i)
			self:showTalkInfo(v)
			break
		end
		if b then
			table.remove(self._talkInfo,i)
			break
		end
	end
end
-- 显示
function ViewTalkBubble:showTalkInfo(talkInfo)
	-- 如果正在显示，则需要移除然后刷新新的
	local _time = talkInfo.time or Fight.talkTip_time
	if talkInfo.text then
		-- 我方阵容的角色tip是朝左的
		if self.target.camp == Fight.camp_1 and 
			(self.target.data.posIndex == 5 or self.target.data.posIndex == 6) then
			self._bubbleView:showFrame(1)
		else
			self._bubbleView:showFrame(2)
		end
		local richText = self._bubbleView.currentView.rich_chatBall
		richText:setString(GameConfig.getLanguage(talkInfo.text))
		if not self.__scale then
			self.__scale = self:getScale()
		end
		self:scale(self.__scale/5)
		self:updateVisible(true)
		self:scaleByPos(0.05,self.__scale,self.__scale)
	else
		self:updateVisible(false)
	end
	self:delayCall(function( )
		self:updateVisible(false)
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TALKBUBBLE,{tType = Fight.talkTip_OnTipEnd,bubbleId = talkInfo.hid})
	end,_time/GameVars.GAMEFRAMERATE)
end

--修正血条的位置
function ViewTalkBubble:adjustBarPos(  )
	local w = self._bubbleView:getContainerBox()
	--如果是下排的人
	if self.target.data.posIndex %2 == 0 and
			self.target.data:boss()== 1 and
			self.target.data:figure() > 1 
	then
		self._posType = 2
		self._bubbleView:pos(-1 * Fight.cameraWay + 200,w.height/2 - self._viewHeight-20)
	else
		self._posType = 1
		self._bubbleView:pos(-1 * Fight.cameraWay + 200, w.height/2 + 70)
	end
	-- echoError ("self.",self:isVisible())
end
function ViewTalkBubble:deleteMe( )
	self.target.data:clearOneObjEvent(self)
	FightEvent:clearOneObjEvent(self)
	--移除侦听
	self:removeFromParent()

end
return ViewTalkBubble
