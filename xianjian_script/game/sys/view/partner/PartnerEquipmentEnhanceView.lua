local PartnerEquipmentEnhanceView = class("PartnerEquipmentEnhanceView", UIBase)

local ANIM_TYPY = {
    QIANGHHUA = 1,
    JINJIE = 2,
    INIT = 3,
    AWAKE = 4,
};

-- 添加装备觉醒的特效
function PartnerEquipmentEnhanceView:addAwakenAnim( ctn,index,isAdd )
    if not self.awakeAnim then
        self.awakeAnim = {}
    end

    if not self.awakeAnim[index] then
        local _anim = self:createUIArmature("UI_shop", "UI_shop_zhuangbeijuexing",  nil, true, GameVars.emptyFunc)
        self.awakeAnim[index] = _anim
        ctn:addChild(_anim)
        _anim:scale(1.1)
        _anim:pos(0, 5)
    end
    self.awakeAnim[index]:visible(isAdd)
    
end

-- 快捷购买的装备强化石 道具id
local equipmentEnhanceStoneId = "10101"

function PartnerEquipmentEnhanceView:addAnim(_view,_type,pos,costKinds,callback,equipId)
    local ctn = _view.ctn_anim
    local ctn_bao = _view.ctn_animBao
    -- ctn:removeAllChildren()
    if _type == ANIM_TYPY.INIT then
        
    elseif _type == ANIM_TYPY.JINJIE then
        local animKey = "jinjie"..pos
        self:delayCall(function()
            local jinjieAnim = nil
            if self.animT[animKey] then
                jinjieAnim = self.animT[animKey]
                jinjieAnim:visible(true)
            else
                jinjieAnim = self:createUIArmature("UI_huoban_zhuangbei","UI_huoban_zhuangbei_jinjie", nil, true, GameVars.emptyFunc)
                ctn:addChild(jinjieAnim)
                self.animT[animKey] = jinjieAnim
                FuncArmature.changeBoneDisplay(jinjieAnim, "node1", display.newNode())
                FuncArmature.changeBoneDisplay(jinjieAnim, "node2", display.newNode())
            end
            jinjieAnim:startPlay(false, true)
            jinjieAnim:doByLastFrame(false,false,function() jinjieAnim:visible(false) end)
        end,1/30)

        -- 添加消耗
        local posX = self.panel_6.mc_1:getPositionX()
        local posY = self.panel_6.mc_1:getPositionY()
        for i=1,costKinds do
            posX = self.panel_6.mc_1:getPositionX() + (i-1)*100
            local costAnim = nil
            if self.costanimT[animKey] then
                costAnim = self.costanimT[animKey] 
            else
                costAnim = self:createUIArmature("UI_huoban","UI_huoban_shengpin_xiaohao", nil, true, GameVars.emptyFunc)
                self.costanimT[animKey] = costAnim
                costAnim:scale(0.8)
                self.panel_6:addChild(costAnim)
                costAnim:setPositionX(posX + 36)
                costAnim:setPositionY(posY - 45)
            end
            costAnim:startPlay(false, true)
            costAnim:doByLastFrame(false, false, function() costAnim:visible(false) end)
        end
        
        
        -- 添加轨迹
        -- self:delayCall(function()
        --     local guijiAnim = self:getGuijiAnim(pos,costKinds,ctn)
        --     guijiAnim:visible(true)
        --     guijiAnim:startPlay(true,false)
        --     guijiAnim:doByLastFrame(false,false,function() guijiAnim:visible(false) end)
        -- end,5/30)
        
        
    elseif _type == ANIM_TYPY.QIANGHHUA then 
        local animKey = "qianghua"..pos
        self:delayCall(function()
            local qianghuaAnim = nil
            if self.animT[animKey] then
                qianghuaAnim = self.animT[animKey]
                qianghuaAnim:visible(true)
            else
                qianghuaAnim = self:createUIArmature("UI_huoban","UI_huoban_zhuangbei_shengji", nil, true, GameVars.emptyFunc)
                ctn:addChild(qianghuaAnim)
                self.animT[animKey] = qianghuaAnim
            end
            qianghuaAnim:startPlay(false,true)
            qianghuaAnim:doByLastFrame(false,false,function() qianghuaAnim:visible(false) end) 
        end,1/30)
        -- 添加消耗 
        local posX = self.panel_6.mc_1:getPositionX()
        local posY = self.panel_6.mc_1:getPositionY()
        for i=1,costKinds do
            posX = self.panel_6.mc_1:getPositionX() + (i-1)*100
        end

        local costAnim = nil
        if self.costanimT[animKey] then
            costAnim = self.costanimT[animKey] 
            costAnim:visible(true)
        else
            costAnim = self:createUIArmature("UI_huoban","UI_huoban_shengpin_xiaohao", nil, true, GameVars.emptyFunc)
            self.costanimT[animKey] = costAnim
            costAnim:scale(0.8)
            self.panel_6:addChild(costAnim)
            costAnim:setPositionX(posX + 36)
            costAnim:setPositionY(posY - 45)
        end
        costAnim:startPlay(false,true)
        costAnim:doByLastFrame(false, false, function() costAnim:visible(false) end)
        -- 添加轨迹
        -- self:delayCall(function()
        --     local guijiAnim = self:getGuijiAnim(pos,costKinds,ctn)
        --     guijiAnim:visible(true)
        --     guijiAnim:startPlay(true,false)
        --     guijiAnim:doByLastFrame(false,false,function() guijiAnim:visible(false) end) 
        -- end,5/30)

        self:delayCall(function ()
                FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, ctn_bao, -3, -3)
                local equData = FuncPartner.getEquipmentById(equipId)
                local equipData = self:getEquipmentData(equipId)
                equData = equData[tostring(equipData.level)]    
                _view.txt_1:setString(equData.showLv[1].key)
            end, 20/GameVars.GAMEFRAMERATE)
    end

    self:delayCall(function()
        EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
        if callback then
            callback()
        end  
    end, 40/GameVars.GAMEFRAMERATE) 
    self.animType = ANIM_TYPY.INIT
end

-- 通过 装备位和消耗道具种类数  获取轨迹动画
function PartnerEquipmentEnhanceView:getGuijiAnim(pos,costKinds,ctn)
    local animName = "UI_huoban_guiji_zhuangbei_qianghuaguijia"
    local boneName = "a"
    if pos == 1 then
        animName = "UI_huoban_guiji_zhuangbei_qianghuaguijia"
        boneName = "a"
    elseif pos == 2 then
        animName = "UI_huoban_guiji_zhuangbei_qianghuaguijic"
        boneName = "c"
    elseif pos == 4 then
        animName = "UI_huoban_guiji_zhuangbei__qianghuaguijib"
        boneName = "b"
    elseif pos == 3 then
        animName = "UI_huoban_guiji_zhuangbei_qianghuaguijid"
        boneName = "d"
    end
    local anim = nil
    
    if self.animT[animName] then
        anim = self.animT[animName]
        anim:visible(true)
    else
        anim = self:createUIArmature("UI_huoban_guiji",animName, nil, false, GameVars.emptyFunc)
        ctn:addChild(anim)
        self.animT[animName] = anim
    end
    local kinds = costKinds
    boneName = "a"
    if kinds == 1 then
        anim:getBone(boneName.."2"):visible(false)
        anim:getBone(boneName.."3"):visible(false)
        anim:getBone(boneName.."4"):visible(false)
        anim:getBone(boneName.."5"):visible(false)
    elseif kinds == 2 then
        anim:getBone(boneName.."3"):visible(false)
        anim:getBone(boneName.."4"):visible(false)
        anim:getBone(boneName.."5"):visible(false)
    elseif kinds == 3 then
        anim:getBone(boneName.."4"):visible(false)
        anim:getBone(boneName.."5"):visible(false)
    elseif kinds == 4 then
        anim:getBone(boneName.."5"):visible(false)
    end

    return anim
end

function PartnerEquipmentEnhanceView:ctor(winName)
	PartnerEquipmentEnhanceView.super.ctor(self, winName)
    self.animT = {}
    self.costanimT = {}
    self.iconPathNames = {}
