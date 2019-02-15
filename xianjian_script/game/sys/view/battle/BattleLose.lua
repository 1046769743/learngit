local BattleLose = class("BattleLose", UIBase);

--[[
    self.panel_1,
    self.panel_2,
    self.panel_3.panel_1,
    self.panel_3.panel_2,
    self.panel_3.panel_3,
    self.panel_3.panel_4,
    self.panel_3.txt_1,
    self.panel_bg,
    self.panel_bg.scale9_bg,
    self.txt_1,
]]

function BattleLose:ctor(winName,params)
    BattleLose.super.ctor(self, winName);
    self.isUpgrade = false

    self.battleDatas = params
    
    self.result = self.battleDatas    

    self._clickIndex = 0
    self._lastClickTime = 0
    self._clickEffArr = {}
    self._pos = cc.p(0,0)

    --self.isLvUp = true
    if not LoginControler:isLogin() then
        self.isLvUp = false
    else
        if not BattleControler:checkIsPVP() then
            self.isLvUp = UserModel:isLvlUp()
        end
    end

    -- 战斗结算
    -- 特殊引导的标记，当此关失败时要指引玩家点按钮，但是不好融入引导功能，就直接写在这里
    self._spGuide = false

    -- 没弹过
    if tonumber(LS:prv():get(StorageCode.tutorial_battle_fail, 0)) == 0 then
        self._spGuide = true
    end
end

function BattleLose:addArt( )
    --显示蓝葵立绘
    local spine = ViewSpine.new("art_30022_lankui")
    spine:playLabel("stand")
    spine:setScaleX(-1)
    spine:pos(0,0)
    local lihuiAni = self.battleLoseAni:getBoneDisplay("layer10")
    FuncArmature.changeBoneDisplay(lihuiAni,"layer1",spine)  
end


function BattleLose:loadUIComplete()

    self.btn_1:setTap(c_func(self.doRankClick,self))
    self.btn_2:setTap(c_func(self.doReplayClick,self))

    FuncCommUI.setScale9Align(self.widthScreenOffset, self.btn_1,UIAlignTypes.RightTop ) -- 统计
    FuncCommUI.setScale9Align(self.widthScreenOffset, self.btn_2,UIAlignTypes.RightTop )--回放

    if BattleControler:checkIsPVP() then
        --echo("战斗失败-------PVp")
        AudioModel:playMusic(MusicConfig.s_pvp_lose, false)
        if TutorialManager.getInstance():isInTutorial() then
            self.btn_1:visible(false)
            self.btn_2:visible(false)
        else
            self.btn_1:visible(true)
            self.btn_2:visible(true)
        end

    else
        if TutorialManager.getInstance():isInTutorial() then
            self.btn_1:visible(false)
        end
        self.btn_2:visible(false)
        --echo("战斗失败 ==-==== 普通----")
        AudioModel:playMusic(MusicConfig.s_battle_lose, false)
    end
    -- WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor):addto(self, -2)
    -- 注册点击任意地方事件
    self:registClickClose(nil, c_func(self.pressClose, self))
    self.isUpgrade = false
    self:registerEvent();
    self:uiAdjust()
    self.battleLoseAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_shibai",self.ctn_big,false,GameVars.emptyFunc)
    self.battleLoseAni:setAllChildAniPlayOnce()
    self.battleLoseAni:pos(400,-180)
    -- local particalNode = FuncArmature.getParticleNode( "xiaxue" )
    
    -- self.ctn_1:addChild(particalNode)
    self:delayCall(c_func(self.addArt,self),0.3)


    FuncArmature.changeBoneDisplay(self.battleLoseAni,"layer9",self.txt_da1)
    self.txt_da1:pos(-280,0)
    -- self.txt_da1:setScale(0.24)
    -- FuncArmature.changeBoneDisplay(self.battleLoseAni,"layer11",self.txt_da2)
    -- self.txt_da2:pos(-20,40)
    local bLabel = BattleControler:getBattleLabel()
    if bLabel == GameVars.battleLabels.missionBattlePve or
     bLabel == GameVars.battleLabels.missionMonkeyPve or
     bLabel == GameVars.battleLabels.guildGve or 
     BattleControler:checkIsCrossPeak()
      then
        -- self.txt_da2:visible(false)
        self.panel_1:visible(false)
        self.battleLoseAni:getBone("layer11"):visible(false)
        if BattleControler:checkIsCrossPeak() then
            self:loadCrossPeak()
        end

        self._spGuide = false

        return
    end
    -- 获取提升的数组[根据数组显示几个按钮]
    self._rArr = self:getJumpTypeArr()
    if #self._rArr == 0 then
        -- self.txt_da2:visible(false)
        self.panel_1:visible(false)
        self.txt_da2:visible(false)
        self.battleLoseAni:getBone("layer11"):visible(false)

        self._spGuide = false

        return
    end

    local jType = self._rArr[1][1]
    self.panel_1.mc_1:showFrame(jType)
    self.panel_1.mc_2:showFrame(jType)
    self.panel_1:setTouchedFunc(c_func(self.upPowerClick, self,1));
    -- 如果有特殊指引，处理一下
    if self._spGuide then
        -- 为了点击 提高层级
        self.panel_1:zorder(200)

        LS:prv():set(StorageCode.tutorial_battle_fail, 1)
        local box = self.panel_1:getContainerBox()
        self._pos = cc.p(box.width/2,-box.height/2)
        local arrow = self:createUIArmature("UI_main_img_shou", "UI_main_img_shou_sz",self.panel_1,true,GameVars.emptyFunc)
        arrow:visible(false)
        arrow:setPosition(self._pos)

        -- --对话结束的回调
        local onUserAction = function(ud)
            if ud.step == -1 and ud.index == -1 then
               arrow:visible(true)
            end
        end
        -- 覆盖一下可能错误设置的回调        
        PlotDialogControl:setAfterOrderCallBack(GameVars.emptyFunc)

        PlotDialogControl:showPlotDialog("40036", onUserAction)
    end

    -- -- local fram = #self._rArr >= 3 and 3 or #self._rArr
    -- local fram = 2 --只有一个跳转、并且居中处理,下方的i从2开始
    -- self.mc_tisheng:showFrame(fram)
    -- local tmpView = self.mc_tisheng.currentView
    -- tmpView.panel_1:visible(false)
    -- for i=2,fram do
    --     local jType = self._rArr[i][1]
    --     tmpView["panel_"..i].mc_1:showFrame(jType)
    --     tmpView["panel_"..i].mc_2:showFrame(jType)
    --     tmpView["panel_"..i]:setTouchedFunc(c_func(self.upPowerClick, self,i));
    -- end
    -- BattleControler.gameControler:doBattleEndCampDie(1)
