--伙伴系统主页面
--2016年12月6日16:15:52
--Author:xiaohuaxiong
local PartnerView = class("PartnerView",UIBase)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local IntervalTime = 10
function PartnerView:ctor(_winName,_CurrentSelect,_selectPartnerId)
    PartnerView.super.ctor(self,_winName);

    if _CurrentSelect and tonumber(_CurrentSelect) == FuncPartner.PartnerIndex.PARTNER_SHENGJI  then 
        _CurrentSelect = FuncPartner.PartnerIndex.PARTNER_QUALILITY
        self.needOpenShengji = true
        _selectPartnerId = PartnerModel:useExpItemOpenId( )
        if not _selectPartnerId then
            self.needOpenShengji = false
            _CurrentSelect = nil
        end
    end
    -- self._currentSelect = tonumber(_CurrentSelect) or PartnerModel:getTopInitIndex() 
    -- self.selectPartnerId = PartnerModel:getInitPartner(self._currentSelect,_selectPartnerId)  

    if (not _selectPartnerId or not _CurrentSelect) then
        self.selectPartnerId = UserModel:avatar() --PartnerModel:getPartnerId( )
        self._currentSelect = FuncPartner.PartnerIndex.PARTNER_QUALILITY  --PartnerModel:getPartnerTypeById( self.selectPartnerId,PartnerModel:getPartnerYeQian() )
    else
        self._currentSelect = tonumber(_CurrentSelect) or PartnerModel:getTopInitIndex() 
        self.selectPartnerId = PartnerModel:getInitPartner(self._currentSelect,_selectPartnerId)  
    end 
    -- 引导要求 
    local ydData = TutorialManager.getInstance():getJumpToNpcInfo()
    dump(ydData,"引导的 类型 和 伙伴ID === ")
    if ydData then    
        self._currentSelect = ydData.index  --引导的类型 (合成或提升) 
        local _id = tostring(ydData.partnerId)
        self.selectPartnerId = _id   --引导的伙伴
        -- PartnerModel:setYDCombinePartnerId(tostring(ydData.partnerId))
        if not FuncPartner.isChar(_id) and not PartnerModel:isHavedPatnner(_id) then
            self._currentSelect = FuncPartner.PartnerIndex.PARTNER_COMBINE
        end
    end

    echo("\n\nself._currentSelect===", self._currentSelect, "self.selectPartnerId===", self.selectPartnerId)
end

