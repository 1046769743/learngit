 -- 伙伴系统左侧的伙伴按钮管理
-- 2016-12-6 16:32:44
-- Author:xiaohuaxiong
local PartnerBtnView = class("PartnerBtnView", UIBase)

function PartnerBtnView:ctor(_winName)
    PartnerBtnView.super.ctor(self, _winName)
    -- 当前被选中的伙伴
    self._selectPartner = 1
    -- 当前被选中的伙伴ID
    self._selectPartnerId = ""
    -- 当前选中的类型 [1可合成类型 2主角 3奇侠 4不可合成]
    self._selectParterType = 1
    -- 关于 ParnterView的引用
    self._partnerView = nil
    -- 所有的单元组件
    self._childViews = { }
    --记录伙伴id与View之间的映射
    self._childIndiceMap={}
    -- 所有的合成单元组件
    self._childCombineViews = { }
    --记录伙伴id与View之间的映射
    self._childCombineIndiceMap={}
    -- 所有的可合成单元组件
    self._childCanCombineViews = { }
    --记录伙伴id与View之间的映射
    self._childCanCombineIndiceMap={}
    --记录主角信息
    self._partnerChar = {}
    self._childPartberCharView = {}
    --排序方式 true正序 false 反序
    self._sortType = true
end

function PartnerBtnView:setPartnerView(_class)
    self._partnerView = _class
end
function PartnerBtnView:loadUIComplete()
    FuncCommUI.setScrollAlign(self.widthScreenOffset,self.panel_3.scroll_1,UIAlignTypes.MiddleBottom,1,0)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_3.scale9_2,UIAlignTypes.MiddleBottom,1,0)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_3.btn_huan,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_3.btn_hong,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_3.panel_xian,UIAlignTypes.LeftBottom)

    self:registerEvent()
    self:performPartner()
    self:combinePartnerStatic()
    self:partnerCharData()
    self:initData()
end
function PartnerBtnView:itemChange()
    self:performPartner()
    self:combinePartnerStatic()
    self:partnerCharData()
    self:updateView()
end
function PartnerBtnView:registerEvent()
    PartnerBtnView.super.registerEvent(self)
    self.panel_3.btn_huan:setTap(c_func(self.partnersSortAction,self))
    self.panel_3.btn_hong:setTap(function ()
        WindowControler:showWindow("PartnerDisplayView")
    end)


    
    -- 注册事件监听,伙伴系统中伙伴数目的变化,或者伙伴本身的变化
    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT, self.notifyPartnerNumChanged, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_INFO_CHANGE_EVENT, self.notifyPartnerInfoChanged, self)
    EventControler:addEventListener(UserEvent.USER_INFO_CHANGE_EVENT, self.notifyCharInfoChanged, self)

    EventControler:addEventListener(PartnerEvent.PARTNER_COST_ITEM_ENHANCE_EVENT,self.notifyPartnerRedPoint,self)
    --监听装备升级变化
    EventControler:addEventListener(PartnerEvent.PARTNER_EQUIPMENT_ENHANCE_EVENT,self.notifyPartnerRedPoint,self)
    --奇侠传记发生变化
    EventControler:addEventListener(BiographyUEvent.EVENT_REFRESH_UI,self.notifyPartnerRedPoint,self)
    --
    EventControler:addEventListener(PartnerEvent.PARTNER_CHANGE_TISHENG_UI_EVENT,self.changTiShengUI,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_CHANGE_HECHENG_UI_EVENT,self.changHechengUI,self)
    -- EventControler:addEventListener(PartnerEvent.PARTNER_HECHENG_SUCCESS_EVENT,self.changTiShengXinUI,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_SKIN_CHANGE_SUCCESS_EVENT,self.notifyPartnerInfoChanged,self)

    --监听 主角时装变化
    EventControler:addEventListener(GarmentEvent.GARMENT_CHANGE_ONE, self.changeCharGarment, self)
    -- 道具发生变化
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.notifySuipianNumChanged, self);   

    EventControler:addEventListener(PartnerEvent.PARTNER_LEVEL_ANIM_EVENT, self.needPlayAttentionAnim, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_STAR_ANIM_EVENT, self.playStarAttentionAnim, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_ANIM_EVENT, self.playQualityAttentionAnim, self)
end

--升品时需要播放特效
function PartnerBtnView:playQualityAttentionAnim()
    if self.curSelectedView and self.curSelectedView.currentView.panel_1.ctn_qualityBao then
        FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.LARGE_BAO, self.curSelectedView.currentView.panel_1.ctn_qualityBao)
    end
end

--升星时需要播放特效
function PartnerBtnView:playStarAttentionAnim()
    if self.curSelectedView and self.curSelectedView.currentView.panel_1.ctn_starBao then
        FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.LARGE_BAO, self.curSelectedView.currentView.panel_1.ctn_starBao)
    end
end