end
function BattleLose:upPowerClick(index)
    local tmp = self._rArr[index]
    BattleControler:setjumpType(tmp[1],tmp[2])

    -- 这种情况下在这里跳
    if self._spGuide then
        self:showOther()
        self:delayCall(function( )
            self:startHide()
        end, 0.5)
    end
end
function BattleLose:loadCrossPeak( )
    self.battleLoseAni:getBone("layer9"):visible(false)

    local view = WindowsTools:createWindow("BattleCrossPeakResult",self.battleDatas):addto(self)
end

-- 根据伙伴id数组、类型返回是否可以提升
function BattleLose:isCanUpgradeByType(pTbl,pType )
    for k,v in pairs(pTbl) do
        --升级
        if pType == Fight.jump_to_Partner_Level and PartnerModel:isShowUpgradeRedPoint(v)  then
            return true,v
        end
        -- 升品
        if pType == Fight.jump_to_Partner_Quality and PartnerModel:isShowQualityRedPoint(v) then
            return true,v
        end
        --升星
        if pType == Fight.jump_to_Partner_Star and PartnerModel:isShowStarRedPoint(v) then
            return true,v
        end
    end
    return false
end
-- 获取可跳转提升按钮数据
function BattleLose:getJumpTypeArr( ... )
    local tmpArr = {}
    if not LoginControler:isLogin() then
        return tmpArr
    end
    -- 引导中不给任意跳转
    if TutorialManager.getInstance():isInTutorial() then
        return tmpArr
    end
    -- 仙盟探索失败不给跳转
    if GuildExploreServer:checkIsInExplore() then
        return tmpArr
    end
    -- 伙伴升级>伙伴升品>提升法宝>提升主角>伙伴修炼>伙伴升星
    -- 保底提升主角
    local gId = UserExtModel:garmentId()
    local tmpTbl = BattleControler:getPartnerIds()
    if #tmpTbl > 0 then
        local bChech,pId =self:isCanUpgradeByType(tmpTbl,jump_to_Partner_Level)
        if bChech then
            table.insert(tmpArr,{Fight.jump_to_Partner_Level,pId})
        end
        bChech,pId = self:isCanUpgradeByType(tmpTbl,Fight.jump_to_Partner_Quality)
        if bChech then
            table.insert(tmpArr,{Fight.jump_to_Partner_Quality,pId})
        end
    end
    if TreasureNewModel:homeRedPointEvent() then
        table.insert(tmpArr,{Fight.jump_to_Treasure})
    end
    if CharModel:showRedPoint() then
        table.insert(tmpArr,{Fight.jump_to_Char,gId})
    end
    if #tmpTbl > 0 then
        local bChech,pId = self:isCanUpgradeByType(tmpTbl,Fight.jump_to_Partner_Star)
        if bChech then
            table.insert(tmpArr,{Fight.jump_to_Partner_Star,pId})
        end
    end
    return tmpArr
