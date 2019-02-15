--[[
    Author: caocheng
    Date:2017-10-12
    Description: 五行布阵主界面
]]

local WuXingTeamEmbattleView = class("WuXingTeamEmbattleView",UIBase);

function WuXingTeamEmbattleView:ctor(winName,systemId,params,isMainView,isMuilt,isNpcs)
    WuXingTeamEmbattleView.super.ctor(self, winName)
    local npcs = nil
    local raidId = nil
    self.partnerTags = nil
    self.tagsDescription = nil

    if params ~= nil then
        self.params = params
        local pdata = params[systemId]
        if pdata ~= nil then
            npcs = pdata.npcs
            raidId = pdata.raidId
            self.secondRaidId = pdata.secondRaidId
            self.partnerTags = pdata.tags
            self.attr_addition = pdata.attr_addition
            self.groupId = pdata.groupId
            self.tagsDescription = pdata.tagsDescription        
        end
        if params.isPvpAttack then
            self.isPvpAttack = true
        end
        if params.isMissionPvp then
            self.isMissionPvp = true
        end
    end

    --如果阵容都是精英 则 都走pve  预设阵容1
    self.systemId = systemId
    self.elitNpc = npcs
    self.raidId = raidId
    self.changeHeroType = true
    -- 界面右下五灵与布阵切换类型
    self.nowChangeView = FuncTeamFormation.btnChange.partner
    -- 界面左下奇侠类型分类按钮
    self.tag = FuncTeamFormation.tagType.all
    self.isMainView = isMainView or false
    self.isMuilt = isMuilt or false
    self:setNodeEventEnabled(true)
    self.curFormationWave = FuncEndless.waveNum.FIRST

    if self.groupId then
        if self.groupId == UserModel:rid() then
            self.isHost = true
        end
        TeamFormationModel:setMultiTreasureOwnerAndId(nil)
        TeamFormationModel:setMultiState(false, false)    
    end

    --将进入布阵时的一些状态保存到model中
    TeamFormationModel:setCurrentSystemId(self.systemId)
    TeamFormationModel:setIsHost(self.isHost)
    TeamFormationModel:setCurrentTags(self.partnerTags)
    TeamFormationModel:setAttrAddition(self.attr_addition)
    TeamFormationModel:setCurFormationWave()

    -- 须臾仙境特殊玩法  需要上一个固定的npc 根据type和层数去取得npcId 如果有就设置到model中去 再在model中去初始化
    if self.systemId == FuncTeamFormation.formation.wonderLand and params ~= nil then
        local floor = params[FuncTeamFormation.formation.wonderLand].floor
        local bossType = params[FuncTeamFormation.formation.wonderLand].bossType

        local npc = FuncWonderland.getNpcByFloor(bossType, floor)
        TeamFormationModel:setWonderLandStaticNpc(npc)
        TeamFormationModel:createTempFormation(self.systemId,bossType,self.elitNpc)
    end

    if self.systemId == FuncTeamFormation.formation.crossPeak then
        TeamFormationModel:setCurrentCrossPeakPlayMode(FuncCrosspeak.getPlayerModel())
    end

    if self.isMuilt then

    else
        if self.systemId ~= FuncTeamFormation.formation.wonderLand then
            TeamFormationModel:createTempFormation(self.systemId,self.raidId,self.elitNpc)
        end     
        TeamFormationModel:createWuXingNum()
    end 

    self.isNpcs = isNpcs or false

    -- 是否是在引导中
    -- self.isInGuide = TutorialManager.getInstance():isInTutorial()
end

function WuXingTeamEmbattleView:loadUIComplete()
    self:registerEvent()
    self:initData()
    self:initViewAlign()
    self:initView()
    self:updateUI()
end 

function WuXingTeamEmbattleView:setCurFormationWave(_formationWave)
    self.curFormationWave = _formationWave
    if self.curFormationWave and self.curFormationWave == FuncEndless.waveNum.SECOND then
        self.isSecondFormation = true
    else
        self.isSecondFormation = false
    end
end

function WuXingTeamEmbattleView:registerEvent()
    WuXingTeamEmbattleView.super.registerEvent(self);

    self.btn_back:zorder(-1)
    -- self.UI_backhome:zorder(-1)
    self.btn_chakandiqing:zorder(-1)
    if self.systemId == FuncTeamFormation.formation.pve 
        or self.systemId == FuncTeamFormation.formation.pvp_defend
        or self.systemId == FuncTeamFormation.formation.pvp_attack
        or self.systemId == FuncTeamFormation.formation.shareBoss
        or self.systemId == FuncTeamFormation.formation.wonderLand
        or self.systemId == FuncTeamFormation.formation.crossPeak
        or self.systemId == FuncTeamFormation.formation.guildBoss
        or self.systemId == FuncTeamFormation.formation.endless
    then
        self.btn_back:setTouchedFunc(c_func(self.doOKClick,self))
    else
        self.btn_back:setTouchedFunc(c_func(self.doBackClick,self))
    end
    EventControler:addEventListener(TeamFormationEvent.UPDATA_SCROLL,self.updateScrollView, self)
    EventControler:addEventListener(TeamFormationEvent.UPDATA_WUINGDATA,self.setWuXingTitle,self)
    EventControler:addEventListener(TeamFormationEvent.CLOSE_TEAMVIEW,self.doBackClick,self)
    if self.isMuilt then
        EventControler:addEventListener("notify_battle_formationComp_5008",self.notifyStartBattle,self)
        EventControler:addEventListener("notify_battle_player_level_5052",self.notifyPlayerLevel,self)
        FightEvent:addEventListener(BattleEvent.BATTLEEVENT_MULITI_UPDATE_FORMATION, self.updateFormationItem, self)
    end
    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        EventControler:addEventListener("notify_crosspeak_battleOperation", self.notifyCloseServerRealTime, self)
    end
    EventControler:addEventListener(WuLingEvent.WULINGEVENT_MAINVIEW_UPDATA, self.updateWuXingScrollView, self)  
    EventControler:addEventListener(TeamFormationEvent.TEAM_WULING_CHANGED, self.updateWuXingScrollView, self)
    EventControler:addEventListener(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE, self.notifyPlayerLevel, self)
    EventControler:addEventListener(TeamFormationEvent.UPDATA_TREA, self.updataWuXingView, self)
    EventControler:addEventListener(TeamFormationEvent.UPDATA_TREA, self.initTreaView, self) 
    EventControler:addEventListener(TeamFormationEvent.CLOSE_PARTNER_DETAILVIEW, self.hidePartnerDetailView, self)
    EventControler:addEventListener(TeamFormationEvent.CLOSE_LOOK_OVER_VIEW, self.hideLookOverView, self)
    EventControler:addEventListener(HomeEvent.CLICK_GOHOME_EVENT, self.clickGoHomeButton, self)
    EventControler:addEventListener(TeamFormationEvent.CLOSE_WUXING_DETAILVIEW, self.hideWuLingDetailView, self)
    EventControler:addEventListener(TeamFormationEvent.CLICK_LOOKOVER_BACK_EVENT, self.clickGoHomeButton, self)
    
    --如果是登仙台布阵需要监听buff变化的消息
    if self.systemId == FuncTeamFormation.formation.pvp_defend
       or self.systemId == FuncTeamFormation.formation.pvp_attack then
        EventControler:addEventListener(PvpEvent.PVP_BUFF_REFRESH_EVENT, self.notifyPvpBuffChanged, self)
    end     
end

function WuXingTeamEmbattleView:clickGoHomeButton()
    if self.systemId == FuncTeamFormation.formation.pve 
        or self.systemId == FuncTeamFormation.formation.pvp_defend
        or self.systemId == FuncTeamFormation.formation.pvp_attack
        or self.systemId == FuncTeamFormation.formation.shareBoss
        or self.systemId == FuncTeamFormation.formation.wonderLand
        or self.systemId == FuncTeamFormation.formation.crossPeak
        or self.systemId == FuncTeamFormation.formation.guildBoss
        or self.systemId == FuncTeamFormation.formation.endless
    then
        self:doOKClick()
    else
        self:doBackClick()
    end
end

function WuXingTeamEmbattleView:notifyPvpBuffChanged()
    self:initData()
    -- EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
    self:initScrollPartener()
end

function WuXingTeamEmbattleView:initData()
    --竞技场需要显示本周buff加成
    if self.systemId == FuncTeamFormation.formation.pvp_defend
       or self.systemId == FuncTeamFormation.formation.pvp_attack then
        self.pvpBuffId = PVPModel:getBuffIdByServerTime()
    end

    if self.systemId == FuncTeamFormation.formation.pve_tower then
        local TowerTeamInfo = TowerMainModel:getTowerTeamFormation()
        if empty(TowerTeamInfo) then
            self.npcsData = TeamFormationModel:getNPCsByTy(self.tag-1)
        else
            self.npcsData = TeamFormationSupplyModel:getNPCsByTy(self.tag-1, nil, self.systemId)
        end

        local curTrea = TeamFormationModel:getCurTreaByIdx(1)
        local banTreasures = TowerMainModel:getBanTreasure()
        if curTrea ~= nil and tostring(curTrea) ~= "0" then
            for k,v in pairs(banTreasures) do
                if tostring(k) == tostring(curTrea) then
                    local allTreas = TeamFormationModel:getAllTreas()
                    local tempTrea 
                    for i,v in ipairs(allTreas) do
                        if tostring(v.id) ~= tostring(curTrea) and not banTreasures[tostring(v.id)] then
                            tempTrea = v.id
                            break
                        end
                    end
                    TeamFormationModel:updateTrea(1, tempTrea)
                end
            end
        end

    elseif self.systemId == FuncTeamFormation.formation.guildExplorePve then
        local guildTeamInfo = GuildExploreModel:getGuildExploreTeamFormation()
        if empty(guildTeamInfo) then
            self.npcsData = TeamFormationModel:getNPCsByTy(self.tag-1)
        else
            self.npcsData = TeamFormationSupplyModel:getNPCsByTy(self.tag-1, nil, self.systemId)
        end

    elseif self.systemId == FuncTeamFormation.formation.trailPve1
            or self.systemId == FuncTeamFormation.formation.trailPve2
            or self.systemId == FuncTeamFormation.formation.trailPve3 then
            if self.tag == FuncTeamFormation.tagType.all and self.isMuilt then
                self.npcsData = TeamFormationMultiModel:getNPCsByTy(self.tag-1)
            else
                self.npcsData = TeamFormationModel:getNPCsByTy(self.tag-1)
            end    
    elseif self.systemId == FuncTeamFormation.formation.wonderLand then
        self.npcsData = TeamFormationModel:getWonderLandNpcs(self.tag-1, nil, self.systemId)
    elseif self.systemId == FuncTeamFormation.formation.crossPeak then
        self.npcsData = TeamFormationModel:getCrossPeakNpcs(self.tag-1, nil)
    else
        self.npcsData = TeamFormationModel:getNPCsByTy(self.tag-1)
        if self.pvpBuffId then
            local pvpBuffData = FuncPvp.getBuffDataByBuffId(self.pvpBuffId)
            local pvpBuffTags = FuncPvp.getBuffTagsByBuffData(pvpBuffData)
            local pvpBuffPartners = FuncPvp.getBuffPartnersByBuffData(pvpBuffData)
            for i,v in ipairs(self.npcsData) do
                v.isPvpAddition = nil
                if tostring(v.id) ~= "1" then
                    if table.indexof(pvpBuffPartners, tonumber(v.id)) then
                        v.isPvpAddition = 1
                    else
                        local npcCfg = FuncPartner.getPartnerById(v.id)
                        local partner_tag = npcCfg.tag
                        for ii,vv in ipairs(pvpBuffTags) do
                            if partner_tag and tostring(partner_tag[tonumber(vv.key)]) == tostring(vv.value) then
                                v.isPvpAddition = 1
                                break
                            end
                        end
                    end
                end
            end
        end
        -- dump(self.npcsData, "\n\nself.npcsData====")
    end
end