--升级时需要播放特效 且 设置新的等级
function PartnerBtnView:needPlayAttentionAnim(event)
    local curLevel = 0
    local curPartner = self._selectPartnerId
    if event.params and event.params.level and event.params.partnerId then
        curLevel = event.params.level
        curPartner = event.params.partnerId
    end
    
    local data = self:getPartnerDataById(curPartner)
    local partnerView = self.scrollView:getViewByData(data)
    if partnerView and partnerView.currentView.panel_1.ctn_anim then
        if event.params.hasChanged then
            partnerView.currentView.panel_1.UI_1:setLevel(curLevel)
        else
            FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, partnerView.currentView.panel_1.ctn_anim)
            partnerView.currentView.panel_1.UI_1:setLevel(curLevel)
        end
    end
end

function PartnerBtnView:getPartnerDataById(partnerId)
    for i,v in ipairs(self._allPartners) do
        if tostring(v.id) == tostring(partnerId) then
            return v
        end
    end
end

--监听主角时装变化
function PartnerBtnView:changeCharGarment()
    self:updateCharItemView(self._partnerChar[1],self._childCharViews)
end

function PartnerBtnView:initData()
    if table.length(self._canCombinePartner) > 0 then
        self._selectPartner = 1
        self._selectPartnerId = self._canCombinePartner[self._selectPartner]
        self._selectParterType = 1
    else
        self._selectPartner = 1
        self._selectPartnerId = self._partnerChar[1].id
        self._selectParterType = 2
    end
end
function PartnerBtnView:changTiShengXinUI(_param)
    local _id = _param.params
    echo("此时合成的伙伴ID ==== ",_id)
    local _index = 1
    for i,v in pairs(self._allPartners) do
        if tostring(v.id) == tostring(_id) then
            _index = i
        end
    end

    self.scrollView:gotoTargetPosForOffset(_index,3,1,0,0)
    self:onTouchCallFunc(_index,3)
    local _partnerInfo = PartnerModel:getPartnerDataById(_id)
    self._partnerView:changeUIInBtnView( _partnerInfo)
    -- 显示
    self._childViews[_index]:showFrame(1)
    self._childViews[_index].currentView.panel_1.mc_xin:setVisible(true)
    self._childViews[_index].currentView.panel_1.mc_xin:showFrame(2)
end

function PartnerBtnView:changTiShengUI(_param)
    local _id = _param.params
    if FuncPartner.isChar(_id) then
        self.scrollView:gotoTargetPosForOffset(1,2,1,0,0)
        self:onTouchCharFunc()
        local _partnerInfo = PartnerModel:getPartnerDataById(_id)
        self._partnerView:changeUIInBtnView( _partnerInfo)
        self._partnerView.UI_1:setCurrentSelect(1)
    else
        local _index = 1
        for i,v in pairs(self._allPartners) do
            if tostring(v.id) == tostring(_id) then
                _index = i
            end
        end
        self.scrollView:gotoTargetPosForOffset(_index,3,1,0,0)
        self:onTouchCallFunc(_index,3)
        local _partnerInfo = PartnerModel:getPartnerDataById(_id)
        self._partnerView:changeUIInBtnView( _partnerInfo)

        self._partnerView.UI_1:setCurrentSelect(1)
    end
    
    
end
function PartnerBtnView:changHechengUI(_param)
    local data = _param.params
    if PartnerModel:isCanCombienPartner(data.id) then 
        local aa = self._childCanCombineIndiceMap[data.id]
        echo("----xxxxxx---------",aa,data.id)
        dump(self._childCanCombineIndiceMap, "xxxxxxxxxxxx==========", 6)
        self.scrollView:gotoTargetPosForOffset(self._childCanCombineIndiceMap[data.id],1,1,0,0)
        self:onTouchCombine(data,self._childCanCombineIndiceMap[data.id])
    else
        self.scrollView:gotoTargetPosForOffset(self._childCombineIndiceMap[data.id],4,1,0,0)
        self:onTouchCombine(data,self._childCombineIndiceMap[data.id])
    end
end

function PartnerBtnView:tiaozhuanChangeUI(data,_type)

    local index = 1
    if self._childCanCombineIndiceMap[data.id] then
        index = self._childCanCombineIndiceMap[data.id]
        _type = 1
        self._selectParterType = 1
    else
        index = self._childCombineIndiceMap[data.id]
        _type = 4
        self._selectParterType = 4
    end
    self._selectPartnerId = data.id
    -- echoError("\n\n_type======", _type, "data.id===", data.id, "self._selectPartnerId==", self._selectPartnerId, "index==", index)
    self.scrollView:gotoTargetPosForOffset(index,_type,1,0,0)
    self:delayCall(c_func(self.updateSelectKuang,self,self._selectParterType,self._selectPartnerId),0.2)
end

function PartnerBtnView:notifyPartnerRedPoint(_param)
    --找到相关的View
    for key,v in pairs(self._allPartners) do
        local panel = self.scrollView:getViewByData(v)
        if panel then
            panel.currentView.panel_1.panel_red:setVisible(self:isShowredPoint(v.id))
        end
    end

    -- 主角红点判断
    if self._childCharViews then
        local isShow = self:isShowredPoint(self._partnerChar[1].id)
        self._childCharViews.currentView.panel_1.panel_red:visible(isShow)
    end

    -- 可合成
    for i,v in pairs(self._canCombinePartner) do
        local isShow = true
        local panel = self.scrollView:getViewByData(v)
        if panel then
            panel.currentView.panel_red:visible(isShow)
        end
    end
    
