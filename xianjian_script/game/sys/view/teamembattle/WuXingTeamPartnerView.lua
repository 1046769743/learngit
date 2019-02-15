--[[
	Author: caocheng
	Date:2017-10-13
	Description: 布阵界面阵位上的动画界面
]]

local WuXingTeamPartnerView = class("WuXingTeamPartnerView", UIBase);

function WuXingTeamPartnerView:ctor(winName,systemId,isMuilt,isCheck,hasNpc,isHost,isSecondFormation)
    WuXingTeamPartnerView.super.ctor(self, winName)
    self.isMuilt = isMuilt
    -- 是否为查看他人阵容信息 
    self.isCheck = isCheck or true
    self.systemId = systemId
    -- all = 1 全部奇侠
    self.tag = FuncTeamFormation.tagType.all
    self.mineOpacity = 255
    self.otherOpacity = 180
    self.isCheck  = isCheck
    self.debug = false

    if hasNpc then
        self.hasNpcs = hasNpc
    end

    self.isHost = isHost
    self.isSecondFormation = isSecondFormation
    -- 是否是引导战斗外布阵
    self.isGuide = TutorialManager.getInstance():isOutFormation()
    -- 是否是引导试炼窟布阵
    self.onkeyIsGuide = TutorialManager.getInstance():isTrialFormation()
    self.playDelayAnimation = true
    -- 是否是在引导中
    self.isInGuide = TutorialManager.getInstance():isInTutorial() 
    if self.isInGuide then
        self.playDelayAnimation = false
    end
end

function WuXingTeamPartnerView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingTeamPartnerView:registerEvent()
	WuXingTeamPartnerView.super.registerEvent(self);
    EventControler:addEventListener(TeamFormationEvent.UPDATA_HEROANIMATION,self.upDataPosAnimation, self)
    if self.isMuilt then
        FightEvent:addEventListener(BattleEvent.BATTLEEVENT_MULITI_UPDATE_FORMATION, self.updateFormationAndTrea, self)
        -- EventControler:addEventListener("nofify_battle_multi_chat_msg_5020",self.multiFormationChat,self)
        EventControler:addEventListener(TeamFormationEvent.PLAY_UPTOMULTITEAMANITION,self.multiFormationAllToUp,self)
    end
    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        EventControler:addEventListener(TeamFormationEvent.MULTI_UP_PARTNER, self.notifyUpPartnerOperation, self)
        EventControler:addEventListener(TeamFormationEvent.MULTI_EXCHANGE_PARTNER, self.notifyExchangePartnerOperation, self)
        EventControler:addEventListener(TeamFormationEvent.MULTI_UP_TREASURE, self.notifyExchangeTreasureOperation, self)
        EventControler:addEventListener(TeamFormationEvent.MULTI_UP_WULING, self.notifyUpWuLingOperation, self)
        EventControler:addEventListener(TeamFormationEvent.MULTI_EXCHANGE_WULING, self.notifyExchangeWuLingOperation, self)
    end
    EventControler:addEventListener(TeamFormationEvent.UPDATA_TREA,self.upDataPosAnimation,self)
    EventControler:addEventListener(TeamFormationEvent.PLAY_UPTOTEAMANIMATION,self.allOnToTeamFormation,self)
    EventControler:addEventListener(TeamFormationEvent.TEAMFORMATIONEVENT_UP_PARTNER, self.embattleOnePartner, self)
    EventControler:addEventListener(TeamFormationEvent.TEAMFORMATIONEVENT_UP_WULING, self.embattleOneWuXing, self)
    -- EventControler:addEventListener(TeamFormationEvent.WUXING_ANIM_CHANGED, self.updateWuLingAnimation, self)
    EventControler:addEventListener(TeamFormationEvent.DISCHARGE_ONE_PARTNER, self.notifyDisChargeOnePartner, self)
end

function WuXingTeamPartnerView:initData()
    if self.isCheck then

    else  
    	if self.systemId == FuncTeamFormation.formation.pve_tower then
            -- 获取锁妖塔上一次保存的阵容数据
            local TowerTeamInfo = TowerMainModel:getTowerTeamFormation()
            if empty(TowerTeamInfo) then
                self.npcsData = TeamFormationModel:getNPCsByTy(self.tag-1)
            else    
                self.npcsData = TeamFormationSupplyModel:getNPCsByTy(self.tag-1, nil, self.systemId)
            end
        elseif self.systemId == FuncTeamFormation.formation.guildExplorePve then
            local guildTeamInfo = GuildExploreModel:getGuildExploreTeamFormation()
            if empty(guildTeamInfo) then
                self.npcsData = TeamFormationModel:getNPCsByTy(self.tag-1)
            else
                self.npcsData = TeamFormationSupplyModel:getNPCsByTy(self.tag-1, nil, self.systemId)
            end
        end    
    end 

    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        self.mateInfo = GuildBossModel:getGuildBossMateInfo()
    end
end

function WuXingTeamPartnerView:initView()
    if self.isCheck then
        self:showOtherTeamFormation()
    else
    	--创建空动画
    	self:initEmptyAnimation()
    	--创建盘子
    	self:initFormation()
        --创建站立人物
        self:initPartnerAnimation()
    	--创建点击区域
    	self:initClickView()  	
        --创建文字动画
        self:initTxtAnimation()
    	--创建五行阵位
        if not self.playDelayAnimation then   
    	   self:initWuXingPos()
        end   
    end    
end

function WuXingTeamPartnerView:setMainTeamView(_mainTeamView)
    self.mainTeamView = _mainTeamView
end

function WuXingTeamPartnerView:setActivityStatus(_isActivity)
    self._isActivity = _isActivity
end

function WuXingTeamPartnerView:initViewAlign()
	-- TODO
	FuncCommUI.setScale9Align(self.widthScreenOffset,self.ctn_weizhi, UIAlignTypes.MiddleBottom)	
end

function WuXingTeamPartnerView:updateUI()
	-- TODO
end

function WuXingTeamPartnerView:deleteMe()
	-- TODO

	WuXingTeamPartnerView.super.deleteMe(self);
end

function WuXingTeamPartnerView:initEmptyAnimation()

    self.tempView1 = self:createUIArmature("UI_wulingbuzhen", "UI_wulingbuzhen_xia", nil, false)
    self.tempView2 = self:createUIArmature("UI_wulingbuzhen", "UI_wulingbuzhen_shang", nil, false) 
    --调整点击交互区域
    self.ctn_weizhi:pos(0,-640)
end      


function WuXingTeamPartnerView:initFormation()
    --阵容已改有一个初始的样子  进入布阵界面会根据对应systemId初始化一个tempFormation
    if self.systemId == FuncTeamFormation.formation.pve_tower or 
        self.systemId == FuncTeamFormation.formation.guildExplorePve then 
        for k = 1,6 do
            local curHeroId = TeamFormationModel:getHeroByIdx(k, self.isSecondFormation)
            if TeamFormationSupplyModel:checkIsDead(curHeroId, self.systemId) then
                local pIdx = TeamFormationModel:getPartnerPIdx(curHeroId)
                TeamFormationModel:updatePartner(pIdx,"0")
                local mc = self["mc_tai"..k]
                mc.heroId = "0"
            end
        end
    end    
    for k = 1,6 do
    		local mc = self["mc_tai"..k]
            mc:showFrame(1)
            -- 单人布阵头顶上的气泡不显示
            mc.currentView.panel_1.panel_qipao:visible(false)
            -- 底部蓝色圆板
            mc.currentView.panel_1.panel_1:visible(false)
            -- 上方血条
            mc.currentView.panel_1.panel_tiao:visible(false)

            local prop = FuncTeamFormation.getPropByTaiZi(k)
            --暂时屏蔽掉攻击防御辅助
            mc.currentView.panel_1.mc_1:visible(false)
            --echo("prop",prop,"hero",hero,"-------")
            mc.currentView.panel_1.mc_1:showFrame(prop)
            --mc.currentView.panel_1.mc_1.currentView["txt_"..prop]:setString(FuncTeamFormation.getPropTxt(prop))
            mc.currentView.panel_1.mc_1.currentView["txt_1"]:setString(FuncTeamFormation.getPropTxt(prop))
            mc.currentView.panel_1.txt_name:visible(false)
            mc.currentView.panel_1.mc_star:visible(false)
            local panel_prop = mc.currentView.panel_1.panel_prop
            panel_prop:zorder(2)
            panel_prop:setVisible(false)
    end
    self:clearCtnNode()
end

function WuXingTeamPartnerView:initPartnerAnimation()
	for k = 1,6 do
 		if self.playDelayAnimation then
            EventControler:dispatchEvent(TeamFormationEvent.OPEN_SCREANONCLICK,{type = false})
            -- self:isShowTopWuXing(false)
            self:delayCall(c_func(self.loadOneFormation,self,k), 0.1*k)
            self:delayCall(function ()
                 EventControler:dispatchEvent(TeamFormationEvent.OPEN_SCREANONCLICK,{type = true})
            end,0.5)
            -- self:loadOneFormation(k)
        else
            self:loadOneFormation(k)
        end 
    end        
end

function WuXingTeamPartnerView:notifyExchangeTreasureOperation(event)
    local params = event.params.params
    -- dump(params, "\n\nparams=notifyExchangeTreasureOperation===")
    local info = json.decode(params.info)
    local rid = params.rid
    self.multiTreasureId = info.tid
    self:initPartnerAnimation()
    TeamFormationModel:setMultiTreasureOwnerAndId(rid, self.multiTreasureId)
    self.mainTeamView:setLoadingStatus(false)
    self.mainTeamView:resumeUIClick()
    self.mainTeamView:removeLoadingAnim()
    EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
end

--监听到点击上阵五灵操作
function WuXingTeamPartnerView:embattleOneWuXing(event)
    if not self._isActivity then
        return 
    end

    if event.params and event.params.data then
        local id = event.params.data.id
        local pIdx = TeamFormationModel:getAutoPIdxByWuXingId(id)
         
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            local info = {
                        fid = tostring(id),
                        rid = UserModel:rid(),
                        pos = pIdx,
                    }
            TeamFormationServer:sendPickUpOneWuLing(info)
            self.mainTeamView:setLoadingStatus(true)
            self.mainTeamView:disabledUIClick()
            self.mainTeamView:createLoadingAnim()
        else
            local heroId = TeamFormationModel:getHeroByIdx(pIdx, self.isSecondFormation)
            TeamFormationModel:setPosWuXing(pIdx, id, nil)

            self:initWuXingPos()
            if tostring(heroId) ~= "0" then
                self:playWuLingAnimation(pIdx)
                self:playUpToAnimation(pIdx)
                self:updateOneTxtAnimation(pIdx)
            end
            
            TeamFormationModel:createWuXingNum()
            EventControler:dispatchEvent(TeamFormationEvent.TEAM_WULING_CHANGED)
            EventControler:dispatchEvent(TeamFormationEvent.WUXING_ANIM_CHANGED)
            EventControler:dispatchEvent(TeamFormationEvent.UPDATA_WUINGDATA)
        end
        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
    end
end

--多人布阵  监听到上阵五灵操作
function WuXingTeamPartnerView:notifyUpWuLingOperation(event)
    local params = event.params.params
    local info = json.decode(params.info)
    local pIdx = info.pos
    local wuxingId = info.fid
    local rid = info.rid
    
    if tostring(wuxingId) == "0" then
        rid = nil
    end

    local heroId = TeamFormationModel:getHeroByIdx(pIdx)
    TeamFormationModel:setPosWuXing(pIdx, wuxingId, rid)
    self:initWuXingPos()
    if tostring(wuxingId) ~= "0" and tostring(heroId) ~= "0" then
        self:playWuLingAnimation(pIdx)
        self:playUpToAnimation(pIdx)
    end
    
    TeamFormationModel:createMultiWuXingNum()
    EventControler:dispatchEvent(TeamFormationEvent.TEAM_WULING_CHANGED)
    EventControler:dispatchEvent(TeamFormationEvent.WUXING_ANIM_CHANGED)
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_WUINGDATA)
    EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
    self.mainTeamView:setLoadingStatus(false)
    self.mainTeamView:resumeUIClick()
    self.mainTeamView:removeLoadingAnim()
