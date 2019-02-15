local PartnerUpQualityView = class("PartnerUpQualityView", UIBase)
local touchNodeWeight = 420
local touchNodeHeight = 420
local nodeDis = 50
function PartnerUpQualityView:ctor(winName)
	PartnerUpQualityView.super.ctor(self, winName)
end
function PartnerUpQualityView:tipsUI(ctn,_type)
    local _weight = 100
    local _height = 35
    if _type == FuncPartner.TIPS_TYPE.QUALITY_TIPS then --品质 名字
        _weight = 150
    elseif _type == FuncPartner.TIPS_TYPE.PARTNER_TYPE_TIPS then -- 类型
        _weight = 50
        _height = 50
    elseif _type == FuncPartner.TIPS_TYPE.STAR_TIPS then -- 星级
        _weight = 200
        _height = 40
    elseif _type == FuncPartner.TIPS_TYPE.POWER_TIPS then -- 战力
        
    elseif _type == FuncPartner.TIPS_TYPE.DESCRIBE_TIPS then -- 描述
        
    elseif _type == FuncPartner.TIPS_TYPE.LIKABILITY_TIPS then -- 好感度
    end
    local node = FuncRes.a_white( _weight,_height)
    ctn:removeAllChildren()
    ctn:addChild(node,10000)
    node:opacity(0)
    if FuncPartner.isChar(self.data.id) and 
    _type == FuncPartner.TIPS_TYPE.PARTNER_TYPE_TIPS then 
        node:setTouchedFunc(function ()
            WindowControler:showWindow("PartnerCharDWTiShiView")
        end)
    else
        -- self:delayCall(function ()
            
        -- end,0.01)
        FuncCommUI.regesitShowPartnerTipView(node,{_type = _type,id = self.data.id})
    end
    
end

function PartnerUpQualityView:updateBg()
    -- 背景
    self.bgId = self.data.id
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

function PartnerUpQualityView:updateTitleView()
    ----------- 伙伴信息 ------------
    self.UI_title:updateUI(self.data.id)
end

function PartnerUpQualityView:updataUI(data)
    if LS:prv():get(StorageCode.partner_skilledForUpQuality) then
        self.isSkillledPlayer = true
    else
        if PartnerModel:isSkilledPlayerForUpQuality() then
            self.isSkillledPlayer = true
        else
            self.isSkillledPlayer = false
        end
    end

    
	self.data = data
    local partnerData = FuncPartner.getPartnerById(self.data.id);
    -----  npc ------
    
    if self.currentLihuiId and self.currentLihuiId == self.data.id
    and self.currentLihui and not self.moveLihui then
        self.currentLihui:pos(self.lihuiPosX,self.lihuiPosY)
        self.currentLihui:runAction(act.fadein(0))
    else
        local ctn = self.ctn_lihui;
        ctn:removeAllChildren();
        local sp = FuncPartner.getPartnerOrCgarLiHui(self.data.id,self.data.skin)
        self.lihuiPosX = sp:getPositionX()
        self.lihuiPosY = sp:getPositionY()
        self.currentLihui = sp 
        self.currentLihuiId = self.data.id
        ctn:addChild(sp);

        self.panel_kong:setTouchedFunc(c_func(self.openPartnerInfoUI,self),nil,nil,nil,nil,false)
        self.panel_kong1:setTouchedFunc(c_func(self.openPartnerInfoUI,self),nil,nil,nil,nil,false)
    end
    self:updateBg()

    --等级
    
    self.panel_level:visible(true)
    self.panel_level.txt_bing:setString(self.data.level .. GameConfig.getLanguage("#tid_partner_ui_013"))

    ----------- 升品消耗 ------------
    self:initUpQualityCostList()
    -- 升品增加战力
    local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
    local upQualityData;
    for i,v in pairs(upQualityDataVec) do
        if v.quality == self.data.quality then
            upQualityData = v;
            break
        end
    end

    -- if self.isSkillledPlayer then
    --     self.panel_fuyong:setVisible(false)
    -- else
    --     self.panel_fuyong:setVisible(true)
    -- end
    
    -- 升级红点
    self:updateUpgradeRedPoint()
end
function PartnerUpQualityView:lovesTap(  )
    local a,b,c,d = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.LOVE)
    echo("b",b," d =",d)
    if a then
        WindowControler:showWindow("NewLovePartnerView",self.data.id)
    else
        --
        local str = GameConfig.getLanguageWithSwap("#tid_partner_32",b)
        WindowControler:showTips(str)
    end
    
end

function PartnerUpQualityView:refreshPower(_curPower, _oldPower, partnerId)
    local frame = _curPower - _oldPower
    if frame > 30 then
        frame = 30
    end

    for i = 1, frame do
        self:delayCall(function ()
                if partnerId and tostring(self.data.id) ~= tostring(partnerId) then
                    return
                end
                local num = math.floor((_curPower - _oldPower) * 1.0 / frame * i) + _oldPower
                self.panel_power.UI_number:setPower(num)
            end, i / GameVars.GAMEFRAMERATE)
    end 
    -- self.panel_power.UI_number:setPower(_ability)  
end

function PartnerUpQualityView:initUpQualityCostList()
    if not self.data.id then
        return 
    end
    echo("此时奇侠id-== ",self.data.id)
    local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
    local upQualityData = upQualityDataVec[tostring(self.data.quality)]
    local upQualityCostVec = upQualityData.pellet;
    local allUser = false
    local quickQuality = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_QUICKQUALITY)
    for i = 1,4 do
        local frame = self:getItemFrame(i,upQualityCostVec[i])
        if frame == 2 or frame == 3 then
            allUser = true and quickQuality
        end
        local item = self["UI_"..i]
        local pos = PartnerModel:getUpqualityPosition(upQualityCostVec[i],self.data.id)
        item:setResource({pos = pos,itemId = upQualityCostVec[i] ,frame = frame,partnerId = self.data.id ,isShowNum = false,isPlaySound = true })
        item:numVisible(false)
    end
    self:coinCostAndBtnRefresh(allUser)