end

--判断某一个伙伴图标的红点是否应该显式
function PartnerBtnView:isShowredPoint(_partnerId)
    -- if tostring(self._selectPartnerId) == tostring(_partnerId) then
    --     return false
    -- end

    if PartnerModel:getRedPoindKaiGuanById(_partnerId) == false then
        return false
    end

    local _tag1 = PartnerModel:isShowUpgradeRedPoint(_partnerId)--升级
    if _tag1 then
        return true 
    end
    local _tag2 = PartnerModel:isShowStarRedPoint(_partnerId) --升星
    if _tag2 then 
        return true 
    end
    local _tag3 = PartnerModel:isShowQualityRedPoint(_partnerId) --升品
 
    if _tag3 then 
        return true 
    end
     --技能
    local _tag4 = PartnerModel:redPointSkillShow(_partnerId) -- 技能
    if _tag4 then
        return true
    end

    -- 装备
    local _tag5 = PartnerModel:isShowEquipRedPoint(_partnerId) -- 装备
    if _tag5 then
        return true
    end
    -- 觉醒
    local _tag7 = PartnerModel:isEquipAwakeRedPoint(_partnerId) -- 觉醒
    if _tag7 then
        return true
    end

    local _tag8 = PartnerModel:isShowBiographyRedPoint(_partnerId)
    if _tag8 then
        return true
    end
    -- -- 情缘
    -- local _tag6 = PartnerModel:isLoveRedPoint(_partnerId) -- 情缘
    -- if _tag6 then
    --     return true
    -- end
    return false
end

-------------------------------------------------------------------
--------------------------所有伙伴信息-----------------------------
-- 主角信息
function PartnerBtnView:partnerCharData()
    self._partnerChar = {}
    table.insert(self._partnerChar,CharModel:getCharData())
end
-- 处理所有的已拥有的伙伴信息
function PartnerBtnView:performPartner()
    self._allPartners = { }
    -- 逆向映射表,可以使用id值快速查找到伙伴的信息
    self._reversePartners = { }
    local _originPartner = PartnerModel:getAllPartner();
    for _key, _value in pairs(_originPartner) do
        table.insert(self._allPartners, _value)
    end
    --对伙伴排序
    table.sort(self._allPartners,c_func(self.partner_table_sort,self))
    for _index=1,#self._allPartners do
        self._reversePartners[tostring(self._allPartners[_index].id)] = _index;
    end
end
--统计所有待合成伙伴的信息
function PartnerBtnView:combinePartnerStatic()
    --有关伙伴的表格数据
    local _partnerTable = FuncPartner.getAllPartner()
    --所有现在存在的伙伴数据
    local _nowPartners = PartnerModel:getAllPartner()
    --
    local _canCombinePartner = {} -- 可合成的伙伴集合
    local _combinePartner = {} --待合成的伙伴的集合
    for _key,_value in pairs(_partnerTable) do
        if not _nowPartners[_key] then--如果该伙伴还没有被合成
            -- 是否要合成 
            local _isShow = FuncPartner.getPartnerById(_key).isShow
            if _isShow == 1 then
                if PartnerModel:isCanCombienPartner(_key) then
                    table.insert( _canCombinePartner,_key )
                else
                    table.insert( _combinePartner,_key )
                end
                
            end
        end
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
    table.sort(_combinePartner,_table_sort)
    for i,v in pairs(_combinePartner) do
        self._childCombineIndiceMap[v] = i
    end
    self._combinePartner = _combinePartner

    table.sort(_canCombinePartner,_table_sort)
    for i,v in pairs(_canCombinePartner) do
        self._childCanCombineIndiceMap[v] = i
    end
    self._canCombinePartner = _canCombinePartner

end


--尝试比较,如果数据刷新了,是否会导致伙伴的位置发生变化
function PartnerBtnView:tryComparePartner( )
    local _allPartners = { }
    -- 逆向映射表,可以使用id值快速查找到伙伴的信息
    local _reversePartners = { }
    local _originPartner = PartnerModel:getAllPartner();
    for _key, _value in pairs(_originPartner) do
        table.insert(_allPartners, _value)
    end
    --对伙伴排序
    table.sort(_allPartners,c_func(self.partner_table_sort,self))
    
    
    for _index=1,#_allPartners do
        _reversePartners[tostring(_allPartners[_index].id)] = _index;
    end

    --重新计算当前的伙伴排列
    if self._selectPartner < 0 or self._selectPartner > #self._allPartners then
        self._selectPartner = 1
    end
    local _currentPartnerId = self._allPartners[self._selectPartner].id
    self._selectPartnerId = tostring(_currentPartnerId)
    
    --重新计算当前的伙伴的id是否发生了变化
    local _now_select = _reversePartners[tostring(_currentPartnerId)]
    --echo("_now_select = ".._now_select.." self._selectPartner = "..self._selectPartner .. " _currentPartnerId" .. _currentPartnerId)
    
    --位置发生了变化
    
    if _now_select ~= self._selectPartner then
        self._allPartners = _allPartners
        self._reversePartners = _reversePartners
        self._selectPartner = _now_select
        return true
    end
    return false