function WuXingTeamEmbattleView:initView()
    self.mc_1:zorder(-1)
    self.mc_2:zorder(-1)
    self.scale9_1:zorder(-2)
    self.mc_jsuese1:setVisible(false)
    self.panel_wuling:visible(false)
    self:inintShowView()
    
    self:initBarItem(self.tag)
    --设定布阵按钮类型
    self:setChooseBtnView()
     --创建伙伴view
    self:initTeamView()
     --创建底部进度条
    -- self:initScrollPartener()
    --创建阵位类型
    self:setPartenerOrWuxing(FuncTeamFormation.btnChange.partner)
    --设定按钮
    self:initTypeView()
    --五行展示
    self:initWuXingTips()
    --法宝按钮移至底部
    -- self:initTreaView()
    if self.raidId or self.isPvpAttack or self.isMissionPvp then
        self.btn_chakandiqing:setVisible(true)
        self.btn_chakandiqing:setTouchedFunc(c_func(self.goToShowEnemys, self))
    else
        self.btn_chakandiqing:setVisible(false)
    end

    self.topItems = {self.btn_back, self.mc_title}
    self.bottomItems = {self.scroll_1, self.mc_1, self.mc_2, self.mc_zhankai, 
            self.scale9_1, self.mc_type, self.panel_xian}
end

function WuXingTeamEmbattleView:goToShowEnemys()
    self:disabledUIClick()
    local resumeFunc = function ()
        self:resumeUIClick()
        self.enemyDisplayView:moveBackItemsView(true)
    end

    self.moveOffsetX = 300
    self.moveOffsetY = 300
    local setVisibleFunc = function (_view, isVisible)
        _view:setVisible(isVisible)
    end

    local curPartnerView = self.partnerView
    local needMoveBg = true
    if self.curFormationWave == FuncEndless.waveNum.SECOND then
        curPartnerView = self.partnerView2
        needMoveBg = false
    end
    local moveFunc = function ()
        self.enemyDisplayView:setElementVisible(false)
        self.pubView:moveItemsView(self.moveOffsetX, self.moveOffsetY, false)
        
        for i,v in ipairs(self.topItems) do
            v:runAction(act.sequence(act.moveby(0.3, 0, self.moveOffsetY), act.callfunc(c_func(setVisibleFunc, v, false))))
        end

        for i,v in ipairs(self.bottomItems) do
            v:runAction(act.sequence(act.moveby(0.3, 0, -self.moveOffsetY), act.callfunc(c_func(setVisibleFunc, v, false))))
        end
    end

    local moveBgAndPartnerView = function ()
        curPartnerView:runAction(act.moveby(0.5, GameVars.maxScreenWidth, 0))
        if needMoveBg then
            self.__bgView:runAction(act.moveby(0.5, GameVars.maxScreenWidth, 0))
        end
        
        self.enemyDisplayView:runAction(act.moveby(0.5, GameVars.maxScreenWidth, 0))
    end

    if self.enemyDisplayView then
        self.enemyDisplayView:setVisible(true)
        self.btn_chakandiqing:setVisible(false)
        self:runAction(act.sequence(act.callfunc(moveFunc), act.delaytime(0.2), act.callfunc(moveBgAndPartnerView), act.delaytime(0.5), act.callfunc(resumeFunc), nil))     
    else
        if self.raidId then
            self.enemyDisplayView = WindowsTools:createWindow("WuXingLookOverView", self.raidId, self.secondRaidId)
            self.enemyDisplayView:addto(self.ctn_x4)
        elseif self.isPvpAttack or self.isMissionPvp then
            self.enemyDisplayView = WindowsTools:createWindow("WuXingLookOverView", nil, nil, self.params)
            self.enemyDisplayView:addto(self.ctn_x4)
        end
        self.btn_chakandiqing:setVisible(false)      
        self.enemyDisplayView:setPositionX(-GameVars.maxScreenWidth)
     
        self:runAction(act.sequence(act.callfunc(moveFunc), act.delaytime(0.2), act.callfunc(moveBgAndPartnerView), act.delaytime(0.5), act.callfunc(resumeFunc), nil))   
    end     
end



function WuXingTeamEmbattleView:hideLookOverView()
    self:disabledUIClick()
    local setVisibleFunc = function (_view, isVisible)
        _view:setVisible(isVisible)
    end

    local curPartnerView = self.partnerView
    local needMoveBg = true
    if self.curFormationWave == FuncEndless.waveNum.SECOND then
        curPartnerView = self.partnerView2
        needMoveBg = false
    end

    if self.enemyDisplayView then
        local hideFunc = function ()
            -- self.enemyDisplayView:setVisible(false)
            self:resumeUIClick()
            -- self.pubView:setVisible(true)
            self:delayCall(function ()
                    self.btn_chakandiqing:setVisible(true)
                end, 0.2)
            
            self.pubView:moveBackItemsView(self.moveOffsetX, self.moveOffsetY, true)

            for i,v in ipairs(self.topItems) do
                v:runAction(act.sequence(act.callfunc(c_func(setVisibleFunc, v, true)), act.moveby(0.2, 0, -self.moveOffsetY)))
            end

            for i,v in ipairs(self.bottomItems) do
                v:runAction(act.sequence(act.callfunc(c_func(setVisibleFunc, v, true)), act.moveby(0.2, 0, self.moveOffsetY)))
            end
        end

        local moveOutFunc = function ()
            self.enemyDisplayView:moveOutItemsView(false)
        end

        local moveBackBgAndPartnerView = function ()
            curPartnerView:runAction(act.moveby(0.5, -GameVars.maxScreenWidth, 0))
            if needMoveBg then
                self.__bgView:runAction(act.moveby(0.5, -GameVars.maxScreenWidth, 0))
            end            
            self.enemyDisplayView:runAction(act.moveby(0.5, -GameVars.maxScreenWidth, 0))
        end
        self.enemyDisplayView:runAction(act.sequence(act.callfunc(moveOutFunc), act.delaytime(0.2), act.callfunc(moveBackBgAndPartnerView), act.delaytime(0.5), act.callfunc(hideFunc)))
    end 
end

function WuXingTeamEmbattleView:initViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_title, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_chakandiqing, UIAlignTypes.Left)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_xian, UIAlignTypes.MiddleBottom)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_1, UIAlignTypes.MiddleBottom, 1, 0)
    FuncCommUI.setScrollAlign(self.widthScreenOffset,self.scroll_1, UIAlignTypes.MiddleBottom, 1, 0)
    -- FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_qie, UIAlignTypes.MiddleBottom)
    -- FuncCommUI.setScale9Align(self.widthScreenOffset,self.mc_btn, UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_zhankai, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_type, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_1, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_2, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_wulingxiangqing, UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_xian, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_4, UIAlignTypes.LeftBottom)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_hua, UIAlignTypes.MiddleBottom)
end

--新需求 将法宝移到了下方奇侠板左侧
function WuXingTeamEmbattleView:initTreaView()
    -- if self.systemId ~= FuncTeamFormation.formation.trailPve3 then
    --     -- self.panel_fb10.btn_1:setTouchedFunc(c_func(self.showTreaList,self),nil,true)
    --     self.panel_fb10:setTouchedFunc(c_func(self.showTreaList,self))
    --     self:updateFormationTreas()
    -- else
    --     self.panel_fb10:visible(false)
    -- end

    -- if FuncCommon.isSystemOpen("treasure") then 
    --     self.panel_fb10.btn_1:visible(true)
    -- else
    --     self.panel_fb10.btn_1:visible(false)
    -- end
    self.scroll_1:refreshCellView(1)   
end

function WuXingTeamEmbattleView:updateFormationTreas(_view)
    for k= 1,1 do
        local curTrea = nil
        if self.isMuilt then
            curTrea = TeamFormationMultiModel:getCurTreaByIdx(1)
        else
            curTrea = TeamFormationModel:getCurTreaByIdx(1)
            -- if tonumber(self.systemId) == FuncTeamFormation.formation.pve_tower then
            --     local banTreasures = TowerMainModel:getBanTreasure()
            --     if curTrea ~= nil and tostring(curTrea) ~= "0" then
            --         for k,v in pairs(banTreasures) do
            --             if tostring(k) == tostring(curTrea) then
            --                 local allTreas = TeamFormationModel:getAllTreas()
            --                 local tempTrea 
            --                 for i,v in ipairs(allTreas) do
            --                     if tostring(v.id) ~= tostring(curTrea) then
            --                         tempTrea = v.id
            --                         break
            --                     end
            --                 end
            --                 TeamFormationModel:updateTrea(1, tempTrea)
            --             end
            --         end
            --     end
            -- end 
            -- curTrea = TeamFormationModel:getCurTreaByIdx(1)
        end 

          
        if  curTrea ~= nil and tostring(curTrea) ~= "0"  then
            local treaData = nil
            local icon = nil
            if not self.isMuilt then
                treaData = TeamFormationModel:getTreaById( curTrea )
                icon = FuncRes.iconTreasureNew( curTrea )
            else
                treaData = curTrea
                icon = FuncRes.iconTreasureNew( curTrea.id )
            end    
            local mc = _view["mc_fbzt"..2]
            mc:showFrame(1)
            
            mc.currentView.panel_fbzt2.panel_tuijian:visible(false)
            --对号
            -- mc.currentView.panel_fbzt2.panel_duihao:visible(false)
            mc.currentView.panel_fbzt2.txt_1:setVisible(false)
            --仙界对决时需要显示段位对应的星级
            if tonumber(self.systemId) == tonumber(FuncTeamFormation.formation.crossPeak) then
                local currentSegment = CrossPeakModel:getCurrentSegment()
                local currentSegmentData = FuncCrosspeak.getSegmentDataById(currentSegment)
                mc.currentView.panel_fbzt2.mc_1:showFrame(currentSegmentData.starTreasure)
            else
                mc.currentView.panel_fbzt2.mc_1:showFrame(treaData.star)
            end    

            local tsp = FuncTreasureNew.getTreasLihui(curTrea)
            tsp:setScale(0.4)
            mc.currentView.panel_fbzt2.ctn_goodsicon:removeAllChildren()
            tsp:addto(mc.currentView.panel_fbzt2.ctn_goodsicon)

        else
            _view["mc_fbzt"..2]:showFrame(2)
        end
    end
end


function WuXingTeamEmbattleView:showTreaData()
    TeamFormationModel:getTreasurePosNature()
    local params = {}
    local tempPosX,tempPosY = self.panel_fb10:getPosition()
    params.x = tempPosX + 300
    params.y = tempPosY + 300
    -- WindowControler:showWindow("WuXingAllTreasureView",params)

    WindowControler:showWindow("WuXingTreasureInfoView", self.isMuilt, self.systemId, FuncTeamFormation.showTreasure.attr)
end

function WuXingTeamEmbattleView:showTreaList()
    if TutorialManager.getInstance():isOutFormation() or TutorialManager.getInstance():isTrialFormation() then
        -- return
    end

    if self.isInPartnerDetailStatus then
        EventControler:dispatchEvent(TeamFormationEvent.CLOSE_PARTNER_DETAILVIEW)
    end
    
    TeamFormationModel:getTreasurePosNature()
    -- WindowControler:showWindow("WuXingTreasureView", self.isMuilt, self.systemId)
    WindowControler:showWindow("WuXingTreasureInfoView", self.isMuilt, self.systemId, self, self.curFormationWave)
end

function WuXingTeamEmbattleView:updateUI()
    
end

function WuXingTeamEmbattleView:doOKClick()
    if TutorialManager.getInstance():isOutFormation() then
        return 
    end

    if self.systemId == FuncTeamFormation.formation.crossPeak then
        TeamFormationModel:setCandidatePanelStatus(false)
        TeamFormationModel:setCloseCandidatePanel(false)
        if TeamFormationModel:isCharInFormationOrCandidate() == false then
            WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2008"))
            return
        end
    end

    if self.systemId == FuncTeamFormation.formation.pve 
        or self.systemId == FuncTeamFormation.formation.pvp_defend 
        or self.systemId == FuncTeamFormation.formation.crossPeak then
        local params = {}
        params.id = self.systemId
        params.formation = TeamFormationModel:getTempFormation()
        if self.systemId == FuncTeamFormation.formation.pvp_defend then
            local energy = FuncTeamFormation.filterPvpFormation(params.formation)
            params.formation.energy = energy
        end
        TeamFormationServer:doFormation(params,c_func(self.closeNowView,self))
    else
        self:saveLocalTeamData()
        self:startHide()
    end       
end


