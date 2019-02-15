local AwakenView = class("AwakenView", UIBase);

local JDTYPE = {
    [1] = 2,
    [2] = 3,
    [3] = 5,
}

function AwakenView:ctor(winName,awakenId,callback,jindu,fromP)
    AwakenView.super.ctor(self, winName);
    self.awakenId = awakenId
    self.callBack = callback
    self.jindu = jindu
    self.isfromP = fromP
end

function AwakenView:loadUIComplete()
    self:registerEvent()
    self:initUI( )
    self:jinduInit( )
    self:playUIAction(1) 
    
end 
--UI_qixiahuanxing_donghua
-- 播放入场动画
function AwakenView:playUIAction( _type )
    if not self.UIActionAnim then
        self.UIActionAnim = self:createUIArmature("UI_qixiahuanxing","UI_qixiahuanxing_donghua", nil,false, GameVars.emptyFunc)
        local animUI = self.UIActionAnim:getBoneDisplay("layer1")
        self.mc_ccc:setPosition(0, 0)
        self.panel_bao:setPosition(0, 0)
        self.ctn_lyr:setPosition(0, 0)
        self.panel_zhushi:setPosition(0, 0)
        self.ctn_name:setPosition(0, 0)
        self.panel_sjhx:setPosition(0, 0)
        self.mc_yuan:setPosition(0, 0)
        self.panel_di:setPosition(0, 35)
        FuncArmature.changeBoneDisplay(animUI,"node1",self.mc_ccc)
        FuncArmature.changeBoneDisplay(animUI,"node2",self.panel_bao)
        FuncArmature.changeBoneDisplay(animUI,"node3",self.ctn_lyr)
        FuncArmature.changeBoneDisplay(animUI,"node4",self.panel_zhushi)
        FuncArmature.changeBoneDisplay(animUI,"node5",self.ctn_name)
        FuncArmature.changeBoneDisplay(animUI,"node6",self.panel_sjhx)
        FuncArmature.changeBoneDisplay(animUI,"node7",self.mc_yuan)
        FuncArmature.changeBoneDisplay(animUI,"node8",self.panel_di)
        -- FuncArmature.changeBoneDisplay(animUI,"node9",self.__bgView)
        
        self.ctn_animUI:removeAllChildren()
        self.ctn_animUI:addChild(self.UIActionAnim)
        self.UIActionAnim:setAllChildAniPlayOnce(  )

        -- local animUI1 = self.UIActionAnim:getBoneDisplay("diceng")
        -- animUI1:visible(false)
    end
    if _type == 1 then
        -- 入场
        self:playPtEffectAction( )
        self:delayCall(function ( ... )
            self:registClickClose(1, c_func( function()
                self:disabledUIClick(  )
                self:clickUiAction()
            end , self))
        end,3.5)
        
        -- 入场音效
        AudioModel:playSound(MusicConfig.s_guide_huanxingjiemian)

        self.UIActionAnim:runEndToNextLabel( 0,1 ,false,false,1)
    elseif _type == 2 then
        -- 退出UI
        self.UIActionAnim:playWithIndex(2,false,false)
        local animUI = self.UIActionAnim:getBoneDisplay("layer1")
        animUI:playWithIndex(2,false,false)
        self.UIActionAnim:doByLastFrame(false,false,function ( ... )
            animUI:visible(false)
            self.UIActionAnim:visible(false)
        end)
        self.UIBgAnim:playWithIndex(2,false,false)
        local childAnim = self.UIBgAnim:getBoneDisplay("layer1")
        childAnim:playWithIndex(2,false,false)
        self.UIBgAnim:doByLastFrame(false,false,function ( ... )
            childAnim:visible(false)
            self.UIBgAnim:visible(false)

            self:delayCall(c_func(self.hideComplete,self),0.01)

            -- self:hideComplete()
        end)
        self:startHide()
    end
end
function AwakenView:startBgAction(  )
    self.UIBgAnim = self:createUIArmature("UI_qixiahuanxing","UI_qixiahuanxing_beijing", nil,false, GameVars.emptyFunc)
    local childAnim = self.UIBgAnim:getBoneDisplay("layer1")
    FuncArmature.changeBoneDisplay(childAnim,"node9",self.__bgView)
    childAnim:runEndToNextLabel(0,1 ,false,false,1)
    self.UIBgAnim:setAllChildAniPlayOnce(  )
    childAnim:runEndToNextLabel( 0,1 ,false,false,1)
    self.ctn_animBg:removeAllChildren()
    self.ctn_animBg:addChild(self.UIBgAnim)
    self.__bgView:pos(-840 ,461)
    return 3
end