end
-- 升品合成按钮和铜钱消耗刷新
function PartnerUpQualityView:coinCostAndBtnRefresh(allUser)
    local partData = PartnerModel:getPartnerDataById(self.data.id)
    self.data = partData
    -- 铜钱消耗
    self:coinCostOrCondition()
    -- 升品按钮
    if FuncPartner.getPartnerMaxQuality( self.data.id ) == self.data.quality 
        and self.data.position == 15 then -- 已圆满状态

        self.mc_sp:showFrame(2)
    else -- 未圆满状态
        local animName = ""    
        self.btnAnimShow = false
        if self:canUpQuality(false) then -- 可升品状态
            self.mc_sp:showFrame(1)
            animName = "anim1"
            if PartnerModel:getRedPoindKaiGuanById(self.data.id) == false then
                self.mc_sp.currentView.btn_1:getUpPanel().panel_red:visible(false)
            else
                self.mc_sp.currentView.btn_1:getUpPanel().panel_red:visible(true)
            end
            
            self.btnAnimShow = true
            self.mc_sp.currentView.btn_1:setTap(c_func(self.combineTap,self))
        else
            if allUser == true and self.isSkillledPlayer then -- 一键食用
                self.mc_sp:showFrame(3)
                animName = "anim3"
                if PartnerModel:getRedPoindKaiGuanById(self.data.id) == false then
                    self.mc_sp.currentView.btn_1:getUpPanel().panel_red:visible(false)
                else
                    self.mc_sp.currentView.btn_1:getUpPanel().panel_red:visible(true)
                end
                self.btnAnimShow = true
                self.mc_wenben:visible(false)
                self.mc_sp.currentView.btn_1:setTap(c_func(self.allUserTap,self))
            else
                self.mc_sp:showFrame(1)
                animName = "anim1"
                self.mc_sp.currentView.btn_1:getUpPanel().panel_red:visible(false)

                self.mc_sp.currentView.btn_1:setTap(c_func(self.combineTap,self))
            end               
        end
        
        local ctn_btnAnim = self.mc_sp.currentView.btn_1:getUpPanel().ctn_btnAnim
        self.liuGuangAnim = ctn_btnAnim:getChildByName(animName)
        if not self.liuGuangAnim then 
            local liuGuangAnim = self:createUIArmature("UI_anniuliuguang", "UI_anniuliuguang_zong", ctn_btnAnim, true)
            liuGuangAnim:setScaleY(1.32)
            liuGuangAnim:setScaleX(1.12)
            liuGuangAnim:pos(-2, 0)
            liuGuangAnim:setName(animName)
            self.liuGuangAnim = liuGuangAnim
        end

        self.liuGuangAnim:visible(self.btnAnimShow)
        self.mc_sp.currentView.btn_1:disableClickSound()
    end
end
--金币消耗或显示不满足条件
function PartnerUpQualityView:coinCostOrCondition()
    local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
    local upQualityData = upQualityDataVec[tostring(self.data.quality)]
    local isEnough,needLevel = self:enoughLevel()
    local isMaxQulity = self:isMaxQuility()
    if isEnough == false  then
        if needLevel and not isMaxQulity then
            if not self.btnsHide then
                self.mc_wenben:visible(true)
            end

            self.mc_wenben:showFrame(2)
            local str = "奇侠";
            if FuncPartner.isChar(self.data.id) then
                str = "主角";
            end
            -- 策划缺 不显示
            self.mc_wenben.currentView.txt_1:setString("")
        else    
            self.mc_wenben:visible(false)
        end
        
    else
        if not self.btnsHide then
            self.mc_wenben:visible(true)
        end
        if upQualityData.coin > UserModel:getCoin() then
            self.mc_wenben:showFrame(1)
            self.mc_wenben.currentView.mc_red5000:showFrame(2)
            self.mc_wenben.currentView.mc_red5000.currentView.txt_1:setString(upQualityData.coin)
        else
            self.mc_wenben:showFrame(1)
            self.mc_wenben.currentView.mc_red5000:showFrame(1)
            self.mc_wenben.currentView.mc_red5000.currentView.txt_1:setString(upQualityData.coin)
        end
    end    
end

function PartnerUpQualityView:getItemFrame(index,itemId,nowResetNum)
    local positions = {}
    local partData = PartnerModel:getPartnerDataById(tostring(self.data.id))
    local value = partData.position or 0
    while value ~= 0 do
		local num = value % 2;
		table.insert(positions, 1, num);
		value = math.floor(value / 2);
	end
    for i = 1 ,4 do
        if positions[i] == nil then
            table.insert(positions, 1, 0);
        end
    end
    -- 判断是否已装备
    if positions[index] and positions[index] == 1 then
        return 1 
    end
    -- 判断是否可装备 
    -- 新需求 满足可合成的道具也可一键装备
    
    if ItemsModel:getItemNumById(itemId) > 0 then
        return 2
    end
    -- 判断此道具    
    -- 判断是否可合成
    local enough = PartnerModel:isCombineQualityItem(itemId,nil,nowResetNum)
    if enough == 3 then
        return 3
    end
    return 4

end

-- 是否可升品  1表示 装备位没有装满 2表示 伙伴等级不满足 3表示 已升到最高品 4表示 铜钱不足
function PartnerUpQualityView:canUpQuality(isYJSY)
    isYJSY = isYJSY or false
    if self.data.position == 15 or isYJSY then
        -- 判断升级是否满足等级
        local ennoughLevel,needLevel = self:enoughLevel()
        if ennoughLevel then
            local maxQuality = FuncPartner.getPartnerMaxQuality( self.data.id )
            if maxQuality > self.data.quality then
                local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
                local upQualityData = upQualityDataVec[tostring(self.data.quality)]
                if upQualityData.coin > UserModel:getCoin() then
                    return false,4,upQualityData.coin
                else
                    return true
                end
            else
                return false,3,self.data.quality
            end
        else    
            if needLevel then
                return false,2,needLevel
            else
                return false,3,self.data.quality
            end
        end
        return false
    else
        return false,1,self.data.position
    end