end

function PartnerEquipmentEnhanceView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
end


function PartnerEquipmentEnhanceView:setAlignment()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_title, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_power, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_bg, UIAlignTypes.LeftTop)
end

--设置是否是熟悉期的状态
function PartnerEquipmentEnhanceView:setSkilledStatus()
    if LS:prv():get(StorageCode.partner_skilledForEquipmentEnhance) then
        self.isSkillledPlayerForEnhance = true
    else
        if PartnerModel:isSkilledPlayerForEquipmentEnhance() then
            self.isSkillledPlayerForEnhance = true
        else
            self.isSkillledPlayerForEnhance = false
        end
    end

    if LS:prv():get(StorageCode.partner_skilledForEquipmentAdvance) then
        self.isSkillledPlayerForAdvance = true
    else
        if PartnerModel:isSkilledPlayerForEquipmentAdvance() then
            self.isSkillledPlayerForAdvance = true
        else
            self.isSkillledPlayerForAdvance = false
        end
    end
end

function PartnerEquipmentEnhanceView:updateUIWithPartner(_partnerInfo)
    --更新UI信息
    self.animType = ANIM_TYPY.INIT -- 初始化动画type信息
    self.data = PartnerModel:getPartnerDataById(_partnerInfo.id)
    self.selectEquipmentId = nil

    local equipmentCfg = FuncPartner.getPartnerEquipment(_partnerInfo.id)
    local canAwakeId = nil
    local canEnhanceId = nil
    for i,v in ipairs(equipmentCfg) do
        local equipData = self.data.equips[tostring(v)]

        if not canAwakeId and not PartnerModel:checkEquipAwakeById(_partnerInfo.id, v) 
            and PartnerModel:canAwake(_partnerInfo.id, v) then
            canAwakeId = v
        end

        local __type, _type = self:enhanceCostEnough(equipData.level, v)
        -- echo("\n__type====", __type, "_type====", _type)
        if not canEnhanceId and _type == 10 and __type == 0 then
            canEnhanceId = v
        end
    end
    
    if canAwakeId then
        self.selectEquipmentId = canAwakeId
    else
        self.selectEquipmentId = canEnhanceId
    end

    -- echo("\nself.selectEquipmentId====", self.selectEquipmentId)
    self.partnerSpId = nil
    self.isWeaponAwake = nil
    self.partnerId = _partnerInfo.id
    self:setPartnerInfo(_partnerInfo)
    self:updatePower()
    FuncCommUI.regesitShowPartnerTipView(self.panel_power,{id = self.partnerId,_type = FuncPartner.TIPS_TYPE .POWER_TIPS})
end

--加载奇侠立绘资源逻辑  如果是同一个奇侠 就不重复删除创建 但是在武器觉醒时需要换装 这时需要重新创建
function PartnerEquipmentEnhanceView:updatePartnerSpineLogic(_partnerInfo)
    local partnerData = PartnerModel:getPartnerDataById(self.partnerId)
    local isWeaponAwake = false
    if partnerData then
        isWeaponAwake = FuncPartner.checkWuqiAwakeSkill(partnerData)
    end

    if not self.isWeaponAwake and isWeaponAwake then
        self:loadPartnerSpine(_partnerInfo)
        self.isWeaponAwake = isWeaponAwake
    end
    --如果spine id 没变  那么就不用创建spine
    if self.partnerSpId ~= self.partnerId then
        self:loadPartnerSpine(_partnerInfo)
        self.isWeaponAwake = isWeaponAwake
    end
end

function PartnerEquipmentEnhanceView:loadPartnerSpine(_partnerInfo)
    local ctn = self.panel_bao.ctn_1
    ctn:removeAllChildren();
    local sp = nil
    if not FuncPartner.isChar(self.partnerId) then
        sp = FuncPartner.getHeroSpineByPartnerIdAndSkin( self.partnerId,_partnerInfo.skin,nil,_partnerInfo)
    else
        sp = FuncGarment.getSpineViewByAvatarAndGarmentId(UserModel:avatar(), UserExtModel:garmentId(),false,_partnerInfo)
    end
    sp:setScale(1.5)
    ctn:addChild(sp);
    self.sp = sp
    self.partnerSpId = self.partnerId
end

--伙伴信息
function PartnerEquipmentEnhanceView:setPartnerInfo( _partnerInfo)
    local partnerData = FuncPartner.getPartnerById(_partnerInfo.id);
    -- 伙伴信息
    self.UI_title:updateUI(_partnerInfo.id)
    self.UI_title:hideStar(  )

    if not self.panel_bao.clickNode then
        local _weight = 250
        local node = FuncRes.a_white( _weight,_weight)
        if self.panel_bao:getChildByTag(10001) then
            self.panel_bao:removeChildByTag(10001,true)
        end
        self.panel_bao:addChild(node,10000,10001)
        node:setPositionY(-290)
        node:setPositionX(271)
        node:setTouchedFunc(c_func(self.openPartnerInfoUI,self))
        node:opacity(0)
        self.panel_bao.clickNode = node
    end
    
    
    --初始化装备
    local equipmentCfg = FuncPartner.getPartnerEquipment( self.partnerId )
    self:initEquipment(equipmentCfg)
    self:refreshEquipmentInfo(self.selectEquipmentId)
    self:updatePartnerSpineLogic(_partnerInfo)
end
function PartnerEquipmentEnhanceView:updateBg()
    -- 背景
    self.bgId = self.partnerId
    self.ctn_bg:removeAllChildren()
    local bgPathName = nil
    if FuncPartner.isChar(self.data.id) then
        local curGarmentId = GarmentModel:getOnGarmentId()
        local avatar = UserModel:avatar()
        bgPathName = FuncPartner.getPartnerBgById(self.data.id, curGarmentId, avatar)
    else
        bgPathName = FuncPartner.getPartnerBgById(self.data.id, self.data.skin)
    end
    if self.bgImgPath ~= bgPathName then
        echo("--------bg ---------------",self.bgImgPath)
        self.bgImgPath = bgPathName
        self:changeBg(self.bgImgPath,true)
    end
end
function PartnerEquipmentEnhanceView:openPartnerInfoUI()
    FuncPartner.playPartnerInfoSound( )
    -- WindowControler:showWindow("PartnerInfoUI",self.data.id)
    EventControler:dispatchEvent(PartnerEvent.PARTNER_CHANGEQINGBAO_EVENT)