end

--多人布阵  监听到交换五灵操作
function WuXingTeamPartnerView:notifyExchangeWuLingOperation(event)
    local params = event.params.params
    local info = json.decode(params.info)
    local sourcePos = info.sourcePos
    local targetPos = info.targetPos
    local rid = params.rid
    local startMc = self["mc_tai"..sourcePos]
    local targetMc = self["mc_tai"..targetPos]

    if rid == UserModel:rid() then
        local tempView = self.ctn_node.view
        -- local tempPosWuXing = self.ctn_node.posWuXing
        local targetView = targetMc.currentView.panel_1.panel_ft.ctn_di.view
        if targetView then
            targetView:parent(self.startMcView.currentView.panel_1.panel_ft.ctn_di)
        end
        startMc.currentView.panel_1.panel_ft.ctn_di.view = targetView
        -- startMc.posWuXing = targetMc.posWuXing
        -- targetMc.posWuXing = tempPosWuXing
        local srcView = startMc.currentView.panel_1.panel_ft.ctn_di.view
        --更新原 位置
        TeamFormationModel:setPosWuXing(sourcePos, targetMc.posWuXing, targetMc.posWuXingRid)
        self:playWuLingAnimation(sourcePos)
        --更新目标位置
        if targetPos ~= 0 then
            TeamFormationModel:setPosWuXing(targetPos, startMc.posWuXing, startMc.posWuXingRid)
            self:playWuLingAnimation(targetPos) 
        end 

        if srcView then
            srcView:opacity(255)
        end
        if targetView then
            targetView:opacity(255)
        end
        self:initWuXingPos()
        EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
        self.startMcView = nil
        self.startPos = nil
        self.viewSrcPos = nil
        self:clearCtnNode()
        self.mainTeamView:setLoadingStatus(false)
        self.mainTeamView:resumeUIClick()
        self.mainTeamView:removeLoadingAnim()
    else
        --更新原 位置
        TeamFormationModel:setPosWuXing(sourcePos, targetMc.posWuXing, targetMc.posWuXingRid)
        self:playWuLingAnimation(sourcePos)
        --更新目标位置
        if targetPos ~= 0 then
            TeamFormationModel:setPosWuXing(targetPos, startMc.posWuXing, startMc.posWuXingRid)
            self:playWuLingAnimation(targetPos)
        end
        self:initWuXingPos()
        EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
    end  
end

function WuXingTeamPartnerView:notifyDisChargeOnePartner(event)
    if not self._isActivity and event.params then
        self:loadOneFormation(event.params.pIdxDischarge)
        self:initWuXingPos()
    end
end

--监听到点击上阵奇侠操作
function WuXingTeamPartnerView:embattleOnePartner(event)
    if not self._isActivity then
        return 
    end
    local otherFormationWave = FuncEndless.waveNum.SECOND
    if self.isSecondFormation then
        otherFormationWave = FuncEndless.waveNum.FIRST
    end

    if event.params and event.params.data then
        local pIdx = TeamFormationModel:getAutoPIdx(0)
        local heroId = event.params.data.id
        local teamFlag = event.params.data.teamFlag
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            local curTreaId = nil
            if tostring(heroId) == "1" then
                curTreaId = TeamFormationModel:getCurTreaByIdx(1)
            end

            local info = {
                        pid = tostring(heroId),
                        rid = UserModel:rid(),
                        pos = pIdx,
                        tid = curTreaId,
                    }
            TeamFormationServer:sendPickUpOneHero(info)
            self.mainTeamView:setLoadingStatus(true)
            self.mainTeamView:disabledUIClick()
            self.mainTeamView:createLoadingAnim()
        else
            TeamFormationModel:updatePartner(pIdx, heroId, nil, teamFlag)
            self:loadOneFormation(pIdx)
            -- self:initFormation()
            self:initWuXingPos()
            local curElementId = TeamFormationModel:getPosWuXingById(pIdx, self.isSecondFormation)
            if tostring(curElementId) ~= "0" then
                self:playUpToAnimation(pIdx)
                self:updateOneTxtAnimation(pIdx)
            end 

            if self.systemId == FuncTeamFormation.formation.endless then
                local pIdxDischarge = TeamFormationModel:getPartnerPIdx(heroId, otherFormationWave)
                if pIdxDischarge and pIdxDischarge ~= 0 then
                    TeamFormationModel:dischargePartnerByFormationWave(pIdxDischarge, otherFormationWave)
                    EventControler:dispatchEvent(TeamFormationEvent.DISCHARGE_ONE_PARTNER, {pIdxDischarge = pIdxDischarge})                                
                end  
            end
            EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
            EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
        end
        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)      
    end  
end

--多人布阵  监听到上阵奇侠操作
function WuXingTeamPartnerView:notifyUpPartnerOperation(event)
    local params = event.params.params
    local info = json.decode(params.info)
    local pIdx = info.pos
    local partnerId = info.pid
    local rid = info.rid
    local tid = info.tid

    if tid then
        self.multiTreasureId = tid
        local treaOwnerId = rid
        if tostring(partnerId) == "0" then
            treaOwnerId = nil
        end
        TeamFormationModel:setMultiTreasureOwnerAndId(treaOwnerId, self.multiTreasureId)
    end

    if tostring(partnerId) == "0" then
        rid = nil
    end
 
    TeamFormationModel:updatePartner(pIdx, partnerId, rid)
    AudioModel:playSound(MusicConfig.s_partner_shangzhen)
    self:loadOneFormation(pIdx)
    self:initWuXingPos()
    local curElementId = TeamFormationModel:getPosWuXingById(pIdx)
    if tostring(curElementId) ~= "0" and tostring(partnerId) ~= "0" then
        self:playUpToAnimation(pIdx)
    end   
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
    EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
    self.mainTeamView:setLoadingStatus(false)
    self.mainTeamView:resumeUIClick()
    self.mainTeamView:removeLoadingAnim()
end

--多人布阵  监听到交换奇侠操作
function WuXingTeamPartnerView:notifyExchangePartnerOperation(event)
    local params = event.params.params
    local info = json.decode(params.info)
    local sourcePos = info.sourcePos
    local targetPos = info.targetPos
    local rid = params.rid
    local startMc = self["mc_tai"..sourcePos]
    local targetMc = self["mc_tai"..targetPos]

    if rid == UserModel:rid() then
        local tempView = self.ctn_node.view
        local tempHeroId = self.ctn_node.heroId
        local targetView = targetMc.currentView.panel_1.ctn_player.view
        local targetRid = targetMc.rid

        if targetView then
            targetView:parent(startMc.currentView.panel_1.ctn_player):pos(0,-50)
            targetView:zorder(-1)
        end
        startMc.currentView.panel_1.ctn_player.view = targetView
        startMc.heroId = targetMc.heroId
        local startRid = startMc.rid

        tempView:parent(targetMc.currentView.panel_1.ctn_player):pos(0,-50)
        tempView:zorder(-1)
        targetMc.currentView.panel_1.ctn_player.view = tempView
        --显示属性文字
        targetMc.heroId = tempHeroId

        local srcView = startMc.currentView.panel_1.ctn_player.view
        if srcView then
            local currentFrame = srcView:getCurrentFrame()
            srcView:gotoAndPlay(currentFrame)
        end
        
        targetView = targetMc.currentView.panel_1.ctn_player.view
        if targetView then
            local  currentFrame =targetView:getCurrentFrame()
            targetView:gotoAndPlay(currentFrame)
        end 

        --更新原 位置
        TeamFormationModel:updatePartner(sourcePos, startMc.heroId, startMc.rid)
        self:loadOneFormation(sourcePos)
        --更新目标位置
        if targetPos ~= 0 then
            TeamFormationModel:updatePartner(targetPos, targetMc.heroId, targetMc.rid)
            self:loadOneFormation(targetPos)
        end

        if srcView then
            srcView:opacity(255)
        end
        if targetView then
            targetView:opacity(255)
        end

        if tonumber(startMc.heroId) ~= 0 and self.moveIng and targetPos ~= sourcePos and targetPos ~= 0 then
            local curElementId = TeamFormationModel:getPosWuXingById(sourcePos)
            if tostring(curElementId) ~= "0" then
                self:playUpToAnimation(sourcePos)
            end
        end
        if targetPos ~= 0 and self.moveIng and targetPos ~= sourcePos then    
            local curElementId = TeamFormationModel:getPosWuXingById(targetPos)
            if tostring(curElementId) ~= "0" then
                self:playUpToAnimation(targetPos)
            end
        end
        self:isShowPosWuXing(true)
        self.startMcView = nil
        self.startPos = nil
        self.viewSrcPos = nil
        self.moveIng = nil
        self:clearCtnNode()
        self.mainTeamView:setLoadingStatus(false)
        self.mainTeamView:resumeUIClick()
        self.mainTeamView:removeLoadingAnim()
        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
    else
        --更新原 位置
        TeamFormationModel:updatePartner(sourcePos, targetMc.heroId, targetMc.rid)
        --更新目标位置
        if targetPos ~= 0 then
            TeamFormationModel:updatePartner(targetPos, startMc.heroId, startMc.rid)
        end

        local targetView = targetMc.currentView.panel_1.ctn_player.view
        local startView = startMc.currentView.panel_1.ctn_player.view
        if startView then
            startView:opacity(0)
        end
        if targetView then
            targetView:opacity(0)
        end
        self:isShowPosWuXing(false)
        self:initPartnerAnimation()
        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
    end 
end