function PartnerView:loadUIComplete()
    self:loadkQuestUI(DailyQuestModel:getquestId());
    self.soundTime = 0
    self.lihuiCanMove = true
    --统计MC功能与实际的帧数,以及实际的UI模块的名字
    self._mcFrames={
        [1] = {titleFrame = 1, frame= 4, name ="UI_shengpin", },--升品
        [2] ={ titleFrame = 2, frame= 5, name ="UI_shengxing",} , --升星
        [3] = { titleFrame = 3, frame= 2 ,name ="UI_jineng",}, --技能
        [4] = { titleFrame = 1 ,frame= 8,name  = "UI_1",},  --情报
        [5]= { titleFrame = 4, frame = 3, name= "UI_1",},--装备
        [6] = {titleFrame = 1 ,frame = 7,name = "UI_1",} , --合成UI
        [7] = { titleFrame = 3 ,frame = 8,name = "UI_fabao",}

    }
    self.titleMc = self.mc_icon
    --注意所有的UI都必须实现 updateUIWithPartner( _partner ) 接口,其中_partner为伙伴的详细信息
    self:registerEvent()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.RightTop);--上方的资源条
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)--右上角返回按钮
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_latiaov,UIAlignTypes.MiddleBottom)--左侧伙伴列表
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_icon,UIAlignTypes.LeftTop)--左上角标题
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1,UIAlignTypes.Right)--
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_landi,UIAlignTypes.Right)--
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_landi.scale9_jiugongge,UIAlignTypes.Right,0,1)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_shengji,UIAlignTypes.LeftBottom)
    --设置组件之间的相互引用
    self.UI_latiaov:setPartnerView(self)
    self.UI_latiaov:setSelectPartner( self.selectPartnerId )
    self.UI_latiaov:updateView()
    -- self.UI_latiaov:setCurrentPartner(self.selectPartnerId)
    self.UI_latiaov:gotoSelectPartner( )
    self.UI_1:setPartnerView(self)
    self.UI_1:refreshBtn(self.selectPartnerId)
    --设置第一个选择的UI
    if self._currentSelect == FuncPartner.PartnerIndex.PARTNER_COMBINE then
        if not self.selectPartnerId then 
            self.selectPartnerId,self.selectPartnerType = self.UI_latiaov:getCurrentPartner()
        end
        self.UI_1:refreshBtn(self.selectPartnerId)
        self.UI_1:combineSelect(self.selectPartnerId)

        local data = FuncPartner.getPartnerById(self.selectPartnerId)
        self.UI_latiaov:tiaozhuanChangeUI(data,self.selectPartnerType)

        self.mc_n:showFrame(7)
        self.titleMc:showFrame(1)
        local   _uiModule = self.mc_n.currentView.UI_1
        _uiModule:updateUIWithPartner(data)
        
    else    
        -- 判断 top选中是否解锁 否则 取解锁的index
        if not PartnerModel:isOpenByType(self._currentSelect,self.selectPartnerId) then
            for i = 1,5 do
                if PartnerModel:isOpenByType(i,self.selectPartnerId) then
                    self._currentSelect = i
                    break
                end
            end
        end
        self.UI_1:setCurrentSelect(self._currentSelect)
    end

    self:initMoveNode( )
    -- self:scheduleUpdateWithPriorityLua(c_func(self.playPartnerSound,self), 0)

    -- self:addQuestAndChat()
end


-- --添加聊天和目标按钮
-- function PartnerView:addQuestAndChat()
--     local arrData = {
--         systemView = FuncCommon.SYSTEM_NAME.PARTNER,--系统
--         view = self,---界面
--     }
--     QuestAndChatControler:createInitUI(arrData)
-- end


function PartnerView:registerEvent()
    PartnerView.super.registerEvent(self)
    self.btn_back:setTap(c_func(self.close,self))

--    self.panel_icon:setTouchedFunc(function ()
----        self.UI_latiaov:partnersSortAction()
--        FuncCommUI.regesitShowPartnerTipView(self.panel_icon,{_type = FuncPartner.TIPS_TYPE.STAR_TIPS},nil)
--    end)
    EventControler:addEventListener(PartnerEvent.PARTNER_SHOW_UPGRADE_TYPE_EVENT,self.setShengjiUIState,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_SHOW_UPGRADE_UI_EVENT,self.showShengJiUi,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_START_HIDE_UPGRADE_UI_EVENT,self.hideShengJiUI,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_UPDATE_UPGRADE_UI_EVENT,self.updateShengjiUI,self)

    EventControler:addEventListener(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT,self.pingbiUIClick,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT,self.huifuUIClick,self)
    --顶部红点变化监听
    EventControler:addEventListener(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT,self.refreshTopRedPoint,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_HECHENG_SUCCESS_EVENT,self.refreshTopRedPointHechang,self)
    --立绘是否可滑动监听
    EventControler:addEventListener(PartnerEvent.PARTNER_LIHUI_MOVE_EVENT,self.setLihuiMove,self)
    -- 奇侠评论消息
    EventControler:addEventListener(PartnerEvent.PARTNER_SHOW_PINGLUN_UI_EVENT,self.showPinglunUI,self)