function AwakenView:initUI( )
    -- 当前奇侠id
    local partnerId = FuncGuide.getAwakenPartner(self.awakenId)
    local mode = FuncGuide.getAwakenMode(self.awakenId)
    -- 立绘
    local partnerLH = FuncPartner.getPartnerOrCgarLiHui(partnerId,nil,"ui")
    partnerLH:setScale(0.8)
    if tostring(partnerId) == "5002" then
        partnerLH:setScaleX(-0.8)
    elseif tostring(partnerId) == "5014" then
        partnerLH:setScaleX(-0.8)
        partnerLH:setPositionY(-100)
    end
    self.ctn_lyr:removeAllChildren()
    self.ctn_lyr:addChild(partnerLH)
    -- spine
    local partnerSp = FuncPartner.getHeroSpineByPartnerIdAndSkin( partnerId )  
    partnerSp:setScale(1.5)

    local maskSprite = display.newSprite(FuncRes.iconQixiaAwaken("partnerAwaken_zz"))
    -- headMaskSprite:setScale(5)
    maskSprite:pos(15,110)
    local _spriteIcon = FuncCommUI.getMaskCan(maskSprite,partnerSp)
    self.panel_di.ctn_zdr:removeAllChildren()
    self.panel_di.ctn_zdr:addChild(_spriteIcon)
    _spriteIcon:pos(-8,2)
    -- 描述
    local miaoshu = FuncGuide.getAwakenMiaoshu(self.awakenId)
    FuncCommUI.setVerTicalTXT({txt = self.panel_zhushi.txt_1,str = miaoshu})
    -- 姓名
    local namePath = FuncGuide.getAwakenNameSpr(self.awakenId)
    local nameSpr = FuncRes.iconQixiaAwaken( namePath )
    self.ctn_name:removeAllChildren()
    self.ctn_name:addChild(display.newSprite(nameSpr))

    --在前进1关即可唤醒李忆如
    -- 判断是否可合成
    local partnerData = FuncPartner.getPartnerById(partnerId)
    local panerName = GameConfig.getLanguage(partnerData.name)
    if tonumber(self.awakenId) == 102 then
        -- 单独处理
        self.panel_bao.mc_1:showFrame(3)
        local panel1 = self.panel_bao.mc_1.currentView
        panel1.txt_1:setString(GameConfig.getLanguage("#tid823"))
        panel1.txt_2:setString(panerName)
        self.mc_ccc:showFrame(3)
    else
        if PartnerModel:isCanCombienPartner(partnerId) then
            self.panel_bao.mc_1:showFrame(2)

            local panel = self.panel_bao.mc_1.currentView  
            panel.txt_1:setString(GameConfig.getLanguage("#tid_partner_awaken_001")..panerName)

            --底部提示
            self.mc_ccc:showFrame(2)
        else
            local maxOrder = FuncGuide.getAwakenType(self.awakenId)
            local currentOrder = FuncGuide.getAwakenOrder(self.awakenId)

            --底部提示


            if maxOrder == currentOrder and mode == 3 then
                self.panel_bao.mc_1:showFrame(3)
                local panel = self.panel_bao.mc_1.currentView
                local txtStr = ""
                local awakenId = tonumber(self.awakenId)
                if awakenId >= 113 and awakenId <= 115 then
                    txtStr = GameConfig.getLanguage("#tid6251")
                elseif awakenId >= 116 and awakenId <= 118 then
                    txtStr = GameConfig.getLanguage("#tid6252") 
                end

                panel.txt_1:setString(txtStr)
                panel.txt_2:setString(panerName)
            else
                self.mc_ccc:showFrame(1)
                self.panel_bao.mc_1:showFrame(1) 
                local panel1 = self.panel_bao.mc_1.currentView
                panel1.txt_1:setString(GameConfig.getLanguage("#tid_partner_awaken_002"))
                if mode == 2 then
                    panel1.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_003")..panerName)
                elseif mode == 3 then
                    local _str = string.format(GameConfig.getLanguage("#tid_partner_awaken_004"),panerName)
                    panel1.txt_2:setString(_str)
                end
                 local guan = self:getGuanNum( )
                if guan == 0 then
                    echoError("此时投放奇侠应该可合成应该")
                    guan = 1
                end
                if tonumber(self.awakenId) == 101 then
                    guan = 1
                end
                if guan >= 10 then
                    local t1,t2 = math.modf(guan/10);
                    panel1.mc_num:showFrame(2)
                    panel1.mc_num.currentView.mc_11:showFrame(t1+1)
                    local gewei = math.modf(t2*10+1);
                    panel1.mc_num.currentView.mc_12:showFrame(gewei)
                else
                    panel1.mc_num:showFrame(1)
                    panel1.mc_num.currentView.mc_1:showFrame(guan+1)
                end
            end
        end
    end