--重要的创建阵位上的spine的函数
function WuXingTeamPartnerView:loadOneFormation(k)
	local mc = self["mc_tai"..k]
	
	mc:showFrame(1)
	local lastHeroId = mc.heroId
    local curHeroId = nil
    local teamFlag = nil
    local curRid = nil
    local curElements = nil
    local curWulingId = nil
    local curHeroRid = nil

    --当重新刷新load时需要停掉气泡动画 并隐藏
    if mc.isShowQiPao then
        mc.currentView.panel_1.panel_qipao:stopAllActions()
        mc.currentView.panel_1.panel_qipao:setVisible(false)
        mc.isShowQiPao = false
    end

    if self.isMuilt then
        local currHero = TeamFormationMultiModel:getHeroByIdx(k)
        curHeroId = currHero.partner.partnerId
        curRid = currHero.partner.rid
        curWuXingRid = currHero.element.rid
        mc.curRid = curRid 
        mc.curWuXingRid = curWuXingRid
    else
        curHeroId, teamFlag, curHeroRid = TeamFormationModel:getHeroByIdx(k, self.isSecondFormation)
        echo("\nk====", k, "curHeroId===", curHeroId)
        mc.heroId = curHeroId
        mc.rid = curHeroRid
        mc.teamFlag = teamFlag
        curRid = curHeroRid    
    end    
	mc.currentView.panel_1.mc_you.currentView.ctn_tu2:removeAllChildren()
    if mc.currentView.panel_xxaxx then
        mc.currentView.panel_xxaxx.ctn_goodsicon:removeAllChildren()
    end

    --仙界对决仙人掌需要弹出气泡动画
    if self.playDelayAnimation and self.systemId == FuncTeamFormation.formation.crossPeak and 
        tostring(curHeroId) == (FuncDataSetting.getDataByHid("CrossPeakCactusId")).str then
        local chatDes = GameConfig.getLanguage("#tid_crosspeak_tips_2031")
        self:updateQiPaoContent(mc, chatDes)
    end
    if (self.systemId == FuncTeamFormation.formation.pve_tower or self.systemId == FuncTeamFormation.formation.guildExplorePve)
         and tostring(curHeroId) ~= "0" then
        mc.currentView.panel_1.panel_tiao:visible(true)
        mc.currentView.panel_1.panel_tiao:setPositionY(125)
        local nowViewData = nil
        for k,v in pairs(self.npcsData) do
            if v.id == tonumber(curHeroId) then
                nowViewData = v
            end 
        end
        if nowViewData then
            mc.currentView.panel_1.panel_tiao.progress_1:setPercent(nowViewData.HpPercent/100)
        end        
    end        

	if tostring(curHeroId) == "1" then
        if FuncCommon.isSystemOpen("treasure") then
            mc.currentView.panel_1.mc_you:showFrame(2)
            mc.currentView.panel_1.mc_you:visible(true)
            self:initPartnerTreaView(mc.currentView.panel_1.mc_you,curRid)
        else
            mc.currentView.panel_1.mc_you:showFrame(1)
            mc.currentView.panel_1.mc_you:visible(true)
        end    
        local tempTreasure = nil
        if self.isMuilt then
            local curTreaData = TeamFormationMultiModel:getCurTreaByIdx(1)
            tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaData.id)
        else
            local curTreaId = TeamFormationModel:getCurTreaByIdx(1)
            if self.multiTreasureId and self.multiTreasureId ~= "0" then
                curTreaId = self.multiTreasureId
            end  
            tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaId)
        end
        curElements = tempTreasure.wuling
        local nowWuXingData = FuncTeamFormation.getWuXingDataById(tempTreasure.wuling)
        local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconResou)
        local sp = display.newSprite(wuxingIcon):addto(mc.currentView.panel_1.mc_you.currentView.ctn_tu2) 
        -- sp:setScale(0.4)
	elseif 	tostring(curHeroId) ~= "0" then
        if FuncWonderland.isWonderLandNpc(curHeroId) or
            teamFlag then
            mc.currentView.panel_1.mc_you:visible(false)
        else
            mc.currentView.panel_1.mc_you:showFrame(1)  
            mc.currentView.panel_1.mc_you:visible(true)
            mc.currentView.panel_1.mc_you.currentView.ctn_tu2:visible(true)
            mc.currentView.panel_1.mc_you.currentView.ctn_tu3:visible(true)
            local partnerData = FuncPartner.getPartnerById(curHeroId)
            curElements = partnerData.elements
            local nowWuXingData = FuncTeamFormation.getWuXingDataById(partnerData.elements)
            local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconResou)
            local sp = display.newSprite(wuxingIcon):addto(mc.currentView.panel_1.mc_you.currentView.ctn_tu2)
            -- sp:setScale(0.4)
        end     
    else
        mc.currentView.panel_1.mc_you:showFrame(1)
    end	

    if FuncCommon.isSystemOpen("fivesoul") then 
        mc.currentView.panel_1.mc_you.currentView.ctn_tu2:visible(true)
        mc.currentView.panel_1.mc_you.currentView.ctn_tu3:visible(true)
    else
        mc.currentView.panel_1.mc_you.currentView.ctn_tu2:visible(false)
        mc.currentView.panel_1.mc_you.currentView.ctn_tu3:visible(false)
    end 

    local anim_ctn = mc.currentView.panel_1.ctn_chuxiantexiao
    local particle_ctn = mc.currentView.panel_1.ctn_particletexiao   
    anim_ctn:zorder(1)
    particle_ctn:zorder(0)
    anim_ctn:removeAllChildren()
    particle_ctn:removeAllChildren()
    if self.isMuilt then
        curWulingId = TeamFormationMultiModel:getPosWuXingById(k)
        if curWulingId == "" then
            curWulingId = "0"
        end
    else
        curWulingId = TeamFormationModel:getPosWuXingById(k, self.isSecondFormation)
    end

    if not curWulingId or not curElements then
        
    else
        if tonumber(curWulingId) ~= 0 and tonumber(curElements) == tonumber(curWulingId) then
            local anim = self:createUIArmature("UI_wulingchuzhan", FuncWuLing.ANIM_NAME[tonumber(curElements)], anim_ctn, true)
            anim:pos(-4, -10)  

            local index = tonumber(curWulingId)
            local WuLingAnim = self:createUIArmature("UI_zhandou_zhenwei","UI_zhandou_zhenwei_buzhenui", particle_ctn, true)
            WuLingAnim:setScale(1.45)
            WuLingAnim:pos(-136, 65)
            local particleAnim = WuLingAnim:getBoneDisplay("a2_ks")
            for i = 1, 10 do
                local animName = "a"..i
                local animBone = particleAnim:getBoneDisplay(animName)
                animBone:playWithIndex(index)
            end 
            local wulingBone1 = particleAnim:getBoneDisplay("a11")
            wulingBone1:playWithIndex(index)
            local wulingBone2 = particleAnim:getBoneDisplay("a12")
            wulingBone2:playWithIndex(index)           
        end
    end

    self:loadOneWuXingPos(k)
    -- echo("\nlastHeroId===", lastHeroId, curHeroId)
	if lastHeroId ~= nil and tostring(lastHeroId) ~= "0" and tostring(lastHeroId) == tostring(curHeroId) and self.changeHeroType and not self.isMuilt then
        local curSpineView = mc.currentView.panel_1.ctn_player.view
        if curSpineView then
            local  currentFrame = curSpineView:getCurrentFrame()
            curSpineView:gotoAndPlay(currentFrame)
            curSpineView:opacity(255)
            if mc.rid and mc.rid ~= UserModel:rid() then               
                FilterTools.setViewFilter(curSpineView, FilterTools.colorTransform_lowLight, 10)
            else
                FilterTools.clearFilter(curSpineView, 10)
            end  
        end
        return
    end

    mc.currentView.panel_1.panel_1:visible(false)
    local ctn = mc.currentView.panel_1.ctn_player
	ctn:removeAllChildren()
    if tostring(curHeroId) == "0" then
        --表示当前位置是个空位置
        --没有人
        --血条不可见
        mc.currentView.panel_1.panel_tiao:visible(false)
     --空位置动画
        ctn.view = nil
        return
    end
    --是否显示如上动画
    local isShowAni = false
    if lastHeroId == nil or tostring(lastHeroId) == "0" and curHeroId ~= "0" then
        --原来不存在现在存在了
        isShowAni = true
    end
    
    --加载奇侠立绘spine
    self:loadHeroSpine(mc, curHeroId, curRid)  
end

function WuXingTeamPartnerView:loadHeroSpine(mc, curHeroId, curRid)
    local ctn = mc.currentView.panel_1.ctn_player
    ctn:removeAllChildren()
    local view = nil
    if curHeroId == "1" then
        if self.isMuilt then
            if curRid == UserModel:rid() then
                view = GarmentModel:getCharGarmentSpine():addto(ctn):pos(0,-50):zorder(-1) 
            else
                view = GarmentModel:getSpineViewByAvatarAndGarmentId(tostring(TeamFormationMultiModel.otheravatar), TeamFormationMultiModel.othergarmentId):addto(ctn):pos(0,-50):zorder(-1) 
            end  
         else
            if curRid == UserModel:rid() then
                view = GarmentModel:getCharGarmentSpine():addto(ctn):pos(0,-50):zorder(-1)
            else
                if self.systemId == FuncTeamFormation.formation.guildBossGve then
                    local avatar = self.mateInfo.avatar
                    local garmentId = ""
                    if self.mateInfo.userExt then
                        garmentId = self.mateInfo.userExt.garmentId
                    end

                    view = FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, garmentId, nil, self.mateInfo):addto(ctn):pos(0,-50):zorder(-1)
                end
            end            
         end   
    else
        if curRid == UserModel:rid() then
            local partnerData = PartnerModel:getPartnerDataById(curHeroId)
            if partnerData then
                view = FuncPartner.getHeroSpineByPartnerIdAndSkin(curHeroId, partnerData.skin, nil, partnerData)
            else
                local spine, sourceId = FuncTeamFormation.getSpineNameByHeroId(curHeroId)
                local sourceData = FuncTreasure.getSourceDataById(sourceId)
                view = ViewSpine.new(spine,{},nil,spine,nil,sourceData)
            end            
        else
            if self.systemId == FuncTeamFormation.formation.guildBossGve then
                local partnerData = self.mateInfo.partners[tostring(curHeroId)]
                view = FuncPartner.getHeroSpineByPartnerIdAndSkin(curHeroId, partnerData.skin, nil, partnerData)
            else
                if PartnerModel:isHavedPatnner(curHeroId) then
                    local partnerData = PartnerModel:getPartnerDataById(curHeroId)
                    view = FuncPartner.getHeroSpineByPartnerIdAndSkin(curHeroId, partnerData.skin, nil, partnerData)
                else
                    local spine, sourceId = FuncTeamFormation.getSpineNameByHeroId(curHeroId, false)
                    local sourceData = FuncTreasure.getSourceDataById(sourceId)
                    view = ViewSpine.new(spine,{},nil,spine,nil,sourceData)
                end     
            end   
        end
        view:addto(ctn):pos(0,-50):zorder(-1)                    
    end

    if self.isMuilt then
        local opVal = nil
        if curRid == UserModel:rid() then
            opVal = self.mineOpacity
        else
            opVal = self.otherOpacity
        end
        view:opacity(opVal)
    end
   
    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        if mc.rid and mc.rid ~= UserModel:rid() then
            -- view:opacity(130)
            FilterTools.setViewFilter(view, FilterTools.colorTransform_lowLight, 10)
        else
            -- view:opacity(255)
            FilterTools.clearFilter(view, 10)
        end
    else
        if self.onClickType == FuncTeamFormation.btnChange.partner then
            -- view:opacity(255)
            FilterTools.clearFilter(view, 10)
        else
            -- view:opacity(150)
            FilterTools.setViewFilter(view, FilterTools.colorTransform_lowLight, 10)
        end
    end
      
    view:setScaleX(-1)
    ctn.view = view

    --播放站立动作   这个需要写一个npc站立方法
    view:playLabel("stand",true)
end

function WuXingTeamPartnerView:initTxtAnimation()
    for i = 1, 6, 1 do
        local pIdx = i
        self:updateOneTxtAnimation(pIdx)   
    end
end

function WuXingTeamPartnerView:updateOneTxtAnimation(pIdx)
    local mc = self["mc_tai"..pIdx] 
    mc:showFrame(1)
    local panel_prop = mc.currentView.panel_1.panel_prop
    panel_prop:setVisible(false)
    panel_prop:stopAllActions()
    panel_prop:opacity(255)
    panel_prop:pos(150, -50)
    panel_prop:zorder(2)
    local curHeroId = TeamFormationModel:getHeroByIdx(pIdx, self.isSecondFormation)
    local curWulingId, curElements = self:getElementAndWulingByLocation(pIdx)
    if tostring(curHeroId) ~= "0" and curWulingId then
        local tempLevel = WuLingModel:getWuLingLevelById(curWulingId)
        local firstProperty,secondProperty = WuLingModel:getWuLingProperty(curWulingId, tempLevel)
        local wulingType = WuLingModel:switchTextById(curWulingId)
        local xianshuDengji = GameConfig.getLanguage("#tid_wuxing_001")
        if tonumber(curWulingId) ~= 0 then 
            panel_prop:setScale(0.1)
            -- panel_prop:setVisible(false)
            if curElements and tonumber(curElements) == tonumber(curWulingId) then
                panel_prop.txt_1:setString(wulingType.."+"..firstProperty.."%")
                panel_prop.txt_2:setString(xianshuDengji.."+"..secondProperty)
            else
                panel_prop.txt_1:setString(wulingType.."+"..firstProperty.."%")
                panel_prop.txt_2:setString("")
            end
            local posX = panel_prop:getPositionX()
            local posY = panel_prop:getPositionY()

            local callBack = function ()
                panel_prop:setVisible(false)
            end

            local visibleCall = function ()
                panel_prop:setVisible(true)
                panel_prop:runAction(act.scaleto(0.5, 1))   
            end

            panel_prop:runAction(cc.Sequence:create(
                    act.delaytime(0.1),
                    act.callfunc(c_func(visibleCall)),
                    act.delaytime(2),
                    act.fadeout(0.5),
                    act.callfunc(c_func(callBack))
                ))
        end
        EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
    end
