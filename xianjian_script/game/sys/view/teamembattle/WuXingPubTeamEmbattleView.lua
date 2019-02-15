--[[
	Author: caocheng
	Date:2017-10-14
	Description: 五行布界面的按钮和
]]

local WuXingPubTeamEmbattleView = class("WuXingPubTeamEmbattleView", UIBase);

function WuXingPubTeamEmbattleView:ctor(winName,systemId,params,isMainView,isMuilt,isNpcs, tagsDescription)
    WuXingPubTeamEmbattleView.super.ctor(self, winName)
    self.systemId = systemId
    self.isMainView = isMainView or false
    self.isMuilt = isMuilt or false
    self.tagsDescription = tagsDescription
    self.paramsData = params

    if self.paramsData then
        local pdata = params[systemId]
        if pdata ~= nil then
            self.hasNpcs = pdata.npcs
            self.raidId = pdata.raidId
            self.groupId = pdata.groupId
            self.battleId = pdata.battleId
        end
    end

    self.backGroundTime = 0
    self.timeLeftFrame = FuncDataSetting.getMultiFormationTimeOut() * GameVars.GAMEFRAMERATE
    self.isNpc = isNpcs or false

    if self.groupId and self.groupId == UserModel:rid() then
        self.isHost = true
    end
end

function WuXingPubTeamEmbattleView:loadUIComplete()
	self:registerEvent()
	self:initData()
    if self.isMuilt then
        self:startTick()
    end    
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingPubTeamEmbattleView:registerEvent()
	WuXingPubTeamEmbattleView.super.registerEvent(self);
    EventControler:addEventListener(TeamFormationEvent.RESET_POWER_EVENT, self.resetPower, self)
	EventControler:addEventListener(TeamFormationEvent.UPDATA_POSNUMTEXT,self.updataPosData, self)
    -- EventControler:addEventListener(TeamFormationEvent.UPDATA_TREA, self.resetPower, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_MULITI_LOCKSTATE_CHANGED,self.updateFormationState,self)
    EventControler:addEventListener(TeamFormationEvent.OPEN_SCREANONCLICK,self.openClickView,self)
    -- EventControler:addEventListener(WuLingEvent.WULINGEVENT_MAINVIEW_UPDATA, self.updateWuLingRed, self) 
    EventControler:addEventListener(TeamFormationEvent.TEAM_WULING_CHANGED, self.updataPosData, self)
    EventControler:addEventListener(TeamFormationEvent.PVP_SKILLVIEW_CLOSED, self.updatePvpBubbleStatus, self)
    --如果是登仙台布阵需要监听buff变化的消息
    if self.systemId == FuncTeamFormation.formation.pvp_defend
       or self.systemId == FuncTeamFormation.formation.pvp_attack then
        EventControler:addEventListener(PvpEvent.PVP_BUFF_REFRESH_EVENT, self.notifyPvpBuffChanged, self)
    end
    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        EventControler:addEventListener("nofify_battle_multi_chat_msg_5020",self.multiFormationChat,self)
        EventControler:addEventListener(TeamFormationEvent.MULTI_FINISH_TEAM, self.prepareForBattle, self)
    end
    EventControler:addEventListener(TeamFormationEvent.CANDIDATE_CHANGED, self.initPosNum, self)
end

function WuXingPubTeamEmbattleView:notifyPvpBuffChanged()
    self:initData()
    self:initPosNum()
end

function WuXingPubTeamEmbattleView:initData()
	if self.systemId == FuncTeamFormation.formation.pvp_defend
       or self.systemId == FuncTeamFormation.formation.pvp_attack
       or self.systemId == FuncTeamFormation.formation.shareBoss
       or self.systemId == FuncTeamFormation.formation.guildBoss
       or self.systemId == FuncTeamFormation.formation.wonderLand
       or self.systemId == FuncTeamFormation.formation.endless then
        self.pvpBuffId = PVPModel:getBuffIdByServerTime()
    end
end

function WuXingPubTeamEmbattleView:initView()
    self.rightItems = {self.mc_zhandou}
    self.topItems = {self.mc_tips, self.panel_power}
    
    self.mc_szzs:setVisible(false)
    self:initBattleBtnType()
	self:initialPower()
	self:initPosNum()
	-- self:initTreaView()
    if self.groupId then
        self.btn_yijian:setVisible(false)
    else
        self.btn_yijian:setVisible(true)
        self.btn_yijian:setTouchedFunc(c_func(self.doFormationByOneKey, self))
    end
    
    self:initChatView()
    --倒计时
    self:initCountdown()
    self:initTextView()
    self:updateNuQiPanel()


    -- self:initPvpAttrBuffTxt()
    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        self.mc_1:setVisible(true)
        self.mc_1:showFrame(1)
        if self.isHost then
            self.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_team_tips_001").."...")
        else
            self.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_team_tips_002").."...")
        end

        table.insert(self.topItems, self.mc_2)
        table.insert(self.topItems, self.mc_3)
        table.insert(self.topItems, self.btn_3)
        table.insert(self.topItems, self.btn_4)
        table.insert(self.topItems, self.mc_1)
    else
        self.mc_1:setVisible(false)
        table.insert(self.rightItems, self.btn_yijian)
    end 

    -- 当为竞技场布阵时 需要有仙术设置功能
    if self.systemId == FuncTeamFormation.formation.pvp_attack 
        or self.systemId == FuncTeamFormation.formation.pvp_defend then
        self.mc_szzs:setVisible(true)
        self.mc_szzs:showFrame(1)
        local tempTeamformation = TeamFormationModel:getTempFormation() 
        if not tempTeamformation.energy or table.length(tempTeamformation.energy) == 0 then
            self.bubbleUI = self:updateBubbleUI(self.mc_szzs)
        end
        self.mc_szzs.currentView.btn_xssz:setTouchedFunc(c_func(self.doClickSkillSetting,self))
        table.insert(self.rightItems, self.mc_szzs)
    --如果是无底深渊  则需要显示第一波第二波的切换按钮          
    elseif self.systemId == FuncTeamFormation.formation.endless then
        self._wave = FuncEndless.waveNum.FIRST
        self.mc_szzs:setVisible(true)
        self.mc_szzs:showFrame(self._wave + 1)
        self.mc_szzs.currentView.btn_1:setTouchedFunc(c_func(self.changePartnerViewByWave, self))
        table.insert(self.rightItems, self.mc_szzs)

        self.mc_1:showFrame(self._wave + 1)
        self.mc_1:setVisible(true)
        table.insert(self.topItems, self.mc_1)
    else
        self.mc_szzs:setVisible(false)
    end
end

