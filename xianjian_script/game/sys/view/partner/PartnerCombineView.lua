--伙伴碎片合成
--2016-12-21 19:57:00
--@Author:xiaohuaixong
local PartnerCombineView = class("PartnerCombineView",UIBase)
-- 新手引导需要特殊处理的奇侠
local GuidePartner = {
    "5003","5014","5002"
}
function PartnerCombineView:ctor(_name)
    PartnerCombineView.super.ctor(self,_name)
end

function PartnerCombineView:loadUIComplete()
    self:registerEvent()

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_title, UIAlignTypes.LeftTop)
    
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_progress, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_cc, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_lihui, UIAlignTypes.MiddleBottom)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_kong, UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_kong1, UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_taolun, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_pf, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_zj, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.LeftTop)
    
    -- FuncArmature.loadOneArmatureTexture("UI_lihuizhezhao", nil, true)
    EventControler:addEventListener("lihui_yidong", self.setLihuiPos, self)
    EventControler:addEventListener("lihui_yidong_end", self.setLihuiPosEnd, self)
    -- self.btn_taolun:getUpPanel().panel_red:setVisible(false)
    self.btn_taolun:setTap(function (  )
        EventControler:dispatchEvent(PartnerEvent.PARTNER_SHOW_PINGLUN_UI_EVENT)
    end)

    --皮肤按钮
    self.btn_pf:setTap(c_func(self.enterGarments,self))
    --奇侠传记
    self.btn_zj:setTouchedFunc(c_func(self.enterPartnerBiography, self))

    self.leftBtnPos = {
        {x = self.btn_taolun:getPositionX(), y = self.btn_taolun:getPositionY()}, 
        {x = self.btn_zj:getPositionX(), y = self.btn_zj:getPositionY()}, 
        {x = self.btn_pf:getPositionX(), y = self.btn_pf:getPositionY()}
    }
end

function PartnerCombineView:enterPartnerBiography()
    WindowControler:showWindow("BiographyMainView", self.data.id)
end

--左下角按钮 更新与加载
function PartnerCombineView:updateLeftButtons()
    local showBtns = {}
    local width1 = 70
    local width2 = 80
    -- 判断是否开启
    self.btn_taolun:setVisible(true)
    table.insert(showBtns, self.btn_taolun)

    local partnerCfg = FuncPartner.getPartnerById(self.data.id)
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.BIOGRAPHY) and partnerCfg.biography then
        self.btn_zj:setVisible(true)           
        self:updateBiographyStatus()
        table.insert(showBtns, self.btn_zj)
    else
        self.btn_zj:setVisible(false)
    end

    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNERSKIN) then
        local data = FuncPartnerSkin.getValidPartnerSkins(tostring(self.data.id))
        if data and table.length(data) > 0 then
            self.btn_pf:visible(true)
            table.insert(showBtns, self.btn_pf)
        else
            self.btn_pf:visible(false)
        end
    else
        self.btn_pf:visible(false)
    end 

    for i,v in ipairs(showBtns) do
        v:pos(self.leftBtnPos[i].x, self.leftBtnPos[i].y)
    end

    self.btn_pf:getUpPanel().panel_red:visible(false)
    self.btn_taolun:getUpPanel().panel_red:visible(false)
end

--更新奇侠传记按钮状态
function PartnerCombineView:updateBiographyStatus()
    if BiographyModel:hasPickUpTask(self.data.id) then
        self.btn_zj:getUpPanel().mc_1:showFrame(2)
    else
        self.btn_zj:getUpPanel().mc_1:showFrame(1)
    end

    self.btn_zj:getUpPanel().panel_red:visible(false)
end


function PartnerCombineView:updateUIWithPartner(data)
    self.data = data
    self.id = data.id
    self:updataView()
    self:refreshBtn( )
    -- self:pfBtnShow()
    self:updateLeftButtons()
end

function PartnerCombineView:registerEvent()
    PartnerCombineView.super.registerEvent(self)
    --道具变化监听
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.notifyItemChangeEvent,self)
end
--邀请事件
function PartnerCombineView:yaoqingTap()
    local haveNum = ItemsModel:getItemNumById(self.id)
    local needNum = self.data.tity

    if haveNum >= needNum then --可以邀请
        PartnerServer:partnerCombineRequest(self.id,c_func(self.onCombineEvent,self,self.id))
        FuncPartner.playPartnerCombineSound( )
    else
        if table.isValueIn(GuidePartner,tostring(self.id)) then
            local awakenId = nil
            local data = FuncGuide.getAwakenData( ) 
            local storyId = UserExtModel:getMainStageId()
            echo("当前解锁关卡 === ",storyId)
            local currentId = nil
            local jindu = 0
            for i ,v in pairs(data) do
                if tostring(v.partnerId) == tostring(self.id) then
                    if not awakenId then
                        awakenId = v.awakenId
                    end
                    if not currentId then
                        currentId = tonumber(v.copy)
                    end
                    if tonumber(storyId) >= tonumber(v.copy) and currentId <= tonumber(v.copy) then
                        currentId = tonumber(v.copy)
                        awakenId = v.awakenId
                        jindu = v.order
                    end
                end
            end
            WindowControler:showWindow("AwakenView",tostring(awakenId),nil,jindu,true)
        else
            self:clickButtonGetSource(self.id)
        end    
        
        -- WindowControler:showTips("命魂不足，去获取")
    end
