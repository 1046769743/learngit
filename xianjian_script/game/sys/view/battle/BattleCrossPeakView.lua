--
-- Author: pangkangning
-- Note:巅峰竞技场换人界面
-- Date: 2017-12-23 
--
local BattleCrossPeakView = class("BattleCrossPeakView", UIBase)

local BZSTATUS = {
	zbkz = 1,--准备开战
	dfbz = 2,--敌方布阵
	wfjg = 3,--我方进攻
	wfbz = 4,--我方布阵
}

function BattleCrossPeakView:loadUIComplete(  )

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_bzwc,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_txt,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_dt,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_baren,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_baren2,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_houbu,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_zbkz,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1,UIAlignTypes.MiddleBottom)



    
    self.btn_bzwc:setTap(c_func(self.doChangeClick,self))
    self.btn_1:setTap(c_func(self.doSureClick,self))
    self:visible(false)
    self.hasLoadIcon = false --是否加载icon完成
end
function BattleCrossPeakView:initControler( view,controler )
	self._cardIdArr = {}
	self._dragSpine = nil
    self._battleView = view
    self.controler = controler
    self:visible(true)
    self.btn_1:visible(false) --确认对战
    self.panel_houbu:visible(false) --候补
    self.mc_zbkz:visible(false)--准备开战
    self.btn_bzwc:visible(false)--布阵完成按钮
    self.panel_txt:visible(false)
    -- 伤害提升
    self.panel_sss:visible(false)
    -- 隐藏头像
    self:hideUserItemIcon()

    self:initHeadIconData()
    self:updateRoleArea()
	if BattleControler:checkIsCrossPeakModeBP() then
		self:selectCartChange()
		self:updateSelectCardIcon()
	else
		self.panel_baren:visible(false)
		self.panel_baren2:visible(false)
	end

    -- 巅峰竞技场角色上下阵
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_HERO_CHANGE, self.heroChange, self)
    -- FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CROSSPEAK_SURE, self.sureBattle, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_QUICK_TO_ROUND, self.reloadUIByQuick, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BATTLESTATE_CHANGE, self.battleStateChange, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BP_RES_COMPLETE, self.bpResComplete, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENTER_BEFORECHANGE, self.updateEnterBeforeChange, self)
    -- 战前上下阵确定按钮
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BEFORECHANGE_CHECKSURE, self.updateSureBtnVisible, self)

    -- 回合伤害增加
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CROSSPEAK_ADDBUFF, self.onAddBuff, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CROSSPEAK_RESETWAITTIME, self.resetWaitTime, self)

    self:addBarrageUI()  --测试

end

--添加弹幕界面
function BattleCrossPeakView:addBarrageUI()
    if self.controler:isReplayGame() then
    	return
    end
	if self.controler:checkIsInProgress() then
		return
	end
    if not LoginControler:isLogin() then
        return
    end
	local db = self.controler.levelInfo:getCrossPeakOtherCampData()
	if not db then
		echoError ("没有获取到对应的敌方信息")
		return
	end
	local arrPame = {
		system = FuncBarrage.SystemType.crosspeak,  --系统参数
		btnPos = {x = 0,y = 0},  --弹幕按钮的位置
		barrageCellPos = {x = 0,y = 50}, --弹幕区域的位置
		addview = self,--索要添加的视图
		_player = {rid = db._id or db.rid},---玩家数据
	}
	BarrageControler:showBarrageCommUI(arrPame)
end
-- 回合伤害增加
function BattleCrossPeakView:onAddBuff()
	if self.controler:isQuickRunGame() then
		return
	end
	if not self.shtsAni then
		self.shtsAni = self:createUIArmature("UI_xianjianduijue","UI_xianjianduijue_shanghaitisheng0", self, false,GameVars.emptyFunc)
        local hsView = UIBaseDef:cloneOneView(self.panel_sss)
        hsView:pos(-150,30)
	    FuncArmature.changeBoneDisplay(self.shtsAni,"node2",hsView)
	    self.shtsAni:getBone("node"):setVisible(false)
	    local x,y = self.panel_sss:getPosition()
	    self.shtsAni:pos(cc.p(x+200,y-100))
	end
    self.shtsAni:playWithIndex(0,0)
	-- self.delayCall(function (  )
	-- 	self.panel_sss:visible(false)
	-- end,0.5)