function WuXingTeamEmbattleView:saveLocalTeamData()
    TeamFormationModel:saveLocalData(self.systemId)
    -- if self.systemId == FuncTeamFormation.formation.pve and not LS:prv():get(UserModel:rid().."isSettedFormation") then
    --     LS:prv():set(UserModel:rid().."isSettedFormation", true)
    -- end
    if self.systemId ~= FuncTeamFormation.formation.endless then
        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_009"))
    end
    
    EventControler:dispatchEvent(TeamFormationEvent.TEAMFORMATIONEVENT_CHANGE_TEAMFORMATION)

    if self.systemId == FuncTeamFormation.formation.pvp_attack then
        EventControler:dispatchEvent(TeamFormationEvent.PVP_ATTACK_CHANGED)
    end

    -- local hasIdlePosition = TeamFormationModel:hasIdlePosition()
    -- local isWuLingType = WuLingModel:checkRedPoint()
    -- local tempType = false
    -- if hasIdlePosition then
    --     tempType = true
    -- end
    -- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,{redPointType = HomeModel.REDPOINT.DOWNBTN.ARRAY, isShow = tempType})
end

function WuXingTeamEmbattleView:closeNowView()
    self:saveLocalTeamData()
    if self.systemId == FuncTeamFormation.formation.pvp_defend then
        EventControler:dispatchEvent(TeamFormationEvent.PVP_DEFENCE_CHANGED)
    elseif self.systemId == FuncTeamFormation.formation.crossPeak then
        TeamFormationModel:setCurrentCrossPeakPlayMode(nil)
    elseif self.systemId == FuncTeamFormation.formation.endless then
        TeamFormationModel:setCurFormationWave()
    end
    TeamFormationModel:setMultiState(false, false)
    self:startHide()
end


function WuXingTeamEmbattleView:doBackClick(params)
    if TutorialManager.getInstance():isTrialFormation() then
        -- return
    end
    if self.isMuilt then
        local params = {}
        params.battleId = TeamFormationMultiModel:getRoomId()
        TeamFormationServer:doLevelRoom(params,c_func(self.doLevelRoomCallBack,self))
    else
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            local onlyHideView = nil
            if params and params.params then
                onlyHideView = params.params.onlyHideView
            end

            self:exitMulityBattle(onlyHideView)
        else
            self:startHide()
        end
    end   
end
function WuXingTeamEmbattleView:exitMulityBattle(onlyHideView)
    if not onlyHideView then
        --关闭realtimeserveri
        ServerRealTime:handleClose() 
        -- 关闭多人语音
        ChatShareControler:quitRealTimeRoom(GuildBossModel:getGuildBossBattleId())
    end
    
    -- 关掉窗口
    self:startHide()
end

function WuXingTeamEmbattleView:notifyCloseServerRealTime(event)
    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        if event.params.params.type == TeamFormationServer.hType_finishBattle then
            self:exitMulityBattle()
        end
    end
end

function WuXingTeamEmbattleView:doLevelRoomCallBack()
    TrailModel:setispipeizhong(false)
    TrailModel:setPiPeiPlayer(nil)
    self:startHide()
end

function WuXingTeamEmbattleView:setFilterOpen( isOpen )
    if TutorialManager.getInstance():isOutFormation() or TutorialManager.getInstance():isTrialFormation() then
        self.mc_4:visible(false)
        self.ctn_bgbg2:visible(false)
        return
    end
    if not isOpen then
        --伙伴过滤关闭，注册事件跳转到相应的帧就可以
        self.mc_zhankai:showFrame(1)
        self.mc_zhankai.currentView.btn_1:setTap(c_func(self.setFilterOpen,self,true))
        if self.ctn_bgbg2 and self.ctn_bgbg2.coverLayer then
            self.ctn_bgbg2.coverLayer:clear()
            self.ctn_bgbg2.coverLayer = nil
        end
        if self.isFilterOpen then
            self.mc_4:runAction(act.scaleto(0.2, 0, 0))
            self:delayCall(function ()
                    self.mc_4:visible(false)
                    self.ctn_bgbg2:visible(false)
                end, 0.2)
        else
            self.mc_4:visible(false)
            self.ctn_bgbg2:visible(false)
        end
        
        self.mc_4.currentView.mc_1.currentView.btn_1:setTap(GameVars.emptyFunc)
        self.mc_4.currentView.mc_2.currentView.btn_1:setTap(GameVars.emptyFunc)
        self.mc_4.currentView.mc_3.currentView.btn_1:setTap(GameVars.emptyFunc)
        self.mc_4.currentView.mc_4.currentView.btn_1:setTap(GameVars.emptyFunc)
    else

        local btnClick = function (tag)
            if TutorialManager.getInstance():isOutFormation() or TutorialManager.getInstance():isTrialFormation() then
                return
            end
           self:doBarItemClick(tag)
           self.mc_type:showFrame(tag)
           self:setFilterOpen(false)
        end

        --伙伴过滤打开，显示相应的帧数
        self.mc_zhankai:showFrame(2)
        self.mc_zhankai.currentView.btn_1:setTap(c_func(self.setFilterOpen,self,false))
        self.mc_4:setScale(0)
        self.mc_4:visible(true)
        self.ctn_bgbg2:setVisible(true)
        self.mc_4:runAction(act.scaleto(0.2, 1, 1))
        self.isFilterOpen = true
        if self.ctn_bgbg2.coverLayer == nil then
            local coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self.ctn_bgbg2, 0)
            coverLayer:pos(-GameVars.width/2, GameVars.height/2)
            -- 注册点击任意地方事件
            --0.5秒后才可以点击胜利界面关闭
            coverLayer:setTouchedFunc(c_func(self.setFilterOpen, self,false),nil,true)
            self.ctn_bgbg2.coverLayer  = coverLayer
        end
        self.mc_4.currentView.mc_1.currentView.btn_1:setTap(c_func(btnClick, FuncTeamFormation.tagType.all))
        self.mc_4.currentView.mc_2.currentView.btn_1:setTap(c_func(btnClick, FuncTeamFormation.tagType.attack))
        self.mc_4.currentView.mc_3.currentView.btn_1:setTap(c_func(btnClick, FuncTeamFormation.tagType.defend))
        self.mc_4.currentView.mc_4.currentView.btn_1:setTap(c_func(btnClick, FuncTeamFormation.tagType.assist))
    end
end

--[[
左侧的bar选择
todo dev 这里应该还有条件判断   某些条件下一些tag是不可见的
tag == 1 所有   
tag == 2 攻击   
tag == 3 防御  
tag == 4 辅助   
]]
function WuXingTeamEmbattleView:initBarItem( tag )
    self.tag = tag
end


--[[
点击barItem
]]
function WuXingTeamEmbattleView:doBarItemClick( tag )
    --echo("tag",tag,"=======")
    if tag == self.tag then
        return
    end
    self:initBarItem(tag)
    --初始化数据
    self:initData()
    --初始化滑动条
    self:initScrollPartener()
end

function WuXingTeamEmbattleView:initScrollPartener()
    local heroData = self.npcsData
    local widthGap = 5
    local offsetX = 2
    
    local heroData1 = {}
    local heroData2 = {}
    local heroData3 = {} 
    local charIndex = 0
    for i,v in ipairs(heroData) do
        if tonumber(v.id) == 1 then
            charIndex = i
            break
        end
    end

    if charIndex == 0 then
        heroData1 = heroData
    elseif charIndex == 1 then
        heroData2 = {heroData[1]}
        for i = 2, #heroData, 1 do
            table.insert(heroData3, heroData[i])
        end
    else
        heroData2 = {heroData[charIndex]}  
        for i = charIndex + 1, #heroData, 1 do
            table.insert(heroData3, heroData[i])
        end 

        for i = 1, charIndex - 1, 1 do
            table.insert(heroData1, heroData[i])
        end
    end

    -- self.mc_hyk.currentView.panel_goods:visible(false)
    local createCellFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.mc_jsuese1);
        self:updatePartnerItem(view, itemData)
        return view
    end

    local updateCellFunc = function (itemData, view)
        self:updatePartnerItem(view, itemData)
    end

    --因为试炼窟盗宝者类型不显示法宝
    local offsetX = 0
    -- if self.systemId == FuncTeamFormation.formation.trailPve3 then
    --     offsetX = -170
    -- end

    local scrollParams = {
        {
            data = heroData1,
            createFunc = createCellFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 5,
            widthGap = 5,
            updateCellFunc = updateCellFunc,
            heightGap = 0,
            itemRect = {x = 0, y = -180, width = 120, height = 180},
            perFrame = 1,
            cellWithGroup = 1,
        },
        {
            data = heroData2,
            createFunc = createCellFunc,
            perNums = 1,
            offsetX = 20,
            offsetY = 5,
            widthGap = 0,
            updateCellFunc = updateCellFunc,
            heightGap = 0,
            itemRect = {x = 0, y = -180, width = 280, height = 180},
            perFrame = 1,
        },
        {
            data = heroData3,
            createFunc = createCellFunc,
            perNums = 1,
            offsetX = 20 + offsetX,
            offsetY = 5,
            widthGap = 5,
            updateCellFunc = updateCellFunc,
            heightGap = 0,
            itemRect = {x = 0, y = -180, width = 120, height = 180},
            perFrame = 1,
            cellWithGroup = 1,
        }      
    }

    self.scroll_1:setPositionX(90 - GameVars.UIOffsetX+ GameVars.toolBarWidth )
    self.scroll_1:cancleCacheView()
    self.scroll_1:styleFill(scrollParams)
    self.scroll_1:hideDragBar()
    self.scroll_1:setCanScroll(true)
    self.scroll_1:setRectTouchedOffset({offsetX = 0, offsetY = 50})
    self.panel_wulingxiangqing:setVisible(false)
    self.mc_type:setVisible(true)
end

function WuXingTeamEmbattleView:initScrollWuXing()
    local heroData = FuncTeamFormation.getWuXingData()
    local widthGap = -20
    local offsetX = 0
    
    local createCellFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_wuling)
        self:updateWuXingItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateWuXingItem(view, itemData)
    end

    local scrollParams = {
        {
            data = heroData,
            createFunc = createCellFunc,
            perNums = 1,
            offsetX = offsetX,
            offsetY = 0,
            widthGap = widthGap,
            updateCellFunc = updateCellFunc,
            heightGap = 0,
            itemRect = {x = 0, y = -183, width = 135, height = 183},
            perFrame = 1,
        }
        
    }

    self.scroll_1:setPositionX(30 - GameVars.UIOffsetX+GameVars.toolBarWidth )
    self.scroll_1:cancleCacheView()
    self.scroll_1:styleFill(scrollParams)  
    self.scroll_1:hideDragBar()
    self.scroll_1:setCanScroll(false)
    self.panel_wulingxiangqing:setVisible(false)
    self.mc_type:setVisible(false)
end

