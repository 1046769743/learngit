--[[
	guan 
	2016.8.22
	2017.3.6 换界面
]]

local ActivityFirstRechargeView = class("ActivityFirstRechargeView", UIBase)

function ActivityFirstRechargeView:ctor(winName, params)
	ActivityFirstRechargeView.super.ctor(self, winName)
	params = params or {}
	self.partnerId = 5022
	self._callBack = params.closeCall
end

function ActivityFirstRechargeView:loadUIComplete()
	self.flag = 1
	-- 设置背景
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bg, UIAlignTypes.Middle)
	self:registerEvent();
	self:initData()
    self:initUI();
    ActivityFirstRechargeModel:setFirstShowRed(false)
   	self:initOpenAniMation()
end

function ActivityFirstRechargeView:initData()
	self.rewardArray = FuncDataSetting.getDataByHid("Firstchargereward").arr;
	self.frame = 1
end

function ActivityFirstRechargeView:initOpenAniMation()
	self.isShowing = true
	--三个下雪特效 不同的大小 速度  范围   层级需要在最上层
	local xiaxue = FuncArmature.getParticleNode("xiaxue")
	xiaxue:addto(self._root):zorder(100):pos(568, 0)
	local xiaxue_b = FuncArmature.getParticleNode("xiaxueb")
	xiaxue_b:addto(self._root):zorder(100):pos(568, 0)
	local xiaxue_c = FuncArmature.getParticleNode("xiaxuec")
	xiaxue_c:addto(self._root):zorder(100):pos(568, 0)
	self.btn_1:setVisible(false)
   	self.panel_1:setVisible(false)
   	self.panel_x1:setVisible(false)
   	self.panel_x2:setVisible(false)
   	self.btn_x:setVisible(false)
   	self.panel_txt_linger:setVisible(false)
   	self.panel_txt_song:setVisible(false)
   	self.mc_wm:setVisible(false)
   	self.btn_1:pos(-115, 30)
   	self.panel_x1:pos(-155, 30)
   	self.panel_x2:pos(-175, 30)
   	self.btn_x:pos(-30, 40)
   	self.panel_1.panel_1:pos(-2, -16)
   	self.panel_1.panel_2:pos(-2, -16)
   	self.panel_1.panel_3:pos(-2, -16)
   	self.panel_1.panel_4:pos(-2, -16)
   	self.panel_txt_linger:pos(-42, 112)
   	self.panel_txt_song:pos(-23, 68)
    self.firstChargeAnim = self:createUIArmature("UI_shouchong", "UI_shouchong_jiemiandonghua", self, true)
    FuncArmature.changeBoneDisplay(self.firstChargeAnim, "layer18", self.btn_x)
    FuncArmature.changeBoneDisplay(self.firstChargeAnim, "layer13", self.panel_x1)
    FuncArmature.changeBoneDisplay(self.firstChargeAnim, "layer13_copy", self.panel_x2)
    FuncArmature.changeBoneDisplay(self.firstChargeAnim, "anniu", self.btn_1)
    -- 物品出现特效  这四个替换后子动画都只播一次
    local anim1 = self.firstChargeAnim:getBoneDisplay("a4")
    FuncArmature.changeBoneDisplay(anim1:getBoneDisplay("a15_copy"), "node1", self.panel_1.panel_1)
    self.panel_1.panel_1:setScale(1.15)
    anim1:setAllChildAniPlayOnce()
    local anim2 = self.firstChargeAnim:getBoneDisplay("a3")
    FuncArmature.changeBoneDisplay(anim2:getBoneDisplay("a15_copy"), "node1", self.panel_1.panel_2)
    self.panel_1.panel_2:setScale(1.15)
    anim2:setAllChildAniPlayOnce()
    local anim3 = self.firstChargeAnim:getBoneDisplay("a2")
    FuncArmature.changeBoneDisplay(anim3:getBoneDisplay("a15_copy"), "node1", self.panel_1.panel_3)
    self.panel_1.panel_3:setScale(1.15)
    anim3:setAllChildAniPlayOnce()
    local anim4 = self.firstChargeAnim:getBoneDisplay("a1")
    FuncArmature.changeBoneDisplay(anim4:getBoneDisplay("a15_copy"), "node1", self.panel_1.panel_4)
    self.panel_1.panel_4:setScale(1.15)
    anim4:setAllChildAniPlayOnce()
    FuncArmature.changeBoneDisplay(self.firstChargeAnim, "node2", self.panel_txt_linger)
	FuncArmature.changeBoneDisplay(self.firstChargeAnim, "node3", self.panel_txt_song)
	--创建赵灵儿spine动画 替换到特效中
	local lingerSpine = FuncPartner.getPartnerLiHuiByIdAndSkin(self.partnerId)
	lingerSpine:setScale(0.65)
	lingerSpine:pos(0, -80)
	local spineMask = display.newSprite(FuncRes.iconOther("activity_img_zhezhao"))
	spineMask:pos(0, 150)
	--添加遮罩
	lingerSpine = FuncCommUI.getMaskCan(spineMask, lingerSpine)
	FuncArmature.changeBoneDisplay(self.firstChargeAnim, "node1", lingerSpine)
	--添加左右荷花spine特效
	local spineShouChong1  = ViewSpine.new("UI_shouchong")
	spineShouChong1:playLabel("UI_shouchong_zuo", true)
	FuncArmature.changeBoneDisplay(self.firstChargeAnim, "node4", spineShouChong1)
	local spineShouChong2  = ViewSpine.new("UI_shouchong")
	spineShouChong2:playLabel("UI_shouchong_you", true)
	FuncArmature.changeBoneDisplay(self.firstChargeAnim, "node5", spineShouChong2)
	self.firstChargeAnim:setAllChildAniPlayOnce()
    self.firstChargeAnim:startPlay(false, true)

    self.firstChargeAnim:registerFrameEventCallFunc(52, 1, function ()
    		self.mc_wm:setVisible(true)
    	end)

    self.firstChargeAnim:registerFrameEventCallFunc(60, 1, function ()
    		--中间 赵灵儿 字闪光
    		local animSaoGuang1 = self:createUIArmature("UI_shouchong", "UI_shouchong_shanguang1", self.panel_x1, true)    		
    		animSaoGuang1:pos(221, -17)
    		--中间 双倍 字闪光
    		local animSaoGuang2 = self:createUIArmature("UI_shouchong", "UI_shouchong_shanguang2", self.panel_x2, true)    		
    		animSaoGuang2:pos(222, -17)
    		--添加左侧赵灵儿闪光特效
    		local animShanGuang = self:createUIArmature("UI_shouchong", "UI_shouchong_anniusaoguang", self.panel_txt_linger, true)
    		animShanGuang:pos(35, -114)
    		--按钮扫光
    		self.saoGuangAnim = self:createUIArmature("UI_shouchong", "UI_shouchong_shuaxin", self.btn_1, true)
    		self.saoGuangAnim:setScale(0.7)
    		self.saoGuangAnim:pos(115.2, -28)
            
            if self.frame == 3 then
            	self.saoGuangAnim:setVisible(false)
            else
            	self.saoGuangAnim:setVisible(true)
            end
            self.isShowing = false
    	end)
