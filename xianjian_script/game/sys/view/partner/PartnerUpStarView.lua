local PartnerUpStarView = class("PartnerUpStarView", UIBase)
local showStarType = {
        TYPE_INIT = 1,
        TYPE_KE_SHENGJI = 2,
        TYPE_SHENGJI = 3, 
        TYPE_BUKE_SHENGJI = 4,
        TYPE_BUKE_MANJI = 5,
        TYPE_SHENGXING = 6,

        TYPE_DIANLIANG = 7,
        TYPE_KE_DIANLIANG = 8,
        TYPE_BUKE_DIANLIANG = 9,
        TYPE_DIANLIANGING = 10,
        TYPE_XIAOHUO_CHUXIAN = 11,  
    }
function PartnerUpStarView:ctor(winName)
	PartnerUpStarView.super.ctor(self, winName)
end

function PartnerUpStarView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
    self.tipsNode = {}
    self.animT = {}
    -- self:delayCall(function ()
            local fazhenAnim = self:createUIArmature("UI_huoban_shengxing_beijing",
                "UI_huoban_shengxing_beijing", self.ctn_bg, false, GameVars.emptyFunc)
        -- end, 0/GameVars.GAMEFRAMERATE)
end


function PartnerUpStarView:setAlignment()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_power, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_title, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_2, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_fazhen, UIAlignTypes.Middle)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.rich_1, UIAlignTypes.LeftBottom)
    
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_wenben, UIAlignTypes.RightBottom)
end

function PartnerUpStarView:updateUIWithPartner(_partnerInfo)
    self:setUpStarBtnEnabled(true)
    --更新UI信息
    self.data = _partnerInfo
    if FuncPartner.isChar(self.data.id) then
        self.boforStarAttr = CharModel:getCharAttr()
        self.rich_1:setVisible(false)
    else
        self.boforStarAttr = PartnerModel:getPartnerAttr(self.data.id)
        self.rich_1:setVisible(true)
    end

    self:setPartnerInfo(_partnerInfo)
    -- 奇侠信息 名字 星级
    self.UI_title:updateUI(self.partnerId)

    self:delayCall(function ()
            self:addPartnerSpine(_partnerInfo)
        end, 2/GameVars.GAMEFRAMERATE)

    -- 升星的动画状态
    self:delayCall(function ()
            self:initStarPointAnim(_partnerInfo.starPoint,self:getUpStarState())
        end, 1/GameVars.GAMEFRAMERATE)  

    self.rich_1:setString(GameConfig.getLanguage("#tid_partner_starup_001"))
    --战力
    local _ability = CharModel:getCharOrPartnerAbility(self.partnerId)
    self.panel_power.UI_number:setPower(_ability)
    self.oldAbility = _ability
    FuncCommUI.regesitShowPartnerTipView(self.panel_power,{id = self.partnerId,_type = FuncPartner.TIPS_TYPE.POWER_TIPS})
end

--添加中间的任务spine
function PartnerUpStarView:addPartnerSpine(_partnerInfo)
    local partnerData = FuncPartner.getPartnerById(self.partnerId)
    local npc_ctn = self.panel_fazhen.ctn_ren
    local npc = nil 
    local name = nil
    local pifuId = nil
    if self.partnerType == 1 then
        npc = FuncPartner.getHeroSpineByPartnerIdAndSkin( self.partnerId,_partnerInfo.skin,nil ,_partnerInfo)
        name = GameConfig.getLanguage(partnerData.name)
        pifuId = _partnerInfo.skin
    else
        npc = FuncGarment.getSpineViewByAvatarAndGarmentId(UserModel:avatar(), UserExtModel:garmentId(),false,_partnerInfo)
        name = UserModel:name()
        pifuId = UserExtModel:garmentId()
    end

    npc:scale(1.1)
    npc_ctn:removeAllChildren()
    npc_ctn:addChild(npc)
    npc:setPosition(cc.p(npc:getPositionX(),npc:getPositionY()+5))
    self.npcSpin = npc
    self.npcspinId = self.partnerId
    self.pifuId = pifuId
    self.npcPType = self.partnerType

    local _weight = 200
    local node = FuncRes.a_white( _weight,_weight)
    npc_ctn:addChild(node,10000)
    node:setPositionY(100)
    node:setTouchedFunc(c_func(self.openPartnerInfoUI,self))
    node:opacity(0)
end