end
--切换UI,注意这个函数主要是作为一个回调函数使用
--_uiIndex:功能的索引值(索引的顺序就是按钮从左到右的顺序),至于如何寻址,取决于模块的内部接口,
--注意这里虽然传入了伙伴的信息,但是具体的刷新与否,取决于UI自己的实现
function PartnerView:changeUIWith( _uiIndex,_partnerInfo)
    -- self.UI_1:visible(true)
    self.UI_1:notCombineSelect()
    -- self.panel_landi:visible(true)

    -- 这里判断是否是主角 并且是否是技能
    -- if FuncPartner.isChar(_partnerInfo.id) and _uiIndex == 3 then
    --     _uiIndex = 7
    -- end
    
    self.selectPartnerId = _partnerInfo.id
    local   _mcFrame = self._mcFrames[_uiIndex]
    self.mc_n:showFrame(_mcFrame.frame)
    self.titleMc:showFrame(_mcFrame.titleFrame)

    local   _uiModule = self.mc_n.currentView[_mcFrame.name]
    if FuncPartner.isChar(_partnerInfo.id) then 
        _partnerInfo = CharModel:getCharData()
    end
    _uiModule:updateUIWithPartner(_partnerInfo)
    if self.needOpenShengji then
        -- 只会在创建的时候有可能是true
        self.needOpenShengji = false
        _uiModule:openLevelUI()
    end
    self._partnerInfo = _partnerInfo
    self:refreshTopRedPoint()
    if _uiIndex == 4 then
        self.lihuiCanMove = false
    else
        self.lihuiCanMove = true
    end
    
    self:partnerSound( _uiIndex,_partnerInfo.id )
end
function PartnerView:changeUIWithIndexAndId( _uiIndex,_partnerId)
    local _partnerInfo = PartnerModel:getPartnerDataById(_partnerId)
    if _partnerInfo then 
        local _param = {}
        _param.params = _partnerId
        self.UI_latiaov:changTiShengUI(_param)
        self.UI_1:setCurrentSelect(_uiIndex)
    else
        echoError(_partnerId.."还未拥有")
    end
end

-- 奇侠音效需求
function PartnerView:partnerSound( _uiIndex,id )
    if self.partnerSoundID and _uiIndex == 1 then
        AudioModel:stopSound(self.partnerSoundID)
        self.partnerSoundID = nil
        self.soundPartnerId = nil
    end
    
    if _uiIndex == 1 then
        self:playPartnerSound(_uiIndex,id )
        self.soundPartnerId = id
        self.soundTime = (IntervalTime-1) * GameVars.GAMEFRAMERATE
    end
end
-- 播放音效
function PartnerView:playPartnerSound(_uiIndex,partnerId )
    if self.soundTime == IntervalTime * GameVars.GAMEFRAMERATE or true then
        local topIndex = _uiIndex
        if self and self.UI_1 and topIndex == 1 and 
            (PartnerModel:isHavedPatnner(partnerId) or tostring(partnerId) == tostring(UserModel:avatar())) then
            self:delayCall(function ()
                local windName = WindowControler:getCurrentWindowView()
                if windName.__cname  == "PartnerView" then 
                    local _soundName = FuncPartner.getPartnerSound(partnerId)
                    if _soundName then
                        if self.partnerSoundID then
                            AudioModel:stopSound(self.partnerSoundID)
                        end
                        
                        self.partnerSoundID = AudioModel:playSound(_soundName)
                    end
                    
                    self.soundTime = 0
                end
            end,0.1)
            
        end
    else
        self.soundTime = self.soundTime + 1
    end
end

function PartnerView:changeCombineUIWith( _partnerInfo)
    self.UI_1:combineSelect(_partnerInfo.id)

    local  _topViewIndex=self.UI_1:getCurrentSelectButtonIndex()
    local _uiModule = nil
    if _topViewIndex == 4 then
        self.mc_n:showFrame(self._mcFrames[4].frame)
        _uiModule = self.mc_n.currentView.UI_1
    elseif _topViewIndex == 3 then
        self.mc_n:showFrame(self._mcFrames[3].frame)
        _uiModule = self.mc_n.currentView.UI_jineng
    else
        self.mc_n:showFrame(7)
        self.titleMc:showFrame(1)
        _uiModule = self.mc_n.currentView.UI_1
    end

    self.selectPartnerId = _partnerInfo.id
    if FuncPartner.isChar(_partnerInfo.id) then 
        _partnerInfo = CharModel:getCharData()
    end
    _uiModule:updateUIWithPartner(_partnerInfo)
    self.lihuiCanMove = true