end

--创建五行阵位
function WuXingTeamPartnerView:initWuXingPos()
	for k = 1,6 do 
		--先获取阵位信息
		self:loadOneWuXingPos(k)
	end
end

function WuXingTeamPartnerView:loadOneWuXingPos(pIdx)
    local mc = self["mc_tai"..pIdx]
    local posView = mc.currentView.panel_1.panel_ft.ctn_di
    posView:removeAllChildren()
    local wuxingId = 0
    if self.isMuilt then
        wuxingId = TeamFormationMultiModel:getPosWuXingById(pIdx)
        if wuxingId == "" then
            wuxingId = "0"
        end
    else
        wuxingId, wuXingRid = TeamFormationModel:getPosWuXingById(pIdx, self.isSecondFormation)
    end
    mc.posWuXing = wuxingId
    mc.posWuXingRid = wuXingRid
    local nowWuXingData = FuncTeamFormation.getWuXingDataById(wuxingId)
    local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconPosi)
    local sp1 = display.newSprite(wuxingIcon):addto(posView)

    -- sp1:setScale(0.4)
    mc.currentView.panel_1.mc_you.currentView.ctn_tu3:removeAllChildren()
    local tempHeroId = "0"
    if self.isMuilt then
         local tempPos = TeamFormationMultiModel:getHeroByIdx(pIdx)
         tempHeroId = tempPos.partner.partnerId
    else    
        tempHeroId = TeamFormationModel:getHeroByIdx(pIdx, self.isSecondFormation)
    end    
    if tostring(tempHeroId) ~= "0" then
        local smallWuXingPosIcon = FuncRes.iconWuXing(nowWuXingData.iconBott)
        local sp2 = display.newSprite(smallWuXingPosIcon):addto(mc.currentView.panel_1.mc_you.currentView.ctn_tu3)
    end
    posView.view = sp1
    
    if mc.posWuXingRid and mc.posWuXingRid ~= UserModel:rid() then
        sp1:opacity(130)
    else
        sp1:opacity(255)
    end
end

--确定当前界面的模式
function WuXingTeamPartnerView:setWuXingOrPartner(type)
	self.onClickType = type
    self:initClickView()
	echo("当前的选择模式",self.onClickType)
end

function WuXingTeamPartnerView:doViewClick(view,pIdx)
    if TutorialManager.getInstance():isInTutorial() or TutorialManager.getInstance():isTrialFormation() then

        -- return
    end

    if not self._isActivity then
        return
    end

    if self.systemId == FuncTeamFormation.formation.crossPeak and TeamFormationModel:isCloseCandidatePanel() then
        -- 设置为false  说明候补框已被关闭
        TeamFormationModel:setCloseCandidatePanel(false)
        return 
    end

    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        local isHostPrepared, isMatePrepared = TeamFormationModel:getMultiState()
        if not self.isHost and isMatePrepared then
            return 
        end
    end
	if self.onClickType == FuncTeamFormation.btnChange.partner then
        if self.isMuilt then
            local targetParam = TeamFormationMultiModel:getHeroByIdx(pIdx)
            if tostring(targetParam.partner.rid ) ~= tostring(TeamFormationMultiModel.rid) or tostring(targetParam.element.rid) ~= tostring(TeamFormationMultiModel.rid) and tostring(targetParam.element.rid)~= "" then
                
                return false
            end 

            if TeamFormationMultiModel:getFormationLockState() == 1 then
                return
            end
        end

        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            if view.rid and view.rid ~= UserModel:rid() then
                return
            end
        end

		if view.heroId ~= nil and view.heroId ~= "0" then
	        if tostring( view.heroId ) == "1"  
                and self.systemId ~= FuncTeamFormation.formation.pve_tower 
                and self.systemId ~= FuncTeamFormation.formation.crossPeak 
                and self.systemId ~= FuncTeamFormation.formation.wonderLand
                and self.systemId ~= FuncTeamFormation.formation.guildBossGve
                and self.systemId ~= FuncTeamFormation.formation.guildBoss
                and self.systemId ~= FuncTeamFormation.formation.endless 
                and self.systemId ~= FuncTeamFormation.formation.guildExplorePve
                and self.systemId ~= FuncTeamFormation.formation.guildExploreElite then

	            WindowControler:showTips( GameConfig.getLanguage("#tid_wuxing_023"))
	            return
	        end

            echo("\n+========click===-+++11111+++++++", view.heroId)
            if FuncWonderland.isWonderLandNpc(view.heroId) then
                -- WindowControler:showTips(GameConfig.getLanguage("#tid_wonderland_shangzhen_101"))
                return
            end

            echo("\n+========click===-+++2222+++++++", view.heroId)
            if view.teamFlag and self.systemId == FuncTeamFormation.formation.crossPeak then
                WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2031"))
                return
            end

	        --下阵音效
	        AudioModel:playSound(MusicConfig.s_partner_xizhen)
            if self.isMuilt then
                if view.curRid ~= tostring(TeamFormationMultiModel.rid) then
                    return
                end
                local params = {}
                params.battleId = TeamFormationMultiModel:getRoomId()
                params.posNum = pIdx
                params.partnerId = "0"
                self:doOnPartnerAction(params)
            else
                if self.systemId == FuncTeamFormation.formation.guildBossGve then
                    local curTreaId = nil
                    if tostring(view.heroId) == "1" then
                        curTreaId = "0"
                    end

                    local info = {
                            pos = pIdx,
                            pid = "0",
                            rid = UserModel:rid(),
                            tid = curTreaId
                        }
                    TeamFormationServer:sendPickUpOneHero(info)
                    self.mainTeamView:setLoadingStatus(true)
                    self.mainTeamView:disabledUIClick()
                    self.mainTeamView:createLoadingAnim()
                else
                    TeamFormationModel:updatePartner( pIdx,"0" )
                    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
                    self:loadOneFormation(pIdx)
                    EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
                    -- self:initWuXingPos()
                end	             
            end     
	    end
	else
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            if view.posWuXingRid and view.posWuXingRid ~= UserModel:rid() then
                return
            end
        end

		if tostring(view.posWuXing) == "0" then
            return
        else
            if self.isMuilt then
                if view.curWuXingRid ~= tostring(TeamFormationMultiModel.rid) then
                    return
                end
                local params = {}
                params.battleId = TeamFormationMultiModel:getRoomId()
                params.posNum = pIdx
                params.elementId = "0"
                self:doOnWuXingPos(params)
            else
                if self.systemId == FuncTeamFormation.formation.guildBossGve then
                    local info = {
                            pos = pIdx,
                            fid = "0",
                            rid = UserModel:rid(),
                        }
                    TeamFormationServer:sendPickUpOneWuLing(info)
                else
                    local useWuXingType = TeamFormationModel:getPosWuXingById(pIdx, self.isSecondFormation)
                    TeamFormationModel:setPosWuXing(pIdx,"0")
                    self:playWuLingAnimation(pIdx) 
                    TeamFormationModel:updateWuXingNum(view.posWuXing, false)
                    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
                    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_WUINGDATA)
                    EventControler:dispatchEvent(TeamFormationEvent.TEAM_WULING_CHANGED)
                    EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
                    self:initWuXingPos()
                end              
            end               
        end
	end
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
    EventControler:dispatchEvent(TeamFormationEvent.WUXING_ANIM_CHANGED)    
end

function WuXingTeamPartnerView:doViewBegan(mcView,pIdx,event)
    if TutorialManager.getInstance():isInTutorial() or TutorialManager.getInstance():isTrialFormation() then
        -- return
    end

    if not self._isActivity then
        return 
    end

    if self.systemId == FuncTeamFormation.formation.crossPeak and TeamFormationModel:getCandidatePanelStatus() then
        return 
    end

    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        local isHostPrepared, isMatePrepared = TeamFormationModel:getMultiState()
        echo("\n\nisMatePrepared==", isMatePrepared)
        if not self.isHost and isMatePrepared then
            WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_007"))
            return 
        end
    end

	if self.onClickType == FuncTeamFormation.btnChange.partner then
        if self.systemId == FuncTeamFormation.formation.guildBossGve and 
            mcView.rid and mcView.rid ~= UserModel:rid() then
            WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_010"))
            return
        end
		self.changeHeroType = true
	    self.moveChangeType = true
        self.playDelayAnimation = false
	    if tostring(mcView.heroId) =="0" then
	        return false
	    end

        echo("\n+========began===-+++11111+++++++", mcView.heroId)
        if FuncWonderland.isWonderLandNpc(mcView.heroId) then
            WindowControler:showTips(GameConfig.getLanguage("#tid_wonderland_shangzhen_102"))
            return
        end

        echo("\n+========began===-+++2222222+++++++", mcView.heroId)
        if self.isMuilt then
            local targetParam = TeamFormationMultiModel:getHeroByIdx(pIdx)
            if tostring(targetParam.partner.rid ) ~= tostring(TeamFormationMultiModel.rid) or tostring(targetParam.element.rid) ~= tostring(TeamFormationMultiModel.rid) and tostring(targetParam.element.rid) ~= "" then
                if self.debug then
                    dump(targetParam,"doViewBegan")
                end   
                WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_026"))
                return false
            end 

            if tostring(mcView.heroId) =="0" then
                return false
            end

            if TeamFormationMultiModel:getFormationLockState() == 1 then
                 WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_018"))
                return
            end
        end


	    self.startMcView = mcView
	    self.startPos = {x = event.x,y = event.y}
        if mcView.currentView.panel_1.ctn_player.view then
            local xx ,yy = mcView.currentView.panel_1.ctn_player.view:getPosition()
     
            --计算当前的世界坐标位置
            local globelPos = mcView.currentView.panel_1.ctn_player.view:convertToWorldSpace(cc.p(xx,yy))
            self:clearCtnNode()

            mcView.currentView.panel_1.ctn_player.view:opacity(120)
            mcView.currentView.panel_1.ctn_player.view:parent(self.ctn_node):pos(0,20)
            self.ctn_node.view = mcView.currentView.panel_1.ctn_player.view
            mcView.currentView.panel_1.ctn_player.view = nil
            mcView.currentView.panel_1.mc_you.currentView.ctn_tu2:visible(false)
            mcView.currentView.panel_1.mc_you.currentView.ctn_tu3:visible(false)
            self.ctn_node.heroId = mcView.heroId
            self.ctn_node.teamFlag = mcView.teamFlag
            --设置临时节点的位置
            local cntParent = self.ctn_node:parent()
            local locaNode = cntParent:convertToNodeSpace(globelPos)
            self.ctn_node:pos(locaNode.x,locaNode.y)

            xx,yy = self.ctn_node:getPosition()
            self.viewSrcPos = {x = xx,y = yy}
            local currentFrame = self.ctn_node.view:getCurrentFrame()
            self.ctn_node.view:gotoAndStop(currentFrame)
            self:isShowPosWuXing(false)
            if mcView.isShowQiPao then
                mcView.currentView.panel_1.panel_qipao:stopAllActions()
                mcView.currentView.panel_1.panel_qipao:setVisible(false)
                mcView.isShowQiPao = false
            end
        else
            echo("\n\nmcView.currentView.panel_1.ctn_player.view == nil")
            return
        end	    
	else
        if self.isMuilt then
            local targetParam = TeamFormationMultiModel:getHeroByIdx(pIdx)
            if  tostring(targetParam.element.rid) ~= tostring(TeamFormationMultiModel.rid) and targetParam.element.rid ~= "" then
                if self.debug then
                    dump(targetParam,"doViewBeganWuxing")
                end   
                WindowControler:showTips( GameConfig.getLanguage("#tid_wuxing_026"))
                return 
            end 
            if TeamFormationMultiModel:getFormationLockState() == 1 then
                WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_018"))
                return
            end
        end
        if self.systemId == FuncTeamFormation.formation.guildBossGve and
            mcView.posWuXingRid and mcView.posWuXingRid ~= UserModel:rid() then

            WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_011"))
            return
        end
		self.changeHeroType = true
        self.moveChangeType = true
        self.startMcView = mcView
        self.startPos = {x = event.x,y = event.y}
        local xx ,yy = mcView.currentView.panel_1.panel_ft.ctn_di.view:getPosition()
        local globelPos = mcView.currentView.panel_1.panel_ft.ctn_di.view:convertToWorldSpace(cc.p(xx,yy))
        self:clearCtnNode()
        mcView.currentView.panel_1.panel_ft.ctn_di.view:opacity(120)
        mcView.currentView.panel_1.panel_ft.ctn_di.view:parent(self.ctn_node):pos(90,40)
        self.ctn_node.view = mcView.currentView.panel_1.panel_ft.ctn_di.view
        -- self.ctn_node.view:setScale(1)
        self.ctn_node.posWuXing = mcView.posWuXing
        local cntParent = self.ctn_node:parent()
        local locaNode = cntParent:convertToNodeSpace(globelPos)
        self.ctn_node:pos(locaNode.x,locaNode.y)
        xx,yy = self.ctn_node:getPosition()
        self.viewSrcPos = {x = xx,y = yy}
    end    