end
function PartnerEquipmentEnhanceView:initEquipment(_equipmentData, notChangeLevel)
    self.equipmentVec = {}
    self.equipmentPosVec = {}
    for i,v in pairs(_equipmentData) do
        local equData = FuncPartner.getEquipmentById(v)
        local equPanel = self["panel_"..i]
        local equipData = self:getEquipmentData(v)
        self.equipmentVec[v] = equPanel
        self.equipmentPosVec[v] = i
        --判断是否开启
        if self:equipmentLockState(v) then
            equData = equData[tostring(equipData.level)]
            equPanel.panel_suo:visible(false)      
            if not notChangeLevel then
                equPanel.txt_1:setString(equData.showLv[1].key)
            end         
            equPanel.txt_1:visible(true)
            equPanel.txt_2:visible(false)
            FilterTools.clearFilter(equPanel.mc_1)
            equPanel.mc_kuang:showFrame(equData.quality)
            equPanel.mc_bg:showFrame(equData.quality)
            -- 判断此装备是否可升级
            local isShowRed = self:equipmentCanUp(v)
            equPanel.panel_red:visible(isShowRed)
            --选择事件
            equPanel:setTouchedFunc(c_func(self.refreshEquipmentInfo,self,v), nil ,true)
        else
            --未开启 默认为1 级
            equData = equData[tostring(equipData.level)] 
            equPanel.panel_suo:visible(true)
            equPanel.txt_1:visible(false)
            equPanel.txt_2:visible(true)
            --装备解锁条件
            local strLock = GameConfig.getLanguageWithSwap("#tid1556",equData.needLv)
            equPanel.txt_2:setString(strLock)
            FilterTools.setGrayFilter(equPanel.mc_1)
            equPanel.mc_kuang:showFrame(equData.quality)
            equPanel.mc_bg:showFrame(equData.quality)
            equPanel.mc_1.currentView.panel_1:visible(false)
            equPanel.panel_red:visible(false)
            --选择事件
            equPanel:setTouchedFunc(c_func(function ()
                WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_005"))
            end,self),nil ,true)
        end
        local ctn = equPanel.ctn_1
        local sprPath = FuncRes.iconPartnerEquipment(PartnerModel:getEquipIconById( self.data.id,i))
        if not self.iconPathNames[i] or (self.iconPathNames[i] and self.iconPathNames[i] ~= sprPath) then
            self.iconPathNames[i] = sprPath
            local spr = cc.Sprite:create(sprPath)
            spr:setScale(1)
            ctn:removeAllChildren()
            ctn:addChild(spr)
        end    

        local ctn_awakAnim = equPanel.ctn_awakAnim
        local addAnim = function ()
            if PartnerModel:checkEquipAwakeById(self.data.id, v) then
                self:addAwakenAnim(ctn_awakAnim,i,true)
            else
                self:addAwakenAnim(ctn_awakAnim,i,false)
            end
        end

        self:delayCall(addAnim, i/GameVars.GAMEFRAMERATE)
        

        --装备名称
        local nameColor = equData.nameColor
        nameColor = string.split(nameColor,",")
        equPanel.mc_name:showFrame(tonumber(nameColor[1]))
        local _equipName = PartnerModel:getEquipNameById( self.data.id, v)
        if tonumber(nameColor[2]) > 1 then
            local colorNum = tonumber(nameColor[2]) - 1
            equPanel.mc_name.currentView.txt_1:setString(GameConfig.getLanguage(_equipName).." +"..colorNum)
        else
            equPanel.mc_name.currentView.txt_1:setString(GameConfig.getLanguage(_equipName))
        end
    end
end
-- 判断此装备是否可升级 或者 升品
function PartnerEquipmentEnhanceView:equipmentCanUp(equipId)
    local equData = self:getEquipmentData(equipId)
    local isShowRed = false
    if self:enhanceCostEnough(equData.level,equipId) == 0 and self:equipLevelLimit(equipId) then
        isShowRed = true
    end

    if PartnerModel:getRedPoindKaiGuanById(self.partnerId) == false then
        isShowRed = false
    end
    return isShowRed
end
-- 判断装备升级的等级限制条件
function PartnerEquipmentEnhanceView:equipLevelLimit(equipId)
    local equData = self:getEquipmentData(equipId)
    local equCfgData = FuncPartner.getEquipmentById(equipId)
    equCfgData = equCfgData[tostring(equData.level)]
    if self.data.level >= equCfgData.needLv then
        return true,equCfgData.needLv
    else
        return false,equCfgData.needLv
    end
end

-- 获取单个装备信息 
function PartnerEquipmentEnhanceView:getEquipmentData(_id)
    return self.data.equips[tostring(_id)]
end
--装备解锁状态
function PartnerEquipmentEnhanceView:equipmentLockState(equipmentId)
    return true
end
--装备选中状态
function PartnerEquipmentEnhanceView:refreshEquipmentSelectedSate()
    for i,v in pairs(self.equipmentVec) do
        if i == self.selectEquipmentId then
            v.mc_two:showFrame(1)
        else
            v.mc_two:showFrame(2)
        end
    end
    
end
--刷新装备详情 
function PartnerEquipmentEnhanceView:refreshEquipmentInfo(EquipmentId)
    if EquipmentId ~= self.selectEquipmentId then
         FuncPartner.playPartnerBtnSound()
    end
    if EquipmentId == nil then
        local equipmentCfg = FuncPartner.getPartnerEquipment( self.partnerId )
        self.selectEquipmentId = equipmentCfg[1]
        EquipmentId = self.selectEquipmentId
    else
        self.selectEquipmentId = EquipmentId
    end
    self:refreshEquipmentSelectedSate()
    
    local equipData = self:getEquipmentData(self.selectEquipmentId) 

    local equPanel = self.panel_5
    local equLevel = equipData.level -- 装备等级
    local equData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    equData = equData[tostring(equLevel)]
    --装备名称
    local nameColor = equData.nameColor
    nameColor = string.split(nameColor,",")
    equPanel.mc_1:showFrame(tonumber(nameColor[1]))
    local _equipName = PartnerModel:getEquipNameById( self.data.id,self.selectEquipmentId )
    if tonumber(nameColor[2]) > 1 then
        local colorNum = tonumber(nameColor[2]) - 1
        equPanel.mc_1.currentView.txt_1:setString(GameConfig.getLanguage(_equipName).." +"..colorNum)
    else
        equPanel.mc_1.currentView.txt_1:setString(GameConfig.getLanguage(_equipName))
    end
    
    --等级  
    equPanel.panel_1.rich_2:setString(GameConfig.getLanguage("#tid_partner_ui_006")..equData.showLv[1].key)
    --加成
    plusVec = equData.subAttr or equData.subAttrPlus
    equPanel.panel_2:visible(false)
    local txtCtn = equPanel.ctn_1
    txtCtn:removeAllChildren()
    for i=2,5 do
        local _panel = equPanel["panel_"..(i)]
        _panel:visible(false)
    end
    local index = 1
    for i,v in pairs(plusVec) do
        local _panel = equPanel["panel_"..(i+1)]
        _panel:visible(true)
        local _str = FuncPartnerEquipAwake.getDesStaheTable(v)
        -- 判断是否已觉醒
        if PartnerModel:checkEquipAwakeById( self.data.id,self.selectEquipmentId ) then
            local awakeId = FuncPartner.getAwakeEquipIdByid( self.data.id,self.selectEquipmentId )
            local jxAtt = FuncPartnerEquipAwake.getAwakeAttrValue(awakeId,v.key,v)
            if jxAtt then
                _str = _str .. "+<color = 00FF00>"..jxAtt.."<->"
            end
        end
        _panel.rich_2:setString(_str)
        index = index + 1
    end
    local awakeAttr = FuncPartnerEquipAwake.getAwakeEquipsAttrById(self.data.id,self.selectEquipmentId)
    for i,v in pairs(awakeAttr) do
        local isHas = false
        for ii,vv in pairs(plusVec) do
            if tostring(vv.key) == tostring(v.key) then
                isHas = true
            end
        end
        if isHas == false then
            if PartnerModel:checkEquipAwakeById( self.data.id,self.selectEquipmentId ) then
                if index <= 4 then
                    local _panel = equPanel["panel_"..(index+1)]
                    _panel:visible(true)
                    local awakeId = FuncPartner.getAwakeEquipIdByid( self.data.id,self.selectEquipmentId )
                    local jxAtt = FuncPartnerEquipAwake.getAwakeAttrValue(awakeId,v.key)
                    
                    local name = FuncPartnerEquipAwake.getNameAndValueStaheTable(v)
                    _str = name .. ": " .. "<color = 00FF00>"..jxAtt.."<->"
                    _panel.rich_2:setString(_str)
                    index = index + 1
                end
                
            end
        end
    end
    
    self:refreshCostView()
    self:refreshBtn()
    -- 装备觉醒的按钮
    self:refreshEquipAwakBtn()
end

function PartnerEquipmentEnhanceView:refreshCostView()
    local equipData = self:getEquipmentData(self.selectEquipmentId) 
    local equLevel = equipData.level -- 装备等级
    local equData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    equData = equData[tostring(equLevel)]
    --强化消耗
    local costPanel = self.panel_6
    local costItemView = costPanel.mc_1
    costItemView:visible(false)
    costPanel.ctn_1:removeAllChildren()
    local costVec = equData.lvCost or equData.qualityCost;
    if costVec then
        for i,v in pairs(costVec) do
            local str = string.split(v,",")
            if tonumber(str[1]) == 1 or tonumber(str[1]) == 3 then
                local itemView = UIBaseDef:cloneOneView(costItemView)
                itemView:setPositionX(itemView:getPositionX() + (i-1)*100)
                costPanel.ctn_1:addChild(itemView)
                
                if tonumber(str[1]) == 3 then
                    self:initCostCoin(itemView,tonumber(str[2]))
                else
                    self:initCostItem(itemView,str[2],tonumber(str[3]))
                end
            end
        end
    end