end

-- 通过拼图类型获得特效名
function AwakenView:getAwakenEffectName(ptType )
    local effctName = "UI_qixiahuanxing_yiban"
    if ptType == 1 then
        effctName = "UI_qixiahuanxing_quankai"
    elseif ptType == 2 then
        effctName = "UI_qixiahuanxing_yiban"
    elseif ptType == 3 then
        effctName = "UI_qixiahuanxing_sanfenzhiyi"
    elseif ptType == 5 then
        effctName = "UI_qixiahuanxing_wufenzhiyi"
    end
    return effctName
end
-- 获取旋转角度
function AwakenView:getEffectRotation(ptType,order)
    local jd = 0
    if ptType == 2 then
        jd = 180
    elseif ptType == 3 then
        jd = 120
    elseif ptType == 5 then
        jd = 72
    end
    local xz = (order - 1) * jd
    return xz
end
-- 获得最大order
function AwakenView:getMaxOrder( )
    local ptType = FuncGuide.getAwakenType(self.awakenId)  
    return ptType
end
--添加特效
function AwakenView:playPtEffect( )
    local name = "UI_qixiahuanxing"
    -- 拼图类型
    local ptType = FuncGuide.getAwakenType(self.awakenId) 
    -- 当前解锁进度
    local order = self.jindu or FuncGuide.getAwakenOrder(self.awakenId) 

    local partnerId = FuncGuide.getAwakenPartner(self.awakenId)
    local maxOrder = order
    if PartnerModel:isCanCombienPartner(partnerId) then
        maxOrder = self:getMaxOrder( )  
    end
    for i = order,maxOrder do
        local aspine = ViewSpine.new(name,{},nil,name)
        local effctName = self:getAwakenEffectName(ptType )
        local jd = self:getEffectRotation(ptType,i)
        aspine:setRotation(jd)
        aspine:playLabel(effctName,false,true)  

        local jdPanel = self.mc_yuan.currentView.panel_1
        local ctn = jdPanel.ctn_anim
        ctn:addChild(aspine)

        AudioModel:playSound(MusicConfig.s_guide_huanxingwanzhenghuanxing)

    end
end
--播放拼图特效逻辑
function AwakenView:playPtEffectAction( )
    -- 当前解锁进度
    local partnerId = FuncGuide.getAwakenPartner(self.awakenId)
    local order = self.jindu or FuncGuide.getAwakenOrder(self.awakenId) 
    local jdPanel = self.mc_yuan.currentView.panel_1

    local isCanComb = PartnerModel:isCanCombienPartner(partnerId)
    local maxOrder = self:getMaxOrder( ) 
    if not isCanComb then
        maxOrder = order
    end
    if self.isfromP then
        if order > 0 then
            jdPanel["panel_"..order]:visible(false)
            jdPanel["panel_p"..order]:visible(false)
            if jdPanel["panel_xian"..order] then
                jdPanel["panel_xian"..order]:visible(false)
            end
        end
    else
        self:delayCall(function (  )
            self:playPtEffect()
            self:delayCall(function (  )
                for i = order,maxOrder do
                    jdPanel["panel_"..i]:visible(false)
                    jdPanel["panel_p"..i]:visible(false)
                    if jdPanel["panel_xian"..i] then
                        jdPanel["panel_xian"..i]:visible(false)
                    end
                end
                
            end,25/GameVars.GAMEFRAMERATE)
            if isCanComb or tonumber(self.awakenId) == 102 then
                -- self:delayCall(function (  )
                --     local name = "UI_qixiahuanxing"
                --     local aspine = ViewSpine.new(name,{},nil,name)
                --     local effctName = "UI_qixiahuanxing_quankai"
                --     aspine:playLabel(effctName,false,true)  

                --     local jdPanel = self.mc_yuan.currentView.panel_1
                --     local ctn = jdPanel.ctn_anim
                --     ctn:addChild(aspine)
                -- end,50/GameVars.GAMEFRAMERATE)
            end
        end,1.0)
    end
    
end


