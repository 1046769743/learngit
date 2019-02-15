
local PartnerPropertyShowView = class("PartnerPropertyShowView",UIBase)
--local defaultParam =  {
--        _type = _type (1伙伴 2主角)
--        titleFrame = 1,2 (1品质 2星级)
--        before = {
--            info = {
--                quilityBorder, -- 品质边框
--                id, -- 绘制头像用
--                star,    -- 星级
--                level,   --等级




--            },
--            power = 3,
--            hp = 3,
--            act = 10,
--            def = 32,
--            magicDef = 100,
--        },
--        after = {
--            info = info,
--            power = 3,
--            hp = 3,
--            act = 10,
--            def = 32,
--            magicDef = 100,    
--        }
-- }
function PartnerPropertyShowView:ctor(_name,defaultParam,callback)
    PartnerPropertyShowView.super.ctor(self,_name)
    self.data = defaultParam
    self.titleFrame = defaultParam.titleFrame
    self._type = defaultParam._type
    self.callBack = callback
    self.isPartnerUpstar = defaultParam.isPartnerUpStar
    -- dump(defaultParam)
end

function PartnerPropertyShowView:loadUIComplete()
    self:registerEvent()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_efbg,UIAlignTypes.Middle)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_ani,UIAlignTypes.LeftTop)
    -- self.txt_jixu:setVisible(false)
    self:initData()
    self:updataUI()
end
function PartnerPropertyShowView:initData()
    self.beforeData = self.data.before
    self.afterData = self.data.after
    self.offset_table1 = {
        [1] = 0,
        [2] = -10,
        [3] = -30,
        [4] = -30,
        [5] = -50,
    }

    self.offset_table2 = {
        [1] = -40,
        [2] = -50,
        [3] = -55,
        [4] = -80,
        [5] = -90,
    }
end

function PartnerPropertyShowView:getCurrentNameFrame(_partnerId, _quality)
    --姓名
    local quaData = FuncPartner.getPartnerQuality(_partnerId)
    quaData = quaData[tostring(_quality)]
    local nameColor = quaData.nameColor
    nameColor = string.split(nameColor, ",")

    local frame = tonumber(nameColor[1]) or 1
    return frame
end