end
--升品条件 是否满足升品等级
function PartnerUpQualityView:enoughLevel()
    local currentPartnerLevle = self.data.level
    local upQualityDataVec = FuncPartner.getPartnerQuality(tostring(self.data.id))[tostring(self.data.quality)]
    local needPartnerLevle = upQualityDataVec.partnerLv;
    local maxQuality = FuncPartner.getPartnerMaxQuality( self.data.id )
    if self:isMaxQuility() then
        -- 此时达到满级
        return false,needPartnerLevle
    end

    if needPartnerLevle > currentPartnerLevle then
        return false,needPartnerLevle,currentPartnerLevle
    else
        return true,needPartnerLevle,currentPartnerLevle
    end
end
-- 判断是否到达最大品质
function PartnerUpQualityView:isMaxQuility()
    local maxQuality = FuncPartner.getPartnerMaxQuality(self.data.id)
    if maxQuality <= self.data.quality then
        -- 此时达到满级
        return true
    else
        return false
    end
end

function PartnerUpQualityView:openPartnerInfoUI()
    FuncPartner.playPartnerInfoSound( )
    -- WindowControler:showWindow("PartnerInfoUI",self.data.id)
    EventControler:dispatchEvent(PartnerEvent.PARTNER_CHANGEQINGBAO_EVENT)
end

function PartnerUpQualityView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
end


function PartnerUpQualityView:setAlignment()
	--设置对齐方式
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_power, UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_love, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_taolun, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_zj, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_sp, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_wenben, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_title, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_level, UIAlignTypes.Right)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_pf, UIAlignTypes.LeftBottom)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_bg, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_lihui, UIAlignTypes.MiddleBottom)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_kong, UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_kong1, UIAlignTypes.MiddleBottom)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_2, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_3, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_4, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_fuyong, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.scale9_shizidi, UIAlignTypes.Right)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_piaozi2, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_piaozi1, UIAlignTypes.MiddleBottom)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_di1, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_di2, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_di3, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_di4, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_yanshi, UIAlignTypes.LeftTop)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_shengpin, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_level, UIAlignTypes.MiddleBottom)

    self.panel_di1:visible(false)
    self.panel_di2:visible(false)
    self.panel_di3:visible(false)
    self.panel_di4:visible(false)

    self.leftBtnPos = {
        {x = self.btn_taolun:getPositionX(), y = self.btn_taolun:getPositionY()}, 
        {x = self.btn_zj:getPositionX(), y = self.btn_zj:getPositionY()}, 
        {x = self.btn_pf:getPositionX(), y = self.btn_pf:getPositionY()}
    }

    dump(self.leftBtnPos, "\n\nself.leftBtnPos=====")
end

function PartnerUpQualityView:updateUIWithPartner(_partnerInfo)
    --只有在必要的时候才会刷新
    local  _hasChanged=false
    if(not self._partnerInfo or self._partnerInfo.id ~= _partnerInfo.id)then
        --如果原来没有目标伙伴
        self._partnerInfo = _partnerInfo;
        _hasChanged=true
    else 
        --否则开始计算两者之间的差异
        self._partnerInfo = _partnerInfo
        _hasChanged=true
    end
    --如果没有发生任何的变化,则直接返回
    if not _hasChanged then
        return
    end
       
    --更新UI信息
    self:updataUI(_partnerInfo);

    -- 添加置灰效果
    local open,value,valueType = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SHENGJI)
    if not open and not FuncPartner.isChar(_partnerInfo.id) then
        FilterTools.setGrayFilter(self.panel_level)
    else
        FilterTools.clearFilter(self.panel_level)
    end

    self:updateLeftButtons()
    self:updateSkillDisplayBtn()
    self:updateTitleView()
    
    self.beforProperty = self:getPartnerProperty()

    if FuncPartner.isChar(self.data.id) then
        self.beforQualityAttr = CharModel:getCharAttr()
    else
        self.beforQualityAttr = PartnerModel:getPartnerAttr(self.data.id)
    end

    self:resumeUIClick()

    --显示战力
    local _ability = CharModel:getCharOrPartnerAbility(self.data.id)
    self.panel_power.UI_number:setPower(_ability)
    --用于战力特效的显示
    self.oldAbility = _ability
    --用于右上角战力的变化显示
    self.oldAbility2 = _ability
    FuncCommUI.regesitShowPartnerTipView(self.panel_power,{id = self.data.id,_type = FuncPartner.TIPS_TYPE.POWER_TIPS})
end

--左下角按钮 更新与加载
function PartnerUpQualityView:updateLeftButtons()
    local showBtns = {}
    local width1 = 70
    local width2 = 80
    -- 判断是否开启
    if FuncPartner.isChar(self.data.id) then
        self.btn_taolun:setVisible(false)
        self.btn_zj:setVisible(false)

        if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GARMENT) then
            self.btn_pf:visible(true)
            table.insert(showBtns, self.btn_pf)
        else
            self.btn_pf:visible(false)
        end
    else
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
    end

    for i,v in ipairs(showBtns) do
        v:pos(self.leftBtnPos[i].x, self.leftBtnPos[i].y)
    end

    self.btn_pf:getUpPanel().panel_red:visible(false)
    self.btn_taolun:getUpPanel().panel_red:visible(false)
end

function PartnerUpQualityView:updateSkillDisplayBtn()
    local showId = FuncPartner.getPartnerShowIdByPartnerId(self.data.id)
    if showId then
        self.btn_yanshi:setVisible(true)
        self.btn_yanshi:setTouchedFunc(function ()
                local controler = MiniBattleControler.getInstance()
                controler:showMiniBattle(showId)       
            end)
    else
        self.btn_yanshi:setVisible(false)
    end
end

--更新奇侠传记按钮状态
function PartnerUpQualityView:updateBiographyStatus()
    if BiographyModel:hasPickUpTask(self.data.id) then
        self.btn_zj:getUpPanel().mc_1:showFrame(2)
    else
        self.btn_zj:getUpPanel().mc_1:showFrame(1)
    end

    local isShowRed = PartnerModel:isShowBiographyRedPoint(self.data.id)
    self.btn_zj:getUpPanel().panel_red:visible(isShowRed)
end

--更新升级按钮上的红点
function PartnerUpQualityView:updateUpgradeRedPoint()
    -- 升级红点
    local ctn_red = self.panel_level.btn_yuanjjia:getUpPanel().panel_red
    if PartnerModel:isShowUpgradeRedPoint(self.data.id) then
        ctn_red:visible(true)
    else
        ctn_red:visible(false)
    end