end
-- 隐藏小头像的问题
function BattleCrossPeakView:hideUserItemIcon( )
    -- 敌方选角头像
	self.panel_baren.UI_1:visible(false)
	self.panel_baren.panel_an:visible(false)
	-- 我方头像
	self.panel_baren2.UI_1:visible(false)
	self.panel_baren2.panel_an:visible(false)
end

-- 更新角色所在区服
function BattleCrossPeakView:updateRoleArea( )
    -- if self.controler:isReplayGame() then
    -- 	return
    -- end
	local db = self.controler.levelInfo:getCrossPeakOtherCampData()
	if not db then
		echoError ("没有获取到对应的敌方信息")
		return
	end
    if not LoginControler:isLogin() then
        return
    end
    local rName,rLevel,rSec,rHead,rAvatar
    if db.userBattleType == Fight.battle_type_robot then
    	local robotData = FuncCrosspeak.getRobotDataById(db.rid)
    	rName = GameConfig.getLanguage(robotData.robotName)
    	rLevel = db.level
    	rSec = LoginControler:getServerId()
    	rHead = UserModel:head()
    	rAvatar = robotData.avatar
    else
    	rName = db.name
    	rLevel = db.level
    	rSec = db.sec
    	rHead = db.head
    	rAvatar = db.avatar
    end
	self.panel_dt:visible(true)
	self.panel_dt.txt_1:setString(rName)
	self.panel_dt.UI_1.panel_lv:visible(false)
    self.panel_dt.UI_1.panel_lv.txt_3:setString(rLevel)
    self.panel_dt.UI_1.mc_dou:visible(false)
    -- self.panel_dt.UI_1.mc_dou:showFrame(db.star)
    local sdb = LoginControler:getServerInfoById(rSec)
    self.panel_dt.txt_2:setString(sdb.mark.." "..sdb.name)

    local icon = FuncUserHead.getHeadIcon(rHead,rAvatar)
    icon = FuncRes.iconHero( icon )
    local iconSprite = display.newSprite(icon)
    -- 不用遮罩图片，自己画一个
	local _spriteIcon = pc.PCNode2Sprite:getInstance():spriteCreate(iconSprite,80,90,10,0)
	_spriteIcon:setScale(1.2)
	_spriteIcon:pos(0,-7)

    self.panel_dt.UI_1.ctn_1:addChild(_spriteIcon)
end
function BattleCrossPeakView:reloadUIByQuick( )
	self:selectCartChange()
	self:updateSelectCardIcon()
	self:reloadHeadData()
	self:updateBZWCBtnVisible()

	local bState = self.controler.logical:getBattleState()
	local oData = self.controler.levelInfo:getCrossPeakOtherData()
	if bState == Fight.battleState_formationBefore and
		oData.changeCamp ~= BattleControler:getTeamCamp() then
		-- 在战前上下人阶段、不是自己的回合
		self:updateSureBattleVisible(false)
		return
	end
	if ( bState == Fight.battleState_changePerson or 
		bState == Fight.battleState_formation )  and 
		not self.controler:chkIsOnMyCamp() then
		-- 在布阵、换人阶段；不是自己的回合
		self:updateSureBattleVisible(false)
		return
	end
end
-- 重新初始化替补头像
function BattleCrossPeakView:reloadHeadData( )
	for k,v in pairs(self._cardIdArr) do
		v.view:removeFromParent()
	end
	self._cardIdArr = {}
	local allArr = self.controler.levelInfo:getAllHeroByCamp(BattleControler:getTeamCamp())
	self:initHeadIconData(allArr)
	-- 重置触摸事件
	self:_removeTouchSp()