end

function PartnerEquipmentEnhanceView:refreshEquipAwakBtn( )
    -- 是否开启
    local btnAwake = self.btn_3
    local panelRed = btnAwake:getUpPanel().panel_red
    if not PartnerModel:checkJXSystemOpen( ) then
        echo("奇侠 觉醒 还未开启========")
        btnAwake:visible(false)
        self.panel_juex:visible(false)
        return
    end
    local partnerId = self.data.id
    local equipId = self.selectEquipmentId
    local awakeEquipId = FuncPartner.getAwakeEquipIdByid( partnerId,equipId )
    local equipData = self:getEquipmentData(equipId)
    -- 判断当前装备是否已觉醒
    -- 判断当前装备是否已觉醒
    local isAwake = PartnerModel:checkEquipAwakeById( partnerId,equipId )
    if isAwake then
        echo("奇侠 觉醒 已经 觉醒=======")
        btnAwake:visible(false)

        self.panel_juex:visible(true)
    else
        echo("奇侠 觉醒 还未  觉醒========")
        btnAwake:visible(true)
        self.panel_juex:visible(false)
        -- 判断限制等级是否满足
        local isCan,_type,tipStr = PartnerModel:canAwake(partnerId, equipId)
        if isCan then
            FilterTools.clearFilter(btnAwake)
            local showRedPoint = self:checkEquipAwake(awakeEquipId, isCan, _type, tipStr)
            if PartnerModel:getRedPoindKaiGuanById(partnerId) == false then
                showRedPoint = false
            end
            panelRed:visible(showRedPoint)
        else
            FilterTools.setGrayFilter(btnAwake)
            panelRed:visible(false)
        end

        btnAwake:setTap(c_func(self.equipAwakeTap, self, isCan, _type, tipStr))
    end
end
--消耗道具显示
function PartnerEquipmentEnhanceView:initCostItem(view,itemId,needNum)
    local num = ItemsModel:getItemNumById(itemId);
    view:showFrame(1)
    local _view = view.currentView
    local itemData = FuncItem.getItemData(itemId)
    _view.mc_1:showFrame(itemData.quality)
    --隐藏选中框
    _view.mc_1.currentView.panel_1:visible(false)

    _view.mc_1:showFrame(itemData.quality)
    local ctn = _view.mc_1.currentView.ctn_1;
    local sprPath = FuncRes.iconItemWithImage(itemData.icon)
    local spr = cc.Sprite:create(sprPath)
    ctn:removeAllChildren()
    ctn:addChild(spr)
    if num >= needNum then
        _view.panel_lv:visible(false)
        FilterTools.clearFilter(_view.mc_1)
        view.currentView.txt_1:setColor(cc.c3b(255,255,255));
        local str = "1,"..itemId ..","..num
        _view:setTouchedFunc(c_func(function ()
            WindowControler:showWindow("GetWayListView", itemId,needNum);
        end,self))
    else
        _view.panel_lv:visible(true)
        FilterTools.setGrayFilter(_view.mc_1)
        view.currentView.txt_1:setColor(cc.c3b(255,0,0));
        _view:setTouchedFunc(c_func(function ()
            WindowControler:showWindow("GetWayListView", itemId,needNum);
        end,self))
    end
    -- view.currentView.txt_1:setScale(0.8)
    view.currentView.txt_1:setString(num .."/"..needNum)
end
--消耗铜钱显示
function PartnerEquipmentEnhanceView:initCostCoin(view,needNum)
    view:showFrame(1)
    local _view = view.currentView
    _view.mc_1:showFrame(1)
    --隐藏选中框
    _view.mc_1.currentView.panel_1:visible(false)
    local ctn = _view.mc_1.currentView.ctn_1;
    local sprPath = FuncRes.iconItemWithImage("CashIcon_Ver80px")
    local spr = cc.Sprite:create(sprPath)
    ctn:removeAllChildren()
    ctn:addChild(spr)

    local num = UserModel:getCoin()
    if num >= needNum then
        _view.panel_lv:visible(false)
        -- FilterTools.clearFilter(_view.mc_1)
        view.currentView.txt_1:setColor(cc.c3b(255,255,255));

        _view:setTouchedFunc(c_func(function ()
            FuncCommUI.showCoinGetView()
        end,self))
    else
        _view.panel_lv:visible(true)
        -- FilterTools.setGrayFilter(_view.mc_1)
        view.currentView.txt_1:setColor(cc.c3b(255,0,0));
        _view:setTouchedFunc(c_func(function ()
            FuncCommUI.showCoinGetView()
        end,self))
    end
    num = FuncCommUI.turnOneNumToStr(num )
    needNum = FuncCommUI.turnOneNumToStr(needNum )
    -- view.currentView.txt_1:scale(0.8)
    view.currentView.txt_1:setString(needNum)
end

-- 0 满足 1条件不足 2,消耗不足 3,金币不足
function PartnerEquipmentEnhanceView:checkEquipAwake(awakeEquipId, _unlock, _type, _tips)
    if _unlock then
        local costT = FuncPartnerEquipAwake.getEquipAwakeCost(awakeEquipId)
        local resType,resId = UserModel:isResEnough(costT)
        if not resId and resType == true then
            return true
        else
            if tonumber(resType) == 1 then
                return false, 1
            elseif tonumber(resType) == 3 then
                return false, 3
            end
        end
    else
        return _unlock,_type,_tips
    end
end

function PartnerEquipmentEnhanceView:equipAwakeTap(isCan, _type, tipStr)
    if isCan then
        if FuncPartner.isChar(self.data.id) then
            self.beforEquipAttr = CharModel:getCharAttr()
        else
            self.beforEquipAttr = PartnerModel:getPartnerAttr(self.data.id)
        end
        self.oldPower = CharModel:getCharOrPartnerAbility(self.partnerId)
        local data = {}
        data.partnerId = self.data.id
        data.equipId = self.selectEquipmentId
        local awakeEquipId = FuncPartner.getAwakeEquipIdByid( self.data.id,self.selectEquipmentId )
        data.awakeEquipId = awakeEquipId
        WindowControler:showWindow("PartnerEquipAwakInfoView",data)
    else
        WindowControler:showTips(tipStr)
    end
end