end

-- 伙伴合成碎片发生变化
function PartnerBtnView:notifySuipianNumChanged(_param)
    if self._selectParterType == 4 then
        local needNum = PartnerModel:getCombineNeedPartnerNum(self._selectPartnerId)
        local haveNum = ItemsModel:getItemNumById(self._selectPartnerId);
        if haveNum < needNum then
            return
        end
        self._selectParterType = 1

        self:performPartner()
        self:partnerCharData()
        self:combinePartnerStatic()
        local _new_select = self._childCanCombineIndiceMap[tostring(self._selectPartnerId)]
        self._selectPartner = _new_select

        self:updateView()
    end
end
-- 伙伴的数目发生了变化,此时会导致伙伴系统列表发生变化
function PartnerBtnView:notifyPartnerNumChanged(_param)
    self:performPartner()
    local _id = _param.params
    if _id == self._selectPartnerId then
        local _new_select = self._reversePartners[tostring(_id)] 
        self._selectPartner = _new_select or self._selectPartner
        self._selectPartnerId = _id or self._selectPartnerId
        self._selectParterType = 3
    end

    self:partnerCharData()
    self:combinePartnerStatic()
    self:updateView()

    if _id == self._selectPartnerId then
        self:onTouchCallFunc(self._selectPartner,self._selectParterType,true)
    else
        -- 重新定位
        self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
    end
    
    for key,v in pairs(self._allPartners) do
        local panel = self.scrollView:getViewByData(v)
        if panel then
            panel.currentView.panel_1.panel_red:setVisible(self:isShowredPoint(v.id))
        end
    end
    
end
-- 某一个伙伴的信息发生了变化,必要时需要更新相关的数据结构,以及UI显示
function PartnerBtnView:notifyPartnerInfoChanged(_param)
    local _localPartner = _param.params;
    --只有在必要的时候才会刷
    -- if self:tryComparePartner() then
    --     self:updateView(true)
    --     return
    -- end
    for _key, _value in pairs(_localPartner) do
        local _index = self._reversePartners[_key];
        local _view = self._childViews[_index]
        if _view then
            local notChangeLevel = true
            self:updateViewItem(_view, _value, _index, notChangeLevel)
        end
    end
    self:updateSelectKuang(self._selectParterType,self._selectPartnerId)
end
-- 主角信息发生变化
function PartnerBtnView:notifyCharInfoChanged()
    local data = CharModel:getCharData()
    self._partnerChar[1] = data
    self:updateCharItemView(data,self._childCharViews)
end
-- 设置选中奇侠的id
function PartnerBtnView:setSelectPartner( _partnerId )
    if _partnerId then
        for i,v in ipairs(self._allPartners) do
            if tostring(v.id) == tostring(_partnerId) then
                self._selectPartner = i
                self._selectPartnerId = _partnerId
                self._selectParterType = 3
                break 
            end
        end

        for i,v in ipairs(self._canCombinePartner) do
            if tostring(v) == tostring(_partnerId) then
                self._selectPartner = i
                self._selectPartnerId = v
                self._selectParterType = 1
                break 
            end
        end

        for i,v in ipairs(self._combinePartner) do
            if tostring(v) == tostring(_partnerId) then
                self._selectPartner = i
                self._selectPartnerId = v
                self._selectParterType = 4
                break 
            end
        end

        if tostring(_partnerId) == tostring(UserModel:avatar()) then
            self._selectPartner = 1
            self._selectPartnerId = _partnerId
            self._selectParterType = 2
        end
        return true
    end
    return false
end
-- 伙伴跳转index
function PartnerBtnView:setCurrentPartner(_partnerId)
    if self:setSelectPartner( _partnerId ) then
        self:updateSelectKuang(self._selectParterType,self._selectPartnerId)
        self:gotoSelectPartner()
        --self:delayCall(c_func(self.updateSelectKuang,self,self._selectParterType,self._selectPartnerId),0)
    end
end
-- 伙伴移动到选中
function PartnerBtnView:gotoSelectPartner( )
    self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
end
-- 返回当前被选中的伙伴以及其索引
function PartnerBtnView:getCurrentPartner()
    if self._selectParterType == 1 then
        return self._canCombinePartner[self._selectPartner], self._selectPartner
    elseif self._selectParterType == 2 then 
        return self._partnerChar[1], 1
    elseif self._selectParterType == 3 then 
        return self._allPartners[self._selectPartner], self._selectPartner
    elseif self._selectParterType == 4 then 
        return self._combinePartner[self._selectPartner], self._selectPartner
    end
end
-- 返回当前伙伴type
function PartnerBtnView:getCurrentPartnerType()
    return self._selectParterType
end

-------------------------------------------------------------------------
---------------------------刷新伙伴详情----------------------------------

