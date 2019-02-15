--zhangqiang
--2017.5.12 

local PartnerSkinMainView = class("PartnerSkinMainView", UIBase);

local CHANGE_PARTNER_TYPE = {
    ZUO = 1,
    YOU = 2,
}
function PartnerSkinMainView:ctor(winName,partnerId)
    PartnerSkinMainView.super.ctor(self, winName);
    self.firstPartnerId = partnerId -- 记录进入时的伙伴ID
    self.partnerId = partnerId
end

--分辨率适配
function PartnerSkinMainView:uiAdjust()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_he, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_title, UIAlignTypes.LeftTop);

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_jianzuo, UIAlignTypes.Left);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_jianzuo, UIAlignTypes.Right);

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_list, UIAlignTypes.MiddleBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.Right);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.Left);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gushi, UIAlignTypes.Left);

--    FuncCommUI.setScale9Align(self.widthScreenOffset, self.scale9_ding,UIAlignTypes.MiddleTop, 1)
end

function PartnerSkinMainView:loadUIComplete()
	self:registerEvent();

    -- 左右切换按钮
    self.zuoBtn = self.btn_jianzuo
    self.youBtn = self.btn_jianyou

    -- 适配
    self:uiAdjust()

    -- 所有带皮肤伙伴
    self.allPartners = PartnerSkinModel:getPartnerSort()
    -- 伙伴对应的index
    self.allPartnersMap = {}
    local index = 1
    for i,v in pairs(self.allPartners) do
        self.allPartnersMap[tostring(v.id)] = index
        index = index + 1 
    end
    self.skinIndexMap = {}
    self.skinViewMap = {}
    self:initUI();
    
     -- 添加战斗属性的点击
    local node = FuncRes.a_white( 35*4,22*9.5)
    self.panel_1.ctn_touch:addChild(node)
    node:setPositionY(60)
    node:setTouchedFunc(c_func(self.playRandomAni,self))
    node:opacity(1)
end 

function PartnerSkinMainView:registerEvent()
	PartnerSkinMainView.super.registerEvent();

    --PartnerSkinEvent.SKIN_BUY_SUCCESS_EVENT
    EventControler:addEventListener(PartnerSkinEvent.SKIN_BUY_SUCCESS_EVENT,self.clickBuyCallBack,self)
    
    -- 左右伙伴切换按钮
    self.btn_jianzuo:setTap(c_func(self.changePartnerTap,self,CHANGE_PARTNER_TYPE.ZUO))
    self.btn_jianyou:setTap(c_func(self.changePartnerTap,self,CHANGE_PARTNER_TYPE.YOU))

    -- 退出
    self.btn_close:setTap(c_func(self.close,self))
    -- 故事书
    self.btn_gushi:setTap(c_func(self.clickLabel,self))
end



-- 左右伙伴切换事件
function  PartnerSkinMainView:changePartnerTap(_type)
    local partnerId = self:getNextPartnerId(_type)
    self.currentIndex = self.allPartnersMap[tostring(partnerId)]
    self.partnerId = partnerId
    echo("切换伙伴按钮",partnerId.."    index == "..self.currentIndex)
    -- 刷新UI
    self:initUI();
end
-- 得到下一个伙伴id
function PartnerSkinMainView:getNextPartnerId(_type)
    local getIdByIndexFunc = function (_index)
        for i,v in pairs(self.allPartnersMap) do
            if v == _index then
                return i
            end
        end
            dump(self.allPartnersMap,"找bug用")
            echo("需要的 index == ",_index)
            return nil
    end
    local nextIndex
    if CHANGE_PARTNER_TYPE.ZUO == _type then
        nextIndex = self.currentIndex - 1
        if nextIndex <= 0 then
            return nil
        end
    elseif CHANGE_PARTNER_TYPE.YOU == _type then 
        nextIndex = self.currentIndex + 1 
        if nextIndex > table.length(self.allPartners) then
            return nil        
        end
    end
    
    return getIdByIndexFunc(nextIndex)