--按钮刷新
function PartnerEquipmentEnhanceView:refreshBtn()
    self:setSkilledStatus()

    local equData = self:getEquipmentData(self.selectEquipmentId)
    --判断当前是否时升品状态
    local equCfgData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    equCfgData = equCfgData[tostring(equData.level)]
    local isQuality = false -- 是否升品
    local isMaxLevel = PartnerModel:equipLevelMax(self.selectEquipmentId,equData.level)
    self.txt_1:visible(false)   
    if isMaxLevel then
        self.mc_1:showFrame(3)  
    else 
        if equCfgData.qualityCost then
            --现在是升品状态
            self.mc_1:showFrame(2)
            isQuality = true
        else
            self.mc_1:showFrame(1)
        end

        local isLvOk,needLevel = self:equipLevelLimit(self.selectEquipmentId)
        if self:enhanceCostEnough(equData.level) == 0 and isLvOk then
            
            -- FilterTools.clearFilter(self.mc_1.currentView)
            local showRed = true
            if PartnerModel:getRedPoindKaiGuanById(self.data.id) == false then
                showRed = false
            end
            self.mc_1.currentView.btn_2:getUpPanel().panel_red:visible(showRed) 
        else
            -- FilterTools.setGrayFilter(self.mc_1.currentView) 
            self.mc_1.currentView.btn_2:getUpPanel().panel_red:visible(false) 
            if not isLvOk then
                self.txt_1:visible(true) 
                local name = ""
                if FuncPartner.isChar(tonumber(self.data.id)) then
                    name = "主角"
                else
                    name = FuncPartner.getPartnerName(self.data.id)
                end
                local str = GameConfig.getLanguageWithSwap("#tid_partner_33",name,needLevel) 
                self.txt_1:setString(str)
            end
        end
    end
    if self.mc_1.currentView.btn_2 then
        local _type = 2
        self.mc_1.currentView.btn_2:setTap(c_func(self.equipmentEnhanceTap,self,_type,isQuality))
        self.mc_1.currentView.btn_2:disableClickSound()
    end

    -- 一键强化 按钮
    local equips = FuncPartner.getPartnerEquipment( self.partnerId )
    local isAllMaxLevel = true
    for i,v in pairs(equips) do
        local equipData = self:getEquipmentData(v)
        local isMaxLevel = PartnerModel:equipLevelMax(v,equipData.level)
        if not isMaxLevel then
            isAllMaxLevel = false
            break
        end
    end

    self.btn_qianghua:visible(false)
    self.btn_jinjie:visible(false)
    self.mc_1:pos(658, -429)
    self.txt_1:pos(660, -405)

    if not isAllMaxLevel then
        local T, enhanceStatus = self:getYJQHTable( )
        local isAdvance, canAdvance = self:isYJJJ()
        if table.length(T) > 0 then
            if self.isSkillledPlayerForEnhance then
                self.btn_qianghua:visible(true)
                self.btn_jinjie:visible(false)
                -- FilterTools.clearFilter(self.btn_1)
                local showRed = true
                if PartnerModel:getRedPoindKaiGuanById(self.partnerId) == false then
                    showRed = false
                end
                self.btn_qianghua:getUpPanel().panel_red:visible(showRed)
            else
                self.btn_qianghua:visible(false)
                self.btn_jinjie:visible(false)
                self.mc_1:pos(740, -429)
                self.txt_1:pos(744, -405)
            end
        else
            -- 是否显示 全部进阶
            if isAdvance then 
                if self.isSkillledPlayerForAdvance then
                    self.btn_jinjie:visible(true)
                    self.btn_qianghua:visible(false)
                    if canAdvance then
                        -- FilterTools.clearFilter(self.btn_1)
                        local showRed = true
                        if PartnerModel:getRedPoindKaiGuanById(self.partnerId) == false then
                            showRed = false
                        end
                        self.btn_jinjie:getUpPanel().panel_red:visible(showRed)
                    else
                        -- FilterTools.setGrayFilter(self.btn_1) 
                        self.btn_jinjie:getUpPanel().panel_red:visible(false)
                    end
                else
                    self.btn_jinjie:visible(false)
                    self.btn_qianghua:visible(false)
                    self.mc_1:pos(740, -429)
                    self.txt_1:pos(744, -405)
                end
            else
                if self.isSkillledPlayerForEnhance then
                    self.btn_qianghua:visible(true)
                    self.btn_jinjie:visible(false)
                     --todo self.isSkillledPlayerForAdvance
                    -- FilterTools.setGrayFilter(self.btn_1) 
                    self.btn_qianghua:getUpPanel().panel_red:visible(false)
                else
                    self.btn_qianghua:visible(false)
                    self.btn_jinjie:visible(false)
                    self.mc_1:pos(740, -429)
                    self.txt_1:pos(744, -405)
                end
            end  
        end

        -- if isAdvance then
            self.btn_jinjie:setTap(c_func(self.YJJJBtnTap,self))
        -- else
            self.btn_qianghua:setTap(c_func(self.YJQHBtnTap,self))
        -- end
    end
end

-- 是否显示一键进阶
function PartnerEquipmentEnhanceView:isYJJJ( )
    local equipmentCfg = FuncPartner.getPartnerEquipment( self.partnerId )
    local T = {} -- 到达进阶
    local advanceTable = {} -- 可以进阶
    self.advanceCost = {}
    for i,v in pairs(equipmentCfg) do
        local equData = self:getEquipmentData(v)
        --判断当前是否时升品状态
        local equCfgData = FuncPartner.getEquipmentById(v)
        equCfgData = equCfgData[tostring(equData.level)]
        if equCfgData.qualityCost then
            table.insert(T,i)

            local isLvOk,needLevel = self:equipLevelLimit(v)
            if isLvOk and self:checkCanAdvance(equData.level, v) then
                advanceTable[v] = 1
            end
        end
    end

    local isAdvance = false
    local canAdvance = false
    if table.length(T) == 4 then
        isAdvance = true
    end

    if isAdvance and table.length(advanceTable) > 0 then
        canAdvance = true
    end

    return isAdvance, canAdvance, advanceTable
end

--一键进阶使用方法  用于判断哪几件装备可进阶
function PartnerEquipmentEnhanceView:checkCanAdvance(_level, _equipId)
    local equipId = _equipId
    local equData = FuncPartner.getEquipmentById(equipId)
    equData = equData[tostring(_level)]
    local costVec = equData.qualityCost

    local canAdvance = 0
    local tempCost = {}
    for i = #costVec, 1, -1 do
        local v = costVec[i]
        local str = string.split(v,",")
        if tonumber(str[1]) == 1 then
            local tempItemNum = self.advanceCost[str[2]] or 0
            local num = ItemsModel:getItemNumById(str[2]) - tempItemNum
            if num >= tonumber(str[3]) then
                canAdvance = canAdvance + 1
                tempCost[str[2]] = tonumber(str[3])
            else
                return false
            end
        elseif  tonumber(str[1]) == 3 then -- 铜钱
            local tempCoinNum = self.advanceCost[str[1]] or 0 
            local coinNum = UserModel:getCoin() - tempCoinNum
            if coinNum >= tonumber(str[2]) then
                canAdvance = canAdvance + 1 
                tempCost[str[1]] = tonumber(str[2])
            else
                return false
            end
        end
    end

    if canAdvance == #costVec then
        for k,v in pairs(tempCost) do
            if not self.advanceCost[k] then
                self.advanceCost[k] = v
            else
                self.advanceCost[k] = self.advanceCost[k] + v
            end
        end
        return true
    end
end

-- 一键强化按钮逻辑
function PartnerEquipmentEnhanceView:YJQHBtnTap( )
    local T, enhanceStatus = self:getYJQHTable( )
    if table.length(T) > 0 then
        local _param = {}
        _param.partnerId = tostring(self.data.id)
        _param.equips = T

        local _equips = {}
        for i,v in pairs(T) do
            table.insert(_equips,i)
        end
        FuncPartner.playPartnerBtnSound()
        local animType = ANIM_TYPY.QIANGHHUA 

        self.oldPower = CharModel:getCharOrPartnerAbility(self.partnerId);
        if FuncPartner.isChar(self.data.id) then
            EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT, 1)
            self.beforEquipAttr = CharModel:getCharAttr()
            CharServer:equipUpLevel(_param,c_func(self.equipmentEnhanceTapCallBackAddAnim,self,1,_equips,animType))
        else
            EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT, 1)
            self.beforEquipAttr = PartnerModel:getPartnerAttr(self.data.id)
            PartnerServer:equipUpgradeRequest(_param,c_func(self.equipmentEnhanceTapCallBackAddAnim,self,1,_equips,animType))
        end
    else
        local _type, _value = self:getAllEnhanceips(enhanceStatus)
        if _type == 0 then
            if FuncPartner.isChar(self.partnerId) then
                WindowControler:showTips(GameConfig.getLanguage("#tid_partner_awaken_013"))
            else
                WindowControler:showTips(GameConfig.getLanguage("#tid_partner_awaken_014"))
            end
        elseif _type == 1 then
            WindowControler:showWindow("QuickBuyItemMainView", equipmentEnhanceStoneId)
        elseif _type == 3 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_common_notEnoughCoin"))
            FuncCommUI.showCoinGetView()
        end
    end
end

