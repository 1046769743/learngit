

local PartnerCharTiShiView = class("PartnerCharTiShiView" ,UIBase)

function PartnerCharTiShiView:ctor(_winName)
    PartnerCharTiShiView.super.ctor(self,_winName)
end

function PartnerCharTiShiView:loadUIComplete()
    self:registerEvent()

    self:updataUI()
end

function PartnerCharTiShiView:registerEvent()
    PartnerCharTiShiView.super.registerEvent(self)
    --注册事件监听,伙伴的信息发生了变化
    self.btn_close:setTap(c_func(self.close,self))
    self:registClickClose("out")

    self.btn_recall:setTap(c_func(self.gotoJDHY,self))
    self.btn_fb:setTap(c_func(self.gotoJingYing,self))
end
function PartnerCharTiShiView:gotoJingYing()
    if WorldModel:isOpenElite() then
        WindowControler:showWindow("EliteMainView")
    else
        local raidData = FuncChapter.getRaidDataByRaidId("10306")
        local str1 = GameConfig.getLanguage(raidData.name)
        local chapter = FuncChapter.getChapterByStoryId(tostring(raidData.chapter))
        local section = FuncChapter.getSectionByRaidId("10306")
        local str2 = chapter.."-"..section 
        local _str = string.format(GameConfig.getLanguage("#tid_partner_ui_001"),str2,str1)
        WindowControler:showTips(_str)
    end
end
function PartnerCharTiShiView:gotoJDHY()
    if WorldModel:isOpenPVEMemory() then
        WorldControler:showPVEListView()
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_002"))
    end
end

function PartnerCharTiShiView:updataUI()
    if WorldModel:isOpenElite() then
        FilterTools.clearFilter(self.btn_fb)
    else
        FilterTools.setGrayFilter(self.btn_fb)
    end

    if WorldModel:isOpenPVEMemory() then
        FilterTools.clearFilter(self.btn_recall)
    else
        FilterTools.setGrayFilter(self.btn_recall)
    end
end

function PartnerCharTiShiView:close()
    self:startHide()
end

return PartnerCharTiShiView