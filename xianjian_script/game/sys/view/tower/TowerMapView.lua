--[[
	Author: ZhangYanguang
	Date:2017-07-27
	Description: 锁妖塔地图主界面
	1.战斗后逻辑(需要重构)
		胜利 
			打死了怪,播放星星增加动画 怪死亡并删除怪model 
			=== 数据更新
			打败抢劫者
			检查是否完美通关
		失败 
			=== 数据更新
			检查雇佣兵是否死亡
	2.
]]

local TowerMapView = class("TowerMapView", UIBase);

local TowerMapControlerClazz = require("game.sys.view.tower.map.TowerMapControler")

function TowerMapView:ctor(winName,towerIndex,playEnterAnim)
    TowerMapView.super.ctor(self, winName)

    self.towerIndex = towerIndex        -- 当前锁妖塔层
    self.itemsType = true     	 	    -- 是否展示道具
    self.playEnterAnim = playEnterAnim  -- 是否播放入场开云动画
end

function TowerMapView:loadUIComplete()
	-- 关闭点击特效
	IS_SHOW_CLICK_EFFECT = false

	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:showEnterAnim()
	self:initView()
	self:updateUI()

	-- 战斗结束后不等恢复完锁妖塔场景直接杀进程
	-- 回来后还需检查是否有雇佣兵在上一次战斗中战死
	-- 此需求涉及的数据只能保存本地
	-- 之前的写法在有多个雇佣兵的时候可能有问题,考虑到此需求出现几率不大,暂时屏蔽该功能
	-- self:checkIsMercenaryDead()
	
	-- 检查未完成的商店
	-- 有商店则弹商店 否则检查是否今天的第一次进入场景 若是则弹出奖励列表界面 -- 三测需求
	self:delayCall(c_func(TowerControler.checkUnCompleteShop,TowerControler), 1/GameVars.GAMEFRAMERATE)

	-- -- 测试完美通关动画
	-- local function showPerfect( ... )
	-- 	WindowControler:showWindow("TowerPerfectView") 
	-- end
	self:getCommentData()
end 

-- 播放锁妖塔进入动画，只有在主界面点击"战"按钮才播放动画
function TowerMapView:showEnterAnim()
	if not self.playEnterAnim then
		return
	end

	if not self.towerIndex then
		return
	end

	local sceneData = FuncTower.getTowerMapSkinData(self.towerIndex)
	if sceneData and sceneData.starAnim then
		local enterAnim  = ViewSpine.new("UI_suoyatazhuanchang")
		enterAnim:playLabel(sceneData.starAnim,false)
		enterAnim:addto(self)
		enterAnim:pos(GameVars.width/2,-GameVars.height/2)
	end
end

function TowerMapView:registerEvent()
	TowerMapView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.clickClose,self,nil,true))
	self.btn_plus:setTap(c_func(self.clickBuff,self))
	self.btn_talk:setTap(c_func(self.clickCommentBtn,self))
	self.btn_list:setTap(c_func(self.enterRewardPreviewView,self))
	-- self.btn_list:getUpPanel().panel_red:visible(false)

	self.panel_prop.btn_back2:setTap(c_func(self.clickCloseItemList,self))
	self.btn_back3:setTap(c_func(self.clickOpenItemList,self))

	-- 注册空方法，解决事件穿透问题
	self.panel_prop:setTouchedFunc(c_func(GameVars.emptyFunc),nil,true)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_TOWER_DATA_UPDATE,self.updateUI,self)
	
	-- 是否选择目标
	EventControler:addEventListener(TowerEvent.TOWEREVENT_CHOOSE_TARGET,self.onChooseTarget,self)
	-- 上楼的逻辑
	EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR,self.goNextFloor,self)
	-- 战斗相关界面全部关闭
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.onBattleClose,self)

	-- 道具相关更新消息
    --更新道具(使用道具后的更新)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_USE_ITEM_UPDATE,self.updateGoods,self)
    -- 捡道具成功
	EventControler:addEventListener(TowerEvent.TOWEREVENT_GET_ITEM_SUCCESS,self.onGetItemSuccess,self)
    --丢弃道具成功
    EventControler:addEventListener(TowerEvent.TOWEREVENT_DROP_ITEM_SUCCESS,self.updateGoods,self)
    -- 获得新道具
    EventControler:addEventListener(TowerEvent.TOWEREVENT_HAVE_TOWERITEM,self.updateGoods,self)

    --道具秒杀怪
    EventControler:addEventListener(TowerEvent.TOWEREVENT_ITEM_KILL_MONSTER,self.onItemKillMonster,self)

    -- 检查是否完美通关(紫金葫芦杀怪成功发送)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_CHECK_IS_PERFECT,self.checkIsPerfect,self)
    -- 购买buff后商店关闭消息
    EventControler:addEventListener(TowerEvent.TOWEREVENT_BUFF_SHOP_VIEW_CLOSE,self.updateStar,self)
