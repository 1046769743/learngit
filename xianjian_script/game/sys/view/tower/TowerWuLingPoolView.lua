--
--Author:      zhuguangyuan
--DateTime:    2017-12-25 11:41:48
--Description: 锁妖塔固定事件 -- 五星池
--


local TowerWuLingPoolView = class("TowerWuLingPoolView", UIBase);

function TowerWuLingPoolView:ctor(winName,params)
    TowerWuLingPoolView.super.ctor(self, winName)
    self.gridPos = params
    dump(self.gridPos, "self.gridPos")
end

function TowerWuLingPoolView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerWuLingPoolView:registerEvent()
	TowerWuLingPoolView.super.registerEvent(self);
	self.btn_back:setTouchedFunc(c_func(self.press_btn_close,self))
	self.btn_plus:setTouchedFunc(c_func(self.showBuffList,self))

    EventControler:addEventListener(TowerEvent.TOWEREVENT_GOT_SOUL_COMFIRMED, self.getSoulProperty, self)
end

-- 展示购买的buff
function TowerWuLingPoolView:showBuffList()
	WindowControler:showWindow("TowerBuffListView")
end

function TowerWuLingPoolView:initData()
	-- 五灵属性对应ui 映射
	self.mapPropertyToUI = {
		"panel_feng",
		"panel_lei",
		"panel_shui",
		"panel_huo",
		"panel_tu",
	}
	-- 五灵属性对应名 映射
	self.mapPropertyToName = {
		"风抗性",
		"雷抗性",
		"水抗性",
		"火抗性",
		"土抗性",
	}

	self:updateData()
end

function TowerWuLingPoolView:updateData()
	if not self.initSoulNum then
		self.curFloorData = FuncTower.getOneFloorData(TowerMainModel:getCurrentFloor())
		dump(self.curFloorData, "self.curFloorData")
		self.initSoulNum = self.curFloorData.fivesoul   
		self.initChargeTime = 1 -- 赠送的初始充能算是充能一次
		self.maxChargeTime = 3	-- 最大充能次数
	end
	self.wulingTempData = TowerMainModel:getTempWulingProperty() or {}
	self.wulingOwnData = TowerMainModel:getOwnWulingProperty() or {}
end

function TowerWuLingPoolView:initView()
	self.chargeAni = {} -- 充能程度动画vector
	self.taijiAni = {} -- taiji动画vector
	self.oldChargeTime = {} -- 充能次数vector
	for i = 1,5 do
		self.oldChargeTime[tostring(i)] = 0
		self:updateItemUI( tostring(i),self[self.mapPropertyToUI[i]] )
	end
	dump(self.taijiAni,"self.taijiAni", 4)
end

function TowerWuLingPoolView:initViewAlign()
	-- TODO
end

function TowerWuLingPoolView:updateUI()
end

function TowerWuLingPoolView:updateItemUI( _itemData,_itemView )
	local _soulId = _itemData
	local txt = self.mapPropertyToName[tonumber(_soulId)]
	local value1 = self.initSoulNum or 0
	-- 太极特效
	local pedestalAniName = "UI_suoyaota_b_"..(string.split(self.mapPropertyToUI[tonumber(_soulId)],"_")[2])
	if not self.taijiAni[tostring(_soulId)] then
		self.taijiAni[tostring(_soulId)] = self:createUIArmature("UI_suoyaota_b",pedestalAniName,_itemView.ctn_pedestal,true,GameVars.emptyFunc) 
	end

	-- 获取五灵充能次数
	local curChargeTime = self:getOneSoulChargedTime(_soulId)
	_itemView.txt_1:setString(curChargeTime.."/"..self.maxChargeTime)

	if table.isKeyIn(self.wulingTempData,_soulId) then
		value1 = self.wulingTempData[_soulId]
		_itemView.mc_1:showFrame(1)
		_itemView.mc_1.currentView.btn_1:setTap(c_func(self.getSoulPropertyRecomfirm, self, _soulId))
		if tonumber(self.oldChargeTime[tostring(_soulId)]) ~= tonumber(curChargeTime) then
			self.oldChargeTime[tostring(_soulId)] = curChargeTime
			local aniName = "UI_suoyaota_b_shui"..curChargeTime
			if self.chargeAni[tostring(_soulId)] then
				self.chargeAni[tostring(_soulId)]:clear()
			end
			self.chargeAni[tostring(_soulId)] = self:createUIArmature("UI_suoyaota_b",aniName,_itemView.ctn_capacity,true,GameVars.emptyFunc) 
		end
	elseif table.isKeyIn(self.wulingOwnData,_soulId) then
		value1 = self.wulingOwnData[_soulId]
		_itemView.mc_1:showFrame(2)
		-- 删除五灵特效
		if self.chargeAni[tostring(_soulId)] then
			self.chargeAni[tostring(_soulId)]:clear()
		end
		-- 停止太极特效
		-- local bone = self.taijiAni[tostring(_soulId)]:getBoneDisplay("zi")
		-- if bone then
		-- 	bone:pause(true)
		-- end
		local bone2 = self.taijiAni[tostring(_soulId)]:getBoneDisplay("di")
		if bone2 then
			bone2:pause(true)
		end
	end
	_itemView.txt_zhushi:setString(txt.." +"..string.format("%d", value1/100).."%")
