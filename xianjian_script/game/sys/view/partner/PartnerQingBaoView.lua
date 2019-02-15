

local PartnerQingBaoView = class("PartnerQingBaoView", InfoTipsBase);


function PartnerQingBaoView:ctor(winName)
    PartnerQingBaoView.super.ctor(self, winName);
end

function PartnerQingBaoView:loadUIComplete()

end 

function PartnerQingBaoView:registerEvent()
	PartnerQingBaoView.super.registerEvent();
end

function PartnerQingBaoView:updateUI()
    --  标题 
    local partnerName = FuncPartner.getPartnerName(self.partnerId)
    self.txt_1:setString(partnerName)

    ----- 伙伴信息 ------
    self:initPartnerInfo()
end

function PartnerQingBaoView:initPartnerInfo()
    
    for i = 1,6 do
    	self["panel_"..i]:visible(false)
    end

    local _scrollParams = self:initScrollData()
    self.scroll_1:refreshCellView( 1 )
    self.scroll_1:styleFill(_scrollParams);
	self.scroll_1:hideDragBar()
end
function PartnerQingBaoView:initScrollData( )
    local createFunc = function ( itemData )
		local view = UIBaseDef:cloneOneView(self["panel_"..itemData])
		self:updateItem(view, itemData)
		return view
    end
    local updateFunc = function (_item,_view)
        self:updateItem(_view,_item)
    end

    local function getData( index,with,height )
    	local data = {
                data = {index},
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX = 20,
                offsetY =0,
                itemRect = {x=0,y= -height,width=with,height = height},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            }

		return data
    end

    local _scrollParams = {}
    -- 简介
    table.insert(_scrollParams,getData( 1,840,170 ))
    -- 新手搭配
    local d = self:getDaPeiData(  )
    local h = 45 + 84 * table.length(d)
    table.insert(_scrollParams,getData( 2,840,h + 25 ))
    -- 故事
    table.insert(_scrollParams,getData( 4,840,125 ))
    -- 基础属性
    table.insert(_scrollParams,getData( 5,840,121 ))
    -- 高级属性
    table.insert(_scrollParams,getData( 6,840,285 ))
    if not FuncPartner.isChar(self.partnerId) then
        -- 标签
        table.insert(_scrollParams,3,getData( 3,840,102 ))
    end
    return _scrollParams
end
function PartnerQingBaoView:updateItem( view, itemData )
	-- body
	if itemData == 1 then -- 简介
		self:jianjie( view )
    elseif itemData == 2 then -- 新手搭配
        self:xinshoudapei( view )
    elseif itemData == 3 then -- 标签
        self:biaoqian( view )
    elseif itemData == 4 then -- 故事
        self:gushi( view )
    elseif itemData == 5 then -- 基础属性
        self:jichushuxing( view )
    elseif itemData == 6 then -- 高级属性
        self:gaojishuxing( view )
	end
