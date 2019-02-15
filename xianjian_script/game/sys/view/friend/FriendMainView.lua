-- //好友系统
-- &2016-4-23 
-- refresh Time 20180504
-- author:wk
local FriendMainView = class("FriendMainView", UIBase);
--//_type,1:好友列表,2:添加好友,3:好友申请
function FriendMainView:ctor(_winName,_params,_type,sharedata)
    FriendMainView.super.ctor(self, _winName);

    self._params = _params  ---好友列表数据结构 {friendList,count}
    self.selectType = _type or 1 --叶签选中的状态   默认给 1（好友列表）

    -- dump(_params,"好友列表 ====")
   
end

function FriendMainView:loadUIComplete()
    self:setUIView()
    self:loadkQuestUI();
    self:registerEvent();
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.LeftTop);
   
    self:setBackAndFindButton()
    self:setYeQianButton()
    self:setFriendCount( )

end
-- //注册按钮事件
function FriendMainView:registerEvent()
    FriendMainView.super.registerEvent(self);


    EventControler:addEventListener(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION  ,self.setFriendCount,self)

    EventControler:addEventListener(FriendEvent.FRIEND_FINED_FRIEND ,self.findFriend,self)

    EventControler:addEventListener(FriendEvent.FRIEND_APPLY_REQUEST,self.setButtonRed,self)  --有好友申请的时候

    EventControler:addEventListener(FriendEvent.FRIEND_REMOVE_SOME_PLAYER  ,self.setFriendCount,self)
    -- FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION
    EventControler:addEventListener(FriendEvent.FRIEND_REFRESH_FIREND_COUNT  ,self.setFriendCount,self)
    
end 

function FriendMainView:findFriend(_param)
   local data = _param.params
   self:showUIView(2,false,data)
end

function FriendMainView:setUIView()
    self.uiView = {
        [1] = self.UI_haoyou,
        [2] = self.UI_tuijian,
        [3] = self.UI_app,
    }
    for i=1,#self.uiView do
       self.uiView[i]:setVisible(false)
    end
end


--设置返回按钮
function FriendMainView:setBackAndFindButton()
    self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
    self.btn_3:setTouchedFunc(c_func(self.clickButtonFriend, self),nil,true);
end

function FriendMainView:clickButtonFriend()
     WindowControler:showWindow("FriendFindView")
end

--设置叶签按钮
function FriendMainView:setYeQianButton()
    local selectType = self.selectType

    local yeqian = self.panel_yeqian
    local yeqianNum = 3
    for i=1,yeqianNum do
        local mc_cell = yeqian["mc_"..i]
        mc_cell:showFrame(1)
        mc_cell:getViewByFrame(1).panel_hongdian:setVisible(false)
        mc_cell:setTouchedFunc(c_func(self.showUIView, self,i,true,{}),nil,true);
        if selectType == i then
            mc_cell:showFrame(2)
            self:showUIView(selectType,false,{})
        end
    end
end
--当是点击的时候选中的是自己叶签直接return
function FriendMainView:showUIView(_type,touch,data)

    if touch then
        if _type == self.selectType then
            return
        end
    end
    self.uiView[self.selectType]:setVisible(false)
    local function _cellBack()
        self.uiView[_type]:setVisible(true)
    end
    self.uiView[_type]:initData(_cellBack,data)     --看需求，要不要处理  初始化数据

    local yeqian = self.panel_yeqian
    yeqian["mc_"..self.selectType]:showFrame(1)
    yeqian["mc_".._type]:showFrame(2)
    self:setUITileName(_type)
    self.selectType = _type
    self:setFriendCount()
end

function FriendMainView:setUITileName(_type)
    local name = {
        [1] = "好友",
        [2] = "添加",
        [3] = "接受",

    }
    self.UI_1.txt_1:setString(name[tonumber(_type)])
end

--好友数量
function FriendMainView:setFriendCount( )
    local sumCount = FuncDataSetting.getDataByConstantName("FriendLimit")
    local data = FriendModel:getFriendList()
    local count = table.length(data) ---好友的数量
    self.panel_friends.txt_2:setString(count.."/"..sumCount)
    self:setButtonRed()

end

--设置叶签按钮的红点
function FriendMainView:setButtonRed()
   local panel = self.panel_yeqian
   local red_1 = panel.mc_1:getViewByFrame(1).panel_hongdian  --好友的红点
   local red_3 = panel.mc_3:getViewByFrame(1).panel_hongdian  --申请的红点

   local isRedShow_1 = FriendModel:getFriendIsHaveSp()
   red_1:setVisible(isRedShow_1 or false)

   local isRedShow_3 = FriendModel:isFriendApply()
   red_3:setVisible(isRedShow_3 or false)

   echo("=======isRedShow_1=======",isRedShow_1,isRedShow_3)


end





function FriendMainView:clickButtonBack()
    -- 主城的红点处理

    -- local  isshow = {}
    -- isshow[1] = FriendModel:isFriendApply() 
    -- isshow[2] = FriendModel:getFriendIsHaveSp() or false
    
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, 
        {
            redPointType = HomeModel.REDPOINT.LEFTMARGIN.FRIEND,
            isShow =   FriendModel:isFriendApply() or FriendModel:getFriendIsHaveSp(), --{[1] =isshow[1],[2] = isshow[2]  }, --self:isFriendApply()  or MailModel:checkShowRedForFriend(),
            eventType = FuncCommon.SYSTEM_NAME.FRIEND,-- //需要在标记红点事件上做细分时使用
        }
    );

    -- FriendModel:settianjiarenshu(self.tianjiarenshu)   ---暂时屏蔽设置人数

    self:startHide();
end



return FriendMainView;