function WuXingTeamEmbattleView:updatePartnerItem(_view, itemData)
    local partnerId = itemData.id

    _view.data = itemData
    if tonumber(partnerId) == 1 then             
        -- if self.systemId ~= FuncTeamFormation.formation.trailPve3 then
            _view:showFrame(2)
            local panel_fb = _view.currentView.panel_fb10
            panel_fb:setTouchedFunc(c_func(self.showTreaList, self))
            self:updateFormationTreas(panel_fb)
        -- else
        --     _view:showFrame(1)
        -- end
    else
        _view:showFrame(1)
    end

    local tempView = _view.currentView.panel_goods
    tempView.data = itemData 
    tempView.panel_xuanzhong:setVisible(false)
    tempView.panel_tanhao:setVisible(false)
    tempView.panel_yishangzhen:setVisible(false)
    tempView.panel_tiao:setVisible(false)
    local function updataGray()
        FilterTools.setGrayFilter(tempView.UI_1)
    end

    FilterTools.clearFilter(tempView.UI_1)  
    if self.systemId == FuncTeamFormation.formation.pve_tower or 
        self.systemId == FuncTeamFormation.formation.guildExplorePve then

        if tonumber(itemData.HpPercent) == 0 then
            tempView.panel_yishangzhen:setVisible(true)
            tempView.panel_yishangzhen.mc_zt:showFrame(2)
        else
            if TeamFormationSupplyModel:isPartnerBan(partnerId, self.systemId) then
                tempView.panel_yishangzhen:setVisible(true)
                tempView.panel_yishangzhen.mc_zt:showFrame(4)
            else
                tempView.panel_tiao:setVisible(true)          --存在已上阵等等
                tempView.panel_tiao.progress_1:setPercent(itemData.HpPercent/100)
            end          
        end
    end
    -- tempView.txt_1:setString(itemData.level)
    local isInFormation = false

    if self.isMuilt then
        isInFormation = TeamFormationMultiModel:chkIsInFormation(partnerId)
    else
        if (self.systemId == FuncTeamFormation.formation.pve_tower or self.systemId == FuncTeamFormation.formation.guildExplorePve) 
            and tonumber(itemData.HpPercent) == 0 then
            isInFormation = false
        else    
            isInFormation = TeamFormationModel:chkIsInFormation(partnerId)
        end
    end

    if self.systemId == FuncTeamFormation.formation.crossPeak then
        if TeamFormationModel:chkIsInCandidate(partnerId) then
            tempView.panel_yishangzhen:setVisible(true)
            tempView.panel_yishangzhen.mc_zt:showFrame(3)
        elseif TeamFormationModel:chkIsInFormation(partnerId) then
            tempView.panel_yishangzhen:setVisible(true)
            tempView.panel_yishangzhen.mc_zt:showFrame(1)
        end
        tempView.mc_pai:setVisible(false)
    elseif self.systemId == FuncTeamFormation.formation.pvp_defend
        or self.systemId == FuncTeamFormation.formation.pvp_attack then
        
        tempView.mc_pai:visible(false)
        if isInFormation then                
            tempView.panel_yishangzhen:setVisible(true)
            tempView.panel_yishangzhen.mc_zt:showFrame(1)               
        elseif itemData.recommend then
            tempView.mc_pai:visible(true)
            tempView.mc_pai:showFrame(2)
        elseif itemData.isPvpAddition then
            tempView.mc_pai:visible(true)
            tempView.mc_pai:showFrame(4)
        end
    elseif self.systemId == FuncTeamFormation.formation.endless then
        tempView.mc_pai:visible(false)
        local inFormation, formationWave = TeamFormationModel:chkIsInWhichFormationWave(partnerId)
        if inFormation then
            tempView.panel_yishangzhen:setVisible(true)
            if formationWave == FuncEndless.waveNum.FIRST then
                tempView.panel_yishangzhen.mc_zt:showFrame(5)
            else
                tempView.panel_yishangzhen.mc_zt:showFrame(6)
            end
        end
    else
        tempView.mc_pai:visible(false)
        if isInFormation then            
            tempView.panel_yishangzhen:setVisible(true)
            tempView.panel_yishangzhen.mc_zt:showFrame(1)
        elseif itemData.recommend then
            tempView.mc_pai:visible(true)
            tempView.mc_pai:showFrame(2)
        end            
    end
    
    
    if itemData.teamFlag and itemData.teamFlag == 1 then
        tempView.UI_1:updataUI(itemData.id, nil, true)
        tempView.mc_gfj:visible(false)
        tempView.ctn_tu2:visible(false)
        tempView.panel_d:visible(false) 
    elseif FuncWonderland.isWonderLandNpc(partnerId) then
        tempView.UI_1:updataUI(partnerId, nil, true)
        tempView.mc_gfj:setVisible(false)
        tempView.ctn_tu2:setVisible(false)
        tempView.panel_d:visible(false)
    else
        tempView.mc_gfj:visible(true)
        
        if tonumber(partnerId) == 1 then
            partnerId = UserModel:avatar()
            local garmentId = GarmentModel:getOnGarmentId()
            tempView.UI_1:updataUI(partnerId,garmentId,nil,self.systemId)
        else    
            local skin = ""
            local partnerData = PartnerModel:getPartnerDataById(partnerId)
            if partnerData then
                skin = partnerData.skin
            end
            tempView.UI_1:updataUI(partnerId,skin,nil,self.systemId)
        end
        tempView.ctn_tu2:removeAllChildren()
        local itemType = FuncPartner.getPartnerById(partnerId).type
        --这里会导致滚动条加载特别卡顿
        -- local itemType = TeamFormationModel:getPropByPartnerId(itemData.id)
        local nowElement = itemData.elements

        if tostring(itemData.id) == "1" then
            local curTreaData = nil
            local tempTreasure = nil
            if self.isMuilt then
                curTreaData = TeamFormationMultiModel:getCurTreaByIdx(1)
                tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaData.id)
            else
                curTreaData = TeamFormationModel:getCurTreaByIdx(1)  
                tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaData)
            end    
            nowElement = tempTreasure.wuling
            tempView.mc_gfj:showFrame(tempTreasure.type)
        else
           tempView.mc_gfj:showFrame(itemType)
        end
        local wuxingData = FuncTeamFormation.getWuXingDataById(nowElement)
        local wuxingIcon = FuncRes.iconWuXing(wuxingData.icon)
        local sp = display.newSprite(wuxingIcon):addto(tempView.ctn_tu2)
        sp:setScale(0.3)  

        if FuncCommon.isSystemOpen("fivesoul") then 
            tempView.ctn_tu2:visible(true)
            tempView.panel_d:visible(true)
        else
            tempView.ctn_tu2:visible(false)
            tempView.panel_d:visible(false)
        end
    end

    if self.isInPartnerDetailStatus then
        tempView.panel_tanhao:setVisible(false)
        if self.lastSelectedPartnerData and self.lastSelectedPartnerData == tempView.data then
            tempView.panel_xuanzhong:setVisible(true)
        else
            tempView.panel_xuanzhong:setVisible(false)
        end
    else
        tempView.panel_xuanzhong:setVisible(false)
        if self.lastSelectedPartnerData and self.lastSelectedPartnerData == tempView.data then
            tempView.panel_tanhao:setVisible(true)
        else
            tempView.panel_tanhao:setVisible(false)
        end
    end
    
    if self.systemId == FuncTeamFormation.formation.crossPeak then
        tempView.panel_tanhao:setVisible(false)
    end

    tempView:setTouchedFunc(
        c_func(self.doItemClick,self, tempView),
        nil,
        true, 
        c_func(self.doItemBegan, self, tempView), 
        c_func(self.doItemMove, self, tempView),
        false,
        c_func(self.doItemEnded, self, tempView)
    ) 

    tempView.panel_tanhao:setTouchedFunc(c_func(self.showPartnerDetailView, self, tempView))     
end

function WuXingTeamEmbattleView:updateWuXingItem(view, itemData) 
    local wuxingNum =  0
    local tempWuXing = 0

    view.panel_tanhao:setVisible(false)
    view.panel_xuanzhong:setVisible(false)
    if self.isMuilt then
        wuxingNum = FuncTeamFormation.getMultiWuXingNum(itemData.id, UserModel:level())
    else
        -- echoError("itemData.id===", itemData.id)
        wuxingNum = FuncTeamFormation.getWuXingNum(itemData.id, UserModel:level())
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            wuxingNum = FuncTeamFormation.getMultiWuXingNum(itemData.id, UserModel:level())
        end
    end   
    --新需求 不显示拥有的数量     5.9  又要显示拥有数量了
    view.mc_xiafangtips:setVisible(false)
    if itemData.id == "0" then
        view.panel_heibao:visible(false)
        view.panel_yishangzhen:setVisible(false)
        view.panel_duigou:visible(false)
    else
        if self.isMuilt then 
            tempWuXing = TeamFormationMultiModel:getNowWuXingDataNum(itemData.id)
        else    
            tempWuXing = TeamFormationModel:getWuXingTempNum(itemData.id)
            if self.systemId == FuncTeamFormation.formation.guildBossGve then
                tempWuXing = TeamFormationModel:getWuXingMultiTempNum(itemData.id, UserModel:rid())
            end
        end   
        
        local haveOnNum = wuxingNum - tempWuXing
        if haveOnNum > 0 then
            view.panel_heibao.txt_2:setString(GameConfig.getLanguage("#tid_team_des_008")..haveOnNum)
            view.panel_heibao:setVisible(true)
            view.panel_duigou:visible(true)
        else
            view.panel_heibao.txt_2:setString("")
            view.panel_heibao:setVisible(false)
            view.panel_duigou:visible(false)
        end

        if haveOnNum >= wuxingNum then
            view.panel_yishangzhen:setVisible(true)
        else
            view.panel_yishangzhen:setVisible(false)
        end
    end 
    
    if self.isInWuXingDetailStatus then
        if self.lastSelectedWuXingData and self.lastSelectedWuXingData == view.data then
            view.panel_xuanzhong:setVisible(true)
        else
            view.panel_xuanzhong:setVisible(false)
        end
    else
        view.panel_xuanzhong:setVisible(false)
        if self.lastSelectedWuXingData and self.lastSelectedWuXingData == view.data then
            view.panel_tanhao:setVisible(true)
        else
            view.panel_tanhao:setVisible(false)
        end
    end

    local wuxingIcon = FuncRes.iconWuXing(itemData.icon)
    view.ctn_xxa:removeAllChildren()
    local sp = display.newSprite(wuxingIcon)
    view.ctn_xxa:addChild(sp)
    view.data = itemData
    view:setTouchedFunc(
        c_func(self.doWuXingClick, self, view),
        nil,
        true, 
        c_func(self.doWuXingBegan, self, view), 
        c_func(self.doWuXingMove, self, view),
        false,
        c_func(self.doWuXingEnded, self, view)
    )

    view.panel_tanhao:setTouchedFunc(c_func(self.showWuXingDetailInfo, self, view))
    -- if tonumber(tempWuXing) == 0 and itemData.id ~= "0" then
    --     FilterTools.setGrayFilter(view.currentView.ctn_xxa)
    -- end
    if itemData.id == "0" then
        FilterTools.setGrayFilter(view.ctn_xxa)
        view.txt_name:setVisible(false)
        view.txt_level:setVisible(false)
    else
        FilterTools.clearFilter(view.ctn_xxa)
        view.txt_name:setVisible(true)
        view.panel_level:setVisible(true)
        local wuxingData = FuncTeamFormation.getWuXingDataById(itemData.id)
        local level = WuLingModel:getWuLingLevelById(itemData.id)
        local name = GameConfig.getLanguage(wuxingData.name)
        view.txt_name:setString(name)
        view.panel_level.txt_level:setString(level)
    end
end

function WuXingTeamEmbattleView:setPartenerOrWuxing(type)
    self.nowChangeView = type
    self.partnerView:setWuXingOrPartner(self.nowChangeView)
    if self.partnerView2 then
        self.partnerView2:setWuXingOrPartner(self.nowChangeView)
    end
end

function WuXingTeamEmbattleView:deleteMe()
    WuXingTeamEmbattleView.super.deleteMe(self);
end

--  设置右下角按钮状态
function WuXingTeamEmbattleView:setChooseBtnView()
    -- self.mc_btn:showFrame(self.nowChangeView)
    -- 因为btn_1在mc的不同frame下都存在所以需要分开每一frame的btn都注册点击事件
    if self.nowChangeView == FuncTeamFormation.btnChange.partner then
        self.mc_1:showFrame(2)
        self.mc_2:showFrame(1)
        self.lastSelectedWuXingData = nil
        self:initScrollPartener()
        -- self.panel_qie.mc_wxzw1.currentView.btn_1:setTouchedFunc(c_func(self.changeWuXingScrollType,self))
        -- self.panel_qie.mc_wxzw2.currentView.btn_1:setTouchedFunc(c_func(self.changePartnerScrollType,self))
    else
        self.mc_1:showFrame(1)
        self.mc_2:showFrame(2)
        self.lastSelectedPartnerData = nil
        self:initScrollWuXing()
        -- self.panel_qie.mc_wxzw1.currentView.btn_1:setTouchedFunc(c_func(self.changeWuXingScrollType,self))
        -- self.panel_qie.mc_wxzw2.currentView.btn_1:setTouchedFunc(c_func(self.changePartnerScrollType,self))
    end

    self.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.changeScrollType, self, FuncTeamFormation.btnChange.partner)) 
    self.mc_2.currentView.btn_1:setTouchedFunc(c_func(self.changeScrollType, self, FuncTeamFormation.btnChange.wuxing)) 

    -- if not self.isMuilt then
    --     local teampWuXing,teampLevel = FuncTeamFormation.checkWuXingPosOpen(UserModel:level())
    --     if not FuncCommon.isSystemOpen("fivesoul") then
    --         if self.mc_btn.currentView.panel_suo then
    --             self.mc_btn.currentView.panel_suo:visible(true)
    --             self.mc_btn.currentView.txt_1:visible(false)
    --         end    
    --         FilterTools.setGrayFilter(self.mc_btn.currentView.btn_wxzw)
    --         -- self.mc_btn.currentView.btn_wxzw:setTouchedFunc(c_func(self.showWuXingWarnTips,self))
    --     else   
    --         if self.mc_btn.currentView.panel_suo then
    --            self.mc_btn.currentView.panel_suo:visible(false)
    --            self.mc_btn.currentView.txt_1:visible(false)
    --         end    
    --         self.mc_btn.currentView.btn_wxzw:setTouchedFunc(c_func(self.changeScrollType,self))
    --     end
    -- else
    --     if self.mc_btn.currentView.panel_suo then
    --          self.mc_btn.currentView.panel_suo:visible(false)
    --          self.mc_btn.currentView.txt_1:visible(false)
    --     end    
    --      self.mc_btn.currentView.btn_wxzw:setTouchedFunc(c_func(self.changeScrollType,self))   
    -- end