end

-- 获取五灵充能次数
function TowerWuLingPoolView:getOneSoulChargedTime( _soulId )
	local chargeTime = self.initChargeTime
	local killMonsters = TowerMainModel:getKillMonsters() or {}
	for k,v in pairs(killMonsters) do
		local monsrerData = FuncTower.getMonsterData(k)
		if monsrerData.fivesoul then
			if tostring(monsrerData.fivesoul[1]) == tostring(_soulId) then
				chargeTime = chargeTime + 1
			end
		end
	end
	return chargeTime
end
-- 弹出二次确认框
function TowerWuLingPoolView:getSoulPropertyRecomfirm(_soulId)
	local chargeTime = self:getOneSoulChargedTime(_soulId)
	if chargeTime < self.maxChargeTime then
		local params = {}
		params.soulId = _soulId
		WindowControler:showWindow("TowerChooseTipsView",FuncTower.VIEW_TYPE.GET_SOUL_TIPS_VIEW,params)
	else
		-- 充能次数达到三次则不弹提示 直接领取
		local event = {}
		event.params = {}
		event.params.soulId = _soulId
		self:getSoulProperty( event )
	end
end

-- 获取五灵属性
function TowerWuLingPoolView:getSoulProperty( event )
	local _soulId = event.params.soulId
	local function _getWulingSoulCallback( serverData )
		if serverData.error then
		else
			TowerMainModel:updateData(serverData.result.data)
			self:updateData()
			self:updateItemUI( tostring(_soulId),self[self.mapPropertyToUI[tonumber(_soulId)]]  )
			self:playGetSoulAnimation(_soulId)
		end
	end
	local params = {
		soulId = _soulId,
		x = self.gridPos.x,
		y = self.gridPos.y,
	}
	TowerServer:getWulingSoul(params,_getWulingSoulCallback)
end

-- 播放领取动画
function TowerWuLingPoolView:playGetSoulAnimation( _soulId )
	local curViewName = self.mapPropertyToUI[tonumber(_soulId)]
	local boomAniName = "UI_suoyaota_b_zhakai"..(string.split(curViewName,"_")[2])
	local box2 = self.btn_plus:getContainerBox()
	local boomAni = self:createUIArmature("UI_suoyaota_b",boomAniName,self[curViewName].ctn_boom,false,function()
		end)
	FuncArmature.setArmaturePlaySpeed(boomAni,1.5) 
	boomAni:getBoneDisplay("zhakai"):startPlay(false,true)
	-- local function playBoomCallback( ... )
		local bone2 = self.taijiAni[tostring(_soulId)]:getBoneDisplay("di")
		if bone2 then
			bone2:pause(true)
		end
		local beginPos = self[curViewName]:convertLocalToNodeLocalPos(self)
		local endPos = self.btn_plus:convertLocalToNodeLocalPos(self)
		self:playGetSoulParticles(_soulId,beginPos,endPos,c_func(self.playParticleAniCallback,self))
	-- end
	-- boomAni:doByLastFrame( true, true ,playBoomCallback)
end

-- 播放粒子特效回调
function TowerWuLingPoolView:playParticleAniCallback()
	local ani = self:createUIArmature("UI_suoyaota_b","UI_suoyaota_b_huiju",self.btn_plus,false,function()
		end)
	ani:startPlay(false,true)
end
-- 播放粒子特效 飞行动画
function TowerWuLingPoolView:playGetSoulParticles(_soulId,beginPos,endPos,callBack)
	if self.particleNode and (not tolua.isnull(self.particleNode)) then
		self.particleNode:removeFromParent()
	end
	local particlesName = "UI_suoyaota_b_"..(string.split(self.mapPropertyToUI[tonumber(_soulId)],"_")[2]).."guiji.plist"
    local effectPlist = FuncRes.getParticlePath() .. particlesName
    self.particleNode = cc.ParticleSystemQuad:create(effectPlist);
    self.particleNode:setTotalParticles(200);
    self:addChild(self.particleNode)
    self.particleNode:pos(beginPos.x,beginPos.y)
   	self.particleNode:zorder(10000)

    local deleteParticle = function()
    	if self.particleNode and (not tolua.isnull(self.particleNode)) then
	        self.particleNode:removeFromParent()
	    end
    end

    local acts = {
        -- act.callfunc(function ( ... )
        --     self.particleNode:setVisible(false);
        -- end),
        -- act.delaytime(0.2),
        act.callfunc(function ( ... )
            self.particleNode:setVisible(true);
        end),
        act.moveto(0.7, endPos.x, endPos.y),
        act.callfunc(callBack),
        act.delaytime(1.0 / GameVars.GAMEFRAMERATE * 5),
        act.moveto(1.0 / GameVars.GAMEFRAMERATE, 500, 500),
        act.delaytime(1),
        act.callfunc(deleteParticle),
    };

    self.particleNode:runAction(act.sequence(unpack(acts)));
end

function TowerWuLingPoolView:press_btn_close()
	self:startHide()
end

function TowerWuLingPoolView:deleteMe()
	-- TODO

	TowerWuLingPoolView.super.deleteMe(self);
end

return TowerWuLingPoolView;