end
function PartnerSkinMainView:initUI()
    -- 当前伙伴index
    self.currentIndex = self.allPartnersMap[tostring(self.partnerId)]
    
    self.currentSkinId = PartnerSkinModel:getDefaltSkinByPartnerId(self.partnerId)
    self:initList();
    self:refreshBtn(); -- 刷新左右按钮是否显示
    self:updateArtBySkinId(self.partnerId);
end
-- 所有伙伴
-- 刷新按钮显示
function PartnerSkinMainView:refreshBtn()
    echo("所有 伙伴数量 === ",#self.allPartners)
    if self.currentIndex > 1 and self.currentIndex < #self.allPartners then
        self.zuoBtn:visible(true)
        self.youBtn:visible(true)
    elseif self.currentIndex == 1 and self.currentIndex == #self.allPartners then 
        self.zuoBtn:visible(false)
        self.youBtn:visible(false)
    elseif self.currentIndex == 1 then
        self.zuoBtn:visible(false)
        self.youBtn:visible(true)
    elseif self.currentIndex == #self.allPartners then
        self.zuoBtn:visible(true)
        self.youBtn:visible(false)
    end
end

function PartnerSkinMainView:initList()
    
    self.scroll = self.scroll_list
    self.mc_sz:visible(false)
    local allPartnerSkin = PartnerSkinModel:getAllSkinByPartnerId(self.partnerId)
    local createItemFunc = function (data,index)
        local baseCell = UIBaseDef:cloneOneView(self.mc_sz);
        self:updateCell(baseCell, data);
        self.skinIndexMap[index] = data
        self.skinViewMap[index] = baseCell
        return baseCell;
    end
    local updateCellFunc = function (data,baseCell,index)
        self:updateCell(baseCell, data);
        self.skinIndexMap[index] = data
        self.skinViewMap[index] = baseCell
        return baseCell;
    end
    local scrollParams = { 
        {
            data = allPartnerSkin,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -240, width = 240, height = 240},
        }
    };

    
    self.scroll:setScrollPage(1, 30, 1,{scale = 0.5,wave = 0.38},c_func(self.scrollMoveEndCallBack, self))
    self.scroll:styleFill(scrollParams)
    self.scroll:hideDragBar()

    -- 定位到当前选中框
    dump(self.skinIndexMap,"---- 批复数据")
    local pos = 1
    for i,v in pairs(self.skinIndexMap) do
        if v == self.currentSkinId then
            pos = i
        end
    end
    echo("当前皮肤ID==== "..self.currentSkinId.."    pos === "..pos)
    self:delayCall(function ()
        self.scroll:gotoTargetPos(pos,1,1)
    end,0.01)


end
function PartnerSkinMainView:scrollMoveEndCallBack(itemIndex,groupIndex)
    echo("------------scrollMoveEndCallBack ==== ",itemIndex)
    if itemIndex < 1 then
        itemIndex = 1
    end
    local skinId = self.skinIndexMap[itemIndex];
    echo("------------self.currentSkinId ==== ",skinId)
    self.currentSkinId = skinId
    
    self:updateArtBySkinId(self.partnerId);
    -- 选中框
    for i,v in pairs(self.skinViewMap) do
        local panel_cell = v.currentView.panel_cell
        if panel_cell then
            if i == itemIndex then
                panel_cell.panel_xuan:visible(true)
            else
                panel_cell.panel_xuan:visible(false)
            end
        end
    end

end