end

--更新升级按钮上的显示等级
function PartnerUpQualityView:changePartnerLevel(event)
    self.data = PartnerModel:getPartnerDataById(self.data.id)

    if event.params and event.params.oldLevel then
        local curLevel = self.data.level
        local oldLevel = event.params.oldLevel
        local frame = curLevel - oldLevel
        if frame > 30 then
            frame = 30
        end

        for i = 1, frame do
            self:delayCall(function ()
                    if event.params and tostring(self.data.id) ~= tostring(event.params.id) then
                        return
                    end
                    local num = math.floor((curLevel - oldLevel) * 1.0 / frame * i) + oldLevel
                    self.panel_level.txt_bing:setString(num .. GameConfig.getLanguage("#tid_partner_ui_013"))
                end, i / GameVars.GAMEFRAMERATE)
        end
    else
        self.panel_level.txt_bing:setString(self.data.level .. GameConfig.getLanguage("#tid_partner_ui_013"))
    end

    local _ability = CharModel:getCharOrPartnerAbility(self.data.id)
    local oldAbility2 = self.oldAbility2
    self:refreshPower(_ability, oldAbility2, event.params.id)
    self.oldAbility2 = _ability
end

function PartnerUpQualityView:changePartnerSkin( )
    self.data = PartnerModel:getPartnerDataById(self.data.id)
    self:updateBg()
    local ctn = self.ctn_lihui;
    ctn:removeAllChildren();
    local sp = FuncPartner.getPartnerOrCgarLiHui(self.data.id,self.data.skin)
    self.lihuiPosX = sp:getPositionX()
    self.lihuiPosY = sp:getPositionY()
    ctn:addChild(sp);
    self.currentLihui = sp


    self.panel_kong:setTouchedFunc(c_func(self.openPartnerInfoUI,self),nil,nil,nil,nil,false)
    self.panel_kong1:setTouchedFunc(c_func(self.openPartnerInfoUI,self),nil,nil,nil,nil,false)
    
    -- 刷新战力
    local _ability = CharModel:getCharOrPartnerAbility(self.data.id)
    local oldAbility2 = self.oldAbility2
    self:refreshPower(_ability, oldAbility2)
    self.oldAbility2 = _ability
end

function PartnerUpQualityView:registerEvent()
    PartnerUpQualityView.super.registerEvent();
    EventControler:addEventListener(PartnerEvent.PARTNER_ATTR_CHANGE_EVENT,self.qualityPositionAttr,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_POSITION_CHANGE_EVENT,self.quailityPositionChange,self)
    EventControler:addEventListener(UserEvent.USEREVENT_QUALITY_POSITION_CHANGE,self.quailityPositionChange,self)
    -- EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.initUpQualityCostList,self)
    --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.initUpQualityCostList, self);
    --等级发生变化
    EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT,self.changePartnerLevel,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT, self.initUpQualityCostList, self);
    EventControler:addEventListener(PartnerEvent.PARTNER_LEVEL_RED_EVENT, self.updateUpgradeRedPoint, self);
    
    -- 升品成功刷新
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_CHANGE_EVENT, self.combineTapCallBack, self);
    EventControler:addEventListener(UserEvent.USEREVENT_QUALITY_CHANGE, self.combineTapCallBack, self);

    -- 红点开关
    EventControler:addEventListener(PartnerEvent.PARTNER_REDPOINT_ZONGKAIGUAN_EVENT, self.refreshRedShowDisplay, self);
    EventControler:addEventListener(PartnerEvent.PARTNER_REDPOINT_KAIGUAN_EVENT, self.refreshRedShowDisplay, self);

    -- EventControler:addEventListener(UserEvent.USER_INFO_CHANGE_EVENT, self.changePartnerLevel, self)
    -- EventControler:addEventListener(UserEvent.USER_INFO_CHANGE_EVENT, self.initUpQualityCostList, self)
    -- 伙伴皮肤发生变化
    EventControler:addEventListener(PartnerEvent.PARTNER_SKIN_CHANGE_SUCCESS_EVENT, self.changePartnerSkin, self);
    --监听 主角时装变化
    EventControler:addEventListener(GarmentEvent.GARMENT_CHANGE_ONE, self.changePartnerSkin, self)

    EventControler:addEventListener("lihui_yidong", self.setLihuiPos, self)
    EventControler:addEventListener("lihui_yidong_end", self.setLihuiPosEnd, self)
    
    EventControler:addEventListener(PartnerEvent.PARTNER_HIDE_UPGRADE_UI_EVENT, self.shengpinBtnShow, self)

    EventControler:addEventListener(PartnerEvent.PARTNER_UPGRADE_EVENT, self.powerAnimCallBack, self)
    
    --情缘按钮红点
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_LOVE_LEVEL_UP_GRADE, 
        self.loveRedPointEvent, self)
    -- 伙伴共鸣升阶成功
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_PARTNER_RESONATE_ONE_STEP, 
        self.loveRedPointEvent, self)
    --更新红点
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_UPDATE_RED,
        self.loveRedPointEvent, self)

    EventControler:addEventListener(GarmentEvent.GARMENT_CLOSE_MAIN_UI,
        self.garmentCallBack, self)
    --传记数据发生变化 刷新传记入口按钮
    EventControler:addEventListener(BiographyUEvent.EVENT_REFRESH_UI, self.updateBiographyStatus, self)
    --需要播放属性飘字
    EventControler:addEventListener(PartnerEvent.PARTNER_ATTR_ANIM_EVENT, self.updateAttrAnim, self)

    local ctn = self.panel_level.ctn_1
    local node = FuncRes.a_white( 150,35)
    ctn:removeAllChildren()
    ctn:addChild(node,10000)
    node:opacity(0)

    -- node:setTouchedFunc(openLevelUI)
    self.btn_taolun:getUpPanel().panel_red:setVisible(false)
    -- 皮肤按钮
    self.btn_pf:setTap(c_func(self.enterGarments,self))

    self.btn_zj:setTouchedFunc(c_func(self.enterPartnerBiography, self))
    -- 评论按钮
    self.btn_taolun:setTap(c_func(self.showRankAndCommentUI,self))

    self.panel_level.btn_yuanjjia:setTap(c_func(self.openLevelUI,self))