function PartnerPropertyShowView:updataUI()
    -- dump(self.beforeData, "\n\nself.beforeData====")
    local _partnerInfo = nil
    -- self.mc_1:showFrame(self.titleFrame)
    ----------before---------
    local panelTou1 = self.panel_tou1
    local _data = PartnerModel:getPartnerDataById(self.beforeData.info.id)
    if self._type == 2 then  -- 主角
        local garmentId = GarmentModel:getOnGarmentId()
        panelTou1.UI_tou1:updataUI(self.beforeData.info.id,garmentId)
        
    else  -- 伙伴
        local skin = self.beforeData.info.skin
        panelTou1.UI_tou1:updataUI(self.beforeData.info.id, skin)
    end

    if self.titleFrame == 1 then 
        panelTou1.UI_tou1:setQulity(_data.quality-1)
        panelTou1.UI_tou1:setStar(_data.star)
    elseif self.titleFrame == 2 then
        panelTou1.UI_tou1:setQulity(_data.quality)
        panelTou1.UI_tou1:setStar(_data.star-1)
    end

    local frameBefore = self:getCurrentNameFrame(self.beforeData.info.id, self.beforeData.info.quality)
    panelTou1.mc_name:showFrame(frameBefore)
    panelTou1.mc_name.currentView.txt_1:setString(PartnerModel:getQiXiaName(self.beforeData.info))

    --战力
    local beforePower = self.beforeData.power
    -- if self.afterData.info.starPoint == 0 and self.titleFrame == 2 then
    --     beforePower = self.beforeData.starPower
    -- end
    self.panel_number1.UI_1:setPower(beforePower)
    self.powerOffsetX1 = self.offset_table1[string.len(tostring(beforePower))]
    --法防
    self.panel_number2.mc_1:showFrame(1)
    self.panel_number2.mc_1.currentView.txt_1_2:setString(math.ceil(tonumber(self.beforeData.magicDef)))
    self.panel_number2.panel_1.mc_biao0:showFrame(6)
    self.panel_number2.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_016"))
    --物防
    self.panel_number3.mc_1:showFrame(1)
    self.panel_number3.mc_1.currentView.txt_1_2:setString(math.ceil(tonumber(self.beforeData.def)))
    self.panel_number3.panel_1.mc_biao0:showFrame(5)
    self.panel_number3.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_017"))
    --气血
    self.panel_number4.mc_1:showFrame(1)
    self.panel_number4.mc_1.currentView.txt_1_2:setString(math.ceil(tonumber(self.beforeData.hp)))
    self.panel_number4.panel_1.mc_biao0:showFrame(3)
    self.panel_number4.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_018"))
    --攻击
    self.panel_number5.mc_1:showFrame(1)
    self.panel_number5.mc_1.currentView.txt_1_2:setString(math.ceil(tonumber(self.beforeData.act)))
    self.panel_number5.panel_1.mc_biao0:showFrame(4) 
    self.panel_number5.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_019"))

    ----------after----------
    local panelTou2 = self.panel_tou2
    if self._type == 2 then
        local garmentId = GarmentModel:getOnGarmentId()
        panelTou2.UI_tou1:updataUI(self.afterData.info.id,garmentId)
    else
        local skin = self.afterData.info.skin
        panelTou2.UI_tou1:updataUI(self.afterData.info.id, skin)
    end
    
    local frameAfter = self:getCurrentNameFrame(self.beforeData.info.id, _data.quality)
    panelTou2.mc_name:showFrame(frameAfter)
    panelTou2.mc_name.currentView.txt_1:setString(PartnerModel:getQiXiaName(_data))
    --战力
    self.panel_number1.UI_2:setPower(self.afterData.power)
    self.powerOffsetX2 = self.offset_table2[string.len(tostring(self.afterData.power))]
    --法防
    if self:isXiangdeng(self.beforeData.magicDef,self.afterData.magicDef) then
        self.panel_number2.mc_2:showFrame(1)
    else
        self.panel_number2.mc_2:showFrame(2)
    end
    self.panel_number2.mc_2.currentView.txt_1_3:setString(math.ceil(tonumber(self.afterData.magicDef)))
    --物防
    if self:isXiangdeng(self.beforeData.def,self.afterData.def) then
        self.panel_number3.mc_2:showFrame(1)
    else
        self.panel_number3.mc_2:showFrame(2)
    end
    self.panel_number3.mc_2.currentView.txt_1_3:setString(math.ceil(tonumber(self.afterData.def)))
    --气血
    if self:isXiangdeng(self.beforeData.hp,self.afterData.hp) then
        self.panel_number4.mc_2:showFrame(1)
    else
        self.panel_number4.mc_2:showFrame(2)
    end
    self.panel_number4.mc_2.currentView.txt_1_3:setString(math.ceil(tonumber(self.afterData.hp)))
    --攻击
    if self:isXiangdeng(self.beforeData.act,self.afterData.act) then
        self.panel_number5.mc_2:showFrame(1)
    else
        self.panel_number5.mc_2:showFrame(2)
    end
    self.panel_number5.mc_2.currentView.txt_1_3:setString(math.ceil(tonumber(self.afterData.act)))

    --播放动画
    self:initAnim()
    -- self:onClose()