end

function TowerMapView:checkIsPerfect()
	self:checkPerfect()
end

function TowerMapView:initData()
	if not self.towerIndex then
		self.towerIndex = 1
	end
    self.perfectFloor = TowerMainModel:getPerfectFloor()
	self.maxItemNum = FuncTower.towerItemMaxNum
end

function TowerMapView:initView()
	if self.panel_erhang then
		self.panel_erhang:visible(false)
	end
	if self.panel_erhang2 then
		self.panel_erhang2:visible(false)
	end
	if self.panel_jdt then
		self.panel_jdt:visible(false)
	end
	self.panel_choose1:setVisible(false)
	self.panel_choose2:setVisible(false)
	self.panel_choose1:setTouchedFunc(GameVars.emptyFunc,nil,true)
	self.panel_choose2:setTouchedFunc(GameVars.emptyFunc,nil,true)
	-- 场景标题
	local currentFloor = TowerMainModel:getCurrentFloor()
	self:displayFloorTitle( currentFloor )
    -- self.panel_icon.mc_1:showFrame(currentFloor>10 and 1 or currentFloor)

	self:initMap()
	self:clickOpenItemList() -- 左下角的道具栏默认打开
    self:updateGoods()
end

-- 场景第几层的标题
function TowerMapView:displayFloorTitle( floor )
	-- 将数字转化为数组形式 11-->{"1","1"}
    local function splitIntToArr( str )
        local len = string.len(tostring(str))
        local arr = {}
        for i=1,len do
            arr[i] = string.sub(str, i,i)
        end
        return arr
    end

	local curFloor = tonumber(floor)
	local contentView = nil
	if curFloor < 11 and curFloor > 0 then
		self.panel_icon.mc_1:showFrame(1)
		contentView = self.panel_icon.mc_1:getCurFrameView()
		contentView.mc_1:showFrame(curFloor)
	elseif curFloor < 20 and curFloor > 0 then
		self.panel_icon.mc_1:showFrame(2)
		contentView = self.panel_icon.mc_1:getCurFrameView()
		local numArr = splitIntToArr(curFloor)
		contentView.mc_1:showFrame(10)
		contentView.mc_2:showFrame(tonumber(numArr[2]))
	else
		local numArr = splitIntToArr(curFloor)
		if numArr[2] ~= "0" then 
			self.panel_icon.mc_1:showFrame(3)
			contentView = self.panel_icon.mc_1:getCurFrameView()
			contentView.mc_1:showFrame(tonumber(numArr[1]))
			contentView.mc_2:showFrame(10)
			contentView.mc_3:showFrame(tonumber(numArr[2]))
		else
			self.panel_icon.mc_1:showFrame(2)
			contentView = self.panel_icon.mc_1:getCurFrameView()
			contentView.mc_1:showFrame(tonumber(numArr[1]))
			contentView.mc_2:showFrame(10)
		end
	end
end

function TowerMapView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon,UIAlignTypes.LeftTop);

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_star,UIAlignTypes.LeftTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_anim,UIAlignTypes.LeftTop);

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_plus,UIAlignTypes.LeftTop);

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.RightTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop);
	
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_prop,UIAlignTypes.LeftBottom);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back3,UIAlignTypes.LeftBottom);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_talk,UIAlignTypes.LeftTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_list,UIAlignTypes.LeftTop);

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_choose1,UIAlignTypes.MiddleTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_choose2,UIAlignTypes.MiddleBottom);

	FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_choose1.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
	FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_choose2.scale9_1,UIAlignTypes.Middle, 1, 0)
end