end

--对上一个函数的封装,这个函数会在PartnerBtnView中被调用
function PartnerView:changeUIInTopView( _topUIIndex)
    local  _partnerInfo = self.UI_latiaov:getCurrentPartner()
    if type(_partnerInfo) ~= "table" then
        _partnerInfo = PartnerModel:getPartnerDataById(_partnerInfo)
    end
    --主角数据要去charmodel中获取
    if FuncPartner.isChar(_partnerInfo.id) then
        _partnerInfo = CharModel:getCharData()
    end
    self:changeUIWith(_topUIIndex,_partnerInfo)
end 
--在PartnerbtnView中被调用
function PartnerView:changeUIInBtnView( _partnerInfo)
    local  _topViewIndex=self.UI_1:getCurrentSelectButtonIndex()
    if _topViewIndex < 1 then
        _topViewIndex = PartnerModel:getTopIndex()
    end
    -- 判断主角技能是否开启 -- 判断主角升星是否开启
    if FuncPartner.isChar(_partnerInfo.id) then
        _partnerInfo = PartnerModel:getPartnerDataById(_partnerInfo.id)
        if _topViewIndex == 3 then
            if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_NEW) then
                _topViewIndex = 1
                self.UI_1:setCurrentSelect( _topViewIndex,false)
            end
        elseif _topViewIndex == 2 then
            if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHARSTAR) then
                _topViewIndex = 1
                self.UI_1:setCurrentSelect( _topViewIndex,false)
            end
        end
    else
        if _topViewIndex == 3 then 
            if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL) then
                _topViewIndex = 1
                self.UI_1:setCurrentSelect( _topViewIndex,false)
            end
        elseif _topViewIndex == 2 then
            if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SHENGXING) then
                _topViewIndex = 1
                self.UI_1:setCurrentSelect( _topViewIndex,false)
            end
        end
        
    end
    self:changeUIWith(_topViewIndex,_partnerInfo)
    self.UI_1:refreshBtn(self.selectPartnerId)
    self.UI_1:refreshSelectState(_topViewIndex)
    self.UI_1:refreshRedPoint(self.selectPartnerId)
end
function PartnerView:close()
    EventControler:dispatchEvent(PartnerEvent.PARTNER_VIEW_CLOSE_EVENT)
    DailyQuestModel:setquestId(nil)
    PartnerModel:setPartnerId(self.selectPartnerId)
    PartnerModel:setPartnerYeQian(self.UI_1:getCurrentSelectButtonIndex())
    self:startHide()

    -- self:changeUIWithIndexAndId( 2,"5001")
end

-- 刷新顶部红点提示
function PartnerView:refreshTopRedPoint()
    if self._partnerInfo then
        self.UI_1:refreshRedPoint(self._partnerInfo.id)
    end
end
function PartnerView:refreshTopRedPointHechang(_param)
    local _id = _param.params
    self.UI_1:refreshRedPoint(_id)
end

--当退出战斗时 需要缓存的数据 以便 恢复这个ui时 记录数据
function PartnerView:getEnterBattleCacheData()
    local retTable = {};
    retTable.topSelectIndex = self.UI_1:getCurrentSelectButtonIndex();
    retTable._partnerInfo, retTable.liebiaoSelectIndex = self.UI_latiaov:getCurrentPartner()
    -- dump(retTable, "\n\nretTable======")
    return retTable;
end