--加载左上角怒气值
function WuXingPubTeamEmbattleView:updateNuQiPanel()
    if self.systemId == FuncTeamFormation.formation.pve_tower then
        self.panel_nuqi:setVisible(true)
        local curEnergy = TowerMainModel:getCurEnergy()
        local maxEnergy = TowerMainModel:getMaxEnergy()
        self:setEnergyNum(self.panel_nuqi.panel_nuqizhi.mc_1, curEnergy)
        self:setEnergyNum(self.panel_nuqi.panel_nuqizhi.mc_2, maxEnergy)
    else
        self.panel_nuqi:setVisible(false)
    end
end

function WuXingPubTeamEmbattleView:setEnergyNum(mcView,num)
    local valueTable = number.split(num)
    local len = table.length(valueTable)
    --不能高于2
    if len > 2 then 
        return
    end 
    mcView:showFrame(len);

    local offsetx = 0
    for k, v in ipairs(valueTable) do
        local mcs = mcView:getCurFrameView()
        local childMc = mcs["mc_" .. tostring(k)]
        childMc:showFrame(v + 1)
    end
end

--无底深渊存在两波布阵 需要分开处理
function WuXingPubTeamEmbattleView:changePartnerViewByWave()
    self.mc_1:setVisible(false)
    self.mc_szzs:setVisible(false)
    local setMcVisible = function ()
        self.mc_1:setVisible(true)
        self.mc_szzs:setVisible(true)
    end

    local moveDistance = GameVars.maxScreenWidth
    local moveTime = 0.3
    if self._wave == FuncEndless.waveNum.FIRST then
        self._wave = FuncEndless.waveNum.SECOND
        TeamFormationModel:setCurFormationWave(self._wave)
        self.mainTeamView:setCurFormationWave(self._wave)
        if not self.partnerView2 then
            local isSecondFormation = true         
            self.partnerView2 = WindowsTools:createWindow("WuXingTeamPartnerView",self.systemId,self.isMuilt,false,nil,nil,isSecondFormation)
            self.mainTeamView.ctn_x1:addChild(self.partnerView2)   
            self.mainTeamView.ctn_x1:setLocalZOrder(-3)
            self.mainTeamView.partnerView2 = self.partnerView2
            self.partnerView2:setWuXingOrPartner(self.mainTeamView.nowChangeView)
            self.partnerView2:pos(moveDistance, 0)
            local bg = display.newSprite(FuncRes.iconBg("team_img_dabg.png"))
            bg:addto(self.partnerView2.ctn_bg)
            bg:pos(GameVars.gameResWidth / 2, -GameVars.gameResHeight / 2)          
        end

        self.partnerView2:setActivityStatus(true)
        self.partnerView:setActivityStatus(false)
        self.partnerView:runAction(act.sequence(act.moveby(moveTime, -moveDistance, 0), act.callfunc(setMcVisible)))
        self.partnerView2:moveBy(moveTime, -moveDistance, 0)
        self.mainTeamView.__bgView:moveBy(moveTime, -moveDistance, 0)
        self.mc_1:showFrame(self._wave + 1)
        self.mc_szzs:showFrame(3)
        self.mc_szzs.currentView.btn_1:setTouchedFunc(c_func(self.changePartnerViewByWave, self))
    else 
        self._wave = FuncEndless.waveNum.FIRST
        TeamFormationModel:setCurFormationWave(self._wave)
        self.mainTeamView:setCurFormationWave(self._wave)
        self.partnerView:setActivityStatus(true)
        self.partnerView2:setActivityStatus(false)

        self.partnerView:runAction(act.sequence(act.moveby(moveTime, moveDistance, 0), act.callfunc(setMcVisible)))
        self.partnerView2:moveBy(moveTime, moveDistance, 0)
        self.mainTeamView.__bgView:moveBy(moveTime, moveDistance, 0)       
        self.mc_1:showFrame(self._wave + 1)
        self.mc_szzs:showFrame(2)
        self.mc_szzs.currentView.btn_1:setTouchedFunc(c_func(self.changePartnerViewByWave, self))     
    end 
    self:initPosNum()
    self:resetPower()
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_WUINGDATA)
end

function WuXingPubTeamEmbattleView:setPartnerView(partnerView)
    self.partnerView = partnerView
end

function WuXingPubTeamEmbattleView:setMainTeamView(_mainTeamView)
    self.mainTeamView = _mainTeamView
end

function WuXingPubTeamEmbattleView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_zhandou, UIAlignTypes.RightBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_power, UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_ysz, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_tips, UIAlignTypes.LeftTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.scale9_2, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_yijian, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_chat, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_2, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_3, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_3, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_4, UIAlignTypes.RightTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_fivesoul, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_szzs, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.ctn_texiao, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_1, UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_nuqi, UIAlignTypes.LeftTop)
end

--切换到查看敌情界面时 需要有一个向四周移出的动画
function WuXingPubTeamEmbattleView:moveItemsView(moveOffsetX, moveOffsetY, _isVisible)
    local setVisibleFunc = function (_view, isVisible)
        _view:setVisible(isVisible)
    end

    self:moveGuildBossItems(false)

    for i,v in ipairs(self.topItems) do
        v:runAction(act.sequence(act.moveby(0.2, 0, moveOffsetY), act.callfunc(c_func(setVisibleFunc, v, _isVisible))))
    end

    for i,v in ipairs(self.rightItems) do
        v:runAction(act.sequence(act.moveby(0.2, moveOffsetX, 0), act.callfunc(c_func(setVisibleFunc, v, _isVisible))))
    end
end

--切换回布阵界面时  需要一个移回的动画
function WuXingPubTeamEmbattleView:moveBackItemsView(moveOffsetX, moveOffsetY, _isVisible)
    local setVisibleFunc = function (_view, isVisible)
        _view:setVisible(isVisible)
    end

    self:delayCall(c_func(self.moveGuildBossItems, self, true), 0.2)

    for i,v in ipairs(self.topItems) do
        v:runAction(act.sequence(act.callfunc(c_func(setVisibleFunc, v, _isVisible)), act.moveby(0.2, 0, -moveOffsetY)))
    end

    for i,v in ipairs(self.rightItems) do
        v:runAction(act.sequence(act.callfunc(c_func(setVisibleFunc, v, _isVisible)), act.moveby(0.2, -moveOffsetX, 0)))
    end
end

function WuXingPubTeamEmbattleView:moveGuildBossItems(_isVisible)
    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        self.panel_t1:setVisible(_isVisible)
        self.panel_t2:setVisible(_isVisible)

        if self.isShowChat1 then
            self.panel_chat1:setVisible(_isVisible)
        end

        if self.isShowChat2 then
            self.panel_chat2:setVisible(_isVisible)
        end

        if self.isOpenQuickChat then
            self.panel_chat:setVisible(_isVisible)
        end
    end