end

function ActivityFirstRechargeView:addItemAnimation(reward, ctnUp, ctnDown)
    local _effectType = {
        [1] = {
            down = "UI_shop_fangxiaceng",
            up = "UI_shop_fangshangceng",
        },
        [2] = {
            down = "UI_shop_yuanxiaceng",
            up = "UI_shop_yuanshangceng",
        },
        [3] = {
            down = "UI_shop_lenxiaceng",
            up = "UI_shop_lenshangceng",
        },
    }
    local frame = FuncCommon.getShapByReward(reward)
    local ani1 = self:createUIArmature("UI_shop", _effectType[frame].up, ctnUp, true, nil)
    local ani2 = self:createUIArmature("UI_shop", _effectType[frame].down, ctnDown, true, nil)
    ani1:setScale(0.65)
    ani1:pos(-2.5, 2)
    ani2:setScale(0.65)
    ani2:pos(-2.5, 2)
    return ani1, ani2
end

function ActivityFirstRechargeView:registerEvent()
	self.btn_x:setTap(c_func(self.onBackTap, self))
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_x, UIAlignTypes.Right);

    -- local scaleX = GameVars.width / GameVars.gameResWidth;
    -- self.panel_bg:setScaleX(scaleX);
    -- (GameVars.width  - GameVars.gameResWidth )
	-- 充值成功消息 现在还没有 
	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, self.onRechargeCallBack, self)
	EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT, self.onRechargeCallBack, self)
end

function ActivityFirstRechargeView:onRechargeCallBack(event)
	self:initBtn()
	-- self.flag = 2
	-- self:addAnimation(true)
end

function ActivityFirstRechargeView:initUI()
	self:initReward();
	self:initAni();
	self:initBtn();
end

