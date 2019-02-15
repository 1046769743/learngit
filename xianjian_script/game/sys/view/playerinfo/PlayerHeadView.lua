--
--Author:      zhuguangyuan
--DateTime:    2017-07-12 17:06:26
--Description: （更改)主角头像
--

local PlayerHeadView = class("PlayerHeadView", UIBase)

function PlayerHeadView:ctor(winName)
    PlayerHeadView.super.ctor(self, winName)
end

function PlayerHeadView:loadUIComplete()
    self:registClickClose("out") 
    self:registerEvent()
    self:initData()
    self:updateView()
    self.UI_1.mc_1:setVisible(false)
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_head_001")) 
end

function PlayerHeadView:registerEvent()
    self.UI_1.btn_close:setTap(c_func(self.close,self))
end

-----------------------------------------------------------------------
-- 初始化头像/头像框数据
-----------------------------------------------------------------------
function PlayerHeadView:initData()
    --头像数据 
    local hearData = {}
    local avatar = UserModel:avatar();
    local configHeadData = FuncUserHead.getAllConfigUserHead()
    local _index = 1
    for i,v in pairs(configHeadData) do
        local isUnlock = UserHeadModel:isHeadUnLock( v.id )
        echo("___ index,isUnlock ___________",_index,isUnlock)

        if isUnlock then
            local iconName = FuncUserHead.getHeadIcon(v.id)
            local tempData = {
                index = _index,
                icon = FuncRes.iconHero( iconName ),
                _id = v.id
            };
            table.insert(hearData,tempData)

            _index = _index + 1
        end
    end

    -- 头像 按 id 从下到大排序
    function sortHead(a,b)
        if a._id >= b._id then
            return false
        else
            return true
        end
    end
    table.sort(hearData,sortHead)
    
    self.allHeadData = hearData
    dump(self.allHeadData, "玩家拥有的头像数据")

    --头像框数据
    self.allFrameData = {}
    local headFrameData = UserHeadModel:getOwnHeadFrame()
    -- dump(headFrameData, "headFrameData")
    for i,v in pairs(headFrameData) do
        table.insert(self.allFrameData,i)
    end
    local function sortFrame(a,b)
        if tonumber(a) >= tonumber(b) then
            return false
        else
            return true
        end
    end
    table.sort(self.allFrameData,sortFrame)
    dump(self.allFrameData, "玩家拥有的头像框数据")
end

-----------------------------------------------------------------------
-- 玩家选择头像或者头像框
-----------------------------------------------------------------------
function PlayerHeadView:updateView()
    --设置头像所在滚动条的位置
    --
    self.panel_11:visible(false)
    local createFunc = function(data)
        local view = UIBaseDef:cloneOneView(self.panel_11)
        self:updateTotalHeadView(view,data)
        return view
    end
    local headNum = table.length(self.allHeadData)
    local headPanelW = 618
    local headPanelH = math.ceil(headNum/5) * 115 + 20
    local dataHeadParams = {
        data = {1},
        createFunc = createFunc,
        perNums = 1,     
        offsetX = 0,
        offsetY = 10,
        widthGap = 15,
        heightGap = 10,
        itemRect = {x=0,y= -headPanelH,width = headPanelW,height = headPanelH},
        perFrame=1
    }

    --设置头像框所在滚动条的位置
    self.panel_22:visible(false)
    local createFunc1 = function(data)
        local view = UIBaseDef:cloneOneView(self.panel_22)
        self:updateTotalFrameView(view,data)
        return view
    end
    local headFrameNum = table.length(self.allFrameData)
    local headFramePanelW = 618
    local headFramePanelH = math.ceil(headFrameNum/5) * 115 + 30
    local dataHeadFrameParams = {
            data = {2},
            createFunc = createFunc1,
            perNums = 1,     
            offsetX = 0,
            offsetY = 10,
            widthGap = 15,
            heightGap = 10,
            itemRect = {x=0,y= -headFramePanelH,width = headFramePanelW,height = headFramePanelH},
            perFrame=1
        }
    local params1 = {
            dataHeadParams,
            dataHeadFrameParams
        }
    self.scroll_1:styleFill(params1)
end

