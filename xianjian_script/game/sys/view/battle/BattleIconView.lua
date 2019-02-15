--
-- autor: pangkangning
-- Date: 2017.08.31
-- 战斗中点击释放技能相关图标显示

local BattleIconView = class("BattleIconView", UIBase)


local UINAME = "panel_"
local iconCount = 6 --6个头像
local POSX = {} --6个头像原始的X位置
local POSY = nil
ANIMA_TYPE = {}
ANIMA_TYPE.SHOW = 1 --展示动画
ANIMA_TYPE.HIDE = 2	--隐藏动画
ANIMA_TYPE.MOVE = 3	--移动动画
UI_TYPE={}
UI_TYPE.BOTTOM = 1 --按钮布局在下方 (默认)
UI_TYPE.RIGHT = 2	--按钮布局在右边
-- 放在下方的坐标
-- POSX={308,398,488,578,668,758} 
-- POSY={-545,-545,-545,-545,-545,-545}
-- self(0,-89) levelid = 10101
-- 放在右边的坐标系
-- POSX={874,951,1030,874,951,1030} 
-- POSY={-113,-113,-113,-546,-546,-546}
-- self(0,-64)

function BattleIconView:loadUIComplete()
	-- self.uiType = UI_TYPE.BOTTOM
	-- model 对应的model、view 头像icon，x坐标、isClick是否点击、posIndex 站位 const 怒气消耗数
	-- {{model = nil,view = nil,x = nil,isClick = false,posIndex = nil,cost=1},}
	self.HeadArray = {}
	self.atkIdxArray = {} --攻击序列
	self._artifactArr = {} --神器头像
	self._artifactPos = {} --神器头像的初始位置
end

function BattleIconView:initControler(battleView,controler )
    self._battleView = battleView
    self.controler = controler
    self:visible(false)

    self._disabledUI = false

	local globalAiOrder = Fight.aiOrder
	-- 将UI的坐标记录、并且隐藏
	for i=1,iconCount do
		local view = self[UINAME..i]
        view._isInAin = false --是否在动画执行之中
        local x,y = view:getPosition()
        POSX[i] = math.round(x)
        POSY = math.round(y)
        -- 添加点击事件
        view.UI_1.ctn_1:setTouchedFunc(c_func(self.doClickIcon,self,view),nil,true)
        view:visible(false)
    end
    -- 只有三个神力的item，所以写死了
	for i=1,3 do
		local view = self["panel_"..i.."x"]
		local x,y = view:getPosition()
		view:visible(false)
        view.ctn_1:setTouchedFunc(c_func(self.doArtifactClick,self,view,i),nil,true)
        if not view.slAnim then
		    view.slAnim = self:createUIArmature("UI_zhandoud", "UI_zhandoud_xiaotishix",
		    										view.ctn_1:getParent(),true,GameVars.emptyFunc)
			view.slAnim:anchor(0.19,0.83)
			view.slAnim:scale(1.3)
		end
		view.slAnim:visible(false)

		table.insert(self._artifactPos,cc.p(x,y))
		table.insert(self._artifactArr,{view = view})
	end

    self:initHeroIcon()
    -- self:sortViewIconPos()

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHANGEAUTOFIGHT,self.autoChanged,self )
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDEND, self.onRoundEnd, self)

	-- 检查UI头像消息
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENERGY_CHANGE, self.onEnergyChange, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHECK_UI_HEAD, self.checkUIHead, self)

    -- 个人怒气消耗变化
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENERGY_COST_CHANGE, self.energyCostChange, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_MAX_SKILL, self.heroPlayMaxSkill, self)
    

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BUZHEN_CHANGE, self.onBuZhenChange, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ATTACK_CLICK, self.onModelHeroClick, self)

    -- 有角色死亡
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SOMEONE_DEAD, self.someoneDead, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ICON_CHANGE, self.iconChange, self)
    
    -- 巅峰竞技场角色上下阵
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_HERO_CHANGE, self.heroChange, self)

    -- 断线重连至回合需要刷新一下头像
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_QUICK_TO_ROUND, self.quickToRound, self)
    

	EventControler:addEventListener(SystemEvent.SYSTEMEVENT_RENTER_RE_CREATE, self.onComeToBackground,self)

	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SHOW_SKILLICON, self.showView, self)

	-- 攻击结束刷新神器的坐标
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ATTACK_COMPLETE, self.attackComplete, self)

end
function BattleIconView:showView( )
	self._canShow = true
	self:updateIconVisible(true)
end
-- 初始化UI头像
function BattleIconView:initHeroIcon( )
	if self.controler:isQuickRunGame() then
		return
	end
	local campArr = self.controler:getMyCampArr()
	-- self:visible(true)
	local globalAiOrder = Fight.aiOrder
	for _,model in pairs(campArr) do
		local tmp = self:getOneIconByModel(model)
		if tmp then
			tmp.view:visible(true)
	        table.insert(self.HeadArray,tmp)
		end
	end
	if BattleControler:checkIsCrossPeak() and
	 BattleControler:getTeamCamp() == Fight.camp_2 then
		self:sortViewIconPos(true)
	else
		self:sortViewIconPos()
	end