end
--碎片合成反馈
function PartnerCombineView:onCombineEvent(_item,_event)
    if _event.result then
        -- WindowControler:showWindow("NewLotteryJieGuoCradView",{1,self.id})
        PartnerModel:showPartnerSkin(self.id)
        local _bool = FuncPartner.getPartnerRedPoint("zongkaiguai")
        PartnerModel:setRedPoindKaiGuanById(self.id,_bool)
        self:delayCall(function ()
            EventControler:dispatchEvent(PartnerEvent.PARTNER_HECHENG_SUCCESS_EVENT,_item)
           -- EventControler:dispatchEvent(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT,self.id)
        end,0.3)
    end
    
    
end

--更新UI
function PartnerCombineView:updataView()
    self.UI_title:updateUI(self.id)
    

    -- 立绘
    local ctnNode = self.ctn_lihui
    ctnNode:removeAllChildren()
--    FuncArmature.loadOneArmatureTexture("UI_lihuizhezhao", nil, true)
--    local lihuiBaseAnim = FuncArmature.createArmature("UI_lihuizhezhao_bianse",ctnNode, false, GameVars.emptyFunc)

    local sp = PartnerModel:initNpc(self.id):addto(ctnNode)

    self.lihuiPosX = sp:getPositionX()
    self.lihuiPosY = sp:getPositionY()
    self.currentLihui = sp

    local partnerId = self.data.id
    local cfgData = FuncPartner.getPartnerById(partnerId)
     --进度条
    local haveNum = ItemsModel:getItemNumById(partnerId)
    local needNum = cfgData.tity
    if haveNum >= needNum then
        FilterTools.clearFilter(sp)
    else
        FilterTools.setGrayFilter(sp)
    end

    self.panel_kong:setTouchedFunc(c_func(self.openPartnerInfoUI,self),nil,nil,nil,nil,false)
    self.panel_kong1:setTouchedFunc(c_func(self.openPartnerInfoUI,self),nil,nil,nil,nil,false)
    local showId = FuncPartner.getPartnerShowIdByPartnerId(self.id)
    if showId then
        self.btn_1:setVisible(true)
        self.btn_1:setTouchedFunc(function ()
                local controler = MiniBattleControler.getInstance()
                controler:showMiniBattle(showId)       
            end)
    else
        self.btn_1:setVisible(false)
    end
    
