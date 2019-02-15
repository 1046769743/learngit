--
-- Author: pangkangning
-- Note:试炼UI
-- Date: 2018-01-10 
--
local BattleTrialView = class("BattleTrialView", UIBase)


function BattleTrialView:loadUIComplete(  )
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_bossxue,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_pkn,UIAlignTypes.MiddleTop)

    self.starType = nil --结算类型
    self.bossHero = nil --boss血量
    self.maxHp = 1 --最大血量
    self._oldWave = -1
    self.itemArr = {}
    self.mc_bossxue:visible(false)
end
function BattleTrialView:initControler( view,controler )
    self._battleView = view
    self.controler = controler
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART,self.updateTrialTip,self)
	
	self:visible(true)
    self.mc_bossxue:visible(false)
    self.panel_pkn:visible(false)
    self:initTipType()

    if self.starType == Fight.star_hero_hp then
		FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ATTACK_COMPLETE,self.updateMyCampHp,self)
	end
end
-- 根据战斗结算获取对应的监听状态
function BattleTrialView:initTipType( )
	local starInfo = self.controler.levelInfo.__starInfo
	if not starInfo and #starInfo > 0 then
		return
	end
	self.starType = starInfo[1].type
end
-- 获取掉落物品
function BattleTrialView:getDropItem(drop,trialDropId,x,y)
	local view = ViewBuff.new(self.controler,drop,trialDropId,x,y):addto(self)
	return view
end
--掉落一个道具()
function BattleTrialView:onDropOneItem(drop,trialDropId,x,y)
	local dropIdx = #self.itemArr + 1
	if #self.itemArr == 0 then
		self.panel_pkn:visible(true)
	end
	if #self.itemArr >= 5 then
		-- 抛弃第一个道具
		dropIdx = 5
		local view = self.itemArr[1]
		self:clearOneItem(view)
		view:resetBuffPos(true)
		view:clear() --移除buffui界面元素
	end
	local p = self.panel_pkn["ctn_buff"..dropIdx]
	local _x,_y = p:getPosition()
	local pos = self.controler.layer.a122:convertLocalToNodeLocalPos(p:getParent(),cc.p(x,y))
	local view = ViewBuff.new(self.controler,drop,trialDropId,_x,_y):addTo(p)
    view:setScaleX(Fight.cameraWay)
    view:parent(p:getParent()):pos(pos.x,pos.y)
	table.insert(self.itemArr,view)
	local onOverEnd = function( view )
		view:addTeXiao()
		view:onCounstatusChange()
		self:chekViewPos(view)
	end
    view:delayCall(function( )
	    --移动
	    transition.moveTo(view,{x = _x, y = _y, time = 0.3,
	    	onComplete = c_func(onOverEnd, view)
	    	}) 
    end, 1 )
	return view
end
-- 移动结束后都需要检查一下位置是否一致
function BattleTrialView:chekViewPos(view )
	-- 检查此时这个view是第几个，变成第几个的位置(防止重叠)
	for k,v in ipairs(self.itemArr) do
		if v == view then
			local __x,__y = self.panel_pkn["ctn_buff"..k]:getPosition()
			view:pos(__x,__y)
			break
		end
	end
end
-- 使用一个道具(道具往前走)
function BattleTrialView:clearOneItem( view )
	for k,v in ipairs(self.itemArr) do
		if v == view then
			table.remove(self.itemArr,k)
		end
	end
	for i=1,5 do
		local p = self.panel_pkn["ctn_buff"..i]
		local x,y = p:getPosition()
	end
	local onOverEnd = function( view )
		view:updateTexiao(true)
		self:chekViewPos(view)
	end
	for idx,view in ipairs(self.itemArr) do
		local p = self.panel_pkn["ctn_buff"..idx]
		local x,y = p:getPosition()
		view:setInitPos(cc.p(x,y))
		transition.moveTo(view,{x = x, y = y, time = 0.1,
				onComplete = c_func(onOverEnd, view)
			}) 
	end
	if #self.itemArr == 0 then
		self.panel_pkn:visible(false)
	end