--伙伴信息
function PartnerUpStarView:setPartnerInfo( _partnerInfo)
    self.partnerId = _partnerInfo.id
    self.starLevel = _partnerInfo.star
    self.starStage = _partnerInfo.starPoint
    self.quality = _partnerInfo.quality
    self.partnerType = 1
    if FuncPartner.isChar(self.partnerId) then
        --此时是主角
        self.partnerType = 2
    end
    local partnerData = FuncPartner.getPartnerById(self.partnerId);
    
    --当前星级
    local maxStar = FuncPartner.getPartnerMaxStar( self.partnerId )
    
    --升星按钮注册事件
    self.maxStar = maxStar
    if maxStar == self.starLevel then -- 当前已满级
        self.mc_2:showFrame(3)
        FilterTools.clearFilter(self.mc_2);
    else
        local animName = ""
        if self.starStage == 5 then  --此时为升星
            self.mc_2:showFrame(2)
            animName = "anim2"          
        else
            self.mc_2:showFrame(1)
            animName = "anim1"
        end

        local ctn_btnAnim = self.mc_2.currentView.btn_2:getUpPanel().ctn_1
        self.animUpStar = ctn_btnAnim:getChildByName(animName)
        if not self.animUpStar then 
            local animUpStar = self:createUIArmature("UI_anniuliuguang", "UI_anniuliuguang_zong", ctn_btnAnim, true)
            animUpStar:setScaleY(1.32)
            animUpStar:setScaleX(1.11)
            animUpStar:pos(-4, 1)
            animUpStar:setName(animName)
            self.animUpStar = animUpStar
        end

        self.animUpStar:setVisible(false)
        self.mc_2.currentView.btn_2:disableClickSound()
        self.mc_2.currentView.btn_2:setTap(c_func(self.upStarTap, self)) --对应按钮响应事件
    end

    -- 每一个小星星的tips 
    self:showPointAttr()
    -- 更新消耗
    self:refreshFragNum()
    -- 更新starpoint显示的小球
    -- self:updateStarPointQiu()
    self.beforProperty = self:getPartnerProperty()
end
function PartnerUpStarView:openPartnerInfoUI()
    FuncPartner.playPartnerInfoSound( )
    -- WindowControler:showWindow("PartnerInfoUI",self.partnerId)
    EventControler:dispatchEvent(PartnerEvent.PARTNER_CHANGEQINGBAO_EVENT)
end
-- 
function PartnerUpStarView:updateStarPointQiu()
    local panel = self.panel_jindu
    for i=1,5 do
        if i <= self.starStage or self.maxStar == self.starLevel then
            FilterTools.clearFilter(panel["panel_starpoint"..i]);
        else
            FilterTools.setGrayFilter(panel["panel_starpoint"..i]);
        end
    end
end
-- 当前法阵的动画状态
function PartnerUpStarView:initStarPointAnim( starIndex,showType,callBackFunc )
    for i = 1 ,5 do
        self.panel_fazhen["panel_"..i].ctn_1:removeAllChildren()
    end
    if starIndex > 0 then
        for i = 0,starIndex-1 do
            self:delayCall(function ()
                    self:showCurStarNodeInfo(i,showStarType.TYPE_DIANLIANG,nil)
                end, i/GameVars.GAMEFRAMERATE)   
        end
    end
    self:showCurStarNodeInfo(starIndex,showType,callBackFunc)
end
function PartnerUpStarView:showCurStarNodeInfo(starIndex,showType,callBackFunc)
    showType = showType or showStarType.TYPE_BUKE_DIANLIANG
    if starIndex > 5 or starIndex < 0 then
        starIndex = 0
    end

    --可升级状态
    local anim = nil
    local panelIndex = starIndex + 1
    if showType == showStarType.TYPE_KE_DIANLIANG then
        anim = self:getAnimByPointAndType(starIndex,showType,true)
        anim:scale(0.7)
        anim:setPositionY(-15)
        if panelIndex <= 5 then
            local ctn = self.panel_fazhen["panel_"..panelIndex].ctn_1;
            ctn:removeAllChildren()
            ctn:addChild(anim)
        end
    elseif showType == showStarType.TYPE_DIANLIANG then -- 播放点亮状态
        local ctn2 = self.panel_fazhen["panel_"..panelIndex].ctn_2;
        local animChu = self:getAnimByPointAndType(starIndex,showStarType.TYPE_XIAOHUO_CHUXIAN,false)
        local lastCall = function ()
            animChu:removeFromParent()
        end;
        ctn2:addChild(animChu)
        animChu:doByLastFrame(true,true,lastCall)

        self:delayCall(function ()
            anim = self:getAnimByPointAndType(starIndex,showType,true)
            local ctn = self.panel_fazhen["panel_"..panelIndex].ctn_1;
            ctn:removeAllChildren()
            ctn:addChild(anim)
        end,0.17)

    elseif showType == showStarType.TYPE_DIANLIANGING then -- 播放小升星动画
        echo("播放小升星动画")
        self:setUpStarBtnEnabled(false)
        local fazhenFunc = function ()
--            anim:removeFromParent()
            self:showCurStarNodeInfo(starIndex+1,self:getUpStarState())
