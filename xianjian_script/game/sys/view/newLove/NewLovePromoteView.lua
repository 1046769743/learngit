-- 情缘激活  提升  动画类

local NewLovePromoteView = class("NewLovePromoteView", UIBase);

function NewLovePromoteView:ctor(winName, loveId, txtArr, loveLevel)
    NewLovePromoteView.super.ctor(self, winName)
    self.loveId = loveId
    self.txtArr = txtArr
    self.loveLevel = loveLevel
    echo("___________ 情缘提升动画 ___________")
    echo("loveId ====== ",loveId)
    dump(txtArr,"txtArr ======")
    echo("loveLevel ========= ",loveLevel)
end

function NewLovePromoteView:loadUIComplete()
    self:registerEvent()
    self:initViewAlign()
    self:initData()
end 

function NewLovePromoteView:registerEvent()
    NewLovePromoteView.super.registerEvent(self)
        
end

function NewLovePromoteView:initViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_lovetxtbig, UIAlignTypes.Middle)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_lovetxtbig2, UIAlignTypes.Middle)
end

function NewLovePromoteView:initData()
    self.propertyMap = {
        ["2"] = "生命",
        ["10"] = "攻击",
        ["11"] = "物防",
        ["12"] = "法防",
    }
    self.mainPartnerId = FuncNewLove.getLoveMainPartnerIdByLoveId(self.loveId)  -- 主伙伴id
    self.vicePartnerId = FuncNewLove.getLoveVicePartnerIdByLoveId(self.loveId)  -- 副伙伴id


    if self.loveLevel == 1 then
        local loveTipsDesc_first = FuncNewLove.getLoveLevelDescById(self.loveId,self.loveLevel-1)
        self.loveTipsDesc_first = GameConfig.getLanguage(loveTipsDesc_first)
        self.mc_lovetxtbig:showFrame(self.loveLevel)
        self.mc_lovetxtbig.currentView.txt_1:setString(self.loveTipsDesc_first)

        local loveTipsDesc_next = FuncNewLove.getLoveLevelDescById(self.loveId,self.loveLevel)
        self.loveTipsDesc_next = GameConfig.getLanguage(loveTipsDesc_next)
        self.mc_lovetxtbig2:showFrame(self.loveLevel+1)
        self.mc_lovetxtbig2.currentView.txt_1:setString(self.loveTipsDesc_next)
    else
        local loveTipsDesc_first = FuncNewLove.getLoveLevelDescById(self.loveId,self.loveLevel-1)
        self.loveTipsDesc_first = GameConfig.getLanguage(loveTipsDesc_first)
        self.mc_lovetxtbig:showFrame(self.loveLevel)
        self.mc_lovetxtbig.currentView.txt_1:setString(self.loveTipsDesc_first)

        local loveTipsDesc_next = FuncNewLove.getLoveLevelDescById(self.loveId,self.loveLevel)
        self.loveTipsDesc_next = GameConfig.getLanguage(loveTipsDesc_next)
        self.mc_lovetxtbig2:showFrame(self.loveLevel+1)
        self.mc_lovetxtbig2.currentView.txt_1:setString(self.loveTipsDesc_next)
    end

    local str = "<color=da611a>"..self.txtArr[1].."<->"..self.txtArr[2]
    self.rich_1:setString(str)

    self:initEnterAni()
end

-- 播放动画
function NewLovePromoteView:initEnterAni()
    local startAni = self:createUIArmature("UI_qingyuan", "UI_qingyuan_zong", self.ctn_1, false, GameVars.emptyFunc)
    startAni:setAllChildAniPlayOnce()

    -- 立绘替换
    FuncArmature.changeBoneDisplay(startAni, "node_juese01", self.ctn_p1)
    FuncArmature.changeBoneDisplay(startAni, "node_juese02", self.ctn_p2)

    -- 名字替换
    FuncArmature.changeBoneDisplay(startAni, "node_ming01", self.txt_1)
    FuncArmature.changeBoneDisplay(startAni, "node_ming02", self.txt_2)

    -- 心 替换
    FuncArmature.changeBoneDisplay(startAni, "node_xin1", self.mc_lovetxtbig)
    FuncArmature.changeBoneDisplay(startAni, "node_xin2", self.mc_lovetxtbig2)

    -- 心的名字 替换
    FuncArmature.changeBoneDisplay(startAni, "node_zi01", self.mc_lovetxtbig.currentView.txt_1)
    FuncArmature.changeBoneDisplay(startAni, "node_zi02", self.mc_lovetxtbig2.currentView.txt_1)

    -- 属性字 替换
    FuncArmature.changeBoneDisplay(startAni, "node_zi", self.rich_1)

    local mainName = FuncPartner.getPartnerName(self.mainPartnerId)
    local viceName = FuncPartner.getPartnerName(self.vicePartnerId)
    self.txt_1:setString(mainName)
    self.txt_2:setString(viceName)
    self.txt_1:setPosition(9,25)
    self.txt_2:setPosition(9,25)

    local mainPartner = FuncPartner.getPartnerOrCgarLiHui(self.mainPartnerId)
    local vicePartner = FuncPartner.getPartnerOrCgarLiHui(self.vicePartnerId)

    self.ctn_p1:addChild(mainPartner)
    self.ctn_p2:addChild(vicePartner)
    mainPartner:setPosition(-250,80)
    vicePartner:setPosition(-900,90)
    mainPartner:setScale(0.75)
    vicePartner:setScale(0.75)

    self.mc_lovetxtbig:setPosition(0,0)
    self.mc_lovetxtbig2:setPosition(0,0)

    self.mc_lovetxtbig.currentView.txt_1:setPosition(-32,5)
    self.mc_lovetxtbig2.currentView.txt_1:setPosition(-32,5)

    self.rich_1:setPosition(30,22)

    startAni:registerFrameEventCallFunc(125,1,function ()
        local subAnim = startAni:getBoneDisplay("bao") ---- 子动画要停掉
        subAnim:pause()
        startAni:playWithIndex(1,true)
        self:registClickClose(-1, c_func( function()
            EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_ONE_LOVE_LEVEL_UP_GRADE,
                {loveId = self.loveId,lv = self.loveLevel,txtArr = self.txtArr})
            EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_ANIMATION_OVER_EVENT)
            self:startHide()
        end , self))
    end)
end


function NewLovePromoteView:deleteMe()
    -- TODO

    NewLovePromoteView.super.deleteMe(self);
end

return NewLovePromoteView;