end

function WuXingTeamEmbattleView:changeScrollType(_clickType)
    if _clickType == self.nowChangeView then
        return 
    else
        if _clickType == FuncTeamFormation.btnChange.partner then
            if TutorialManager.getInstance():isOutFormation() then
                return
            else
                self:setFilterOpen(false)
                self:setPartenerOrWuxing(FuncTeamFormation.btnChange.partner)
                self.mc_zhankai:showFrame(1)
                self:initEffectBtnView()
                self:setWuXingTitle()
                EventControler:dispatchEvent(TeamFormationEvent.CHANGED_TO_PARTNER)
            end            
        else
            if not self.isMuilt then
                if not FuncCommon.isSystemOpen("fivesoul") then
                    self:showWuXingWarnTips()
                    return 
                end
            end 
            
            EventControler:dispatchEvent(TeamFormationEvent.CHANGED_TO_WULING) 
            self:setPartenerOrWuxing(FuncTeamFormation.btnChange.wuxing)
            self.mc_zhankai:showFrame(3)
            self:initEffectBtnView()
            self:setWuXingTitle()
        end
        self.nowChangeView = _clickType
        self:setChooseBtnView()
    end   
end

function WuXingTeamEmbattleView:initTypeView()
    self:closeChooseTreaView()
    --这里要判定  显示那些选择项
    -- self.mc_1:showFrame(1)

    self:setFilterOpen(false)

end

function WuXingTeamEmbattleView:closeChooseTreaView()
    self.pIdx = nil
    self.ctn_bgbg:setVisible(false)
end

function WuXingTeamEmbattleView:showPartnerDetailView(view)
    if (view.data.teamFlag and view.data.teamFlag == 1) or 
        FuncWonderland.isWonderLandNpc(view.data.id) then 
        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_014"))
        return
    end

    if self.partnerDetailView then
        self.partnerDetailView:setVisible(true)
        self.partnerDetailView:setPartnerData(view.data.id, self.isMuilt)
        self.partnerDetailView:runAction(act.spawn(
                    act.fadein(0.2),
                    act.moveto(0.2, 0, 0)
                ))
    else
        self.partnerDetailView = WindowsTools:createWindow("WuXingPartnerDetailView", view.data.id, self.isMuilt)
        self.ctn_x3:addChild(self.partnerDetailView)
        self.partnerDetailView:pos(0, -600 - GameVars.UIOffsetY)
        self.partnerDetailView:opacity(0)
        self.ctn_x3:zorder(-1)
        self.partnerDetailView:runAction(act.spawn(
                    act.fadein(0.2),
                    act.moveto(0.2, 0, 0)
                ))
    end
    
    self.isInPartnerDetailStatus = true
    view.panel_tanhao:setVisible(false)
    view.panel_xuanzhong:setVisible(true)
end

function WuXingTeamEmbattleView:hidePartnerDetailView()
    if self.partnerDetailView then
        local endFunc = function ()
            self.partnerDetailView:setVisible(false)  
            self.isInPartnerDetailStatus = false
            if self.lastSelectedPartnerData then
                local _view = self.scroll_1:getViewByData(self.lastSelectedPartnerData)
                if _view then
                    _view.currentView.panel_goods.panel_xuanzhong:setVisible(false)     
                end
            end
            self.lastSelectedPartnerData = nil
        end

        self.partnerDetailView:runAction(act.sequence(act.spawn(
                    act.fadeout(0.2),
                    act.moveto(0.2, 0, -600 - GameVars.UIOffsetY)
                ), act.callfunc(endFunc)))
    end 
end

function WuXingTeamEmbattleView:doItemClick(view, event)
    if TutorialManager.getInstance():isOutFormation() or TutorialManager.getInstance():isTrialFormation() then
        return
    end
    if self.scroll_1:isMoving() then
        return
    end

    -- echo("\n\nself.isInPartnerDetailStatus====", self.isInPartnerDetailStatus)
    if self.isInPartnerDetailStatus then
        if self.lastSelectedPartnerData == view.data then
            return 
        else 
            if (view.data.teamFlag and view.data.teamFlag == 1) or 
                FuncWonderland.isWonderLandNpc(view.data.id) then 
                WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_014"))
                return
            end 

            if self.lastSelectedPartnerData then
                local _view = self.scroll_1:getViewByData(self.lastSelectedPartnerData)
                if _view then
                    _view.currentView.panel_goods.panel_xuanzhong:setVisible(false)     
                end
            end
            view.panel_xuanzhong:setVisible(true)
            self.partnerDetailView:setPartnerData(view.data.id, self.isMuilt)
            self.lastSelectedPartnerData = view.data
        end
    else
        if TeamFormationModel:getCandidatePanelStatus() then
            self:updateCandidatePartner(view)
            return 
        else
            -- WindowControler:showWindow("WuXingPartnerDetailView",view.data.id,self.isMuilt)
            local currentNum = TeamFormationModel:hasNowTeamNum()
            local isHasPos = TeamFormationModel:hasPosNum(self.systemId)
      
            if self.lastSelectedPartnerData and self.lastSelectedPartnerData == view.data then
            
            else
                if self.lastSelectedPartnerData then
                    local _view = self.scroll_1:getViewByData(self.lastSelectedPartnerData)
                    if _view then
                        _view.currentView.panel_goods.panel_tanhao:setVisible(false)
                    end
                end
                view.panel_tanhao:setVisible(true)
                if self.systemId == FuncTeamFormation.formation.crossPeak then
                    view.panel_tanhao:setVisible(false)
                end
                self.lastSelectedPartnerData = view.data
            end

            local partnerId = view.data.id
            if self.systemId == FuncTeamFormation.formation.crossPeak then
                if TeamFormationModel:chkIsInCandidate(partnerId) then
                    WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_016"))
                elseif TeamFormationModel:chkIsInFormation(partnerId) then
                    WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_015"))
                else
                    if isHasPos then
                        EventControler:dispatchEvent(TeamFormationEvent.TEAMFORMATIONEVENT_UP_PARTNER, {data = view.data})
                    else
                        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_022"))                      
                    end                             
                end
            else
                if self.systemId == FuncTeamFormation.formation.pve_tower or 
                    self.systemId == FuncTeamFormation.formation.guildExplorePve then

                    if TeamFormationSupplyModel:checkIsDead(partnerId, self.systemId) then
                        WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_128"))
                        return
                    end

                    if TeamFormationSupplyModel:isPartnerBan(partnerId, self.systemId) then
                        WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_129"))
                        return
                    end 
                end

                if self.systemId == FuncTeamFormation.formation.guildBossGve then
                    local isHostPrepared, isMatePrepared = TeamFormationModel:getMultiState()
                    echo("\n\nisMatePrepared==", isMatePrepared)
                    if not self.isHost and isMatePrepared then
                        return 
                    end
                end

                if TeamFormationModel:chkIsInFormation(partnerId) then
                    WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_034"))
                else
                    if isHasPos then
                        EventControler:dispatchEvent(TeamFormationEvent.TEAMFORMATIONEVENT_UP_PARTNER, {data = view.data})
                    else
                        if self.systemId == FuncTeamFormation.formation.guildBoss then
                            WindowControler:showTips(GameConfig.getLanguage("#tid_team_des_009"))
                        else
                            WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_022"))
                        end
                    end
                end
            end
        end
    end
    
end

function WuXingTeamEmbattleView:updateCandidatePartner(view)
    local partnerId = view.data.id
    local fightInStageMax = CrossPeakModel:getFightInStageMax()
    local fightNumMax = CrossPeakModel:getFightNumMax()
    local candidateNum = fightNumMax - fightInStageMax

    if TeamFormationModel:chkIsInFormation(partnerId) then 
        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_015"))
        return
    end

    if TeamFormationModel:chkIsInCandidate(partnerId) then
        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_016"))
        return 
    end

    if TeamFormationModel:chkCandidateIsFull(candidateNum, TeamFormationModel:getTempFormation()) then
        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_017"))
        return
    end

    TeamFormationModel:updateCandidatePartner(partnerId, candidateNum)
    EventControler:dispatchEvent(TeamFormationEvent.CANDIDATE_CHANGED)
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
end

function WuXingTeamEmbattleView:doItemBegan( view,event)
    self.canNotMove = false
    if self.isMuilt and TeamFormationMultiModel:getFormationLockState() == 1 then
        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_018"))
        self.canNotMove = true
        return
    end
    --新手引导准备
    if TutorialManager.getInstance():isOutFormation() and tonumber(view.data.id) ~= 5003 then
        self.canNotMove = true
        return
    end

    if TutorialManager.getInstance():isTrialFormation() then
        self.canNotMove = true
        return
    end

    if self.isInPartnerDetailStatus then
        return 
    end

    if self.systemId == FuncTeamFormation.formation.crossPeak and TeamFormationModel:getCandidatePanelStatus() then
        self.canNotMove = true
        return 
    end
    --1:判断是否已经上阵
    --2:判断是否已经死亡  根据条件 判断是否需要判断死亡
    if self.systemId == FuncTeamFormation.formation.pve_tower or 
        self.systemId == FuncTeamFormation.formation.guildExplorePve then

        if TeamFormationSupplyModel:checkIsDead(view.data.id, self.systemId) then
            self.canNotMove = true
            return 
        end

        if TeamFormationSupplyModel:isPartnerBan(view.data.id, self.systemId) then
            self.canNotMove = true
            return
        end 
    end  

    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        local isHostPrepared, isMatePrepared = TeamFormationModel:getMultiState()
        echo("\n\nisMatePrepared==", isMatePrepared)
        if not self.isHost and isMatePrepared then
            WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_007"))
            return 
        end
    end

    if FuncWonderland.isWonderLandNpc(view.data.id) then
        self.canNotMove = true
        return
    end
    --试炼部分类型区分
    -- local parentType = FuncPartner.getPartnerById(partnerId).type
    -- local parentType = TeamFormationModel:getPropByPartnerId(view.data.id)
    -- if self.systemId == FuncTeamFormation.formation.trailPve1 and parentType == 2 then
    --     return
    -- elseif self.systemId == FuncTeamFormation.formation.trailPve2 and parentType == 1 then
    --     return
    -- elseif self.systemId == FuncTeamFormation.formation.trailPve3 and parentType ~= 3 and parentType ~= 0 then
    --     return
    -- end

    local isInFormation = false
    local isInCandidate = false
    if self.isMuilt then
        isInFormation = TeamFormationMultiModel:chkIsInFormation(view.data.id)
    else
        isInFormation = TeamFormationModel:chkIsInFormation(view.data.id)
    end

    if self.systemId == FuncTeamFormation.formation.crossPeak then
        isInCandidate = TeamFormationModel:chkIsInCandidate(view.data.id)
    end
    if isInFormation or isInCandidate then
        self.canShangZhen = false
        return
    else
        self.canShangZhen = true
    end

    self.isShowSpine = false
    self.isItemClick = true
    --获取item所在的位置
    --转换成为世界坐标
    local xx,yy = view:getPosition()
    local globelPos = view:getParent():convertToWorldSpace(cc.p(xx+50,yy-40))
    -- local spine = FuncTeamFormation.getSpineNameByHeroId( tostring(view.data.id), true)
    -- local spineView = ViewSpine.new(spine,{},spine):addto(self.ctn_node):pos(0, -20)
    -- spineView:setScaleX(-1)
    -- spineView:playLabel("stand",true)
    -- local currentFrame = spineView:getCurrentFrame()
    -- spineView:gotoAndStop(currentFrame)
    -- self.ctn_node.view = spineView
    -- self.ctn_node.view:opacity(120)
    -- self.ctn_node.heroId = view.data.id

    local cntParent = self.ctn_node:parent()
    local locaNode = cntParent:convertToNodeSpace(globelPos)
    self.ctn_node:pos(locaNode.x,locaNode.y)

    xx,yy = self.ctn_node:getPosition()
    self.ctnSrcPos = {x = xx,y = yy}
    self.startItemPos = {x = event.x,y = event.y}
end