--          此时要刷新UI
            callBackFunc()
            self:delayCall(function ()
                self:setUpStarBtnEnabled(true)
            end, 40/30)
            
        end
        local anim = self:getAnimByPointAndType(starIndex,showType,false)
        local ctn2 = self.panel_fazhen["panel_"..panelIndex].ctn_2;
        ctn2:addChild(anim)
        anim:doByLastFrame(true,true,fazhenFunc)

        self:delayCall(function ()
            self:showCurStarNodeInfo(starIndex,showStarType.TYPE_DIANLIANG)
        end,0.17)

    elseif showType == showStarType.TYPE_BUKE_SHENGJI then -- 不可升级状态
        
    elseif showType == showStarType.TYPE_BUKE_MANJI then -- 满级的状态
        echo("满级的状态")
        for i = 1 ,5 do
            self.panel_fazhen["panel_"..i].ctn_1:removeAllChildren()
            local anim = self:getAnimByPointAndType(i-1,showStarType.TYPE_DIANLIANG,true)
            local ctn = self.panel_fazhen["panel_"..i].ctn_1;
            ctn:removeAllChildren()
            ctn:addChild(anim)
        end
              
    elseif showType == showStarType.TYPE_SHENGXING then  -- 升星动画

        self:setUpStarBtnEnabled(false)
        local fazhenFunc = function ()
            -- 判断是否可升级
            self:showCurStarNodeInfo(0,self:getUpStarState())
            -- 此时要刷新UI
            
            self:delayCall(function ()
                callBackFunc()
                self:setUpStarBtnEnabled(true)
            end, 40/30)
        end
        for i = 1 ,5 do
            self.panel_fazhen["panel_"..i].ctn_1:removeAllChildren()
            local ctn_zha = self.panel_fazhen["panel_"..i].ctn_1
            -- 播放炸开
            local anim = self:getAnimByPointAndType( i-1 ,showStarType.TYPE_SHENGXING,false )
            anim:doByLastFrame(true,true,GameVars.emptyFunc)
            anim:setPositionY(-50)
            ctn_zha:addChild(anim)
        end
        -- 5帧之后 播放轨迹
        local guijiAnimName = "UI_huoban_shengxing_guiji"
        self:delayCall(function ( ... )
            local ctn_animRen = self.panel_fazhen.ctn_animRen
            if not self.guijiAnim then
                self.guijiAnim = self:createUIArmature("UI_huoban_shengxing_guiji",
                guijiAnimName, nil, false, GameVars.emptyFunc)
                local guijiAnim = self.guijiAnim
                ctn_animRen:addChild(guijiAnim)
                guijiAnim:doByLastFrame(true,true,function ( ... )
                    guijiAnim:visible(false)
                end)

                -- 调整位置
                guijiAnim:setPositionX(0)
                guijiAnim:setPositionY(70)
            else
                local guijiAnim = self.guijiAnim
                guijiAnim:visible(true)
                guijiAnim:startPlay(false, true )
            end
            
        end, 2/30)
        -- 15+5 帧之后 播放立绘身上的特效
        local animName = "UI_huoban_shengxing_zhakai"
        self:delayCall(function ( ... )
            local ctn_animRen = self.panel_fazhen.ctn_animRen
            if not self.lihuiAnim then
                self.lihuiAnim = self:createUIArmature("UI_huoban_shengxing",
                animName, nil, false, GameVars.emptyFunc)
                local lihuiAnim = self.lihuiAnim
                ctn_animRen:addChild(lihuiAnim)
                lihuiAnim:doByLastFrame(true,true,function (  )
                    lihuiAnim:visible(false)
                end)
                -- 调整位置
                lihuiAnim:setPositionX(0)
                lihuiAnim:setPositionY(70)
            else
                local lihuiAnim = self.lihuiAnim
                lihuiAnim:visible(true)
                lihuiAnim:startPlay(false, true )
            end
            
        end, 20/30)
        -- 30帧之后 播放星星出现动画
        -- local animName1 = "UI_huoban_shengxing_jiaxing"
        -- self:delayCall(function ( ... )
        --     local jiaxingAnim = self:createUIArmature("UI_huoban_shengxing", animName1, nil, false, GameVars.emptyFunc)
        --     local partnerData = PartnerModel:getPartnerDataById(self.partnerId)
        --     local star = partnerData.star
        --     local starCtn = self.UI_title.panel_star.ctn_1
        --     starCtn:addChild(jiaxingAnim)
        --     jiaxingAnim:doByLastFrame(true, true, GameVars.emptyFunc)
        --     -- jiaxingAnim:setPositionY(-1)
        --     jiaxingAnim:pos((star - 1) * 32, 0)

        --     self.UI_title:updateStar(self.partnerId)
        --     -- 50 帧之后刷新UI
        --     self:delayCall(function()
        --         fazhenFunc()
        --     end, 40/30)
            
        -- end, 25/30)
        self:delayCall(function ( ... )
            -- EventControler:dispatchEvent(PartnerEvent.PARTNER_STAR_ANIM_EVENT)
            -- local ctn_anim = self.UI_title.panel_star.ctn_1
            -- FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, ctn_anim, offsetX, -3)
            -- local curStar = self.data.star
            -- local offsetX = (self.data.star - 1) * 32
            -- self.UI_title:updateStar(self.partnerId)
            fazhenFunc()
        end, 25/30)
    end