end

--有
function WuXingPubTeamEmbattleView:initPvpAttrBuffTxt()
    if self.pvpBuffId then
        self.btn_bzjc:setVisible(true)
        if self.systemId == FuncTeamFormation.formation.pvp_defend
            or self.systemId == FuncTeamFormation.formation.pvp_attack then
            
            local buffData = FuncPvp.getBuffDataByBuffId(self.pvpBuffId)
            local themeName = GameConfig.getLanguage(buffData.themeName)
            self.btn_bzjc:getUpPanel().txt_1:setString(GameConfig.getLanguageWithSwap("#tid_pvp_des005" ,themeName))
        else
            self.btn_bzjc:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_pvp_des005"))
        end
        self.btn_bzjc:setTouchedFunc(c_func(self.showBuffView, self))
    else
        self.btn_bzjc:setVisible(false)
    end
end

-- 登仙台中点击弹出bufflist,该bugfflist中下部添加无极阁加成属性
-- 其他玩法的 则弹出 仙盟无极阁加成bufflist
function WuXingPubTeamEmbattleView:showBuffView()
    if self.systemId == FuncTeamFormation.formation.pvp_attack 
        or self.systemId == FuncTeamFormation.formation.pvp_defend then
        WindowControler:showWindow("ArenaBuffView", self.pvpBuffId)
    else
        local effectZoneType = FuncGuild.effectZoneType.SHAREBOSS
        if self.systemId == FuncTeamFormation.formation.shareBoss then
            effectZoneType = FuncGuild.effectZoneType.SHAREBOSS
        elseif self.systemId == FuncTeamFormation.formation.guildBoss then
            effectZoneType = FuncGuild.effectZoneType.GUILDBOSS
        elseif self.systemId == FuncTeamFormation.formation.wonderLand then
            effectZoneType = FuncGuild.effectZoneType.WONDERLAND
        elseif self.systemId == FuncTeamFormation.formation.endless then
            effectZoneType = FuncGuild.effectZoneType.ENDLESS
        end
        WindowControler:showWindow("GuildSkillPropertiesView",effectZoneType)
    end
end

function WuXingPubTeamEmbattleView:updateUI()
	-- TODO
end


function WuXingPubTeamEmbattleView:setMultiBackGroundTime(time)
    if self.isMuilt then
         self.backGroundTime = time
    end
end

function WuXingPubTeamEmbattleView:startTick()
    TimeControler:startOneCd("multiFormation_leftTime_CD",self.timeLeftFrame/GameVars.GAMEFRAMERATE)
    self.handle = self:scheduleUpdateWithPriorityLua(c_func(self.updateTimeLeft,self), 0)
end

function WuXingPubTeamEmbattleView:updateTimeLeft()
     self.mc_zhandou.currentView.txt_1:visible(true)
    local sec = TimeControler:getCdLeftime("multiFormation_leftTime_CD")-self.backGroundTime --math.floor(self.timeLeftFrame/GameVars.GAMEFRAMERATE)
    local newsec = sec
    if sec<=0 then
        sec = 0
    end
    -- if sec <= 1 then
    --     self.btn_back:setTouchedFunc(function()  end)
    -- end
    self.mc_zhandou.currentView.txt_1:setString(sec)
    if newsec <= 0 then
        self:unscheduleUpdate()
        --end
        --发送超时请求
        self:doSendTimeOut()
    end
end

function WuXingPubTeamEmbattleView:doSendTimeOut()
    TeamFormationMultiModel:setTimeOutLock()
    local params = {}
    params.battleId = TeamFormationMultiModel:getRoomId()
    EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMDETAILVIEW)
    TeamFormationServer:doTimeOut(params)
end
  
function WuXingPubTeamEmbattleView:initialPower()
	local allPowerNum = 0
    if self.isMuilt then
        allPowerNum = TeamFormationMultiModel:getMultiTempAbility()
    else    
        allPowerNum = TeamFormationModel:getTempAbility()
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            allPowerNum = 0
        end
    end    
    self.panel_power.UI_power:setPower(allPowerNum)
    self.nowPowerNum = allPowerNum
end

function WuXingPubTeamEmbattleView:showWuLingDetailView()
    if TutorialManager.getInstance():isOutFormation() then
        return
    end
   
    self.mainTeamView:showWuLingDetailView()
end