-- 当UI存在时 外部跳转 调用这个
function PartnerView:gotoPartner( _topViewIndex,_partnerId )
    -- body
    self._currentSelect = _topViewIndex 
    self.selectPartnerId = _partnerId   
    echo("_partnerId ==== ",_partnerId)
    if not FuncPartner.isChar(_partnerId) and not PartnerModel:isHavedPatnner(_partnerId) then
        self._currentSelect = FuncPartner.PartnerIndex.PARTNER_COMBINE
    end
    if self._currentSelect ~= FuncPartner.PartnerIndex.PARTNER_COMBINE then
        self.UI_1:setPartnerView(self)
        self.UI_latiaov:setPartnerView(self)
        self.UI_latiaov:setCurrentPartner(self.selectPartnerId)
        -- self.UI_latiaov:updateView()
        local data = PartnerModel:getPartnerDataById(self.selectPartnerId)
        self:changeUIWith(self._currentSelect,data)
        self.UI_1:setCurrentSelect( self._currentSelect,false)
    else
        self.UI_1:combineSelect(self.selectPartnerId)  
        local data = FuncPartner.getPartnerById(self.selectPartnerId)
        self.UI_latiaov:tiaozhuanChangeUI(data,self.selectPartnerType)

        self.mc_n:showFrame(7)
        self.titleMc:showFrame(1)
        local _uiModule = self.mc_n.currentView.UI_1    
        _uiModule:updateUIWithPartner(data)
        self.UI_1:setCurrentSelect(1)
    end

end

--当退出战斗后 恢复这个ui时 ,会把这个cacheData传递给ui
function PartnerView:onBattleExitResume(cacheData)
    echo("==============chuzhandou伙伴============")

    -- dump(cacheData, "\n\ncacheData======")
    local _topViewIndex = cacheData.topSelectIndex
    local _partnerInfo = cacheData._partnerInfo
    if type(_partnerInfo) ~= "table" then
        _partnerInfo = {id = cacheData._partnerInfo}
    end
    local _liebiaoSelectIndex = cacheData.liebiaoSelectIndex
   -- self.UI_latiaov:changePartnerXuanzhongkuang(_liebiaoSelectIndex)
    local refreshUI = function ( ... )
        self.selectPartnerId = _partnerInfo.id
        self.UI_1:setPartnerView(self)
        self.UI_latiaov:setPartnerView(self)      
        self.UI_latiaov:updateView()

        if _topViewIndex <= 0 then
            _topViewIndex = 1
        end

        self.UI_1:refreshSelectState(_topViewIndex)
        if not FuncPartner.isChar(self.selectPartnerId) and not PartnerModel:isHavedPatnner(self.selectPartnerId) then
            local data = FuncPartner.getPartnerById(_partnerInfo.id)
            self.UI_latiaov:tiaozhuanChangeUI(data)
            _partnerInfo = FuncPartner.getPartnerById(_partnerInfo.id)
            self:changeCombineUIWith(_partnerInfo)
        else
            self.UI_latiaov:setCurrentPartner(_partnerInfo.id)
            self:changeUIWith(_topViewIndex, _partnerInfo) 
        end
    end
    self:delayCall(refreshUI, 0.1)
end
function PartnerView:onBecomeTopView()
    local ydData = TutorialManager.getInstance():getJumpToNpcInfo()
    dump(ydData,"onBecomeTopView 引导的类型和伙伴ID=== ")
    if ydData then
        self._currentSelect = ydData.index  --引导的类型 (合成或提升) 
        local _id = tostring(ydData.partnerId)
        self.selectPartnerId = _id   
        local refreshUI = function ( ... )
            if self._currentSelect ~= FuncPartner.PartnerIndex.PARTNER_COMBINE then
                self.UI_1:setPartnerView(self)
                self.UI_latiaov:setPartnerView(self)
                self.UI_latiaov:setCurrentPartner(self.selectPartnerId)
                self.UI_latiaov:updateView()
                local data = PartnerModel:getPartnerDataById(self.selectPartnerId)
                self:changeUIWith(self._currentSelect,data)
                self.UI_1:setCurrentSelect( self._currentSelect,false)
            else
                self.UI_1:combineSelect(self.selectPartnerId)  
                local data = FuncPartner.getPartnerById(self.selectPartnerId)
                self.UI_latiaov:tiaozhuanChangeUI(data,self.selectPartnerType)

                self.mc_n:showFrame(7)
                self.titleMc:showFrame(1)
                local   _uiModule = self.mc_n.currentView.UI_1
                if FuncPartner.isChar(data.id) then 
                    echoError("配置错误，引导主角合成")
                    return
                end
                _uiModule:updateUIWithPartner(data)
            end

            
        end
        self:delayCall(refreshUI, 0.1)
    end
