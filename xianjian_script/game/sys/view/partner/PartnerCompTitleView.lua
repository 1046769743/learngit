

local PartnerCompTitleView = class("PartnerCompTitleView", UIBase);


function PartnerCompTitleView:ctor(winName)
    PartnerCompTitleView.super.ctor(self, winName);
end

function PartnerCompTitleView:loadUIComplete()
	self:registerEvent();
end 

function PartnerCompTitleView:registerEvent()
	PartnerCompTitleView.super.registerEvent();

end

function PartnerCompTitleView:tipsUI(ctn,_type)
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
        FuncCommUI.regesitShowPartnerTipView(node,{_type = _type,id = self.data.id})
    end
end

function PartnerCompTitleView:updateUI(partnerId)	
    
    if not FuncPartner.isChar(partnerId) and not PartnerModel:isHavedPatnner(partnerId) then
        --姓名
        local partnerData = FuncPartner.getPartnerById(partnerId)
        self.panel_name.mc_1:showFrame(1)
        self.panel_name.mc_1.currentView.txt_1:setString(GameConfig.getLanguage(partnerData.name))
        FuncCommUI.regesitShowPartnerTipView(self.panel_name,{   id = partnerData.id ,_type = FuncPartner.TIPS_TYPE.QUALITY_TIPS})
        
        --type
        PartnerModel:partnerTypeShow(self.panel_dingwei.mc_1,partnerData )
        --描述
        self.panel_dingwei.txt_bing:setString(GameConfig.getLanguage(partnerData.charaCteristic))
        FuncCommUI.regesitShowPartnerTipView(self.panel_dingwei,{   id = partnerData.id ,_type = FuncPartner.TIPS_TYPE.DESCRIBE_TIPS})
        -- 五行定位
        local elementFrom = partnerData.elements
        if not elementFrom then
            elementFrom = 6
        end
        if FuncPartner.isChar(partnerData.id) then
            local treasureId = TeamFormationModel:getOnTreasureId()
            local treaData = FuncTreasureNew.getTreasureDataById(treasureId)
            elementFrom = treaData.wuling or 6
        end
        -- if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FIVESOUL) then
        --     elementFrom = 6
        -- end
        self.panel_gfj.mc_tu2:showFrame(elementFrom)
        --星级
        self.panel_star.mc_star:showFrame(partnerData.initStar)
        FuncCommUI.regesitShowPartnerTipView(self.panel_star,{   id = partnerData.id ,_type = FuncPartner.TIPS_TYPE.STAR_TIPS})
    else
        local data = PartnerModel:getPartnerDataById(partnerId)
        local partnerData = FuncPartner.getPartnerById(partnerId)
        --姓名
        local quaData = FuncPartner.getPartnerQuality(partnerId)
        quaData = quaData[tostring(data.quality)]
        local nameColor = quaData.nameColor
        nameColor = string.split(nameColor,",") 
        self.panel_name.mc_1:showFrame(tonumber(nameColor[1]))
        self.panel_name.mc_1.currentView.txt_1:setString(PartnerModel:getQiXiaName(data))

        FuncCommUI.regesitShowPartnerTipView(self.panel_name,{   id = partnerId ,_type = FuncPartner.TIPS_TYPE.QUALITY_TIPS})
        
        --type
        PartnerModel:partnerTypeShow(self.panel_dingwei.mc_1,partnerData )
        -- self:tipsUI(self.panel_gfj.ctn_1,FuncPartner.TIPS_TYPE.PARTNER_TYPE_TIPS)
        --五行定位
        local elementFrom = partnerData.elements
        if not elementFrom then
            elementFrom = 6
        end
        if FuncPartner.isChar(partnerId) then
            local treasureId = TeamFormationModel:getOnTreasureId()
            local treaData = FuncTreasureNew.getTreasureDataById(treasureId)
            elementFrom = treaData.wuling or 6 
        end
        -- if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FIVESOUL) then
        --     elementFrom = 6
        -- end
        self.panel_gfj.mc_tu2:showFrame(elementFrom)
        --描述
        local charaCteristic = FuncPartner.getDescribe(partnerId)
        
        self.panel_dingwei.txt_bing:setString(GameConfig.getLanguage(charaCteristic))
       -- self:tipsUI(self.panel_dingwei,FuncPartner.TIPS_TYPE.DESCRIBE_TIPS)
        FuncCommUI.regesitShowPartnerTipView(self.panel_dingwei,{id = partnerId,_type = FuncPartner.TIPS_TYPE.DESCRIBE_TIPS})
        --星级
        self.panel_star.mc_star:showFrame(data.star)
        FuncCommUI.regesitShowPartnerTipView(self.panel_star,{id = partnerId,_type = FuncPartner.TIPS_TYPE.STAR_TIPS})
    end
    -- self.panel_gfj.mc_tu2:setPositionX(1  
    -- self.btn_qixiaxiangqing:setTap(function (  )
    --     FuncPartner.playPartnerInfoSound( )
    --     WindowControler:showWindow("PartnerInfoUI",partnerId)
    -- end)

end

--更新星级
function PartnerCompTitleView:updateStar(partnerId)
    local data = PartnerModel:getPartnerDataById(partnerId)
    --星级
    self.panel_star.mc_star:showFrame(data.star)
end

function PartnerCompTitleView:hideStar(  )
	self.panel_star:visible(false)
end

return PartnerCompTitleView;