end
-- 简介
function PartnerQingBaoView:jianjie( view )
    local partnerId = self.partnerId
    local partnerData = FuncPartner.getPartnerById(partnerId)
    -- 定位
    local dwStr = GameConfig.getLanguage(FuncPartner.getDescribe(partnerId))
	view.txt_3:setString(dwStr)
    
    -- 五灵 -- 类型
    local elementFrom = partnerData.elements
    if not elementFrom then
        elementFrom = 6
    end
    if FuncPartner.isChar(partnerId) then
        local treasureId = TeamFormationModel:getOnTreasureId()
        local treaData = FuncTreasureNew.getTreasureDataById(treasureId)
        elementFrom = treaData.wuling or 6 

        view.txt_5:setString(FuncPartner.partnerType[treaData.type])
    else
        view.txt_5:setString(FuncPartner.partnerType[partnerData.type])
    end

    if elementFrom > 5 then
        view.txt_7:visible(false)
    else
        view.txt_7:visible(true)
        view.txt_7:setString(FuncPartner.fiveName[elementFrom].."奇侠")
    end   

    -- 情缘详情按钮
    local a,b,c,d = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.LOVE)
    local _func = function (curPartnerId)
        if a then
            if WindowControler:checkHasWindow("NewLovePartnerView") then
                local wind = WindowControler:getWindow("NewLovePartnerView" )
                wind:updateNewLovePartnerView(self.partnerId, curPartnerId)
                WindowControler:showTopWindow("NewLovePartnerView")
            else
                WindowControler:showWindow("NewLovePartnerView", self.partnerId, curPartnerId)
            end
        else
            --
            local str = GameConfig.getLanguageWithSwap("#tid_partner_32",b)
            WindowControler:showTips(d)
        end
    end

    if FuncPartner.isChar(partnerId) then
        view.panel_1:visible(false)
    else
        view.panel_1:visible(true)
        local lovePartners = FuncNewLove.getVicePartnersListByPartnerId(partnerId)
        for k,v in pairs(lovePartners) do
            view.panel_1["panel_red"..k]:setVisible(false)
            local partnerCfg = FuncPartner.getPartnerById(v)
            if partnerCfg.isShow == 0 then
                view.panel_1["mc_"..k]:showFrame(2)
                view.panel_1["mc_"..k].currentView.txt_1:setString(GameConfig.getLanguage(partnerCfg.name)) 
                view.panel_1["mc_"..k].currentView:setTouchedFunc(function ()
                        WindowControler:showTips( GameConfig.getLanguage("tid_common_2053"))
                    end)
            else
                view.panel_1["mc_"..k]:showFrame(1)
                local panel = view.panel_1["mc_"..k].currentView.UI_1
                -- panel:scale(0.7)
                -- panel:setPositionY(-75)
                panel:updataUI(v)
                if PartnerModel:isHavedPatnner(v) then
                    panel:setIconZhiHui(false)
                else
                    panel:setIconZhiHui(true)
                end
                panel:hideStar(false)
                panel:hideLevel(false)
                view.panel_1["mc_"..k].currentView.txt_1:setString(GameConfig.getLanguage(partnerCfg.name))
                -- panel:showName(GameConfig.getLanguage(partnerCfg.name))
                panel:setTouchedFunc(c_func(_func, v),nil,nil,nil,nil,false)
            end          
        end
    end