end


--[[
打开排名列表
]]
function BattleLose:doRankClick(  )
    if self:wrongClick() then return end

    local data = BattleControler.gameControler:getBattleAnalyze()
    --构建战斗数据
    WindowControler:showBattleWindow("BattleAnalyze",data)

end

--[[
重新播放
]]
function BattleLose:doReplayClick()
    if self:wrongClick() then return end

    self:startHide()
    BattleControler:replayLastGame(BattleControler._battleInfo,true)
end

--[[
界面适配
]]
function BattleLose:uiAdjust()
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_1,UIAlignTypes.RightTop )
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_2,UIAlignTypes.RightTop )
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.ctn_lankui,UIAlignTypes.RightBottom )
    -- FuncCommUI.setViewAlign(self.widthScreenOffset, self.txt_2,UIAlignTypes.MiddleBottom )


    -- self.btn_3:visible(false)
    -- self.btn_4:visible(false)

    -- self.panel_lose1:setScaleX(GameVars.width/GameVars.gameResWidth)


    -- FuncCommUI.setViewAlign(self.widthScreenOffset,  self.panel_lose1,UIAlignTypes.Left )
    -- self.panel_lose1:setAnchorPoint(cc.p(0.5,0.5))
    -- self.panel_lose1:pos(0,-40)

end




function BattleLose:registerEvent() 
    BattleLose.super.registerEvent()
    if BattleControler:checkIsPVP() then
        self.btn_1:setTap(function( )
            -- 此引导下只能点手指的地方
            if self:wrongClick() then 
                return 
            end
            WindowControler:showBattleWindow("BattleAnalyze",StatisticsControler:getStatisDatas())
        end)
        self.btn_2:setTap(function( )
            -- 此引导下只能点手指的地方
            if self:wrongClick() then 
                return 
            end

            self:startHide()
            BattleControler:replayLastGame(BattleControler._battleInfo,true)
        end)
    end
    
end


-- 退出战斗
function BattleLose:pressClose()
    -- 此引导下只能点手指的地方
    if self:wrongClick() then return true end
    
    if self.isUpgrade then
        
    end
    self:showOther()
    self:delayCall(function( )
        self:startHide()
    end, 0.5)

end

function BattleLose:wrongClick()
    local curTime = os.clock()
    if curTime - self._lastClickTime > 0.1 then
        self._lastClickTime = curTime

        local clickEffArr = self._clickEffArr
        local getClickkEff = function ( index )
            if not clickEffArr[index] then
                clickEffArr[index] = self:createUIArmature("UI_qiangzhitishi","UI_qiangzhitishi_tishi",self.panel_1,false,GameVars.emptyFunc)

            end

            local ani = clickEffArr[index]
            ani:visible(true)
            ani:playWithIndex(0, false)
            ani:doByLastFrame(false, true)
            ani._showTime = curTime
            return ani
        end

        local clickIndex = self._clickIndex
        clickIndex = clickIndex%3 +1
        self._clickIndex = clickIndex

        local ani = getClickkEff(clickIndex)
        ani:setPosition(self._pos)
    end

    return self._spGuide
end

function BattleLose:hideComplete()
    BattleLose.super.hideComplete(self)
    --FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
end
function BattleLose:showOther( )
    if not self.isLvUp then
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    else
        WindowControler:showBattleWindow("CharLevelUpView", UserModel:level(),true);
    end
end


return BattleLose;