end

function PartnerUpQualityView:enterPartnerBiography()
    WindowControler:showWindow("BiographyMainView", self.data.id)
end

function PartnerUpQualityView:showRankAndCommentUI()
    -- echo("======伙伴ID=========",self.data.id)
    -- local arrayData = {
    --      systemName = FuncCommon.SYSTEM_NAME.PARTNER,
    --      diifID = self.data.id,  --关卡ID
    --      _type = "" 
    -- }
    -- RankAndcommentsControler:showUIBySystemType(arrayData)
    EventControler:dispatchEvent(PartnerEvent.PARTNER_SHOW_PINGLUN_UI_EVENT)
end



function PartnerUpQualityView:enterGarments()
    self._oldPower = CharModel:getCharOrPartnerAbility(self.data.id) 
    WindowControler:showWindow("GarmentMainView", tostring(self.data.id))
end

--穿戴时装后  播放战力
function PartnerUpQualityView:garmentCallBack(event)
    if event.params and tostring(event.params) == tostring(self.data.id) then
        local _curPower = CharModel:getCharOrPartnerAbility(self.data.id)
        if tonumber(self._oldPower) ~= tonumber(_curPower)  then
            FuncCommUI.showPowerChangeArmature(self._oldPower or 10, _curPower or 10);
            self:refreshPower(_curPower, self._oldPower)
        end
    end
end


function PartnerUpQualityView:openLevelUI()
    if FuncPartner.isChar(self.data.id) then
        WindowControler:showWindow("CompLevelUpTipsView", true)
        return
    end
    local open,value,valueType = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SHENGJI)
    if open then
        --WindowControler:showWindow("PartnerUpgradeView",self.data)
        self:showShengJiUi()
    else    
        FuncPartner.getUnLock("升级",value,valueType)
    end
end


function PartnerUpQualityView:showShengJiUi()
    EventControler:dispatchEvent(PartnerEvent.PARTNER_SHOW_UPGRADE_TYPE_EVENT)
    EventControler:dispatchEvent(PartnerEvent.PARTNER_SHOW_UPGRADE_UI_EVENT)
    self:shengpinBtnHide()
end
function PartnerUpQualityView:refreshRedShowDisplay()
    -- 升级的红点
    local ctn_red = self.panel_level.btn_yuanjjia:getUpPanel().panel_red
    if PartnerModel:getRedPoindKaiGuanById(self.partnerId) then
        if PartnerModel:isShowUpgradeRedPoint(self.data.id) then
            ctn_red:visible(true)
        else
            ctn_red:visible(false)
        end
    else    
        ctn_red:visible(false)
    end

    local allUser = false
    local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
    local upQualityData = upQualityDataVec[tostring(self.data.quality)]
    local upQualityCostVec = upQualityData.pellet;  
    local quickQuality = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_QUICKQUALITY)
    for i = 1,4 do
        local frame = self:getItemFrame(i, upQualityCostVec[i])
        if frame == 2 or frame == 3 then
            allUser = true and quickQuality
        end
    end
    -- 升品的红点
    self:coinCostAndBtnRefresh(allUser)
end

--升品装备位发生变化
function PartnerUpQualityView:quailityPositionChange(event)
    self.data = PartnerModel:getPartnerDataById(self.data.id)

    if event.params and event.params.position and table.length(event.params.position) > 0 then
        local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
        local upQualityData = upQualityDataVec[tostring(self.data.quality)]
        local upQualityCostVec = upQualityData.pellet;
        for k,v in pairs(event.params.position) do
            local index = tonumber(k)          
            local frame = self:getItemFrame(index, upQualityCostVec[index])
            local item = self["UI_"..index]
            local pos = PartnerModel:getUpqualityPosition(upQualityCostVec[index], self.data.id)
            
            local data = {
                pos = pos,
                itemId = upQualityCostVec[index],
                frame = frame,
                partnerId = self.data.id,
                isShowNum = false,
                isPlaySound = true,
            }
            item:playEatFoodMaterialAnim(data)
        end

        local allUser = false
        local quickQuality = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_QUICKQUALITY)
        for i = 1,4 do
            local frame = self:getItemFrame(i, upQualityCostVec[i])
            if frame == 2 or frame == 3 then
                allUser = true and quickQuality
            end
        end
        self:coinCostAndBtnRefresh(allUser)
    else
        self:delayCall(function ()
                self:initUpQualityCostList()
            end, 1/GameVars.GAMEFRAMERATE)
    end

    if self.data.position > 0 then
        local _ability = CharModel:getCharOrPartnerAbility(self.data.id)
        local oldAbility = self.oldAbility
        local oldAbility2 = self.oldAbility2
        self:qualityPositionAttr()
        self:delayCall(function ()
                self:powerCallBack(_ability, oldAbility)
                self:refreshPower(_ability, oldAbility2)
            end, 30/GameVars.GAMEFRAMERATE)
        self.oldAbility2 = _ability
        self.oldAbility = _ability
        if not self.isSkilledPlayer then
            EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT, 1)
        end
    end
end
-- 一键食用
function PartnerUpQualityView:allUserTap()
    
    local positions = {}
    local partData = PartnerModel:getPartnerDataById(tostring(self.data.id))
    local value = partData.position or 0
    while value ~= 0 do
		local num = value % 2;
		table.insert(positions, 1, num);
		value = math.floor(value / 2);
	end
    for i = 1 ,4 do
        if positions[i] == nil then
            table.insert(positions, 1, 0);
        end
    end


    local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
    local upQualityData = upQualityDataVec[tostring(self.data.quality)]
    local upQualityCostVec = upQualityData.pellet;
    local posT = {}
    local comT = {}
    for i = 1,4 do
        if positions[i] and positions[i] == 1 then
            -- 已经添加的 
        else
            local frame = self:getItemFrame(i,upQualityCostVec[i],true)
            if frame == 3 then
                comT[upQualityCostVec[i]] = 1
            end
            if frame == 2 or frame == 3 then
                table.insert(posT,i-1)
                PartnerModel:setShengPinId(i-1,self.data.id)
            end
        end
    end
    
    local shiyongFunc = function ( event )
        if event.result then
            if FuncPartner.isChar(self.data.id) then
                self.beforQualityAttr = CharModel:getCharAttr()
                CharServer:qualityEquip({positions = posT},nil)
                FuncPartner.playPartnerShengPinPointSound( )
            else
                self.beforQualityAttr = PartnerModel:getPartnerAttr(self.data.id)
                PartnerServer:qualityItemEquipRequest({ positions = posT,partnerId = tostring(self.data.id) },nil) 
                FuncPartner.playPartnerShengPinPointSound( )
            end
        end
    end
    if table.length(comT) > 0 then
        ItemServer:composeItemsPieces(comT,shiyongFunc)
    else
        shiyongFunc({result = true})
    end
    
    
   