function TowerMapView:initMap()
	self.mapControler = TowerMapControlerClazz.new(self,self.towerIndex)
	self.towerMap = self.mapControler:getTowerMap()
	self._root:addChild(self.towerMap,-1)

	self.panel_prop:zorder(1)	
	self.btn_back3:zorder(1)

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.towerMap,UIAlignTypes.MiddleTop);
end

-- 进入下一层
function TowerMapView:goNextFloor()
	-- 播放转场动画
    self:playTransitionAnim(TowerMainModel:getCurrentFloor())
end

-- 播放转场动画
function TowerMapView:playTransitionAnim(callBack,floorIndex)
	local towerData = FuncTower.getOneFloorData( floorIndex )
	local label = "UI_suoyatazhuanchang_landaohong"
	if towerData and towerData.transitionAnim then
		label = towerData.transitionAnim
	end

	local transitionAnim  = ViewSpine.new("UI_suoyatazhuanchang")
	transitionAnim:playLabel(label,false)
	transitionAnim:addto(self)
	transitionAnim:anchor(0.5,0.5)
	transitionAnim:pos(GameVars.width/2 - GameVars.UIOffsetX,-GameVars.height/2 )
	local totalFrame = transitionAnim:getTotalFrames()

	local showNewMap = function()
		self:deleteCurrentFloorMap()
		self:showNewFloorMap(totalFrame)
	end
	self:delayCall(c_func(showNewMap), 10 / GameVars.GAMEFRAMERATE)
end

function TowerMapView:deleteCurrentFloorMap()
	if self.mapControler then
		self.mapControler:deleteMe()
	end
	TowerMainModel:resetTower()
end

-- 创建下一层地图
function TowerMapView:showNewFloorMap(totalFrame)
	local tempData = TowerMainModel:getNextData()  -- 取服务器返回的下层数据进行更新
	TowerMainModel:updateData(tempData)

    local currentFloor = TowerMainModel:getCurrentFloor()
    self:displayFloorTitle( currentFloor )
    -- self.panel_icon.mc_1:showFrame(currentFloor>10 and 1 or currentFloor)

	local function popupRewardView()
		echo("________换层时 检查 弹出奖励列表界面 _____________",currentFloor)
	    local hasPopup = TowerMainModel:checkHasBeenPopupRewardPreview(currentFloor)
	    if not hasPopup or tostring(hasPopup) == "nil" then
	        TowerMainModel:recordHasAutoOpenPreview( currentFloor,true )
	        WindowControler:showWindow("TowerRewardPreviewView",currentFloor)
	    end
    end
	self:delayCall(c_func(popupRewardView), (totalFrame-5) / GameVars.GAMEFRAMERATE)

	self.mapControler = TowerMapControlerClazz.new(self,currentFloor)
	self.towerMap = self.mapControler:getTowerMap()
	self._root:addChild(self.towerMap,-1)
	-- 进入下一层完成,弹幕系统用
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR_COMPLETE)
end

-- 打开道具列表
function TowerMapView:clickOpenItemList()
	self.panel_prop:setVisible(true)
	self.btn_back3:setVisible(false)
    self.itemsType = true
end

-- 关闭道具列表
function TowerMapView:clickCloseItemList()
	self.panel_prop:setVisible(false)
	self.btn_back3:setVisible(true)
    self.itemsType = false
end

function TowerMapView:updateUI()
	-- self:updateGoods()
	if not self.starAniNotFinished then
		self:updateStar()
	end
end

-- 展示 选择道具时 的场景上沿和下沿变化
function TowerMapView:onChooseTarget(event)
	local isSelect = event.params.isSelect

	if isSelect then
		self.panel_choose1:setVisible(true)
		self.panel_choose2:setVisible(true)
		self.panel_prop:setVisible(false)

		local notFindTarget = event.params.notFindTarget
		local tips = ""
		-- notFindTarget为nil表示找到了目标
		if notFindTarget == false then
			-- "当前没有可选择目标"
			tips = GameConfig.getLanguage("#tid_tower_prompt_112")
		else
			-- "请选择使用目标"
			tips = GameConfig.getLanguage("#tid_tower_prompt_113")
		end
		self.panel_choose2.txt_xuanze:setString(tips)
	else
		self.panel_choose1:setVisible(false)
		self.panel_choose2:setVisible(false)
		self.panel_prop:setVisible(true)
	end