end
-- 通过starpoint 和 type 取动画
function PartnerUpStarView:getAnimByPointAndType( _point ,_type,_circle )
    local animName = ""
    echo("实际 出现的 star point ==== ",_point)
    echo("星星状态  === ",_type)
    _point = _point + 1
    -- local key = "star".._point.."_".._type
    -- if self.animT[key] then
    --     return self.animT[key]
    -- end

    if _point == 1 then
        if _type == showStarType.TYPE_DIANLIANG then
            animName = "UI_huoban_shengxing_tuzhu"
        elseif _type == showStarType.TYPE_BUKE_DIANLIANG then
            -- animName = "UI_huoban_shengxing_zizhu"
        elseif _type == showStarType.TYPE_KE_DIANLIANG then
            animName = "UI_huoban_shengxing_tutishi"
        elseif _type == showStarType.TYPE_DIANLIANGING then
            animName = "UI_huoban_shengxing_zhakaitu"
        elseif _type == showStarType.TYPE_XIAOHUO_CHUXIAN then 
            animName = "UI_huoban_shengxing_chuxiantu"
        elseif _type == showStarType.TYPE_SHENGXING then
            animName = "UI_huoban_shengxing_zhakaitu"
        end
    elseif _point == 2 then
        if _type == showStarType.TYPE_DIANLIANG then
            animName = "UI_huoban_shengxing_fengzhu"
        elseif _type == showStarType.TYPE_BUKE_DIANLIANG then
            -- animName = "UI_huoban_shengxing_zizhu"
        elseif _type == showStarType.TYPE_KE_DIANLIANG then
            animName = "UI_huoban_shengxing_fengtishi"
        elseif _type == showStarType.TYPE_DIANLIANGING then
            animName = "UI_huoban_shengxing_zhakailv"
        elseif _type == showStarType.TYPE_XIAOHUO_CHUXIAN then 
            animName = "UI_huoban_shengxing_chuxianlv"
        elseif _type == showStarType.TYPE_SHENGXING then
            animName = "UI_huoban_shengxing_zhakailv"
        end
    elseif _point == 3 then
        if _type == showStarType.TYPE_DIANLIANG then
            animName = "UI_huoban_shengxing_leizhu"
        elseif _type == showStarType.TYPE_BUKE_DIANLIANG then
            -- animName = "UI_huoban_shengxing_zizhu"
        elseif _type == showStarType.TYPE_KE_DIANLIANG then
            animName = "UI_huoban_shengxing_leitishi"
        elseif _type == showStarType.TYPE_DIANLIANGING then
            animName = "UI_huoban_shengxing_zhakaizi"
        elseif _type == showStarType.TYPE_XIAOHUO_CHUXIAN then 
            animName = "UI_huoban_shengxing_chuxianzi"
        elseif _type == showStarType.TYPE_SHENGXING then
            animName = "UI_huoban_shengxing_zhakaizi"
        end
    elseif _point == 4 then
        if _type == showStarType.TYPE_DIANLIANG then
            animName = "UI_huoban_shengxing_huozhu"
        elseif _type == showStarType.TYPE_BUKE_DIANLIANG then
            -- animName = "UI_huoban_shengxing_zizhu"
        elseif _type == showStarType.TYPE_KE_DIANLIANG then
            animName = "UI_huoban_shengxing_huotishi"
        elseif _type == showStarType.TYPE_DIANLIANGING then
            animName = "UI_huoban_shengxing_zhakaihuo"
        elseif _type == showStarType.TYPE_XIAOHUO_CHUXIAN then 
            animName = "UI_huoban_shengxing_chuxianhuo"
        elseif _type == showStarType.TYPE_SHENGXING then
            animName = "UI_huoban_shengxing_zhakaihuo"
        end
    elseif _point == 5 or _point == 6 then
        if _type == showStarType.TYPE_DIANLIANG then
            animName = "UI_huoban_shengxing_shuizhu"
        elseif _type == showStarType.TYPE_BUKE_DIANLIANG then
            -- animName = "UI_huoban_shengxing_zizhu"
        elseif _type == showStarType.TYPE_KE_DIANLIANG then
            animName = "UI_huoban_shengxing_shuitishi"
        elseif _type == showStarType.TYPE_DIANLIANGING then
            animName = "UI_huoban_shengxing_zhakailan"
        elseif _type == showStarType.TYPE_XIAOHUO_CHUXIAN then 
            animName = "UI_huoban_shengxing_chuxianlan"
        elseif _type == showStarType.TYPE_SHENGXING then
            animName = "UI_huoban_shengxing_zhakailan"
        end
    end
    
    -- self.animT[key] = self:createUIArmature("UI_huoban_shengxing",
    --             animName, nil, _circle, GameVars.emptyFunc)
    return self:createUIArmature("UI_huoban_shengxing",
                animName, nil, _circle, GameVars.emptyFunc)
end