end
-- 根据model初始化一个头像的数据
function BattleIconView:getOneIconByModel(model )
	if model:getHeroProfession() == Fight.profession_obstacle then
		return nil
	end
	-- 将已经死亡的角色移除
	for i=#self.HeadArray,1,-1 do
		local v = self.HeadArray[i]
		if v.model and (v.model._isDied or v.model.data:hp() <= 0 or
		v.model:hasNotAliveBuff() ) then
			-- 头像使用者已经死亡
			table.remove(self.HeadArray,i)
		end
	end
	-- 遍历6个头像，看哪个头像没被使用，则使用之
	for i=1,6 do
		local view = self[UINAME..i]
		for k,v in pairs(self.HeadArray) do
			-- 头像已经被使用了
			if v.view == view then
				view = nil
				break
			end
		end
		if view then
	        local cost = model:getEnergyCost()
	        local tmp = {
		        model = model,
		        view = view,
		        x = POSX[i],
		        isClick = false,
		        posIndex = model.data.posIndex,
		        cost = cost ,
		        status = Fight.icon_normal,
		    }
	        self:initHeadIcon(tmp)
		    -- 加一个buff监听改变头像状态
		    model.data:addEventListener(BattleEvent.BATTLEEVENT_ONBUFFCHANGE,self.onbuffChange,self)
		    return tmp
		end
	end
	echoError ("头像都被使用了----")
	return nil
end

function BattleIconView:onbuffChange(event )
	if event.target then
		for k,v in pairs(self.HeadArray) do
			-- 此处的 target 是 ObjectHero对象
			if v.model.data == event.target then
				self:changeHeadStatus(v)
			end
		end
	end
end
function BattleIconView:attackComplete( event )
	if self.controler:isQuickRunGame() then
		return
	end
	if event.params.camp == Fight.camp_1 then
		self:updateArtifactVisible(true)
	end
end
-- 刷新所有头像
function BattleIconView:reFreshAllIcon()
	if self.controler:isQuickRunGame() then
		return
	end
	-- 重新刷新头像的时候，需要把以前旧的visible都设置为false
	for k,v in pairs(self.HeadArray) do
		v.view:visible(false)
	end
	table.clear(self.HeadArray)

	self:initHeroIcon()
end
--  战中换装
function BattleIconView:iconChange( event )
    local params = event.params
    self:reFreshAllIcon()
    
	self:changeHeadStatus()
end
-- 
function BattleIconView:quickToRound(event)
	self:iconChange(event)
end
-- heroChange
function BattleIconView:heroChange( event )
    local params = event.params
	-- 删除一切有的头像
	for k,v in pairs(self.HeadArray) do
		if v.model.data.posIndex == params.posIndex then
			v.view:visible(false)
			-- -- 删除原有头像
			-- if v.view._iconSp then
			-- 	v.view._iconSp:removeFromParent()
			-- 	v.view._iconSp = nil
			-- end
			table.remove(self.HeadArray,k)
			break
		end
	end
	-- 添加新头像
	local campArr = self.controler:getMyCampArr()
	for k,model in pairs(campArr) do
		if model.data.posIndex == params.posIndex then
			local tmp = self:getOneIconByModel(model)
			if tmp then
				tmp.view:visible(true)
		        table.insert(self.HeadArray,tmp)
				self:changeHeadStatus(tmp)
			end
		end
	end
	
    self:sortViewIconPos()
end
-- 重新绘制头像rendertexture
function BattleIconView:onComeToBackground( )
	-- 延迟一帧处理
	self:delayCall(function( ... )
		for k,v in pairs(self.HeadArray) do
			if v.view._iconSp then
		    	v.view._iconSp:removeFromParent()
		    	v.view._iconSp = nil
			end
			local _spriteIcon = self:_getHeadIcon(v)
		    v.view.UI_1.ctn_1:addChild(_spriteIcon )
		    v.view._iconSp = _spriteIcon
		end
	end,0.1)
end
function BattleIconView:_getHeadIcon(headObj )
	local heroObj = headObj.model.data
    local iconSpr = display.newSprite(FuncRes.iconHero(heroObj:getIcon()))
    iconSpr:setScale(1.2)
    return iconSpr
end
-- 对UI头像做填充
function BattleIconView:initHeadIcon(headObj )
	if self.controler:isQuickRunGame() then
		return
	end
	local view = headObj.view
	local heroObj = headObj.model.data

	local _spriteIcon = self:_getHeadIcon(headObj)


    local level = heroObj:lv() or 1
    local quality = 1
    if heroObj.quality then
    	quality = heroObj:quality() or 1
    end
    local star = 1
    if heroObj.star then
    	star = heroObj:star() or 1
    end
    view.UI_1.mc_dou:visible(false)--隐藏星级
    view.UI_1.panel_lv:visible(false) --隐藏等级
    -- view.UI_1.panel_lv.txt_3:setString(level)
    if view._iconSp then
    	view._iconSp:removeFromParent()
    	view._iconSp = nil
    end
    view.UI_1.ctn_1:addChild(_spriteIcon )
    view._iconSp = _spriteIcon

    view.UI_1.mc_kuang:showFrame(tonumber(FuncChar.getBorderFramByQuality(quality) ) )

	self:_addTouXiangAnim(view)
	self:iconNormal(headObj)
    self:updateViewDou(headObj)