function WuXingTeamEmbattleView:doItemMove( view, event )   
    if self.canNotMove then
        return 
    end
    local beginItemPos = nil
    if self.nowChangeView == FuncTeamFormation.btnChange.partner then
        beginItemPos = self.startItemPos
    else
        beginItemPos = self.startWuXingPos
    end    
    if not beginItemPos  then
        return
    end
    if self.canShangZhen then
       
        local offsetX = event.x - beginItemPos.x
        local offsetY = event.y - beginItemPos.y
        if math.abs(offsetY) > 80 then
            self.isItemClick = false
            --创建 viewSpine 放入 ctn_node中
            if not self.isShowSpine then
                self.ctn_node:removeAllChildren()
                local isSelf = false
                if PartnerModel:isHavedPatnner(tostring(view.data.id)) then
                    isSelf = true
                end
                local spine, sourceId = FuncTeamFormation.getSpineNameByHeroId(tostring(view.data.id), isSelf)
                local sourceData = FuncTreasure.getSourceDataById(sourceId)
                local spineView = ViewSpine.new(spine,{},nil,spine,nil,sourceData):addto(self.ctn_node):pos(0, -20)
                spineView:setScaleX(-1)
                spineView:playLabel("stand",true)
                local currentFrame = spineView:getCurrentFrame()
                spineView:gotoAndStop(currentFrame)
                self.ctn_node.view = spineView
                self.ctn_node.view:opacity(120)
                self.ctn_node.heroId = view.data.id
                self.isShowSpine = true
            end
            
            self.ctn_node.view:visible(true)
            --echo("滚动条不能滚动")
            if not self.scroll_1:isSideShow() then
                self.scroll_1:setCanScroll(false)
            else
                local posx,posy = self.scroll_1.scrollNode:getPosition()
                if posx > 0 then
                    self.scroll_1:gotoTargetPos(1,1,0,true)
                else
                    self.scroll_1:gotoTargetPos(#self.npcsData,1,0,true)
                end
            end
            self.scrollMovingType = false 
        else
            if self.isShowSpine then
                self.ctn_node.view:visible(false)
            end           
            self.scrollMovingType = true
            self.isItemClick = true
            -- self.isShowSpine = false
        end
        self.ctn_node:pos(self.ctnSrcPos.x + offsetX, self.ctnSrcPos.y+ offsetY)

    end
 end   

function WuXingTeamEmbattleView:doItemEnded( view, event )
    
    if TutorialManager.getInstance():isOutFormation() and tonumber(view.data.id) ~= 5003 then
        return
    end
    if TutorialManager.getInstance():isTrialFormation() then
        return
    end

    self.scroll_1:setCanScroll(true)
    if self.scrollMovingType then
        return 
    end
    
    if self.isItemClick then
        return 
    end
    local tempType =true
    if self.canShangZhen then
        local x,y = event.x,event.y
        local targetMc
        local curPartnerView = self.partnerView
        local otherPartnerView = self.partnerView2
        local otherFormationWave = FuncEndless.waveNum.SECOND
        if self.curFormationWave and self.curFormationWave == FuncEndless.waveNum.SECOND then
            curPartnerView = self.partnerView2
            otherPartnerView = self.partnerView
            otherFormationWave = FuncEndless.waveNum.FIRST
        end

        local pIdx = curPartnerView:checkOneEffect(x,y)
        if pIdx then
            targetMc = curPartnerView["mc_tai"..pIdx]
        end

        if self.isMuilt and pIdx then
            local showTips = true
            local targetParam = TeamFormationMultiModel:getHeroByIdx(pIdx)
            if tostring(targetParam.element.rid ) ~= tostring(TeamFormationMultiModel.rid) and tostring(targetParam.element.rid) ~= "" then
                WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_019"))
                targetMc = nil
                pIdx = nil
                showTips = false
            end

            local hasPosNum = TeamFormationMultiModel:getMineNowPosNum()
            if hasPosNum >= 3 and tostring(targetParam.element.rid ) ~= tostring(TeamFormationMultiModel.rid) and showTips then
                WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_020"))
                targetMc = nil
                pIdx = nil
            end
        end

        if self.systemId == FuncTeamFormation.formation.crossPeak and targetMc and tostring(targetMc.heroId) == (FuncDataSetting.getDataByHid("CrossPeakCactusId")).str then
            WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2031")) 
            targetMc = nil
            pIdx = nil
        end

        if TutorialManager.getInstance():isOutFormation() and pIdx ~= 1 then 
            targetMc = nil
            pIdx = nil
        end

        if targetMc and targetMc.rid and tostring(targetMc.rid) ~= UserModel:rid() then
            targetMc = nil
            pIdx = nil
            WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_008"))
        end

        if targetMc then
            --找到了目标
            if tostring(targetMc.heroId) ~= "1" then
                if FuncWonderland.isWonderLandNpc(targetMc.heroId) then
                    tempType = false
                    pIdx = nil
                    WindowControler:showTips(GameConfig.getLanguage("#tid_wonderland_shangzhen_101"))
                else
                    local tempView = self.ctn_node.view
                    local tempHeroId = self.ctn_node.heroId
                    -- echo("tempHeroId",targetMc.heroId,"==================")

                    if targetMc.currentView.panel_1.ctn_player.view then
                        if self.isMuilt then

                        else
                            if self.systemId ~= FuncTeamFormation.formation.guildBossGve then
                                targetMc.currentView.panel_1.ctn_player.view:clear()
                            end      
                        end    
                    else
                        if self.isMuilt then

                        else
                            local isHasPos = TeamFormationModel:hasPosNum(self.systemId)

                            if not isHasPos then
                                self.canShangZhen = false
                                self.ctnSrcPos = nil
                                self.startItemPos = nil
                                self.ctn_node:removeAllChildren()
                                self.isShowSpine = false
                                self.scroll_1:refreshCellView(1)
                                if self.systemId == FuncTeamFormation.formation.guildBoss then
                                    WindowControler:showTips(GameConfig.getLanguage("#tid_team_des_009"))
                                else
                                    WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_022"))
                                end
                                return
                            end 
                        end    
                    end
                    
              
                    --更新玩家的站位信息
                    if self.isMuilt then
                        local params = {}
                        params.battleId = TeamFormationMultiModel:getRoomId()
                        params.posNum = pIdx
                        params.partnerId = targetMc.heroId
                        self:doOnPartnerAction(params)
                    else                       
                        if self.systemId == FuncTeamFormation.formation.guildBossGve then 
                            local curTreaId = nil                         
                            if tostring(tempHeroId) == "1" then
                                curTreaId = TeamFormationModel:getCurTreaByIdx(1)
                            end

                            local info = {
                                        pid = tostring(tempHeroId),
                                        rid = UserModel:rid(),
                                        pos = pIdx,
                                        tid = curTreaId,
                                    }
                            TeamFormationServer:sendPickUpOneHero(info)
                            tempType = false
                            self:setLoadingStatus(true)
                            self:disabledUIClick()
                            self:createLoadingAnim()
                        else
                            targetMc.heroId = tempHeroId

                            tempView:parent(targetMc.currentView.panel_1.ctn_player):pos(0,-50)
                            tempView:zorder(-1)
                            targetMc.currentView.panel_1.ctn_player.view = tempView

                            if FuncTower.isConfigEmployee(targetMc.heroId) then
                                targetMc.teamFlag = 1
                            else
                                targetMc.teamFlag = nil
                            end

                            TeamFormationModel:updatePartner(pIdx, targetMc.heroId, nil, targetMc.teamFlag)

                            if self.systemId == FuncTeamFormation.formation.endless then
                                local pIdxDischarge = TeamFormationModel:getPartnerPIdx(targetMc.heroId, otherFormationWave)
                                if pIdxDischarge and pIdxDischarge ~= 0 then
                                    TeamFormationModel:dischargePartnerByFormationWave(pIdxDischarge, otherFormationWave)
                                    if otherPartnerView then
                                        otherPartnerView:loadOneFormation(pIdxDischarge)
                                        otherPartnerView:initWuXingPos()
                                    end                                
                                end  
                            end
                            self.scroll_1:refreshCellView(1)
                        end   
                    end
                end              
            elseif (self.systemId == FuncTeamFormation.formation.pve_tower or 
                    self.systemId == FuncTeamFormation.formation.crossPeak or
                    self.systemId == FuncTeamFormation.formation.wonderLand or
                    self.systemId == FuncTeamFormation.formation.endless or
                    self.systemId == FuncTeamFormation.formation.guildBoss or
                    self.systemId == FuncTeamFormation.formation.guildExplorePve or
                    self.systemId == FuncTeamFormation.formation.guildExploreElite) then

                local tempView = self.ctn_node.view
                local tempHeroId = self.ctn_node.heroId
                if targetMc.currentView.panel_1.ctn_player.view then
                    targetMc.currentView.panel_1.ctn_player.view:clear()
                end    
                targetMc.heroId = tempHeroId
                tempView:parent(targetMc.currentView.panel_1.ctn_player):pos(0,-50)
                tempView:zorder(-1)
                targetMc.currentView.panel_1.ctn_player.view = tempView
                --显示属性文字
                
                local targetView = targetMc.currentView.panel_1.ctn_player.view
                if targetView then
                    local  currentFrame =targetView:getCurrentFrame()
                    targetView:gotoAndPlay(currentFrame)
                    targetView:opacity(255)
                end
                if FuncTower.isConfigEmployee(targetMc.heroId) then
                    targetMc.teamFlag = 1
                else
                    targetMc.teamFlag = nil
                end
                TeamFormationModel:updatePartner(pIdx, targetMc.heroId, nil, targetMc.teamFlag)
                if self.systemId == FuncTeamFormation.formation.endless then
                    local pIdxDischarge = TeamFormationModel:getPartnerPIdx(targetMc.heroId, otherFormationWave)
                    if pIdxDischarge and pIdxDischarge ~= 0 then
                        TeamFormationModel:dischargePartnerByFormationWave(pIdxDischarge, otherFormationWave)
                        if otherPartnerView then
                            otherPartnerView:loadOneFormation(pIdxDischarge)
                            otherPartnerView:initWuXingPos()
                        end                                
                    end  
                end
                self.scroll_1:refreshCellView(1)
            elseif self.systemId == FuncTeamFormation.formation.guildBossGve then
                local tempHeroId = self.ctn_node.heroId
                local curTreaId = nil                         
                if tostring(tempHeroId) == "1" then
                    curTreaId = TeamFormationModel:getCurTreaByIdx(1)
                end

                local info = {
                            pid = tostring(tempHeroId),
                            rid = UserModel:rid(),
                            pos = pIdx,
                            tid = curTreaId,
                        }
                TeamFormationServer:sendPickUpOneHero(info)
                tempType = false
                self:setLoadingStatus(true)
                self:disabledUIClick()
                self:createLoadingAnim()
            else
                tempType = false
                WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_023"))
            end
        end
        self.canShangZhen = false
        self.ctnSrcPos = nil
        self.startItemPos = nil
        self.ctn_node:removeAllChildren()
        self.isShowSpine = false
        if TutorialManager.getInstance():isOutFormation() and pIdx == 1 then
            EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_FORMATION)
        end

        if self.isMuilt then
            if tempType and pIdx then
                self:delayCall(function()
                    curPartnerView:playUpToAnimation(pIdx)
                    curPartnerView:updateOneTxtAnimation(pIdx)
                end,0.03)
            end    
        else
            -- self.scroll_1:refreshCellView(1)
            if self.systemId ~= FuncTeamFormation.formation.guildBossGve then
                if pIdx ~= 0 and pIdx ~=nil then
                    curPartnerView:loadOneFormation(pIdx)
                    curPartnerView:initWuXingPos()
                    if tempType then
                        local curElementId = TeamFormationModel:getPosWuXingById(pIdx, self.isSecondFormation)
                        if tostring(curElementId) ~= "0" then
                            curPartnerView:playUpToAnimation(pIdx)
                            curPartnerView:updateOneTxtAnimation(pIdx)
                        end                   
                    end    
                end
                EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
            end
        end
        EventControler:dispatchEvent(TeamFormationEvent.WUXING_ANIM_CHANGED)
        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
    end
    
end  