-- 判断当前状态是否可升星 -- 获取升星状态
function PartnerUpStarView:getUpStarState()
    local maxStar = FuncPartner.getPartnerMaxStar( self.partnerId )
    if maxStar > tonumber(self.data.star) then -- 当前未满级
        if PartnerModel:isCanUpStar(self.partnerId) then
            return showStarType.TYPE_KE_DIANLIANG
        else
            return showStarType.TYPE_BUKE_DIANLIANG
        end            
    else
        return showStarType.TYPE_BUKE_MANJI
    end 
end

-- 获得伙伴或主角升星当前 拥有
function PartnerUpStarView:getHaveNum(_id)
    if FuncPartner.isChar(_id) then
        return CharModel:getStarDirt()
    else
        return ItemsModel:getItemNumById(_id)
    end
end
-- 刷新碎片数量进度条 和 按钮状态
function PartnerUpStarView:refreshFragNum()
    self:refreshBtnDisplay()
end
-- 刷新按钮和小球的状态
function PartnerUpStarView:refreshBtnAndStar( )
    self:refreshBtnDisplay()
    self:refreshStarPoint()
end
-- 刷新当前星点状态
function PartnerUpStarView:refreshStarPoint()
    self:showCurStarNodeInfo(self.data.starPoint,self:getUpStarState())
end


--刷新升星按钮的状态
function PartnerUpStarView:refreshBtnDisplay()
    --升星按钮注册事件
    local partnerData = FuncPartner.getPartnerById(self.partnerId);
    local maxStar = FuncPartner.getPartnerMaxStar( self.partnerId )
    self.maxStar = maxStar
    local needPartner,needCoin = self:getNeedPartnerNum()
    if maxStar == self.starLevel then -- 当前已满级
        self.mc_2:showFrame(3)
        FilterTools.clearFilter(self.mc_2);
    else
        if self.starStage == 5 then  --此时为升星
            self.mc_2:showFrame(2)  
            -- 刷新消耗铜钱数
            if UserModel:getCoin() >= needCoin then
                self.mc_2.currentView.mc_wenben:showFrame(1)
                self.mc_2.currentView.mc_wenben.currentView.mc_red5000:showFrame(1)
                self.mc_2.currentView.btn_2:getUpPanel().panel_red:visible(true)
                -- FilterTools.clearFilter(self.mc_2.currentView.btn_2);
                self.animUpStar:setVisible(true)
            else
                self.mc_2.currentView.mc_wenben:showFrame(1)
                self.mc_2.currentView.mc_wenben.currentView.mc_red5000:showFrame(2)
                self.mc_2.currentView.btn_2:getUpPanel().panel_red:visible(false)
                -- FilterTools.setGrayFilter(self.mc_2.currentView.btn_2);
            end
            self.mc_2.currentView.mc_wenben.currentView.mc_red5000.currentView.txt_1:setString(needCoin)
                  
        else 
            ----提升
            self.mc_2:showFrame(1)
            local havePartner = 0
            if FuncPartner.isChar(self.partnerId) then
                havePartner = CharModel:getStarDirt()
            else
                havePartner = ItemsModel:getItemNumById(self.partnerId)
            end

            local panelSp = self.mc_2.currentView.panel_sp
            panelSp.txt_1:setString(havePartner.."/"..needPartner)

            local itemID = self.partnerId 
            if FuncPartner.isChar(itemID) then
                itemID = "5000"
            end
            local spPanel = panelSp.mc_kuang
            FuncPartner.initQXSP( spPanel,itemID )
            

            if havePartner >= needPartner then
                self.mc_2.currentView.btn_2:getUpPanel().panel_red:visible(true)
                -- FilterTools.clearFilter(self.mc_2.currentView.btn_2);
                self.animUpStar:setVisible(true)
            else
                self.mc_2.currentView.btn_2:getUpPanel().panel_red:visible(false)
                -- FilterTools.setGrayFilter(self.mc_2.currentView.btn_2);
            end

            self.mc_2.currentView.panel_sp.btn_1:setTap(function ()
                if FuncPartner.isChar(self.partnerId) then
                    WindowControler:showWindow("GetWayListView",FuncChar.starDirt,self:getNeedPartnerNum())
                else
                    WindowControler:showWindow("GetWayListView",self.partnerId,self:getNeedPartnerNum())
                end
        
    end)
        end
        self.mc_2.currentView.btn_2:disableClickSound()
        self.mc_2.currentView.btn_2:setTap(c_func(self.upStarTap, self)) --对应按钮响应事件
    end

    -- 在这添加 红点的判断 该伙伴的红点是否显示
    if not PartnerModel:getRedPoindKaiGuanById(self.partnerId) then
        -- 判断当前是否是满星
        if maxStar == self.starLevel then
        else
            self.mc_2.currentView.btn_2:getUpPanel().panel_red:visible(false)
        end
    end
end