-- 设置生成的每一个伙伴详情的页面
function PartnerBtnView:updateViewItem(_view, _item, _index, notChangeLevel)
    --如果被选中了
    -- 品质
    _view:showFrame(1)
    local panel=_view.currentView.panel_1

    panel.mc_xin:setVisible(false)--伙伴出站标志暂时隐藏
    --伙伴ID------------iiiiiiiiiiiiiiiiiii  echo("----",_item.id)
    local _newPartnerIds = PartnerModel:getNewCombinePartner()
    for i,v in pairs(_newPartnerIds) do
        if tostring(v) == tostring(_item.id) then
            panel.mc_xin:setVisible(true)
            self._childViews[_index].currentView.panel_1.mc_xin:showFrame(2)
        end
    end

    panel.UI_1:updataUI(_item.id, _item.skin, nil, nil, notChangeLevel)
    panel.UI_1:setIconZhiHui(false)
    panel.UI_1:hideLevel(true)
    panel.UI_1:hideStar(true)
    -- 注册按钮回调事件
    panel:setTouchedFunc(c_func(self.onTouchCallFunc, self, _index,3),nil,nil,nil,nil,false )
    panel:setTouchSwallowEnabled(true)
    --红点
    local showRed = self:isShowredPoint(_item.id)
    panel.panel_red:setVisible(showRed)

    -- 选中框
    if tostring(self._selectPartnerId) == tostring(_item.id) then
        panel.panel_1:visible(true)
        self.curSelectedView = _view
    else
        panel.panel_1:visible(false)
    end
end
--刷新合成
function PartnerBtnView:updateCombineItemView(_item,_view)
    local cfgData = FuncPartner.getPartnerById(_item)
    _view:showFrame(2)
    local panel = _view.currentView
    panel.UI_1:updataUI(_item)
    panel.UI_1:setIconZhiHui(true)
    panel.UI_1:hideLevel(false)
    panel.UI_1:hideStar(false)

    local getType = cfgData.get or 1
    if tonumber(getType) == 2 or tonumber(getType) == 3 then
        -- panel.mc_song:scale(0.8)
        panel.mc_song:visible(true)
        if tonumber(getType) == 2 then
            panel.mc_song:showFrame(1)
        elseif tonumber(getType) == 3 then
            panel.mc_song:showFrame(2)
        end
        
    else
        panel.mc_song:visible(false)
    end

    --是否隐藏红点
    local needNum = PartnerModel:getCombineNeedPartnerNum(_item)
    local haveNum = ItemsModel:getItemNumById(_item);
    local isShow = haveNum >= needNum
    _view.currentView.panel_red:visible(isShow)

    -- 进度条
    local panel_progress = _view.currentView.panel_progress
    local progressTxt = panel_progress.txt_1
    progressTxt:setString(haveNum.."/"..needNum)
    panel_progress.progress_1:setPercent(haveNum/needNum*100)

    if haveNum >= needNum then
        _view:setTouchedFunc(c_func(self.onTouchCanCombine,self,cfgData),nil,nil,nil,nil,false)
    else
        _view:setTouchedFunc(c_func(self.onTouchCombine,self,cfgData),nil,nil,nil,nil,false)
    end
    
    _view:setTouchSwallowEnabled(true)

    -- 选中框
    if self._selectPartnerId == _item then
        _view.currentView.panel_1:visible(true)
        self.curSelectedView = _view
    else
        _view.currentView.panel_1:visible(false)
    end
end
-- 刷新头像icon
function PartnerBtnView:updateCharItemView(_item,_view)
    local quality = _item.quality
    local level = _item.level
    local star = _item.star
    local avatar = _item.id

    _view:showFrame(1)
    local panel=_view.currentView.panel_1

    panel.mc_xin:setVisible(false)--伙伴出站标志暂时隐藏
    
    local garmentId = GarmentModel:getOnGarmentId()
    panel.UI_1:updataUI(avatar, garmentId)
    panel.UI_1:setIconZhiHui(false)
    panel.UI_1:hideLevel(true)
    panel.UI_1:hideStar(true)
    -- panel.UI_1.panel_lv.txt_3:setString(tostring(_item.level))
    
    -- 注册按钮回调事件
    panel:setTouchedFunc(c_func(self.onTouchCharFunc, self),nil,nil,nil,nil,false )
    panel:setTouchSwallowEnabled(true)
    --红点
    panel.panel_red:setVisible(self:isShowredPoint(_item.id))

    --选中框
    if self._selectPartnerId == _item.id then
        panel.panel_1:visible(true)
        self.curSelectedView = _view
    else
        panel.panel_1:visible(false)
    end
end

----------------------------------------------------------------
-------------------------- 分类选中框---------------------------
-- 可合成 选中框
function PartnerBtnView:canCombineKuang(isShow)
    for i,v in pairs(self._canCombinePartner) do
        local view = self.scrollView:getViewByData(v);
        if view then
            view.currentView.panel_1:setVisible(false)
        end
    end
    
end
--主角 选中框
function PartnerBtnView:charKuang(isShow)
    if self._childCharViews then
        local panel = self._childCharViews.currentView.panel_1
        panel.panel_1:setVisible(isShow)
    end