end
-- 初始化可换人的头像
function BattleCrossPeakView:initHeadIconData(arr)
	if not arr or #arr == 0 then
		return
	end
	self.__heroArr = arr
	self.panel_houbu.panel_goods1:visible(false)
	local width = #arr * 90
	self.panel_houbu.scale9_1:setContentSize(cc.size(width,87)) --设置背景图层宽高
	local x,y = self.panel_houbu:getPosition()
	if #arr == 8 then
		self.panel_houbu:setPosition(cc.p(GameVars.halfResWidth - 115,y))
	end
	for i=1,#arr do
		local view = UIBaseDef:cloneOneView(self.panel_houbu.panel_goods1):addTo(self.panel_houbu)
		view:pos(-233+90*(i-1),38)
		local v = arr[i]
		local data = {hid = v.hid,isRobootNPC=v.datas.isRobootNPC,icon = v:getIcon(),
		lv = v:lv(),star = v:star(),quality = v:quality()}
		FuncCommUI.initHeadIconData(view,data)
		view.UI_1.panel_lv:visible(false)
		view.UI_1.mc_dou:visible(false)
		view.panel_an:visible(false)
		view.panel_ran.panel_an:visible(false)
		view.panel_ran.mc_zengyi:visible(false)
		view.panel_ran.mc_jianyi:visible(false)
		view.panel_ran.mc_1:showFrame(v:maxenergy()+1)
		view.ctn_goodsicon:visible(false)

		local tmp = {view = view,isUp = false,data = v}
		local pron,ele
		if v.isCharacter then
			pron = 4 --主角是4
			for k,tre in pairs(v.treasures) do
				if tre.treaType == Fight.treaType_normal then
					ele = tre:sta_elements()
					break
				end
			end

			-- 显示主角法宝图标
			view.ctn_goodsicon:visible(true)
			local tData = self.controler.levelInfo:getCrossPeakTreasure()
			if tData then
				local hid = tData[BattleControler:getTeamCamp()]
				local sp = display.newSprite(FuncRes.iconTreasureNew(hid))
				sp:scale(0.5)
				view.ctn_goodsicon:addChild(sp)
			end
		else
			pron = v.curTreasure:sta_profession()
			ele = v.curTreasure:sta_elements()
		end
		-- 标签
		if pron then
			view.mc_gfj:showFrame(pron)
		end
		-- 五行
		if ele then
			ele = tonumber(ele[1])
			view.ctn_tu2:removeAllChildren()
			local wuxingData = FuncTeamFormation.getWuXingDataById(ele)
			if wuxingData then
		        local wuxingIcon = FuncRes.iconWuXing(wuxingData.icon)
		        local sp = display.newSprite(wuxingIcon):addto(view.ctn_tu2)
		        sp:setScale(0.3)
			end
			view.ctn_tu2:visible(false)--注释五灵
			view.panel_d:visible(false)
		end
		if v.__isUp == Fight.partner_isUp then
			tmp.isUp = true
			view.panel_pai:visible(true)
			view.panel_an:visible(true)
		else
			tmp.isUp = false
			view.panel_pai:visible(false)
			view.panel_an:visible(false)
		end

		view.UI_1.ctn_1:setTouchedFunc(
			c_func(self.doItemClick, self,i),
			nil,true,
			c_func(self.doItemBegan, self,i), 
			c_func(self.doItemMove, self,i),false,
			c_func(self.doItemEnded, self,i)
        )
        table.insert(self._cardIdArr,tmp)
	end
	self.hasLoadIcon = true
	self:updateHouBuVisible(true)
end
function BattleCrossPeakView:getTouchHeroPos(event )
    local ttPos = self.controler.layer.a122:convertToNodeSpaceAR(event)
    -- local ttPos = self.controler.layer:getGameCtn(2):convertToNodeSpaceAR(event)
	local camp = BattleControler:getTeamCamp()
	ttPos.y = GameVars.height - event.y
	-- echo("ss-s-----",aaPos.x,aaPos.y)
	-- echo("ss---xxxx",ttPos.x,ttPos.y,event.y)
	local x,y = self.controler:tuozhuaiBianJieJianCha(camp,ttPos.x,ttPos.y)
	return x,y
end
-- 更新角色已上阵
function BattleCrossPeakView:updateHeroIconIsUp(idx,isUp)
	local headObj = self._cardIdArr[idx]
	if headObj then
		-- echo("cc====",isUp,headObj.data.hid,headObj.data.__cardId)
	    headObj.isUp = isUp
	    headObj.view:visible(true)
	    headObj.view.panel_pai:visible(isUp)
		headObj.view.panel_an:visible(isUp)
	end