end

function WuXingTeamPartnerView:doViewMove(mcView,pIdx,event)
	if self.startMcView and self.startPos and self.viewSrcPos then        
        local offsetX = event.x - self.startPos.x
        local offsetY = event.y - self.startPos.y

        self.ctn_node:pos(self.viewSrcPos.x + offsetX,self.viewSrcPos.y+ offsetY)

        if self.onClickType == FuncTeamFormation.btnChange.partner then
            if self.moveIng == nil then
                self.moveIng = {}
            end
 
            local targetIdx = self:chkEnterMc(event.x, event.y)
            if targetIdx>=1 and targetIdx<=6  then

                if self.moveIng.targetMC and self.moveIng.srcMC and self.moveIng.lastIdx ~= targetIdx then
                    self:moveToMc(self.moveIng.srcMC,self.moveIng.targetMC)                 
                end
                --设置新的移动
                if self.moveIng.lastIdx ~= targetIdx and targetIdx ~= pIdx then
                    self.moveIng.targetMC = self.startMcView
                    self.moveIng.targetIdx = targetIdx
                    self.moveIng.srcMC = self["mc_tai"..targetIdx]
                    self.moveIng.srcIdx = pIdx
                    --echo("设置新移动")
                    self:moveToMc(self.moveIng.targetMC,self.moveIng.srcMC)
                    self.moveIng.lastIdx = targetIdx
                end
            else
                self.moveIng.lastIdx = targetIdx
            end

        end   
	end		
end

