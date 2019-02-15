--伙伴系统功能按钮管理
--2016-12-6 17:14:13
--Author:xiaohuaxiong
local PartnerTopView = class("PartnerTopView",UIBase)

local NAME_MAP = {
    [1] = "提升",
    [2] = "升星",
    [3] = "仙术",
    [4] = "情报",
    [5] = "装备",
    [6] = "法宝",
};

function PartnerTopView:ctor(_winName)
    PartnerTopView.super.ctor(self,_winName)
--当前被选中的按钮
    self._currentSelect=0;
--关于PartnerView的引用
    self._partnerView=nil
end

function PartnerTopView:setPartnerView( _class)
    self._partnerView = _class
end

function PartnerTopView:loadUIComplete()
    self:registerEvent();
end

function PartnerTopView:registerEvent()
    PartnerTopView.super.registerEvent(self)
    --将按钮的名字集合起来,注意按钮与事件之间的对应关系
    self._mcFunc={}
    --升品
    self._mcFunc[1]=self.mc_1 -- 提升
    self._mcFunc[2]=self.mc_2 -- 升星
    self._mcFunc[3]=self.mc_3 -- 技能
    self._mcFunc[4]=self.mc_4 -- 情报
    self._mcFunc[5]=self.mc_5 -- 装备

    -- 6月28号 要求隐藏
    --   self._mcFunc[5]:visible(false)
    --隐藏star
    --    self._mcFunc[5]:visible(false)
    -- end
   
    --按钮注册事件
    self._funcSet ={
        self.clickButtonQualityLevelup,--升品
        self.clickButtonLevelup,--升级
        self.clickButtonStarLevelup,--升星
        self.clickButtonSkill,--技能
        self.clickButtonQingbao,--情报
    }
    
    EventControler:addEventListener(PartnerEvent.PARTNER_CHANGEQINGBAO_EVENT,self.changeQingBao,self)

end

--[[
处理按钮显示及事件
]]
function PartnerTopView:refreshBtn(partnerId)
    --函数表驱动
    if not partnerId then
        return
    end
    for _index=1, #self._mcFunc do
        -- 注意 要先showfram 再置灰或者清除
        if _index == 3 and FuncPartner.isChar(partnerId) then
            self._mcFunc[_index]:showFrame(2)
        elseif _index == 1 and self.comnbine then 
            self._mcFunc[_index]:showFrame(2)
        else
            self._mcFunc[_index]:showFrame(1)
        end


        if _index == 3 then
            self._mcFunc[_index].currentView.mc_3.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index,true))
        elseif _index == 1 then 
            self._mcFunc[_index].currentView.mc_1.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index,true))
        else
            self._mcFunc[_index].currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index,true))
        end

        if self:isOpenByType(_index,partnerId) then
            FilterTools.clearFilter(self._mcFunc[_index])
        else
            FilterTools.setGrayFilter(self._mcFunc[_index])
        end
    end

    self:refreshRedPoint(partnerId)
end

-- 合成时 显示
function PartnerTopView:combineSelect(partnerId)
    for _index=1, #self._mcFunc do
        FilterTools.setGrayFilter(self._mcFunc[_index])
        if _index == 3 then
            self._mcFunc[_index]:showFrame(1)
            if self._currentSelect == 3 then
                self._mcFunc[_index].currentView.mc_3:showFrame(2)
            else
                self._mcFunc[_index].currentView.mc_3:showFrame(1)
            end
            
            self._mcFunc[_index].currentView.mc_3.currentView.panel_red:visible(false)
            self._mcFunc[_index].currentView.mc_3.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index,true))
            if self:isOpenByType(_index, partnerId) then
                FilterTools.clearFilter(self._mcFunc[_index])
            else
                FilterTools.setGrayFilter(self._mcFunc[_index])
            end
        elseif _index == 1 then 
            local redShow = PartnerModel:isCanCombienPartner(partnerId)
            self._mcFunc[_index]:showFrame(2)
            if self._currentSelect == 4 or self._currentSelect == 3 then
                self._mcFunc[_index].currentView.mc_1:showFrame(1)
            else
                self._mcFunc[_index].currentView.mc_1:showFrame(2)
            end

            -- 判断是否可合成
            self._mcFunc[_index].currentView.mc_1.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index,true))
            self._mcFunc[_index].currentView.mc_1.currentView.panel_red:visible(redShow)

            FilterTools.clearFilter(self._mcFunc[_index])
        elseif _index == 4 then
            -- 情报页签不做处理
            if self._currentSelect == 4 then
                self._mcFunc[_index]:showFrame(2)
            else
                self._mcFunc[_index]:showFrame(1)
            end

            FilterTools.clearFilter(self._mcFunc[_index])
            self._mcFunc[_index].currentView.panel_red:visible(false)
        else
            self._mcFunc[_index]:showFrame(1)
            self._mcFunc[_index].currentView.panel_red:visible(false)
        end
    end
    self.comnbine = true