end
--屏蔽点击事件
function PartnerView:pingbiUIClick(event)
    local isPingbi = TutorialManager.getInstance():isInTutorial() 
        or not TutorialManager.getInstance():isFinishForceGuide()
    echo("-------------此时屏蔽--------- 引导的值 == ",isPingbi)
    if isPingbi or event.params == 3 or event.params == 1 then
        echo("-----------------此时屏蔽 点击事件----1111-------------")
        self.canNotClick = true
        self:disabledUIClick()
    end
    
end
-- 恢复点击事件 
function PartnerView:huifuUIClick()
    echo("-----------------此时恢复恢复 点击事件----222222-------------")
    self:resumeUIClick()
    self.canNotClick = false
end

-- 奇侠评论相关
function PartnerView:setPinglunUIState( )
    self.pinglunUIShow = true
end
function PartnerView:showPinglunUI( )

    local arrayData = {
         systemName = FuncCommon.SYSTEM_NAME.PARTNER,
         diifID = self.selectPartnerId,  
         _type = "" 
    }
    if not self.pinglunUI then
        self.pinglunUI = WindowControler:createWindowNode("CommentsMainView")
        if self.pinglunUI then
            
            local nd = FuncRes.a_white( 850 ,520)
            self.ctn_taolun:addChild(nd)
            nd:pos(70,-30)
            nd:zorder(10)
            nd:opacity(0)
            nd:setTouchedFunc(GameVars.emptyFunc,nil,true,nil,nil,false)

            local pingbiNode = FuncRes.a_white( 2*GameVars.width,2*GameVars.height)
            pingbiNode:opacity(0)
            self.ctn_taolun:addChild(pingbiNode)
            pingbiNode:setTouchedFunc(c_func(self.hidePingLunUI,self),nil,true,nil,nil,false)
            pingbiNode:zorder(1)

            self.pinglunUI:getServerData(arrayData)
            self.ctn_taolun:addChild(self.pinglunUI)
            self.pinglunUI:pos(-450+GameVars.sceneOffsetX,280)
            self.pinglunUI:zorder(11)
        end
    else
        self.pinglunUI:getServerData(arrayData)
    end
    
    self:setPinglunUIState()

    
    self.ctn_taolun:visible(true)
end
function PartnerView:updatePingLunUI( )
    if not self.pinglunUIShow then
        return
    end
    local arrayData = {
         systemName = FuncCommon.SYSTEM_NAME.PARTNER,
         diifID = self.selectPartnerId,  
         _type = "" 
    }
    local callfunc = function (  )
        if self.pinglunUI then
            self.pinglunUI:initData(arrayData)
        end
    end
    RankAndcommentsControler:getRankAndCommentAllData(arrayData,callfunc)
end
function PartnerView:hidePingLunUI( )
    self.pinglunUIShow = false

    self.ctn_taolun:visible(false)
end

-- 升级相关
function PartnerView:setShengjiUIState()
    self.shengjiUIShow = true 