end
function PartnerQingBaoView:starShowLovePao(  )
    if FuncPartner.isChar(self.partnerId) then
        return
    end
    local itemPanel = self.scroll_1:getViewByData(1)
    if not self.currentFrame then
        self.currentFrame = 0
    end
    
    self.currentFrame = self.currentFrame + 1
    if itemPanel then
        local panel = itemPanel.panel_1.panel_1
        if self.currentFrame >= 150 then
            self.currentFrame = 0

            if not self.historyT then
                self.historyT = {}
            elseif table.length(self.historyT) >= self.qiPaoNum then
                self.historyT = {}
            end
            local lovePartners = FuncNewLove.getVicePartnersListByPartnerId(self.partnerId)
            local T = {}
            for i,v in pairs(lovePartners) do                
                local isSHow = false
                for ii,vv in pairs(self.historyT) do
                    if vv == i then
                        isSHow = true
                    end
                end

                if not isSHow then
                    table.insert(T,i)
                end
            end
            local index = math.random(1, #T)
            local pid = lovePartners[T[index]]
            local partnerCfg = FuncPartner.getPartnerById(pid)
            if pid and partnerCfg.isShow == 1 then
                table.insert(self.historyT,T[index])
                local posX = -80 + (T[index]-1) * 120
                echo("self.partnerId,pid === ",self.partnerId,pid)
                local str = FuncNewLove.getLoveByPartnerId(self.partnerId,pid).talk
                panel.txt_1:setString(GameConfig.getLanguage(str))
                panel:setPosition(posX, -40)
            else
                self.currentFrame = 150
            end
        end 
    end
end


function PartnerQingBaoView:getDaPeiData(  )
    local parnterId = self.partnerId
    if FuncPartner.isChar(parnterId) then
        parnterId = "5000"
    end
    local data = FuncPartner.getPartnerDapei(parnterId)
    return data
end
-- 新手搭配
function PartnerQingBaoView:xinshoudapei( view )
    local data = self:getDaPeiData(  )
    -- dump(data, "\n\ndata====")
    local panel = view.panel_1
    panel:visible(false)
    local posx = panel:getPositionX()
    local posy = panel:getPositionY()
    view.ctn_1:removeAllChildren()
    for k,v in pairs(data) do
        local _view = UIBaseDef:cloneOneView(panel)
        view.ctn_1:addChild(_view)
        _view:pos(posx,posy - (k-1)*83 - 5)
        self:updateDaPeiItem( _view, v )
    end
    
end
function PartnerQingBaoView:updateDaPeiItem( view, itemData )
    local partners = itemData.viceLovePartner
    local num = #partners
    if num > 3 then
        num = 3
    end
    view.mc_1:showFrame(num)

    local function tishengFunc( id )
        EventControler:dispatchEvent(PartnerEvent.PARTNER_CHANGE_TISHENG_UI_EVENT,tonumber(id))
    end

    local function hechengFunc( partnerId )
        local partnerData = FuncPartner.getPartnerById(partnerId)
        EventControler:dispatchEvent(PartnerEvent.PARTNER_CHANGE_HECHENG_UI_EVENT,partnerData)
    end

    local function fabaoFunc(treasureId)
        if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_NEW) then
            WindowControler:showTips(GameConfig.getLanguage("tid_common_2033")) 
        else    
            WindowControler:showWindow("TreasureMainView", treasureId)
        end
    end

    for k,v in pairs(partners) do
        local panel = view.mc_1.currentView["UI_"..k]
        if FuncTreasureNew.isTreasureById(v) then
            -- 策划说 头像框颜色 资质对应颜色
            local frame = FuncTreasureNew.getKuangColorFrame(v)
            panel.mc_kuang:showFrame(frame)
            panel.mc_di:showFrame(frame)
            -- icon
            local iconPath = FuncRes.iconTreasureNew(v)
            local treasureIcon = display.newSprite(iconPath)
            panel.ctn_1:removeAllChildren()
            panel.ctn_1:addChild(treasureIcon)
            if TreasureNewModel:isHaveTreasure(v) then
                panel:setIconZhiHui(false)
            else
                panel:setIconZhiHui(true)
            end
            panel:setTouchedFunc(function (  )
                fabaoFunc(v)
            end)
        else
            panel:updataUI(v)
            if PartnerModel:isHavedPatnner(v) then
                panel:setIconZhiHui(false)
                panel:setTouchedFunc(function (  )
                    tishengFunc( v )
                end)
            else
                panel:setIconZhiHui(true)
                panel:setTouchedFunc(function ( ... )
                    hechengFunc(v)
                end)
            end
        end
        
        panel:hideStar(false)
        panel:hideLevel(false)
    end

    -- 描述
    local des = itemData.reason
    view.txt_2:setString(GameConfig.getLanguage(des))
end


-- 标签
function PartnerQingBaoView:biaoqian( view )
    if not FuncPartner.isChar(self.partnerId) then
        local partnerData = FuncPartner.getPartnerById(self.partnerId)
        local partnerTag = partnerData.tag
        if not partnerTag then
            echoError("伙伴的传记信息没配",self.partnerId)
            return
        end
        -- 仙剑版本 #tid_partner_ui_011
        local banben = FuncCommon.getPartnerTagDataByIdAndTag( "2",partnerTag[2] )
        banben = GameConfig.getLanguage(banben)
        view.txt_3:setString(banben)
        -- 种族
        local zhongzu = FuncCommon.getPartnerTagDataByIdAndTag( "4",partnerTag[4] )
        zhongzu = GameConfig.getLanguage(zhongzu)
        view.txt_5:setString(zhongzu)
        -- 门派
        local menpai = FuncCommon.getPartnerTagDataByIdAndTag( "6",partnerTag[6] ) 
        menpai = GameConfig.getLanguage(menpai)
        view.txt_7:setString(menpai)
        -- 武器
        local wuqi = FuncCommon.getPartnerTagDataByIdAndTag( "5",partnerTag[5] ) 
        wuqi = GameConfig.getLanguage(wuqi)
        view.txt_9:setString(wuqi)
    end
end

-- 故事
function PartnerQingBaoView:gushi( view )
    local partnerData = FuncPartner.getPartnerById(self.partnerId)
    view.txt_2:setString(GameConfig.getLanguage(partnerData.describe)) 
end