end
-- 刷新按钮
function PartnerCombineView:refreshBtn( )
    local partnerId = self.id
    local cfgData = FuncPartner.getPartnerById(partnerId)
     --进度条
    local haveNum = ItemsModel:getItemNumById(partnerId)
    local needNum = cfgData.tity

    local _refreshBtn = function ( ... )
        self.mc_cc:showFrame(5)
        local btnYQ = self.mc_cc.currentView.btn_yq
        local progressPanel = self.mc_cc.currentView.panel_progress
        --进度条
        local progressBar = progressPanel.panel_hongneng.progress_green 
        progressBar:setPercent(haveNum/needNum*100)
        progressPanel.btn_1:visible(true)
        progressPanel.btn_1:setTap(c_func(self.clickButtonGetSource,self,partnerId))
        FilterTools.setGrayFilter(btnYQ)
        btnYQ:getUpPanel().panel_red:visible(false)
        progressPanel.txt_1:setString(haveNum.."/"..needNum)

        --邀请事件
        btnYQ:setTap(c_func(self.yaoqingTap,self))
    end
    if haveNum >= needNum then
        --可合成的
        self.mc_cc:showFrame(5)
        local btnYQ = self.mc_cc.currentView.btn_yq
        FilterTools.clearFilter(btnYQ)
        btnYQ:getUpPanel().panel_red:visible(true)


        btnYQ:setTap(c_func(self.yaoqingTap,self))
        -- self.mc_cc.currentView.panel_1:visible(false)
    else
        if cfgData.activity then
            local contion = string.split(cfgData.activity[1],",")
            if tonumber(contion[1]) == 1 then
                --合成的
                _refreshBtn()

                self.mc_cc.currentView.panel_1:visible(false)
            elseif tonumber(contion[1]) == 2 then
                --充值送的
                self.mc_cc:showFrame(2)
                self.mc_cc.currentView.btn_yq:setTouchedFunc(function ()
                        WindowControler:showWindow("ActivityFirstRechargeView")
                    end)
            elseif tonumber(contion[1]) == 3 then
                --登录给的
                self.mc_cc:showFrame(3)
                local panel = self.mc_cc.currentView.panel_1
                local onlineDay = HappySignModel:getOnlineDays()
                local leftDays = tonumber(contion[2])-onlineDay
                if leftDays > 0 then
                    panel.txt_1:setString(leftDays)
                    panel.txt_1:setVisible(true)
                    panel.txt_2:setVisible(true)
                    panel.txt_3:setVisible(true)
                else
                    --已满足登录天数
                    panel.txt_1:setString(0)
                    panel.txt_1:setVisible(false)
                    panel.txt_2:setVisible(false)
                    panel.txt_3:setVisible(false)
                end
                local goto7UI = function ( ... )
                    local a,b,c,d = FuncCommon.isSystemOpen(FuncHome.active_systemname[4])
                    if a then
                        WindowControler:showWindow("HappySignView")
                    else
                        WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_003")..d) 
                    end
                end
                self.mc_cc.currentView.btn_yq:setTap(goto7UI)
            elseif tonumber(contion[1]) == 4 then
                --通关的
                self.mc_cc:showFrame(1)

                self.mc_cc.currentView.panel_1:visible(true)
                local raidData = FuncChapter.getRaidDataByRaidId(contion[2])
                local raidName = GameConfig.getLanguage(raidData.name)
                local chapter = FuncChapter.getChapterByStoryId(tostring(raidData.chapter))
                local section = FuncChapter.getSectionByRaidId(contion[2])
                local str = chapter.."-"..section..raidName
                self.mc_cc.currentView.panel_1.txt_3:setString(str)
            elseif tonumber(contion[1]) == 5 then
                --前往taptap评论
                self.mc_cc:showFrame(4)
                local gotoPingLun = function ( ... )
                    LoginControler:fetchGonggao()
                end
                self.mc_cc.currentView.btn_yq:setTap(gotoPingLun)
            end
            self.mc_cc.currentView.btn_yq:getUpPanel().panel_red:visible(false)
        else
            --合成的
            _refreshBtn()

            -- self.mc_cc.currentView.panel_1:visible(false)
        end
    end
    local progressPanel = self.mc_cc.currentView.panel_progress
    local progressBar = progressPanel.panel_hongneng.progress_green 
    if haveNum >= needNum then
        progressBar:setPercent(100)
    else
        progressBar:setPercent(haveNum/needNum*100)
    end
    
    progressPanel.btn_1:visible(true)
    progressPanel.btn_1:setTap(c_func(self.clickButtonGetSource,self,partnerId))
    progressPanel.txt_1:setString(haveNum.."/"..needNum)

    local spPanel = progressPanel.mc_kuang
    spPanel:scale(1.4)
    spPanel:setPositionY(20)
    spPanel:setPositionX(-20)
    FuncPartner.initQXSP( spPanel,partnerId )
end


--详情UI
function PartnerCombineView:openPartnerInfoUI(  )
    FuncPartner.playPartnerInfoSound( )
    -- WindowControler:showWindow("PartnerInfoUI",self.data.id)
    EventControler:dispatchEvent(PartnerEvent.PARTNER_CHANGEQINGBAO_EVENT)
end

--道具变化监听
function PartnerCombineView:notifyItemChangeEvent()
    self:updataView()
    self:refreshBtn()
end
--点击碎片的来源
function PartnerCombineView:clickButtonGetSource(_item)
    local partnerId = self.id
    local cfgData = FuncPartner.getPartnerById(partnerId)
    local needNum = cfgData.tity

    WindowControler:showWindow("GetWayListView", _item,needNum);
end

----------------------------------------------
-- 立绘滑动
----------------------------------------------
function PartnerCombineView:setLihuiPos(event)
    if event.params then
        local dis = event.params.dis
        self.currentLihui:setPositionX(self.lihuiPosX + dis)
    end
end
function PartnerCombineView:setLihuiPosEnd(event)
    if event.params then
        local _time = 0.25
        local _type = event.params._type
        if math.abs(_type) > 0 then
            self.currentLihui:runAction(act.spawn(
                    -- act.callfunc(c_func(visibleCall)),
                    act.moveto(_time , self.lihuiPosX - (500 * _type), self.lihuiPosY),
                    act.fadeout(_time)
                )
            )
        else
            self.currentLihui:runAction(
                act.moveto(_time , self.lihuiPosX - (500 * _type), self.lihuiPosY)
            )
        end
        
    end
end

function PartnerCombineView:pfBtnShow()
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNERSKIN) then
        local data = FuncPartnerSkin.getValidPartnerSkins(tostring(self.data.id))
        if data and table.length(data) > 0 then
            self.btn_pf:visible(true)
            -- 皮肤按钮
            self.btn_pf:setTap(c_func(self.enterGarments,self))
        else
            self.btn_pf:visible(false)
        end
    else
        self.btn_pf:visible(false)
    end
    self.btn_pf:getUpPanel().panel_red:visible(false)
    self.btn_taolun:getUpPanel().panel_red:visible(false)
end

function PartnerCombineView:enterGarments() 
    WindowControler:showWindow("GarmentMainView", tostring(self.data.id))
end

return PartnerCombineView