end
-- 已拥有 选中框
function PartnerBtnView:partnerKuang(isShow)
    for i,v in pairs(self._allPartners) do
        local view = self.scrollView:getViewByData(v);
        if view then
            view.currentView.panel_1.panel_1:setVisible(isShow)
        end
    end
end
-- 不可合成 选中框
function PartnerBtnView:notCanCombineKuang(isShow)
    for i,v in pairs(self._combinePartner) do
        local view = self.scrollView:getViewByData(v);
        if view then
            view.currentView.panel_1:setVisible(isShow)
        end
    end
end
--选中框逻辑
function PartnerBtnView:updateSelectKuang(_type,id)
    self:charKuang(false)
    self:partnerKuang(false)
    self:notCanCombineKuang(false)
    self:canCombineKuang(false)
     
    if _type == 1 then  -- 可合成
        local panel = self.scrollView:getViewByData(id)
        if panel then
            panel.currentView.panel_1:setVisible(true)
            self.curSelectedView = panel
        end
    elseif _type == 2 then --主角
        if self._childCharViews then
            self._childCharViews.currentView.panel_1.panel_1:setVisible(true)
            self.curSelectedView = self._childCharViews
        end
    elseif _type == 3 then --已拥有
        local index = self._childIndiceMap[id]
        local data = nil
        for i,v in pairs(self._allPartners) do
            if tostring(v.id) == tostring(id) then
                data = v
            end
        end
        local panel = self.scrollView:getViewByData(data)
        if panel then 
            panel.currentView.panel_1.panel_1:setVisible(true)
            self.curSelectedView = panel
        end 
    elseif _type == 4 then --不可合成
        local panel = self.scrollView:getViewByData(id)
        if panel then
            panel.currentView.panel_1:setVisible(true)
            self.curSelectedView = panel
        end
    end

    self:notifyPartnerRedPoint()
end


------------------------------------------------------------------
-------------------------按钮的选中事件---------------------------
-- 主角按钮事件
function PartnerBtnView:onTouchCharFunc(update)
    if self.scrollView:isMoving() and update ~= true then
        return
    end

    if self._selectPartnerId == self._partnerChar[1].id then
        return
    end

    self._selectPartner = 1
    self._selectPartnerId = self._partnerChar[1].id
    self._selectParterType = 2

    self:updateSelectKuang(self._selectParterType,self._partnerChar[1].id)

    self._partnerView:changeUIInBtnView(self._partnerChar[1])
    -- self:notifyPartnerRedPoint()

    
    if self._partnerView.shengjiUIShow then
        WindowControler:showWindow("CompLevelUpTipsView", true)
    end
    self._partnerView:hideShengJiUI()
    self._partnerView:hidePingLunUI()

    FuncPartner.playPartnerBtnsSound()
end
-- 伙伴按钮事件
function PartnerBtnView:onTouchCallFunc(_index,_type,update)
    if self.scrollView:isMoving() then
        return
    end

    -- 只有在必要的时候才会刷新
    if self._selectPartnerId == self._allPartners[_index].id and update ~= true then
        return
    end
    if (_index ~= self._selectPartner or self._selectParterType ~= _type or update )then
        self._partnerView:changeUIInBtnView(self._allPartners[_index])
        local data = self._allPartners[_index]
        local _view = self.scrollView:getViewByData(data)

        if _view then
            _view.currentView.panel_1.mc_xin:setVisible(false)
        end

        self._selectPartner = _index
        self._selectPartnerId = self._allPartners[_index].id
        self._selectParterType = _type
        -- self:notifyPartnerRedPoint()

        self:updateSelectKuang(self._selectParterType,self._allPartners[_index].id)

        local _newPartnerIds = PartnerModel:getNewCombinePartner()
        for i,v in pairs(_newPartnerIds) do
            if tostring(v) == tostring(self._allPartners[_index].id) then
                PartnerModel:removeNewCombinePartner(i)
            end
        end

        self._partnerView:updateShengjiUI()
        self._partnerView:updatePingLunUI()


        FuncPartner.playPartnerBtnsSound()
    end
end 

--碎片合成事件
function PartnerBtnView:onTouchCombine(data)
    if self._selectPartnerId == data.id then
        return
    end

    self._partnerView:changeCombineUIWith( data)

    --隐藏已有伙伴的选中框
    self._selectPartner = self._childCombineIndiceMap[data.id]
    self._selectPartnerId = data.id
    self._selectParterType = 4
    
    self:updateSelectKuang(self._selectParterType,data.id)
    -- self:notifyPartnerRedPoint()

    self._partnerView:hideShengJiUI()
    self._partnerView:updatePingLunUI()
    FuncPartner.playPartnerBtnsSound()
end
--碎片合成事件
function PartnerBtnView:onTouchCanCombine(data)
    if self._selectPartnerId == data.id then
        return
    end
    self._partnerView:changeCombineUIWith( data)

    --隐藏已有伙伴的选中框
    self._selectPartner = self._childCanCombineIndiceMap[data.id]
    self._selectPartnerId = data.id
    self._selectParterType = 1
    
    self:updateSelectKuang(self._selectParterType,data.id)
    -- self:notifyPartnerRedPoint()

    self._partnerView:hideShengJiUI()
    self._partnerView:updatePingLunUI()
    FuncPartner.playPartnerBtnsSound()