function PartnerEquipmentEnhanceView:getAllEnhanceips(enhanceStatus)
    local equipmentCfg = FuncPartner.getPartnerEquipment(self.partnerId)
    local _type = nil
    local _value = nil
    for i,v in ipairs(equipmentCfg) do
        if enhanceStatus[v] and enhanceStatus[v].tipsCondition then
            _type = enhanceStatus[v].tipsCondition._type
            _value = enhanceStatus[v].tipsCondition._value
            break
        end
    end
    return _type, _value
end

function PartnerEquipmentEnhanceView:YJJJBtnTap( )
    echo("一键进阶-----------")
    local _, _, advanceTable = self:isYJJJ()
    if table.length(advanceTable) > 0 then
        local _param = {}
        _param.partnerId = tostring(self.data.id)
        _param.equips = advanceTable

        local _equips = {}
        for i,v in pairs(advanceTable) do
            table.insert(_equips,i)
        end
        FuncPartner.playPartnerBtnSound()
        local animType = ANIM_TYPY.JINJIE 

        self.oldPower = CharModel:getCharOrPartnerAbility(self.partnerId);
        if FuncPartner.isChar(self.data.id) then
            EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT, 1)
            self.beforEquipAttr = CharModel:getCharAttr()
            CharServer:equipUpLevel(_param,c_func(self.equipmentEnhanceTapCallBackAddAnim,self,2,_equips,animType))
        else
            EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT, 1)
            self.beforEquipAttr = PartnerModel:getPartnerAttr(self.data.id)
            PartnerServer:equipUpgradeRequest(_param,c_func(self.equipmentEnhanceTapCallBackAddAnim,self,2,_equips,animType))
        end
        -- self:equipmentEnhanceTapCallBackAddAnim(1,_equips,animType)
    else
        --如果一件都不能够进阶 则弹出选中装备需求的材料
        local equipData = self:getEquipmentData(self.selectEquipmentId)
        local costRes,itemId,costNum = self:enhanceCostEnough(equipData.level)

        if costRes == 1 or costRes == 11 then --道具不满足
            -- 快捷购买
            if itemId == equipmentEnhanceStoneId or self.isStoneNotEnough then
                WindowControler:showWindow("QuickBuyItemMainView", equipmentEnhanceStoneId)
            else
                WindowControler:showWindow("GetWayListView", itemId, costNum);
            end
        elseif costRes == 2 or costRes == 12 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_common_notEnoughCoin"))
            FuncCommUI.showCoinGetView()
        elseif costRes == -1 then
            if FuncPartner.isChar(self.partnerId) then
                WindowControler:showTips(GameConfig.getLanguage("#tid_partner_awaken_013"))
            else
                WindowControler:showTips(GameConfig.getLanguage("#tid_partner_awaken_014"))
            end
        end
    end
end

-- 一键强化按钮的逻辑 
function PartnerEquipmentEnhanceView:getYJQHTable( )
    local equipmentCfg = FuncPartner.getPartnerEquipment( self.partnerId )
    
    self:getMaxYJQHlevel(equipmentCfg)
    local T = {}
    for k,v in pairs(self.addLevel) do
        if v > 0 then
            T[k] = v
        end
    end
    return T, self.canEnhanceStatus
end

function PartnerEquipmentEnhanceView:getMaxYJQHlevel(equipmentCfg)
    self.addLevel = {}
    self.canEnhanceStatus = {}
    for k,v in pairs(equipmentCfg) do
        self.addLevel[v] = 0
        self.canEnhanceStatus[v] = {}
        self.canEnhanceStatus[v].canEnhance = true
    end

    self.tempCost = {}
    self.initEnhanceLevel = 0
    while not self:checkCanNotEnhance() do
        for k,v in pairs(equipmentCfg) do
            self:checkCanEnhanceById(v)
        end
        self.initEnhanceLevel = self.initEnhanceLevel + 1
    end
end

function PartnerEquipmentEnhanceView:checkCanNotEnhance()
    for k,v in pairs(self.canEnhanceStatus) do
        if self.canEnhanceStatus[k].canEnhance then
            return false
        end
    end
    return true
end

function PartnerEquipmentEnhanceView:checkCanEnhanceById(equipmentId)
    if not self.canEnhanceStatus[equipmentId].canEnhance then
        return
    end

    local equData = FuncPartner.getEquipmentById(equipmentId)
    local _equipData = self:getEquipmentData(equipmentId)

    local _level = _equipData.level
    local _equData = equData[tostring(_level + self.initEnhanceLevel)]

    if _equData.qualityCost then
        self.canEnhanceStatus[equipmentId].canEnhance = false
        return
    end

    if _equData.needLv > self.data.level then 
        self.canEnhanceStatus[equipmentId].canEnhance = false
        self.canEnhanceStatus[equipmentId].tipsCondition = {_type = 0, _value = _equData.needLv}
        return
    end

    if self.initEnhanceLevel > 0 and self.addLevel[tostring(equipmentId)] == 0 then
        self.canEnhanceStatus[equipmentId].canEnhance = false
        return
    end

    local costVec = _equData.lvCost
    if not costVec then -- 此时已manji
        self.canEnhanceStatus[equipmentId].canEnhance = false
        return
    end

    local tempCost = {}
    local canEnhance = true
    for i,v in pairs(costVec) do
        local str = string.split(v,",")
        if tonumber(str[1]) == 1 then
            local stoneCost = tonumber(str[3])
            local allStoneNum = ItemsModel:getItemNumById(str[2])
            local tempStoneCost = self.tempCost[tostring(str[2])] or 0
            if allStoneNum >= stoneCost + tempStoneCost then
                tempCost[tostring(str[2])] = stoneCost
                self.isStoneNotEnough = false
            else
                self.isStoneNotEnough = true
                canEnhance = false
            end
        elseif tonumber(str[1]) == 3 then -- 铜钱   
            local coinCost = tonumber(str[2])
            local allCoinNum = UserModel:getCoin()
            local tempCoinCost = self.tempCost[tostring(str[1])] or 0
            if allCoinNum >= coinCost + tempCoinCost then
                tempCost[tostring(str[1])] = coinCost
            else
                canEnhance = false
            end
        end
    end

    if canEnhance then
        for k,v in pairs(tempCost) do
            if self.tempCost[k] then
                self.tempCost[k] = self.tempCost[k] + v
            else
                self.tempCost[k] = v
            end
        end
        self.addLevel[tostring(equipmentId)] = self.addLevel[tostring(equipmentId)] + 1
    else
        if self.addLevel[tostring(equipmentId)] == 0 then
            if self.isStoneNotEnough then
                self.canEnhanceStatus[equipmentId].tipsCondition = {_type = 1, _value = equipmentEnhanceStoneId}
            else
                self.canEnhanceStatus[equipmentId].tipsCondition = {_type = 3}
            end    
        end
    end
end

--计算一键升级 最多可生的级数
function PartnerEquipmentEnhanceView:getMaxEnhance(equipmentId)
    equipmentId = equipmentId or self.selectEquipmentId
    local equData = FuncPartner.getEquipmentById(equipmentId)
    local _equipData = self:getEquipmentData(equipmentId)
    local addLevel = 0
    local isAdd = true
    local _level = _equipData.level
    local logs = {}
    while isAdd do
        local _equData = equData[tostring(_level)]
        if _equData.needLv > self.data.level or _equData.qualityCost then
            --伙伴等级判断  升品等级等级判断
            isAdd = false
            break
        end
        local costVec = _equData.lvCost or _equData.qualityCost;
        if not costVec then -- 此时已manji
            isAdd = false
            break
        end
        for i,v in pairs(costVec) do
            local str = string.split(v,",")
            if tonumber(str[1]) == 1 then
                local num = 0
                if logs[str[2]] then
                    if logs[str[2]] - tonumber(str[3]) < 0 then
                        isAdd = false
                    else
                        logs[str[2]] = logs[str[2]] - tonumber(str[3])
                    end
                else    
                    num = ItemsModel:getItemNumById(str[2]) - tonumber(str[3])
                    if num < 0 then
                        isAdd = false  
                        -- 装备强化石不足
                        if tostring(str[2]) == equipmentEnhanceStoneId then
                            self.isStoneNotEnough = true
                        end
                    else
                        logs[str[2]] = num
                    end

                end
            elseif  tonumber(str[1]) == 3 then -- 铜钱   
                if logs[str[1]] then
                    if logs[str[1]] - tonumber(str[2]) < 0 then
                        isAdd = false
                    else
                        logs[str[1]] = logs[str[1]] - tonumber(str[2])
                    end
                else
                    local num = UserModel:getCoin() - tonumber(str[2])
                    if num < 0 then
                        isAdd = false
                    else
                        logs[str[1]] = num
                    end
                end
            end
        end
        if isAdd then
            self.isStoneNotEnough = false
            _level = _level + 1
            addLevel = addLevel + 1
        end 
    end
    return addLevel