end
function PartnerTopView:notCombineSelect()
    local partnerId = self._partnerView.selectPartnerId
    if not partnerId then
        return
    end
    for _index=1, #self._mcFunc do
        if self:isOpenByType(_index,partnerId) then
            FilterTools.clearFilter(self._mcFunc[_index])
        else
            FilterTools.setGrayFilter(self._mcFunc[_index])
        end
        if _index == 1 then
            self._mcFunc[1]:showFrame(1)
            self._mcFunc[1].currentView.mc_1:showFrame(1)
            self._mcFunc[1].currentView.mc_1.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,self._currentSelect,true))
        end
    end
    self.comnbine = false
end

-- 判断是否开启
function PartnerTopView:isOpenByType(_select,_partnerId)
    if _select == 1 then -- 品质
        return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_QUALITY)
    elseif _select == 2 then -- 升星
        if _partnerId and FuncPartner.isChar(_partnerId) then
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHARSTAR)
        else
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SHENGXING)
        end
        
    elseif _select == 3 then -- 技能
        if _partnerId and FuncPartner.isChar(_partnerId) then
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_NEW)
        else
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL)
        end
    elseif _select == 4 then -- 情报
        return true
    elseif _select == 5 then -- 装备
        return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_ZHUANGBEI)
    end
end

--设置当前被选中的按钮
function PartnerTopView:setCurrentSelect( _select,isPlaySound)
    -- echoError("\n_select=====", _select, "self.comnbine===", self.comnbine, "self._currentSelect==", self._currentSelect)
    if self.comnbine and _select ~= 1 and _select ~= 4 and _select ~= 3 then
        WindowControler:showTips(GameConfig.getLanguage("#tid_partner_notawake_01"))
        return
    end
    -- 添加功能未开启的提示
    local _partnerId = self._partnerView.selectPartnerId
    local open, value, valueType,lockTip,is_sy_screening  = self:isOpenByType(_select,_partnerId) 
    if not open then
        --判断是否是屏蔽的系统
        if is_sy_screening then
            WindowControler:showTips(FuncCommon.screeningstring)
        else
            if _select == 3 and FuncPartner.isChar(_partnerId) then
                FuncPartner.getUnLock(NAME_MAP[6],value,valueType,lockTip)  
            else
                FuncPartner.getUnLock(NAME_MAP[_select],value,valueType,lockTip)  
            end
            
        end  
        return 
    end
    assert(_select>0 and _select<=#self._mcFunc)
    if(_select ~= self._currentSelect)then
        self._currentSelect = _select
        if(not self.comnbine and self._currentSelect > 0)then
            if self._currentSelect == 3 then
                if FuncPartner.isChar(_partnerId) then
                    self._mcFunc[3]:showFrame(2)
                else
                    self._mcFunc[3]:showFrame(1)
                end
                self._mcFunc[3].currentView.mc_3:showFrame(1)
                self._mcFunc[3].currentView.mc_3.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,self._currentSelect,true))
            elseif self._currentSelect == 1 then 
                if self.comnbine then
                    self._mcFunc[1]:showFrame(2)
                else
                    self._mcFunc[1]:showFrame(1)
                end
                self._mcFunc[1].currentView.mc_1:showFrame(1)
                self._mcFunc[1].currentView.mc_1.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,self._currentSelect,true))
            else
                self._mcFunc[self._currentSelect]:showFrame(1)  
                self._mcFunc[self._currentSelect].currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,self._currentSelect,true))
            end
            if _select == 3 then
                if FuncPartner.isChar(_partnerId) then
                    self._mcFunc[3]:showFrame(2)
                else
                    self._mcFunc[3]:showFrame(1)
                end
                self._mcFunc[3].currentView.mc_3:showFrame(2)
            elseif _select == 1 then
                if self.comnbine then
                    self._mcFunc[1]:showFrame(2)
                else
                    self._mcFunc[1]:showFrame(1)
                end
                self._mcFunc[1].currentView.mc_1:showFrame(2)
            else
                self._mcFunc[_select]:showFrame(2)
            end
            
            self._funcSet[_select](self);
            self._partnerView:changeUIInTopView(_select)
            if isPlaySound then
                FuncPartner.playPartnerTopBtnSound()
            end
        else
            self._partnerView:changeCombineUIWith( FuncPartner.getPartnerById(_partnerId))
        end
        
        
    end
    self:refreshSelectState(_select)
end

--切换情报页签
function PartnerTopView:changeQingBao(  )
    self:setCurrentSelect(4)
end