end
-- 点击头像上阵操作
function BattleCrossPeakView:doItemClick(idx)
	local camp = BattleControler:getTeamCamp()
	local isOut,max = self:chkUpIsMax()
	if isOut then
		-- 最多上阵max人
		WindowControler:showTips( { text = GameConfig.getLanguageWithSwap("#tid_crosspeak_tips_2022", max) })

		return
	end
	local headObj = self._cardIdArr[idx]
	if not headObj or not self.__heroArr or not self.__heroArr[idx] then
		return
	end
	if headObj.isUp then
		WindowControler:showTips( { text = GameConfig.getLanguage("#tid_crosspeak_tips_2023") })
		return
	end
	local bState = self.controler.logical:getBattleState()
	for i=1,6 do
		local posHero = self.controler.logical:findHeroModel(camp,i,false)
		if not posHero then
		    if bState == Fight.battleState_changePerson then
				-- 上阵
		    	local info = {rid = self.controler:getUserRid(),pos = i,
		    		hid = self.__heroArr[idx].__cardId,camp = camp,ctype = Fight.change_up}
		    	self.controler.server:sendChangeHandle(info)
	    	elseif bState == Fight.battleState_formationBefore then
		    	local info = {rid = self.controler:getUserRid(),posNum = i,
		    		partnerId = self.__heroArr[idx].__cardId}
		    	self.controler.server:sendBeforeChangeHandle(info)
	    	end
	    	self:updateHeroIconIsUp(idx,true)
	    	return
		end
	end
	WindowControler:showTips( { text = GameConfig.getLanguageWithSwap("#tid_crosspeak_tips_2022", max) })
end

function BattleCrossPeakView:doItemBegan(idx,event)
	local camp = BattleControler:getTeamCamp()
	local isOut,max = self:chkUpIsMax()
	if isOut then
		-- 最多上阵max人
		WindowControler:showTips( { text = GameConfig.getLanguageWithSwap("#tid_crosspeak_tips_2022", max) })
		return
	end
	if not self.__heroArr then
		return 
	end
	local headObj = self._cardIdArr[idx]
	if self.__heroArr[idx] and headObj then
		if headObj.isUp then
			-- 奇侠已经上阵
			WindowControler:showTips( { text = GameConfig.getLanguage("#tid_crosspeak_tips_2023") })
			return
		end

	    self._offPos = {x = 0,y = 0,hid = self.__heroArr[idx].__cardId}
	end
end
function BattleCrossPeakView:doItemMove(idx,event)
    if not self._offPos then return end
	local headObj = self._cardIdArr[idx]
    if not headObj or headObj.isUp then
    	return
    end
	local x,y = self:getTouchHeroPos(event)
    if not self._dragSpine then
    	-- 检查人数是否过大
		local isOut,max = self:chkUpIsMax()
		if isOut then
			return
		end
	    local spine, sourceId = FuncTeamFormation.getSpineNameByHeroId(tostring(self._offPos.hid), true)
	    local sourceData = FuncTreasure.getSourceDataById(sourceId)
	    local spineView = ViewSpine.new(spine,{},nil,spine,nil,sourceData):addto(self.controler.layer.a122):pos(x,-y)
        spineView:setScaleX(-1*Fight.cameraWay)
	    spineView:playLabel("stand",true)
	    self._dragSpine = spineView
	    headObj.view:visible(false) --隐藏下方头像框(上阵结束后将上阵标签修改为出战)
	    self._dragSpine._idx = idx
    end
    self._dragSpine:pos(x,-y)
end
function BattleCrossPeakView:heroChange( event )
 --    local params = event.params
	-- if params.ctype == Fight.change_down then
	-- 	for k,v in pairs(self._cardIdArr) do
	-- 		if tostring(v.data.__cardId) == tostring(params.hid) then
	-- 		    v.isUp = false
	-- 		    v.view.panel_pai:visible(false)
	-- 			v.view.panel_an:visible(false)
	-- 		end
	-- 	end
	-- end
	self:updateCardArrVisible()
	-- 需要更新按钮显示与否状态
	self:updateSureBtnVisible()
end
function BattleCrossPeakView:_removeTouchSp()
    if self._dragSpine then
    	self._dragSpine:removeFromParent()
    	self._dragSpine = nil
    end
    self._offPos = nil