end
-- 添加头像的特效
function BattleIconView:_addTouXiangAnim(view)
	if not view.chuxianAnim then
		-- 开始出现特效
		view.chuxianAnim = self:createUIArmature("UI_zhandoud", "UI_zhandoud_chuxian",view.UI_1,false,GameVars.emptyFunc)
		view.chuxianAnim:anchor(0.42,0.58)
		view.chuxianAnim:scale(1.2)
	end
	view.chuxianAnim:visible(false)
	if not view.chixuAnim then
		-- 循环特效
	    view.chixuAnim = self:createUIArmature("UI_zhandoud", "UI_zhandoud_xunhuan",view.UI_1,true,GameVars.emptyFunc)
		view.chixuAnim:anchor(0.16,0.83)
		view.chixuAnim:scale(1.3)
	end
	view.chixuAnim:visible(false)
	if not view.dianAnim then
		-- 点击特效
		view.dianAnim = self:createUIArmature("UI_zhandoud", "UI_zhandoud_dianji",view.panel_an,false,GameVars.emptyFunc)
		-- view.dianAnim:anchor(0.12,0.88)
		view.dianAnim:anchor(0.25,0.73)
		view.dianAnim:scale(1.3)
	end
	view.dianAnim:visible(false)
	if not view.jinzhiAnim then
		-- 技能释放的上涨特效
		view.jinzhiAnim = self:createUIArmature("UI_zhandou", "UI_zhandou_jinzhi",
			view.UI_1.ctn_1,false,GameVars.emptyFunc)
		view.jinzhiAnim:scale(1.3)
	end
	view.jinzhiAnim:visible(false)
	if not view.dianjiAnim then
		-- 点击内发光特效
		view.dianjiAnim = self:createUIArmature("UI_zhandou", "UI_zhandou_neifaguang",
			view.UI_1.ctn_1,true,GameVars.emptyFunc)
		view.dianjiAnim:scale(1.3)
	end
	view.dianjiAnim:visible(false)
end
-- 更新头像框上的怒气豆数
function BattleIconView:updateViewDou(headObj,cost,costType)
	local view,model = headObj.view,headObj.model
	if not cost or not costType then
		cost,costType = model:getEnergyCost()
	end
	headObj.cost = cost
	local mc_name = {
		[Fight.energyC_normal] = "mc_1",
		[Fight.energyC_reduce] = "mc_zengyi",
		[Fight.energyC_add] = "mc_jianyi",
	}
	for ct,mn in pairs(mc_name) do
		local mc = view.panel_ran[mn]
		mc:visible(ct == costType)
		mc:showFrame(cost+1)
	end
	-- 判断豆能够释放
	self:changeHeadStatus(headObj)
end

-- 更新UI位置、
function BattleIconView:sortViewIconPos(ignore)
	self:updateIconVisible(false)
	-- 如果不是我方回合，也不显示
	if not ignore and self.controler:getUIHandleCamp() ~= Fight.camp_1 then
		return
	end
	-- 序章战斗影响显示
	if not self.controler:chkXvZhangIconShow() then
		return
	end
	-- if not self:chkShowCrossPeakIcon() then
	-- 	return
	-- end
	-- 竞技场的时候，隐藏掉
	self:updateIconVisible(true)
	self.panel_qipao:visible(false)

	local showTable = {}
	local campArr = self.controler:getMyCampArr()

	for k,v in pairs(self.HeadArray) do
		if v.model._isDied or v.model.data:hp() <= 0 or
		 v.model:hasNotAliveBuff() or 
		 not table.find(campArr,v.model) then
			v.view:visible(false) --死亡的时候将其隐藏
		else
			v.view:visible(true)
			table.insert(showTable,v)
		end
	end
	local globalAiOrder = Fight.aiOrder
	table.sort(showTable,function( a,b )
		local i1 = table.find(globalAiOrder,a.posIndex)
		local i2 = table.find(globalAiOrder,b.posIndex)
		return i1 < i2
	end)
	
	-- 如果固定位置下面不刷新
	if self._spGuideUI then return end

	local nowIdx = 0
	for k,v in pairs(showTable) do
		local i = table.find(globalAiOrder,v.posIndex)

		v.view:pos(POSX[i],POSY)
		nowIdx = nowIdx + 1
		v.view:zorder(nowIdx)
	end
end
function BattleIconView:autoChanged( )
	if self.controler:isQuickRunGame() then
		return
	end
    local isAuto = self.controler.logical:chkCampIsAutoFight(BattleControler:getTeamCamp())
    if isAuto then
	    -- self:visible(false)
    else
	    local camp = self.controler:getUIHandleCamp()
	    if camp == Fight.camp_1 then
	    	self:sortViewIconPos()
	    end
    end
end
-- 阵型发生变化
function BattleIconView:onBuZhenChange( )
	if self.controler:isQuickRunGame() then
		return
	end
	for k,v in pairs(self.HeadArray) do
		v.posIndex = v.model.data.posIndex --重新赋值位置
	end
	self:sortViewIconPos()
end
-- 重置头像view为可点击状态
function BattleIconView:resetViewStatus(headObj )
	headObj.isClick = false
	headObj.status = Fight.icon_normal
	-- local view = headObj.view
	-- if view.jinzhiAnim then
	-- 	view.jinzhiAnim:visible(false)
	-- end
	-- if view.dianjiAnim then
	-- 	view.dianjiAnim:visible(false)
	-- end
	self:iconNormal(headObj)
	self:changeHeadStatus(headObj)
end
function BattleIconView:onRoundStart( )
	if self.controler:isQuickRunGame() then
		return
	end
	self:updateIconVisible(false)
    local camp = self.controler:getUIHandleCamp()
    if camp == Fight.camp_1 then
    	-- 回合切换的时候，将所有已经点击过的角色reset
    	for k,v in pairs(self.HeadArray) do
    		self:resetViewStatus(v)
    	end
		self:sortViewIconPos()
    else
		-- self:updateIconVisible(false)
    end
    self:updateArtifactByRound()
end
function BattleIconView:someoneDead( )
	if self.controler:isQuickRunGame() then
		return
	end
    local camp = self.controler.logical.currentCamp
    if camp == Fight.camp_1 then
		self:sortViewIconPos(true)--(强制刷新)
	else
		-- 巅峰竞技场也需要重新刷新(强制刷新)
		if BattleControler:checkIsCrossPeak() then
			self:sortViewIconPos(true)
		end
	end
end
function BattleIconView:onRoundEnd( )
	if self.controler:isQuickRunGame() then
		return
	end
	self:visible(false)
	self.atkIdxArray = {}
	-- 所有状态都要重置
	for k,v in pairs(self.HeadArray) do
		self:updateIconStatus(v,Fight.icon_normal)
	end
