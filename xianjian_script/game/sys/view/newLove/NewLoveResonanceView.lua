--情缘共鸣view

local NewLoveResonanceView = class("NewLoveResonanceView", UIBase);

function NewLoveResonanceView:ctor(winName,mainPartnerId,vicePartnerId,mainPartnerLoves)
    NewLoveResonanceView.super.ctor(self, winName)
    self.mainPartnerId = mainPartnerId
    self.vicePartnerId = vicePartnerId
    self.mainPartnerLoves = mainPartnerLoves

    echo("___________ 情缘共鸣等级 ___________",mainPartnerResonateLv)
end

function NewLoveResonanceView:loadUIComplete()
	self:registerEvent()
    self:initViewAlign()
	self:initData()
	self:initView()
end 

function NewLoveResonanceView:registerEvent()
	NewLoveResonanceView.super.registerEvent(self)
	self.panel_1.btn_close:setTap(c_func(self.startHide,self))
	-- self:registClickClose("out")

   	-- 伙伴共鸣升阶成功
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_PARTNER_RESONATE_ONE_STEP, self.initData, self)
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_PLAY_ANIMAtion_EVENT, self.onLoveResonanceUpSucceed, self)
end

function NewLoveResonanceView:initViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_zi1, UIAlignTypes.Middle)
end

function NewLoveResonanceView:initData()
	self.partners = FuncNewLove.getVicePartnersListByPartnerId(self.mainPartnerId)
	self.propertyMap = {
        ["2"] = "生命",
        ["10"] = "攻击",
        ["11"] = "物防",
        ["12"] = "法防",
    }

    self.mainPartnerData =  PartnerModel:getPartnerDataById(self.mainPartnerId)
    if self.mainPartnerData then
    	self.mainPartnerResonateLv = self.mainPartnerData.resonanceLv
    else
    	self.mainPartnerResonateLv = 0
    end
    echo("self.mainPartnerResonateLv ========= ",self.mainPartnerResonateLv)
    self:updateUI()
end

function NewLoveResonanceView:initView()
	self.panel_1.txt_1:setString("情缘共鸣")
	-- self.panel_1.mc_1:visible(false)
end