end




-- 当有数据变化时引起的UI的刷新
function PartnerBtnView:updateView()
    self.scrollView = self.panel_3.scroll_1
    self.panel_3.mc_1:setVisible(false)

    local createFunc1 = function(_item, _index)
        local _view = UIBaseDef:cloneOneView(self.panel_3.mc_1)
        self._childCanCombineViews[_item] = _view
        self:updateCombineItemView(_item,_view)
        return _view
    end
    
    local updateCellFunc1 = function (_item,_view,_index)
        --重新映射,如果原来的位置已经被占用
        self._childCanCombineViews[_item] = _view
        self:updateCombineItemView(_item,_view)
    end
    local offetY = 0
    local offetX = 0
    local _widthGap = 0
    local _param1 = {
        data = self._canCombinePartner,
        createFunc = createFunc1,
        updateCellFunc = updateCellFunc1,
        perNums = 1,
        offsetX = offetX,
        offsetY = offetY,
        widthGap = _widthGap,
        heightGap = 0,
        itemRect = { x = 0, y = - 111.0, width = 128, height = 111 },
        perFrame = 1, 
        cellWithGroup = 1,
    }
    local createFunc2 = function(_item, _index)
        local _view = UIBaseDef:cloneOneView(self.panel_3.mc_1)
        self._childCharViews = _view
        self:updateCharItemView(_item,_view)
        return _view
    end
    
    local updateCellFunc2 = function (_item,_view,_index)
        --重新映射,如果原来的位置已经被占用
        self:updateCharItemView(_item,_view)
        self._childCharViews = _view
    end
    local _param2 = {
        data = self._partnerChar,
        createFunc = createFunc2,
        updateCellFunc = updateCellFunc2,
        perNums = 1,
        offsetX = offetX,
        offsetY = offetY,
        widthGap = _widthGap,
        heightGap = 0,
        itemRect = { x = 0, y = - 111.0, width = 128, height = 111 },
        perFrame = 1, 
        cellWithGroup = 2,
    }
    local createFunc3 = function(_item)
        local _view = UIBaseDef:cloneOneView(self.panel_3.mc_1)
        table.insert(self._childViews, _view) 
        self._childIndiceMap[_item.id] = #self._childViews
        self:updateViewItem(_view, _item, #self._childViews)
        return _view
    end
    
    local updateCellFunc3 = function (_item,_view,_index)
        --重新映射,如果原来的位置已经被占用
        self._childIndiceMap[_item.id] = _index
        self._childViews[_index] = _view
        self:updateViewItem(_view,_item,_index)
    end
    local _param3 = {
        data = self._allPartners,
        createFunc = createFunc3,
        updateCellFunc = updateCellFunc3,
        perNums = 1,
        offsetX = offetX,
        offsetY = offetY,
        widthGap = _widthGap,
        heightGap = 0,
        itemRect = { x = 0, y = - 111.0, width = 128, height = 111 },
        perFrame = 1,
        cellWithGroup = 3,
    }
    local createFunc4 = function (_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_3.mc_1)
        self._childCombineViews[_item] = _view
        self:updateCombineItemView(_item,_view)
        return _view
    end
    local updateCellFunc4 = function (_item,_view,_index)
        self._childCombineViews[_item] = _view
        self:updateCombineItemView(_item,_view)
    end
    local _param4 = {
        data = self._combinePartner,
        createFunc = createFunc4,
        updateCellFunc = updateCellFunc4,
        perNums =1,
        offsetX = offetX,
        offsetY = offetY,
        widthGap = _widthGap,
        heightGap = 4,
        itemRect = {x =0, y =-111,width = 128,height =111},
        perFrame = 1,
        cellWithGroup = 4,
    }
    self.scrollView:styleFill( { _param1,_param2,_param3,_param4})
    self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
end


-- 重新排序
function PartnerBtnView:partnersSortAction()
    if table.length(self._allPartners) <= 0 then
        return 
    end
    self._sortType = not self._sortType
    self:tryComparePartner()
    --和策划确认 重新排序 默认选中第一个
    
    self:onTouchCallFunc(1,3,true)
    self:updateView()
    self.scrollView:gotoTargetPosForOffset(1,1,0,0,0)

end
--对伙伴排序
function PartnerBtnView:partner_table_sort(a,b)
    local _sortType = function (_ret)
        if self._sortType then
            return _ret
        else    
            return not _ret
        end
    end
    local res = PartnerModel:partner_table_sort( a,b )

    return _sortType(res)
end

--退出战斗 头像选中框
function PartnerBtnView:changePartnerXuanzhongkuang(_type)
    -- 现在 只有已存在的伙伴可以进战斗   需要优化
    -- todo
    self:onTouchCallFunc(self._selectPartner,_type)
end

-- 伙伴左右滑动
function PartnerBtnView:partnerMoveEvent( _type )
    local index = self._selectPartner or 1
    local partnerType = self._selectParterType
    echo("=====############## 当前 滑动  ====== ",_type)
    if _type > 0 then -- 右
        if partnerType == 1 then
            if table.length(self._canCombinePartner) > index then
                local partnerId = self._canCombinePartner[self._selectPartner + 1]
                local dataCfg = FuncPartner.getPartnerById(partnerId)
                self:onTouchCanCombine(dataCfg)
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            elseif table.length(self._canCombinePartner) == index then
                echo("=====@@@@@@@@@@ 当前 滑动  ====== ",_type)
                self:onTouchCharFunc()    
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            end
        elseif partnerType == 2 then
            if table.length(self._allPartners) > 0 then
                self:onTouchCallFunc(1,3)
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            elseif table.length(self._combinePartner) > 0 then
                local partnerId = self._combinePartner[self._selectPartner + 1]
                local dataCfg = FuncPartner.getPartnerById(partnerId)
                self:onTouchCombine(dataCfg)
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            end
        elseif partnerType == 3 then
            if table.length(self._allPartners) > index then
                self:onTouchCallFunc(self._selectPartner+1,3)
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            elseif table.length(self._allPartners) == index then 
                if table.length(self._combinePartner) > 0 then
                    local partnerId = self._combinePartner[1]
                    local dataCfg = FuncPartner.getPartnerById(partnerId)
                    self:onTouchCombine(dataCfg)
                    self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
                end
            end
        elseif partnerType == 4 then
            if table.length(self._combinePartner) > index then
                local partnerId = self._combinePartner[self._selectPartner + 1]
                local dataCfg = FuncPartner.getPartnerById(partnerId)
                self:onTouchCombine(dataCfg)
                if table.length(self._combinePartner) == self._selectPartner then
                    self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
                else
                    self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
                end
            end
        end
    elseif _type < 0 then -- 左
        if partnerType == 1 then
            if index > 1 then
                local partnerId = self._canCombinePartner[self._selectPartner - 1]
                local dataCfg = FuncPartner.getPartnerById(partnerId)
                self:onTouchCanCombine(dataCfg)
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            end
        elseif partnerType == 2 then
            if table.length(self._canCombinePartner) > 0 then
                local partnerId = self._canCombinePartner[table.length(self._canCombinePartner)]
                local dataCfg = FuncPartner.getPartnerById(partnerId)
                self:onTouchCanCombine(dataCfg)
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            end
        elseif partnerType == 3 then
            if index > 1 then
                self:onTouchCallFunc(self._selectPartner-1,3)
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            elseif index == 1 then 
                self:onTouchCharFunc()    
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            end
        elseif partnerType == 4 then
            if index > 1 then
                local partnerId = self._combinePartner[self._selectPartner - 1]
                local dataCfg = FuncPartner.getPartnerById(partnerId)
                self:onTouchCombine(dataCfg)
                self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
            elseif index == 1 then
                if table.length(self._allPartners) > 0 then
                    self:onTouchCallFunc(table.length(self._allPartners),3)
                    self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
                else
                    --todo
                    self:onTouchCharFunc()    
                    self.scrollView:gotoTargetPosForOffset(self._selectPartner,self._selectParterType,1,0,0)
                end
            end
        end
    end
end

-- 判断立绘是否可滑动到下一个
function PartnerBtnView:isPartnerCanMove( _type )
    local index = self._selectPartner or 1
    local partnerType = self._selectParterType
    if _type > 0 then -- 右
        if partnerType == 1 then
            -- if true then -- 未获得的奇侠不可滑动
            --     return false
            -- end
            if table.length(self._canCombinePartner) > index then
                return true
            elseif table.length(self._canCombinePartner) == index then
                return true
            else
                return false
            end
        elseif partnerType == 2 then
            if table.length(self._allPartners) > 0 then
                return true
            elseif table.length(self._combinePartner) > 0 then
                -- if true then -- 未获得的奇侠不可滑动
                --     return false
                -- end
                return true
            else
                return false
            end
        elseif partnerType == 3 then
            if table.length(self._allPartners) > index then
                return true
            elseif table.length(self._combinePartner) > 0  then 
                -- if true then -- 未获得的奇侠不可滑动
                --     return false
                -- end
                return true
            else
                return false
            end
        elseif partnerType == 4 then
            -- if true then -- 未获得的奇侠不可滑动
            --     return false
            -- end
            if table.length(self._combinePartner) > index then
                return true
            else
                return false
            end
        end
    elseif _type < 0 then -- 左
        if partnerType == 1 then
            -- if true then -- 未获得的奇侠不可滑动
            --     return false
            -- end
            if index > 1 then
                return true
            else
                return false
            end
        elseif partnerType == 2 then
            -- if true then -- 未获得的奇侠不可滑动
            --     return false
            -- end
            if table.length(self._canCombinePartner) > 0 then
                return true
            else
                return false
            end
        elseif partnerType == 3 then
            if index > 1 then
                return true
            elseif index == 1 then 
                return true
            else
                return false
            end
        elseif partnerType == 4 then
            -- if true then -- 未获得的奇侠不可滑动
            --     return false
            -- end
            if index > 1 then
                return true
            elseif index == 1 then
                return true
            else
                return false
            end
        end
    end
end

return PartnerBtnView