end
-- 怒气变化、更新按钮状态
function BattleIconView:onEnergyChange(event)
	if self.controler:isQuickRunGame() then
		return
	end
	local result = event.params
    local camp = self.controler:getUIHandleCamp() --self.controler.logical.currentCamp
    if camp == 1 then 
		self:changeHeadStatus()
	end
end
-- UI检测
function BattleIconView:checkUIHead(event)
	if self.controler:isQuickRunGame() then
		return
	end
	local result = event.params
	for k,v in pairs(self.HeadArray) do
		if v.model == result.model then
			if (not result.model.hasOperate and not result.model.isWaiting) then
				-- 重置攻击、或者盗宝者试炼主角拾取法宝(并且能释放技能了)
				self:resetViewStatus(v)
			end
			break
		end
	end
	self:changeHeadStatus()
end
-- 个人怒气变化
function BattleIconView:energyCostChange(event )
	if self.controler:isQuickRunGame() then
		return
	end
	local model = event.params.model
	local cost,costType = model:getEnergyCost()

	for k,v in pairs(self.HeadArray) do
		if v.model == model then
			-- 说明消耗怒气了
			if v.cost < cost then
				-- 怒气消耗变化
				local xhAnim = self:createUIArmature("UI_zhandou", "UI_zhandou_xiaohaozengjia",v.view,false,GameVars.emptyFunc)
				xhAnim:pos(39,-45)
				-- 豆闪
				local tibaoAnim = self:createUIArmature("UI_zhandou", "UI_zhandoui_mantubiaoliang",v.view.panel_ran,false,GameVars.emptyFunc)
				tibaoAnim:pos(10,-20)
				tibaoAnim:playWithIndex(0,0,0)
			end
			self:updateViewDou(v,cost,costType)
		end
	end
end
-- 当角色释放大招的时候
function BattleIconView:heroPlayMaxSkill( event )
	if self.controler:isQuickRunGame() then
		return
	end
	local result = event.params
	for k,v in pairs(self.HeadArray) do
		if v.model == result.model then
			self:updateIconStatus(v, Fight.icon_clickEnd)
			break
		end
	end
end
-- 按钮是巅峰竞技场不能点击状态
-- 按钮是正常状态(但是蒙灰)
function BattleIconView:iconCrossPeakUnClick( v )
	if self.controler:isQuickRunGame() then
		return
	end
	v.status = Fight.icon_crossPeak
	self:_addTouXiangAnim(v.view)
	v.__isCrossPeak = true
	v.view.mc_debuff:visible(false)
	v.view.mc_num:visible(false)
	v.view.panel_da:visible(false)
	FilterTools.setGrayFilter(v.view.panel_ran)
	-- v.view.chuxianAnim:visible(false)
	-- v.view.dianAnim:visible(false)
	-- if v.view.jinzhiAnim then
	-- 	v.view.jinzhiAnim:visible(false)
	-- end
	-- v.view.chixuAnim:visible(false)

	v.view.panel_ran.panel_an:visible(true)
	v.view.panel_an:visible(true)
end
-- 按钮是正常状态
function BattleIconView:iconNormal( v )
	if self.controler:isQuickRunGame() then
		return
	end
	v.__isCrossPeak = false
	v.view.panel_ran.panel_an:visible(false)
	v.view.panel_an:visible(false)
	v.view.mc_debuff:visible(false)
	v.view.mc_num:visible(false)
	v.view.panel_da:visible(false)
	FilterTools.setGrayFilter(v.view.panel_ran)
	v.view.chuxianAnim:visible(false)
	v.view.dianAnim:visible(false)
	if v.view.jinzhiAnim then
		v.view.jinzhiAnim:visible(false)
	end
	if v.view.dianjiAnim then
		v.view.dianjiAnim:visible(false)
	end
	v.view.chixuAnim:visible(false)
end
-- 按钮有特殊状态
function BattleIconView:unClickStatus( v )
	if self.controler:isQuickRunGame() then
		return
	end
	v.view.mc_debuff:visible(false)--隐藏debuff层
	v.view.panel_an:visible(false)
	if v.model.data:checkHasOneBuffType(Fight.buffType_xuanyun) or 
		v.model.data:checkHasOneBuffType(Fight.buffType_shufu) then
		v.view.mc_debuff:visible(true)
		v.view.panel_an:visible(true)
		v.view.mc_debuff:showFrame(1)
	elseif v.model.data:checkHasOneBuffType(Fight.buffType_chenmo) then
		v.view.mc_debuff:visible(true)
		v.view.panel_an:visible(true)
		v.view.mc_debuff:showFrame(2)
	elseif v.model.data:checkHasOneBuffType(Fight.buffType_bingdong) then
		v.view.mc_debuff:visible(true)
		v.view.panel_an:visible(true)
		v.view.mc_debuff:showFrame(3)
	elseif v.model.data:checkHasOneBuffType(Fight.buffType_sleep) then
		v.view.mc_debuff:visible(true)
		v.view.panel_an:visible(true)
		v.view.mc_debuff:showFrame(4)
	end
end
-- 更新按钮是可点击状态
function BattleIconView:canClickStatus(v)
	if self.controler:isQuickRunGame() then
		return
	end
	if v.__isCrossPeak then
		return
	end
	v.view.panel_an:visible(false)
	v.view.mc_debuff:visible(false)
	v.view.mc_num:visible(false)
	v.view.panel_ran.panel_an:visible(false)
	-- 自动战斗的时候因为是满大招就能释放、所以不存在有满大招的状态
	local isAuto = self.controler.logical:chkCampIsAutoFight(BattleControler:getTeamCamp())
	if isAuto then
		v.view.chixuAnim:visible(false)
		v.view.panel_da:visible(false)
		return
	end
	v.view.chixuAnim:visible(true)
	v.view.panel_da:visible(true)
	FilterTools.clearFilter(v.view.panel_ran)