function ActivityFirstRechargeView:initBtn()
	local btn_panel = self.btn_1:getUpPanel()
	-- self.mc_1:showFrame(1);
	-- local gotoBtn = self.mc_1.currentView.btn_1;
	-- gotoBtn:setTap(c_func(self.onGoToRechargeView, self));

	-- self.mc_1:showFrame(2);
	-- local getBtn = self.mc_1.currentView.btn_1;
	-- getBtn:setTap(c_func(self.onShowRewardView, self));

	--没有充过值
	echo("--UserModel:goldTotal()--", UserModel:goldTotal());
	if ActivityFirstRechargeModel:isRecharged() then
		-- 判断是否已领取
		if ActivityFirstRechargeModel:haveGetFirstGift() then			
			btn_panel.mc_1:showFrame(3)
			self.mc_wm:showFrame(3)
			self.btn_1:setTap(c_func(self.hasGetReward, self))
			self.frame = 3
			if self.saoGuangAnim then
				self.saoGuangAnim:setVisible(false)
			end
		else			
			btn_panel.mc_1:showFrame(2)
			self.mc_wm:showFrame(2)
			self.btn_1:setTap(c_func(self.onShowRewardView, self))
			self.frame = 2
			if self.saoGuangAnim then
				self.saoGuangAnim:setVisible(true)
			end
			-- self.flag = 2		
			-- self:addAnimation(true)
		end		
	else		
		btn_panel.mc_1:showFrame(1)
		self.mc_wm:showFrame(1)
		self.btn_1:setTap(c_func(self.onGoToRechargeView, self))
		self.frame = 1
		if self.saoGuangAnim then
			self.saoGuangAnim:setVisible(true)
		end
		-- self.flag = 1
		-- self:addAnimation(true)
	end 
end

function ActivityFirstRechargeView:hasGetReward()
	return
end

function ActivityFirstRechargeView:onShowRewardView()
    self:disabledUIClick();
    echo("-----onShowRewardView-----");
    self:handleReward()
    FirstRechargeServer:getReward(c_func(self.rewardCallBack, self));
end

function ActivityFirstRechargeView:handleReward()
    for i,v in ipairs(self.rewardArray) do
        local str_arr = string.split(v, ",")
        if tostring(str_arr[1]) == FuncDataResource.RES_TYPE.PARTNER and PartnerModel:isHavedPatnner(str_arr[2]) then
            local debrisNum = FuncPartner.getSameCardDebrisById(str_arr[2])
            self.rewardArray[i] = string.format("%d,%d,%d", FuncDataResource.RES_TYPE.ITEM, str_arr[2], debrisNum)
        end
    end
end

function ActivityFirstRechargeView:rewardCallBack(event)
    if event.error == nil then
		-- self:close()
		
		self:clickCallBack()
		EventControler:dispatchEvent(ChargeEvent.GET_FIRST_CHARGE_REWARD_EVENT, {})
		self:initBtn()
	end 
	self:resumeUIClick();
end

function ActivityFirstRechargeView:clickCallBack()
    local param = {
        id = self.partnerId,
        skin = "1",
    }

    WindowControler:showWindow("PartnerSkinFirstShowView", param, function ()
    		FuncCommUI.startFullScreenRewardView(self.rewardArray)
    	end)
end


function ActivityFirstRechargeView:onGoToRechargeView()	
	WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
    -- WindowControler:showWindow("RechargeMainView");
end

function ActivityFirstRechargeView:initAni()
	-- self:createUIArmature("UI_huodong","UI_huodong_guangxiao", 
 --        self.ctn_jian, true)

	-- self:createUIArmature("UI_huodong","UI_huodong_5", 
 --        self.ctn_glow, true)
end

function ActivityFirstRechargeView:initReward()
	for i = 1, 4 do
		local reward = string.split(self.rewardArray[i], ",");
		local rewardType = reward[1];
		local rewardNum = reward[table.length(reward)];
		local rewardId = reward[table.length(reward) - 1];
		local panel = self.panel_1["panel_"..i]
		local commonUI = panel.UI_1;
		commonUI:setResItemData({reward = self.rewardArray[i]});
		commonUI:showResItemName(false);
		commonUI:showResItemRedPoint(false);
        FuncCommUI.regesitShowResView(commonUI,
            rewardType, rewardNum, rewardId, self.rewardArray[i], true, true);
        panel.mc_1:showFrame(i)
        local name = FuncCommon.getNameByReward(self.rewardArray[i])
        panel.mc_1.currentView.txt_1:setString(name)
        if i == 1 then
    		local ctnUp = panel.ctn_shang
            local ctnDown = panel.ctn_xia
            local itemData = self.rewardArray[i]
            self:addItemAnimation(itemData, ctnUp, ctnDown)
        end
	end
end

function ActivityFirstRechargeView:addAnimation(showAnim)
	if showAnim then
		local ctn = self.mc_1.currentView.btn_1:getUpPanel().ctn_sweep
		if self.flag == 1 then
			if not ctn:getChildByName("saoguang1") then
				local ani = self:createUIArmature("UI_chongzhi",
		        "UI_chongzhi", ctn, true)
		    
		    	ani:setName("saoguang1")
			end
		else
			if not ctn:getChildByName("saoguang2") then
				local ani = self:createUIArmature("UI_chongzhi",
		        "UI_chongzhi", ctn, true)

		    	ani:setName("saoguang2")
			end	
		end
	end	
end

function ActivityFirstRechargeView:onBackTap()
	if self.isShowing then
		return
	end
	local func = self._callBack
	self._callBack = nil
	if func then func() end
	
	self:close()
end

function ActivityFirstRechargeView:close()
	ActivityFirstRechargeModel:showRedPoint()
	self:startHide()
end

return ActivityFirstRechargeView









