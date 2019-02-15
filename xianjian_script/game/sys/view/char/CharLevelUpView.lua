--guan
--2016.12.26
--第三版主角升级界面

local CharLevelUpView = class("CharLevelUpView", UIBase);

function CharLevelUpView:ctor(winName, lvl,isInBattle)
    CharLevelUpView.super.ctor(self, winName);
    -- 升到的新等级
    self.newLevel = lvl;
    self.preLevel = UserModel:getlastLv();
    self.isInBattle = isInBattle;
end

function CharLevelUpView:loadUIComplete()
    EventControler:dispatchEvent(ShopEvent.SHOPEVENT_CHECK_SHOP_DATA)
	self:registerEvent();
    self:initUI();
end 

function CharLevelUpView:registerEvent()
	CharLevelUpView.super.registerEvent();
end

function CharLevelUpView:initUI()
    self:disabledUIClick();

    self.txt_bai:setVisible(false);
    self.txt_lv:setVisible(false);
    self.txt_bai:setVisible(false);
    self.txt_jixu:setVisible(false);

    self:initOpenSystemUI();
    self:showArmature(); 

    AudioModel:playSound(MusicConfig.s_com_lvl_up);

    if BattleControler:isInBattle() then
        EventControler:dispatchEvent(TutorialEvent.TUTORIAL_LEVEL_UP)
    end

    UserModel:lastLv(self.newLevel);

    echo("--resetLvUpresetLvUpresetLvUp--");
    UserModel:resetLvUp();
end

--升级后要显示的ui
function CharLevelUpView:initOpenSystemUI()
    --升级前最大的体力
    local preLvlNum = UserModel:getlastLv() or self.newLevel - 1;
    local preMaxSp = UserModel:getMaxSpLimitByLevel(preLvlNum);
    self._preMaxString = UIBaseDef:cloneOneView(self.txt_bai);
    self._preMaxString:setString(preMaxSp);
    self._preMaxString:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    --升级后最大体力
    local curMaxSp = UserModel:getMaxSpLimitByLevel(self.newLevel);
    self._curMaxString = UIBaseDef:cloneOneView(self.txt_lv);
    self._curMaxString:setString(curMaxSp);

    --升级后等级  
    self._curLvl = UIBaseDef:cloneOneView(self.txt_lv);
    self._curLvl:setString(self.newLevel);

    --升级前等级
    self._preLvl = UIBaseDef:cloneOneView(self.txt_bai);

    self._preLvl:setString(preLvlNum);
    self._preLvl:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)

    --升级后的体力 
    local curSp = UserExtModel:sp();
    self._curSp = UIBaseDef:cloneOneView(self.txt_lv);
    self._curSp:setString(curSp);

    --升级前的体力
    local spAdd = FuncChar.getCharLevelUpSp(self.newLevel, preLvlNum);
    preSp = curSp - spAdd;
    if preSp < 0 then
        -- echoError("\n\ncurSp==", curSp, "preSp==", preSp, "preLvlNum==", preLvlNum, "self.newLevel==", self.newLevel)
        preSp = 0
    end
    self._preSp = UIBaseDef:cloneOneView(self.txt_bai);
    self._preSp:setString(preSp);
    self._preSp:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)


    -- 开启预览
    local cfgData = FuncChar.getCharLevelConfig()
    cfgData = cfgData[tostring(self.newLevel)]
    if cfgData and cfgData.icon and cfgData.name and cfgData.des then
        self.panel_x1:visible(true)
        for i=1,3 do
            if cfgData.icon[i] then
                local panel = self.panel_x1["panel_"..i]
                panel:visible(true)
                local iconPath = FuncRes.iconSys(cfgData.icon[i])
                local iconSp = display.newSprite(iconPath)
                panel.ctn_x1:removeAllChildren()
                iconSp:scale(0.6)
                panel.ctn_x1:addChild(iconSp)
                local name = GameConfig.getLanguage(cfgData.name[i])
                panel.txt_1:setString(name) 
                local des = GameConfig.getLanguage(cfgData.des[i])
                panel.txt_2:setString(des)
                local desOpen = GameConfig.getLanguage(cfgData.desOpen[i])
                panel.txt_3:setString(desOpen)
            else
                self.panel_x1["panel_"..i]:visible(false)
            end
        end
    else
        self.panel_x1:visible(false)
    end

    self.panel_x1:setOpacity(0)
end