end
function BattleCrossPeakView:doItemEnded(idx,event)
    if not self._offPos then return end
    if not self._dragSpine then return end

	local x,y = self:getTouchHeroPos(event)
    self._dragSpine:pos(x,-y)
    -- local targetX = event.x * Fight.cameraWay - self._offPos.x
    -- local targetY = -event.y -self._offPos.y

 --    local ttPos = self.controler.layer.a122:convertToNodeSpaceAR(event)
 --    local targetX = ttPos.x
 --    local targetY = ttPos.y
 --    local camp = BattleControler:getTeamCamp()
	-- targetX,targetY = self.controler:tuozhuaiBianJieJianCha(camp,targetX,targetY)

 --    self._dragSpine:pos(targetX,-targetY)



    local camp = BattleControler:getTeamCamp()
    local heroObj,index = self.controler:getAreaTargetByPos(camp,x,y)
    if index == 0 then
    	self:_removeTouchSp()
    	self:updateHeroIconIsUp(idx,false)
    	return
    end
    -- 可以替换傀儡或者刚上阵的角色
    -- if heroObj and (not heroObj:isNewInCrossPeak() and not heroObj.data:checkHasOneBuffType(Fight.buffType_kuilei)) then
    -- 修改不可以替换傀儡
    if heroObj and (not heroObj:isNewInCrossPeak()) then
    	-- 只能替换新上阵的奇侠
		WindowControler:showTips( { text = GameConfig.getLanguage("#tid_crosspeak_tips_2019") })
		self:_removeTouchSp()
    	self:updateHeroIconIsUp(idx,false)
    else
    	local hid = nil
    	if heroObj and heroObj:isNewInCrossPeak() then
    		hid = heroObj.data.hid
    	end
    	-- 先下阵再上阵
    	local bState = self.controler.logical:getBattleState()
	    if bState == Fight.battleState_changePerson then
	    	if hid then
				local info = {rid = self.controler:getUserRid(),pos = index,
			    		hid = hid,camp = camp,ctype = Fight.change_down}
				self.controler.server:sendChangeHandle(info)
	    	end
			-- 上阵
	    	local info1 = {rid = self.controler:getUserRid(),pos = index,
	    		hid = self._offPos.hid,camp = camp,ctype = Fight.change_up}
	    	self.controler.server:sendChangeHandle(info1)
    	elseif bState == Fight.battleState_formationBefore then
	    	if hid then
				local info = {rid = self.controler:getUserRid(),posNum = index,
				    		partnerId = 0}
				self.controler.server:sendBeforeChangeHandle(info)
	    	end
	    	local info1 = {rid = self.controler:getUserRid(),posNum = index,
	    		partnerId = self._offPos.hid}
	    	self.controler.server:sendBeforeChangeHandle(info1)
    	end
	    self:_removeTouchSp()
    	self:updateHeroIconIsUp(idx,true)
    end
end
-- 下阵某个角色
function BattleCrossPeakView:downOneHero(hid )
	-- for k,v in pairs(self._cardIdArr) do
	-- 	if tostring(v.data.hid) == tostring(hid) then
	-- 		self._cardIdArr[k].isUp = false
	-- 	    self._cardIdArr[k].view.panel_pai:visible(false)
	-- 	    self._cardIdArr[k].view.panel_an:visible(false)
	-- 		break
	-- 	end
	-- end
	-- 更新头像的显示方式
	self:updateCardArrVisible()
end
-- 更新确认进攻按钮状态、及对应文字
function BattleCrossPeakView:updateSureBattleVisible(value )
	if self.controler:isQuickRunGame() then
		return
	end
	self.btn_1:visible(value) --确认对战
end
function BattleCrossPeakView:battleStateChange( )
    if Fight.isDummy or self.controler:isQuickRunGame() then
        return
    end
	local bState = self.controler.logical:getBattleState()
	self:_updateTipInfo(bState)
	self:_updateDrag(bState)
end

-- 当换人状态改变的时候，如果还在拖拽状态，需要取消该状态
function BattleCrossPeakView:_updateDrag(bState)
	self:updateBZWCBtnVisible()
	if bState ~= Fight.battleState_changePerson then
		if self._offPos then
			if self._dragSpine then
				local idx = self._dragSpine._idx
		    	self:updateHeroIconIsUp(idx,false)
			end
			self:_removeTouchSp()
		end
	end
	if bState == Fight.battleState_selectPerson or 
		bState == Fight.battleState_formationBefore then
	    self:selectCartChange() --检查是否需要选牌
	    self:updateSelectCardIcon()
	end
	if bState == Fight.battleState_battle or 
		bState == Fight.battleState_wait or
		bState == Fight.battleState_switch or
		bState == Fight.battleState_none then
		self.mc_zbkz:visible(false)
		self.panel_houbu:visible(false)
		self:updateSureBattleVisible(false)
		self.panel_txt:visible(false)
	end