function WuXingPubTeamEmbattleView:initPosNum()
    if self.isMuilt then
        self.mc_tips:visible(false)
    else
        -- self.mc_tips:visible(false)
        if self.systemId == FuncTeamFormation.formation.crossPeak then
            self.mc_tips:showFrame(2)
            self.mc_tips.currentView.btn_1:setTouchedFunc(c_func(self.showWuLingDetailView, self), nil, true)
            local panel_tips = self.mc_tips.currentView.panel_ysz
            local fightNumMax = CrossPeakModel:getFightNumMax()
            local fightInStageMax = CrossPeakModel:getFightInStageMax()
            local candidateNum = fightNumMax - fightInStageMax
            local nowTeamNum = TeamFormationModel:hasNowTeamNum(self.systemId)
            if nowTeamNum < fightInStageMax then
                panel_tips.mc_1:showFrame(2)
            else
                panel_tips.mc_1:showFrame(1)
            end
            panel_tips.mc_1.currentView.txt_25:setString(tostring(nowTeamNum))
            panel_tips.txt_3:setString("/ "..fightInStageMax)
            panel_tips.txt_2:setString(GameConfig.getLanguage("#tid_team_des_005"))
            
            local nowCandidateNum = TeamFormationModel:hasNowCandidateNum()
            if nowCandidateNum < candidateNum then
                panel_tips.mc_2:showFrame(2)
            else
                panel_tips.mc_2:showFrame(1)
            end
            panel_tips.mc_2.currentView.txt_25:setString(tostring(nowCandidateNum))
            panel_tips.txt_5:setString("/ "..candidateNum)
            panel_tips.txt_4:setString(GameConfig.getLanguage("#tid_team_des_006"))

            if FuncCommon.isSystemOpen("fivesoul") then
                local maxWulingNum = TeamFormationModel:wuxingHasPosNum(self.systemId)
                local nowWulingNum = TeamFormationModel:getAllWuXinNum()

                if tonumber(maxWulingNum) == tonumber(nowWulingNum) then
                    panel_tips.mc_3:showFrame(1)
                else
                    panel_tips.mc_3:showFrame(2)
                end
                panel_tips.mc_3.currentView.txt_25:setString(nowWulingNum)
                panel_tips.txt_7:setString("/ "..(maxWulingNum))
                panel_tips.mc_3:setVisible(true)
                panel_tips.txt_7:setVisible(true)
                panel_tips.txt_6:setString(GameConfig.getLanguage("#tid_team_des_007"))
            else
                panel_tips.mc_3:setVisible(false)
                panel_tips.txt_7:setVisible(false)
                panel_tips.txt_6:setString("")
            end
        else
            self.mc_tips:showFrame(1)
            self.mc_tips.currentView.panel_ysz.btn_1:setTouchedFunc(c_func(self.showWuLingDetailView, self), nil, true)
            
            if self.pvpBuffId then
                self.mc_tips.currentView.panel_bzjc:setVisible(true)
                --如果是竞技场则显示本周加成  如果不是显示仙盟科技加成
                if self.systemId == FuncTeamFormation.formation.pvp_defend
                    or self.systemId == FuncTeamFormation.formation.pvp_attack then 

                    local buffData = FuncPvp.getBuffDataByBuffId(self.pvpBuffId)
                    local themeName = GameConfig.getLanguage(buffData.themeName)
                    self.mc_tips.currentView.panel_bzjc.txt_1:setString(GameConfig.getLanguageWithSwap("#tid_pvp_des005", themeName))
                else
                    self.mc_tips.currentView.panel_bzjc.txt_1:setString(GameConfig.getLanguage("#tid_guild_skill_20"))
                end
                
                self.mc_tips.currentView.panel_bzjc.btn_1:setTouchedFunc(c_func(self.showBuffView, self))              
            elseif self.tagsDescription then
                self.mc_tips.currentView.panel_bzjc:setVisible(true)
            else
                self.mc_tips.currentView.panel_bzjc:setVisible(false)
            end

            local maxNum,maxLevel = FuncTeamFormation.checkPoshasOpenNum(UserModel:level())
            local nowNum = TeamFormationModel:hasNowTeamNum(self.systemId)

            if self.systemId == FuncTeamFormation.formation.guildBoss then
                maxNum = FuncDataSetting.getDataByConstantName("GuildBossSingleMax")
            end

            if self.systemId == FuncTeamFormation.formation.guildBossGve then
                nowNum = TeamFormationModel:hasMultiNowTeamNum(self.systemId)
            end

            --无底深渊分为两个布阵  需要特殊处理
            if self.systemId == FuncTeamFormation.formation.endless then
                local curEndlessId = EndlessModel:getCurChallengeEndlessId()
                maxNum = FuncEndless.getFormationNumByEndlessId(curEndlessId)
            end

            if tonumber(nowNum) == tonumber(maxNum) then
                self.mc_tips.currentView.panel_ysz.mc_1:showFrame(1)
            else
                self.mc_tips.currentView.panel_ysz.mc_1:showFrame(2)
            end    
                      
            self:createTeamTitle(nowNum,maxNum,maxLevel) 

            if FuncCommon.isSystemOpen("fivesoul") then
                self.mc_tips.currentView.panel_ysz.mc_2:showFrame(2)
                local maxWulingNum = TeamFormationModel:wuxingHasPosNum(self.systemId)
                local nowWulingNum = TeamFormationModel:getAllWuXinNum()
                
                if self.systemId == FuncTeamFormation.formation.guildBossGve then
                    maxWulingNum = TeamFormationModel:hasMultiNowWuXingNum(self.systemId)
                end
                if tonumber(maxWulingNum) == tonumber(nowWulingNum) then
                    self.mc_tips.currentView.panel_ysz.mc_2.currentView.mc_1:showFrame(1)
                else
                    self.mc_tips.currentView.panel_ysz.mc_2.currentView.mc_1:showFrame(2)
                end

                self.mc_tips.currentView.panel_ysz.mc_2.currentView.mc_1.currentView.txt_25:setString(nowWulingNum)

                self.mc_tips.currentView.panel_ysz.mc_2.currentView.txt_3:setString("/ "..(maxWulingNum))

            else
                self.mc_tips.currentView.panel_ysz.mc_2:showFrame(1)
                self.mc_tips.currentView.panel_ysz.mc_2.currentView.txt_2:setString("")
            end 

            if not self.tipsAnim then
                self.mc_tips:opacity(0)
                self.tipsAnim = self:createUIArmature("UI_wulingchuzhan","UI_wulingchuzhan_chuzhantishi", self.ctn_texiao, false)
                self.tipsAnim:pos(0, -5)
                self.tipsAnim:registerFrameEventCallFunc(15, 1, function ()
                    self.mc_tips:runAction(act.fadein(0.5))
                    -- self.mc_tips:setVisible(true)
                end) 
            end                     
        end
    end
end

function WuXingPubTeamEmbattleView:createTeamTitle(nowNum,maxNum,maxLevel)

    self.mc_tips.currentView.panel_ysz.mc_1.currentView.txt_25:setString(nowNum)

    self.mc_tips.currentView.panel_ysz.txt_25:setString("/ "..(maxNum))
    -- TODO 需要配置多语言表
    -- local _str = string.format(GameConfig.getLanguage("#tid_wuxing_006"),tostring(maxLevel),tostring(maxNum)) 
    -- self.mc_tips.currentView.panel_ysz.txt_2:setString("")
end

function WuXingPubTeamEmbattleView:doFormationByOneKey()
    if TutorialManager.getInstance():isOutFormation() then
        return
    end
    if self.isMuilt then
            TeamFormationMultiModel:allOnFormation()
            -- TODO 需要配置多语言表 
            WindowControler:showTips( GameConfig.getLanguage("#tid_wuxing_007") )
            AudioModel:playSound(MusicConfig.s_partner_yijian)  
            EventControler:dispatchEvent(TeamFormationEvent.PLAY_UPTOMULTITEAMANITION)
            self:disabledUIClick()     
    else
       
        if TutorialManager.getInstance():isTrialFormation() then
            -- 试炼窟阵型特殊处理
            TeamFormationModel:allOnSpecialTeam()
        elseif self.systemId == FuncTeamFormation.formation.pve_tower then
            if TeamFormationModel:checkAllDead() then
                WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_008") )
                return
            else
                TeamFormationModel:allOnFormation(nil,self.systemId)
            end
        else    
    	    TeamFormationModel:allOnFormation(nil,self.systemId)
        end  

        -- if self.systemId == FuncTeamFormation.formation.pve_tower and TeamFormationModel:checkAllDead() then
        --     WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_008") )
        --     return
        -- end 

        -- 巅峰竞技场一键布阵需求 需要刷新相关UI
        if self.systemId == FuncTeamFormation.formation.crossPeak then
            EventControler:dispatchEvent(TeamFormationEvent.CANDIDATE_CHANGED)
            EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
        end

        --刷新对应的cell
        EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)       
        EventControler:dispatchEvent(TeamFormationEvent.UPDATA_HEROANIMATION)
        -- self:updateFormationTreas()
        --一键布阵音效
        AudioModel:playSound(MusicConfig.s_partner_yijian)
        self:initPosNum()
        -- TODO 需要配置多语言表
        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_007")) 
        EventControler:dispatchEvent(TeamFormationEvent.PLAY_UPTOTEAMANIMATION)
        EventControler:dispatchEvent(TeamFormationEvent.RESET_POWER_EVENT)
        self:disabledUIClick()
   end   
     