end

function TowerMapView:updateStar()
	local starNum = TowerMainModel:towerExt().star or 0
	self.panel_star.txt_1:setString(starNum)
end

function TowerMapView:playNumChangeEffect(fromNum, toNum)
	-- echo("________ fromNum, toNum _________",fromNum, toNum)
	local textNode = self.panel_star.txt_1
	local textAnimCtn = self.ctn_anim

	local animName = "UI_common_res_num"
	self.ani_resNum = self:createUIArmature("UI_common", animName, textAnimCtn, false, GameVars.emptyFunc)
	local posx, posy = self.ani_resNum:getPosition()
	self.resNumAnimPosX = posx
	self.resNumAnimPosY = posy
	FuncArmature.changeBoneDisplay(self.ani_resNum , "layer6", textNode)
	local numAnim = self.ani_resNum
	local textRect = textNode:getContainerBox()
	numAnim:pos(0,-9)
	textNode:pos(-textRect.width/2, textRect.height/2)

	local setTextNum = function(num)
		-- echo("_______ shezhi shuzi _________",num)
		textNode:setString(num)
	end

	numAnim:gotoAndPause(1)
	numAnim:startPlay(false)
	local frameLen = numAnim.totalFrame
	for frame=1,frameLen do
		local num = toNum
		if frame < frameLen then
			num = math.floor((toNum - fromNum)*1.0/frameLen * frame) + fromNum
		end
		numAnim:registerFrameEventCallFunc(frame, 1, c_func(setTextNum, num))
	end
end

-- 战斗后当前view显示在最顶层
-- 如果战斗胜利,先执行星星增加动画,不让点击格子 怪死亡动画;再更新数据
-- 如果战斗失败 则直接更新数据 
function TowerMapView:onBattleClose()
	if not self.isBattleExitResume then
		return
	end
    echo("\n\n------------战斗退出后恢复------------")

	local callBack = function ()
	    -- 删除怪所在格子对怪model的索引 并删除怪model及视图
    	local killMonsterId = TowerMainModel:getKilledMonsterId()
    	local addStar = TowerMainModel:getBattleAddStar()    	
    	if addStar and addStar > 0 then
    		local targetGrid = self.mapControler:findGridByMonsterId(killMonsterId)
    		echo("__________ killMonsterId,targetGrid ____________",killMonsterId,targetGrid)
    		self:disabledUIClick()
			self.starAniNotFinished = true
    		self:playStarChangeAnim(targetGrid)
    	end
	    if killMonsterId then
	    	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_MONSTER_DIE,{monsterId=killMonsterId})
	    end
	    -- 更新战斗结果数据
	    self:updateBattleResultData(1)
    end

    if TowerMainModel:checkBattleWin() then
    	self:delayCall(c_func(callBack),1/GameVars.GAMEFRAMERATE)
    else
	    self:updateBattleResultData()
	end
end

function TowerMapView:onItemKillMonster(event)
	echo("______ 剑灵格子杀怪 也会走这里 ______________")
	if event and event.params then
		self.addStar = event.params.addStar or 1
		self.oldStar = TowerMainModel:towerExt().star or 0
		local targetGrid = event.params.targetGrid
		self:playStarChangeAnim(targetGrid)
	end
end

-- 播放星星新增动画
function TowerMapView:playStarChangeAnim(targetGrid)
	echo("目标格子targetGrid-----------",targetGrid)
	local beginGrid = targetGrid or self.mapControler.charModel:getGridModel()
	local pos = beginGrid.pos
	pos.y = pos.y + beginGrid.mySize.height / 2

	local beginCtn = beginGrid.myView:getParent()
	local beginPos = beginCtn:convertLocalToNodeLocalPos(self,pos)

	local endCtn = self.panel_star
	local endPos = cc.p(endCtn:getPosition())

	local function addBuffStar( num )
		-- if num < self.addStar then
		-- 	self:playAddStarParticles(beginCtn,beginPos, endCtn,endPos,GameVars.emptyFunc)
		-- elseif num == self.addStar then
			local addStarCallBack = function()
				local starNum = self.oldStar + num - 1
				local endStarNum = self.oldStar + num
				self:playNumChangeEffect(starNum,endStarNum)
				if leftTime == self.addStar then
					self.starAniNotFinished = false
						self:resumeUIClick()
				end
			end
			self:playAddStarParticles(beginCtn,beginPos, endCtn,endPos,addStarCallBack)
		-- end
	end

	for leftTime = 1,self.addStar do
		self:delayCall(c_func(addBuffStar,leftTime), 0.4*leftTime)
	end

	-- 兼容处理，防止特殊情况导致resumeUIClick无法执行
	local callBack = function()
		self:resumeUIClick()
	end

	self:delayCall(c_func(callBack,leftTime), 0.4*self.addStar)