-- 所有属性
function PartnerQingBaoView:getPropertyT( _type )
    -- 属性vec
    local propertyVec1 = {};
    local propertyVec2 = {};

    local function initPropertyF(propertyData)
        for i,v in pairs(propertyData) do
            if self:isInitProperty(v.key) then
                table.insert(propertyVec1,v)
            else
                table.insert(propertyVec2,v)
            end
        end
    end;

    local partnerData
    --初始属性
    if FuncPartner.isChar(self.partnerId) then
        partnerData = CharModel:getCharData()
        local charAttrData = CharModel:getCharAttr()
        charAttrData = FuncBattleBase.formatAttribute( charAttrData )
        initPropertyF(charAttrData)
    else
        partnerData = PartnerModel:getPartnerDataById(tostring(self.partnerId))
        if partnerData then
            local skins = PartnerSkinModel:getSkinsByPartnerId(self.partnerId)
            local data = PartnerModel:getPartnerAttr(tostring(self.partnerId))
            data = FuncBattleBase.formatAttribute( data )
            initPropertyF(data)
        else
            partnerData = FuncPartner.getPartnerById(self.partnerId);
            local data1 = FuncBattleBase.countFinalAttr( partnerData.initAttr )
            data1 = FuncBattleBase.formatAttribute( data1 )
            initPropertyF(data1)
        end
    end

    if _type == 1 then
        return propertyVec1
    else
        return propertyVec2
    end
end
-- 基础属性
function PartnerQingBaoView:jichushuxing( view )
    -- 属性vec
    local dataAttr = self:getPropertyT(1)
    --初始属性    
    local basePanel = view.panel_1
    basePanel:visible(false)
    local posX = basePanel:getPositionX() + 20
    local posY = basePanel:getPositionY()
    local dis = 200
    view.ctn_1:removeAllChildren()
    for i,v in pairs(dataAttr) do
        local panel = UIBaseDef:cloneOneView(basePanel)
        panel.txt_1:setString(FuncBattleBase.getAttributeName( v.key )..": "..v.value)
        panel.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.key)])
        view.ctn_1:addChild(panel)
        panel:pos((i-1)*dis+posX,posY-5)
    end
end
-- 高级属性
function PartnerQingBaoView:gaojishuxing( view )
    -- 属性vec
    local dataAttr = self:getPropertyT(2)

    local basePanel = view.panel_1
    basePanel:visible(false)
    local posX = basePanel:getPositionX() + 20
    local posY = basePanel:getPositionY()
    local disX = 200
    local disY = 50
    view.ctn_1:removeAllChildren()
    for i,v in pairs(dataAttr) do
        local panel = UIBaseDef:cloneOneView(basePanel)
        panel.txt_1:setString(FuncBattleBase.getAttributeName( v.key )..": "..v.value)
        panel.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.key)])
        view.ctn_1:addChild(panel)

        local row = math.floor((i-1)/4)
        panel:pos((i-1 - row * 4)*disX+posX,posY-row*disY -5)
    end
end

function PartnerQingBaoView:updateUIWithPartner(partnerData)
    -- dump(partnerData,"shax0------",4)
    echo("partnerData.id === ",partnerData.id)
	self.partnerId = partnerData.id
    self:updateUI()
    

    if not FuncPartner.isChar(self.partnerId) then     
        self.currentFrame = 150
        self.historyT = {}
        self.qiPaoNum = 4
        local lovePartners = FuncNewLove.getVicePartnersListByPartnerId(self.partnerId)
        for k,v in pairs(lovePartners) do
            local partnerCfg = FuncPartner.getPartnerById(v)
            if partnerCfg.isShow == 0 then
                self.qiPaoNum = self.qiPaoNum - 1
            end
        end
        self:scheduleUpdateWithPriorityLua(c_func(self.starShowLovePao,self), 0)
    end 
end


-- 是否会放到初始属性里 -- 这里 先这样写死
function PartnerQingBaoView:isInitProperty(_type) 
    if tonumber(_type) == 2 then
        return true
    elseif tonumber(_type) == 10 then
        return true
    elseif tonumber(_type) == 11 then
        return true
    elseif tonumber(_type) == 12 then
        return true
    else
        return false
    end
end

return PartnerQingBaoView;