end

function WuXingPubTeamEmbattleView:resetPower()
    echo("\n\n________resetPower______")
	local allPowerNum = 0
    if self.isMuilt then
        allPowerNum = TeamFormationMultiModel:getMultiTempAbility()
    else
        allPowerNum = TeamFormationModel:getTempAbility()
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            allPowerNum = TeamFormationModel:getMultiTempAbility()
        end
    end    
    self.panel_power.UI_power:setPower(allPowerNum)
    self.nowPowerNum = allPowerNum
end

function WuXingPubTeamEmbattleView:deleteMe()
	-- TODO
    self:unscheduleUpdate()

	WuXingPubTeamEmbattleView.super.deleteMe(self);
end
    
function WuXingPubTeamEmbattleView:initChatView()
    if self.isMuilt then
       self.panel_chat:visible(false)
       self.mc_szzs:setVisible(false)
       -- self.btn_2:setTouchedFunc(c_func(self.doVoiceChat,self))
       self.btn_3:setTouchedFunc(c_func(self.doCommonChat,self))
       self.btn_4:setTouchedFunc(c_func(self.doQuickChat,self))
    else
        self.panel_chat1:setVisible(false)
        self.panel_chat2:setVisible(false)
        self.panel_chat:visible(false) 
        if tonumber(self.systemId) == FuncTeamFormation.formation.guildBossGve then
            self.mc_2:visible(true)
            self.mc_3:visible(true)
            self.btn_3:visible(true)
            self.btn_4:visible(true)
            self.panel_t1:setVisible(true)
            self.panel_t2:setVisible(true)
            self:updateHeadAndFrame(self.panel_t1, true)
            self:updateHeadAndFrame(self.panel_t2)
            self.mc_2:setTouchedFunc(c_func(self.doVoiceClick, self))
            self.mc_3:setTouchedFunc(c_func(self.doMicClick, self))
            self.btn_3:setTouchedFunc(c_func(self.doCommonChat, self))
            self.btn_4:setTouchedFunc(c_func(self.doQuickChat, self))
            local micFrame = tonumber(LS:prv():get(StorageCode.realTime_mic, 1))
            self.mc_3:showFrame(micFrame)

            local staFrame = tonumber(LS:prv():get(StorageCode.realTime_voice, 1))
            self.mc_2:showFrame(staFrame)
        else           
            self.mc_2:visible(false)
            self.mc_3:visible(false)
            self.btn_3:visible(false)
            self.btn_4:visible(false)
            self.panel_t1:setVisible(false)
            self.panel_t2:setVisible(false)
        end        
    end    
end

function WuXingPubTeamEmbattleView:updateHeadAndFrame(_panel, isSelf)
    local head = nil
    local avatar = nil
    local frame = nil
    if isSelf then
        head = UserModel:head()
        avatar = UserModel:avatar()
        frame = UserModel:frame()
    else
        local mateInfo = GuildBossModel:getGuildBossMateInfo()
        head = mateInfo.head or ""
        avatar = mateInfo.avatar
        frame = mateInfo.frame or ""
    end

    local iconHead = FuncRes.iconHero(FuncUserHead.getHeadIcon(head, avatar))
    local headSprite = display.newSprite(iconHead)
    local iconFrame = FuncRes.iconHero(FuncUserHead.getHeadFramIcon(frame))
    local frameSprite = display.newSprite(iconFrame)
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(0,0)
    headSprite = FuncCommUI.getMaskCan(headMaskSprite, headSprite)
    headSprite:pos(-2.2, 1.5)
    frameSprite:pos(-2.2, 1.5)
    _panel.ctn_t:removeAllChildren()
    _panel.ctn_t:addChild(headSprite)
    _panel.ctn_t:addChild(frameSprite)
end

function WuXingPubTeamEmbattleView:updateBubbleUI(_ctn)
    local cx = _ctn:getPositionX()
    local cy = _ctn:getPositionY()
    local params = {
        pos = {x = cx - 20, y = cy},
        chat = GameConfig.getLanguage("#tid_pvp_des006"),
        appear = 10,
        display = 60,
        interval = 90,
    }
    local bubbleUI = FuncCommUI.regesitWorldBubbleView(params, _ctn, true)
    return bubbleUI
end

function WuXingPubTeamEmbattleView:updatePvpBubbleStatus()
    local tempTeamformation = TeamFormationModel:getTempFormation() 
    if not tempTeamformation.energy or table.length(tempTeamformation.energy) == 0 then
        if not self.bubbleUI then
            self.bubbleUI = self:updateBubbleUI(self.mc_szzs)
            self.bubbleUI:setVisible(true)
        else
            self.bubbleUI:setVisible(true)
        end
    elseif tempTeamformation.energy and table.length(tempTeamformation.energy) > 0 
        and self.bubbleUI then
        self.bubbleUI:setVisible(false)
    end
end

function WuXingPubTeamEmbattleView:updataPosData()
    if self.isMuilt then
        
    else    
    	self:initPosNum()	
    end
end

function WuXingPubTeamEmbattleView:initCountdown()
    if self.isMuilt then

    else
        self.mc_zhandou.currentView.txt_1:visible(false)
    end    
end


-- function WuXingPubTeamEmbattleView:showTreaList()
--     if TutorialManager.getInstance():isOutFormation() or TutorialManager.getInstance():isTrialFormation() then
--         return
--     end
--     WindowControler:showWindow("WuXingTreasureView", self.isMuilt, self.systemId)
-- end