--    PartnerServer:qualityLevelupRequest(self.data.id, c_func(self.combineTapCallBack,self),self.data)
end
--升品按钮注册事件
function PartnerUpQualityView:combineTap()
    local isCan,_type,_value = self:canUpQuality(false)
    if isCan then
        local maxQuality = FuncPartner.getPartnerMaxQuality(self.data.id)
        if maxQuality > self.data.quality then
            self.beforProperty = self:getPartnerProperty()
            if FuncPartner.isChar(self.data.id) then
                CharServer:qualityLevelUp({},c_func(self.combineTapCallBack,self))
            else
                -- self:combineTapCallBack()
                PartnerServer:qualityLevelupRequest(self.data.id, c_func(self.combineTapCallBack,self),self.data)
            end
            self:disabledUIClick()
            EventControler:dispatchEvent(PartnerEvent.PARTNER_LIHUI_MOVE_EVENT,false)
            EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT,1)
            FuncPartner.playPartnerShengPinSound( )
        else 
            WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_029"))
        end
    else
        if _type == 3 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_029"))
        elseif _type == 1 then 
            self:btnAction(  )
            -- WindowControler:showTips(GameConfig.getLanguage("#tid_partner_28"))
        elseif _type == 2 then 
            if FuncPartner.isChar(self.data.id) then
                local _str = string.format(GameConfig.getLanguage("#tid_partner_ui_030"),tostring(_value))
                WindowControler:showTips(_str)
            else
                local _str = string.format(GameConfig.getLanguage("#tid_partner_ui_031"),tostring(_value))
                WindowControler:showTips(_str)
            end
        elseif _type == 4 then  
            WindowControler:showTips(GameConfig.getLanguage("#tid1557"))
            FuncCommUI.showCoinGetView() 
        end
    end
end
-- 不可升品按钮逻辑
function PartnerUpQualityView:btnAction(  )
    local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
    local upQualityData = upQualityDataVec[tostring(self.data.quality)]
    local upQualityCostVec = upQualityData.pellet;

    --判断是否有可食用
    for i = 1,4 do
        local _itemId = upQualityCostVec[i]
        local frame = self:getItemFrame(i,_itemId)
        if frame == 2 then
            local name = FuncItem.getItemName(_itemId)
            WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_partner_37", name))
            local ctn_anim = self["UI_"..i].ctn_tishi
            FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, ctn_anim)
            return
        end
    end

    --判断是否有可合成
    for i = 1,4 do
        local _itemId = upQualityCostVec[i]
        local frame = self:getItemFrame(i,_itemId)
        if frame == 3 then
            PartnerModel:addCombineItemId(_itemId,self.partnerId)
            local _id = PartnerModel:getCombineFirstItemId()
            Cache:set("qualityCombinePartnerId",self.data.id)
            local _ui = WindowControler:showWindow("PartnerUpQualityItemCombineView", _id,tostring(self.data.id));
            _ui:initUI(_itemId)
            return
        end
    end
    --[[ 如果没有可合成的，则打开当前有已激活的获取渠道的灵材中，
    欠缺合成材料的数量最少的，玩家材料的详情和获取渠道窗口]]
    for i = 1,4 do
        local _itemId = upQualityCostVec[i]
        local frame = self:getItemFrame(i,_itemId)

        if frame == 4 then
            local needNum = 0
            local needItemId = nil
            local needCoinNum = 0

            needItemId, needNum = self:getCostItemFunc(_itemId)
            if tonumber(needItemId) == 3 then
                needCoinNum = needNum
                needNum = 0
            end

            if needNum > 0 then
                -- 再判断获取途径是否开启
                local name = FuncItem.getItemName(needItemId)
                WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_partner_28", name))
                if ItemsModel:isResIdGetWayOpen( needItemId ) then
                    WindowControler:showWindow("GetWayListView",needItemId,needNum)
                    return
                end
            elseif needCoinNum > 0 then
                WindowControler:showTips(GameConfig.getLanguage("#tid1557"))
                FuncCommUI.showCoinGetView() 
                return
            end
        end
    end
end
function PartnerUpQualityView:getCostItemFunc(_itemId)
    local _itemData = FuncItem.getItemData(_itemId)
    local _costData = _itemData.cost
    local needNum = 0
    local needItemId = nil
    local needCoinNum = 0
    if not _costData then
        needItemId = _itemId
        needNum = 1
        return needItemId,needNum
    end
    for i,v in pairs(_costData) do
        local _T = string.split(v,",")
        if tonumber(_T[1]) == 1 then
            local _num = tonumber(_T[3]) - ItemsModel:getItemNumById(_T[2])
            local _itemSubType = FuncItem.getItemType(_T[2])
            if _itemSubType == 2 then
                if _num > 0 and (_num < needNum or needNum == 0) then
                    needItemId = _T[2]
                    needNum = tonumber(_T[3])
                    return needItemId,needNum
                end
            elseif _itemSubType == 3 then
                if _num > 0 and (_num < needNum or needNum == 0) then
                    needItemId, needNum = self:getCostItemFunc(_T[2])
                    echo("__________看一下_______",needItemId,needNum )
                    if needItemId then
                        return needItemId,needNum
                    end
                end   
            end
                    
        elseif tonumber(_T[1]) == 3 then
            needCoinNum = tonumber(_T[2]) - UserModel:getCoin()
            if needCoinNum > 0 then
                return 3,needCoinNum
            end
        end
    end
    return nil,0
end