function WuXingTeamPartnerView:doViewEnded(mcView,pIdx,event)
    if TutorialManager.getInstance():isInTutorial() or TutorialManager.getInstance():isTrialFormation() then
        -- return
    end

	if self.onClickType == FuncTeamFormation.btnChange.partner then
        if self.isMuilt then
            self.myMouseCache_partnerId = nil

        end
        if tostring(mcView.heroId) =="0" then
            return
        end
		local localPos = self.ctn_weizhi:convertToNodeSpace(event)
	    local rect = cc.rect(0,0,960,160)
	    if rectEx.contain(rect,localPos.x, localPos.y) then
	        self.changeHeroType = false

	        if  tostring(mcView.heroId) == "1" and (self.systemId ~= FuncTeamFormation.formation.pve_tower 
                and self.systemId ~= FuncTeamFormation.formation.crossPeak and self.systemId ~= FuncTeamFormation.formation.wonderLand
	            and self.systemId ~= FuncTeamFormation.formation.guildBossGve and self.systemId ~= FuncTeamFormation.formation.guildBoss
                and self.systemId ~= FuncTeamFormation.formation.endless and self.systemId ~= FuncTeamFormation.formation.guildExplorePve
                and self.systemId ~= FuncTeamFormation.formation.guildExploreElite) then
                -- local targetView = mcView
	            if self.moveChangeType and not self.isMuilt then 
	                local tempView = self.ctn_node.view
	                local tempHeroId = self.ctn_node.heroId
	                tempView:parent(mcView.currentView.panel_1.ctn_player):pos(0,-50)
	                tempView:zorder(-1)

	                mcView.currentView.panel_1.ctn_player.view = tempView
	                mcView.heroId = tempHeroId
	            
	                local  currentFrame =mcView.currentView.panel_1.ctn_player.view:getCurrentFrame()
	                mcView.currentView.panel_1.ctn_player.view:gotoAndPlay(currentFrame)
	                mcView.currentView.panel_1.ctn_player.view:opacity(255)

	            end
                if self.isMuilt then
                    if tostring(mcView.curRid) == tostring(TeamFormationMultiModel.rid) then 
                        WindowControler:showTips( GameConfig.getLanguage("#tid_wuxing_023"))
                        self:initFormation()
                        self:initPartnerAnimation() 
                        -- self:initWuXingPos()
                    end
                else
	               WindowControler:showTips( GameConfig.getLanguage("#tid_wuxing_023"))
                end   
	        else
                if self.isMuilt then
                    if mcView.curRid ~= tostring(TeamFormationMultiModel.rid) then
                        self:initFormation()
                        self:initPartnerAnimation()
                        -- self:initWuXingPos()
                        return
                    end
                    local params = {}
                    params.battleId = TeamFormationMultiModel:getRoomId()
                    params.posNum = pIdx
                    params.partnerId = "0"
                    self:doOnPartnerAction(params)
                else
                    if self.systemId == FuncTeamFormation.formation.crossPeak and mcView.teamFlag then
                        WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2031"))
                    elseif FuncWonderland.isWonderLandNpc(mcView.heroId) then
                        WindowControler:showTips(GameConfig.getLanguage("#tid_wonderland_shangzhen_101"))
                        return
                    else
                        if self.systemId == FuncTeamFormation.formation.guildBossGve then
                            local curTreaId = nil
                            if tostring(mcView.heroId) == "1" then
                                curTreaId = "0"
                            end

                            local info = {
                                    pos = pIdx,
                                    pid = "0",
                                    rid = UserModel:rid(),
                                    tid = curTreaId
                                }
                            TeamFormationServer:sendPickUpOneHero(info)
                            self.ctn_node.view:opacity(0)
                            self.mainTeamView:setLoadingStatus(true)
                            self.mainTeamView:disabledUIClick()
                            self.mainTeamView:createLoadingAnim()
                        else
                            TeamFormationModel:updatePartner(pIdx,"0")
                            self:loadOneFormation(pIdx)
                            EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
                        end
                    end   
                end   
	        end
            if self.isMuilt then
            else 
    	        self:isShowPosWuXing(true)
    	        -- self:initFormation()
    	        self:initPartnerAnimation()
                -- self:initWuXingPos()
    	 --        -- self.scroll_1:refreshCellView(1) 
                EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
                EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT) 
            end  
	        self:clearCtnNode()
	        self.startMcView = nil
	        self.startPos = nil
	        self.viewSrcPos = nil
	        self.moveIng = nil
            
	        return
	    end

	    if self.startMcView and self.startPos and self.viewSrcPos then
	        local x,y = event.x,event.y
	        local targetMc = nil
	        local targetIdx = 0
	        for k=1,6,1 do
                --已经开启的情况
                local nd = self["mc_tai"..k].currentView.panel_1.ctn_player2.nd
                local localPos = nd:convertToNodeSpace(cc.p(x,y))
                if cc.rectContainsPoint(cc.rect(0,0,100,160),localPos) then
                    targetMc = self["mc_tai"..k]
                    targetIdx = k
                    break
                end
	        end

            -- if self.systemId == FuncTeamFormation.formation.guildBossGve and 
            --         targetMc and targetMc.rid and targetMc.rid ~= UserModel:rid() then

            --     targetMc = nil
            --     targetIdx = 0
            -- end
            dump(self.moveIng, "\n\nself.moveIng===")
	        if self.moveIng and self.moveIng.targetMC and self.moveIng.srcMC  then
	            --移动到目标内了。且 第一次进入目标内 则把原来的移动撤销回来
	            -- echo("执行撤销还原---------222222222")

                echo("\n\nself.moveIng.targetMC.heroId===", self.moveIng.targetMC.heroId, "self.moveIng.srcMC.heroId==", self.moveIng.srcMC.heroId)
                if FuncWonderland.isWonderLandNpc(self.moveIng.targetMC.heroId) then
                    WindowControler:showTips(GameConfig.getLanguage("#tid_wonderland_shangzhen_102"))
                    targetMc = nil
                    targetIdx = 0
                elseif FuncWonderland.isWonderLandNpc(self.moveIng.srcMC.heroId) then
                    WindowControler:showTips(GameConfig.getLanguage("#tid_wonderland_shangzhen_103"))
                    targetMc = nil
                    targetIdx = 0                  
                elseif self.systemId == FuncTeamFormation.formation.guildBossGve and 
                        self.moveIng.srcMC.rid and self.moveIng.targetMC.rid and 
                        self.moveIng.targetMC.rid ~= self.moveIng.srcMC.rid then

                    WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_008"))
                    targetMc = nil
                    targetIdx = 0                  
                else
                    self:moveToMc(self.moveIng.srcMC, self.moveIng.targetMC)
                end
	            
	        end

            if targetMc and targetMc.heroId and FuncWonderland.isWonderLandNpc(targetMc.heroId) then
                targetMc = nil
                targetIdx = 0
            end
            
	        if not targetMc then
	            targetMc = self.startMcView
	        end
	        if targetMc ~= self.startMcView then
	            --拖动成功音效
	            AudioModel:playSound(MusicConfig.s_partner_yiwei)
	        end

            if self.isMuilt then
                if targetIdx == pIdx then
                    targetMc = nil
                end
            end

	        if targetMc then
                if self.isMuilt then
                     local targetView = targetMc.currentView.panel_1.ctn_player.view
                     local tempHeroId = self.ctn_node.heroId

                    if targetView then
                        if tostring(targetIdx) ~= "0" then 
                            local params = {}
                            params.battleId = TeamFormationMultiModel:getRoomId()
                            params.pos = {pIdx,targetIdx}
                            if tostring(targetMc.curRid) ~= tostring(TeamFormationMultiModel.rid) then
                                params.type = ""
                            else
                                params.type = "partner"
                            end
                            TeamFormationServer:changePos(params,nil)
                        else
                            self:initFormation()
                            self:initPartnerAnimation()   
                        end    
                    else
                        if tostring(targetIdx) ~= "0" then 
                            local params = {}
                            params.battleId = TeamFormationMultiModel:getRoomId()
                            params.pos = {pIdx,targetIdx}
                            params.type = ""
                            TeamFormationServer:changePos(params,nil)          
                        end  
                        self:initFormation()
                        self:initPartnerAnimation() 
                        -- self:loadOneFormation(pIdx)   
                    end
                    if tonumber(targetMc.heroId) == 0 and targetIdx ~= 0 then
                        self:delayCall(function ()
                            self:playUpToAnimation(targetIdx)
                        end,0.3)
                    elseif targetIdx ~= 0 then
                        self:delayCall(function ()
                            self:playUpToAnimation(pIdx)
                            self:playUpToAnimation(targetIdx)
                        end,0.3)    
                    end   
                    self:clearCtnNode()
                    self:isShowPosWuXing(true)
                else   	                             
                    if self.systemId == FuncTeamFormation.formation.guildBossGve and  targetIdx ~= 0 
                        and targetIdx ~= pIdx then
                        local info = {
                                sourcePos = pIdx,
                                targetPos = targetIdx,
                            }
                        TeamFormationServer:sendExchangeHeros(info)
                        local targetView = targetMc.currentView.panel_1.ctn_player.view
                        if targetView then
                            targetView:opacity(0)
                        end
                        self.ctn_node.view:opacity(0)
                        self.mainTeamView:setLoadingStatus(true)
                        self.mainTeamView:disabledUIClick()
                        self.mainTeamView:createLoadingAnim()
                    else
                        local tempView = self.ctn_node.view
                        local tempHeroId = self.ctn_node.heroId
                        local tempTeamFlag = self.ctn_node.teamFlag
                        local targetView = targetMc.currentView.panel_1.ctn_player.view
                        local targetRid = targetMc.rid

                        if targetView then
                            targetView:parent(self.startMcView.currentView.panel_1.ctn_player):pos(0,-50)
                            targetView:zorder(-1)
                        end
                        self.startMcView.currentView.panel_1.ctn_player.view = targetView
                        self.startMcView.heroId = targetMc.heroId
                        self.startMcView.teamFlag = targetMc.teamFlag
                        local startRid = self.startMcView.rid

                        tempView:parent(targetMc.currentView.panel_1.ctn_player):pos(0,-50)
                        tempView:zorder(-1)
                        targetMc.currentView.panel_1.ctn_player.view = tempView
                        --显示属性文字
                        targetMc.heroId = tempHeroId
                        targetMc.teamFlag = tempTeamFlag
                 

                        local srcView = self.startMcView.currentView.panel_1.ctn_player.view
                        if srcView then
                            local currentFrame = srcView:getCurrentFrame()
                            srcView:gotoAndPlay(currentFrame)
                        end
                        --srcView:playLabel("stand",true)
                        
                        targetView = targetMc.currentView.panel_1.ctn_player.view
                        if targetView then
                            local  currentFrame =targetView:getCurrentFrame()
                            targetView:gotoAndPlay(currentFrame)
                        end

                        -- echoError("self.startMcView.heroId==", self.startMcView.heroId, "pIdx=", pIdx, "targetMc.heroId==", targetMc.heroId, "targetIdx=", targetIdx)
                        -- if FuncTower.isConfigEmployee(self.startMcView.heroId) then
                        --     self.startMcView.teamFlag = 1
                        -- else
                        --     self.startMcView.teamFlag = nil
                        -- end
                        -- echo("\n\nself.startMcView.teamFlag===", self.startMcView.teamFlag, "targetMc.teamFlag==", targetMc.teamFlag)

                        echo("\npIdx===", pIdx, "targetIdx==", targetIdx, "self.startMcView.heroId===", self.startMcView.heroId, "targetMc.heroId===", targetMc.heroId)
                        --更新原 位置
                        TeamFormationModel:updatePartner(pIdx, self.startMcView.heroId, targetRid, self.startMcView.teamFlag, self.startMcView.isHelper)
                        self:loadOneFormation(pIdx)
                        --更新目标位置
                        if targetIdx ~= 0 then
                            TeamFormationModel:updatePartner(targetIdx, targetMc.heroId, startRid, targetMc.teamFlag, targetMc.isHelper)
                            self:loadOneFormation(targetIdx)
                        end 

                        if srcView then
                            srcView:opacity(255)
                        end
                        if targetView then
                            targetView:opacity(255)
                        end
                        -- self:delayCall(c_func(self.initFormation,self),0.02)
                        -- self:initFormation()
                        -- self:initPartnerAnimation()
                        -- self:initWuXingPos()
                                           
                        if tonumber(self.startMcView.heroId) ~= 0 and self.moveIng and targetIdx ~= pIdx and targetIdx ~= 0 then
                            local curElementId = TeamFormationModel:getPosWuXingById(pIdx, self.isSecondFormation)
                            if tostring(curElementId) ~= "0" then
                                self:playUpToAnimation(pIdx)
                                self:updateOneTxtAnimation(pIdx)
                            end          
                        end
                        if targetIdx ~= 0 and self.moveIng and targetIdx ~= pIdx then
                            local curElementId = TeamFormationModel:getPosWuXingById(targetIdx, self.isSecondFormation)
                            if tostring(curElementId) ~= "0" then
                                self:playUpToAnimation(targetIdx)
                                self:updateOneTxtAnimation(targetIdx)
                            end  
                        end


                        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)

                        self:isShowPosWuXing(true)
                        self.startMcView = nil
                        self.startPos = nil
                        self.viewSrcPos = nil
                        self.moveIng = nil
                    end                                 
                end
            else
                self:initFormation()
                self:initPartnerAnimation()
                self:clearCtnNode()
                 -- self:loadOneFormation(pIdx)     
	        end
	    end

	else
        local localPos = self.ctn_weizhi:convertToNodeSpace(event)
        local rect = cc.rect(0,0,960,160)
        dump(localPos,"交错的位置========================")

        if self.isMuilt then
            local targetParam = TeamFormationMultiModel:getHeroByIdx(pIdx)
            if  tostring(targetParam.element.rid) ~= tostring(TeamFormationMultiModel.rid) and targetParam.element.rid ~= "" then
                self:initWuXingPos()
                return 
            end 
            if TeamFormationMultiModel:getFormationLockState() == 1 then
                self:initWuXingPos()
                return
            end
        end

        if rectEx.contain(rect,localPos.x, localPos.y) then
            self.changeHeroType = false
            if  tostring(mcView.posWuXing) == "0" then
                local tempView = self.ctn_node.view
                local tempHeroId = self.ctn_node.posWuXing
                tempView:parent(mcView.currentView.panel_1.panel_ft.ctn_di)
                mcView.currentView.panel_1.panel_ft.ctn_di.view = tempView
                mcView.posWuXing = tempHeroId
                mcView.currentView.panel_1.panel_ft.ctn_di.view:opacity(255)
                self:initWuXingPos()
            else
                if self.isMuilt then
                     local params = {}
                     params.battleId = TeamFormationMultiModel:getRoomId()
                     params.posNum = pIdx
                     params.elementId = "0"
                     self:doOnWuXingPos(params)
                else
                    if self.systemId == FuncTeamFormation.formation.guildBossGve then
                        local info = {
                                pos = pIdx,
                                fid = "0",
                                rid = UserModel:rid(),
                            }
                        TeamFormationServer:sendPickUpOneWuLing(info)
                        self.ctn_node.view:opacity(0)
                        self.mainTeamView:setLoadingStatus(true)
                        self.mainTeamView:disabledUIClick()
                        self.mainTeamView:createLoadingAnim()
                    else
                        TeamFormationModel:setPosWuXing(pIdx,"0")
                        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
                    end                    
                end   
            end
            if self.isMuilt then
                
            else    
                TeamFormationModel:createWuXingNum()
                EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
                EventControler:dispatchEvent(TeamFormationEvent.UPDATA_WUINGDATA)
                self:initWuXingPos()
            end    
           
            self.startMcView = nil
            self.startPos = nil
            self.viewSrcPos = nil
            self:clearCtnNode()
            self:playWuLingAnimation(pIdx)
            EventControler:dispatchEvent(TeamFormationEvent.WUXING_ANIM_CHANGED) 
            return
        end

        if self.startMcView and self.startPos and self.viewSrcPos then
            local x,y = event.x,event.y
            local targetMc = nil
            local targetIdx = 0
            for k=1,6,1 do
                --已经开启的情况
                local nd = self["mc_tai"..k].currentView.panel_1.ctn_player2.nd
                local localPos = nd:convertToNodeSpace(cc.p(x,y))
                if cc.rectContainsPoint(cc.rect(0,0,180,100),localPos) then
                    targetMc = self["mc_tai"..k]
                    targetIdx = k
                    break
                end
            end

            if targetMc and targetMc.posWuXingRid and targetMc.posWuXingRid ~= UserModel:rid() then
                WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_009"))
                targetMc = nil
                targetIdx = 0
            end

            if targetMc and targetMc.posWuXing == "0" and mcView.posWuXing == "0" then
                targetMc = nil
                targetIdx = 0
            end

            if self.isMuilt  then
                if targetIdx == pIdx or targetIdx == 0 then
                    self:initFormation()
                    self:initPartnerAnimation() 
                    self:initWuXingPos()
                    self.startMcView = nil
                    self.startPos = nil
                    self.viewSrcPos = nil
                    self:clearCtnNode()
                    return
                end
            end

            local needResetPower = true
            if not targetMc or targetIdx == pIdx then
                targetMc = self.startMcView
                needResetPower = false
            end
            
            if targetMc  then
                if self.isMuilt then
                    local targetView = targetMc.currentView.panel_1.ctn_player.view
                    local tempHeroId = self.ctn_node.heroId
                    if targetView then
                        local params = {}
                        params.battleId = TeamFormationMultiModel:getRoomId()
                        params.pos = {pIdx,targetIdx}
                        if  tostring(targetMc.curRid) ~= tostring(TeamFormationMultiModel.rid) then
                            params.type = ""
                        else
                            params.type = "element"
                        end
                        TeamFormationServer:changePos(params,nil)
                    else
                        local params = {}
                        params.battleId = TeamFormationMultiModel:getRoomId()
                        params.pos = {pIdx,targetIdx}
                        params.type = ""
                        TeamFormationServer:changePos(params,nil) 
                    end
                else 
                    if self.systemId == FuncTeamFormation.formation.guildBossGve and 
                        targetIdx ~= 0 and targetIdx ~= pIdx then

                        local info = {
                                    sourcePos = pIdx,
                                    targetPos = targetIdx
                                }
                        TeamFormationServer:sendExchangeWuLing(info)
                        local targetView = targetMc.currentView.panel_1.panel_ft.ctn_di.view
                        if targetView then
                            targetView:opacity(0)
                        end
                        self.ctn_node.view:opacity(0)
                        self.mainTeamView:setLoadingStatus(true)
                        self.mainTeamView:disabledUIClick()
                        self.mainTeamView:createLoadingAnim()
                    else
                        local tempView = self.ctn_node.view
                        local tempPosWuXing = self.ctn_node.posWuXing
                        local targetView = targetMc.currentView.panel_1.panel_ft.ctn_di.view
                        if targetView then
                            targetView:parent(self.startMcView.currentView.panel_1.panel_ft.ctn_di)
                        end
                        self.startMcView.currentView.panel_1.panel_ft.ctn_di.view = targetView
                        self.startMcView.posWuXing = targetMc.posWuXing
                        targetMc.posWuXing = tempPosWuXing
                        local srcView = self.startMcView.currentView.panel_1.panel_ft.ctn_di.view
                         --更新原 位置
                        TeamFormationModel:setPosWuXing(pIdx,self.startMcView.posWuXing)
                        self:playWuLingAnimation(pIdx)
                        if tostring(self.startMcView.posWuXing) ~= "0" and targetIdx ~= pIdx then
                            local curHeroId = TeamFormationModel:getHeroByIdx(pIdx, self.isSecondFormation)
                            if tostring(curHeroId) ~= "0" then
                                self:playUpToAnimation(pIdx)
                                self:updateOneTxtAnimation(pIdx)
                            end         
                        end
                        
                        --更新目标位置
                        if targetIdx ~= 0 then
                            TeamFormationModel:setPosWuXing(targetIdx,targetMc.posWuXing)
                            self:playWuLingAnimation(targetIdx)
                            if tostring(targetMc.posWuXing) ~= "0" and targetIdx ~= pIdx then
                                local curHeroId = TeamFormationModel:getHeroByIdx(targetIdx, self.isSecondFormation)
                                if tostring(curHeroId) ~= "0" then
                                    self:playUpToAnimation(targetIdx)
                                    self:updateOneTxtAnimation(targetIdx)                              
                                end 
                            end  
                        end
                        
                        

                        if srcView then
                            srcView:opacity(255)
                        end
                        if targetView then
                            targetView:opacity(255)
                        end
                        self:initWuXingPos()
                        EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
                        if needResetPower then
                            EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
                        end
                        
                        self.startMcView = nil
                        self.startPos = nil
                        self.viewSrcPos = nil
                        self:clearCtnNode()
                    end                                       
                end
            end   
        end    
    end	
    EventControler:dispatchEvent(TeamFormationEvent.WUXING_ANIM_CHANGED) 