end
--道具强化 1一键满级 2强化
function PartnerEquipmentEnhanceView:equipmentEnhanceTap(_type,isQuality)
    local equipData = self:getEquipmentData(self.selectEquipmentId)
    local costRes,itemId,costNum = self:enhanceCostEnough(equipData.level)
    local costKinds = self.costItemKinds
    local isLevelLimit = self:equipLevelLimit(self.selectEquipmentId)
    local equCfgData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    equCfgData = equCfgData[tostring(equipData.level)]
    local isMaxLevel = PartnerModel:equipLevelMax(self.selectEquipmentId,equipData.level)
    echo("----------11111111111111111-------------",costRes,isLevelLimit,isMaxLevel)
    if costRes == 0 and isLevelLimit and isMaxLevel == false then --满足条件
        echo("----------2222222222222-------------")
        local addLevel = 1

        local _param = {}
        _param.partnerId = tostring(self.data.id)
        _param.equips = {}
        _param.equips[self.selectEquipmentId] = addLevel 

        FuncPartner.playPartnerBtnSound()
        if isQuality and _type == 2 then
            self.animType = ANIM_TYPY.JINJIE
        else
            self.animType = ANIM_TYPY.QIANGHHUA 
        end
       -- echo("此时 动画 type ==== ",self.animType)
        self.oldPower = CharModel:getCharOrPartnerAbility(self.partnerId);
        if FuncPartner.isChar(self.data.id) then
            EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT, 1)
            self.beforEquipAttr = CharModel:getCharAttr()
            CharServer:equipUpLevel(_param,c_func(self.equipmentEnhanceTapCallBackAddAnim,self,costKinds,{self.selectEquipmentId},self.animType))
        else
            EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT, 1)
            self.beforEquipAttr = PartnerModel:getPartnerAttr(self.data.id)
            PartnerServer:equipUpgradeRequest(_param,c_func(self.equipmentEnhanceTapCallBackAddAnim,self,costKinds,{self.selectEquipmentId},self.animType))
        end
    else
        echo("-------ddddd---2222222222222-------------")
        local levelOk ,levelLimit = self:equipLevelLimit(self.selectEquipmentId)
        if isMaxLevel == true then --装备以满级 
            WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_007"))
        elseif costRes == 1 or costRes == 11 then --道具不满足
            echo("PartnerEquipmentEnhanceView_______itemId 获取数量=33===",itemId,costNum)
            -- 快捷购买
            if itemId == equipmentEnhanceStoneId or self.isStoneNotEnough then
                WindowControler:showWindow("QuickBuyItemMainView", equipmentEnhanceStoneId)
            else
                WindowControler:showWindow("GetWayListView", itemId, costNum);
            end
            -- WindowControler:showTips(GameConfig.getLanguage("#tid_partner_29"))
        elseif levelOk == false then --等级条件
            local name = ""
            if FuncPartner.isChar(tonumber(self.data.id)) then
                name = GameConfig.getLanguage("#tid_partner_ui_003")
            else
                name = FuncPartner.getPartnerName(self.data.id)
            end
            local str = GameConfig.getLanguageWithSwap("#tid_partner_33",name,levelLimit)
            WindowControler:showTips(str) 
        elseif costRes == 2 or costRes == 12 then -- 金币不满足  
            WindowControler:showTips(GameConfig.getLanguage("#tid_common_notEnoughCoin"))
            FuncCommUI.showCoinGetView() 
            -- WindowControler:showTips(GameConfig.getLanguage("#tid1557"))
        elseif b == false then  -- 一键满级
            WindowControler:showTips(GameConfig.getLanguage("#tid1560")) 
        end
    end
end

function PartnerEquipmentEnhanceView:equipmentEnhanceTapCallBackAddAnim(costKinds,equipsId,animType,event)
    if event.error then
        EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
        return 
    end

    self.data = PartnerModel:getPartnerDataById(self.data.id)

    if FuncPartner.isChar(self.data.id) then
        self.afterEquipAttr = CharModel:getCharAttr()
    else
        self.afterEquipAttr = PartnerModel:getPartnerAttr(self.data.id)
    end

    local addAttr = FuncPartner.getPartnerAddAttr(self.beforEquipAttr,self.afterEquipAttr)

    -- 添加效果
    FuncPartner.playPartnerZhangbeiqianghuaSound()

    -- 添加动画
    -- dump(self.equipmentVec, "-----xxxxxx----", 4)
    for i,v in pairs(equipsId) do
        if self.equipmentVec[v] and self.equipmentPosVec[v] then
            self:addAnim(self.equipmentVec[v],animType,self.equipmentPosVec[v],costKinds,nil,v)
        end
    end
    
    self:delayCall(function ()
            self:equipPositionAttr(animType, addAttr, equipsId)
        end, 5/GameVars.GAMEFRAMERATE)
    self:delayCall(function ()
            self:equipmentEnhanceTapCallBack()
            FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAOGUANG, self.panel_5.ctn_anim, 1, 2.5, {x = 1.25, y = 1.4})
        end, 30/GameVars.GAMEFRAMERATE)
    self:delayCall(function ()
            self:playPowerChangedAnim()
        end, 35/GameVars.GAMEFRAMERATE)

    if FuncPartner.isChar(self.data.id) then
        self.beforEquipAttr = CharModel:getCharAttr()
    else
        self.beforEquipAttr = PartnerModel:getPartnerAttr(self.data.id)
    end
end

--更新战力
function PartnerEquipmentEnhanceView:updatePower()
    local _ability = CharModel:getCharOrPartnerAbility(self.partnerId)
    self.panel_power.UI_number:setPower(_ability)
    self.oldAbility = _ability
end

function PartnerEquipmentEnhanceView:equipmentEnhanceTapCallBack()
    self.data = PartnerModel:getPartnerDataById(self.data.id)
    self:setPartnerInfo(self.data)

    local _curAbility = CharModel:getCharOrPartnerAbility(self.partnerId)
    self:refreshPower(_curAbility, self.oldAbility)
    self.oldAbility = _curAbility
end

--更新奇侠界面右上角战力
function PartnerEquipmentEnhanceView:refreshPower(_curPower, _oldPower)
    local frame = _curPower - _oldPower
    if frame > 20 then
        frame = 20
    end

    for i = 1, frame do
        self:delayCall(function ()
                local num = math.floor((_curPower - _oldPower) * 1.0 / frame * i) + _oldPower
                self.panel_power.UI_number:setPower(num)
            end, i / GameVars.GAMEFRAMERATE)
    end 
end

--强化消耗是否满足  0 可以升级或升阶
--                  1--强化消耗碎片不满足  2--强化消耗金币 不足
--                  11--升阶消耗碎片不满足  12--升阶消耗金币 不足
function PartnerEquipmentEnhanceView:enhanceCostEnough(_level,_equipId)
    local equipId = _equipId or self.selectEquipmentId
    local equData = FuncPartner.getEquipmentById(equipId)
    equData = equData[tostring(_level)]
    local costVec = equData.lvCost or equData.qualityCost;
    local _type = 0
    if equData.qualityCost then
        _type = 10 --现在是升品状态
    end

    if equData.qualityCost and equData.needLv > self.data.level then
        return -1
    end
    if costVec == nil then
        return 3
    end
    self.costItemKinds = 0
    local __type = 0
    for i = #costVec,1,-1 do
        local v = costVec[i]
        local str = string.split(v,",")
        if tonumber(str[1]) == 1 then
            local num = ItemsModel:getItemNumById(str[2])
            self.costItemKinds = self.costItemKinds + 1
            if num < tonumber(str[3]) then 
                self.costItemKinds = 0
                self:checkIsStoneEnough( table.deepCopy(costVec))
                return 1+_type , str[2] ,tonumber(str[3])
            end
        elseif  tonumber(str[1]) == 3 then -- 铜钱   
            if tonumber(str[2]) > UserModel:getCoin() then
                self.costItemKinds = 0
                __type = 2+_type 
            end
        end
    end
    return __type, _type