end
-- 弹出升级UI
function PartnerView:showShengJiUi()
    self.UI_shengji:setPositionX(0)
    self:updateShengjiUI()
    self:disabledUIClick()
    -- echo("pingmukuan-============ ",GameVars.UIOffsetX + self.widthScreenOffset/2)
    local posY = 0
    local moveAnim = act.moveto(0.3,0,0)
    local animCallBack = function()
        if self.shengjiNode then
            self.shengjiNode:visible(true)
            self.youNode:visible(true)
            self.youNode2:visible(true)
            self.zuoNode:visible(true)
        else  
            echo("GameVars.height == ",GameVars.height)
            local height = GameVars.height - 300
            local node = FuncRes.a_white( GameVars.width - 120,height)
            self.shengjiNode = node
            node:anchor(0,1)
            node:pos(0,0)
            node:opacity(0)
            FuncCommUI.setViewAlign(self.widthScreenOffset,node,UIAlignTypes.LeftTop)
            self:addChild(node)
            node:setTouchedFunc(c_func(self.hideShengJiUI,self),nil,true,nil,nil,false) 
            local zuoNode = FuncRes.a_white(120 + GameVars.UIOffsetX + self.widthScreenOffset/2,200)
            self.zuoNode = zuoNode
            zuoNode:anchor(0,1)
            zuoNode:pos(0,-height)
            zuoNode:opacity(0)
            FuncCommUI.setViewAlign(self.widthScreenOffset,zuoNode,UIAlignTypes.LeftTop)
            self:addChild(zuoNode)
            zuoNode:setTouchedFunc(c_func(self.hideShengJiUI,self),nil,true,nil,nil,false)
            local youNode = FuncRes.a_white(230+GameVars.UIOffsetX + self.widthScreenOffset/2, 480 + GameVars.UIOffsetY * 2)
            self.youNode = youNode
            youNode:anchor(1,1)
            youNode:pos(GameVars.width, -50)
            youNode:opacity(0)
            FuncCommUI.setViewAlign(self.widthScreenOffset,youNode,UIAlignTypes.LeftTop)
            self:addChild(youNode)
            youNode:setTouchedFunc(c_func(self.hideShengJiUI,self),nil,true,nil,nil,false)
            local youNode2 = FuncRes.a_white(140+GameVars.UIOffsetX + self.widthScreenOffset/2, 300)
            self.youNode2 = youNode2
            youNode2:anchor(1,1)
            youNode2:pos(GameVars.width,-height)
            youNode2:opacity(0)
            FuncCommUI.setViewAlign(self.widthScreenOffset,youNode,UIAlignTypes.LeftTop)
            self:addChild(youNode2)
            youNode2:setTouchedFunc(c_func(self.hideShengJiUI,self),nil,true,nil,nil,false)
        end
        self:resumeUIClick()
    end
    self.UI_shengji:runAction(act.sequence(moveAnim, act.callfunc(animCallBack)))
    self.UI_shengji.panel_1:setTouchEnabled(true)
    self.UI_shengji.panel_1:setTouchSwallowEnabled(true)

end
-- 刷新升级UI
function PartnerView:updateShengjiUI()
    if not self.shengjiUIShow then
        return 
    end
    local data = PartnerModel:getPartnerDataById(tostring(self.selectPartnerId))
    self.UI_shengji:updataUI(data)
end

-- 隐藏升级UI
function PartnerView:hideShengJiUI()
    if self.canNotClick then
        return
    end
    
    self.shengjiUIShow = false 
    if self.shengjiNode then
        self:disabledUIClick()
        self.shengjiNode:visible(false)
        self.youNode:visible(false)
        self.youNode2:visible(false)
        self.zuoNode:visible(false)
        local posY = -355
        local moveAnim = act.moveto(0.3,0,posY)
        local animCallBack = function()
            self:resumeUIClick()
            echo("huidiao -------------")
            EventControler:dispatchEvent(PartnerEvent.PARTNER_HIDE_UPGRADE_UI_EVENT )
        end
        self.UI_shengji:runAction(act.sequence(moveAnim, act.callfunc(animCallBack)))
    end
end