function NewLoveResonanceView:updateUI()
	self.btn_1:setVisible(true)
	local contentView = nil
	contentView = self.panel_1
	local mainPartnerName = FuncPartner.getPartnerName(self.mainPartnerId)
	-- 共鸣属性
	local resonanceLv = self.mainPartnerResonateLv
	if resonanceLv < FuncNewLove.maxLevel then
		local inVisible = 1
		contentView.mc_1:showFrame(1)
		resonanceView = contentView.mc_1:getCurFrameView()
        -- 当前阶
        if resonanceLv == 0 then
            resonanceView.mc_1:showFrame(1)
            local tips = GameConfig.getLanguage("#tid_love_tip_1910")
            resonanceView.panel_t1.txt_1:setString(GameConfig.getLanguage("#tid_loveGlobal_009")) 
            resonanceView.panel_t1.mc_pro:setVisible(false)
            resonanceView.panel_t2:setVisible(false)
            resonanceView.panel_t3:setVisible(false)
            resonanceView.panel_t4:setVisible(false)
        else
            local dataArr = FuncNewLove.getResonatePropertyBypartnerId(self.mainPartnerId,resonanceLv)
            resonanceView.mc_1:showFrame( resonanceLv + 1)  
            for k,v in ipairs(dataArr) do
            	resonanceView["panel_t"..k]:setVisible(true)
            	resonanceView["panel_t"..k].txt_1:setString(self.propertyMap[tostring(v.property)].."+"..tostring(v.value/100).."%")
                resonanceView["panel_t"..k].mc_pro:visible(true)
            	resonanceView["panel_t"..k].mc_pro:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.property)])
            	inVisible = k + 1
            end  
         --    for k = inVisible,4 do
        	-- 	addPropertyView["panel_t"..k]:setVisible(false)
        	-- end 
        end
        -- 目标阶
		local dataArrr = FuncNewLove.getResonatePropertyBypartnerId(self.mainPartnerId,resonanceLv + 1)
		resonanceView.mc_2:showFrame( resonanceLv + 2 )
	    for k,v in ipairs(dataArrr) do
	    	resonanceView["panel_t"..(k+4)]:setVisible(true)
        	resonanceView["panel_t"..(k+4)].txt_1:setString(self.propertyMap[tostring(v.property)].."+"..tostring(v.value/100).."%")
        	resonanceView["panel_t"..(k+4)].mc_pro:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.property)])
        	inVisible = k + 1
        end  
        -- for k = inVisible,4 do
        -- 	addPropertyView["panel_t"..(k+4)]:setVisible(false)
        -- end 
	elseif resonanceLv == FuncNewLove.maxLevel then
		contentView.mc_1:showFrame(2)
		resonanceView = contentView.mc_1:getCurFrameView()

		local dataArr = FuncNewLove.getResonatePropertyBypartnerId(self.mainPartnerId,resonanceLv)
		resonanceView.mc_1:showFrame( resonanceLv + 1)
	    for k,v in ipairs(dataArr) do
	    	resonanceView["panel_t"..k]:setVisible(true)
        	resonanceView["panel_t"..k].txt_1:setString(self.propertyMap[tostring(v.property)].."+"..tostring(v.value/100).."%")
        	resonanceView["panel_t"..k].mc_pro:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.property)])
        	inVisible = k + 1
        end  
        -- for k = inVisible,4 do
        -- 	addPropertyView["panel_t"..k]:setVisible(false)
        -- end  		
	end

	-- 共鸣状态及升阶
	if resonanceLv == FuncNewLove.maxLevel then
        self.ctn_1:removeAllChildren()
		contentView.mc_gongming:showFrame(3)
		self.btn_1:setVisible(false)
	else
		contentView.mc_gongming:showFrame(1)
		panelView = contentView.mc_gongming:getCurFrameView()
		-- panelView.txt_x1
            -- 情缘阶进度条组
        -- 注意顺序要与左侧副奇侠顺序一致
        local targetResonateLevel = nil
        if self.mainPartnerResonateLv < FuncNewLove.maxLevel then
            targetResonateLevel = self.mainPartnerResonateLv + 1
        else
            targetResonateLevel = self.mainPartnerResonateLv
        end
        local inVisible = nil
        for k,vicePartnerId in ipairs(self.partners) do
            local loveId,loveLevel,loveValue = NewLoveModel:getVicePartnerLoveData( self.mainPartnerId,vicePartnerId,self.mainPartnerLoves )
            
            local name = FuncPartner.getPartnerName(vicePartnerId)
            -- local str = loveLevel.."/"..targetResonateLevel
            -- local percent = nil
            if loveLevel >= targetResonateLevel then
                -- percent = 100 
                panelView["panel_tiao"..k].mc_1:showFrame(3)
                self["ctn_tiao"..k]:visible(false)
            else
                -- percent = loveLevel/targetResonateLevel * 100
                panelView["panel_tiao"..k].mc_1:showFrame(2)
                self["ctn_tiao"..k]:visible(true)
            end
            panelView["panel_tiao"..k].txt_2:setString(mainPartnerName)
            panelView["panel_tiao"..k].txt_1:setString(name)
            panelView["panel_tiao"..k].panel_tiao.mc_1:showFrame(targetResonateLevel+1)

            local loveTipsDesc = FuncNewLove.getLoveLevelDescById(loveId,targetResonateLevel)
			loveTipsDesc = GameConfig.getLanguage(loveTipsDesc)
			panelView["panel_tiao"..k].panel_tiao.mc_1:getCurFrameView().txt_1:setString(loveTipsDesc)
            inVisible = k + 1
        end
        for k = inVisible,4 do
            panelView["panel_tiao"..k]:setVisible(false)
        end


        local dataArr = FuncNewLove.getResonatePropertyBypartnerId(self.mainPartnerId,resonanceLv + 1)
		local txtArr = {}
	    for k,v in ipairs(dataArr) do
        	txtArr[#txtArr + 1 ] = (self.propertyMap[tostring(v.property)].."+"..tostring(v.value/100).."%")
        end  
        -- dump(txtArr,"txtArr ================ ")

        local canShowRedPoint = NewLoveModel:isShowResonanceRedPoint(self.mainPartnerId)
        self.ctn_1:removeAllChildren()
     	if canShowRedPoint then
            local btn_anim = self.btn_1:getUpPanel():getChildByName("saoguang")
            if not btn_anim then
                local btnAni = self:createUIArmature("UI_anniuliuguang","UI_anniuliuguang_zong",self.btn_1:getUpPanel(), true)
                btnAni:pos(78, -36)
                btnAni:setName("saoguang")
            end
        else
            self.btn_1:getUpPanel():removeChildByName("saoguang")
        end
		self.btn_1:getUpPanel().panel_red:visible(canShowRedPoint)
		self.btn_1:setTap(function()
			if NewLoveModel.haveSentResonateLevelUpRequest then
				return
			end

			local isFinish = NewLoveModel:isCanResonate(self.mainPartnerId)
			if isFinish then
				NewLoveModel.haveSentResonateLevelUpRequest = true
				self._oldPower = PartnerModel:getPartnerAbility(self.mainPartnerId)
				echo("_________ 主伙伴当前战力 ________ ",self._oldPower)
				NewLoveModel:loveResonanceUp(self.mainPartnerId,txtArr,self.vicePartnerId)
			else
                self.ctn_tiao1:removeAllChildren()
                self.ctn_tiao2:removeAllChildren()
                self.ctn_tiao3:removeAllChildren()
                self.ctn_tiao4:removeAllChildren()
                local btnAni1 = self:createUIArmature("UI_qingyuan_tisheng", "UI_qingyuan_tisheng_kuoquan", self.ctn_tiao1, false, GameVars.emptyFunc)
                local btnAni2 = self:createUIArmature("UI_qingyuan_tisheng", "UI_qingyuan_tisheng_kuoquan", self.ctn_tiao2, false, GameVars.emptyFunc)
                local btnAni3 = self:createUIArmature("UI_qingyuan_tisheng", "UI_qingyuan_tisheng_kuoquan", self.ctn_tiao3, false, GameVars.emptyFunc)
                local btnAni4 = self:createUIArmature("UI_qingyuan_tisheng", "UI_qingyuan_tisheng_kuoquan", self.ctn_tiao4, false, GameVars.emptyFunc)
                btnAni1:setScaleX(0.35)
                btnAni1:setScaleY(0.3)
                btnAni2:setScaleX(0.35)
                btnAni2:setScaleY(0.3)
                btnAni3:setScaleX(0.35)
                btnAni3:setScaleY(0.3)
                btnAni4:setScaleX(0.35)
                btnAni4:setScaleY(0.3)
				WindowControler:showTips("先解锁共鸣条件")
			end
		end)
	end
end

function NewLoveResonanceView:onLoveResonanceUpSucceed(event)
	-- dump(event.params," 共鸣升级成功后的 回调 params -----")
	local txtArr = event.params.txtArr
	NewLoveModel.haveSentResonateLevelUpRequest = false

	local function _callBack( ... )
		local _curPower = PartnerModel:getPartnerAbility(self.mainPartnerId)
		-- echo("________ 战力提升 ____self._oldPower,_curPower___________ ",self._oldPower,_curPower)
		FuncCommUI.showPowerChangeArmature(self._oldPower or 10, _curPower or 10 );
	end
	
	local _ctn = self.ctn_zi1
    _ctn:removeAllChildren()
	local isEffectType = FuncCommUI.EFFEC_NUM_TTITLE.RESONANCE  --- 共鸣
	local data = {text = txtArr, isAnimation = nil, isEffectType = isEffectType, callBack = _callBack}
	FuncCommUI.playNumberRunaction(_ctn,data)
end

function NewLoveResonanceView:deleteMe()
	-- TODO

	NewLoveResonanceView.super.deleteMe(self);
end

return NewLoveResonanceView;