end

-- 检测强化石是否充足
function PartnerEquipmentEnhanceView:checkIsStoneEnough( costVec )
    local __type = 0
    for i = #costVec,1,-1 do
        local v = costVec[i]
        local str = string.split(v,",")
        if tonumber(str[1]) == 1 and str[2] == equipmentEnhanceStoneId then
            local num = ItemsModel:getItemNumById(str[2])
            if num < tonumber(str[3]) then 
                self.isStoneNotEnough = true
                return 
            else
                self.isStoneNotEnough = false
            end
        end
    end
end
--铜钱变化刷新
function PartnerEquipmentEnhanceView:coinChangeRefresh()
    -- self.data = PartnerModel:getPartnerDataById(self.data.id)
    -- local equipData = self:getEquipmentData(self.selectEquipmentId) 
    -- local equLevel = equipData.level -- 装备等级
    -- local equData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    -- equData = equData[tostring(equLevel)]
    -- local costVec = equData.lvCost or equData.qualityCost;
    -- if costVec then
    --     for i,v in pairs(costVec) do
    --         local str = string.split(v,",")
    --         if  tonumber(str[1]) == 3 then -- 铜钱   
    --             if tonumber(str[2]) > UserModel:getCoin() then
    --             else
    --             end
    --         end
    --     end
    -- end
    self:refreshCostView()
    self:refreshBtn()
end
--道具变化刷新UI
function PartnerEquipmentEnhanceView:refreshUI()
    WindowControler:globalDelayCall(c_func(function()
        local partnerData = FuncPartner.getPartnerById(self.data.id);
        local equipCfg = FuncPartner.getPartnerEquipment( self.data.id )
        local notChangeLevel = true
        self:initEquipment(equipCfg, notChangeLevel)
        self:refreshCostView()
    end),0.1)
end
function PartnerEquipmentEnhanceView:registerEvent()
    PartnerEquipmentEnhanceView.super.registerEvent();
    -- self.btn_qianghua:setTap(c_func(self.equipmentEnhanceTap,self,2))
    -- self.btn_jinjie:setTap(c_func(self.equipmentEnhanceTap,self,2))
    self.btn_qianghua:disableClickSound()
    self.btn_jinjie:disableClickSound()

    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.coinChangeRefresh, self);
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.refreshUI, self);  

    EventControler:addEventListener(UserEvent.USER_INFO_CHANGE_EVENT, self.refreshUI, self)
    --EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_LEVEL_CHANGE_EVENT, self.equipmentEnhanceTapCallBack, self);
    
    EventControler:addEventListener(PartnerEvent.PARTNER_EQUIPMENT_AWAKE_EVENT, self.equipmentEnhanceTapCallBack, self)
    --装备觉醒结束 回到主界面
    EventControler:addEventListener(PartnerEvent.PARTNER_EQUIPMENT_AWAKE__BACK_EVENT, self.equipmentAwakedBack, self)
end

function PartnerEquipmentEnhanceView:equipmentAwakedBack()
    local animType = ANIM_TYPY.AWAKE
    self:playPowerChangedAnim()

    if FuncPartner.isChar(self.data.id) then
        self.afterEquipAttr = CharModel:getCharAttr()
    else
        self.afterEquipAttr = PartnerModel:getPartnerAttr(self.data.id)
    end

    --通过之前的属性以及当前的属性 获取增加的属性列表
    local addAttr = FuncPartner.getPartnerAddAttr(self.beforEquipAttr,self.afterEquipAttr)
    self:equipPositionAttr(animType, addAttr)

    --更新当前的属性
    if FuncPartner.isChar(self.data.id) then
        self.beforEquipAttr = CharModel:getCharAttr()
    else
        self.beforEquipAttr = PartnerModel:getPartnerAttr(self.data.id)
    end
end

-- 装备位 属性
function PartnerEquipmentEnhanceView:equipPositionAttr(animType, addAttr, equipIds)
    self:playSuccessAinms(addAttr, animType, equipIds)
    FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.LIHUI_GUANG, self.panel_bao.ctn_1)
end

--获取带颜色的装备名字
function PartnerEquipmentEnhanceView:getEquipNameStringByIdAndLevel(equipId, level)
    --装备名称
    local equData = FuncPartner.getEquipmentById(equipId)
    equData = equData[tostring(level)]

    local nameColor = equData.nameColor

    nameColor = string.split(nameColor,",")
    local colorFrame = FuncPartner.colorFrame[tonumber(nameColor[1])]
    local _equipName = PartnerModel:getEquipNameById(self.data.id, equipId)
    
    local nameStr = ""
    if tonumber(nameColor[2]) > 1 then
        local colorNum = tonumber(nameColor[2]) - 1
        nameStr = GameConfig.getLanguage(_equipName).." +"..colorNum
    else
        nameStr = GameConfig.getLanguage(_equipName)
    end

    return string.format(colorFrame, nameStr)
end

--进阶时需要显示 装备名字的tips
function PartnerEquipmentEnhanceView:getAdvanceAdditionTips(_equipId)
    local string = nil
    -- if not self.isSkillledPlayerForAdvance then
        local equipmentData = self:getEquipmentData(_equipId)
        local old_str = self:getEquipNameStringByIdAndLevel(_equipId, equipmentData.level - 1)
        local cur_str = self:getEquipNameStringByIdAndLevel(_equipId, equipmentData.level)
        string = old_str.." [partner/partner_img_jiantou.png] "..cur_str
    -- end
    return string
end

function PartnerEquipmentEnhanceView:playSuccessAinms(addAttr, animType, equipIds)
    local attr_str = {}

    local params = {}
    local effectType = nil
    local ctn = nil
    if animType == ANIM_TYPY.QIANGHHUA then
        ctn = self.ctn_piaozi
        effectType = FuncCommUI.EFFEC_NUM_TTITLE.STRENDTHENING
        self.ctn_piaozi:setVisible(true)
        self.ctn_piaozi2:setVisible(false)
    elseif animType == ANIM_TYPY.JINJIE then
        ctn = self.ctn_piaozi2
        effectType = FuncCommUI.EFFEC_NUM_TTITLE.ADVANCED
        self.ctn_piaozi:setVisible(false)
        self.ctn_piaozi2:setVisible(true)

        for i,v in ipairs(equipIds) do
            table.insert(attr_str, self:getAdvanceAdditionTips(v))
        end
    elseif animType == ANIM_TYPY.AWAKE then
        ctn = self.ctn_piaozi2
        effectType = nil
        self.ctn_piaozi:setVisible(false)
        self.ctn_piaozi2:setVisible(true)
    end
    
    local attr_table = FuncBattleBase.formatAttribute(addAttr)
    for i,v in ipairs(attr_table) do
        local str = v.name.."+"..v.value
        table.insert(attr_str, str)
    end
    params.scale = 0.7
    -- params.scale_Size = {width = 50, height = 50}
    params.text = attr_str
    params.cellNoOffsetY = true

    params.isEffectType = effectType
    FuncCommUI.playNumberRunaction(ctn, params)
end

function PartnerEquipmentEnhanceView:playPowerChangedAnim()
    local power = CharModel:getCharOrPartnerAbility(self.partnerId);
    FuncCommUI.showPowerChangeArmature(self.oldPower or 10, power or 10)
end

return PartnerEquipmentEnhanceView