end

-- 战斗退出后恢复当前view
function TowerMapView:onBattleExitResume()
	echo("\n\n------------战斗退出后恢复........... ")
    self.isBattleExitResume = true

    self.oldStar = TowerMainModel:towerExt().star or 0
    self.addStar = TowerMainModel:getBattleAddStar()
end

-- 更新战斗数据
function TowerMapView:updateBattleResultData(delayTime)
	delayTime = delayTime or 0
	local updateData = function()
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_UPDATE_BATTLE_DATA)
		local function _callback()
			self:checkIsMercenaryDead()
			self:checkDefeatRobber()
		end
		self:checkPerfect(_callback)
	end
	self:delayCall(c_func(updateData), delayTime)
end

-- 检查雇佣兵是否死亡
function TowerMapView:checkIsMercenaryDead()
	local deadMercenaryId = nil
	if not TowerMainModel._data.towerExt.employeeInfo or table.length(TowerMainModel._data.towerExt.employeeInfo)<=0 then
		return
	end
	if TowerConfig.SHOW_TOWER_DATA then
		dump(TowerMainModel._oldData.towerExt.employeeInfo, "老书记", nesting)
		dump(TowerMainModel._data.towerExt.employeeInfo, "新数据", nesting)
	end
	-- TowerMainModel:saveMercenaryId( nil )
	local oldData = TowerMainModel._oldData.towerExt.employeeInfo
	local newData = TowerMainModel._data.towerExt.employeeInfo
	for k,v in pairs(newData) do
		if v then
			local new = json.decode(v)
			if new and new.hpPercent and new.hpPercent <= 0 then
				local old = json.decode(oldData[k])
				if old and old.hpPercent and old.hpPercent > 0 then
					deadMercenaryId = tostring(k)
					break
				end
			end
		end
	end
	if not deadMercenaryId or deadMercenaryId == "nil" then
		return
	end

	local _mercenaryId = deadMercenaryId --mercenaryData.hid 
	local deadMercenaryCtn = display.newNode():addto(self,WindowControler.ZORDER_TIPS)
    local deadMercenaryAni = self:createUIArmature("UI_suoyaota_b", "UI_suoyaota_b_guaixiaoshi",deadMercenaryCtn,false,GameVars.emptyFunc) 
    local xpos = GameVars.halfResWidth - 550  
    local ypos = GameVars.halfResHeight - 150  
    deadMercenaryAni:setPosition(cc.p(GameVars.halfResWidth - xpos ,-(GameVars.halfResHeight - ypos)))
    local deadMercenaryView = WindowsTools:createWindow("TowerNpcMercenaryDiedView",_mercenaryId)
    deadMercenaryCtn:addChild(deadMercenaryView)
    deadMercenaryView:pos(0,0) 

   	local newAni = deadMercenaryAni:getBoneDisplay("layer4")
    FuncArmature.changeBoneDisplay( newAni,"layer3",deadMercenaryView )
    newAni:startPlay(true, true)
end

-- 检查是否打败劫财劫色者
function TowerMapView:checkDefeatRobber()
	local defeatData = TowerMainModel:getBeatBadGuyData()
	if defeatData then
		TowerMainModel:saveBeatBadGuyData(nil)
		WindowControler:showWindow("TowerNpcRobberView",defeatData.npcId,cc.p(defeatData.x,defeatData.y),defeatData.reward)
	else
		-- 通知劫色界面 再次判断女性伙伴是否死亡,死亡则重新random
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_REFRESH_RANDOM_FEMALE_PARTNER) 
	end
end