end
-- 显示战斗tip详情
function BattleCrossPeakView:_updateTipInfo(bState)
	local _getTipStr = function (  )
		local isMax,max,count = self:chkUpIsMax()
		local i = 0
		if not isMax then
			i = max - count
		end
		local str = GameConfig.getLanguageWithSwap("#tid_crosspeak_tips_2018", i)
		return str
	end
	self.panel_txt:visible(false)
	if bState == Fight.battleState_formation then
		self.panel_txt:visible(true)
		if self.controler:chkIsOnMyCamp() then
			self.panel_txt.rich_1:setString(GameConfig.getLanguage("#tid_crosspeak_tips_2017"))
		else
			self.panel_txt.rich_1:setString(GameConfig.getLanguage("#tid_crosspeak_tips_2016"))
		end
    elseif bState == Fight.battleState_changePerson then
		self.panel_txt:visible(true)
		if self.controler:chkIsOnMyCamp() then
			self.panel_txt.rich_1:setString(_getTipStr())
		else
			self.panel_txt.rich_1:setString(GameConfig.getLanguage("#tid_crosspeak_tips_2015"))
		end
	elseif bState == Fight.battleState_formationBefore then
		self.panel_txt:visible(true)
		local oData = self.controler.levelInfo:getCrossPeakOtherData()
		if oData.changeCamp == BattleControler:getTeamCamp() then
			self.panel_txt.rich_1:setString(_getTipStr())
		else
			self.panel_txt.rich_1:setString(GameConfig.getLanguage("#tid_crosspeak_tips_2015"))
		end
    end
end
-- 更新布阵mc 传空表示隐藏
function BattleCrossPeakView:updateBZMC(_type)
	if not _type then
		self.mc_zbkz:visible(false)
	else
		self.mc_zbkz:visible(true)
		self.mc_zbkz:showFrame(_type)
	end
end

-- 刷新布阵完成、发起进攻按钮的显示状态
function BattleCrossPeakView:updateBZWCBtnVisible()
	self.btn_bzwc:visible(false)
	local bState = self.controler.logical:getBattleState()
	if bState ~= Fight.battleState_changePerson then
		return
	end
	if self.controler:chkIsOnMyCamp() then
		self.btn_bzwc:visible(true)
	end
end
-- 刷新战前上下阵按钮显示方式
function BattleCrossPeakView:updateSureBtnVisible(  )
	self.controler.formationControler:doBeginBuZhen()
	self:updateSureBattleVisible(false)

	local bState = self.controler.logical:getBattleState()
	if bState ~= Fight.battleState_formationBefore then
		return
	end
	local oData = self.controler.levelInfo:getCrossPeakOtherData()
	if oData.changeCamp ~= BattleControler:getTeamCamp() then
		return
	end
	local isOut,max = self:chkUpIsMax()
	if isOut then
		self:updateSureBattleVisible(true)
	end
end
-- 更新角色上下阵状态
function BattleCrossPeakView:updateCardArrVisible( )
	for k,v in pairs(self._cardIdArr) do
	    v.view:visible(true)
		if v.data.__isUp == Fight.partner_isUp then
		    v.view.panel_pai:visible(true)
			v.view.panel_an:visible(true)
			v.isUp = true
		else
			v.isUp = false
		    v.view.panel_pai:visible(false)
			v.view.panel_an:visible(false)
		end
	end
end
function BattleCrossPeakView:updateEnterBeforeChange( ... )
	self:updateViewVisible()
	self.controler.formationControler:doBeginBuZhen()
end
-- 更新ui的显示方式
function BattleCrossPeakView:updateViewVisible( )
	self:updateBZMC()
	self:updateBZWCBtnVisible()
	self:updateSureBattleVisible(false)
	local camp = self.controler:getUIHandleCamp()
	local bState = self.controler.logical:getBattleState()
    if bState == Fight.battleState_changePerson then
		if camp == Fight.camp_1 and self.controler:chkIsOnMyCamp() then
			-- self.panel_houbu:visible(true)
			self:updateCardArrVisible()
	    	self:updateBZMC(BZSTATUS.wfjg)
		else
	    	self:updateBZMC(BZSTATUS.dfbz)
		end
	elseif bState == Fight.battleState_formation then
		if camp == Fight.camp_1 and self.controler:chkIsOnMyCamp() then
	    	self:updateBZMC(BZSTATUS.wfjg)
		else
	    	self:updateBZMC(BZSTATUS.dfbz)
		end
	elseif bState == Fight.battleState_formationBefore then
		local oData = self.controler.levelInfo:getCrossPeakOtherData()
		if oData.changeCamp == BattleControler:getTeamCamp() then
			-- self.panel_houbu:visible(true)
			self:updateCardArrVisible()
		end
    end