-- 刷新下方皮肤头像
function PartnerSkinMainView:updateCell(baseCell,data)
    local currentPartner = self.partnerId --当前伙伴
    local skinId = data; -- 皮肤ID
    local skinCfg = FuncPartnerSkin.getPartnerSkinById(skinId);
    if skinCfg.isOpen == 0 then
        -- 此时是 敬请期待
        baseCell:showFrame(2)

    else
        baseCell:showFrame(1)
        local panel_cell = baseCell.currentView.panel_cell
        -- 头像
        local sp = FuncPartnerSkin.getPartnerIcon(data)
        panel_cell.ctn_1:removeAllChildren()
        panel_cell.ctn_1:addChild(sp)
        -- 时装name 
        panel_cell.txt_name:setString(GameConfig.getLanguage(skinCfg.name))
        -- 穿戴中
        local _zhuangtai = PartnerSkinModel:getSkinStage(currentPartner,skinId)
        if _zhuangtai == FuncPartnerSkin.SKIN_ZT.ON then
            panel_cell.panel_cdz:visible(true)
        else
            panel_cell.panel_cdz:visible(false)
        end
        -- 隐藏推荐
        panel_cell.panel_tuijian:visible(false)
        -- 选中框
        if skinId == self.currentSkinId then
            panel_cell.panel_xuan:visible(true)
        else
            panel_cell.panel_xuan:visible(false)
        end
        
    end

end

function PartnerSkinMainView:showNotOpen( skinId )
    local name = FuncGarment.getGarmentName( skinId ) 
    WindowControler:showTips( name .. GameConfig.getLanguage("#tid_partnerskin_005")); 
end

-- 刷新选中的皮肤显示
function PartnerSkinMainView:setSelectSkin(skinId)


end
-- 播放大招
function PartnerSkinMainView:playRandomAni()
    echo("--------播放大招")
    local ani = FuncPartnerSkin.getValueByKey( self.currentSkinId,"standSkillStart")
    local arrAction = {
            {label = ani,loop = false},
            {label = "stand",loop = true},
        };
    
    self.dazhaoDonghua:playActionArr(arrAction);
end
--根据 partnerId 更改立绘
function PartnerSkinMainView:updateArtBySkinId(partnerId)
    local partnerCfg = FuncPartner.getPartnerById(partnerId)

    echo("默认显示皮肤ID == ",self.currentSkinId)
    local id = self.currentSkinId
    --立绘
    local artSp = FuncPartner.getPartnerLiHuiByIdAndSkin(partnerId,id )
    self.ctn_icon:removeAllChildren();
    self.ctn_icon:addChild(artSp);

    local partnerData = PartnerModel:getPartnerDataById(partnerId)
    --动画
    local ani = FuncPartner.getHeroSpineByPartnerIdAndSkin(self.partnerId,id,nil,partnerData)
    self.panel_1.ctn_ani:removeAllChildren();
    self.panel_1.ctn_ani:addChild(ani);
    ani:playLabel("stand");
    self.dazhaoDonghua = ani

   

    --伙伴名字
    local nameStr = FuncPartnerSkin.getPartnerName(id)
    self.panel_name.txt_name:setString(nameStr);
    -- 皮肤名字
    local skinName = FuncPartnerSkin.getSkinName(id)
    self.panel_name.txt_1:setString(skinName);

    -- 故事
    self.btn_gushi:setVisible(true);
    
    --判断动画下面按钮 状态
    local mcBtn = self.panel_1.mc_btn
    local mcTxt = self.panel_1.mc_1 
    local btnZt = PartnerSkinModel:getSkinStage(partnerId,id)
    echo("皮肤状态 ===== ",btnZt)
    if btnZt == FuncPartnerSkin.SKIN_ZT.ON then -- 穿戴中
        mcBtn:showFrame(4)
        mcTxt:showFrame(1)
    elseif btnZt == FuncPartnerSkin.SKIN_ZT.BUY then -- 可购买
        mcBtn:showFrame(1)
        mcTxt:showFrame(1)
        mcTxt:visible(true)
        local costNum = FuncPartnerSkin.getCostNum( id )
        mcBtn.currentView.btn_buy:getUpPanel().txt_1:setString(costNum)
        mcBtn.currentView.btn_buy:setTap(c_func(self.clickBuy,self,id))
    elseif btnZt == FuncPartnerSkin.SKIN_ZT.NOT_ON then -- 可穿戴
        mcBtn:showFrame(3)
        mcTxt:visible(false)
        mcBtn.currentView.txt_1:visible(false)
        mcBtn.currentView.btn_on:setTap(c_func(self.clickOn,self,id))
    elseif btnZt == FuncPartnerSkin.SKIN_ZT.JIESUO then -- 解锁
        mcBtn:showFrame(6)
        local condition = self:jiesuoMiaoshu(self.currentSkinId);
        mcBtn.currentView.txt_1:setString(condition[1])
        mcBtn.currentView.btn_buy:setTap(function ()
            WindowControler:showTips(condition[1])
        end)
        mcTxt:visible(false)
    elseif btnZt == FuncPartnerSkin.SKIN_ZT.TIME then -- 活动/过期
        mcBtn:showFrame(5)
        mcTxt:showFrame(1)
        mcTxt:visible(true)
    elseif btnZt == FuncPartnerSkin.SKIN_ZT.HUOQU then -- 活动获取
        mcBtn:showFrame(5)
        mcTxt:showFrame(1)
        mcTxt:visible(true)
    elseif btnZt == FuncPartnerSkin.SKIN_ZT.YUSHOU then -- 即将上架
        mcBtn:showFrame(2)
        mcTxt:visible(false)
        mcBtn.currentView.btn_buy:setTap(c_func(self.jijiangShangxian,self,id))
    end