-- 添加升品特效
function PartnerUpQualityView:addShengPinAnim(callBackFunc)
    if self.shengPinAnim then
        self.shengPinAnim:visible(true)
        self.shengPinGuijiAnim:visible(true)
    else
        local shengPinAnim = self:createUIArmature("UI_huoban","UI_huoban_shengpin", nil, true, GameVars.emptyFunc)
        local shengPinGuijiAnim = self:createUIArmature("UI_huoban_guiji","UI_huoban_guiji_shengpin", nil, true, GameVars.emptyFunc)
        shengPinAnim:doByLastFrame(true,true,GameVars.emptyFunc)
        shengPinGuijiAnim:doByLastFrame(true,true,GameVars.emptyFunc)
        shengPinAnim:pos(-12, 4)
        shengPinGuijiAnim:setPositionY(4)
        self.ctn_shengpin:removeAllChildren()
        self.ctn_shengpin:addChild(shengPinAnim)
        self.ctn_shengpin:addChild(shengPinGuijiAnim)
        self.shengPinAnim = shengPinAnim
        self.shengPinGuijiAnim = shengPinGuijiAnim
    end
    
    local hideCostItemFunc = function (_bool)
        for i = 1,4 do
            self["UI_"..i].mc_1.currentView.mc_3.currentView.ctn_1:visible(_bool)
        end
    end
    local shengpinFunc = function ()
        hideCostItemFunc(true)
        callBackFunc()
        self.shengPinAnim:visible(false)
        self.shengPinGuijiAnim:visible(false)
    end
    self.shengPinAnim:startPlay(false,true)
    self.shengPinGuijiAnim:startPlay(false,true)
    self:delayCall(shengpinFunc,1.5)
    
end

--收到消息时 播放特效走这里
function PartnerUpQualityView:powerAnimCallBack()
    local _curAbility = 0 
    local oldAbility = self.oldAbility 
    if FuncPartner.isChar(self.data.id) then
        _curAbility = CharModel:getCharAbility()
    else
        _curAbility = PartnerModel:getPartnerAbility(self.data.id)
    end

    local offsetX = 0
    self:powerCallBack(_curAbility, oldAbility, offsetX)
    self.oldAbility = _curAbility
end

--播放战力变化特效  这里改成通过传参的方式 因为self.oldAbility在走到这的时候就已经发生了变化
function PartnerUpQualityView:powerCallBack(_curPower, _oldAbility, offsetX)
    local offsetX = offsetX or -80
    if _oldAbility ~= _curPower then
        FuncCommUI.showPowerChangeArmature(_oldAbility or 10, _curPower or 10);
    end    
end

--升品成功后的回调
function PartnerUpQualityView:shengpinCallBack() 
    --dump(partData,"升品回调")
    self.aferProperty = self:getPartnerProperty()
    -- 伙伴类型
    local _type = 1
    if FuncPartner.isChar(self.data.id) then
        _type = 2
    end
    local partnerParam = {
        before = self.beforProperty,
        after = self.aferProperty,
        _type = _type,
        titleFrame = 1,
    }
    if self.aferProperty and self.beforProperty then
        if self.aferProperty.info.quality > self.beforProperty.info.quality then
            local qulityCallback = function ( ... )
                self:resumeUIClick()

                self:playQualityUpAnims()

                local partData = PartnerModel:getPartnerDataById(self.data.id)
                self:updataUI(partData)
                local delayFrame = 5
                if not self.isSkillledPlayer then
                    delayFrame = 30
                end
                self:delayCall(function ()
                        EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
                    end, delayFrame / GameVars.GAMEFRAMERATE)
                EventControler:dispatchEvent(PartnerEvent.PARTNER_LIHUI_MOVE_EVENT,true) 
            end
            WindowControler:showWindow("PartnerPropertyShowView",partnerParam,qulityCallback)
        end
    else
        self:resumeUIClick()
        EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
    end
    -- EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
end

--升品成功 点击PartnerPropertyShowView关闭后 播放一系列动画
function PartnerUpQualityView:playQualityUpAnims()
    self:qualityPositionAttr(true)
    local oldAbility = self.oldAbility
    local oldAbility2 = self.oldAbility2
    local _curAbility = 0       
    if FuncPartner.isChar(self.data.id) then
        _curAbility = CharModel:getCharAbility()
    else
        _curAbility = PartnerModel:getPartnerAbility(self.data.id)
    end
    self:delayCall(function ()
            self:powerCallBack(_curAbility, oldAbility)
            self:refreshPower(_curAbility, oldAbility2)
        end, 20/GameVars.GAMEFRAMERATE)
    self.oldAbility2 = _curAbility
    self.oldAbility = _curAbility
end

--升品回调
function PartnerUpQualityView:combineTapCallBack(event)
    if event.result then
        self:addShengPinAnim(c_func(self.shengpinCallBack,self))
    end
end
--获取当前伙伴的基础属性
function PartnerUpQualityView:getPartnerProperty()
    if FuncPartner.isChar(self.data.id) then
        return CharModel:getCharProperty()
    end
    local partnerData = PartnerModel:getPartnerDataById(self.data.id)
    local skins = PartnerSkinModel:getSkinsByPartnerId(self.data.id)
    local data = PartnerModel:getPartnerAttr(self.data.id)
    local partnerProperty = {}
    for i,v in pairs(data) do
        local isTrue,_type = FuncPartner.isInitProperty(v.key)
        if isTrue then    
            partnerProperty[_type] = v.value
        end
    end
    partnerProperty["power"] = CharModel:getCharOrPartnerAbility(self.data.id)
    partnerProperty["info"] = partnerData
    return table.deepCopy(partnerProperty)
end
-- 装备位 属性  isQualityUp为true  表示 是升品 不传为食用
function PartnerUpQualityView:qualityPositionAttr(isQualityUp)
    -- self.beforQualityAttr
    if FuncPartner.isChar(self.data.id) then
        self.afterQualityAttr = CharModel:getCharAttr()
    else
        self.afterQualityAttr = PartnerModel:getPartnerAttr(self.data.id)
    end

    local addAttr = FuncPartner.getPartnerAddAttr(self.beforQualityAttr,self.afterQualityAttr)
    
    if FuncPartner.isChar(self.data.id) then
        self.beforQualityAttr = CharModel:getCharAttr()
    else
        self.beforQualityAttr = PartnerModel:getPartnerAttr(self.data.id)
    end
    
    self:atteAction(addAttr, isQualityUp)