-- 播放新增star特效
function TowerMapView:playAddStarParticles(beginCtn,beginPos,endCtn,endPos,callBack)
    local effectPlist = FuncRes.getParticlePath() .. 'mobailizi.plist'
    local particleNode = cc.ParticleSystemQuad:create(effectPlist);
    particleNode:setTotalParticles(200);
    particleNode:setVisible(false);

    self:addChild(particleNode)
    particleNode:pos(beginPos)
   	particleNode:zorder(10000)

    local deleteParticle = function()
        particleNode:removeFromParent()
        echo("删除特效")
    end

    local beginX = beginPos.x
    local beginY = beginPos.y

    local endX = endPos.x
    local endY = endPos.y

    local xDiff = endX - beginX+15
    local yDiff = endY - beginY-15

    local acts = {
        act.callfunc(function ( ... )
            particleNode:setVisible(false);
        end),
        act.delaytime(0.2),
        act.callfunc(function ( ... )
            particleNode:setVisible(true);
        end),
        act.moveby(1, xDiff, yDiff),
        act.callfunc(callBack),
        act.delaytime(1.0 / GameVars.GAMEFRAMERATE * 5),
        act.moveby(1.0 / GameVars.GAMEFRAMERATE, 500, 500),
        act.delaytime(1),
        act.callfunc(deleteParticle),
    };

    particleNode:runAction(act.sequence(unpack(acts)));
end

function TowerMapView:updateGoods()
	local goods = TowerMainModel:getGoodsSortArr()
	-- echo("goods=========")
	-- dump(goods)

	for i=1,self.maxItemNum do
		local itemView = self.panel_prop["UI_" .. i]
		-- itemView:setVisible(false)
		itemView:setIconVisible(false)
		itemView:setItemNumVisible(false)
        itemView:setNameVisible(false)
	end

	for i=1,#goods do
		local itemView = self.panel_prop["UI_" .. i]
		-- itemView:setVisible(true)
		itemView:setIconVisible(true)

		local goodsId = goods[i].id
		local goodsTime = goods[i].time
		local data = {
			reward = goodsId .. ",1"
		}

		itemView:getIconCtn():removeAllChildren()
		itemView:setTowerItemData(data)
		itemView:getIconCtn():setTouchedFunc(c_func(self.onClickItem,self,goodsId,goodsTime),nil,true)
        itemView:setNameVisible(false)
	end
end

function TowerMapView:onGetItemSuccess(event)
	local itemId = nil
	if event then
        itemId = event.params.itemId
        local tempCtn = event.params.tempGrid
        local beginCtn = tempCtn.myView:getParent()
        local pos = tempCtn.pos
        pos.y = pos.y + tempCtn.mySize.height / 2
        local beginPos = beginCtn:convertLocalToNodeLocalPos(self,pos)

        local itemViewIndex = self:getItemViewIndex(event.params.itemId)
        local endCtn = nil
        local endPos = nil

        -- 如果左下角的道具栏是展开的 则飞行轨迹终点为其中的新一个ctn
        -- 否则飞行轨迹终点为收起的小箭头
        if self.itemsType then
            endCtn = self.panel_prop["UI_" .. itemViewIndex]:getIconCtn()
            local tempPos = cc.p(endCtn:getPosition())
            tempPos.y = tempPos.y + 55
            tempPos.x = tempPos.x - 40
            endPos = endCtn:convertLocalToNodeLocalPos(self,tempPos)
        else
            endCtn = self.btn_back3
            endPos = cc.p(endCtn:getPosition())
        end
 
        local getItemCallBack = function()
            echo("获得道具成功itemId=",itemId)
            self:updateGoods()
            local itemViewIndex = self:getItemViewIndex(itemId)
            if itemViewIndex then
                 local itemView = self.panel_prop["UI_" .. itemViewIndex]
                 self:playGetItemAnim(itemView)
            end
        end
        dump(endPos,"当前的飞行距离")
        self:playAddStarParticles(beginCtn,beginPos, endCtn,endPos,getItemCallBack)
		
	end
end

function TowerMapView:playGetItemAnim(itemView)
	local ctn = itemView:getIconCtn()

	local anim = self:createUIArmature("UI_suoyaota","UI_suoyaota_newdaoju", 
		ctn, false, GameVars.emptyFunc);
	anim:pos(0,0)
	anim:startPlay(false)

	local callBack = function()
		anim:setVisible(false)
	end
	anim:registerFrameEventCallFunc(anim.totalFrame, 1,callBack)