-- 最上层是当前界面，依次往下分别为候补界面（-1），公用界面（-2），奇侠阵型界面（-3）
function WuXingTeamEmbattleView:initTeamView()
    if self.isMuilt then
        TeamFormationMultiModel:createMultiWuXing()
    end    
    self.pubView = WindowsTools:createWindow("WuXingPubTeamEmbattleView",self.systemId,self.params,self.isMainView,self.isMuilt,self.isNpcs, self.tagsDescription)
    self.ctn_x2:addChild(self.pubView)   
    self.ctn_x2:setLocalZOrder(-2)
    self.partnerView = WindowsTools:createWindow("WuXingTeamPartnerView",self.systemId,self.isMuilt,false,self.elitNpc,self.isHost) 
    self.ctn_x1:addChild(self.partnerView)
    self.ctn_x1:setLocalZOrder(-3)
    self.partnerView:setActivityStatus(true)
    self.pubView:setPartnerView(self.partnerView)
    self.pubView:setMainTeamView(self)
    self.partnerView:setMainTeamView(self)
    if self.systemId == FuncTeamFormation.formation.crossPeak then
        self.crosspeakView = WindowsTools:createWindow("WuXingCrossPeakTeamView", self.systemId, self.isMuilt, false, self.elitNpc)
        self.ctn_x3:addChild(self.crosspeakView)
        self.ctn_x3:setLocalZOrder(-1)
    end

    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        
    end 
end

--
function WuXingTeamEmbattleView:setLoadingStatus(_boolean)
    self.needLoading = _boolean
end

function WuXingTeamEmbattleView:createLoadingAnim()
    local loadingAniName = FuncCommon.getLoadingAniName()
    self:delayCall(function ()
            if self.needLoading then
                local loadingAnim = self:createUIArmature("UI_zhuanjuhua", loadingAniName, self.ctn_loading, true, GameVars.emptyFunc)
                self.ctn_loading.anim = loadingAnim
            end
        end, 0.5)
     
end

function WuXingTeamEmbattleView:removeLoadingAnim()
    if self.ctn_loading.anim then
        self.ctn_loading:removeAllChildren()
        self.ctn_loading.anim = nil
    end 
end

function WuXingTeamEmbattleView:doWuXingBegan(view,event)
    local tempWuXing = 0
    if self.isMuilt then
        tempWuXing = TeamFormationMultiModel:getNowWuXingDataNum(view.data.id)
    else
        tempWuXing = TeamFormationModel:getWuXingTempNum(view.data.id)
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            tempWuXing = TeamFormationModel:getWuXingMultiTempNum(view.data.id, UserModel:rid())    
        end
    end    
    if TutorialManager.getInstance():isOutFormation() and view.data.id ~= "5" then
        return
    end

    if self.isInWuXingDetailStatus then
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

    if tempWuXing == 0 then
        self.canShangZhen = false
        return 
    else
        self.canShangZhen = true 
    end
    
    self.ctn_node:removeAllChildren()
    local xx,yy = view:getPosition()
    local globelPos = view:getParent():convertToWorldSpace(cc.p(xx+50,yy-100))
    local nowWuXingData = FuncTeamFormation.getWuXingDataById(view.data.id)
    local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconPosi)
    local sp1 = display.newSprite(wuxingIcon):addto(self.ctn_node)
    -- sp1:setScale(0.8)
    self.ctn_node.wuxingId = view.data.id
    self.ctn_node.view = sp1
    self.ctn_node.view:opacity(120)
    local cntParent = self.ctn_node:parent()
    local locaNode = cntParent:convertToNodeSpace(globelPos)
    self.ctn_node:pos(locaNode.x,locaNode.y)
    xx,yy = self.ctn_node:getPosition()
    self.ctnSrcPos = {x = xx,y = yy}
    self.startWuXingPos = {x = event.x,y = event.y}
    self.ctn_node.view:visible(false)
end

function WuXingTeamEmbattleView:doWuXingMove( view, event )
    local beginItemPos = nil
    if self.nowChangeView == FuncTeamFormation.btnChange.partner then
        beginItemPos = self.startItemPos
    else
        beginItemPos = self.startWuXingPos
    end    
    if not beginItemPos  then
        return
    end
    if self.canShangZhen then
       
        local offsetX = event.x - beginItemPos.x
        local offsetY = event.y - beginItemPos.y
        if math.abs(offsetY) > 80 then           
            self.ctn_node.view:visible(true)
            --echo("滚动条不能滚动")
            if not self.scroll_1:isSideShow() then
                self.scroll_1:setCanScroll(false)
            else
                local posx,posy = self.scroll_1.scrollNode:getPosition()
                if posx > 0 then
                    self.scroll_1:gotoTargetPos(1,1,0,true)
                else
                    self.scroll_1:gotoTargetPos(#self.npcsData,1,0,true)
                end
            end
        end
        self.ctn_node:pos(self.ctnSrcPos.x + offsetX, self.ctnSrcPos.y+ offsetY)
    end
end

function WuXingTeamEmbattleView:showWuXingDetailInfo(view)
    self.panel_wulingxiangqing:opacity(0)
    self.panel_wulingxiangqing:pos(280, -500 - GameVars.UIOffsetY)
    self.panel_wulingxiangqing:setVisible(true)
    self.panel_wulingxiangqing:runAction(act.spawn(
                    act.fadein(0.2),
                    act.moveto(0.2, 280, -360 - GameVars.UIOffsetY)
                ))
    self.isInWuXingDetailStatus = true
    view.panel_tanhao:setVisible(false)
    view.panel_xuanzhong:setVisible(true)
    local id = view.data.id   
    self:changeShowWuXingDetailInfo(id)

    if self.wuXingCoverLayer then
        self.wuXingCoverLayer:setVisible(true)
    else
        self.wuXingCoverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self.ctn_x3, 0)
        self.wuXingCoverLayer:pos(-GameVars.UIOffsetX, GameVars.UIOffsetY) 
        self.ctn_x3:zorder(-1)
    end
    self.wuXingCoverLayer:setTouchedFunc(c_func(self.hideWuXingDetail, self), nil, true)   
end

function WuXingTeamEmbattleView:changeShowWuXingDetailInfo(id)
    local tempLevel = WuLingModel:getWuLingLevelById(id)
    local firstProperty, secondProperty = WuLingModel:getWuLingProperty(id, tempLevel)
    self.panel_wulingxiangqing.mc_txtlingzhen:showFrame(tonumber(id))
    self.panel_wulingxiangqing.mc_2:showFrame(tonumber(id))
    self.panel_wulingxiangqing.txt_2:setString(tempLevel)
    self.panel_wulingxiangqing.txt_3:setString("+"..firstProperty.."%")
    self.panel_wulingxiangqing.txt_5:setString("+"..secondProperty)
end

function WuXingTeamEmbattleView:hideWuXingDetail()
    local hideFunc = function ()
        self.isInWuXingDetailStatus = false
        self.panel_wulingxiangqing:setVisible(false)
        self.wuXingCoverLayer:setVisible(false)
    end 
    
    self.panel_wulingxiangqing:runAction(act.sequence(act.spawn(
                    act.fadeout(0.2),
                    act.moveto(0.2, 280, -500 - GameVars.UIOffsetY)
                ), act.callfunc(hideFunc)))
    
    if self.lastSelectedWuXingData then
        local _view = self.scroll_1:getViewByData(self.lastSelectedWuXingData)
        if _view then
            _view.panel_xuanzhong:setVisible(false)
        end
    end
    self.lastSelectedWuXingData = nil
end

function WuXingTeamEmbattleView:doWuXingClick(view, event)
     --这里需要弹出属性tips
     -- if tonumber(view.data.id) ~= 0 then
     --    self:setShowWuXingTips(view)
     -- end 
     if self.isInWuXingDetailStatus then
        if self.lastSelectedWuXingData == view.data then
            return 
        else        
            if self.lastSelectedWuXingData then
                local _view = self.scroll_1:getViewByData(self.lastSelectedWuXingData)
                if _view then
                    _view.panel_xuanzhong:setVisible(false)     
                end
            end
            view.panel_xuanzhong:setVisible(true)
            self:changeShowWuXingDetailInfo(view.data.id)
            self.lastSelectedWuXingData = view.data
        end
    else
        local id = view.data.id
        local tempWuXingNum = 1
        local wuxingNum = 1
        local nextLevel = 0
        if self.isMuilt then 
            tempWuXingNum = TeamFormationMultiModel:getNowWuXingDataNum(id)
            wuxingNum = FuncTeamFormation.getMultiWuXingNum(id, UserModel:level())
            nextLevel = FuncTeamFormation.getMulitNextLevelWuLing()
        else    
            tempWuXingNum = TeamFormationModel:getWuXingTempNum(id)
            wuxingNum = FuncTeamFormation.getWuXingNum(id, UserModel:level())
            nextLevel = FuncTeamFormation.getNextLevelWuLing(UserModel:level())
            if self.systemId == FuncTeamFormation.formation.guildBossGve then
                wuxingNum = FuncTeamFormation.getMultiWuXingNum(id, UserModel:level())
                tempWuXingNum = TeamFormationModel:getWuXingMultiTempNum(id, UserModel:rid())    
                nextLevel = FuncTeamFormation.getMulitNextLevelWuLing(UserModel:level())
            end
        end

        local currentNum = TeamFormationModel:getAllWuXinNum()
        local maxWulingNum = TeamFormationModel:wuxingHasPosNum(self.systemId)

        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            currentNum = TeamFormationModel:getWuXingNumByRid(UserModel:rid())
            maxWulingNum = TeamFormationModel:wuxingMultiHasPosNum()
        end

        if self.lastSelectedWuXingData and self.lastSelectedWuXingData == view.data then

        else
            if self.lastSelectedWuXingData then
                local _view = self.scroll_1:getViewByData(self.lastSelectedWuXingData)
                if _view then
                    _view.panel_tanhao:setVisible(false)
                end
            end
            view.panel_tanhao:setVisible(true)
            
            self.lastSelectedWuXingData = view.data
        end
        
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            local isHostPrepared, isMatePrepared = TeamFormationModel:getMultiState()
            if not self.isHost and isMatePrepared then
                return 
            end
        end
            
        if tempWuXingNum > 0 then
            if currentNum < maxWulingNum then
                -- echoError("\n\ntempWuXingNum====", tempWuXingNum)
                EventControler:dispatchEvent(TeamFormationEvent.TEAMFORMATIONEVENT_UP_WULING, {data = view.data})
            else
                if self.systemId == FuncTeamFormation.formation.guildBoss and 
                    currentNum == FuncDataSetting.getDataByConstantName("GuildBossSingleMax") then
                           
                    WindowControler:showTips(GameConfig.getLanguage("#tid_team_des_0010"))
                else
                    if nextLevel then 
                        local _str = string.format(GameConfig.getLanguage("#tid_wuxing_024"), tostring(nextLevel))
                        WindowControler:showTips(_str)
                    else
                        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_025"))
                    end
                end               
            end
        else
            -- echo("\n\n_________11111111________")
            WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_036"))
        end
    end
end

function WuXingTeamEmbattleView:setBackGroundTime(time)
    self.pubView:setMultiBackGroundTime(time)
end