end
-- 更新按钮是点击状态
function BattleIconView:isClickStatus( v )
	if self.controler:isQuickRunGame() then
		return
	end
	-- 点击的时候，将角色加入待放序列
	table.insert(self.atkIdxArray,v)
	v.view.mc_debuff:visible(false)
	if v.oldStatus and v.oldStatus == Fight.icon_clickEnd then
		-- v.view.mc_num:visible(false)
		-- v.view.panel_ran.panel_an:visible(true)
		v.view.chixuAnim:visible(false)
		self:updateIconStatus(v,Fight.icon_clickEnd)
		return
	end
	v.view.dianjiAnim:visible(true)
	v.view.chixuAnim:visible(false)
	v.view.panel_an:visible(true)
	v.view.mc_num:visible(true)
	local f = #self.atkIdxArray
	if f > 6 then f = 6 end
	v.view.mc_num:showFrame(f)
	v.view.panel_ran.panel_an:visible(true)
end
-- 大招释放结束
function BattleIconView:clickEndStatus( v )
	if self.controler:isQuickRunGame() then
		return
	end
	v.view.mc_debuff:visible(false)
	if v.view.dianjiAnim then
		v.view.dianjiAnim:visible(false)
	end
	v.view.chixuAnim:visible(false)
	-- 大招释放结束
	v.view.panel_an:visible(true)
	v.view.mc_num:visible(false)
	v.view.panel_da:visible(false)
	FilterTools.setGrayFilter(v.view.panel_ran)
	v.view.panel_ran.panel_an:visible(true)
	if v.view.jinzhiAnim then
		v.view.jinzhiAnim:visible(false)
	end
end
-- 更新头像的状态
function BattleIconView:updateIconStatus(v,newStatus)
	self:updateArtifactEnergy()
	-- echo("ss----wwww",self.controler.logical:getBattleState(),"what?",self.controler:getLogicalCountStatus())
	-- 仙界对决、在战中换人阶段，头像不做处理
	if BattleControler:checkIsCrossPeak() then
	    local bState = self.controler.logical:getBattleState()
		if bState == Fight.battleState_changePerson and not v.model:isNewInCrossPeak() then
			self:iconCrossPeakUnClick(v)
			return
		end
		if bState == Fight.battleState_formation and not self.controler:chkIsOnMyCamp() then
			self:iconCrossPeakUnClick(v)
			return
		end
		if bState == Fight.battleState_formationBefore then
			if  v.model:isNewInCrossPeak() then
				newStatus = Fight.icon_normal
			else
				self:iconCrossPeakUnClick(v)
			end
			return
		end
		-- 只要不是战中换人状态，这个就修改为正常状态
		if bState ~= Fight.battleState_changePerson then
			v.__isCrossPeak = false
		end
	end
	if self.controler:isQuickRunGame() then
		return
	end
	if not self.controler:chkIsOnMyCamp() then
		return
	end
	if v.status == newStatus then
		if v.status == Fight.icon_normal then
			FilterTools.setGrayFilter(v.view.panel_ran)
		end
		return
	end
	v.view.jinzhiAnim:removeFrameCallFunc()
	v.view.chuxianAnim:stopAllActions()
	v.view.dianAnim:removeFrameCallFunc()
	-- echo (":%s位置状态：%s,新：%s",v.model.data.posIndex,v.status,newStatus)
	v.oldStatus = v.status --旧的状态
	v.status = newStatus
	if newStatus == Fight.icon_normal then --常态
		self:iconNormal(v)
	elseif newStatus == Fight.icon_unClick then --不可点击
		self:unClickStatus(v)
	elseif newStatus == Fight.icon_canClick then --可点击
		v.view.panel_ran.panel_an:visible(false)
		v.view.panel_an:visible(false)
		v.view.chuxianAnim:visible(true)
		v.view.chuxianAnim:stopAllActions()
		v.view.chuxianAnim:gotoAndPlay(0)
		v.view.chuxianAnim:delayCall(function()
			v.view.chuxianAnim:visible(false)
			self:canClickStatus(v)
		end,23/GameVars.GAMEFRAMERATE)

	elseif newStatus == Fight.icon_isClick then --点击
		v.view.chuxianAnim:visible(false)
		v.view.panel_an:visible(true)
		v.view.dianAnim:visible(true)
		v.view.dianAnim:playWithIndex(0,false)
		v.view.dianAnim:doByLastFrame(false,true,function( )
			v.view.dianAnim:visible(false)
			self:isClickStatus(v)
        end)
	elseif newStatus == Fight.icon_clickEnd then --释放结束
		v.view.chuxianAnim:visible(false)
		v.view.dianAnim:visible(false)
		if v.oldStatus == Fight.icon_canClick then
			return
		end
		v.view.jinzhiAnim:visible(true)
		v.view.jinzhiAnim:playWithIndex(0,false)
		v.view.jinzhiAnim:doByLastFrame(false,false,function( )
			v.view.jinzhiAnim:visible(false)
			self:clickEndStatus(v)
        end)
	end