function WuXingPubTeamEmbattleView:initBattleBtnType()
    if self.isMainView then
        self.mc_zhandou:visible(false)
    else
        if self.systemId == FuncTeamFormation.formation.pvp_attack 
            or self.systemId == FuncTeamFormation.formation.pve_elite
            or self.systemId == FuncTeamFormation.formation.trailPve1
            or self.systemId == FuncTeamFormation.formation.trailPve2
            or self.systemId == FuncTeamFormation.formation.trailPve3
            or self.systemId == FuncTeamFormation.formation.pve_tower
            or self.systemId == FuncTeamFormation.formation.missionBattlePvp
            or self.systemId == FuncTeamFormation.formation.missionBattleMonkey
            or self.systemId == FuncTeamFormation.formation.missionBattleFengYao
            or self.systemId == FuncTeamFormation.formation.missionBattleTianLei
            or self.systemId == FuncTeamFormation.formation.shareBoss
            or self.systemId == FuncTeamFormation.formation.guildGve
            or self.systemId == FuncTeamFormation.formation.wonderLand
            or self.systemId == FuncTeamFormation.formation.crossPeak
            or self.systemId == FuncTeamFormation.formation.guildBoss
            or self.systemId == FuncTeamFormation.formation.endless
            or self.systemId == FuncTeamFormation.formation.guildExplorePve
            or self.systemId == FuncTeamFormation.formation.guildExploreElite
        then
            --显示index----战斗按钮
            self.mc_zhandou:showFrame(1)
            --这些都是需要保存到本地的
            self.mc_zhandou.currentView:setTouchedFunc(c_func(self.doBattleClick, self))         
        elseif self.systemId == FuncTeamFormation.formation.guildBossGve then
            if self.isHost then
                --多人战斗 房主显示战斗按钮
                self.mc_zhandou:showFrame(1)
                self.mc_zhandou.currentView:setTouchedFunc(c_func(self.doMultiBattleClick, self))
            else
                --多人战斗 非房主显示准备按钮
                self.mc_zhandou:showFrame(3)
                self.mc_zhandou.currentView:setTouchedFunc(c_func(self.doBattlePrepare, self))
            end
        else
            --这些是要上传到服务器的
            --显示确定按钮
            self.mc_zhandou:showFrame(2)
            self.mc_zhandou.currentView:setTouchedFunc(c_func(self.doFormationClick,self))
        end
        self.mc_zhandou.currentView.txt_1:visible(false)
    end

    -- if FuncCommon.isSystemOpen("fivesoul") then
    --     self.panel_fivesoul:visible(true)
    --     self.panel_fivesoul:registerBtnEff()
    --     self.panel_fivesoul:setTouchedFunc(c_func(self.enterWuLingUp,self))
    --     local tempType = WuLingModel:checkRedPoint()  
    --     self.panel_fivesoul.panel_red:visible(tempType)
    -- else    
    --     self.panel_fivesoul:visible(false)
    -- end    
end

function WuXingPubTeamEmbattleView:doBattlePrepare()
    if self.isHostPrepared then
        -- WindowControler:showTips("队长已经点击开战,无需准备")
        return 
    end

    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        if TeamFormationModel:hasNowTeamNum(self.systemId) <= 0 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_005"))
        else
            local info = {state = 1}
            TeamFormationServer:sendFinishTeamFormation(info)
        end
    end
end

function WuXingPubTeamEmbattleView:cancelBattlePrepare()
    if self.isHostPrepared then
        -- WindowControler:showTips("队长已经点击开战，无法取消准备")
        return 
    end

    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        local info = {state = 0}
        TeamFormationServer:sendFinishTeamFormation(info)
    end
end

function WuXingPubTeamEmbattleView:prepareForBattle(event)
    local fmt = TeamFormationModel:getTempFormation()
    local params = event.params.params
    local info = json.decode(params.info)
    if not self.isHost then
        if params.rid ~= UserModel:rid() then
            if tostring(info.state) == "1" then
                self.isHostPrepared = true
                -- WindowControler:showTips("队长点击了 进入战斗")
                -- EventControler:dispatchEvent(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW,
                --     {formation = fmt,systemId = self.systemId, params = self.paramsData})
            end
        else
            if tostring(info.state) == "1" then
                self.isMatePrepared = true
                self.mc_zhandou:showFrame(4)
                self.mc_zhandou.currentView:setTouchedFunc(c_func(self.cancelBattlePrepare, self))
            else
                self.isMatePrepared = false
                self.mc_zhandou:showFrame(3)
                self.mc_zhandou.currentView:setTouchedFunc(c_func(self.doBattlePrepare, self))
            end
        end            
    else
        if params.rid ~= UserModel:rid() then
            if tostring(info.state) == "1" then
                self.isMatePrepared = true
                -- WindowControler:showTips("对方已经准备好了")
                self.mc_1:showFrame(4)
                self.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_team_tips_003"))
            else
                self.isMatePrepared = false
                -- WindowControler:showTips("对方已经取消了准备")
                self.mc_1:showFrame(1)
                self.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_team_tips_001").."...")
            end
        else
            if tostring(info.state) == "1" then
                self.isHostPrepared = true
                -- WindowControler:showTips("队长点击了 进入战斗")
            end
        end       
    end
    
    self.mc_zhandou.currentView.txt_1:visible(false)
    TeamFormationModel:setMultiState(self.isHostPrepared, self.isMatePrepared)
end

function WuXingPubTeamEmbattleView:doMultiBattleClick()
    if not self.isMatePrepared then
        WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_004"))
    else
        if self.isHostPrepared then
            -- WindowControler:showTips("队长已经点击开战，无需再次点击开战")
            return 
        end

        if TeamFormationModel:hasNowTeamNum(self.systemId) <= 0 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_005"))
        else
            local info = {state = 1}
            TeamFormationServer:sendFinishTeamFormation(info)
        end     
    end
end