function PartnerUpStarView:getNeedPartnerNum()
    local costVec = FuncPartner.getStarsByPartnerId(self.partnerId)
    local costFrag = 0
    local costCoin = 0
    for i,v in pairs(costVec) do
        if v.star == self.starLevel then
            local starStage = self.starStage+1;
            if starStage > 5 then
                -- 升星时 消耗
                costCoin = v.coin or 0
                return 0,costCoin
            end
            local maxStar = FuncPartner.getPartnerMaxStar( self.partnerId )
            if self.starLevel < maxStar then
                costFrag = (v.cost)[starStage] or 0
                costCoin = 0
            end
            break
        end
    end
    return costFrag,costCoin
end

function PartnerUpStarView:registerEvent()
    PartnerUpStarView.super.registerEvent();

    EventControler:addEventListener(PartnerEvent.PARTNER_FRAGMENT_CHANGE_EVENT,self.refreshBtnAndStar,self)
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.refreshBtnDisplay, self);
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.refreshBtnAndStar,self)

    -- 红点开关
    EventControler:addEventListener(PartnerEvent.PARTNER_REDPOINT_ZONGKAIGUAN_EVENT, self.refreshBtnDisplay, self);
    EventControler:addEventListener(PartnerEvent.PARTNER_REDPOINT_KAIGUAN_EVENT, self.refreshBtnDisplay, self);
    --升星成功回调
    -- EventControler:addEventListener(PartnerEvent.PARTNER_STAR_POINT_CHANGE_EVENT, self.upStarCallBack, self);
end

--获取当前伙伴的基础属性
function PartnerUpStarView:getPartnerProperty()
    if tonumber(self.partnerId) < 5000 then
        return CharModel:getCharProperty()
    end
    local partnerData = PartnerModel:getPartnerDataById(tostring(self.partnerId))
    local skins = PartnerSkinModel:getSkinsByPartnerId(tostring(self.partnerId))
    local data = PartnerModel:getPartnerAttr(tostring(self.partnerId))
    local partnerProperty = {}
    for i,v in pairs(data) do
        local isTrue,_type = FuncPartner.isInitProperty(v.key)
        if isTrue then    
            partnerProperty[_type] = v.value
        end
    end
    partnerProperty["starPower"] = CharModel:getCharOrPartner0PointAbility(self.partnerId)
    partnerProperty["power"] = CharModel:getCharOrPartnerAbility(self.partnerId)
    partnerProperty["info"] = partnerData
    return table.deepCopy(partnerProperty)
end

function PartnerUpStarView:upStarTap()
    local partnerData = FuncPartner.getPartnerById(self.partnerId);
    local maxStar = FuncPartner.getPartnerMaxStar( self.partnerId )
    if self.data.star == maxStar then
        -- echoError("正常情况 不会出现") 
        WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_032"))
    else
        local isCan ,_type = PartnerModel:isCanUpStar(self.partnerId);
        if isCan then
            if self.starBtnEnable then
                if self.starStage ~= 5 then
                    local animCtn = self.mc_2:getViewByFrame(1).panel_sp.ctn_anim
                    if not self.costAnim then
                        self.costAnim = self:createUIArmature("UI_buxingxiaohao", "UI_buxingxiaohao", animCtn, true)
                    end
                    self.costAnim:startPlay(false, true)
                end
                self:setUpStarBtnEnabled(false)
                self.beforProperty = self:getPartnerProperty()
                self.oldAbility = CharModel:getCharOrPartnerAbility(self.partnerId)
                if FuncPartner.isChar(self.partnerId) then
                    self.beforStarAttr = CharModel:getCharAttr()
                    CharServer:starUpLevel({}, c_func(self.upStarCallBack,self))
                else
                    self.beforStarAttr = PartnerModel:getPartnerAttr(self.partnerId)
                    PartnerServer:starLevelupRequest(tonumber(self.partnerId), c_func(self.upStarCallBack,self))
                end
                EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT)
                

                self:playUpstarSound() 
            end
            
        elseif _type == 1 then 
            --WindowControler:showTips("命魂不足，可通过三皇台获得") --
            local tips = GameConfig.getLanguage("#tid_common_notEnoughItem")
            WindowControler:showTips(string.format(tips,GameConfig.getLanguage("#tid_partner_ui_033"))) 
            if FuncPartner.isChar(self.partnerId) then
                WindowControler:showWindow("GetWayListView",FuncChar.starDirt,self:getNeedPartnerNum())
            else
                WindowControler:showWindow("GetWayListView",self.partnerId,self:getNeedPartnerNum())
            end
        elseif _type == 2 then    
            --WindowControler:showTips("铜钱不足，点击铜钱加号查看铜钱来源")
            local tips = GameConfig.getLanguage("#tid1557")
            WindowControler:showTips(tips)
            FuncCommUI.showCoinGetView() 
        end
    end
end

--升星按钮播放的音效
function PartnerUpStarView:playUpstarSound( )
    if self.data.starPoint == 5 then
        FuncPartner.playPartnerUpstarSound( )
    else
        FuncPartner.playPartnerUpstarPointSound( )
    end