end
-- 更新头像状态
function BattleIconView:changeHeadStatus(headObj)
	-- 不可点击状态的buff
	local debuffArr = {
			Fight.buffType_xuanyun,Fight.buffType_shufu,
			Fight.buffType_chenmo,Fight.buffType_bingdong,Fight.buffType_sleep
		}
	local reloadIcon = function(v )
		v.view.mc_debuff:visible(false)
		-- 判断能否使用怒气
		local model = v.model
		if model._isDied == false and model.data:checkCanGiveSkill() 
			and (not model.hasOperate) and (not model.isWaiting) and (not v.isClick) then
			-- and model.data.characterRid == self.controler:getUserRid() then
			self:updateIconStatus(v,Fight.icon_canClick)
		else
			if v.status ~= Fight.icon_isClick then
				if v.status ~= Fight.icon_clickEnd then
					self:updateIconStatus(v,Fight.icon_normal)
				end
			end
		end
		-- 判断按钮状态
		for k,buff in pairs(debuffArr) do
			if v.model.data:checkHasOneBuffType(buff) then
				self:updateIconStatus(v,Fight.icon_unClick)
			end
		end
	end
	if headObj then
		reloadIcon(headObj)
	else
		for k,v in pairs(self.HeadArray) do
			reloadIcon(v)
		end
	end
end

-- 当某个角色被点击
function BattleIconView:onModelHeroClick(event )
	if self.controler:isQuickRunGame() then
		return
	end
	local model = event.params
	for k,v in pairs(self.HeadArray) do
		if v.model == model then
			v.isClick = true
			self:updateIconStatus(v,Fight.icon_isClick)
			break
		end
	end
end
-- 修改屏蔽
function BattleIconView:disabledUIClick()
	echo("头像屏蔽了")
	self._disabledUI = true
end
function BattleIconView:resumeUIClick()
	echo("头像放开屏蔽了")
	self._disabledUI = false
end
-- 界面上icon被点击相关战斗逻辑
function BattleIconView:doClickIcon(view)
	-- 讲道理，快点的时候是不能点头像的
	if self.controler:isQuickRunGame() then
		return
	end
	-- 检查角色是否能放大招
	if not self:checkCanClick(view) then
		return
	end
	for k,v in pairs(self.HeadArray) do
		if v.view == view then
			-- 判断能否使用怒气
			local model = v.model
			if not model:jianChaShiFangJiNengHeDaZhao() then
				-- echoError ("检查角色不能释放大招")
				-- 检查角色不能释放大招
				self:showUnPlayTip(v)
				return
			end
			if model._isDied == false and model.data:checkCanGiveSkill() 
				and not model.hasOperate and not model.isWaiting and not v.isClick then
				-- and model.data.characterRid == self.controler:getUserRid() then
				v.model:doAttackClick(true) --给角色添加点击事件
				v.isClick = true --设置为依据点击状态
				self:updateIconStatus(v,Fight.icon_isClick)
			else
				self:showUnPlayTip(v)
			end
			break
		end
	end
end
-- 点击角色头像布阵完成特效
function BattleIconView:finishBuZhen( )
	if not self.finishBuZhenAnim then
		self.finishBuZhenAnim = self:createUIArmature("UI_zhandoud", "UI_zhandoud_buzhenchenggong",self,false,GameVars.emptyFunc)
        self.finishBuZhenAnim:pos(GameVars.halfResWidth ,-350)
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.finishBuZhenAnim,UIAlignTypes.MiddleBottom)
	end
	self.finishBuZhenAnim:visible(true)
	self.finishBuZhenAnim:playWithIndex(0,0,1)
end
-- 显示不能释放大招的tip
function BattleIconView:showUnPlayTip( v )
	local _updateTip = function(b,txt)
		if b then
			if not v.view.qipaoAnim then
				v.view.qipaoAnim = self:createUIArmature("UI_zhandoud", "UI_zhandoud_qipao",v.view,false,GameVars.emptyFunc)
				v.view.qipaoAnim:pos(40,5)
			end
			-- 在这里设置显示的label
			if not v.view.qipaoAnim.showLab then
				local qpView = UIBaseDef:cloneOneView(self.panel_qipao)
				qpView:pos(0,0)
				FuncArmature.changeBoneDisplay(v.view.qipaoAnim,"tankuang",qpView,0)
				v.view.qipaoAnim.showLab = qpView
			end
			v.view.qipaoAnim.showLab.txt_1:setString(txt)

			v.view.qipaoAnim:stopAllActions()
			v.view.qipaoAnim:visible(true)
			v.view.qipaoAnim:playWithIndex(0,false)
			v.view.qipaoAnim:delayCall(function( )
				v.view.qipaoAnim:playWithIndex(2,false, true)
			end,1.5)
		else
			if v.view.qipaoAnim then
				v.view.qipaoAnim:visible(false)
			end
		end
	end

	if v.model.data:checkHasOneBuffType(Fight.buffType_xuanyun) then
		_updateTip(true,GameConfig.getLanguage("#tid_battle_ui_bufflabel_3"))
	elseif v.model.data:checkHasOneBuffType(Fight.buffType_chenmo) then
		_updateTip(true,GameConfig.getLanguage("#tid_battle_ui_bufflabel_8"))
	elseif v.model.data:checkHasOneBuffType(Fight.buffType_bingdong) then
		_updateTip(true,GameConfig.getLanguage("#tid_battle_ui_bufflabel_25"))
	elseif v.model.data:checkHasOneBuffType(Fight.buffType_shufu) then
		_updateTip(true,GameConfig.getLanguage("#tid_battle_ui_bufflabel_36"))
	elseif v.model.data:checkHasOneBuffType(Fight.buffType_sleep) then
		_updateTip(true,GameConfig.getLanguage("#tid_battle_ui_bufflabel_47"))
	elseif v.model.data:checkHasOneBuffType(Fight.buffType_mabi) then
		_updateTip(true,GameConfig.getLanguage("#tid_battle_ui_bufflabel_28"))
	elseif v.model.data:checkHasOneBuffType(Fight.buffType_hunluan) then
		_updateTip(true,GameConfig.getLanguage("#tid_battle_ui_bufflabel_41"))
	else
		_updateTip(false)
	end