end
function PartnerPropertyShowView:initAnim()

    -- 标题特效
    if self.titleFrame == 1 then
        self.titleFrame = 8
    elseif self.titleFrame == 2 then 
        self.titleFrame = 7
    end

    FuncCommUI.addCommonBgEffect(self.ctn_efbg,self.titleFrame)

    self.panel_close:setVisible(false)
    self.panel_tou1:visible(false)
    self.panel_tou2:visible(false)
    self.panel_t1:visible(false)
    self.panel_t2:visible(false)
    self.panel_zhalisuoqu:visible(false)
    self.panel_number1:visible(false)
    self.panel_number2:visible(false)
    self.panel_number3:visible(false)
    self.panel_number4:visible(false)
    self.panel_number5:visible(false)

    local _animFunc = function ( ... )
        local jiesuanAnim = self:createUIArmature("UI_huoban","UI_huoban_shengpin_jiesuan", nil, false, 
        function ()
            self:registClickClose(-1, c_func( function()
                local _partnerId = self.afterData.info.id
                if self.isPartnerUpstar and (not FuncPartner.isChar(_partnerId)) then
                    -- 判断是否有新技能解锁
                    local _data = PartnerModel:getPartnerDataById(_partnerId)
                    local newSkillId = FuncPartner.unlockSkillByStar(_partnerId,_data.star)
                    if newSkillId then
                        local _partnerId = self.data.after.info.id
                        local _data = PartnerModel:getPartnerDataById(_partnerId)
                        local skillId = FuncPartner.unlockSkillByStar(_partnerId,_data.star)
                        WindowControler:showWindow("PartnerOpenSkillShowView",skillId,self.callBack)
                    else
                        if self.callBack then
                            self.callBack()
                        end   
                    end
                else
                    if self.callBack then
                      self.callBack()
                    end  
                end
                self:onClose()
            end , self))
        end)
        self.ctn_ani:addChild(jiesuanAnim)
        -- jiesuanAnim:setScale(0.845)
        jiesuanAnim:setPositionX(4)
        --替换 bones
        self.panel_tou1:pos(-160, 40)
        self.panel_tou2:pos(-150, 40)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"node1",self.panel_tou1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"node2",self.panel_tou2)
        --战力
        self.panel_zhalisuoqu:pos(-60, 25)
        self.panel_number1.UI_1:pos(cc.p(self.powerOffsetX1, 12))
        self.panel_number1.UI_2:pos(cc.p(self.powerOffsetX2, 12))
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a6",self.panel_zhalisuoqu)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a7",self.panel_number1.UI_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a8",self.panel_number1.UI_2)
        --
        
        local shuxingPos = cc.p(-60, 20)
        local numPos1 = cc.p(-200, 16)
        local numPos2 = cc.p(-160, 16)

        self.panel_number4.panel_1:pos(shuxingPos)
        self.panel_number4.mc_1:pos(numPos1)
        self.panel_number4.mc_2:pos(numPos2)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a11",self.panel_number4.panel_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a12",self.panel_number4.mc_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a13",self.panel_number4.mc_2)

        self.panel_number5.panel_1:pos(shuxingPos)
        self.panel_number5.mc_1:pos(numPos1)
        self.panel_number5.mc_2:pos(numPos2)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a16",self.panel_number5.panel_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a17",self.panel_number5.mc_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a18",self.panel_number5.mc_2)

        self.panel_number3.panel_1:pos(shuxingPos)
        self.panel_number3.mc_1:pos(numPos1)
        self.panel_number3.mc_2:pos(numPos2)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a21",self.panel_number3.panel_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a22",self.panel_number3.mc_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a23",self.panel_number3.mc_2)

        self.panel_number2.panel_1:pos(shuxingPos)
        self.panel_number2.mc_1:pos(numPos1)
        self.panel_number2.mc_2:pos(numPos2)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a26",self.panel_number2.panel_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a27",self.panel_number2.mc_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a28",self.panel_number2.mc_2)
    end
    self:delayCall(_animFunc, 0.5)

end

function PartnerPropertyShowView:isXiangdeng(before,after)
    if before == after then
        return true
    else
        return false
    end
end
function PartnerPropertyShowView:registerEvent()
    PartnerPropertyShowView.super.registerEvent(self)
--    self:registClickClose("out")
    
    --关闭
--    self.btn_1:setTap(c_func(self.onClose,self))
end
function PartnerPropertyShowView:onClose()
    self:startHide()
end
return PartnerPropertyShowView
