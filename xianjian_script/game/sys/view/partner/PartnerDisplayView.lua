--伙伴碎片合成
--2016-12-21 19:57:00
--@Author:xiaohuaixong
local PartnerDisplayView = class("PartnerDisplayView",UIBase)

function PartnerDisplayView:ctor(_name)
    PartnerDisplayView.super.ctor(self,_name)
    self._sortType = true
end

function PartnerDisplayView:loadUIComplete()
    self.kaiguan = self.panel_kai

    self:registerEvent()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.RightTop);--上方的资源条
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)--右上角返回按钮
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop)--左上角标题
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_xian,UIAlignTypes.RightTop)--
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_kai,UIAlignTypes.RightTop)--
    
    -- local panel_icon = UIBaseDef:createPublicComponent( "UI_partner_main","panel_icon" )
    -- self:addChild(panel_icon)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,panel_icon,UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_1, UIAlignTypes.Middle, 1 ,1, nil);
    self:buildPartnerStatic()
    self:updateView()

    -- self.panel_icon:visible(false)
end

function PartnerDisplayView:registerEvent()
    PartnerDisplayView.super.registerEvent(self)
    --伙伴的数目发生了变化
    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT,self.notifyPartnerChangeEvent,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_REDPOINT_ZONGKAIGUAN_EVENT,self.zongkaiguanJianTing,self)
    --关闭
    self.btn_back:setTap(c_func(self.onClose,self))
end

--伙伴数目监听
function PartnerDisplayView:notifyPartnerChangeEvent(_param)
    self:buildPartnerStatic()
    self:updateView()
end
--刷新UI
function PartnerDisplayView:updateView()
    local _data_source = self._nowPartner
    
    local _template_panel = self.UI_yong
    _template_panel:setVisible(false)
    --创建函数
    local _createFunc = function (_item)
        local _view = UIBaseDef:cloneOneView(_template_panel)
        _view:updateEveryItemView(_item)
        _view:setParentView(self)
        self._childView[_item.id] = _view
        return _view
    end

    --updateCellFunc
    local updateCellFunc = function (_item,_view)
        _view:updateEveryItemView(_item)
        self._childView[_item.id] = _view
    end
     --创建函数
    local _createFunc1 = function (_item)
        local _view = UIBaseDef:cloneOneView(_template_panel)
        _view:updateEveryCombineItemView(_item)
        _view:setParentView(self)
        return _view
    end

    --updateCellFunc
    local updateCellFunc1 = function (_item,_view)
        _view:updateEveryCombineItemView(_item)
    end
     --创建函数
    self.panel_fen:visible(false)
    local _createFunc2 = function (_item)
        local _view = UIBaseDef:cloneOneView(self.panel_fen)
        return _view
    end
    local updateCellFunc2 = function (_item,_view)
        
    end
    --param
    local _param = {
        data = _data_source,
        createFunc = _createFunc,
        updateCellFunc = updateCellFunc,
        perNums = 2,
        offsetX =0,
        offsetY =0,
        widthGap = 4,
        heightGap = 4,
        itemRect = {x=0,y=-130, width = 495,height = 130},
        perFrame = 1,
    }
    local _param1 = {
        data = self._combinePartner,
        createFunc = _createFunc1,
        updateCellFunc = updateCellFunc1,
        perNums = 2,
        offsetX =0,
        offsetY =0,
        widthGap = 4,
        heightGap = 4,
        itemRect = {x=0,y=-130, width = 495,height = 130},
        perFrame = 1,
    }
    local _param2 = {
        data = {1},
        createFunc = _createFunc2,
        updateCellFunc = updateCellFunc2,
        perNums = 1,
        offsetX =335,
        offsetY =25,
        widthGap = 4,
        heightGap = 10,
        itemRect = {x=0,y=-40, width = 771.75,height = 40},
        perFrame = 1,
    }
    self.scroll_1:styleFill({_param,_param2,_param1})
    self.scroll_1:hideDragBar()

    self.kaiguan:setTouchedFunc(c_func(self.zongkaiguanTap,self))

    local kaiguanKey = "zongkaiguai";
    local _bool = FuncPartner.getPartnerRedPoint(kaiguanKey)
    local kaiguanPanel = self.kaiguan
    local guanPosX = -6
    local kaiPosX = 28
    if _bool then 
        kaiguanPanel.mc_1:showFrame(1)
        kaiguanPanel.mc_2:showFrame(1)
        kaiguanPanel.mc_1:setPositionX(kaiPosX)
    else 
        kaiguanPanel.mc_1:showFrame(2)
        kaiguanPanel.mc_2:showFrame(2)
        kaiguanPanel.mc_1:setPositionX(guanPosX)
    end
end