end

function TowerMapView:getItemViewIndex(itemId)
	local goods = TowerMainModel:getGoodsSortArr()
	for i=1,#goods do
		if goods[i].id == itemId then
			return i
		end
	end
end

function TowerMapView:onClickItem(goodsId,goodsTime)
	WindowControler:showWindow("TowerUseItemView", goodsId,goodsTime)
end

function TowerMapView:clickClose()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_UPDATE_TESETTOWERTYPE)
    local tempType = TowerMainModel:getGridAni()
    if tempType then
        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_OVERTHEGRIDANIMATION )
        TowerMainModel:saveGridAni(false)
    end
	self:startHide()
end

function TowerMapView:clickBuff()
	WindowControler:showWindow("TowerBuffListView")
	-- self:test()
end

-- 进入奖励预览界面
function TowerMapView:enterRewardPreviewView()
	 WindowControler:showWindow("TowerRewardPreviewView",TowerMainModel:getCurrentFloor())
end

-- 跳转评论界面
function TowerMapView:clickCommentBtn()
	-- 寻找bossId
	local floor = TowerMainModel:getCurrentFloor() 
	local monsterId = TowerMapModel:findBossMonsterId(floor)
	if monsterId then
	else
		echoError("____ 找不到当前层的bossId _________",floor)
	end
	local arrayData = {
		systemName = FuncCommon.SYSTEM_NAME.TOWER,---系统名称
		diifID = monsterId,  --关卡ID
	}
	RankAndcommentsControler:showUIBySystemType(arrayData)
end

--获取锁妖塔评论数据
function TowerMapView:getCommentData()
	-- 寻找bossId
	echo("=======获取锁妖塔评论数据=======")
	local floor = TowerMainModel:getCurrentFloor() 
	local monsterId = TowerMapModel:findBossMonsterId(floor)
	local arrayData = {
		systemName = FuncCommon.SYSTEM_NAME.TOWER,---系统名称
		diifID = monsterId,  --关卡ID
		flagCommentOnly = 1,
		view = self,
	}
	BarrageControler:getRankAndCommentsData(arrayData,true)
end

function TowerMapView:test()
	-- local rt = TowerMapModel:isSleepMonster("1003")
	-- echo("rt---------",rt)
	-- EventControler:dispatchEvent(TowerEvent.TOWEREVENT_MONSTER_DIE,{monsterId="3002"})
	-- self:playStarChangeAnim()
	if true then
		return
	end
end

function TowerMapView:startHide()
	TowerMapView.super.startHide(self)
end

function TowerMapView:deleteMe()
	-- 打开点击特效
	IS_SHOW_CLICK_EFFECT = true

	if self.deadMercenaryView then
		self.deadMercenaryView:visible(false)
	end
	if self.mapControler then
		self.mapControler:deleteMe()
	end

	-- 快速退出地图时也要更新数据
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_UPDATE_BATTLE_DATA)
	TowerMapView.super.deleteMe(self)
end

--30星播放动画
function TowerMapView:checkPerfect(_callback)
	local currentHaveStar = TowerMainModel:getAllStar()
	local totalConfigStarNum = TowerMainModel:getTotalStarNum(TowerMainModel:getCurrentFloor())
    echo("\n\n___检查 是否全星通关 currentHaveStar,totalConfigStarNum ______",currentHaveStar,totalConfigStarNum)
	if currentHaveStar == totalConfigStarNum then
		local perfectData = TowerMainModel:getPerfactReward()
		if perfectData and table.length(perfectData)>0 then
			WindowControler:showWindow("TowerPerfectView")
	       	TowerMainModel:setPerfectTime(tempFloor)
	        TowerMainModel:saveGridAni(true)
	    else
	    	echo("_____ 全星通关 但是服务器没有给完美通关奖励 翻开所有格子_______")
			EventControler:dispatchEvent(TowerEvent.TOWEREVENT_AUTO_OPEN_LEFT_GRIDS)
	    end
	end
	if _callback then
		_callback()
	end
end

return TowerMapView;