-- 添加滑动逻辑
function PartnerView:initMoveNode( )
    local moveNode = FuncRes.a_white( 170*4,36*9.5)
    moveNode:setPosition(cc.p(0,0))
    self.ctn_move:addChild(moveNode,10)
    moveNode:setTouchEnabled(true)
    self.moveNode = moveNode

    moveNode:opacity(0)
    moveNode:setTouchedFunc(c_func(self.moveNodeTouchEnd, self), nil, nil,
     c_func(self.moveNodeTouchStart, self),
     c_func(self.moveNodeTouchMove, self),
     nil,
     c_func(self.moveNodeTouchEnd, self)  )
end
function PartnerView:moveNodeTouchEnd(event)
    if not self.lihuiCanMove then 
        return
    end 
    local isPingbi = TutorialManager.getInstance():isInTutorial() 
        or not TutorialManager.getInstance():isFinishForceGuide()
    if isPingbi then return end
    -- dump(event, "moveend -----------", 3)
    

    local moveEndX = event.x
    local moveEndY = event.y

    local dis = 100
    local _tiem = 0.27
    local partnerType = self.UI_latiaov:getCurrentPartnerType()
    local partnerId = self.UI_latiaov:getCurrentPartner()
    local params = {}
    if moveEndX - self.starMoveX > dis then
        -- 立绘向右滑动
        if self.UI_latiaov:isPartnerCanMove( -1 ) then
            params = {_type = -1 ,partnerTy = partnerType}
            EventControler:dispatchEvent("lihui_yidong_end",params )
                self:delayCall(function()
                self.UI_latiaov:partnerMoveEvent( -1 )
            end, _tiem)
        else
            self.moveNode:setTouchEnabled(false)
            params = {_type = 0 ,partnerTy = partnerType}
            EventControler:dispatchEvent("lihui_yidong_end",params )
            self:delayCall(function()
                self.moveNode:setTouchEnabled(true)
            end, _tiem)
        end
    elseif moveEndX - self.starMoveX < -dis then
        -- 立绘向左++滑动
        if self.UI_latiaov:isPartnerCanMove( 1 ) then
            params = {_type = 1 ,partnerTy = partnerType}
            EventControler:dispatchEvent("lihui_yidong_end",params )
            self:delayCall(function()
                self.UI_latiaov:partnerMoveEvent( 1 )
            end, _tiem)
        else
            params = {_type = 0 ,partnerTy = partnerType}
            EventControler:dispatchEvent("lihui_yidong_end",params )
            self.moveNode:setTouchEnabled(false)
            self:delayCall(function()
                self.moveNode:setTouchEnabled(true)
            end, _tiem)
            
        end
        
    else
        params = {_type = 0 ,partnerTy = partnerType}
        EventControler:dispatchEvent("lihui_yidong_end",params )
    end
end
function PartnerView:moveNodeTouchStart(event)
    -- dump(event, "moveStar -----------", 3)
    self.starMoveX = event.x
    self.starMoveY = event.y

end
function PartnerView:moveNodeTouchMove(event)
    if not self.lihuiCanMove then 
        return
    end 
    local isPingbi = TutorialManager.getInstance():isInTutorial() 
        or not TutorialManager.getInstance():isFinishForceGuide()
    if isPingbi then return end
    -- dump(event, "movemove -----------", 3)
    local partnerType = self.UI_latiaov:getCurrentPartnerType()
    local _dis = event.x - self.starMoveX
    if event.x - self.starMoveX > 150 then
        _dis = 150
    elseif event.x - self.starMoveX < -150 then
        _dis = -150
    end
    local data = {dis = _dis,partnerTy = partnerType}
    EventControler:dispatchEvent("lihui_yidong",data )
end

-- 设置立绘是否可以滑动
function PartnerView:setLihuiMove( event )
    self.lihuiCanMove = event.params
end

function PartnerView:deleteMe()
    PartnerView.super.deleteMe(self)
    if self.partnerSoundID then
        AudioModel:stopSound(self.partnerSoundID)
        self.partnerSoundID = nil
        self.soundPartnerId = nil
    end
end

return PartnerView