function WuXingPubTeamEmbattleView:doBattleClick()
    if self.isMuilt then
        local params = {}
        params.battleId = tostring(TeamFormationMultiModel.roomId)
        TeamFormationServer:doLockFormation(params)
    else
        if self.systemId == FuncTeamFormation.formation.crossPeak then
            local currentSegment = tonumber(CrossPeakModel:getCurrentSegment())
            local newCrossPeakPlayMode = FuncCrosspeak.getPlayerModel()
            local oldCrossPeakPlayMode = TeamFormationModel:getCurrentCrossPeakPlayMode()
            local fightNumMax = CrossPeakModel:getFightNumMax()
            local fightInStageMax = CrossPeakModel:getFightInStageMax()
            local candidateNum = fightNumMax - fightInStageMax
            local tempFormation = TeamFormationModel:getTempFormation()
            
            if (tonumber(newCrossPeakPlayMode) == FuncCrosspeak.PLAYMODE.CACTUS and tonumber(newCrossPeakPlayMode) ~= tonumber(oldCrossPeakPlayMode))
                or (tonumber(oldCrossPeakPlayMode) == FuncCrosspeak.PLAYMODE.CACTUS and tonumber(newCrossPeakPlayMode) ~= tonumber(oldCrossPeakPlayMode)) then
                return 
            end

            if TeamFormationModel:isCharInFormationOrCandidate() == false then
                WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2008"))
                return
            elseif TeamFormationModel:chkFormationIsFull(fightInStageMax, tempFormation) == false then
                WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2007"))
                return
            elseif TeamFormationModel:chkCandidateIsFull(candidateNum, tempFormation) == false then
                --如果候补阵容未满 就发消息弹出候补框
                EventControler:dispatchEvent(TeamFormationEvent.CANDIDATE_NOT_FULL)
                WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_crosspeak_tips_2006", candidateNum))
                return
            end
        end

        if self.systemId == FuncTeamFormation.formation.endless then
            if not TeamFormationModel:canEnterBattle() then
                WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_012"))
                return
            end

            if not TeamFormationModel:isPartnerInFormation("1") then
                WindowControler:showTips(GameConfig.getLanguage("#tid_team_tips_013"))
                return
            end

            local fmt = TeamFormationModel:getTempFormation()
            local params = {formation = fmt,systemId = self.systemId, params = self.paramsData}
            local tipStr = GameConfig.getLanguage("#tid_team_tips_014")
            if not TeamFormationModel:checkEndlessFormationIsFull() then
                WindowControler:showWindow("WuXingBattleConfirmView", params, tipStr)
                return
            end    
        end

        if self.systemId == FuncTeamFormation.formation.crossPeak then
            local params = {}
            params.id = self.systemId
            params.formation = TeamFormationModel:getTempFormation()
            TeamFormationServer:doFormation(params,c_func(self.enterCrossPeakMatch,self)) 
        elseif self.systemId ~= FuncTeamFormation.formation.pve_tower then

            if TeamFormationModel:getNowEmptyTeamNum() then
                WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2009"))
                return
            end
            --发送开始战斗消息
            local fmt = TeamFormationModel:getTempFormation()
            -- dump(fmt,"走完布阵进入战斗前的阵型")
            if tonumber(self.systemId) == FuncTeamFormation.formation.wonderLand then
                for i = 2, 6, 1 do
                    local partnerId = tostring(fmt.partnerFormation["p"..i].partner.partnerId)
                    if partnerId ~= "0" and FuncWonderland.isWonderLandNpc(partnerId) then
                        fmt.partnerFormation["p"..i].partner.partnerId = "0"
                        fmt.partnerFormation["p"..i].partner.rid = nil
                    end
                end
            end

            EventControler:dispatchEvent(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW,
                {formation = fmt,systemId = self.systemId, params = self.paramsData})
            
            TeamFormationModel:saveLocalData()

            if self.systemId == FuncTeamFormation.formation.pvp_attack then
                EventControler:dispatchEvent(TeamFormationEvent.PVP_ATTACK_CHANGED)
            end                      
        else
            local _currX,_currY = TowerMapModel:getCharGridPos()
            local serverParams = {}
            serverParams.x = self.paramsData.x
            serverParams.y = self.paramsData.y
            serverParams.currX = _currX
            serverParams.currY = _currY
            serverParams.formation = TeamFormationModel:getTempFormation()

            if TeamFormationModel:getNowEmptyTeamNum() then
                WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2009"))
                return
            end
            EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ENTER_BATTLE)
            TeamFormationModel:saveLocalData()
            if self.isNpc then
                serverParams.eventId = self.paramsData.eventId
                TowerServer:attackNpc(serverParams,c_func(self.doFormationCallBack,self))
            else
                serverParams.star = self.paramsData.star
                TowerServer:attackMonster(serverParams,c_func(self.doFormationCallBack,self))
            end
        end 
    end       
end

-- 保存布阵到服务端返回后 再将阵型保存本地 进入匹配界面 并关闭布阵主界面
function WuXingPubTeamEmbattleView:enterCrossPeakMatch()
    TeamFormationModel:saveLocalData()
    EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_TRIGGER_MATCH_EVENT)
    EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
end

function WuXingPubTeamEmbattleView:doFormationCallBack(event)
    if event.error then
        echoError("返回数据出错了=============")
    else
       if self.systemId ~= FuncTeamFormation.formation.pve_tower then
            -- TODO 需要配置多语言表
            WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_009"))
            TeamFormationModel:saveLocalData()
            EventControler:dispatchEvent(TeamFormationEvent.PVP_DEFENCE_CHANGED)
            EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
       else
            TowerMainModel:saveMonterData(self.paramsData)
            local battleInfoData = BattleControler:turnServerDataToBattleInfo( event.result.data.battleInfo )
            EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
            BattleControler:startBattleInfo(battleInfoData)
        end
    end    
end

function WuXingPubTeamEmbattleView:doFormationClick()
    --初始化阵容

    if self.systemId == FuncTeamFormation.formation.pvp_defend then
        local params = {}
        params.id = tostring(self.systemId)
        params.formation = TeamFormationModel:getTempFormation()
        local energy = FuncTeamFormation.filterPvpFormation(params.formation)
        params.formation.energy = energy
        TeamFormationServer:doFormation(params,c_func(self.doFormationCallBack,self) )
    else
        local index = 1
        if self.zhenrong == FuncTeamFormation.formation.noPve then
            index = 2
        end
        TeamFormationModel:saveLocalData(self.systemId,index)
        -- TODO 需要配置多语言表
        WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_009"))
        if self.systemId == FuncTeamFormation.formation.pve then  
            EventControler:dispatchEvent(TeamFormationEvent.TEAMFORMATIONEVENT_CHANGE_TEAMFORMATION)
            local hasIdlePosition = TeamFormationModel:hasIdlePosition()
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {redPointType = HomeModel.REDPOINT.DOWNBTN.WORLD, isShow = hasIdlePosition})
        end
        if self.systemId == FuncTeamFormation.formation.pve 
            or self.systemId == FuncTeamFormation.formation.pvp_defend then
            local params = {}
            params.id = self.systemId
            params.formation = TeamFormationModel:getFormation(self.systemId)
            TeamFormationServer:doFormation(params,function()
                EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
            end)
         end   
        -- EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
    end
    
end

function WuXingPubTeamEmbattleView:updateFormationState()
    local state = TeamFormationMultiModel:getFormationLockState()
    if state == 0 then
        self.mc_zhandou:showFrame(1)    
    elseif state == 1 then
        self.mc_zhandou:showFrame(3)
    end
    self.mc_zhandou.currentView:setTouchedFunc(c_func(self.doBattleClick,self))
end

function WuXingPubTeamEmbattleView:doVoiceChat()
    echo("语音聊天功能")
end

--点击了喇叭
function WuXingPubTeamEmbattleView:doVoiceClick()
    local vFrame = tonumber(LS:prv():get(StorageCode.realTime_voice,1))
    if vFrame == 1 then
       vFrame = 2
    else
        vFrame = 1
    end

    self.mc_2:showFrame(vFrame)
    LS:prv():set(StorageCode.realTime_voice, vFrame)
    local isOpen = vFrame == 1 and true or false 
    ChatShareControler:updateMicOrSpeak(2, isOpen)