end
-- 点击换人完成按钮
function BattleCrossPeakView:doChangeClick( )
	local camp = BattleControler:getTeamCamp()
	self.controler.server:sendChangeHeroFinishHandle({change=0,camp = camp})
end
-- 确认对战
function BattleCrossPeakView:doSureClick( )
    local bState = self.controler.logical:getBattleState()
	if bState == Fight.battleState_formationBefore then
		if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
			-- 切换至机器人方
			self.controler.cpControler:chkCrossPeakBeforeChangeByTimeOut()
		else
			self.controler.server:sendBeforeChangeSureHandle()
		end
		self:updateSureBattleVisible(false)
	end
end
-- 检查是否超过上阵人数
function BattleCrossPeakView:chkUpIsMax( )
	local camp = BattleControler:getTeamCamp()
	local oData = self.controler.levelInfo:getCrossPeakOtherData()
	local count,max = 0,0
    local bState = self.controler.logical:getBattleState()
	if bState == Fight.battleState_changePerson then
		count = self.controler:countLiveHero(self.controler:getCampArr(camp))
		max = FuncCrosspeak.getSegmentFightInStageMax(oData.seg)
	elseif bState == Fight.battleState_formationBefore then
		count = self.controler.cpControler:getCampNewUpCount(camp)
		max = self.controler.cpControler:getMaxUpCountByIdx(camp,oData.upNum[camp])
	end
	echo("上阵人数===",bState,max,count,camp,oData.upNum[camp])
	if max <= count then
		return true,max,count
	end
	return false,max,count
end
-- 仙界对决选卡阶段
function BattleCrossPeakView:selectCartChange( )
	if self.controler:checkIsInProgress() then
		return
	end
	if self.controler:isReplayGame() then
		return
	end
	local _closeBPView = function( )
		if self.bpView then
			self.bpView:startHide()
			self.bpView = nil
		end
	end
	local bState = self.controler.logical:getBattleState() 
	if bState == Fight.battleState_selectPerson then
	    local camp = BattleControler:getTeamCamp()
		local selectIds = self.controler.levelInfo:getBPPartnerByCampIndex(camp)
		if selectIds then
			if not self.bpView then
			    self.bpView = WindowControler:showBattleWindow("BattleBpPartnerView",self.controler)
			    self.bpView.cardType = Fight.battle_card_hero
			else
				self.bpView:updateShowPartner()
			end
		else
			if self.bpView and self.bpView.cardType == Fight.battle_card_hero then
				_closeBPView()
			end
			selectIds = self.controler.levelInfo:getBPTreasureByCampIndex(camp)
			if selectIds then
				if self.bpView then
					return
				end
			    self.bpView = WindowControler:showBattleWindow("BattleBpTreasureView",self.controler)
			else
				_closeBPView()
			end
		end
	else
		_closeBPView()
	end
end
-- 资源加载完成
function BattleCrossPeakView:bpResComplete(event)
	local isMyChoose = event.params
	if isMyChoose then
		self:selectCartChange()
	end
	-- 刷新敌我双方所选的角色
	self:updateSelectCardIcon()
end
-- 对bp头像做填充
function BattleCrossPeakView:loadIconImg(view,heroObj )
    local skin = ""
	if heroObj.datas.garmentId then
    	skin = heroObj.datas.garmentId
    end
    local iconSpr = display.newSprite( FuncRes.iconHero(heroObj:getIcon()))
    -- 不用遮罩图片，自己画一个
	local _spriteIcon = pc.PCNode2Sprite:getInstance():spriteCreate(iconSpr,80,90,10,0)
	_spriteIcon:setScale(1.2)
	_spriteIcon:pos(0,-7)

    local level = heroObj:lv() or 1
    local quality = 1
    if heroObj.quality then
    	quality = heroObj:quality() or 1
    end
    local star = 1
    if heroObj.star then
    	star = heroObj:star() or 1
    end
    view.mc_dou:visible(false)--隐藏星级
    view.panel_lv:visible(false) --隐藏等级
    if view._iconSp then
    	view._iconSp:removeFromParent()
    	view._iconSp = nil
    end
    view.ctn_1:addChild(_spriteIcon )
    view._iconSp = _spriteIcon
    view.mc_kuang:showFrame(tonumber(FuncChar.getBorderFramByQuality(quality) ) )