end
--[[
	隐藏怒气消耗
	引导需要
]]
function BattleIconView:hideEnergyDou()
	for k,v in pairs(self.HeadArray) do
		local view = v.view
		view.panel_ran:visible(false)
	end
end

-- 根据hero的data.hid 获取对应头像的中心世界坐标
function BattleIconView:getPosByHeroHid(hid )
	local function getPos(view)
		local box = view:getContainerBox()
		local cx = box.x + box.width/2
		local cy = box.y + box.height/2
		local point = view:convertToWorldSpaceAR(cc.p(cx,cy));
		return point
	end
	for k,v in pairs(self.HeadArray) do
		if hid == "player" then
			-- 找主角
			if v.model.data.isCharacter then
				return getPos(v.view.UI_1.ctn_1)
			end
		else
			if v.model.data.hid == hid then
				return getPos(v.view.UI_1.ctn_1)
			end
		end
	end
	return cc.p(0,0)
end
-- 巅峰竞技场头像显隐与否
function BattleIconView:updateIconVisible(value)
	if not self._canShow then
		-- echo("还未到头像显示时间",value)
		return
	end
	-- echo("还未到头像显示时间====",value)
	-- 巅峰竞技场头像一直显示，但是有自己的状态处理
	if BattleControler:checkIsCrossPeak() then
		self:visible(true)
		self.panel_qipao:visible(false)
		self:updateCrossPeakStatus()
		self:updateArtifactVisible(true)
		return
	end
	self.panel_cs:visible(false)
	-- 偷袭战第一回合也不显示头像
	if self.controler:isTowerTouxiAndFirstWaveRound() then
		self:visible(false)
	elseif BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
		if not self.controler.formationControler:checkIsMeBZ() then
			self:visible(false)
		else
			self:visible(value)
			self:updateArtifactVisible(value)
		end
	else
		self:visible(value)
		self:updateArtifactVisible(value)
	end
	self.panel_qipao:visible(false)
end
-- function BattleIconView:chkShowCrossPeakIcon( )
-- 	-- 如果是巅峰竞技场、第一回因为因为是自动战斗、所以也不显示ui
-- 	if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPvp then
-- 		local curRound = self.controler:getCurrRound()
-- 		if curRound == 1 then
-- 			return false
-- 		end
-- 	end
-- 	return true
-- end
-- 更新按钮状态
function BattleIconView:updateIconStatusByCrossPeak(canClick,model)
	local _funcUpdateIcon = function(v)
		if v.model:isNewInCrossPeak() then
			self:updateIconStatus(v, Fight.icon_normal)
		else
			if canClick then
				self:iconCrossPeakUnClick(v)
			else
				v.status = Fight.icon_normal
				self:iconNormal(v)
				-- self:updateIconStatus(v, Fight.icon_normal)
			end
		end
	end
	if not model then
		for k,v in pairs(self.HeadArray) do
			_funcUpdateIcon(v)
		end
	else
		_funcUpdateIcon(model)
	end
end

-- 巅峰竞技场头像显示方式
function BattleIconView:updateCrossPeakStatus( )
	if self.controler:chkIsOnMyCamp() then
		local bState = self.controler.logical:getBattleState()
		if bState == Fight.battleState_changePerson then
			self:updateIconStatusByCrossPeak(true)
		end
	else
		self:updateIconStatusByCrossPeak(true)
	end

	-- local cState = self.controler:getLogicalCountStatus()
	-- -- 巅峰竞技场相关处理
	-- if cState == Fight.countState_change then
	-- 	self:updateIconStatusByCrossPeak(true)
	-- elseif cState == Fight.countState_buzhen  then
	-- 	self:updateIconStatusByCrossPeak(false)
	-- 	self:changeHeadStatus()
	-- end
end
-- 传入一个坐标，检查坐标是否在按钮上
function BattleIconView:chkPosIsInHeadIcon( pos )
	for k,v in pairs(self.HeadArray) do
		local size = v.view:getContainerBox()
		local p = v.view:convertToNodeSpaceAR(pos)
		if cc.rectContainsPoint(cc.rect(0,0,size.width,size.height),cc.p(p.x,-p.y)) then
			return v.model
		end
	end
	return nil
end
function BattleIconView:updateArtifactByRound(  )
	local tmpArr = self.controler.artifactControler:getUseSkillArr()
	local campArr = self.controler.artifactControler:getCanUseManualSkill(Fight.camp_1)
	campArr = campArr or {}
	for k,v in ipairs(self._artifactArr) do
		-- 初始化或者重新赋值神器技能
		if k <= #campArr then
			if table.isValueIn(tmpArr,campArr[k].hid) then
				--已经释放了
				v.view:visible(false)
			else
				v.view:visible(true)
				v.data = campArr[k]
				v.view._isClick = false
				self:loadArtifactIcon(v)
			end
		else
			v.data = nil
			v.view:visible(false)
		end
	end

	self:updateArtifactEnergy()
end

-- 更新神器技能显示与否
function BattleIconView:updateArtifactVisible( value )
	if value then
		local tmpArr = self.controler.artifactControler:getUseSkillArr()
		local campArr = self.controler.artifactControler:getCanUseManualSkill(Fight.camp_1)
		campArr = campArr or {}
		for k,v in ipairs(self._artifactArr) do
			if v.data then
				local isHave = false
				for m,n in pairs(campArr) do
					if v.data.hid == n.hid then
						isHave = true
						break
					end
				end
				if (not isHave) or v.view._isClick then
					v.data = nil
					v.view:visible(false)
				else
					v.view:visible(true)
				end
			else
				v.view:visible(false)
			end
		end
	end

	self:updateArtifactEnergy()