function WuXingTeamEmbattleView:doWuXingEnded(view, event)
    -- self.scroll_1:setCanScroll(true)
    if self.canShangZhen then
        local x,y = event.x,event.y
        local targetMc
        local curPartnerView = self.partnerView
        if self.curFormationWave and self.curFormationWave == FuncEndless.waveNum.SECOND then
            curPartnerView = self.partnerView2
        end

        local pIdx = curPartnerView:checkOneEffect(x,y)
        
        if pIdx then
            targetMc = curPartnerView["mc_tai"..pIdx]
        end 

        if self.isMuilt and pIdx then
            local targetParam = TeamFormationMultiModel:getHeroByIdx(pIdx)     
            local showTips = true
            if tostring(targetParam.element.rid) ~= tostring(TeamFormationMultiModel.rid) and tostring(targetParam.element.rid) ~= "" then
                WindowControler:showTips( GameConfig.getLanguage("#tid_wuxing_019"))
                targetMc = nil 
                pIdx = 0
                showTips = false
            end


            local hasPosNum = TeamFormationMultiModel:getMineNowPosNum()
            if hasPosNum >= 3 and tostring(targetParam.element.rid ) ~= tostring(TeamFormationMultiModel.rid) and showTips then
                WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_020"))
                targetMc = nil  
                pIdx = 0 
            end
        end
        if TutorialManager.getInstance():isOutFormation() and pIdx ~= 4 then 
            targetMc = nil
            pIdx = nil
        end

        if targetMc and targetMc.posWuXingRid and targetMc.posWuXingRid ~= UserModel:rid() then
            WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_009"))
            targetMc = nil
            pIdx = nil
        end

        if targetMc then
            if tostring(targetMc.posWuXing) == "0" then
                local nowWuXingNum = 0
                local AllWuXingNUm = 0
                local nextLevel = 0
                if self.isMuilt then
                    nowWuXingNum = TeamFormationMultiModel:getAllWuXinNum()
                    AllWuXingNUm = TeamFormationMultiModel:wuxingHasPosNum()
                    nextLevel = FuncTeamFormation.getMulitNextLevelWuLing()
                else
                    nowWuXingNum = TeamFormationModel:getAllWuXinNum()
                    AllWuXingNUm = TeamFormationModel:wuxingHasPosNum(self.systemId)
                    nextLevel = FuncTeamFormation.getNextLevelWuLing(UserModel:level())

                    if self.systemId == FuncTeamFormation.formation.guildBossGve then
                        nowWuXingNum = TeamFormationModel:getWuXingNumByRid(UserModel:rid())
                        AllWuXingNUm = TeamFormationModel:wuxingMultiHasPosNum()    
                        nextLevel = FuncTeamFormation.getMulitNextLevelWuLing(UserModel:level())
                    end
                end

                if nowWuXingNum >= AllWuXingNUm then
                    self.canShangZhen = false
                    self.ctnSrcPos = nil
                    self.startItemPos = nil
                    self.ctn_node:removeAllChildren()
                    -- self.scroll_1:refreshCellView(1)
                    if tostring(self.ctn_node.wuxingId) ~= "0" then
                        if self.systemId == FuncTeamFormation.formation.guildBoss and 
                            nowWuXingNum == FuncDataSetting.getDataByConstantName("GuildBossSingleMax") then
                            
                            WindowControler:showTips(GameConfig.getLanguage("#tid_team_des_0010"))
                        else
                            if nextLevel then 
                                local _str = string.format(GameConfig.getLanguage("#tid_wuxing_024"),tostring(nextLevel))
                                WindowControler:showTips(_str)
                            else
                                WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_025"))
                            end
                        end                       
                        return
                    else
                        return   
                    end 
                else
                    if tostring(self.ctn_node.wuxingId) == "0" then   
                        self.canShangZhen = false
                        self.ctnSrcPos = nil
                        self.startItemPos = nil
                        self.ctn_node:removeAllChildren()
                        -- self.scroll_1:refreshCellView(1)
                        return
                    end  
                end
            end
            local tempView = self.ctn_node.view
            local tempWuXingId = self.ctn_node.wuxingId 
            if targetMc.currentView.panel_1.panel_ft.ctn_di.view then
                if self.isMuilt then

                else
                    targetMc.currentView.panel_1.panel_ft.ctn_di.view:clear()
                end
            end
            targetMc.posWuXing = tempWuXingId

            
            --更新玩家的站位信息
            if self.isMuilt then
                if tostring(targetMc.curRid) ~= tostring(TeamFormationMultiModel.rid) and tostring(targetMc.curRid) ~= "" then
                    WindowControler:showTips( GameConfig.getLanguage("#tid_wuxing_026")) 
                else
                    local params = {}
                    params.battleId = TeamFormationMultiModel:getRoomId()
                    params.posNum = pIdx
                    params.elementId = view.data.id
                    self:doOnWuXingPos(params)
                end    
            else
                if self.systemId == FuncTeamFormation.formation.guildBossGve then
                    local info = {
                                fid = tostring(targetMc.posWuXing),
                                rid = UserModel:rid(),
                                pos = pIdx,
                            }
                    TeamFormationServer:sendPickUpOneWuLing(info)
                    self:setLoadingStatus(true)
                    self:disabledUIClick()
                    self:createLoadingAnim()
                else
                    tempView:parent(targetMc.currentView.panel_1.panel_ft.ctn_di)
                    targetMc.currentView.panel_1.panel_ft.ctn_di.view = tempView
                    --显示属性文字
                    
                    local targetView = targetMc.currentView.panel_1.panel_ft.ctn_di.view
                    if targetView then
                        targetView:opacity(255)
                    end
                    TeamFormationModel:setPosWuXing( pIdx,targetMc.posWuXing )
                    curPartnerView:playWuLingAnimation(pIdx)
                    TeamFormationModel:createWuXingNum()
                    self:setWuXingTitle()
                    curPartnerView:initWuXingPos()
                    local heroId = TeamFormationModel:getHeroByIdx(pIdx)
                    if tostring(heroId) ~= "0" then
                        curPartnerView:playUpToAnimation(pIdx)
                        curPartnerView:updateOneTxtAnimation(pIdx)
                    end
                    
                    EventControler:dispatchEvent(TeamFormationEvent.TEAM_WULING_CHANGED)
                    EventControler:dispatchEvent(TeamFormationEvent.WUXING_ANIM_CHANGED)
                end    
            end
            EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
        end
        self.canShangZhen = false
        self.ctnSrcPos = nil
        self.startItemPos = nil
        self.ctn_node:removeAllChildren()
        if TutorialManager.getInstance():isOutFormation() and pIdx == 4 then
            EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_FORMATION)
        end
    end    
end

function WuXingTeamEmbattleView:updateScrollView(event)
    self:setWuXingTitle()
    self.scroll_1:refreshCellView(1)
end

function WuXingTeamEmbattleView:setWuXingTitle()
    if self.nowChangeView == FuncTeamFormation.btnChange.wuxing then
        local nowWuXingNum = 0
        local AllWuXingNum = 0
        if self.isMuilt then
            nowWuXingNum = TeamFormationMultiModel:getAllWuXinNum()
            AllWuXingNum = TeamFormationMultiModel:wuxingHasPosNum()
        else    
            nowWuXingNum = TeamFormationModel:getAllWuXinNum()
            AllWuXingNum = TeamFormationModel:wuxingHasPosNum(self.systemId)
        end    

        self.mc_zhankai.currentView.txt_1:setString(nowWuXingNum.."/"..AllWuXingNum)
    end    
end    

function WuXingTeamEmbattleView:inintShowView()
    if self.systemId == FuncTeamFormation.formation.pvp_defend then
        self.mc_title:showFrame(2)
    else
        self.mc_title:showFrame(1)
    end
end    

function WuXingTeamEmbattleView:notifyStartBattle(params)
     local p = params.params.params.data
      EventControler:dispatchEvent("TRIAL_PIPEI_END_CALLBACK") --- 发送监听到聊天
         EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_MULITI_START_BATTLE_AFTER5008,
        { data = p })
end

function WuXingTeamEmbattleView:notifyPlayerLevel(params)
    if self.isMuilt then
        TrailModel:setPiPeiPlayer(nil)
    end    
    self:startHide()
end

function WuXingTeamEmbattleView:doOnPartnerAction(params)
   if TeamFormationMultiModel:getFormationLockState() == 1 then
         WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_018"))
        return
   end 
   TeamFormationServer:doOnPartner(params,nil)  
end

function WuXingTeamEmbattleView:updateFormationItem(params)
    if self.isMuilt then
         TeamFormationMultiModel:createMultiWuXing()
         self:setWuXingTitle()
     end   
    self:initData()
    self.scroll_1:refreshCellView(1)
end

function WuXingTeamEmbattleView:doOnWuXingPos(params)
    if TeamFormationMultiModel:getFormationLockState() == 1 then
         WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_018"))
        return
   end 
   TeamFormationServer:doChangeWuXing(params,nil) 
end

function WuXingTeamEmbattleView:initWuXingTips()
    self.panel_duihua:visible(false)
end

function WuXingTeamEmbattleView:setShowWuXingTips(view)
    self.panel_duihua:visible(true)
    if self.ctn_bgbg.coverLayer == nil then
    local coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self.ctn_bgbg, 0)
        coverLayer:pos(-GameVars.width/2,GameVars.height/2)
         -- 注册点击任意地方事件
         --0.5秒后才可以点击胜利界面关闭
        coverLayer:setTouchedFunc(c_func(self.closeWuXingTips, self),nil,true)
        self.ctn_bgbg.coverLayer  = coverLayer
    end
    local xx,yy = view:getPosition()
    self.ctn_bgbg:visible(true)
    local tempNum = GameVars.height / 768
    self.panel_duihua:setPosition(xx + 210, yy - 455 * tempNum)
    self.panel_duihua:setTouchedFunc(c_func(self.isCanCloseWuXingTips),nil,true)
    local tempLevel = WuLingModel:getWuLingLevelById(view.data.id)
    local firstProperty,secondProperty = WuLingModel:getWuLingProperty(view.data.id, tempLevel)
    local wulingType = WuLingModel:switchTextById(view.data.id)
    self.panel_duihua.txt_1:setString(wulingType..": +"..firstProperty.."%")
    self.panel_duihua.txt_2:setString(GameConfig.getLanguage("#tid_wuxing_027")..secondProperty) 

end

function WuXingTeamEmbattleView:closeWuXingTips()
    if self.ctn_bgbg and self.ctn_bgbg.coverLayer then
        self.ctn_bgbg.coverLayer:clear()
        self.ctn_bgbg.coverLayer = nil
    end
     self.panel_duihua:visible(false)
     self.ctn_bgbg:visible(false)
end

function WuXingTeamEmbattleView:isCanCloseWuXingTips()
    --点击资源的界面出现的内容
end


function WuXingTeamEmbattleView:updateWuXingScrollView(event)
    if self.isMuilt then
        TeamFormationMultiModel:createMultiWuXing()
    else 
        TeamFormationModel:createWuXingNum()
    end    
    self:setWuXingTitle()   
    if self.nowChangeView == FuncTeamFormation.btnChange.wuxing then
        self.scroll_1:refreshCellView(1)
    end  
end  
  
function WuXingTeamEmbattleView:checkNpcs(id)
    if self.elitNpc then
        for k,v in pairs(self.elitNpc) do
            if tostring(v) == tostring(id) then
                return true
            end
        end
        return false
    end 
end

function WuXingTeamEmbattleView:initEffectBtnView()

    if self.nowChangeView == FuncTeamFormation.btnChange.wuxing then
        self.mc_zhankai.currentView.btn_1:setVisible(false)
        self.mc_zhankai.currentView.txt_1:setVisible(false)
        -- self.mc_zhankai.currentView.btn_1:setTouchedFunc(c_func(self.showEffectView,self), nil, true)
    end
end


function WuXingTeamEmbattleView:showEffectView()
    if TutorialManager.getInstance():isOutFormation() then
        return
    end
    local params = {}
    params.x, params.y = self.mc_zhankai:getPosition()
   
    WindowControler:showWindow("WuXingNowDetailTips",self.isMuilt,params,self.systemId)
end   

function WuXingTeamEmbattleView:showWuXingWarnTips()
    -- local raidData = FuncChapter.getRaidDataByRaidId("10506")
    -- local str1 = GameConfig.getLanguage(raidData.name)
    -- local chapter = FuncChapter.getChapterByStoryId(tostring(raidData.chapter))
    -- local section = FuncChapter.getSectionByRaidId("10506")
    -- local str2 = "第"..chapter.."章"
    WindowControler:showTips(GameConfig.getLanguage("tid_up_333"))
end

function WuXingTeamEmbattleView:updataWuXingView()
    -- self:initData()
    -- self:initScrollPartener()
    self:initData()
    self.scroll_1:refreshCellView(1)
end

function WuXingTeamEmbattleView:showWuLingDetailView()
    if not self.wuxingDetailView then
        self.wuxingDetailView = WindowsTools:createWindow("WuXingNowDetailTips", self.isMuilt, self.systemId)
        self.wuxingDetailView:addto(self._root)
        self.wuxingDetailView:pos(15 - GameVars.UIOffsetX + GameVars.toolBarWidth, -105 + GameVars.UIOffsetY)
        self.wuxingDetailView:setScale(0)
        self.wuxingDetailView:runAction(act.scaleto(0.2, 1.0, 1.0))
    else
        self.wuxingDetailView:setVisible(true)
        self.wuxingDetailView:refreshDetailView()
        self.wuxingDetailView:runAction(act.scaleto(0.2, 1.0, 1.0))
    end
end

function WuXingTeamEmbattleView:hideWuLingDetailView()
    if self.wuxingDetailView then 
        self.wuxingDetailView:runAction(act.scaleto(0.2, 0))
        self:delayCall(function ()
                self.wuxingDetailView:setVisible(false)
            end, 0.2)
    end 
end

function WuXingTeamEmbattleView:startHide()
    WuXingTeamEmbattleView.super.startHide(self)
    TeamFormationModel:setCurrentSystemId(nil)
    EventControler:dispatchEvent(TeamFormationEvent.TEAMVIEW_HAS_CLOSED)
    if self.systemId == FuncTeamFormation.formation.pve then
        PartnerModel:setFormationPartners()
        PartnerModel:dispatchShowApproveAnimEvent()
    end
end

return WuXingTeamEmbattleView;