end

--点击了麦克
function WuXingPubTeamEmbattleView:doMicClick()
    local micFrame = tonumber(LS:prv():get(StorageCode.realTime_mic,1))
    if micFrame == 1 then
       micFrame = 2
    else
        micFrame = 1
    end
    self.mc_3:showFrame(micFrame)
    LS:prv():set(StorageCode.realTime_mic,micFrame)
    local isOpen = micFrame == 1 and true or false 
    ChatShareControler:updateMicOrSpeak(1, isOpen)
end

function WuXingPubTeamEmbattleView:doCommonChat()
    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        ChatModel:settematype("guildBossGve")
        WindowControler:showWindow("ChatMainView", 4)
    else
        ChatModel:settematype("trial")
        WindowControler:showWindow("ChatMainView", 4)
    end
    
end

function WuXingPubTeamEmbattleView:doQuickChat()
    if self.isOpenQuickChat then
        self.panel_chat:visible(false)
        self.panel_chat.panel_1:visible(false)
        self.isOpenQuickChat = false
    else       
        self.panel_chat:visible(true)
        self.panel_chat.panel_1:visible(false)
        self:loadQuickChatDatas()
        self.isOpenQuickChat = true
    end 
end

function WuXingPubTeamEmbattleView:loadQuickChatDatas()
    --多人聊天的内容数据
    local chatData = FuncTeamFormation.getQuickChatList()

    local createCellFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_chat.panel_1);
        self:updateQuickChatItem(view, itemData)
        return view
    end
    local updateCellFunc = function ( data,view )
        self:updateQuickChatItem(view, data)
    end

    self.chatScrollParams = {
        {
            data = chatData,
            createFunc = createCellFunc,
            perNums = 1,
            offsetX = 6,
            offsetY = 2,
            widthGap = 0,
            updateCellFunc = updateCellFunc,
            heightGap = 0,
            itemRect = {x = 0, y = 0, width = 220, height =30},
            perFrame = 5,
        }
        
    }
    self.panel_chat.scroll_1:styleFill(self.chatScrollParams)
    self.panel_chat.scroll_1:hideDragBar()
end

function WuXingPubTeamEmbattleView:updateQuickChatItem(view,data)
    --echoError("更新数据")
    view:visible(true)
    view.txt_1:setString(data.des)
    view:setTouchedFunc(c_func(self.doQuickChatItemClick,self,data))
end


function WuXingPubTeamEmbattleView:doQuickChatItemClick(data)
    if self.systemId == FuncTeamFormation.formation.guildBossGve then
        local params = {}
        params.battleId = self.battleId
        params.type = 3
        params.content = data.id
        TeamFormationServer:doFormationChat(params, nil)
        --关闭快捷聊天的按钮
        self:doCloseQuickChat()
    else
        local params = {}
        params.battleId = TeamFormationMultiModel:getRoomId()
        params.type = 3
        params.content = data.id
        TeamFormationServer:doFormationChat(params,nil)
        --关闭快捷聊天的按钮
        self:doCloseQuickChat()
    end

end

function WuXingPubTeamEmbattleView:doCloseQuickChat()
    self.panel_chat:visible(false)
    self.panel_chat.panel_1:visible(false)
    self.isOpenQuickChat = false
end

function WuXingPubTeamEmbattleView:multiFormationChat(e)
    --聊天内容
    local data = e.params.params.data
    -- dump(data,"客户端收到的聊天内容-----------------")

    self:setQiPaoChat(data)
    ChatServer:requestTeamMessage(e)
end

--[[
聊天气泡
]]
function WuXingPubTeamEmbattleView:setQiPaoChat(chatData)
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
    
    if id == UserModel:rid() then
        self.panel_chat1:stopAllActions()
        self.panel_chat1:setVisible(false)
        self.panel_chat1:setScale(0)
        self.panel_chat1.txt_1:setString(chatDes)
        self.isShowChat1 = true
    else
        self.panel_chat2:stopAllActions()
        self.panel_chat2:setVisible(false)    
        self.panel_chat2:setScale(0)
        self.panel_chat2.txt_1:setString(chatDes)
        self.isShowChat2 = true
    end

    local setVisible1 = function ()
        self.panel_chat1:setVisible(false)
        self.isShowChat1 = false
    end
    local setVisible2 = function ()
        self.panel_chat2:setVisible(false)
        self.isShowChat2 = false
    end

    if self.isShowChat1 then
        self.panel_chat1:setVisible(true)
        local act_sequence = act.sequence(
                                act.scaleto(0.2, 1),
                                act.delaytime(5),
                                act.scaleto(0.2, 0),
                                act.callfunc(setVisible1)
                            )
        self.panel_chat1:runAction(act._repeat(act_sequence))
    end

    if self.isShowChat2 then
        self.panel_chat2:setVisible(true)
        local act_sequence = act.sequence(
                                act.scaleto(0.2, 1),
                                act.delaytime(5),
                                act.scaleto(0.2, 0),
                                act.callfunc(setVisible2)
                            )
        self.panel_chat2:runAction(act._repeat(act_sequence))
    end
end

-- function WuXingPubTeamEmbattleView:showTreaData()
--     TeamFormationModel:getTreasurePosNature()
--     local params = {}
--     local tempPosX,tempPosY = self.panel_fb10:getPosition()
--     params.x = tempPosX
--     params.y = tempPosY
--     WindowControler:showWindow("WuXingAllTreasureView",params)
-- end

-- 情缘战斗tips提示
function WuXingPubTeamEmbattleView:initTextView()
    self.txt_lx:visible(false)
end

function WuXingPubTeamEmbattleView:enterWuLingUp()
    if FuncCommon.isSystemOpen("fivesoul") then
        WindowControler:showWindow("WuLingMainView")
    else
        -- TODO 需要配置多语言表
        WindowControler:showTips(GameConfig.getLanguage("tid_common_2033"))
    end    
end

function WuXingPubTeamEmbattleView:openClickView(event)
    if event.params.type then
        self:resumeUIClick()
    else
        self:disabledUIClick()
    end
end

function WuXingPubTeamEmbattleView:updateWuLingRed()
    if FuncCommon.isSystemOpen("fivesoul") then
        local tempType = WuLingModel:checkRedPoint()  
        self.panel_fivesoul.panel_red:visible(tempType)
    end    
end

-- 弹出仙术设置界面
function WuXingPubTeamEmbattleView:doClickSkillSetting()   
    WindowControler:showWindow("WuXingSkillSettingView", self.systemId)
    if self.bubbleUI then
        self.bubbleUI:setVisible(false)
    end   
end

return WuXingPubTeamEmbattleView;