end
-- 更新选卡人头像
function BattleCrossPeakView:updateSelectCardIcon( )
	if self.controler:isReplayGame() then
		self.panel_baren.txt_1:visible(false)
		return
	end
	local bState = self.controler.logical:getBattleState() 
	if bState ~= Fight.battleState_selectPerson then
		self.panel_baren:visible(false)
		self.panel_baren2:visible(false)
		return
	end
	if not self._headIcon then
		self._headIcon = {[Fight.camp_1]={},[Fight.camp_2]={}}
	end
	-- 查找是否有过该icon
	local _findIcon = function( arr,cardId )
		for k,v in pairs(arr) do
			if v.__cardId == cardId then
				return true
			end
		end
		return false
	end
	-- 获取明或暗个数
	local _getIconCount = function( arr,isAn )
		local count = 0
		for k,v in pairs(arr) do
			if v.__isAn == isAn then
				count = count + 1
			end
		end
		return count
	end
	-- local camp = BattleControler:getTeamCamp()
	local uiCamp = self.controler:getUIHandleCamp()
	for i=1,2 do
		local allHero = self.controler.levelInfo:getAllHeroByCamp(i)
		for k,v in ipairs(allHero) do
			local arr = self._headIcon[i]
			if not _findIcon(arr,v.__cardId) then
				local iconView
				-- 是主角 或者是我选的角色，则有头像,否则暗
				if not v.__selectTeamId or v.__selectTeamId == uiCamp then
					local count = _getIconCount(arr,true) + 1
					if i == uiCamp then
						iconView = UIBaseDef:cloneOneView(self.panel_baren2.UI_1):addTo(self.panel_baren2)
						iconView:pos(-90*count+45,0)
					else
						iconView = UIBaseDef:cloneOneView(self.panel_baren.UI_1):addTo(self.panel_baren)
						iconView:pos(90*count-45,0)
					end
					self:loadIconImg(iconView,v)
					iconView.__isAn = true
				else
					local count = _getIconCount(arr,false) + 1
					if i == uiCamp then
						iconView = UIBaseDef:cloneOneView(self.panel_baren2.panel_an):addTo(self.panel_baren2)
						iconView:pos(-90*count+45,-90)
					else
						iconView = UIBaseDef:cloneOneView(self.panel_baren.panel_an):addTo(self.panel_baren)
						iconView:pos(90*count-45,-90)
					end
					iconView.__isAn = false
				end
				iconView.__cardId = v.__cardId
				table.insert(arr,iconView)
			end
		end
	end
end
-- 候补阵容显示与否
function BattleCrossPeakView:updateHouBuVisible(value)
	self.panel_houbu:visible(false)
	if not self.hasLoadIcon then return end
    local bState = self.controler.logical:getBattleState()
    if bState ~= Fight.battleState_changePerson and 
       bState ~= Fight.battleState_formationBefore then
       return
	end
	-- 战前选人，不是我方选人的不显示
	local oData = self.controler.levelInfo:getCrossPeakOtherData()
	if bState == Fight.battleState_formationBefore and
		oData.changeCamp ~= BattleControler:getTeamCamp() then 
		return
	end
	-- 不是我方布阵的 不显示
	if bState == Fight.battleState_changePerson and 
		not self.controler:chkIsOnMyCamp() then
		return
	end
	self.panel_houbu:visible(value)
end
function BattleCrossPeakView:resetWaitTime(  )
	if self.__haveSend then
		return
	end
	self.__waitTime = TimeControler:getBattleServerTime()
end
-- 如果玩家30秒内未收到任何操作，则认为玩家卡主了，发送日志平台
function BattleCrossPeakView:checkSendBattleLog()
	if self.__haveSend then
		return
	end
	if not BattleControler:checkIsMultyBattle() then
		-- 单人不发日志平台
		return
	end
	-- 忽略的时段不校验(切后台然后再切回来时间未同步期间)
	if self.controler:isIngoreCheckSeized() then
		return
	end
	if not self.__waitTime then
		self.__waitTime = TimeControler:getBattleServerTime()
	else
		local diffTime = TimeControler:getBattleServerTime() - self.__waitTime
		if diffTime > 35 then
			self.__haveSend = true
		    if self.controler.__gameStep == Fight.gameStep.result then
		        return
		    end
			self.controler:sendSeizedUpData()
		end
	end
end
return BattleCrossPeakView