end	

function WuXingTeamPartnerView:chkEnterMc( globelPosX,globelPosY )
    local targetIdx = -1
    for k=1,6,1 do
         --已经开启的情况
        local nd = self["mc_tai"..k].currentView.panel_1.ctn_player2.nd
        local localPos = nd:convertToNodeSpace(cc.p(globelPosX,globelPosY))
        if cc.rectContainsPoint(cc.rect(0,0,100,160),localPos) then
            if self["mc_tai"..k].heroId ~= nil and tostring(self["mc_tai"..k].heroId) ~= "0" then
                targetIdx = k     
            else
                targetIdx = k 
            end
            break
        end
    end
    return targetIdx
end

function WuXingTeamPartnerView:moveToMc( targetMc,srcMc )
    if targetMc.isShowQiPao then
        targetMc.currentView.panel_1.panel_qipao:stopAllActions()
        targetMc.currentView.panel_1.panel_qipao:setVisible(false)
        targetMc.isShowQiPao = false
    end

    if srcMc.isShowQiPao then
        srcMc.currentView.panel_1.panel_qipao:stopAllActions()
        srcMc.currentView.panel_1.panel_qipao:setVisible(false)
        srcMc.isShowQiPao = false
    end
       
    if FuncWonderland.isWonderLandNpc(targetMc.heroId) 
        or FuncWonderland.isWonderLandNpc(srcMc.heroId) then
        return
    end
    if targetMc.rid and srcMc.rid and targetMc.rid ~= srcMc.rid then
        return 
    end

    if  srcMc.currentView.panel_1.ctn_player.view then
        local tempView = targetMc.currentView.panel_1.ctn_player.view
        srcMc.currentView.panel_1.ctn_player.view:parent(targetMc.currentView.panel_1.ctn_player):pos(0,-50)
        targetMc.currentView.panel_1.ctn_player.view = srcMc.currentView.panel_1.ctn_player.view
        self.moveChangeType = false
        if tempView and self.ctn_node.view ~= tempView then
            tempView:parent(srcMc.currentView.panel_1.ctn_player):pos(0,-50)
            srcMc.currentView.panel_1.ctn_player.view = tempView
        else
            srcMc.currentView.panel_1.ctn_player.view = nil
        end
    end
end

function WuXingTeamPartnerView:isShowPosWuXing(type)
    if not FuncCommon.isSystemOpen("fivesoul") then
        for k = 1,6 do
            local mc = self["mc_tai"..k]
            mc.currentView.panel_1.mc_you.currentView.ctn_tu2:visible(false)
            mc.currentView.panel_1.mc_you.currentView.ctn_tu3:visible(false)
        end    
        return
    end  
    
	for k = 1,6 do
	 	local mc = self["mc_tai"..k]
	 	mc.currentView.panel_1.mc_you.currentView.ctn_tu2:visible(type)
        mc.currentView.panel_1.mc_you.currentView.ctn_tu3:visible(type)
        if mc.currentView.panel_1.mc_you.currentView.panel_xxaxx then
            mc.currentView.panel_1.mc_you.currentView.panel_xxaxx:visible(type)
        end
        if tostring(mc.heroId) ~= "0" and 
            (self.systemId == FuncTeamFormation.formation.pve_tower or self.systemId == FuncTeamFormation.formation.guildExplorePve) then
            mc.currentView.panel_1.panel_tiao:visible(type)
        end    

	end
end

function WuXingTeamPartnerView:clearCtnNode(  )
    self.ctn_node:removeAllChildren()
    self.ctn_node.view = nil
    self.ctn_node.heroId = nil
    self.ctn_node.posWuXing = nil
    self.ctn_node.teamFlag = nil
end

function WuXingTeamPartnerView:initClickView()
	 for k = 1,6 do
    	local mc = self["mc_tai"..k]
		local ctn = mc.currentView.panel_1.ctn_player2
        local ctn_player = mc.currentView.panel_1.ctn_player
	    ctn:removeAllChildren()
	    local nd = display.newNode()
	    
	    --注册点全部放到脚下
        if self.onClickType == FuncTeamFormation.btnChange.partner then
            local viewSize  = cc.size(100,160)
            nd:setContentSize(viewSize)
            nd:anchor(0,0)
	        nd:pos(-viewSize.width* 0.5,-viewSize.height * 0.1-40)
            if ctn_player.view and self.systemId ~= FuncTeamFormation.formation.guildBossGve then
                -- ctn_player.view:opacity(255)
                FilterTools.clearFilter(ctn_player.view, 10)
                
            end
        else
            local viewSize  = cc.size(180,90)
            nd:setContentSize(viewSize)
            -- local layer = cc.LayerColor:create(cc.c4b(0,0,0,255), 180, 90)
            -- nd:addChild(layer)
            nd:anchor(0,0)
            nd:pos(-viewSize.width* 0.5,-viewSize.height * 0.1-80)
            if ctn_player.view and self.systemId ~= FuncTeamFormation.formation.guildBossGve then
                -- ctn_player.view:opacity(150)
                FilterTools.setViewFilter(ctn_player.view, FilterTools.colorTransform_lowLight, 10)
            end
        end   
	    nd:addto(ctn):zorder(1)
	    ctn.nd = nd
	    mc.currentView.panel_1.ctn_player2.nd:setTouchedFunc(
	        c_func(self.doViewClick,self,mc,k), 
	        nil, 
	        true, 
	        c_func(self.doViewBegan, self,mc,k), 
	        c_func(self.doViewMove, self,mc,k),
	        false,
	        c_func(self.doViewEnded, self,mc,k) 
	        )
	 end   
end

function WuXingTeamPartnerView:checkOneEffect(x,y)
	local pIdx = nil
	for k=1,6,1 do
        --已经开启的情况
        local nd = self["mc_tai"..k].currentView.panel_1.ctn_player2.nd
        local localPos = nd:convertToNodeSpace(cc.p(x,y))
        if self.onClickType == FuncTeamFormation.btnChange.partner then
            if cc.rectContainsPoint(cc.rect(0,-40,100,120),localPos) then
                pIdx = k
                break
            end
        else
            -- if k == 6 then
            --     dump(localPos,"=======================")
            -- end
             if cc.rectContainsPoint(cc.rect(0,0,180,100),localPos) then
                pIdx = k
                break
            end
        end
     end
     return pIdx
end

function WuXingTeamPartnerView:upDataPosAnimation(event)
    if event.params and event.params.isSecondWave and event.params.isSecondWave ~= self.isSecondFormation then
        return
    end

    if event.params and event.params.changeHeroType then
        self.changeHeroType = event.params.changeHeroType
    end
    self.playDelayAnimation = false
    -- self:initFormation()
    self:initPartnerAnimation()
    -- self:initWuXingPos()
    self:isShowPosWuXing(true)
end

function WuXingTeamPartnerView:initPartnerTreaView(view,curRid)
    local curTrea = nil
    if self.isMuilt then
        local curTreaData = nil
        if curRid == UserModel:rid() then
            curTreaData = TeamFormationMultiModel:getCurTreaByIdx(1)
            curTrea = curTreaData.id
        else
            curTreaData = TeamFormationMultiModel:getCurTreaByIdx(2)
            curTrea = curTreaData.id
        end
    else
        curTrea = TeamFormationModel:getCurTreaByIdx(1)
        if self.multiTreasureId and self.multiTreasureId ~= "0" then
            curTrea = self.multiTreasureId
        end
    end   
    -- local treaData = nil
    -- if curTrea ~= nil then
    --     treaData = TeamFormationModel:getTreaById( curTrea )
    -- end
    if  curTrea ~= nil and tostring(curTrea) ~= "0" then
        local icon = FuncRes.iconTreasureNew( curTrea )
        local tsp = display.newSprite(icon):size(28,28)
        view.currentView.panel_xxaxx.ctn_goodsicon:removeAllChildren()
        tsp:addto(view.currentView.panel_xxaxx.ctn_goodsicon)
    else
          
    end
end

function WuXingTeamPartnerView:updateFormationAndTrea()
    self:initData()
   
    -- self:initFormation()

    self:initPartnerAnimation()
    -- self:initWuXingPos()
    self:isShowPosWuXing(true)
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT) 
end

function WuXingTeamPartnerView:doOnPartnerAction(params)
   if TeamFormationMultiModel:getFormationLockState() == 1 then
         WindowControler:showTips( GameConfig.getLanguage("#tid_wuxing_018"))
        return
   end 
   TeamFormationServer:doOnPartner(params,nil)  
end

function WuXingTeamPartnerView:doOnWuXingPos(params)
    if TeamFormationMultiModel:getFormationLockState() == 1 then
         WindowControler:showTips( GameConfig.getLanguage("#tid_wuxing_018"))
        return
   end 
   TeamFormationServer:doChangeWuXing(params,nil) 
end

function WuXingTeamPartnerView:multiFormationChat(e)
    --聊天内容
    local data = e.params.params.data
    -- dump(data,"客户端收到的聊天内容-----------------")

    self:setQiPaoChat(data)
    ChatServer:requestTeamMessage(e)
end

--[[
聊天气泡
]]
function WuXingTeamPartnerView:setQiPaoChat(chatData)
    --if chatData
    local id = chatData.rid
    local chatDes = ""
    if tostring(chatData.type) == "3" then
        chatDes = FuncTeamFormation.getQuickChatContent(chatData.content)
    elseif tostring(chatData.type) == "2" then
        chatDes = chatData.content
    else
        echo("语音聊天  暂时不使用这个功能-----------")
    end

    --查抄rid对应的主角



    local mcView = nil
    for i=1,6,1 do
        local mc = self["mc_tai"..i]
        if tostring(mc.curRid) == id and tostring(mc.heroId) == "1" then
            mcView = mc
            break
        end
    end

    -- chatDes = "你号"
    local spSize = {}
    local height,lengthnum = FuncCommUI.getStringHeightByFixedWidth(chatDes,16,nil,210)
    if lengthnum == 1 then
        widths = FuncCommUI.getStringWidth(chatDes, 16)
    else
        widths = 200
    end
    spSize.width = widths +13
    spSize.height = height + 15
    local wordNum = math.floor(spSize.width/16)
    local tempWordNum = wordNum
    if wordNum <=6 then
        wordNum = 6
        spSize.width = 106
    else
        wordNum = 12
        spSize.width = 213
    end
     
    if mcView then
        mcView.currentView.panel_1.panel_qipao:stopAllActions()
        mcView.currentView.panel_1.panel_qipao:visible(true)
        mcView.currentView.panel_1.panel_qipao:setPosition(20,200)
        mcView.currentView.panel_1.panel_qipao.scale9_chat2:setContentSize(spSize)
        if lengthnum > 1 then
            mcView.currentView.panel_1.panel_qipao.scale9_chat2:setPosition(0,(lengthnum-1)*19-11)
            mcView.currentView.panel_1.panel_qipao.rich_1:setPosition(12,(lengthnum-1)*19-20)
        else
            mcView.currentView.panel_1.panel_qipao.scale9_chat2:setPosition((12-wordNum)*8,-11)
            mcView.currentView.panel_1.panel_qipao.rich_1:setPosition((12-tempWordNum)*8+4,-20)
        end

        mcView.currentView.panel_1.panel_qipao.rich_1:setString(chatDes)
        mcView.currentView.panel_1.panel_qipao:delayCall(function()
            mcView.currentView.panel_1.panel_qipao:visible(false)
        end, 4)
    end
end

--设置气泡动画
function WuXingTeamPartnerView:updateQiPaoContent(mcView, chatDes)
    local qipaoView = mcView.currentView.panel_1.panel_qipao
    qipaoView:stopAllActions()
    qipaoView:visible(true)
    qipaoView:setScale(0)
    qipaoView.rich_1:setString(chatDes)

    local delayCall = function ()
        qipaoView:visible(false)
    end

    mcView.isShowQiPao = true
    local actSequence = act.sequence(act.scaleto(0.3, 1, 1), act.delaytime(3), act.scaleto(0.2, 0, 0), act.delaytime(2))
    qipaoView:runAction(act.sequence(act._repeat(actSequence, 3), act.callfunc(delayCall)))