end


function PartnerUpStarView:setUpStarBtnEnabled(enable)
    if self.starBtnEnable == enable then
        return
    end

    self.starBtnEnable = enable

    if enable then
        EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
        EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, 
                            {tutorailParam = TutorialEvent.CustomParam.partnerAnimFinish})
    else
        EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT,3)
    end
end

--战力刷新
function PartnerUpStarView:refreshPower(_curPower, _oldPower)
    local frame = _curPower - _oldPower
    if frame > 30 then
        frame = 30
    end

    for i = 1, frame do
        self:delayCall(function ()
                local num = math.floor((_curPower - _oldPower) * 1.0 / frame * i) + _oldPower
                self.panel_power.UI_number:setPower(num)
            end, i / GameVars.GAMEFRAMERATE)
    end 
end

function PartnerUpStarView:playAddStarAnim()
    local jiaxingAnim = self.UI_title.panel_star.ctn_1:getChildByName("addStar")

    if not jiaxingAnim then
        jiaxingAnim = self:createUIArmature("UI_huoban_shengxing", "UI_huoban_shengxing_jiaxing", 
                                                    self.UI_title.panel_star.ctn_1, true, GameVars.emptyFunc)
        jiaxingAnim:setName("addStar")
    end
    local partnerData = PartnerModel:getPartnerDataById(self.partnerId)
    local star = partnerData.star
    jiaxingAnim:pos((star - 1) * 32, 0)
    jiaxingAnim:registerFrameEventCallFunc(15, 1, function ()
            self.UI_title:updateStar(self.partnerId)
        end)

    jiaxingAnim:startPlay(false, true)
end

function PartnerUpStarView:upStarCallBack(event)
    self.aferProperty = self:getPartnerProperty()
    self.data = PartnerModel:getPartnerDataById(self.data.id)
    -- 伙伴类型
    local _type = 1
    if FuncPartner.isChar(self.data.id) then
        _type = 2
    end
    local refreshPowerCallBack = function (_playAnim)
        local _newAbility = CharModel:getCharOrPartnerAbility(self.data.id)
        local _oldAbility = self.oldAbility
        if _newAbility > self.oldAbility then
            self:delayCall(function ()
                    FuncCommUI.showPowerChangeArmature(_oldAbility or 10, _newAbility or 10);
                    self:refreshPower(_newAbility, _oldAbility)
                end, 20 / GameVars.GAMEFRAMERATE)   
            self:starPositionAttr()

            if _playAnim then
                -- local ctn_anim = self.UI_title.panel_star.ctn_1
                EventControler:dispatchEvent(PartnerEvent.PARTNER_STAR_ANIM_EVENT)
                -- FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, ctn_anim, offsetX, -3)
                self:playAddStarAnim()
            end    
        end
    end

    local partnerParam = {
        before = self.beforProperty,
        after = self.aferProperty,
        _type = _type,
        titleFrame = 2,
        isPartnerUpStar = true,
    }

    function refreshUI()
        self:delayCall(c_func(self.setPartnerInfo, self, self.data), 23/GameVars.GAMEFRAMERATE)
        self:delayCall(function()
            self:setUpStarBtnEnabled(true)
        end, 40/GameVars.GAMEFRAMERATE)
    end
    
    function playAttentionAnim()
        local ctn_anim = self.panel_fazhen.ctn_attention
        FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.LIHUI_GUANG, ctn_anim)
    end

    local _shengxingCall = function()
        playAttentionAnim()
        if self.aferProperty.info.star > self.beforProperty.info.star then -- 此时升星啦
            local shengxingFunc= function ()
                WindowControler:showWindow("PartnerPropertyShowView", partnerParam, c_func(refreshPowerCallBack, true))
                refreshUI()
            end
            self:showCurStarNodeInfo(5, showStarType.TYPE_SHENGXING, shengxingFunc)
        else
            self:showCurStarNodeInfo(self.data.starPoint-1, showStarType.TYPE_DIANLIANGING, refreshUI)
            refreshPowerCallBack()
        end
    end
    _shengxingCall()
end

-- 刷新星级
function PartnerUpStarView:updateStar()

    local maxStar = FuncPartner.getPartnerMaxStar( self.partnerId )
    self.panel_star.mc_star:showFrame(maxStar)
    for i = 1,maxStar do
        if self.data.star >= i then
            self.panel_star.mc_star.currentView["mc_"..i]:showFrame(1)
        else
            self.panel_star.mc_star.currentView["mc_"..i]:showFrame(2)
        end
    end
end