end

--播放升品成功爆点特效   左上角名字 奇侠头像上
function PartnerUpQualityView:playQualityUpAttentionAnims()
    EventControler:dispatchEvent(PartnerEvent.PARTNER_QUALITY_ANIM_EVENT)
    FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.LARGE_BAO, self.UI_title.panel_name.ctn_name)
    self:delayCall(function ()
            self:updateTitleView()
        end, 10/GameVars.GAMEFRAMERATE)
end

-- 自己造一个上飘的动画
function PartnerUpQualityView:atteAction(addAttr, isQualityUp)
    -- FuncPartner.showAttrEffect(self.UI_title.panel_name.mc_1.currentView.txt_1,
    --     self.ctn_lihui,addAttr)
    local attr_str = {}
    local attr_table = FuncBattleBase.formatAttribute(addAttr)
    for i,v in ipairs(attr_table) do
        local str = v.name.."+"..v.value
        table.insert(attr_str, str)
    end

    local _type = "quality"
    if isQualityUp then
        _type = "qualityUp"
        self:playQualityUpAttentionAnims()
    end
    EventControler:dispatchEvent(PartnerEvent.PARTNER_ATTR_ANIM_EVENT, {_type = _type, attr = attr_str})
end

--属性飘字特效  需要根据类型 显示不同的特效  
function PartnerUpQualityView:updateAttrAnim(event)
    local _type = event.params._type
    local attr = event.params.attr
    


    local params = {}
    local ctn = nil
    local effectType = nil
    if _type == "level" then
        ctn = self.ctn_piaozi2

        local partnerId = event.params.partnerId
        if tostring(partnerId) ~= tostring(self.data.id) then
            self.ctn_piaozi2:setVisible(false)
            return
        end
        effectType = FuncCommUI.EFFEC_NUM_TTITLE.UPGRADE
        params.scale = 0.6
        -- self:playEatAndLevelUpItemsAnim(self.ctn_level)
        -- params.scale_Size = {width = 20, height = 20}
        params.cellNoOffsetY = true
        self.ctn_piaozi1:setVisible(false)
        self.ctn_piaozi2:setVisible(true)
        self.ctn_piaozi3:setVisible(false)
    elseif _type == "quality" then
        ctn = self.ctn_piaozi1
        effectType = FuncCommUI.EFFEC_NUM_TTITLE.EATING
        params.y = -30   
        params.scale = 0.8
        -- self:playEatAndLevelUpItemsAnim(self.ctn_level)

        self:delayCall(function ()
                EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
            end, 30/GameVars.GAMEFRAMERATE)

        self.ctn_piaozi1:setVisible(true)
        self.ctn_piaozi2:setVisible(false)
        self.ctn_piaozi3:setVisible(false)
    elseif _type == "qualityUp" then
        ctn = self.ctn_piaozi3
        effectType = nil
        params.scale = 0.8
        self.ctn_piaozi1:setVisible(false)
        self.ctn_piaozi2:setVisible(false)
        self.ctn_piaozi3:setVisible(true)
    end

    params.text = attr
    params.isEffectType = effectType
    FuncCommUI.playNumberRunaction(ctn, params)
end

function PartnerUpQualityView:playEatAndLevelUpItemsAnim(_ctn)
    local eatAnim = _ctn:getChildByName("eatAnim")
    if not eatAnim then
        eatAnim = self:createUIArmature("UI_huoban", "UI_huoban_qixiachishicai", _ctn, true)
        eatAnim:pos(0, 150)
    else
        eatAnim:setVisible(false)
    end

    eatAnim:startPlay(false, true)
    eatAnim:doByLastFrame(false, false, function()
            eatAnim:setVisible(false)
        end)
end
----------------------------------------------
-- 立绘滑动
----------------------------------------------
function PartnerUpQualityView:setLihuiPos(event)
    if event.params then
        local dis = event.params.dis
        local partnerType = event.params.partnerTy
        if partnerType < 2 or partnerType > 3 then
            return 
        end

        self.currentLihui:setPositionX(self.lihuiPosX + dis)
    end
end
function PartnerUpQualityView:setLihuiPosEnd(event)
    if event.params then
        local partnerType = event.params.partnerTy
        if partnerType < 2 or partnerType > 3 then
            return 
        end

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

-- 升品的按钮 隐藏
function PartnerUpQualityView:shengpinBtnHide()
    self.mc_sp:visible(false)
    self.mc_wenben:visible(false)
    self.btn_pf:visible(false)
    self.btn_taolun:setVisible(false)
    self.btn_zj:setVisible(false)
    self.btn_yanshi:setVisible(false)
    self.btnsHide = true
    self:updateRightItemPanels()
end

function PartnerUpQualityView:shengpinBtnShow()
    self.mc_sp:visible(true)
    self.liuGuangAnim:visible(self.btnAnimShow)
    self.mc_wenben:visible(true)
    self:updateLeftButtons()
    self:updateSkillDisplayBtn()
    self.btnsHide = false
    self:updateRightItemPanels()
end

function PartnerUpQualityView:updateRightItemPanels()
    self.panel_fuyong:setVisible(not self.btnsHide)
    self.scale9_shizidi:setVisible(not self.btnsHide)
    for i = 1, 4 do
        self["UI_"..i]:setVisible(not self.btnsHide)
    end
end

function PartnerUpQualityView:loveRedPointEvent( )
    -- if FuncPartner.isChar(self.data.id) then
    --     self.btn_love:visible(false)
    -- else
    --     self.btn_love:visible(true)
    --     -- 判断是否开启
    --     if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.LOVE) then
    --         -- 情缘红点
    --         local loveShow = PartnerModel:isLoveRedPoint(self.data.id)
    --         self.btn_love:getUpPanel().panel_red:visible(loveShow)
    --         FilterTools.clearFilter(self.btn_love);
    --     else
    --         self.btn_love:getUpPanel().panel_red:visible(false)
    --         FilterTools.setGrayFilter(self.btn_love);
    --     end
        
    --     self.btn_love:setTap(c_func(self.lovesTap,self))
    -- end
end

return PartnerUpQualityView