-- 刷新选中状态
function PartnerTopView:refreshSelectState(_select)
    self._currentSelect = _select
    local _partnerId = self._partnerView.selectPartnerId
    assert(_select>0 and _select<=#self._mcFunc)
    -- if(_select ~= self._currentSelect)then
    for _index=1, #self._mcFunc do
        if _index == 3 then
            if FuncPartner.isChar(_partnerId) then
                self._mcFunc[3]:showFrame(2)
            else
                self._mcFunc[3]:showFrame(1)
            end
            if self._currentSelect == 3 then
                self._mcFunc[3].currentView.mc_3:showFrame(2)
                self._mcFunc[3].currentView.mc_3.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index,true))
            else
                self._mcFunc[3].currentView.mc_3:showFrame(1)
                self._mcFunc[3].currentView.mc_3.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index,true))
            end
        elseif _index == 1 then
            if self.comnbine then
                self._mcFunc[1]:showFrame(2)
            else
                self._mcFunc[1]:showFrame(1)
            end
            if self._currentSelect == 1 then
                self._mcFunc[1].currentView.mc_1:showFrame(2)
                self._mcFunc[1].currentView.mc_1.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index,true))
            else
                self._mcFunc[1].currentView.mc_1:showFrame(1)
                self._mcFunc[1].currentView.mc_1.currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index,true))
            end
        else
            if _select == _index then
                self._mcFunc[_index]:showFrame(2)
            else
                self._mcFunc[_index]:showFrame(1)
            end
        end
    end

    self:refreshRedPoint(_partnerId)
    local systemName = FuncPartner.getPartnerSystemName(self._currentSelect, _partnerId)
    EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, {tutorailParam = TutorialEvent.CustomParam.partnerTabChange.. systemName})
end

--获取当前被选中的按钮的索引
function PartnerTopView:getCurrentSelectButtonIndex()
     return self._currentSelect
end
-------------------------按钮事件集合---------------
--升品
function PartnerTopView:clickButtonQualityLevelup()

end
--升级
function PartnerTopView:clickButtonLevelup()

end
--升星
function PartnerTopView:clickButtonStarLevelup()

end
--技能
function PartnerTopView:clickButtonSkill()

end
--情报
function PartnerTopView:clickButtonQingbao()

end

-------------------红点提示刷新--------------------
function PartnerTopView:refreshRedPoint(_partnerId)
    if PartnerModel:isHavedPatnner(_partnerId) or FuncPartner.isChar(_partnerId) then
        --提升
        local isQualityShow = PartnerModel:isShowQualityRedPoint(_partnerId)
        local isBiographyShow = PartnerModel:isShowBiographyRedPoint(_partnerId)
        local isUpgradeShow = PartnerModel:isShowUpgradeRedPoint(_partnerId)
        local isLoveShow = PartnerModel:isLoveRedPoint(_partnerId)

        if self._currentSelect == 1 then
            if self.comnbine then
                self._mcFunc[1]:showFrame(2)
                self._mcFunc[1].currentView.mc_1:showFrame(2)
            else
                self._mcFunc[1]:showFrame(1)
                self._mcFunc[1].currentView.mc_1:showFrame(2)
            end
        end

        -- if self._currentSelect ~= 1 then
            local showRed = isQualityShow or isUpgradeShow or isBiographyShow
            self._mcFunc[1].currentView.mc_1.currentView.panel_red:visible(showRed)
        -- else
        --     self._mcFunc[1].currentView.mc_1.currentView.panel_red:visible(false)
        -- end
        

        --升星
        local isStarShow = PartnerModel:isShowStarRedPoint(_partnerId)
        -- if self._currentSelect ~= 2 then
            self._mcFunc[2].currentView.panel_red:visible(isStarShow)
        -- else
        --     self._mcFunc[2].currentView.panel_red:visible(false)
        -- end
        
        --技能
        local isSkillShow = PartnerModel:redPointSkillShow(_partnerId)
        if self._currentSelect == 3 then
            if FuncPartner.isChar(_partnerId) then
                self._mcFunc[3]:showFrame(2)
                self._mcFunc[3].currentView.mc_3:showFrame(2)
            else
                self._mcFunc[3]:showFrame(1)
                self._mcFunc[3].currentView.mc_3:showFrame(2)
            end
        end
        -- if self._currentSelect ~= 3 then
            self._mcFunc[3].currentView.mc_3.currentView.panel_red:visible(isSkillShow)
        -- else
        --     self._mcFunc[3].currentView.mc_3.currentView.panel_red:visible(false)
        -- end
        
        -- 情报
        local isQBShow = false


        self._mcFunc[4].currentView.panel_red:visible(isQBShow)
        --装备
        local isEquipShow = PartnerModel:isShowEquipRedPoint(_partnerId)
        -- 觉醒
        local isAwake = PartnerModel:isEquipAwakeRedPoint(_partnerId) -- 觉醒
        

        -- if self._currentSelect ~= 5 then
            local showRed = isEquipShow or isAwake
            self._mcFunc[5].currentView.panel_red:visible(showRed)
        -- else
        --     self._mcFunc[5].currentView.panel_red:visible(false)
        -- end
    else
        if self._currentSelect == 3 then
            self._mcFunc[3]:showFrame(1)
            self._mcFunc[3].currentView.mc_3:showFrame(2)
            self._mcFunc[3].currentView.mc_3.currentView.panel_red:visible(false)
        end    
    end
end
return PartnerTopView