function AwakenView:jinduInit( )
    -- 拼图类型
    local ptType = FuncGuide.getAwakenType(self.awakenId) 
    -- 当前解锁进度
    local order = self.jindu or FuncGuide.getAwakenOrder(self.awakenId) 
    
    self.mc_yuan:showFrame(ptType)

    local jdPanel = self.mc_yuan.currentView.panel_1

    local openStoryId = FuncGuide.getAwakenStory(self.awakenId)
    if FuncGuide.getAwakenOrder(self.awakenId) == 1 and tonumber(openStoryId) < 10100 then
        jdPanel["panel_1"]:visible(false)
    end
    local partnerId = FuncGuide.getAwakenPartner(self.awakenId)
    local data = FuncGuide.getAllAwakenByPartnerId( partnerId )
    for i,v in pairs(data) do
        if v.order >= order then
            -- 未解锁
            local _awakenId = v.awakenId

            local storyId = FuncGuide.getAwakenStory(_awakenId)
            local maxStoryID = FuncGuide.getAwakenMaxStory(_awakenId)
            local raidData = FuncChapter.getRaidDataByRaidId(storyId)
            local raidName = WorldModel:getRaidName(storyId)
            local chapter = FuncChapter.getChapterByStoryId(raidData.chapter)-- WorldModel:getChapterNum()
            local section = FuncChapter.getSectionByRaidId(storyId) --WorldModel:getChapterNum(FuncChapter.getSectionByRaidId(storyId))
            local strTip = ""
            local secTip = ""
            if not chapter or chapter == "" or chapter == 0 then
                strTip = " 通关序章 "
                secTip = "第"..section.."关"
            else
                strTip = "通过剧情"
                secTip = chapter.."-"..section
            end
            jdPanel["panel_"..v.order].txt_1:setString(strTip)

            jdPanel["panel_"..v.order].txt_2:setString(secTip)    
            local tuPath = FuncGuide.getAwakenPinTu(_awakenId)
            tuPath = FuncRes.iconQixiaAwaken(tuPath)
            local tuSpr = display.newSprite(tuPath)

            jdPanel["panel_"..v.order].mc_kuang:showFrame(1)
            local jdCtn = jdPanel["panel_"..v.order].mc_kuang.currentView.ctn_1
            local  pintu = FuncGuide.getAwakenPinTu(_awakenId)
            local spaceIcon = display.newSprite(FuncRes.iconQixiaAwaken(pintu))
            spaceIcon:scale(1.7)
            jdCtn:removeAllChildren()
            jdCtn:addChild(spaceIcon)

            jdPanel["panel_p"..v.order]:visible(true)
            if jdPanel["panel_xian"..v.order] then
                jdPanel["panel_xian"..v.order]:visible(true)
            end
        else
            -- 已解锁
            jdPanel["panel_"..v.order]:visible(false)
            jdPanel["panel_p"..v.order]:visible(false)
            if jdPanel["panel_xian"..v.order] then
                jdPanel["panel_xian"..v.order]:visible(false)
            end
        end
    end
    local partnerData = FuncPartner.getPartnerById(partnerId);
    local elementFrom = partnerData.elements
    self.mc_yuan.currentView.panel_jg.mc_tu2:showFrame(elementFrom)
    self.mc_yuan.currentView.panel_jg:visible(false)
    local needNum = partnerData.tity
    local haveNum = 0
    if tonumber(self.awakenId) == 101 then
        haveNum = needNum / 2
    elseif tonumber(self.awakenId) == 102 then
        haveNum = needNum
    else
        haveNum = ItemsModel:getItemNumById(partnerId)
    end
    self.mc_yuan.currentView.panel_jg.txt_1:setString(haveNum.."/"..needNum)
end

function AwakenView:getGuanNum( )
    local current = UserExtModel:getMainStageId()
    if tonumber(current) == 0 then
        current = "10002"
    end
    local max = FuncGuide.getAwakenMaxStory(self.awakenId)
    return WorldModel:getBetweenRaidNum(current, max)
end
 
function AwakenView:registerEvent()
    AwakenView.super.registerEvent();
end
-- 点击UI时的逻辑
function AwakenView:clickUiAction( )
    -- 判断当前奇侠是否可以合成
    local partnerId = FuncGuide.getAwakenPartner(self.awakenId)
    if PartnerModel:isCanCombienPartner(partnerId) then
        PartnerServer:partnerCombineRequest(partnerId,c_func(self.awakenServerCallBack,self))
    else
        if self.callBack then
            self.callBack()
        end
        
        self:playUIAction( 2 )
        -- self:awakenServerCallBack({})
    end
end
function AwakenView:awakenServerCallBack(event)
    if event.result then
        local partnerId = FuncGuide.getAwakenPartner(self.awakenId)
        local closeFunc = function ( ... )
            if self.callBack then
                self.callBack()
            end
            self:startHide() 
            -- self:hideComplete()
            self:delayCall(c_func(self.hideComplete,self),0.01)
        end
        -- WindowControler:showTutoralWindow("NewLotteryJieGuoCradView",{1,partnerId},nil,closeFunc)

        local param = {
            id = partnerId,
            skin = "1",
            file = nil,
            funFile = nil,
        }
        WindowControler:showTutoralWindow("PartnerSkinFirstShowView",param,closeFunc)
    end
end
function AwakenView:doHideCompleteFunc(  )
    return true
end

return AwakenView;
   