end
-- 获取文字显示信息
function BattleTrialView:getWaveTip(currWave)
	local bInfo = self.controler.levelInfo:getBattleInfo()
	local trialId = bInfo.battleParams.trialId
	local tData = FuncTrail.byIdgetdata(trialId)
	if self.starType == Fight.star_boss_hp then --boss总血量、拿的第一波的星级数据
		if self.bossHero then 
			return tData 
		end
	    for k,v in pairs(self.controler.campArr_2) do
	        -- 检查是否有boss
	        if v:getHeroProfession() == Fight.profession_boss or v.data:boss() == 1 then
            	self.bossHero = v
    	        self.bossHero.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH,
    	        		 c_func( self.updateTrialHpTip ,self), self)
    	        break
	        end
	    end
	end
	if self.starType == Fight.star_hero_hp and self.maxHp == 1 then
	    for k,v in pairs(self.controler.campArr_1) do
	        local maxHp = v.data:getAttrByKey(Fight.value_maxhp)
	        self.maxHp = self.maxHp + maxHp
	    end
	end
    return tData
end
-- 更新试炼显示
function BattleTrialView:updateTrialTip( )
	if not self.gxAnim then
		self.gxAnim = self._battleView:createUIArmature("UI_shilian_zhandou",
			"UI_shilian_zhandou_mubiaosaoguang", self.mc_bossxue, false,GameVars.emptyFunc)
		self.gxAnim:pos(190,-32)
		self.gxAnim:visible(false)
	end
	self.mc_bossxue:visible(true)
	local wave = self.controler.__currentWave
	if wave == self.controler.levelInfo.maxWaves then
		self.mc_bossxue:showFrame(2)
		self:updateTrialHpTip()
	else
		self.mc_bossxue:showFrame(1)
	end
	if wave ~= self._oldWave then
		self._oldWave = wave 
		self.gxAnim:visible(true)
		self.gxAnim:playWithIndex(0,0,0)
		self.gxAnim:delayCall(function(  )
			self.gxAnim:visible(false)
		end,38/GameVars.GAMEFRAMERATE )
	end
	local curWave = self.controler.__currentWave
	local tData = self:getWaveTip(curWave)
	local str = GameConfig.getLanguage(tData.targetDes[curWave])
	self.mc_bossxue.currentView.rich_1:setString(str)
end
-- 我方血量处理
function BattleTrialView:updateMyCampHp(e )
	if e.params.camp == Fight.camp_2 and self.starType == Fight.star_hero_hp then
		self:updateTrialHpTip()
	end
end
-- 更新tip血量的富文本
function BattleTrialView:updateTrialHpTip( ... )
	local curWave = self.controler.__currentWave
	local tData = self:getWaveTip(curWave)
	local str 

	if self.starType == Fight.star_boss_hp then

		if not self.bossHero then
			echoError ("没有boss，不应该走这里的")
			return
		end
		local bossHpPer = math.round(self.bossHero.data:getAttrPercent(Fight.value_health )*100)

		-- 当前已造成<color = 66cc00>#1<->的伤害输出
		str = GameConfig.getLanguageWithSwap(tData.targetDes2,100 - bossHpPer)
	elseif self.starType == Fight.star_hero_hp then
    	local currHp = 0
		for k,v in pairs(self.controler.campArr_1) do
			local hp = v.data:getAttrByKey(Fight.value_health)
    		currHp = currHp + hp
		end
		local per = math.round(currHp/self.maxHp * 100 )
		str = GameConfig.getLanguageWithSwap(tData.targetDes2,per)
	end
	if not str then
		str = ""
	end
	self.mc_bossxue.currentView.rich_2:setString(str)
end

return BattleTrialView