--总开关显示监听   -- 小开关影响总开关的逻辑
function PartnerDisplayView:zongkaiguanJianTing()
    local kaiguanKey = "zongkaiguai";
    local _bool = FuncPartner.getPartnerRedPoint(kaiguanKey)
    local kaiguanPanel = self.kaiguan
    local guanPosX = -6
    local kaiPosX = 28
    local posY = kaiguanPanel.mc_1:getPositionY();
    local moveAnim;
    if _bool then -- 开到关
        --判断是否所有的笑开关的关闭
        if not PartnerModel:isAllKaiGuanClose() then
            return
        end
        kaiguanPanel.mc_1:showFrame(2)
        kaiguanPanel.mc_2:showFrame(2)
        moveAnim = act.moveto(0.2,guanPosX,posY)
    else --关到开
        kaiguanPanel.mc_1:showFrame(1)
        kaiguanPanel.mc_2:showFrame(1)
        moveAnim = act.moveto(0.2,kaiPosX,posY)
    end
    kaiguanPanel.mc_1:runAction(moveAnim)

    FuncPartner.setPartnerRedPoint(kaiguanKey,not _bool)


    PartnerModel:partnerRedPoint()
    PartnerModel:homeRedPointEvent()
    PartnerModel:dispatchShowApproveAnimEvent()
end
--总开关逻辑
function PartnerDisplayView:zongkaiguanTap()
    self.kaiguan:setTouchEnabled(false)
    FuncPartner.playPartnerRedBtnSound( )
    local _callBack = function()
        self.kaiguan:setTouchEnabled(true)
    end
    self:delayCall(_callBack, 0.5)
    local kaiguanKey = "zongkaiguai";
    local _bool = FuncPartner.getPartnerRedPoint(kaiguanKey)
    local kaiguanPanel = self.kaiguan
    local guanPosX = -6
    local kaiPosX = 28
    local posY = kaiguanPanel.mc_1:getPositionY();
    local moveAnim;
    if _bool then -- 开到关
        kaiguanPanel.mc_1:showFrame(2)
        kaiguanPanel.mc_2:showFrame(2)
        moveAnim = act.moveto(0.2,guanPosX,posY)
    else --关到开
        kaiguanPanel.mc_1:showFrame(1)
        kaiguanPanel.mc_2:showFrame(1)
        moveAnim = act.moveto(0.2,kaiPosX,posY)
    end
    kaiguanPanel.mc_1:runAction(moveAnim)

    FuncPartner.setPartnerRedPoint(kaiguanKey,not _bool)

    local aa = os.clock()
    for i,v in pairs(self._nowPartner) do
        PartnerModel:setRedPoindKaiGuanById(v.id,not _bool)
    end
    aa = os.clock() - aa
    
    self:delayCall(function ()
        EventControler:dispatchEvent(PartnerEvent.PARTNER_REDPOINT_KAIGUAN_EVENT)
    end,0.1)
    

    PartnerModel:partnerRedPoint()
    PartnerModel:homeRedPointEvent()
    PartnerModel:dispatchShowApproveAnimEvent()
    echo("aa =====",aa)
end


--点击碎片的来源
function PartnerDisplayView:clickButtonGetSource(_item)
    WindowControler:showWindow("GetWayListView", _item);
end


function PartnerDisplayView:onClose()
    self:startHide()
    PartnerModel:saveRedPoindLocal()
end

--对伙伴排序
function PartnerDisplayView:partner_table_sort(a,b)
    return PartnerModel:partner_table_sort( a,b )

end
--统计所有有关伙伴的信息
function PartnerDisplayView:buildPartnerStatic()
    --有关伙伴的表格数据
    local _partnerTable = FuncPartner.getAllPartner()
    --所有现在存在的伙伴数据
    local _nowPartners = PartnerModel:getAllPartner()
    --
    local _combinePartner = {} --待合成的伙伴的集合
    for _key,_value in pairs(_partnerTable) do
        if not _nowPartners[_key] then--如果该伙伴还没有被合成
            -- 是否要合成 
            local _isShow = FuncPartner.getPartnerById(_key).isShow
            if _isShow == 1 then
                table.insert( _combinePartner,_key )
            end
        end
    end
    local __nowPartner = {};
    for i,v in pairs(_nowPartners) do
        table.insert( __nowPartner,v )
    end
    
    local function _table_sort(a,b)
        local data1 = FuncPartner.getPartnerById(a)
        local data2 = FuncPartner.getPartnerById(b)
        -- 表里的默认排序
        if data1.sequence and data2.sequence then
            if data1.sequence < data2.sequence then
                return true
            else
                return false
            end
        else
            if data1.sequence then
                return true
            end
            if data2.sequence then
                return false
            end
        end
        return false
    end
    table.sort(__nowPartner,c_func(self.partner_table_sort,self))
    table.sort(_combinePartner,_table_sort)
    table.insert(__nowPartner,1,CharModel:getCharData())
    self._combinePartner = _combinePartner
    self._nowPartner = __nowPartner

    --记录所有的组件
    self._childView = {}
    --记录组件的索引
    self._childIndiceMap={}
end
return PartnerDisplayView