function CharLevelUpView:showArmature()
    FuncCommUI.addBlackBg(self.widthScreenOffset,self._root);

    self.panel_x1:runAction(cc.FadeIn:create(0.5))

    local mainAni = nil;
    -- if UserModel:isNewSystemOpenByLevel( self.newLevel ) == true then 
    mainAni = self:createUIArmature("UI_zhujue_levelup", "UI_zhujue_levelup", self.ctn_ani, 
            false, GameVars.emptyFunc);   
    if tonumber(UserModel:avatar()) == 101 then
        mainAni:setPositionX(85) 
    else
        mainAni:setPositionX(61) 
    end  
    -- 暂时屏蔽跳转
    self.mainAni = mainAni
    -- self:tiaozhuanAction()
    self.panel_go:setVisible(false)
    self.btn_qw:setVisible(false)
    
    -- 遮罩
    local zhezhaoPath= FuncRes.iconOther("global_img_jsza")
    local zhezhaoSp = display.newSprite(zhezhaoPath)   
    zhezhaoSp:setAnchorPoint(cc.p(0.5,0.5))
    zhezhaoSp:setPosition(-10,-5)
    zhezhaoSp:setScale(1.1)
    FuncArmature.changeBoneDisplay(mainAni, "node10", zhezhaoSp); 

    --升级啦
    -- local lvUpAni = mainAni:getBoneDisplay("sjl");  
    -- lvUpAni:playWithIndex(0, 0); 

    --猪脚小人   
    -- local charAni = mainAni:getBoneDisplay("zj");
    -- charAni:playWithIndex(0, 0);  

    -- local charPath = FuncRes.iconChar(tonumber( UserModel:sex() ));

    -- local charSp = display.newSprite(charPath);
    -- charSp:setPosition(0, 0);
    local avatarId = UserModel:avatar();
    --UserExtModel:garmentId()
    local heroAnim = FuncGarment.getGarmentLihui( "",avatarId,nil,nil,"ui")
    heroAnim:setPositionX(-150)
    heroAnim:setPositionY(-350)  
    heroAnim:setScaleX(-1.3)
    heroAnim:setScaleY(1.3)

    local p1 = mainAni:getBoneDisplay("zhujue");    
    FuncArmature.changeBoneDisplay(p1, "layer1", heroAnim); 


    local posY = 16;
    local offetX1 = -175
    local offetX2 = -35
    --之前的猪脚等级
    self._preLvl:setPosition(offetX1, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node1", self._preLvl); 
    --现在主角等级
    self._curLvl:setPosition(offetX2, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node2", self._curLvl); 
    --之前的体力上限
    self._preMaxString:setPosition(offetX1, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node3", self._preMaxString); 
    --现在的体力上限
    self._curMaxString:setPosition(offetX2, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node4", self._curMaxString); 
    --之前的体力
    self._preSp:setPosition(offetX1, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node5", self._preSp); 
    --之后的体力
    self._curSp:setPosition(offetX2, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node6", self._curSp); 

    -- 子动画
    local charAni = mainAni:getBoneDisplay("di1");
    charAni:startPlay(true, true )
    
    --45帧的时候
    mainAni:registerFrameEventCallFunc(50, 1, function ( ... )
        self:aniOver();
    end);

end

-- 跳转按钮
function CharLevelUpView:tiaozhuanAction()
    local level = self.newLevel;
    local mainAni = self.mainAni;

    --是否开启新功能 可能生多级，开启一串新功能
    local sysArrays = UserModel:isNewSystemOpenInRange(self.preLevel, self.newLevel);
    --是否在战斗中
    local inBattle = BattleControler:isInBattle()

    --
    self.panel_go:setVisible(false)
    self.btn_qw:setVisible(false)

     -- 此时为空 说明没有推荐跳转
    local _node = display.newNode()
    FuncArmature.changeBoneDisplay(mainAni,"layer6",_node)
end

function CharLevelUpView:aniOver()
    self:resumeUIClick();
    self.txt_jixu:setVisible(false);

    self:setTouchedFunc(c_func(self.closeFunc, self,false));

    -- 如果一会有引导需要进行跳转，需要关掉扫荡界面，不然会阻挡剧情对话的显示
    local tutorialManager = TutorialManager.getInstance()
    if tutorialManager:isCurStepFirstStep() then
        local window = WindowControler:getWindow("WorldSweepListView")
        if window then
            window:startHide()
        end
    end
end

function CharLevelUpView:closeFunc(isTZ)
    self:startHide();
    --是否开启新功能 可能生多级，开启一串新功能
    local sysArrays = UserModel:isNewSystemOpenInRange(self.preLevel, self.newLevel);

    if #sysArrays ~= 0 then
        -- 改为判断当前引导步骤是否需要跳主城（是第一步）
        local isNeedJump = FuncGuide.isNeedJumpToHomeWhenSysOpen(sysArrays);
        local tutorialManager = TutorialManager.getInstance()
        if BattleControler:isInBattle() then -- 战斗中设置为跳转
            --echo("------self.isInBattle setisNeedJumpToHome----");
            if isNeedJump == true then 
                WindowControler:setisNeedJumpToHome(true);
            end 

            --如果是在战斗中 则直接销毁战斗
            FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
        else -- 非战斗中
            if tutorialManager:isCurStepFirstStep() then
                tutorialManager:doLevelJump(function()
                    -- 这里需要先打开屏蔽，并且不能写在goBackToHomeView的方法里，会影响其他步骤
                    WindowControler:setUIClickable(false)
                    WindowControler:goBackToHomeView(true)
                    PartnerModel:clearCombine()
                end)
            end
        end
    else
        if BattleControler:isInBattle() then
            FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
        end
    end 

    EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT);   
end

return CharLevelUpView;



