--更新头像数据
function PlayerHeadView:updateTotalHeadView(view,data)
    local posX = view.panel_1:getPositionX()
    local posY = view.panel_1:getPositionY()

    view.panel_1:visible(false)
    local index = 1;
    for i,v in pairs(self.allHeadData) do
        local itemView = UIBaseDef:cloneOneView(view.panel_1)
        self:updateOneHeadView(itemView,v)

        local xNum = 1
        local yNum = math.floor(index/5)
        if index%5 == 0 then
            xNum = 4
            if yNum > 0 then
                yNum = yNum - 1
            end
        else
            xNum = index%5 - 1
        end
        
        local x = posX + xNum * (103 + 10) + 10
        local y = posY - yNum * (100 + 10) + 10
        itemView:pos( x,y)
        index = index + 1
        view:addChild(itemView)
    end
end
function PlayerHeadView:updateOneHeadView(view,data)
    local iconSprite = display.newSprite(data.icon)
    local artMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
    artMaskSprite:anchor(0.5,0.5)
    local headSprite = FuncCommUI.getMaskCan(artMaskSprite,iconSprite)
    view.ctn_icon:removeAllChildren()
    view.ctn_icon:addChild(headSprite)

    view.panel_1:visible(false)
    --注册点击事件
    view:setTouchedFunc(
        function ()
            if self:isSelectedHead(data._id) then
                WindowControler:showTips(GameConfig.getLanguage("#tid_head_002"))
                self:close()
            else
                local function _callBack( serverData )
                    if serverData.error then
                        WindowControler:showTips(GameConfig.getLanguage("#tid_head_003"))
                    else
                        WindowControler:showTips(GameConfig.getLanguage("#tid_head_002"))
                        EventControler:dispatchEvent(UserEvent.USER_CHANGE_HEAD_EVENT,{userHeadId = data._id})
                    end
                    self:close()
                end
                UserServer:changeUserHead(data._id,_callBack)
            end
        end
    )
end

--更新头像框数据
function PlayerHeadView:updateTotalFrameView(view,data)
    local posX = view.panel_2:getPositionX()
    local posY = view.panel_2:getPositionY()
    view.panel_2:visible(false)
    local index = 1;
    for i,_frameId in pairs(self.allFrameData) do
        local itemView = UIBaseDef:cloneOneView(view.panel_2)
        self:updateOneFrameView(itemView,_frameId)
        local xNum = 1
        local yNum = math.floor(index/5)
        if index%5 == 0 then
            xNum = 4
            if yNum > 0 then
                yNum = yNum - 1
            end
        else
            xNum = index%5 - 1
        end
        
        local x = posX + xNum * (103 + 10) + 10
        local y = posY - yNum * (100 + 10) - 10

        itemView:pos( x,y)
        index = index + 1
        view:addChild(itemView)
    end
end

function PlayerHeadView:updateOneFrameView(view,_frameId)
    local _headFrameId = _frameId 
    local icon = FuncUserHead.getHeadFramIcon(_headFrameId) 
    icon = FuncRes.iconHero(icon)
    local iconSp = display.newSprite(icon)
    view.ctn_tou:removeAllChildren()
    view.ctn_tou:addChild(iconSp)
    view.panel_1:visible(false)
    --注册点击事件
    view:setTouchedFunc(function ()
        if self:isSelectedFrame(_headFrameId) then
            WindowControler:showTips(GameConfig.getLanguage("#tid_head_002"))
            self:close()
        else
            local function callBack( serverData )
                if serverData.error then
                    WindowControler:showTips(GameConfig.getLanguage("#tid_head_003"))
                else
                    WindowControler:showTips(GameConfig.getLanguage("#tid_head_002"))
                    EventControler:dispatchEvent(UserEvent.USER_CHANGE_HEAD_FRAM_EVENT,{headFrameId = _headFrameId})
                end
                self:close()
            end
            if tostring(_headFrameId) == "101" then
                UserServer:changeUserHeadFram(nil,callBack)
            else
                UserServer:changeUserHeadFram(tostring(_headFrameId),callBack)
            end
        end
    end)
end

-- 判断是否是已选中的
function PlayerHeadView:isSelectedHead(id)
    local currentId = UserModel:head()
    if currentId == "" or  not currentId then
        currentId = FuncUserHead.getDefaultIcon()
    end
    
    if tostring(currentId) == tostring(id) then
        return true
    else
        return false
    end
end
function PlayerHeadView:isSelectedFrame(id)
    local currentId = UserModel:frame()
    if currentId == "" or  not currentId then
        currentId = FuncUserHead.getDefaultHeadFrame()
    end
    if currentId == id then
        return true
    else
        return false
    end
end

function PlayerHeadView:close()
    self:startHide()
end

return PlayerHeadView