end
-- 解锁条件描述
function PartnerSkinMainView:jiesuoMiaoshu(skinid)
    local condition = FuncPartnerSkin.getValueByKey( skinid,"condition")
    local desT = {}
    for i,v in pairs(condition) do
        local strT = string.split(v,",")
        local _type = strT[1]
        local _value = strT[2]
        if tonumber(_type) == 1 then --等级
            local str = "伙伴".._value.."级解锁购买"
            table.insert(desT,str)
        elseif tonumber(_type) == 2 then --星级
            local str = "伙伴".._value.."星解锁购买"
            table.insert(desT,str)
        elseif tonumber(_type) == 3 then --品质
            local str = "伙伴".._value.."品解锁购买"
            table.insert(desT,str)
        end
    end
    return desT
end
-- 故事书
function PartnerSkinMainView:clickLabel()
    WindowControler:showWindow("PartnerSkinStoryBView", self.currentSkinId,self.partnerId);
end

--购买
function PartnerSkinMainView:clickBuy(skinId)
    WindowControler:showWindow("PartnerSkinBuyView", skinId);
end
-- 购买回调
function PartnerSkinMainView:clickBuyCallBack(params)
    self.currentSkinId = params.params.skinId
    self:updateArtBySkinId(self.partnerId)
--    self:initList()
end
--穿戴
function PartnerSkinMainView:clickOn(skinId) 
    local onSkinId = PartnerSkinModel:getDefaltSkinByPartnerId(self.partnerId)
    self.lastOnCell = self.scroll:getViewByData(onSkinId)
    local suyanId = PartnerSkinModel:getSuYanSkinId(self.partnerId)
    if skinId == suyanId then
        PartnerSkinServer:skinOnServer(self.partnerId,"",c_func(self.clickOnCallBack,self))
    else
        PartnerSkinServer:skinOnServer(self.partnerId,skinId,c_func(self.clickOnCallBack,self))
    end
end

function PartnerSkinMainView:clickOnCallBack() 
--    self:delayCall(c_func(self.initUI,self), 0.1 )
    self:updateArtBySkinId(self.partnerId)
    self.lastOnCell.currentView.panel_cell.panel_cdz:visible(false)
    self.currentOnCell = self.scroll:getViewByData(self.currentSkinId)
    self.currentOnCell.currentView.panel_cell.panel_cdz:visible(true)
end
-- 皮肤即将上线
function PartnerSkinMainView:jijiangShangxian()
    WindowControler:showTips(GameConfig.getLanguage("#tid_partnerskin_006")) 
end
function PartnerSkinMainView:close()
    if self.firstPartnerId ~= self.partnerId then
        EventControler:dispatchEvent(PartnerEvent.PARTNER_CHANGE_TISHENG_UI_EVENT,tonumber(self.partnerId))
    end
    self:startHide()
end

return PartnerSkinMainView;