function PartnerUpStarView:showPointAttr()
    local dataCfg = FuncPartner.getStarsByPartnerId(self.partnerId)
    datacfg = dataCfg[tostring(self.data.star)]
    local partnerData = FuncPartner.getPartnerById(self.partnerId);
    -- 判断是否是满星的状态
    -- if self.data.star == partnerData.maxStar then
    --     for i = 1,5 do 
    --         local mc = self.panel_fazhen["panel_"..i].mc_1
    --         mc:visible(false)
    --         self.panel_fazhen["panel_"..i].panel_hei:visible(false)
    --     end
    -- else
        
    -- end
    local visibleCall = function (index,node)
        self.panel_fazhen["panel_"..index].mc_1:showFrame(1)
        local mc = self.panel_fazhen["panel_"..index].mc_1.currentView.mc_1
        local panel_hei = self.panel_fazhen["panel_"..index].panel_hei
        mc:visible(false)
        panel_hei:visible(false)
        mc:runAction(act.fadein(0.01))
        panel_hei:runAction(act.fadein(0.01))
        if index <= (self.data.starPoint+1) then
            if node then
                node:setTouchEnabled(true)
            end
        end
    end;
    local showTipPanel = function ( index,node )
        node:setTouchEnabled(false)
        self.panel_fazhen["panel_"..index].mc_1:showFrame(1)
        local mc = self.panel_fazhen["panel_"..index].mc_1.currentView.mc_1
        local panel_hei = self.panel_fazhen["panel_"..index].panel_hei
        mc:visible(true)
        panel_hei:visible(true)
        mc:runAction(cc.Sequence:create(
            act.delaytime(2.5),
            act.fadeout(0.5),
            act.callfunc(c_func(visibleCall,index,node))
        ))
        panel_hei:runAction(cc.Sequence:create(
            act.delaytime(2.5),
            act.fadeout(0.5)
        ))
    end
    for i = 1,5 do 
        -- local ctn = self.panel_fazhen["panel_"..i].ctn_tips  
        -- -- ctn:removeAllChildren()
        -- local _key = "tipsnode"..i
        -- if not self.tipsNode[_key] then
        --     local _node = FuncRes.a_white( 60,60)
        --     ctn:addChild(_node)
        --     self.tipsNode[_key] = _node
        --     _node:opacity(120)
        -- end
        
        -- local node = self.tipsNode[_key]
        -- node:stopAllActions()
        -- node:setPositionY(100)
        -- if i <= (self.data.starPoint+1) then
        --     node:setTouchedFunc(c_func(showTipPanel,i,node))
        -- else
        --     node:setTouchedFunc(GameVars.emptyFunc)
        -- end
        
        self.panel_fazhen["panel_"..i].mc_1:showFrame(1)
        local mc = self.panel_fazhen["panel_"..i].mc_1.currentView.mc_1
        local panel_hei = self.panel_fazhen["panel_"..i].panel_hei
        mc:visible(true)
        panel_hei:visible(false)
        if self.data.starPoint >= i then
            mc:showFrame(1)
        elseif (self.data.starPoint+1) == i then 
            mc:showFrame(2)
        else
            mc:visible(false)
            panel_hei:visible(false)
        end

        local txt = mc.currentView.txt_1
        local attr = datacfg["addAttr"..i]
        
        if attr then
            attr = FuncBattleBase.formatAttribute( attr )
            attr = attr[1] --table.length(attr)
            local ratio = 10000
            --主角的属性跟法宝的 加成系数相关
            if FuncPartner.isChar(self.partnerId) then
                local treasureId = TeamFormationModel:getOnTreasureId()
                local treasureData = TreasureNewModel:getTreasureData(treasureId)
                ratio = FuncTreasureNew.getRatioByIdAndStar(treasureId, treasureData.star, attr.key)
            end
            local value = math.floor((ratio / 10000) * attr.value)
            txt:setString(attr.name.."+"..value)
        else
            mc:visible(false)
        end

        if i > 1 and i < 4 then
            self.panel_fazhen["panel_"..i].mc_1:setPositionY(-95)
        else
            self.panel_fazhen["panel_"..i].mc_1:setPositionY(-110)
        end
    end
    
    
end

-- 小星星位 属性
function PartnerUpStarView:starPositionAttr()
    if FuncPartner.isChar(self.partnerId) then
        self.afterStarAttr = CharModel.getCharAttr()
    else 
        self.afterStarAttr = PartnerModel:getPartnerAttr(self.partnerId)       
    end    

    local addAttr = FuncPartner.getPartnerAddAttr(self.boforStarAttr,self.afterStarAttr)
    
    if FuncPartner.isChar(self.partnerId) then
        self.boforStarAttr = CharModel:getCharAttr()
    else
        self.boforStarAttr = PartnerModel:getPartnerAttr(self.partnerId)
    end
    self:playAttrAnim(addAttr)
end

--播放属性飘字特效
function PartnerUpStarView:playAttrAnim(addAttr)
    local attr_str = {}
    local attr_table = FuncBattleBase.formatAttribute(addAttr)
    for i,v in ipairs(attr_table) do
        local str = v.name.."+"..v.value
        table.insert(attr_str, str)
    end

    dump(attr_str, "\n\nattr_str=====")
    FuncCommUI.playNumberRunaction(self.panel_fazhen.ctn_shengxing, {text = attr_str})
end

return PartnerUpStarView