end
-- 加载/更新神器显示 TODO(需要做怒气是否能够满足的处理)
function BattleIconView:loadArtifactIcon(item )
	local view = item.view
	local artifactModel = item.data
	view.mc_num:visible(false) -- 释放顺序
	-- view.panel_ran:visible(false) --怒气
	view.panel_ran.panel_an:visible(false) -- 怒气上方暗的层
	view.panel_ran.mc_zengyi:visible(false) -- 增益怒气字
	view.panel_ran.mc_jianyi:visible(false) -- 减益怒气字
	local frame = artifactModel:getEnergyCost()
	view.panel_ran.mc_1:showFrame(frame+1) --怒气消耗
	view.ctn_1:removeAllChildren()
	local skillId = artifactModel:getCombineId()
	local arData = FuncArtifact.byIdgetCCInfo(skillId)
	display.newSprite(FuncRes.iconSkill(arData.skillIcon)):addTo(view.ctn_1)
end
function BattleIconView:checkCanClick(view)
	if self._disabledUI then
		return false 
	end

	-- 如果是偷袭战，第一回合也不能点击头像
	if self.controler:isTowerTouxiAndFirstWaveRound() then
		return false 
	end
	local bState = self.controler.logical:getBattleState()
	-- 巅峰竞技场相关处理
	if BattleControler:checkIsCrossPeak() then
		if bState == Fight.battleState_changePerson or 
			bState == Fight.battleState_formationBefore then
			if bState == Fight.battleState_changePerson and 
				not self.controler:chkIsOnMyCamp() then
				echo("仙界对决战斗中换人不是自己回合,不能按按钮")
				return false
			end
			-- 检查这个人是不是新人，如果是、则下阵
			for k,v in pairs(self.HeadArray) do
				if v.view == view and v.model:isNewInCrossPeak() then
					self.controler.cpControler:downOneHero(v.model)
					break
				end
			end
			return false 
		end
	end
	-- 只有是本回合的时候才能够点击
	if not self.controler:chkIsOnMyCamp() then
		echo("不在自己的回合按的按钮。",self.controler:chkIsOnMyCamp())
		return false 
	end
	-- if BattleControler:checkIsShareBossPVE() then
	-- 	WindowControler:showTips({text=GameConfig.getLanguage("#tid2603")})
	-- 	return
	-- endeControler:checkIsShareBossPVE() then
	-- 	WindowControler:showTips({text=GameConfig.getLanguage("#tid2603")})
	-- 	return
	-- end
	-- 如果是自动战斗，提示 关闭自动战斗功能后尝试操作！
    local isAuto = self.controler.logical:getAutoState(self.controler:getUserRid())
    local isAuto_wait,waiting = self.controler:getUIGameAuto()
    if isAuto or isAuto_wait then
        WindowControler:showTips({text=GameConfig.getLanguage("#tid2602")})
    	return false
	end
	-- 如果是PVP 提示 登仙台玩法中无法进行操作！
	if BattleControler:checkIsPVP() then
        WindowControler:showTips({text=GameConfig.getLanguage("#tid2601")})
		return false
	end
	
	-- 序章引导正在攻击过程不可点击
	if self.controler:chkDisableAtkIcon() then
		if self.controler.logical.attackingHero then
			return false
		end
	end
	-- 如果是在等待阶段，也不能点
	if bState == Fight.battleState_wait then
		return false
	end
	return true
end

-- 点击神器技能
function BattleIconView:doArtifactClick(view,idx )
	if not self:checkCanClick(view) then
		return
	end
	local item = self._artifactArr[idx]
	if (not item) or (not item.data) then
		echoError ("未获取到神器技能",idx)
		return
	end
	-- 检查怒气是否够释放
	local count = item.data:getEnergyCost()
    local isEnough = self.controler.energyControler:isEnergyEnough(count,Fight.camp_1)
	if not isEnough then
		echo("怒气不足=不能释放神器技能")
		return
	end
	self.controler.artifactControler:doArtifactAttackClick(Fight.camp_1,item.data.hid)
	-- 释放后将按钮隐藏
	local view = self["panel_"..idx.."x"]
	view:visible(false)
	view._isClick = true
end
-- 更新神器技能怒气相关
function BattleIconView:updateArtifactEnergy( )
	if self.controler:isQuickRunGame() then
		return
	end
	for k,item in pairs(self._artifactArr) do
		if item.data then
			local count = item.data:getEnergyCost()
		    local isEnough = self.controler.energyControler:isEnergyEnough(count,Fight.camp_1)
		    if isEnough then
		    	FilterTools.clearFilter(item.view.panel_ran)
				item.view.slAnim:visible(true)
	    	else
				FilterTools.setGrayFilter(item.view.panel_ran)
				item.view.slAnim:visible(false)
		    end
		end
	end
end

-- 修改写死成序章特殊布局
function BattleIconView:setSpGuideUI()
	self._spGuideUI = true -- 特殊序章UI标记一下
	-- 无关的隐藏
	self.panel_h1:visible(false)
	self.panel_h2:visible(false)
	-- 找到特殊的几个
	local needPos = {
		[1] = 3,
		[2] = 1,
		[3] = 2,
	}

	for _,item in ipairs(self.HeadArray) do
		local flag = false
		for i,pos in ipairs(needPos) do
			if item.posIndex == pos then
				flag = true
				needPos[i] = item
			end
		end
		-- 无关的隐藏
		item.view:visible(flag)
		item.view.panel_ran:visible(false)
	end

	-- 位置都是写死的
	for i,item in ipairs(needPos) do
		local posX = (i - 2) * 80 + GameVars.width / 2 - 30 - GameVars.UIOffsetX
		item.view:setPositionX(posX)
	end
end

return BattleIconView