end

function WuXingTeamPartnerView:showOtherTeamFormation()
    local otherTeamFormationData  = LineUpModel:getOtherTeamFormation()
    local otherHeroFormationData  = LineUpModel:getOtherTeamFormationData()
    for i =1,6 do
        local mc = self["mc_tai"..i]

        mc:showFrame(1) 
        --单人布阵头顶上的气泡不显示
        mc.currentView.panel_1.panel_qipao:visible(false)
        --蓝色的条
        mc.currentView.panel_1.panel_1:visible(false)
        mc.currentView.panel_1.panel_tiao:visible(false)
        --暂时屏蔽掉攻击防御辅助
        mc.currentView.panel_1.mc_1:visible(false)
        mc.currentView.panel_1.txt_name:visible(false)
        mc.currentView.panel_1.mc_star:visible(false)
        mc.currentView.panel_1.panel_prop:setVisible(false)
        curHeroId = otherTeamFormationData.partnerFormation["p"..i].partner.partnerId or "0"
        curWuXingId = otherTeamFormationData.partnerFormation["p"..i].element.elementId or "0"
        if tostring(curHeroId) ~= "0" then
            local ctn = mc.currentView.panel_1.ctn_player
            local view = nil
            mc.currentView.panel_1.mc_you.currentView.ctn_tu2:removeAllChildren()
            if tostring(curHeroId) == "1" then
                view = self:getCharGarmentSpine():addto(ctn):pos(0,-50):zorder(-1)
                if tonumber(otherHeroFormationData.level) >= 43 then
                    mc.currentView.panel_1.mc_you:showFrame(2)
                    local otherTeamFormationData  = LineUpModel:getOtherTeamFormation()
                    local curTrea = otherTeamFormationData.treasureFormation["p1"]
                    local icon = FuncRes.iconTreasureNew( curTrea )
                    local tsp = display.newSprite(icon):size(33.3,33.3)
                    mc.currentView.panel_1.mc_you.currentView.panel_xxaxx.ctn_goodsicon:removeAllChildren()
                    tsp:addto(mc.currentView.panel_1.mc_you.currentView.panel_xxaxx.ctn_goodsicon)   
                else
                    mc.currentView.panel_1.mc_you:showFrame(1)     
                end
            else
                mc.currentView.panel_1.mc_you:showFrame(1)
                local partnerData = otherHeroFormationData.partners[tostring(curHeroId)]
                local spine, sourceId = FuncTeamFormation.getSpineNameByHeroId(curHeroId, false, partnerData.skin)
                local sourceData = FuncTreasure.getSourceDataById(sourceId)
                view = ViewSpine.new(spine,{},nil,spine,nil,sourceData):addto(ctn):pos(0,-50):zorder(-1)       
            end
            view:setScaleX(-1)
            view:playLabel("stand",true)
            local nowWuXingData = FuncTeamFormation.getWuXingDataById(curWuXingId)
            local posView = mc.currentView.panel_1.panel_ft.ctn_di
            local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconPosi)
            local sp1 = display.newSprite(wuxingIcon):addto(posView)
            sp1:setScale(0.4)
            mc.currentView.panel_1.mc_you.currentView.ctn_tu3:removeAllChildren()
            if tostring(curHeroId) ~= "0" then
                local smallWuXingPosIcon = FuncRes.iconWuXing(nowWuXingData.iconBott)
                local sp2 = display.newSprite(smallWuXingPosIcon):addto(mc.currentView.panel_1.mc_you.currentView.ctn_tu3)
                local nowWuXingData = nil
                if tostring(curHeroId) ~= "1" then
                    local partnerData = FuncPartner.getPartnerById(curHeroId)
                    nowWuXingData = FuncTeamFormation.getWuXingDataById(partnerData.elements)
                else
                    local tempTreasure = FuncTreasureNew.getTreasureDataById(otherTeamFormationData.treasureFormation["p1"])
                    nowWuXingData =  FuncTeamFormation.getWuXingDataById(tempTreasure.wuling)
                end   
                local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconResou)
                local sp = display.newSprite(wuxingIcon):addto(mc.currentView.panel_1.mc_you.currentView.ctn_tu2) 
            end
            
        end
    end

end

function WuXingTeamPartnerView:getCharGarmentSpine()
    local otherHeroFormationData  = LineUpModel:getOtherTeamFormationData()
    local garmentId = otherHeroFormationData.garment
    local charView = GarmentModel:getSpineViewByAvatarAndGarmentId(otherHeroFormationData.avatar, garmentId);

    return charView;
end

function WuXingTeamPartnerView:checkTempNpcs(id)
    if self.hasNpcs then
        for k,v in pairs(self.hasNpcs) do
            if tostring(v) == tostring(id) then
                return true
            end
        end
        return false
    end 
end

function WuXingTeamPartnerView:playUpToAnimation(pIdx)
    self["mc_tai"..pIdx].currentView.panel_1.ctn_kongdonghua:zorder(99)
    self["mc_tai"..pIdx].currentView.panel_1.ctn_kongdonghua:removeAllChildren()
    local tempAnitiom1 = self:createUIArmature("UI_wulingbuzhen","UI_wulingbuzhen_xia",self["mc_tai"..pIdx].currentView.panel_1.ctn_kongdonghua,false)
    local tempAnitiom2 = self:createUIArmature("UI_wulingbuzhen","UI_wulingbuzhen_shang",self["mc_tai"..pIdx].currentView.panel_1.ctn_kongdonghua,false)
    tempAnitiom1:pos(2, -45)      
end

function WuXingTeamPartnerView:playWuLingAnimation(pIdx)
    local anim_ctn = self["mc_tai"..pIdx].currentView.panel_1.ctn_chuxiantexiao
    local particle_ctn = self["mc_tai"..pIdx].currentView.panel_1.ctn_particletexiao
    particle_ctn:removeAllChildren()
    anim_ctn:removeAllChildren()
    
    local wulingId, nowElement = self:getElementAndWulingByLocation(pIdx)
    if wulingId and nowElement then
        if tonumber(wulingId) ~= 0 and tonumber(nowElement) == tonumber(wulingId) then
            local anim = self:createUIArmature("UI_wulingchuzhan", FuncWuLing.ANIM_NAME[tonumber(nowElement)], anim_ctn, true)
            anim:pos(-4, -10) 

            local index = tonumber(wulingId)
            local WuLingAnim = self:createUIArmature("UI_zhandou_zhenwei","UI_zhandou_zhenwei_buzhenui", particle_ctn, true)
            WuLingAnim:setScale(1.45)
            WuLingAnim:pos(-136, 65)
            local particleAnim = WuLingAnim:getBoneDisplay("a2_ks")
            for i = 1, 10 do
                local animName = "a"..i
                local animBone = particleAnim:getBoneDisplay(animName)
                animBone:playWithIndex(index)
            end 
            local wulingBone1 = particleAnim:getBoneDisplay("a11")
            wulingBone1:playWithIndex(index)
            local wulingBone2 = particleAnim:getBoneDisplay("a12")
            wulingBone2:playWithIndex(index)         
        end
    end
end

function WuXingTeamPartnerView:getElementAndWulingByLocation(pIdx)
    local wulingId = TeamFormationModel:getPosWuXingById(pIdx, self.isSecondFormation)
    local heroId = TeamFormationModel:getHeroByIdx(pIdx, self.isSecondFormation) 
    local nowElement = nil
    if tostring(heroId) == "1" then
        local curTreaData = nil
        local tempTreasure = nil
        if self.isMuilt then
            curTreaData = TeamFormationMultiModel:getCurTreaByIdx(1)
            tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaData.id)
        else
            curTreaData = TeamFormationModel:getCurTreaByIdx(1)
            if self.multiTreasureId and self.multiTreasureId ~= "0" then
                curTreaData = self.multiTreasureId
            end 
            tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaData)
        end    
        nowElement = tempTreasure.wuling
    else
        if tostring(heroId) ~= "0" then
            local partnerData = FuncPartner.getPartnerById(heroId)
            if partnerData then
                nowElement = partnerData.elements
            end
        end                   
    end
    return wulingId, nowElement
end

function WuXingTeamPartnerView:updateWuLingAnimation()
    echo("\n\n__________")
    for i = 1, 6, 1 do       
        local pIdx = i
        local anim_ctn = self["mc_tai"..pIdx].currentView.panel_1.ctn_chuxiantexiao
        anim_ctn:removeAllChildren()
        
        local wulingId, nowElement = self:getElementAndWulingByLocation(pIdx)
        if not wulingId or not nowElement then
        
        else
            if tonumber(wulingId) ~= 0 and tonumber(nowElement) == tonumber(wulingId) then
                local anim = self:createUIArmature("UI_wulingchuzhan", FuncWuLing.ANIM_NAME[tonumber(nowElement)], anim_ctn, true)
                -- if tonumber(nowElement) == 1 then
                --     anim = self:createUIArmature("UI_wulingchuzhan","UI_wulingchuzhan_feng", anim_ctn, true)
                -- elseif tonumber(nowElement) == 2 then
                --     anim = self:createUIArmature("UI_wulingchuzhan","UI_wulingchuzhan_lei", anim_ctn, true)
                -- elseif tonumber(nowElement) == 3 then
                --     anim = self:createUIArmature("UI_wulingchuzhan","UI_wulingchuzhan_shui", anim_ctn, true)
                -- elseif tonumber(nowElement) == 4 then
                --     anim = self:createUIArmature("UI_wulingchuzhan","UI_wulingchuzhan_huo", anim_ctn, true)
                -- elseif tonumber(nowElement) == 5 then
                --     anim = self:createUIArmature("UI_wulingchuzhan","UI_wulingchuzhan_tu", anim_ctn, true)       
                -- end 
                anim:pos(-4, -10)            
            end
        end
    end
end

function WuXingTeamPartnerView:allOnToTeamFormation()
    self.playDelayAnimation = false
    local tempList = TeamFormationModel:getTempFormation()
    if not self.isSecondFormation then
        for k,v in pairs(tempList.partnerFormation) do
            if tostring(v.partner.partnerId) ~= "0" and tostring(v.element.elementId) ~= "0" then
                local tempNum = string.sub(k,2,2)
                self:playUpToAnimation(tempNum)
                self:updateOneTxtAnimation(tempNum)
            end
        end
    else
        for k,v in pairs(tempList.partnerFormation2) do
            if tostring(v.partner.partnerId) ~= "0" and tostring(v.element.elementId) ~= "0" then
                local tempNum = string.sub(k,2,2)
                self:playUpToAnimation(tempNum)
                self:updateOneTxtAnimation(tempNum)
            end
        end
    end
    
    self:delayCall(function ()
         EventControler:dispatchEvent(TeamFormationEvent.OPEN_SCREANONCLICK,{type = true})
    end,0.8)
end

function WuXingTeamPartnerView:multiFormationAllToUp()
    self.playDelayAnimation = false
    local tempList = TeamFormationMultiModel:getTempFormation()
    for k,v in pairs(tempList.partnerFormation) do
        if tostring(v.partner.partnerId) ~= "0" and v.partner.rid == UserModel:rid() then
            local tempNum = string.sub(k,2,2)
            self:delayCall(function ()
                self:playUpToAnimation(tempNum)
            end,0.3)  
        end
    end
    self:delayCall(function ()
         EventControler:dispatchEvent(TeamFormationEvent.OPEN_SCREANONCLICK,{type = true})
    end,0.8)
end

function WuXingTeamPartnerView:isShowTopWuXing(type)
    for k=1,6 do 
        local mc = self["mc_tai"..k]
        mc.currentView.panel_1.mc_you.currentView.ctn_tu3:visible(type)
    end
end


return WuXingTeamPartnerView;
