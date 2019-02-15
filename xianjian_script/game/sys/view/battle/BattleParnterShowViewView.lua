--
-- Author: pangkangning
-- Note:新奇侠展示界面
-- Date: 2018-01-22 
--



local BattleParnterShowViewView = class("BattleParnterShowViewView", UIBase)

function BattleParnterShowViewView:loadUIComplete(  )
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHK_SHOW_PARNTER, self.chkShowParnter, self)
end
function BattleParnterShowViewView:initControler( view,controler )
    self._battleView = view
    self.controler = controler
    self._pData = table.deepCopy(controler.levelInfo:getParnterShowData())
    self:zorder(999)
    self._qxzsAnim = nil
end
-- 展示ui
function BattleParnterShowViewView:updateVisible(value)
	self:visible(value)
	self.mc_gfjname:visible(false)
	self.mc_txt:visible(false)
	self.mc_texing:visible(false)
	self.ctn_name:visible(false)
end
function BattleParnterShowViewView:onRoundStart(  )
	self:chkShowParnter()
end
function BattleParnterShowViewView:chkShowParnter()
	if not self._pData then
		return
	end
	-- 检查是否有展示奇侠
	local _chkHaveMonster = function(arr, monsterId )
		for k,v in pairs(arr) do
			if v.data.hid == monsterId then
				return v
			end
		end
		return nil
	end
	local _resetGame =function( )
		if not self._isPause then
			return
		end
		self._isPause = false
		if self._qxzsAnim then
			self._qxzsAnim:playWithIndex(2,0)
			self._qxzsAnim:doByLastFrame(false,false,function( )
				-- 添加去掉动画 
				self._battleView:setClickAble(true)
				self._battleView:disableIconClick(false)
				-- 镜头归位(镜头穿帮，去掉)
				-- self.controler.screen:setFocus(self.controler.middlePos, self.controler.screen.focusPos.y)
				self.controler:playOrPause(true)
				self:updateVisible(false) --这里隐藏就行
				-- 所有人都亮
				self.controler.viewPerform:setHeroLightOrDark(self.controler.campArr_1,{})
				self.controler.viewPerform:setHeroLightOrDark(self.controler.campArr_2,{})
			end)
		end
	end
	-- 奇侠展示
	local _showParnter = function(v )
		-- echoError ("posIndex===",posIndex)
		-- 该动画其实缓存意义不大，因为里面的数据都会替换掉
		if not self._qxzsAnim then
		    self._qxzsAnim = self:createUIArmature("UI_qixiajieshao",
		    					"UI_qixiajieshao_mianban",self,false,GameVars.emptyFunc)
		end
	    self._qxzsAnim:playWithIndex(0,0)
	    self._qxzsAnim:pos(GameVars.halfResWidth,-GameVars.halfResHeight)--绝对中心位置
	    -- local time = self.controler.originSpeed * 1.8
	    -- echoError ("aa====",self.controler.originSpeed)
	    self._qxzsAnim:doByLastFrame(false,false,function( )
	    	self:delayCall(function( )
	    		_resetGame()
	    	end,1.8 )
	        -- 添加点击事件
	        self:setTouchedFunc(function( )
	    		_resetGame()
	        end, nil, true,nil, nil,false,nil )
    	end)

		local parnter = FuncPartner.getPartnerById(v.partnerId)
		local frame = parnter.type
	    -- 角色名字
	    local gfjView =  UIBaseDef:cloneOneView(self.mc_gfjname)
	    gfjView:anchor(0.5,1)
	    gfjView:pos(0,100)
	    gfjView:showFrame(frame)
	    local sp = FuncRes.getParnterShowNameIcon(v.name):addTo(gfjView)
	    sp:anchor(0.5,1)
	    sp:pos(43,-100)
	    FuncArmature.changeBoneDisplay(self._qxzsAnim,"node7",gfjView)
	    local ttView = FuncRes.getParnterShowNameIcon(v.name)
	    ttView:anchor(0.5,1)
	    ttView:pos(43,0)
	    FuncArmature.changeBoneDisplay(self._qxzsAnim,"node8",ttView)

	    FuncCommUI.setViewAlign(self.widthScreenOffset,ttView,UIAlignTypes.LeftTop)
	    FuncCommUI.setViewAlign(self.widthScreenOffset,gfjView,UIAlignTypes.LeftTop)

	    -- 特性
		local txView = UIBaseDef:cloneOneView(self.mc_texing)
		txView:pos(0,50)
		txView:showFrame(frame)
	    FuncArmature.changeBoneDisplay(self._qxzsAnim,"node3",txView)
	    -- FuncCommUI.setViewAlign(self.widthScreenOffset,txView,UIAlignTypes.RightTop,0.5)

		-- 角色简介
	    local jjView =  UIBaseDef:cloneOneView(self.mc_txt)
	    jjView:pos(-300,-10)
		jjView:showFrame(frame)
		local str = GameConfig.getLanguage(FuncPartner.getDescribe(v.partnerId))
		jjView.currentView.txt_1:setString(str)
	    FuncArmature.changeBoneDisplay(self._qxzsAnim,"node5",jjView)
	    -- FuncCommUI.setViewAlign(self.widthScreenOffset,jjView,UIAlignTypes.RightTop,0.5)

	    -- 立绘
		local lihuiView = FuncPartner.getPartnerOrCgarLiHui(v.partnerId)
		if v.pos and #v.pos > 0 then
			local lpos = v.pos[1]
			lihuiView:pos(lpos.x,lpos.y)
		end
	    FuncArmature.changeBoneDisplay(self._qxzsAnim,"node4",lihuiView)
	    FuncCommUI.setViewAlign(self.widthScreenOffset,lihuiView,UIAlignTypes.LeftBottom,0.5)

	    -- 背景
		local bgView = FuncRes.getParnterShowBg(frame)
	    FuncArmature.changeBoneDisplay(self._qxzsAnim,"node1",bgView)

	    -- 横幅
		local hfView = FuncRes.getParnterShowTopBg(frame)
		hfView:setRotation(360-69)
	    FuncArmature.changeBoneDisplay(self._qxzsAnim,"node2",hfView)
	end
	local wave = self.controler.__currentWave
	for k,v in pairs(self._pData) do
		if tonumber(v.wave) == tonumber(wave) then
			local model = _chkHaveMonster(self.controler.campArr_1,v.monsterId)
			if not model then
				model = _chkHaveMonster(self.controler.campArr_2,v.monsterId)
			end
			if model then
				-- 亮展示的角色、暗所有角色
				local darkHeroArr = {}
				for i=1,2 do
					for k,v in pairs(self.controler["campArr_"..i]) do
						if v ~= model then
							table.insert(darkHeroArr,v)
						end
					end
				end
				self.controler.viewPerform:setHeroLightOrDark({model},darkHeroArr)
			    -- 先从数组里面移除
			    table.remove(self._pData,k)
			    -- 自动战斗补弹面板
			    local isAuto = self.controler.logical:getAutoState(self.controler:getUserRid())
			    if isAuto then
			    	return
			    end
			    self._isPause = true
				self._battleView:setClickAble(false)
				self._battleView:disableIconClick(true)
				self:updateVisible(true)
				-- 游戏暂停
				self.controler:playOrPause(false)
				-- 相机聚焦某个位置，然后弹面板(镜头穿帮，去掉)
				-- self.controler.screen:moveToPoint(cc.p(pos.x,self.controler.screen.focusPos.y))
				local jjAnim
			    jjAnim = self:createUIArmature("UI_qixiajieshao",
	    					"UI_qixiajieshao_jujiao",self,false,function( )
					_showParnter(v)
					if jjAnim then
						-- jjAnim:removeFromParent()
					end
			    end)
			    jjAnim:playWithIndex(1,0)
			    local p = model.myView:convertLocalToNodeLocalPos(self)
			    -- 添加血量的偏移
			    jjAnim:pos(cc.p(p.x,p.y + model.healthBarPos.y/2))
				break
			end
		end
	end
end
return BattleParnterShowViewView