-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ChatMainView = class("ChatMainView", UIBase)
--可以用来扩展表情
-- local numerToFrameMap = {
--     ["@:/101"] = "@101",
--     ["@:/102"] = "@101",
--     ["@:/103"] = "@101",
--     ["@:/104"] = "@101",
--     ["@:/105"] = "@101",
--     ["@:/106"] = "@101",
--     ["@:/107"] = "@101",
--     ["@:/108"] = "@101",
--     ["@:/109"] = "@101",
--     ["@:/110"] = "@101", 
-- }
local  ChatType={
        ChatType_System = 1,
        ChatType_World=2,
        ChatType_League=3,
        ChatType_Team = 4,
        ChatType_Private=5,
        ChatType_Love=6,
};
local cdTime = FuncChat.getWorldTime()

-- MethodCode.chat_Get_inf_2801 = 2801 ---读取设置
-- MethodCode.chat_Set_inf_2801 = 2803 ---设置上传
--//_type,1:世界聊天,2:仙盟聊天,3:私聊  zitype --私聊子类型  --511 表示私聊的第几个聊天界面
function ChatMainView:ctor(winName, _type,zitype,params_id)
    ChatMainView.super.ctor(self, winName)
--//当前选中的聊天按钮,默认为世界聊天
    self.chatType=ChatModel:getSelectType()
    self.chatWorldContent=nil;--//世界聊天内容
--//联盟聊天
    self.chatLeagueContent=nil;
    self.currentPrivateSelect=1;--//私聊对象的索引
--//聊天内容
    self.reserveMessage="";
--//聊天对象,在私聊系统中使用,如果不为nil,表明发送聊天时的对象是别人
    self.targetObject=nil;
    ---
    self.todochatview = false
    self.Leafsign_index = 1 ----点击第几个的业签
    self.fistplayVoice = 1  ---第一个播放
    self.voicetable = {}
    self.countdown = 1 --语音倒计时

--显示的那个界面
    self.selectview = nil
    self.chatzitype = zitype
    self.params_id = params_id
    self.ui_type= _type or ChatModel:getSelectType()

    if not ChatModel.issendFriend then
        --获得好友详情
        ChatModel:getfriendData()
        ChatModel:setissendFriend(true)
    end


end
function ChatMainView:openChat()
    self:setVisible(true)
end

function ChatMainView:loadUIComplete()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self._root,UIAlignTypes.LeftBottom);
    self.panel_name:setTouchedFunc(c_func(self.touchremoveAllChildren,self),nil,true);
    -- self:setTouchedFunc(c_func(self.touchremoveAllChildren,self),nil,true);
    self.mc_5:setVisible(false)
    self.btn_shizhi:setTap(c_func(self.ToDosetView,self));
    FriendModel:SendServergetFriendList()
    self:setUIShow()
    self:setButtonTouchEvent()
    self:getAllTemporaryAndThereData()
    self:registerEvent()
    self:setinputText()  ---处理输入问题

    self:setVoiceSdkHelper() 

    if self.ui_type ~= 4 then  ---删除队伍数据
        ChatModel:settematype(nil)
        ChatModel:setChatTeamData(nil) ---传"玩家数据"
    end
	local isaddGuild = GuildModel:isInGuild()
    if not isaddGuild then
        if self.ui_type == 3 then
            self.ui_type = 2
        end
    end



	self:delayCall(handler(self, self.initData),0.2)
end
function ChatMainView:initData()  
    self.mc_5:setVisible(true)
    if(self.ui_type==1)then   --系统
        self:panduanFiveButtonRed()
        self:clickButtonSystem()
    elseif(self.ui_type==2)then   ---世界
        self:panduanFiveButtonRed()
        self:clickButtonWorld()
    elseif(self.ui_type==3)then   ---仙盟
        self:panduanFiveButtonRed()
        self:clickButtonLeague()
    elseif(self.ui_type==4)then   ---队伍
        self:panduanFiveButtonRed()
        self:clickButtonTeam()
    elseif(self.ui_type==5)then   ---私聊
        self:clickButtonPrivate(self.chatzitype )
    elseif(self.ui_type==6)then   ---情缘按钮
        -- local isopen = OptionsModel:getOneOption(101)
        -- if isopen ~= "0" then
        --     self:panduanFiveButtonRed()
        --     self:clickButtonlovePartner()
        -- else
        --     self:panduanFiveButtonRed()
        -- end
    end
    -- local isopen = OptionsModel:getOneOption(101)
    -- if isopen ~= "0" then
    --     self.mc_7:setVisible(true)
    -- else
    --     self.mc_7:setVisible(false)
    -- end


    self:BiaoqianIndex(self.ui_type)
    if self.params_id ~= nil then
        self:showChatViewList()
    end

    -- if device.platform ~= "windows" or device.platform ~="mac" then
    --     self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0) 
    -- end
    
end
function ChatMainView:updateFrame()
    -- 必须每帧调用
    -- VoiceSdkHelper:update()

    -- self:addautorun()   ---暂时没用

end
 --自动播放语音
function ChatMainView:addautorun()

    local _index = self.Leafsign_index + 3   --差值
    local voicename = ChatModel.setchatsetlistindex[_index]
    local valuer = ChatModel.setchatVoicelist[voicename]
    if valuer == 0 then
        return 
    end

    if #self.voicetable == 0 then
        return 
    end
    if self.fistplayVoice == 1 then
        local data = self.voicetable[self.fistplayVoice]

    end
    self.countdown = self.countdown + 1
end

function ChatMainView:setVoiceSdkHelper()
    if device.platform == "windows" or device.platform =="mac" then
        return
    end
    VoiceSdkHelper:setVoiceWork(true)

    --初始化语音SDk
    --- 初次进界面加载，下次进入不需要加载
    -- if not ChatModel.voiceInitSdk  then  
    --     ChatShareControler:iniData()
    --     ChatModel:setinitSdk(true)
    -- end
end


function ChatMainView:touchremoveAllChildren()
    self.ctn_press:removeAllChildren()
    self.FriendEmailview = nil
end
---设置界面
function ChatMainView:ToDosetView()
    self:touchremoveAllChildren()    
    WindowControler:showWindow("ChatSetview")
     -- WindowControler:showTips(GameConfig.getLanguage("chat_function_not_open_1015"));
end

function ChatMainView:showChatViewList()
    local item = nil
    self:getAllTemporaryAndThereData()
    if self.chatzitype == 1 then
        -- self.temporaryfriend   self.params_id
        for k,v in pairs(self.temporaryfriend ) do
            if v.rid == self.params_id then
                item = v
            end
        end
        if item then
            self:ShowPrivateChatView(item,1)
        end
    else
         for k,v in pairs(self.ThereFriend ) do
            if v.rid == self.params_id then
                item = v 
            end
        end
        if item then
            self:ShowPrivateChatView(item,2)
        end
    end
    

end




function ChatMainView:panduanFiveButtonRed(index)
    if index ~= 5 then
        local friend,notfriend = ChatModel:panduanfriengListRed()
        -- echo("======friend======notfriend==========",friend,notfriend)
        if friend == true  then
            self.mc_5:getViewByFrame(1).panel_red:setVisible(friend)
        end
        if notfriend == true then
            self.mc_5:getViewByFrame(1).panel_red:setVisible(notfriend)
        end
        self.mc_5:getViewByFrame(1).panel_red:setVisible(ChatModel:getPrivateDataRed())
    end
end
function ChatMainView:BiaoqianIndex(index)
    for i=1,6 do
        if i == index then
            if i == 6 then
                i = 7
            end
            self["mc_"..i]:showFrame(2)
        else
            if i == 6 then
                i = 7
            end
            self["mc_"..i]:showFrame(1) 
        end
    end
end

function ChatMainView:setUIShow()
    self.mc_scroll:setVisible(false)
    self.mc_6:setVisible(false)
    -- self.panel_biaoqing:setVisible(false)
    self.panel_tishi:setVisible(false)
    self.panel_sl:setVisible(false)
    self.mc_btn:setVisible(false)
    self.UI_spake:setVisible(false)
    -- self.mc_talk:setVisible(false)   ---测试
    self.UI_talk1:setVisible(false)
    -- self.panel_copy2:setVisible(false)
    self.mc_6:getViewByFrame(3).panel_red:setVisible(false)
    self.mc_6:getViewByFrame(3).panel_red2:setVisible(false)
    -- self.mc_6:getViewByFrame(3).panel_red3:setVisible(false)
    self.mc_5:getViewByFrame(1).panel_red:setVisible(false)
    -- self.mc_7:getViewByFrame(1).panel_red:setVisible(false)
end



function ChatMainView:showComplete( )
    ChatMainView.super.showComplete(self);
    -- self.mc_5:setVisible(false)
  --//加入弹出动画
    local  _rect=self._root:getContainerBox();
    local  _otherx,_othery=self._root:getPosition();

    self._root:setPosition(cc.p(_otherx - _rect.width,_othery));
--    self:setPosition(cc.p(-_rect.width+_otherx,0));
    local  _mAction=cc.MoveTo:create(0.2,cc.p(_otherx,_othery));
    self._root:runAction(_mAction);
end
function ChatMainView:setButtonTouchEvent()
    self.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonSystem,self));   ---系统
    self.mc_2.currentView.btn_1:setTap(c_func(self.clickButtonWorld,self));   ---世界
    self.mc_3.currentView.btn_1:setTap(c_func(self.clickButtonLeague,self));  ---仙盟
    self.mc_4.currentView.btn_1:setTap(c_func(self.clickButtonTeam,self));     --队伍
    self.mc_5.currentView.btn_1:setTap(c_func(self.clickButtonPrivate,self));   --私聊
    self.mc_7.currentView.btn_1:setTap(c_func(self.clickButtonlovePartner,self));   --缘伴
    self.mc_7:setVisible(false)
    -- self.mc_5:setVisible(true)
    self.mc_4:getViewByFrame(1).panel_red:setVisible(false)
    self.mc_5:getViewByFrame(1).panel_red:setVisible(false)
    
    self.btn_close:setTap(c_func(self.closeChat,self));
 --//加入弹出动画
    local function _closeCallback()
            -- self:Savedatalocal()
            
            -- ChatModel:Savedatalocal()
            ChatModel:setPrivateTargetPlayer(nil);
            self:removeUI();
    end
    local  function _callback()
       local  _root=self._root;
       local  _rect=_root:getContainerBox();
       local  _mAction=cc.MoveBy:create(0.2,cc.p(-_rect.width,0));
       local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(_closeCallback));
       _root:runAction(_mSeq);
    end
    self:registClickClose("out",_callback);
end

--缘伴数据
function ChatMainView:clickButtonlovePartner()
    -- TODO删除缘伴系统
    if true then
        return
    end

    self.targetPlayer = nil

    ChatServer:stopPlayFile()
    self:touchremoveAllChildren()

    self:setUIShow()

    ChatModel:setSelectType(6)
    self:panduanFiveButtonRed(6)
    self:BiaoqianIndex(6) ---标签显示问题
    self.mc_6:setVisible(true)
    self.mc_6:showFrame(1)
    self.Leafsign_index = 6
    self.mc_scroll:setVisible(false)
    self.mc_scroll:showFrame(1)

    

    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.SendinputTextButton,self))
    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.SendinputTextButton,self))   
    -- self:showLoveData()
    

end


function ChatMainView:showLoveData()
    ChatModel:automaticallyPlayVoice(self.Leafsign_index)
    ChatModel:removeLoveMessage()
    local data = ChatModel:getLoveMessage()
    local  function genPrivateObject(_table)   
        local  _cell= UIBaseDef:cloneOneView(self.UI_talk1);
        self:currencyTextModel(_cell,_table);
        return _cell;
    end

    local  function updateCellFunc(_table,_cell)   
        self:currencyTextModel(_cell,_table);
    end
    
    local params = {}
    local sumindex = 0
    -- dump(data,"0000000000000000000000000000")
    if  #data ~= 0 then
        for i=1,#data do
           -- local width,height = FuncChat.getStrWandH(data[i].content)
           --  local newheight = 55 + height
           --  local ynewheight = -55-height
           --  if data[i].voice then
           --      newheight = height + 65
           --      ynewheight = -(68 + height)
           --  end

           --  if data[i].type == FuncChat.EventEx_Type.voice then  --语音类型
           --      newheight = newheight + 10
           --      ynewheight = ynewheight - 10
           --  end

            local content = data[i].content
            if data[i].type == FuncChat.EventEx_Type.voice then  --语音类型
                local newcotent = table.copy(json.decode(data[i].content))
                -- if  type(newcotent) == "table" then
                    content = newcotent.content
                -- end
            end
            local width,height = FuncChat.getStrWandH(content)
            local newheight = 60 + height
            local ynewheight = -55-height
            if data[i].voice then
                newheight = height + 65
                ynewheight = ynewheight - 10 ---(68 + height)
            end
            if data[i].type == FuncChat.EventEx_Type.voice then  --语音类型
                newheight = newheight + 10
                ynewheight = ynewheight - 10
            end


            local param={
               data={data[i]},
               createFunc=genPrivateObject,
               -- updateCellFunc = updateCellFunc,
               perNums=1,
               offsetX=10,
               offsetY= 0,
               widthGap=0,
               itemRect={x=0,y=ynewheight,width=450,height=newheight},
               perFrame=touchs,
            };
            sumindex =  sumindex + 1
            table.insert(params,param)
        end
        self.mc_scroll:setVisible(true)
        self.mc_scroll:getViewByFrame(1).scroll_1:styleFill(params);
        self.mc_scroll:getViewByFrame(1).scroll_1:gotoTargetPos(1,#params);
    end
end


function ChatMainView:showChattypeUI( _type,pracieindex ,params_id)
    if _type ~= nil then
        -- if self.Leafsign_index ~= 5 then
        -- if self.selectview ~= 511 then
            -- self.params_id = params_id
            -- self:clickButtonPrivate()
            -- self:ShowPrivateChatView(item,pracieindex)
            -- ChatModel:setSelectType(5)
            self:BiaoqianIndex(5)
            self.Leafsign_index = 5
            self.temporaryType = pracieindex
            self.chatzitype = pracieindex
            self.params_id = params_id
            self:showChatViewList()
            -- ChatModel:automaticallyPlayVoice(self.Leafsign_index)
        -- end
    end
end
function ChatMainView:registerEvent()

      -- self.mc_2:setVisible(false)
      -- local p_x = self.mc_2:getPositionX()
      -- local p_y = self.mc_2:getPositionY()
      -- self.mc_3:setPosition(p_x,p_y)   --之前版本仙盟位置改变
--//注册监听事件

    EventControler:addEventListener(ChatEvent.SYSTEM_CHAT_CONTENT_UPDATE,self.notifySystemChat,self);
    EventControler:addEventListener(ChatEvent.WORLD_CHAT_CONTENT_UPDATE,self.notifyWorldChat,self);
    EventControler:addEventListener(ChatEvent.TEAM_CHAT_CONTENT_UPDATE,self.notifyTeamChat,self);
    EventControler:addEventListener(ChatEvent.LEAGUE_CHAT_CONTENT_UPDATE,self.notifyContentChat,self);
    EventControler:addEventListener(ChatEvent.LOVE_CHAT_CONTENT_UPDATE,self.notifyLoveChat,self);

    
    EventControler:addEventListener(ChatEvent.PRIVATE_CHAT_CONTENT_UPDATE,self.notifyPrivateChat,self);
    EventControler:addEventListener(ChatEvent.CHAT_SEND_SP_REWARD,self.GetSendSp_callback,self);
    EventControler:addEventListener("notify_friend_Agreed_2928" ,self.getfriendList,self)
    EventControler:addEventListener(ChatEvent.FRIEND_REMOVE_ONE_PLAYER ,self.removeChatPlayer,self)
    EventControler:addEventListener(FriendEvent.FRIEND_MODIFY_NAME ,self.modifynameEvent,self) --修改玩家昵称
    EventControler:addEventListener("TRIAL_PIPEI_END_CALLBACK" ,self.reomveChatview,self)

    EventControler:addEventListener(GuildEvent.CLOSE_ADD_GUILD_VIEW_EVENT ,self.removeUI,self)
    
    --屏幕旋转回调
    EventControler:addEventListener(PCSdkHelper.EVENT_SCREEN_ORIENTATION ,self.screenRotation,self)


    EventControler:addEventListener(ChatEvent.REFRESH_PLAYER_ONLOINE ,self.refreshOnlineData,self)

    EventControler:addEventListener(ChatEvent.REFRESH_PLAYER_TIHUAN_SERVER,self.refreshplayRid,self)

    EventControler:addEventListener(ChatEvent.REMOVE_CHAT_UI,self.removeUI,self)

    EventControler:addEventListener(ChatEvent.REMOVE_VOICE_UI, self.showVoiceView, self)

    EventControler:addEventListener("REFRESHSETINFO" ,self.playvoice,self)

    EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_CHALLENGE_END ,self.removeUI,self)
end

function ChatMainView:notifyLoveChat()
    if(self.Leafsign_index==ChatType.ChatType_Love)then
        self:showLoveData()      
    end
end

function ChatMainView:playvoice()
    
    -- if self.targetPlayer ~= nil then
    --     local rid = self.targetPlayer.rid
    --     ---语音播放
    --     ChatModel:playPrivate(rid)
    -- else
        ChatModel:automaticallyPlayVoice(self.Leafsign_index)
    -- end

end
function ChatMainView:showVoiceView()
    self.UI_spake:setVisible(false)
    self.isSendVoice = true
    self.firsttouch = true
end
function ChatMainView:removeUI()
    -- if device.platform ~= "windows" or device.platform ~="mac" then
    --     VoiceSdkHelper:setVoiceWork(false)
    -- end
    ChatServer:stopPlayFile()
    -- ChatModel:saveLandData()
    
    -- EventControler:dispatchEvent(HomeEvent.HOME_VOICE_PLAY);

    EventControler:dispatchEvent(ChatEvent.SHOW_RED_TRACK);
    EventControler:dispatchEvent(ChatEvent.PRIVATE_CHAT_CONTENT_UPDATE);
    self:startHide()
end
function ChatMainView:refreshplayRid()
    
    -- dump(self.targetPlayer,"当前玩家的数据",7)
    if self.targetPlayer ~= nil then
        if self.selectview ~= 511 then 
            local data = ChatModel.selectTargetPlayer
            if data ~= nil then
                if self.targetPlayer.uid == data.uid then
                    self.targetPlayer.rid = data.rid
                end
                ChatModel.selectTargetPlayer = nil
            end
        end
    end
end
function ChatMainView:refreshOnlineData()
    if(self.Leafsign_index == ChatType.ChatType_Private)then
        if self.selectview ~= 511 then 
            if self.temporaryType == 1 then
                self:Settemporaryfriend(self.temporaryfriend,1)
            else
                self:ToDoGoodfriend(self.ThereFriend,2)
            end
        end
    end
end
function ChatMainView:reomveChatview()
    ChatModel:settematype(nil)
    ChatModel:setChatTeamData(nil) ---传"玩家数据"
    ChatModel:setTeamMessage(nil)
    ChatModel:setSelectType(2)
    ChatModel:setPrivateTargetPlayer(nil);
    self:removeUI()
end

function ChatMainView:modifynameEvent()
    self:getAllTemporaryAndThereData()
    -- dump(self.ThereFriend,"11111111111111111111111")
    if self.selectview == 511 then  --511 表示私聊的第几个聊天界面
        local data = FriendModel:getupfriendData()
        self.mc_scroll:getViewByFrame(2).txt_1:setString(data.name);
        local friendinfo = ChatModel:ByFriendIDgetData(self.targetPlayer.rid)
        -- dump(self.targetPlayer,"11111111")
        -- dump(friendinfo,"2222222")
        self.targetPlayer = friendinfo
        self:refreshPrivateview()
    else
        self:ToDoGoodfriend()
    end
end
function ChatMainView:notifyTeamChat()
    dump(ChatModel.teamMessage,"组队聊天")
    if(self.Leafsign_index==ChatType.ChatType_Team)then
                 --self:tremData()
                 self:clickButtonTeam()
                -- echo("1111111111111111111111111111111")
                --self:clickButtonWorld()
         -- else--//否则,产生红点事件        
    end
end
function ChatMainView:GetSendSp_callback()
    if(self.Leafsign_index == ChatType.ChatType_Private)then
        self.mc_5:getViewByFrame(1).panel_red:setVisible(false)
        if self.Leafsign_index == 5 then  --511 表示私聊的第几个聊天界面 
            self:getAllTemporaryAndThereData()
            if self.temporaryType == 1 then
                self.mc_6:getViewByFrame(3).panel_red2:setVisible(true)
                self:Settemporaryfriend(self.temporaryfriend,1)
            else
                self:ToDoGoodfriend(self.ThereFriend,2)
            end
        end
    else
        self.mc_5:getViewByFrame(1).panel_red:setVisible(true)
    end
end
function ChatMainView:removeChatPlayer(_param)
    -- dump(_param.params,"删除的好友")
    -- self:getAllTemporaryAndThereData()
    -- dump(self.ThereFriend,"11111111111111")
    FriendModel:SendServergetFriendList()
    if self.Leafsign_index == ChatType.ChatType_Private then
        ChatModel:RemoveChatprivateMessage(tostring(_param.params))
        for k,v in pairs(self.ThereFriend) do
            if _param.params == v.rid then
                self.ThereFriend[k] = nil
                -- echo("555555555555555555555555")
            end
        end
        -- dump(self.ThereFriend,"0000000")
        local index = 1
        local data = {}
        for k,v in pairs(self.ThereFriend) do
            v.index = index
            data[index] = v
            index =index + 1
        end
        self.ThereFriend = {}
        self.ThereFriend = data
        -- dump(self.ThereFriend,"00000")
        FriendModel:removeFriend(_param.params)
        self:ToDoGoodfriend(self.ThereFriend,2)
        -- self:getAllTemporaryAndThereData()
    end
end
---点击系统按钮
function ChatMainView:clickButtonSystem()  
    -- WindowControler:showTips(GameConfig.getLanguage("chat_function_not_open_1015"));
    self.targetPlayer = nil
    self:touchremoveAllChildren()
    self:setUIShow()
    self:BiaoqianIndex(1)
    ChatModel:setSelectType(1)
    self:panduanFiveButtonRed(1)
    self.Leafsign_index = 1
    self.mc_scroll:setVisible(true)
    self.mc_scroll:showFrame(1)
    self.mc_6:setVisible(true)
    self.mc_6:showFrame(2)
    self.panel_tishi:setVisible(false)
    self.mc_scroll:getViewByFrame(1).scroll_1:setVisible(false)
    -- self.systemchadata = ChatModel:getSystemMessage()
    -- self.mc_scroll:getViewByFrame(1).scroll_1:cancleCacheView();
    local touch = 1
    self:showsystemListview(touch)
end
----系统显示问题
function ChatMainView:showsystemListview(touch)
	local touchs = 0
	if touch  ~= nil then
		touchs = touch
	end
    self.systemchadata = ChatModel:getSystemMessage()
    if #self.systemchadata ~= 0 then
        self.mc_scroll:setVisible(true)
    else
        self.mc_scroll:setVisible(false)
    end
    local  function genPrivateObject(_item)   
        local  _cell=UIBaseDef:cloneOneView(self.panel_tishi);
        self:currencySystemTextModel(_cell,_item);
        return _cell;
    end

    local  function updateCellFunc(_item,_cell)
        if _cell ~= nil then
            self:currencySystemTextModel(_cell,_item);
        end
    end

    

    local params = {}
    local sumindex = 0
    -- dump(data,"0000000000000000000000000000")
    -- self.systemchadata
    local data = self.systemchadata
    -- dump(data,"系统提示数据")

    if  #data ~= 0 then
        for i=1,#data do
            --dump(data[i],"+++++++++++++++++")
            local content = ChatModel:setSyetemdataStr(data[i])
            local temp
            -- local height,length = FuncCommUI.getStringHeightByFixedWidth(content,20,nil,480)
            -- echo("======content00000========",content)
            temp,content = RichTextExpand:parseRichText(content)
            -- local height,length = FuncCommUI.getStringHeightByFixedWidth(content,20,nil,480)
            local width,height = FuncChat.getStrWandH(content,470)
            -- echo("======content1111========",height)
            -- if data[i].chattype ~= 9 then
            --     if length > 4 then
            --         height = height
            --     else
            --         height = height/(length+1)
            --     end
            -- end
            -- height =0
            
            local param={

               data={data[i]},
               createFunc = genPrivateObject,
               -- updateFunc = updateCellFunc,
               perNums=1,
               offsetX=10,
               offsetY=5,
               widthGap=0,
               itemRect={x=0,y=-(10 + height),width = 470,height = 10 + height},               
               perFrame=0,
            };
            sumindex =  sumindex + 1
            table.insert(params,param)
        end
        -- dump(params,"111111111111111111111111")
        self.mc_scroll:getViewByFrame(1).scroll_1:setVisible(true)
        self.mc_scroll:getViewByFrame(1).scroll_1:styleFill(params);
        self.mc_scroll:getViewByFrame(1).scroll_1:gotoTargetPos(1,#params);
    end

end
function ChatMainView:currencySystemTextModel(_cell,_item)

    local kongge = "        "
    _cell.scroll_1:setVisible(false)
    _cell.mc_colorful:showFrame(1)
    local content = ChatModel:setSyetemdataStr(_item)
    local height,length = FuncCommUI.getStringHeightByFixedWidth(kongge..content,20,nil,480)
    -- echo("===============height=============",height,length)
    local _,string =  RichTextExpand:parseRichText(content)
    local newheight,newlength = FuncCommUI.getStringHeightByFixedWidth(kongge..string,20,nil,480)
    -- _cell.rich_1:setPositionY(_cell.rich_1:getPositionY()+height/length+2)
    -- if newlength <= 1 then
    --     _cell.rich_1:setPositionY(_cell.rich_1:getPositionY() +height/4)
    -- end
    -- if _item.chattype == 9 then
    --     if length >= 4 then
    --         _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() - height/length)
    --     end
    -- end
    -- if _item.chattype ~= 9 then
    --     if newlength >= 3 then 
    --         _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() + height/length-23/2)
    --     else
    --         _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() + height/length)
    --     end
    -- end
    
    _cell.rich_1:setString(kongge..content)
    -- _cell.rich_1:setfunc( callBack )
    -- dump(table,"可点击的文本")

end
function ChatMainView:setSystemtouch(index)
    -- echo("1111111111111111111")
    -- echo("==========index=============",index)
    -- echo("222222222222222222222")


end
---点击队伍按钮
function ChatMainView:clickButtonTeam()
    -- WindowControler:showTips(GameConfig.getLanguage("chat_function_not_open_1015"));
    self.targetPlayer = nil

    local chattematype = ChatModel:gettematype()


    if chattematype == nil then
        WindowControler:showTips(GameConfig.getLanguage("#tid_chat_004"));
        return
    end

    ChatServer:stopPlayFile()
    self:touchremoveAllChildren()
    self.targetPlayer = nil
    if chattematype == FuncChat.CHAT_TYPE.TRIAL then
        self.targetPlayer = ChatModel:getChatTeamData()
    elseif chattematype == FuncChat.CHAT_TYPE.GUILD then

    end
    self:setUIShow()
    ChatModel:setSelectType(4)
    self:panduanFiveButtonRed(4)
    self:BiaoqianIndex(4) ---标签显示问题
    self.mc_6:setVisible(true)
    self.mc_6:showFrame(1)
    self.Leafsign_index = 4
    self.mc_scroll:setVisible(false)
    self.mc_scroll:showFrame(1)
    self:tremData()
    ChatModel:automaticallyPlayVoice(self.Leafsign_index)
end
function ChatMainView:tremData()
    local touchs = 0
    if touch ~= nil then
        touchs = touch
    end
    local data = ChatModel:getTeamMessage()
    -- dump(data,"组队的聊天数据",9)

    local  function genPrivateObject(_table)
        local  _cell=UIBaseDef:cloneOneView(self.UI_talk1)--mc_talk);
        self:currencyTextModel(_cell,_table);
        return _cell;
    end
    local  function updateCellFunc(_table,_cell)
        self:currencyTextModel(_cell,_table);
    end
    local params = {}
    local sumindex = 0
    -- dump(data,"0000000000000000000000000000")
    if  #data ~= 0 then
        for i=1,#data do
            -- dump(data[1][i],"+++++++++++++++++")
            -- local height,length = FuncCommUI.getStringHeightByFixedWidth(data[i].content,20,nil,380)
            local content = data[i].content
            if data[i].type == FuncChat.EventEx_Type.voice then  --语音类型
                local newcotent = table.copy(json.decode(data[i].content))
                if  type(newcotent) == "table" then
                    content = newcotent.content
                end
            end


            local width,height = FuncChat.getStrWandH(content)
            -- echo("===========width=====length=================",width,length)
            local param={
               data={data[i]},
               createFunc=genPrivateObject,
               -- updateCellFunc = updateCellFunc,
               perNums=1,
               offsetX=-5,
               offsetY=5,
               widthGap=0,
               itemRect={x=0,y=-60-height,width=450,height= 50 + height},
               perFrame=0,
            };
            sumindex =  sumindex + 1
            table.insert(params,param)
        end
        -- dump(params,"111111111111111111111111")
        self.mc_scroll:setVisible(true)
        self.mc_scroll:getViewByFrame(1).scroll_1:styleFill(params);
        self.mc_scroll:getViewByFrame(1).scroll_1:gotoTargetPos(1,#params);
    end
end

----同意加好友返回的数据
function ChatMainView:getfriendList(event)
    -- self.event = event
    -- local function _callback(_param)
    --     -- dump(_param.result,"1111111111111111111")
    --     if (_param.result ~= nil) then
    --         FriendModel:setFriendList(_param.result.data.friendList);
    --         FriendModel:setFriendCount(_param.result.data.count);
    --         FriendModel:updateFriendSendSp(_param.result.data);
            self:getAllTemporaryAndThereData()
            self:removeAndAddFriend(event)
    --     else
    --         WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
    --     end
    -- end
    -- local param = { };
    -- param.page = 1;
    -- FriendServer:getFriendListByPage(param, _callback);
end
function ChatMainView:removeAndAddFriend(_param)
-- dump(_param.params,"2928==========")
    local paramdata = _param.params.params.data
    if paramdata.type == 1 then
        if self.targetPlayer ~= nil then
            if paramdata ~= nil then 
                if  self.targetPlayer.rid == paramdata.data._id then
                    self:VisibleinFalse()
                    -- WindowControler:showTips("已添加为好友")
                end
            end
        end
    -- else
    --     FriendModel:removeFriendUID( _param.params.uid)

    end
end
---隐藏添加好友按钮
function ChatMainView:VisibleinFalse()
   self.mc_scroll:getViewByFrame(2).panel_2:setVisible(false)
end

--//监听系统事件
function ChatMainView:notifySystemChat()
    if(self.Leafsign_index==ChatType.ChatType_System)then
        self:showsystemListview()
    end
end
--//监听世界事件
function ChatMainView:notifyWorldChat()
        if(self.Leafsign_index==ChatType.ChatType_World)then
                 self:worldData()
                 -- self:clickButtonWorld()
                -- echo("1111111111111111111111111111111")
                --self:clickButtonWorld()
         -- else--//否则,产生红点事件
                  
        end
end
function ChatMainView:notifyContentChat()
    if(self.Leafsign_index==ChatType.ChatType_League)then
        self:leagueData()          
    end
end
----聊天返回注册事件
function ChatMainView:notifyPrivateChat()
    -- echo("111111111111111111111")
        if(self.Leafsign_index == ChatType.ChatType_Private)then
            self.mc_5:getViewByFrame(1).panel_red:setVisible(false)
            self:getAllTemporaryAndThereData()
            if self.selectview == 511 then  --511 表示私聊的第几个聊天界面
                self:refreshPrivateview()
            else
                -- self:clickButtonPrivate()
                if self.temporaryType == 1 then
                    self:Settemporaryfriend(self.temporaryfriend,1)
                else
                    self:ToDoGoodfriend(self.ThereFriend,2)
                end
            end
        else--//产生红点事件
            self.mc_5:getViewByFrame(1).panel_red:setVisible(true)
        end
end
--//世界聊天
function ChatMainView:clickButtonWorld()
    self.targetPlayer = nil
    ChatServer:stopPlayFile()
    self:touchremoveAllChildren()
    self:setUIShow()
    ChatModel:setSelectType(2)
    self:panduanFiveButtonRed(2)
    self:BiaoqianIndex(2) ---标签显示问题
    self.mc_6:setVisible(true)
    self.mc_6:showFrame(1)
    self.Leafsign_index = 2
    self.mc_scroll:setVisible(false)
    self.mc_scroll:showFrame(1)
    self:worldData(1)
    self:worldChatCd()

end

function ChatMainView:worldChatCd()
    -- FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
    -- FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
    -- self.flagButtonGray=nil;
    -- self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.SendinputTextButton,self))
    -- self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.SendinputTextButton,self))
    -- FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
    -- FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
    -- self.flagButtonGray=true;
    -- self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.coolingTo,self))
    -- self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.coolingTo,self))

    -- echo("=====ChatModel.worldChatCD===1111111111======",ChatModel.worldChatCD,TimeControler:getServerTime())
    if ChatModel.worldChatCD == 0 then
        -- self:sendclearFilter()
        self:setChatButtonSendGrayAndclear()
    else
        local serveTime = TimeControler:getServerTime()
        
        local time = serveTime - ChatModel.worldChatCD
        if time >= cdTime then 
            self:sendclearFilter()
            self:setChatButtonSendGrayAndclear()
        else
            if  not self.worldHanhua then
                self:setGrayFilter()
                self.worldHanhua = true
                self:delayCall(function ()
                    self:sendclearFilter()
                    ChatModel.worldChatCD = 0
                    self:setChatButtonSendGrayAndclear()
                end,cdTime - time)

            end
        end
    end
end

function ChatMainView:sendclearFilter()
    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
    self.flagButtonGray=nil;
    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.SendinputTextButton,self))
    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.SendinputTextButton,self))
end


function ChatMainView:setGrayFilter()
    FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
    FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
    self.flagButtonGray=true;
    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.coolingTo,self))
    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.coolingTo,self))
end

function ChatMainView:worldData(touch)
    ChatModel:automaticallyPlayVoice(self.Leafsign_index)
	local touchs = 0
	if touch ~= nil then
		touchs = touch
	end
    local data = ChatModel:getWorldMessage()

    -- dump(data,"voice ==== 世界的聊天数据")

    local  function genPrivateObject(_table)   
        local  _cell=UIBaseDef:cloneOneView(self.UI_talk1)--mc_talk);
        self:currencyTextModel(_cell,_table,_item);
        return _cell;
    end
    local  function updateCellFunc(_table,_cell)
        if _table.type == FuncChat.EventEx_Type.voice then
            self:currencyTextModel(_cell,_table);
        end
    end

    
    local params = {}
    local sumindex = 0
    -- dump(data,"0000000000000000000000000000")
    if  #data ~= 0 then
        for i=1,#data do
            -- dump(data[1][i],"+++++++++++++++++")
            -- local height,length = FuncCommUI.getStringHeightByFixedWidth(data[i].content,20,nil,380)
            local content = data[i].content
            if data[i].type == FuncChat.EventEx_Type.voice then  --语音类型
                local newcotent = table.copy(json.decode(data[i].content))
                -- if  type(newcotent) == "table" then
                    content = newcotent.content
                -- end
            end
            local width,height = FuncChat.getStrWandH(content)
            local newheight = 60 + height
            local ynewheight = -55-height
            if data[i].voice then
                newheight = height + 65
				ynewheight = ynewheight - 10 ---(68 + height)
            end
            if data[i].type == FuncChat.EventEx_Type.voice then  --语音类型
                newheight = newheight + 10
                ynewheight = ynewheight - 10
            elseif data[i].type == FuncChat.EventEx_Type.guildinvite then
                newheight = newheight + 5
            elseif data[i].type == FuncChat.EventEx_Type.shareArtifact or data[i].type == FuncChat.EventEx_Type.shareTreasure then
                newheight = newheight + 5
            end

            local param={
               data={data[i]},
               createFunc=genPrivateObject,
               -- updateCellFunc = updateCellFunc,
               perNums= 1,
               offsetX= 5,
               offsetY= 0,
               widthGap=0,
               itemRect={x=0,y=ynewheight+5,width=450,height=newheight+5},
               perFrame=0,
            };
            sumindex =  sumindex + 1
            table.insert(params,param)
        end

        -- dump(params,"111111111111111111111111")
        self.mc_scroll:setVisible(true)
        -- self.mc_scroll:getViewByFrame(1).scroll_1:clearCacheView()
        self.mc_scroll:getViewByFrame(1).scroll_1:styleFill(params);
        self.mc_scroll:getViewByFrame(1).scroll_1:gotoTargetPos(1,#params);

    end

end
--//联盟聊天
function ChatMainView:clickButtonLeague()
    --WindowControler:showTips(GameConfig.getLanguage("chat_function_not_open_1015")); ---暂未开启
	self.targetPlayer = nil
    
    local isaddGuild = GuildModel:isInGuild()
    if not isaddGuild then
        WindowControler:showTips(GameConfig.getLanguage("#tid_chat_005"))
        return 
    end
    ChatServer:stopPlayFile()
    self:touchremoveAllChildren()
    self:setUIShow()
    ChatModel:setSelectType(3)
    self:panduanFiveButtonRed(3)
    self:BiaoqianIndex(3) ---标签显示问题
    self.mc_6:setVisible(true)
    self.mc_6:showFrame(1)
    self.Leafsign_index = 3
    self.mc_scroll:setVisible(false)
    self.mc_scroll:showFrame(1)

    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.SendinputTextButton,self))
    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.SendinputTextButton,self))   
    ChatModel:automaticallyPlayVoice(self.Leafsign_index)

    ChatShareControler:getGuildNotlineData(c_func(self.leagueData,self))

end





--仙盟
function ChatMainView:leagueData()
    -- local touchs = 0
    -- if touch ~= nil then
    --     touchs = touch
    -- end
    local data = ChatModel:getLeagueMessage()
    -- dump(data,"仙盟的聊天数据111111111")

    local  function genPrivateObject(_table)   
        local  _cell= UIBaseDef:cloneOneView(self.UI_talk1);
        self:currencyTextModel(_cell,_table);
        return _cell;
    end

    local  function updateCellFunc(_table,_cell)   
        self:currencyTextModel(_cell,_table);
    end
    
    local params = {}
    local sumindex = 0
    if  #data ~= 0 then
        for i=1,#data do
           local width,height = FuncChat.getStrWandH(data[i].content)

            local newheight = 55 + height
            local ynewheight = -55-height
            if data[i].voice then
                newheight = height + 65
                ynewheight = -(68 + height)
            elseif data[i].type == FuncChat.EventEx_Type.guildinvite then
                newheight = 115
                ynewheight = -115
             elseif data[i].type ==  FuncChat.EventEx_Type.guildExportMine then
                newheight = 115
                ynewheight = -115
            else
                local _Lineindex = string.find(data[i].content,"_line") 
                if _Lineindex ~= nil then
                    newheight = newheight + 10
                    ynewheight = ynewheight-10
                end

            end


            local param={
               data={data[i]},
               createFunc=genPrivateObject,
               -- updateCellFunc = updateCellFunc,
               perNums=1,
               offsetX=10,
               offsetY= 0,
               widthGap=0,
               itemRect={x=0,y=ynewheight,width=450,height=newheight},
               perFrame=touchs,
            };
            sumindex =  sumindex + 1
            table.insert(params,param)
        end
        -- dump(params,"111111111111111111111111")
        self.mc_scroll:setVisible(true)
        self.mc_scroll:getViewByFrame(1).scroll_1:styleFill(params);
        self.mc_scroll:getViewByFrame(1).scroll_1:gotoTargetPos(1,#params);
    end

end

---获得私聊里面所有的数据
function ChatMainView:getAllTemporaryAndThereData()
    local friend,notFriend = ChatModel:FenLeigetPrivateData() --ChatModel:getPrivateMessage()
    ---[[ 分布处理]]

    self.temporaryfriend = notFriend
    if #self.temporaryfriend ~= 0 then
        for i=1,#self.temporaryfriend do
            self.temporaryfriend[i].index = i
        end
    end

    self.ThereFriend =  friend 
    if #self.ThereFriend ~= 0 then
        for i=1,#self.ThereFriend do
            self.ThereFriend[i].index = i
        end
    end

    self.temporaryfriend = self:onlinePaixu(self.temporaryfriend)
    for i=1,#self.temporaryfriend do
        self.temporaryfriend[i].index = i
    end

    self.ThereFriend = self:onlinePaixu(self.ThereFriend)
    for i=1,#self.ThereFriend do
        self.ThereFriend[i].index = i
    end

    
    -- dump(self.temporaryfriend,"非好友列表数据")
    -- dump(self.ThereFriend,"好友列表数据")
    return self.ThereFriend,self.temporaryfriend
end
function ChatMainView:onlinePaixu(tables)
    local newtable = {}
    -- dump(tables,"排序数据")
    if #tables ~=  0 then
        for i=1,#tables do
            if tables[i].online == true then
                if #newtable == 0 then
                    table.insert(newtable,tables[i])
                else
                    table.insert(newtable,1,tables[i])
                end
            else
                table.insert(newtable,tables[i])
            end
        end
    end
    -- dump(newtable,"排序后")
    local iereadpaixu = {}
    for i=1,#newtable do
        if newtable[i].chatContent ~= nil then
            if #newtable[i].chatContent ~= 0 then
                local isseave = false
                for _i=1,#newtable[i].chatContent do
                    if newtable[i].chatContent[_i].isread == false then
                        isseave = true
                    end
                end
                if isseave then
                    table.insert(iereadpaixu,1,newtable[i])
                else
                    table.insert(iereadpaixu,newtable[i])
                end
            else
                table.insert(iereadpaixu,newtable[i])
            end
        end
    end


    -- dump(iereadpaixu,"排序后")

    return iereadpaixu
end

--//私聊按钮点击
function ChatMainView:clickButtonPrivate(zitype)

    ChatServer:stopPlayFile()
    self:touchremoveAllChildren()
    self:setUIShow()
    self.Leafsign_index = 5
    ChatModel:setSelectType(5)  ---低级个标签
    self:BiaoqianIndex(5)
    -- local temporaryfriend,ThereFriend =  ---临时好友和当前存在的好友
    self:getAllTemporaryAndThereData()

    self.mc_6:setVisible(false)
    self.mc_6:getViewByFrame(3).btn_2:setTap(c_func(self.ToDoGoodfriend,self,self.ThereFriend,2))--临时界面好友按钮
  ---临时界面好友按钮
    self.mc_6:getViewByFrame(3).btn_1:setTap(c_func(self.Settemporaryfriend,self,self.temporaryfriend,1))  ---临时界面好友按钮
    -- self.mc_6:getViewByFrame(3).btn_3:setTap(c_func(self.Akeytoget,self))
    if zitype == 1 then
        self.todochatview = true
        self:Settemporaryfriend(self.temporaryfriend,1)
    elseif zitype == 2 then
        self.todochatview = true
        self:ToDoGoodfriend(self.ThereFriend,2)
    else
        if #self.temporaryfriend ~= 0 then
          -- self.mc_6:getViewByFrame(3).btn_2:setTap(c_func(self.ToDoGoodfriend,self,self.ThereFriend,2))  ---临时界面好友按钮
          self:Settemporaryfriend(self.temporaryfriend,1)
        else
            if #self.ThereFriend ~= 0 then
                -- self.mc_6:getViewByFrame(3).btn_1:setTap(c_func(self.Settemporaryfriend,self,self.temporaryfriend,1))  ---临时界面好友按钮
                self:ToDoGoodfriend(self.ThereFriend,2)
            else
                self.mc_scroll:setVisible(false)
                self.mc_btn:setVisible(true)
                self.mc_btn:showFrame(2)
                self.mc_6:setVisible(true)
                self.mc_6:showFrame(3)
                self:ToDoGoodfriend(self.ThereFriend,2)
                self.mc_btn:getViewByFrame(2).btn_1:setTap(c_func(self.AddFriendView,self))
            end
        end
    end

    -- self.mc_6:showFrame(3)
    

      --//设置私聊对象
      -- ChatModel:setPrivateTargetPlayer(nil);
      -- self:freshPrivateChat();
end 
---一键领取
-- function ChatMainView:Akeytoget()
--     if self.temporaryType  == 1 then  --临时领取
--         -- echo("=============临时===========")
--         WindowControler:showTips(GameConfig.getLanguage("#tid_chat_006"))
--     else  --好友领取
--         -- self.temporaryfriend
--         -- self.ThereFriend
--         -- echo("=============好友===========")
--         self:AllinGetreward()
--     end
    
-- end
--发送获取好友列表，在刷新数据
function ChatMainView:getFriendTiliData()
    local function _callback(_param)
        -- dump(_param.result,"获取服务器好友列表")
        if (_param.result ~= nil) then
            FriendModel:setFriendList(_param.result.data.friendList);
            FriendModel:setFriendCount(_param.result.data.count);
             self:getAllTemporaryAndThereData()
            if self.temporaryType == 1 then
                self:Settemporaryfriend(self.temporaryfriend,1)
            else
                self:ToDoGoodfriend(self.ThereFriend,2)
            end
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
        end
    end
    local param = { };
    param.page = 1;
    FriendServer:getFriendListByPage(param, _callback);
end
function ChatMainView:AllinGetreward()
        local function _callback(_param)
        if (_param.result ~= nil) then
            dump(_param.result.data,"一键领取体力返回数据",8)
            -- FriendModel:SendServergetFriendList()
            if (_param.result.data.sp > 0) then
                local _achieveInfo = GameConfig.getLanguage("tid_friend_sp_detail_1023");
                -- //获取了多少体力,还剩余多少体力
            -- //获取了多少体力,还剩余多少体力
               local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
               local _maxSpNum = FuncDataSetting.getDataByConstantName("ReceiveTimes")*_oneSp;
            -- //体力上限
               local   _achieveCount=CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_ACHIEVE_SP_COUNT)*_oneSp;
               WindowControler:showTips(_achieveInfo:format(_param.result.data.sp, _maxSpNum - _achieveCount));
               self:getFriendTiliData()
            else
                local needCount=0;
                local _maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
                local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
                if(UserExtModel:sp()+_oneSp>_maxSpNum)then--//体力超上限
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_reach_limit_1044"):format(_maxSpNum));
                else
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_to_limit_1047"));
                end
            end
        else
            echo("---FriendMainView:clickButtonOneKeyAchieveSp-----", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_achieve_sp_failed_1024");
            if (_param.error.message == "friend_sp_times_max") then
                -- //已经达到体力上限
                _tipMessage = GameConfig.getLanguage("tid_friend_self_sp_reach_limit_1025");
            elseif (_param.error.message == "friend_sp_not_exists") then
                _tipMessage = GameConfig.getLanguage("tid_friend_can_not_achieve_sp_1026");
            end
            WindowControler:showTips(_tipMessage);
        end
    end
    if ChatModel:getLiwuRewrad() then
        local param = { };
        --          param.frid="";
        param.isAll = 1;
        FriendServer:achieveFriendSp(param, _callback);
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_chat_006"))
    end
end

function ChatMainView:newmessagePaiXu( datalist )
    local function table_sort(a,b)
        if a.time ~= nil  and b.time ~= nil then
          return a.time > b.time
        end
    end
    table.sort(datalist,table_sort);
    return datalist
end
---设置临时好友界面
function ChatMainView:Settemporaryfriend(data,_type)
    self.targetPlayer = nil
    ChatServer:stopPlayFile()
    ChatModel:setPrivateTargetPlayer(nil);
    self:touchremoveAllChildren()
    -- self:getAllTemporaryAndThereData()
    FilterTools.setGrayFilter(self.mc_6:getViewByFrame(3).btn_1);
    FilterTools.clearFilter(self.mc_6:getViewByFrame(3).btn_2);
    self.mc_6:getViewByFrame(3).btn_1:setTap(function ()end)--临时界面好友按钮
    self.mc_6:getViewByFrame(3).btn_2:setTap(c_func(self.ToDoGoodfriend,self,self.ThereFriend,2))--临时界面好友按钮
  ---临时界面好友按钮
    -- self.mc_6:getViewByFrame(3).btn_1:setTap(c_func(self.Settemporaryfriend,self,self.temporaryfriend,1))  ---临时界面好友按钮
    -- self.mc_6:getViewByFrame(3).btn_3:setTap(c_func(self.Akeytoget,self))
    local datafriend,notfriend = self:getAllTemporaryAndThereData()
    data = self:newmessagePaiXu(notfriend)
    -- dump(data,"临时好友列表数据")
    self.selectview = nil
    local FrR,NotFrR = ChatModel:panduanfriengListRed()
    self.mc_6:getViewByFrame(3).panel_red:setVisible(false)
    if FrR then
        self.mc_6:getViewByFrame(3).panel_red2:setVisible(true)
    end

    self.mc_scroll:setVisible(false)
    -- self.mc_scroll:showFrame(1)
    self.mc_6:showFrame(3)
    -- self.mc_6:getViewByFrame(3).mc_1:showFrame(2)
    self.mc_btn:setVisible(false)
    -- self.temporaryType = 
    self.temporaryType = 1
    self.mc_scroll:getViewByFrame(1).scroll_1:clearCacheView()
     if #data == 0 then
        self.mc_btn:setVisible(true)
        self.mc_btn:showFrame(3)
        -- self.mc_btn:getViewByFrame(3).txt_1:setString("暂无好友列表")
        -- self.mc_6:getViewByFrame(3).mc_1:showFrame(2)
        self.mc_6:getViewByFrame(3).btn_2:setTap(c_func(self.ToDoGoodfriend,self,self.ThereFriend,2))
        self.temporaryType = _type

        return 
    end


    -- data = ChatModel:setfriendListHead(data)
    self.mc_6:setVisible(true)
    
    local  function genPrivateObject(_item)   
        local  _cell=UIBaseDef:cloneOneView(self.panel_sl);
        self:updatePrivateObject(_cell,_item);
        return _cell;
    end
    local  function updateCellFunc(_item,_cell)   
        self:updatePrivateObject(_cell,_item);

    end
    

    local param={
           data=data,
           createFunc=genPrivateObject,
           -- updateCellFunc = updateCellFunc,
           perNums=1,
           offsetX=10,
           offsetY= 10,
           widthGap=0,
           itemRect={x=0,y=-65,width=536,height=65},
           perFrame=0,
    };

    self.mc_scroll:setVisible(true)
    self.mc_scroll:showFrame(1)
    self.mc_scroll:getViewByFrame(1).scroll_1:cancleCacheView();
    self.mc_scroll:getViewByFrame(1).scroll_1:styleFill({param});
    self.mc_scroll:getViewByFrame(1).scroll_1:gotoTargetPos(1,1);
    -- self.mc_6:getViewByFrame(3).mc_1:showFrame(2)  --显示临时好友
end
function ChatMainView:AddFriendView()
    ChatModel:setPrivateTargetPlayer(nil);

    self:removeUI()
    FriendViewControler:forceShowFriendList(nil,nil,2) ---直接到好友推荐列表
end
---点击临时界面好友按钮跳转
function ChatMainView:ToDoGoodfriend(data,_type)
    self.targetPlayer = nil
    ChatServer:stopPlayFile()
    ChatModel:setPrivateTargetPlayer(nil)
    self:touchremoveAllChildren()
    local friend,notfriend = self:getAllTemporaryAndThereData()
    -- local data = friend
    -- dump(data,"===ToDoGoodfriend==111111==")
    data = self:newmessagePaiXu(friend)   
    -- dump(data,"===ToDoGoodfriend===222222=")
    FilterTools.setGrayFilter(self.mc_6:getViewByFrame(3).btn_2);
    FilterTools.clearFilter(self.mc_6:getViewByFrame(3).btn_1);
    self.mc_6:getViewByFrame(3).btn_2:setTap(function ( ... )end)--临时界面好友按钮
  ---临时界面好友按钮
    self.mc_6:getViewByFrame(3).btn_1:setTap(c_func(self.Settemporaryfriend,self,self.temporaryfriend,1))  ---临时界面好友按钮
    -- self.mc_6:getViewByFrame(3).btn_3:setTap(c_func(self.Akeytoget,self))
    self.selectview = nil
    local FrR,NotFrR = ChatModel:panduanfriengListRed()
    self.mc_6:getViewByFrame(3).panel_red2:setVisible(false)
    if NotFrR then
        self.mc_6:getViewByFrame(3).panel_red:setVisible(true)
    end
    self.mc_btn:setVisible(false)
    self.mc_scroll:setVisible(true)
    self.mc_scroll:showFrame(1)
    self.mc_6:setVisible(true)
    self.mc_6:showFrame(3)
    -- self.mc_6:getViewByFrame(3).mc_1:showFrame(1)
    self.temporaryType = _type
    self.temporaryType = 2
    -- data = ChatModel:setfriendListHead(data)
    if #data == 0 then
        self.mc_scroll:setVisible(false)
        -- self.mc_6:setVisible(false)
        self.mc_btn:setVisible(true)
        self.mc_btn:showFrame(2)
        self.mc_btn:getViewByFrame(2).btn_1:setTap(c_func(self.AddFriendView,self))
        -- self.mc_6:getViewByFrame(3).mc_1:showFrame(1)
        self.mc_6:getViewByFrame(3).btn_1:setTap(c_func(self.Settemporaryfriend,self,self.temporaryfriend,1))
        -- self.mc_btn:getViewByFrame(3).txt_1:setString("暂无好友列表")
        -- self.temporaryType = _type
        return 
    end
    -- self.mc_6:setVisible(true)
    
    local  function genPrivateObject(_item)   
        local  _cell=UIBaseDef:cloneOneView(self.panel_sl);
        self:updatePrivateObject(_cell,_item);
        return _cell;
    end

    local  function updateCellFunc(_item,_cell)   
        self:updatePrivateObject(_cell,_item);
    end
    

    local param={
           data=data,
           createFunc=genPrivateObject,
           -- updateCellFunc = updateCellFunc,
           perNums=1,
           offsetX=10,
           offsetY=10,
           widthGap=0,
           itemRect={x=0,y=-65,width=536.35,height=65},
           perFrame=0,
    };
    self.mc_scroll:setVisible(true)
    -- self.mc_scroll:getViewByFrame(1).scroll_1:cancleCacheView();
    self.mc_scroll:getViewByFrame(1).scroll_1:styleFill({param});
    self.mc_scroll:getViewByFrame(1).scroll_1:gotoTargetPos(1,1);
     -- self.mc_6:getViewByFrame(3).mc_1:showFrame(1)  --显示临时好友
     self.mc_6:getViewByFrame(3).btn_1:setTap(c_func(self.Settemporaryfriend,self,self.temporaryfriend,1))

end

-- 临时数据模板：
function ChatMainView:updatePrivateObject(_cell,_item)
    -- dump(_item,"私聊列表控件数据===",6)

 --//玩家头像
        local     _node=_cell.panel_1.ctn_1;
        -- local _icon = FuncChar.icon(tostring(_item.avatar));
        -- local _sprite = display.newSprite(_icon)--:size(_node.ctnWidth, _node.ctnHeight);
        -- _sprite:setScale(0.52)
        -- _node:addChild(_sprite);
        local head = nil
        if _item.head ~= nil or _item.liwu ~= nil then
            -- ChatModel:setPlayerIcon(_node,head,_item.avatar)
            head = _item.head or _item.liwu.head or ""
        end
        ChatModel:setPlayerIcon(_node,head,_item.avatar)
--//名字
        if(_item.name==nil or _item.name=="")then
           _cell.txt_1:setString(GameConfig.getLanguage("tid_common_2006"));
        else
            _cell.txt_1:setString(_item.name);
        end
        if _item.liwu ~= nil then
            if _item.liwu.mk ~= nil then
                _cell.txt_1:setString(_item.liwu.mk)
            end
        else
            if _item.mk ~= nil then
                _cell.txt_1:setString(_item.mk)
            end
        end
        if(not _item.online)then
            _cell.panel_2.mc_1:showFrame(2)
        else
            _cell.panel_2.mc_1:showFrame(1)
        end

---红点
    _cell.panel_red:setVisible(false)
    -- for i=1,#_item.chatContent do
    --     if _item.chatContent[i].isread == true then
    --         _cell.panel_red:setVisible(true)
    --     end
    -- end
    if _item.isread == false then
        _cell.panel_red:setVisible(true)
    else
        _cell.panel_red:setVisible(false)
    end

    if self.temporaryType == 1 then
        _cell.txt_red:setVisible(false)  ---好友度的数量不显示
        _cell.panel_xin:setVisible(false) --好友度的红心不显示
        _cell.btn_1:setVisible(true)
        _cell.btn_1:setTap(c_func(self.DeleteFriendChat,self,_item))                                  
    else
        _cell.txt_red:setVisible(true)  ---好友度的数量显示
        _cell.panel_xin:setVisible(true) ---好友度的红心显示
        _cell.btn_1:setVisible(false)  ---删除按钮隐藏
        _cell.txt_red:setString(_item.lk or 0)
    end
--礼物
    -- if _item.liwu ~= nil then
    --     if  _item.liwu.hasSp  then
    --         _cell.mc_liwu:showFrame(1)
    --         _cell.mc_liwu:getViewByFrame(1).btn_1:setTap(c_func(self.getLiWuButton,self,_item))
    --         _cell.panel_red:setVisible(true)
    --     else
    --         _cell.mc_liwu:showFrame(2)
    --         _cell.mc_liwu:getViewByFrame(2).btn_1:setTap(c_func(self.getNotLiWuButton,self,_item))
    --         -- _cell.panel_red:setVisible(false)
    --     end
    -- else
    --     if _item.tili then
    --         _cell.mc_liwu:showFrame(1)
    --         _cell.mc_liwu:getViewByFrame(1).btn_1:setTap(c_func(self.getLiWuButton,self,_item))
    --         _cell.panel_red:setVisible(true)
    --    else
    --         _cell.mc_liwu:showFrame(2)
    --         _cell.mc_liwu:getViewByFrame(2).btn_1:setTap(c_func(self.getNotLiWuButton,self,_item))
    --     end
    --     -- _cell.panel_red:setVisible(false)
    -- end

--//等级
    _cell.panel_1.txt_1:setString("".._item.level);
--//高亮度显示
    -- _cell.scale9_2:setVisible(_item.rid==self.targetPlayer.rid);
--//注册监听事件  ---私聊界面
    _cell.panel_2:setTouchedFunc(c_func(self.ShowPrivateChatView,self,_item,2),nil,true);
    -- if 
--//注册玩家详情点击事件
    _cell.panel_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayerInfo,self,_item),nil,true);
end
--获得礼物
function ChatMainView:getLiWuButton(_item)
    -- body
    -- local _cell = self.scroll_list:getViewByData(_item)
    -- dump(_item,"0000000000000000000000000000000000")
    -- echo("===========礼物================")
    -- local _maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
    -- local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
    -- if(UserExtModel:sp()+_oneSp>_maxSpNum)then--//体力超上限
    --     WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_reach_limit_1044"):format(_maxSpNum));
    --     return
    -- end


    local function _callback(_param)
        if (_param.result ~= nil) then
                local function callBack()
                    self:getAllTemporaryAndThereData()
                    if(_param.result.data.sp>0)then
                        local _cell = self.mc_scroll:getViewByFrame(1).scroll_1:getViewByData(_item);
                        _cell.mc_liwu:showFrame(2)
                        _cell.mc_liwu:getViewByFrame(2).btn_1:setTap(c_func(self.getNotLiWuButton,self,_item))
                        _cell.panel_red:setVisible(false)

                        ChatModel:setLingQuTili(_item.rid)
                        WindowControler:showTips(GameConfig.getLanguage("#tid_chat_007"))
                    else--//分情况
                        local _maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
                        local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
                        if(UserExtModel:sp()+_oneSp>_maxSpNum)then--//体力超上限
                            WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_reach_limit_1044"):format(_maxSpNum));
                        else
                            WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_to_limit_1047"));
                            self:ToDoGoodfriend(self.ThereFriend,2)
                        end
                    end
                end
                FriendModel:SendServergetFriendList(callBack)
        else
            echo("-----FriendMainView:clickButtonSendSp-------", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_achieve_sp_failed_1024");
            -- //领取体力失败
            if (_param.error.message == "friend_sp_times_max") then
                _tipMessage = GameConfig.getLanguage("tid_friend_self_sp_reach_limit_1025");
                -- //自己已经达到体力上限
            elseif (_param.error.message == "friend_sp_not_exists") then--//好友已经被删除了
                -- //无法领取体力
                _tipMessage = GameConfig.getLanguage("tid_friend_need_add_friend_first_1045");--GameConfig.getLanguage("tid_friend_can_not_achieve_sp_1026");
                -- self:freshFriendListUICommon();--//刷新页面
            elseif(_param.error.message=="friend_not_exists")then--//如果不是好友
                _tipMessage=GameConfig.getLanguage("tid_friend_need_add_friend_first_1045");
                -- self:freshFriendListUICommon();--//刷新页面
            end
            WindowControler:showTips(_tipMessage);
        end
    end
        local param = { };
    param.frid = _item.rid;
    param.isAll = 0;
    FriendServer:achieveFriendSp(param, _callback);
end
---未获得礼物
function ChatMainView:getNotLiWuButton()
    -- body
    -- local _cell = self.scroll_list:getViewByData(_item)
    WindowControler:showTips(GameConfig.getLanguage("#tid_chat_008"))

end
function ChatMainView:ShowPrivateChatView(_item,_type)

    -- dump(_item,"3333333333333")

    self:getAllTemporaryAndThereData()
    ChatModel:setSelectType(5)
    self.params_id = nil
    self.selectview = 511 
    ChatModel:setPrivateTargetPlayer(_item);
    -- dump(_item,"私聊玩家的数据")  --chatContent
    self.targetPlayer = _item
    ChatModel:setChatPrivateisread(_item.rid)
    self.mc_6:showFrame(1)
    self.mc_scroll:setVisible(true)
    self.mc_scroll:showFrame(2)
    self.mc_scroll:getViewByFrame(2).scroll_1:setVisible(false)
    local number = ChatModel:getChatPrivateRedNumber()
    -- echo("=========number==============",number)
    if tonumber(number) == 0 then
        number = ""
    else
        if _item.isread ~= nil then
            if _item.isread == false then
                local nus = number
                if nus == 0 then
                    number = ""
                else
                    number = "("..nus..")"
                end
            else
                number = "("..number..")"
            end
        else
            number = "("..number..")"
        end
    end
    _item.isread = true
    -- number = ""
    self.mc_scroll:getViewByFrame(2).panel_1.txt_1:setString(GameConfig.getLanguage("tid_common_2043"))--..number)



    if(_item.name == nil or _item.name == "")then
        self.mc_scroll:getViewByFrame(2).txt_1:setString(GameConfig.getLanguage("tid_common_2006"));
    else
        self.mc_scroll:getViewByFrame(2).txt_1:setString(_item.name);
    end



    local mk = ""
    if _item.liwu ~= nil then
        if _item.liwu.mk ~= nil then
            mk = _item.liwu.mk
        end
    end
    if mk ~= "" then
        self.mc_scroll:getViewByFrame(2).txt_1:setString(mk);
    end
    if _item.mk ~= nil then
        self.mc_scroll:getViewByFrame(2).txt_1:setString(_item.mk);
    end
    

    -- c_func(self.ToDoGoodfriend,self,self.ThereFriend,2)
    -- c_func(self.Settemporaryfriend,self,self.temporaryfriend,1)
    if self.temporaryType == 2 then
        self.mc_scroll:getViewByFrame(2).panel_2:setVisible(false)
        self.mc_scroll:getViewByFrame(2).panel_1:setTouchedFunc(c_func(self.ToDoGoodfriend,self,self.ThereFriend,2),nil,true);    
        -- :setTap(c_func(self.ToDoGoodfriend,self,self.ThereFriend,2))
    else
        self.mc_scroll:getViewByFrame(2).panel_2:setVisible(true)
        self.mc_scroll:getViewByFrame(2).panel_1:setTouchedFunc(c_func(self.Settemporaryfriend, self,self.temporaryfriend,1),nil,true);   
        -- :setTap(c_func(self.Settemporaryfriend,self,self.temporaryfriend,1))
        self.mc_scroll:getViewByFrame(2).panel_2:setTouchedFunc(c_func(self.addFriendButton, self,_item),nil,true);    
         -- :setTap(c_func(self.addFriendButton,self,_item))
    end
    

   
    self:sendPrivatedata(_item)

end


function ChatMainView:sendPrivatedata(_item)
    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
    EventControler:dispatchEvent(ChatEvent.SHOW_RED_TRACK);
    local rid = _item.rid
    ChatModel:byPlayidGetData(rid,c_func(self.refreshPrivateview,self))
end

--刷新私聊的view
function ChatMainView:refreshPrivateview()
    if not self  then   --对象被删除
        return
    end
    if not self.targetPlayer then
        return 
    end
	self.mc_6:getViewByFrame(1).mc_1:showFrame(1)
    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.SendinputTextButton,self))    
    local rid = self.targetPlayer.rid
    ---语音播放
    ChatModel:playPrivate(rid)


    local data = {}
    local privateMessagedata =  ChatModel:getPrivateMessage()
    -- dump(privateMessagedata,"111111111111111111111111111111111",4)
    -- dump(self.targetPlayer,"2222222222222222222222222222222")
    if #privateMessagedata ~= 0 then
        for k,v in pairs(privateMessagedata) do
            local uid = ChatModel:getRidBySec(v.rid)
            if self.targetPlayer.uid == uid then
                if v.isread ~= nil then
                    v.isread = true
                end
                if #v.chatContent ~= 0 then
                    -- local head = v.chatContent[#v.chatContent].head
                    local frienddata = FriendModel:getFriendDataByID(v.rid)
                    for i=1,#v.chatContent do
                        if v.chatContent[i].isread ~= nil then
                            v.chatContent[i].isread = true
                            if self.targetPlayer.uid ~= uid then
                                v.chatContent[i].head = frienddata.head
                            end
                            v.isread = true
                        end
                    end
                    table.insert(data,v.chatContent)
                end
            end
        end
    end
    -- self.targetPlayer
    ChatModel:setPrivateMessageFriend(privateMessagedata)

    local  function genPrivateObject(_table)
        local  _cell=UIBaseDef:cloneOneView(self.UI_talk1);
        self:currencyTextModel(_cell,_table,_item);
        return _cell;
    end
    local  function updateCellFunc(data,view)
        if data.type == FuncChat.EventEx_Type.voice then
            self:currencyTextModel(view,data);
        end
    end
    local params = {}
    local sumindex = 0
    data = ChatModel:setPrivesHeard(data)

    if #data ~= 0 then
        for i=1,#data[1] do
--            local width,height = FuncChat.getStrWandH(data[1][i].content)
 
            local content = data[1][i].content
            if data[1][i].type == FuncChat.EventEx_Type.voice then  --语音类型
                local newcotent = table.copy(json.decode(data[1][i].content))
                if  type(newcotent) == "table" then
                    content = newcotent.content
                end
            end
            

            local width,height = FuncChat.getStrWandH(content)

            local newheight = 55 + height
            local ynewheight = -55-height
            -- if data[1][i].voice then
            --     newheight = height + 65
            --     ynewheight = -(68 + height)
            -- end
            if data[1][i].type == FuncChat.EventEx_Type.voice then  --语音类型
                newheight = newheight + 10
                ynewheight = ynewheight - 10
            end
            local param={
               data={data[1][i]},
               createFunc=genPrivateObject,
               -- updateCellFunc = updateCellFunc,
               perNums=1,
               offsetX=-5,
               offsetY= -3,
               widthGap=0,
               itemRect={x=0,y=ynewheight,width=450,height=newheight},
               perFrame=0,
            };
            sumindex =  sumindex + 1
            table.insert(params,param)
        end
        -- dump(params,"111111111111111111111111")
        -- self.mc_scroll:getViewByFrame(2).scroll_1:cancleCacheView()
        self.mc_scroll:getViewByFrame(2).scroll_1:setVisible(true)
        self.mc_scroll:getViewByFrame(2).scroll_1:styleFill(params);
        self.mc_scroll:getViewByFrame(2).scroll_1:gotoTargetPos(1,#params);
    -- else
    --     self.mc_6:showFrame(1)
    end


end
----通用聊天是模板
function ChatMainView:currencyTextModel(_cell,_item,playinfo)
    -- echo("=======_item======",_item)
    -- dump(_item,"=======_item======")
    _cell:initData(_item, self.mc_scroll)
end
--//查询任意一个角色信息
function ChatMainView:clickCellButtonQueryPlayerInfo(_item)
  -- dump(_item,"1111111111111")
    if _item.isRobot then 
        local   _playerUI=WindowControler:showWindow("CompPlayerDetailView",_item,self,1);
    else
        -- _playerUI=WindowControler:showWindow("CompPlayerDetailView",_item,self,1);
        local function _callback(param)
          -- dump(param.result,"111111111")
                if(param.result~=nil)then
                    local data = param.result.data.data
                    FriendModel:setChatDataInFriendData(data)
                    self:refreshOnlineData()
                    local   _playerUI=WindowControler:showWindow("CompPlayerDetailView",param.result.data.data[1],self,1);--//从世界聊天进入
                end
        end
        -- local sec = FriendModel:getRidBySec(_item.rid)
        local  _param={};
        -- _param.tsec = sec
        _param.rids={};
        _param.rids[1]=_item.rid;
        ChatServer:queryPlayerInfo(_param,_callback);
    end
end
-- function ChatMainView:showpranterSkin(id)
--    -- PartnerSkinEvent.SKIN_FRINED_SHOW_EVENT
--    echo("=========id=========",id)
--    EventControler:addEventListener(PartnerSkinEvent.SKIN_FRINED_SHOW_EVENT ,{id = id})
-- end

---输入的图标和语言的问题
function ChatMainView:setinputText()
    self.mc_6:showFrame(1)
    self:addVoicebutton()  
    self.mc_6:getViewByFrame(1).btn_bq:setVisible(false) --屏蔽聊天图标
    self.mc_6:getViewByFrame(1).btn_bq:setTap(c_func(self.showsmallsprite,self))
        ----扩展添加图片
    -- local Text2 = self.panel_2.input_1:getText()
    -- local _inputView = self.mc_6:getViewByFrame(1).input_1
    -- _inputView:registerScriptEditBoxHandler(c_func(self.pressEditBox, self))
    self:setChatButtonSendGrayAndclear()
end

function ChatMainView:setChatButtonSendGrayAndclear()
    local   _ramind_chat_count = ChatModel:getFreeOfChatCount();
    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
    FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);

    if(_ramind_chat_count > 0)then
        self.mc_6:getViewByFrame(1).mc_1:showFrame(1)
        self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.SendinputTextButton,self))
    else
        local costNum = ChatModel:getRMBOfChatCount()
        if costNum > 0 then
            self.mc_6:getViewByFrame(1).mc_1:showFrame(2)
            self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.SendinputTextButton,self))
            self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:getUpPanel().txt_2:setString(ChatModel:getChatCost())
        else
            self.mc_6:getViewByFrame(1).mc_1:showFrame(1)
            FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
            FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
            self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.costRMBNotCount,self))
            self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.costRMBNotCount,self))

        end
    end

end

--聊天次数不足
function ChatMainView:costRMBNotCount()
    WindowControler:showTips(GameConfig.getLanguage("#tid_Talk_202"))

end



function ChatMainView:addVoicebutton()


    local touchEndCallBack = function (event)
        if self.notvoice then
            self.notvoice = false
            return 
        end
        EventControler:dispatchEvent(HomeEvent.HOME_VOICE_PLAY);
        local fils =  self:sendVoiceGold()
        if not fils then
            self.firsttouch = true
            self.UI_spake:setVisible(false)
            self.UI_spake:moveEndSendVoice()
            return
        end

        if not self.endtouch then
            self.endtouch = true
            self.UI_spake:setVisible(false)
            self:voiceButton()
            if self.ismove or self.isSendVoice then
                self.firsttouch = true
                return
            end
            local iserror = self.UI_spake:endTiming(self.Leafsign_index)
            self:delayCall(function ()
                self.firsttouch = true
            end,FuncChat.touchClickInterval())
        end
    end

    local touchMoveCallBack = function (event)
        if self.notvoice then
            return
        end
        local movex = event.x
        local movey = event.y
        local offset = FuncChat.voiceMoveOffset()
        if not self.ismove then
            if math.abs(movex - self.firstPosX) >= offset or math.abs(movey - self.firstPosY) >= offset then
                self.ismove = true
                self.UI_spake:setVisible(false)
                self.UI_spake:moveEndSendVoice()
                EventControler:dispatchEvent(HomeEvent.HOME_VOICE_PLAY);
                WindowControler:showTips(GameConfig.getLanguage("#tid_chat_009"));
            end
        end
    end
    local touchBeginCallBack = function (event)
         if device.platform == "windows" or device.platform =="mac" then
            WindowControler:showTips(GameConfig.getLanguage("#tid_chat_010"));
            self.notvoice = true
            return 
        end
        self.firstPosX = event.x
        self.firstPosY = event.y
        if self.firsttouch then
            self.ismove = false
            self.isSendVoice = false
            self.firsttouch = false
            self.endtouch = false
            self.UI_spake:setVisible(true)
            self.UI_spake:startedTiming(self.Leafsign_index)
            -- AudioModel:stopMusic()--停止播放背景音乐
        end
    end
    self.firsttouch = true

    self.mc_6:getViewByFrame(1).panel_1:setTouchedFunc(GameVars.emptyFunc, nil, false, 
        touchBeginCallBack, touchMoveCallBack,
         isPlayComClick2Music, touchEndCallBack)
    -- self.mc_6:getViewByFrame(1).panel_1:setTouchedFunc(c_func(self.voiceButton,self),nil, true)
end

function ChatMainView:sendVoiceGold()
    if self.Leafsign_index == 2 then
        local   _ramind_chat_count=ChatModel:getFreeOfChatCount();
        if(_ramind_chat_count<=0)then
            -- WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
            if ChatModel:getRMBOfChatCount() <= 0 then
                self.UI_spake:moveEndSendVoice()
                WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
                return false
            else
                if UserModel:getGold() < ChatModel:getChatCost()  then
                    WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"));
                    self.UI_spake:moveEndSendVoice()
                    return false
                end
            end
        end
    end
    return true
end
function ChatMainView:hostRMB( )
    echo("=============花元宝===================")
    WindowControler:showTips(GameConfig.getLanguage("chat_function_not_open_1015"));
end
---显示小图标框
function ChatMainView:showsmallsprite()
    echo("=========显示小图标的窗口============")
    self:setIconView()
    -- WindowControler:showTips(GameConfig.getLanguage("chat_function_not_open_1015"));

end
function ChatMainView:voiceButton()
    -- echo("=============语音按钮===================")
    -- WindowControler:showTips("该功能正在开发中...");
    self:touchremoveAllChildren()

end

--
function ChatMainView:screenRotation()
    if self.UI_spake:isVisible() then
        self.UI_spake:setVisible(false)
        self.UI_spake:moveEndSendVoice()
        EventControler:dispatchEvent(HomeEvent.HOME_VOICE_PLAY);
        WindowControler:showTips(GameConfig.getLanguage("#tid_chat_009"));
    end
end



function ChatMainView:SendinputTextButton()
	
    -- self.Leafsign_index
    if self.Leafsign_index == 1 then

    elseif self.Leafsign_index == 2  then
        self:clickButtonSendWorldMessage()
    elseif self.Leafsign_index == 3  then
        self:clickButtonSendLeagueMessage("guild")
    elseif self.Leafsign_index == 4  then
        self:clickSendteeamMessage()
    elseif self.Leafsign_index == 5  then
        self:clickButtonSendPrivateMessage()
    elseif self.Leafsign_index == 6  then
        self:clickButtonSendLeagueMessage("love")

    end
    -- self:Savedatalocal()
    -- ChatModel:Savedatalocal()
    -- self.panel_biaoqing:setVisible(false)
    self.ctn_press:removeAllChildren()
    self.FriendEmailview = nil
end
function ChatMainView:clickButtonSendLeagueMessage(_type)
    
        --//如果仍处于冷却中
        local  bad;
        local _text = self.mc_6:getViewByFrame(1).input_1:getText()
        _text = FuncChat.ruleOutText(_text)
        local  _size=string.len(_text);
        local  _other_size=string.len4cn2(_text);
        --//字数过少
        if(_other_size<=0)then
            WindowControler:showTips(GameConfig.getLanguage("chat_words_too_little_1002"));
            return;
        end
        --//字数过多
        if(_other_size>100)then
               WindowControler:showTips(GameConfig.getLanguage("chat_words_too_long_1003"));
               return;
        end

        local isbadword,_text = Tool:checkIsBadWords(_text)
        if isbadword == true then
            _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
            WindowControler:showTips(_tipMessage);
        else   
            self.mc_6:getViewByFrame(1).input_1:setText("");
            if _type == "guild" then
                self:sendLeagueChat(_text)
            elseif _type == "love" then
                self:sendLoveChat(_text)
            end

        end
end

function ChatMainView:sendLoveChat(_text)
    local function callback(_param)
            if(_param.result~=nil)then--//发言成功后需要置灰冷却发送信息按钮
            elseif(_param.error.message=="ban_word")then--//敏感词
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_ban_word_1004"));
            elseif(_param.error.message=="string_illegal")then
                WindowControler:showTips(GameConfig.getLanguage("chat_illegal_word_1005"));
            elseif(_param.error.message=="chat_times_max")then--//次数上限
                WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
            elseif(_param.error.message=="chat_in_cd")then
                WindowControler:showTips(GameConfig.getLanguage("chat_cool_down_1006"));
            elseif(_param.error.message=="ban_chat")then--//被禁言
                WindowControler:showTips(GameConfig.getLanguage("chat_extra_forbid_chat_1001"));
            else
                echo("--ChatMainView:sendWorldChat-",_param.error.message);
            end
    end
    ChatServer:chatSendlove(_text,callback)
end

function ChatMainView:sendLeagueChat(_text)
    local function callback(_param)
            if(_param.result~=nil)then--//发言成功后需要置灰冷却发送信息按钮
            elseif(_param.error.message=="ban_word")then--//敏感词
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_ban_word_1004"));
            elseif(_param.error.message=="string_illegal")then
                WindowControler:showTips(GameConfig.getLanguage("chat_illegal_word_1005"));
            elseif(_param.error.message=="chat_times_max")then--//次数上限
                WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
            elseif(_param.error.message=="chat_in_cd")then
                WindowControler:showTips(GameConfig.getLanguage("chat_cool_down_1006"));
            elseif(_param.error.message=="ban_chat")then--//被禁言
                WindowControler:showTips(GameConfig.getLanguage("chat_extra_forbid_chat_1001"));
            else
                echo("--ChatMainView:sendWorldChat-",_param.error.message);
            end
    end
    ChatServer:chatSendLeague(_text,callback)
end

function ChatMainView:clickSendteeamMessage()
        -- echo("===========队伍数据==============")

        local _text = self.mc_6:getViewByFrame(1).input_1:getText()
        _text = FuncChat.ruleOutText(_text)
        local  _size=string.len(_text);
        local  _other_size=string.len4cn2(_text);
        if(_other_size<=0)then--//字数过少
            WindowControler:showTips(GameConfig.getLanguage("chat_words_too_little_1002"));
            return;
        end
--//字数过多
        if(_other_size>100)then
           WindowControler:showTips(GameConfig.getLanguage("chat_words_too_long_1003"));
           return;
        end
              local isbadword,_text = Tool:checkIsBadWords(_text)
        if isbadword == true then
            _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
            WindowControler:showTips(_tipMessage);
        else
            self.mc_6:getViewByFrame(1).input_1:setText("");
            self:clickButtonSendtreamMessage(_text);
        end
end
---发送队伍聊天
function  ChatMainView:clickButtonSendtreamMessage(_text)

    echo("===========队伍聊天数据==============")
    local chattematype = ChatModel:gettematype()
    if chattematype == FuncChat.CHAT_TYPE.TRIAL then
        local params = {}
        params.battleId = TeamFormationMultiModel:getRoomId()
        params.type = 2
        params.content = _text
        TeamFormationServer:doFormationChat(params,function () end)
    elseif chattematype == FuncChat.CHAT_TYPE.GUILD then
        -- local teamId = 
        -- local guildId = 
        -- local param = {
        --   guildId = params.guildId,
        --   content = _text,
        --   teamId = teamId,
        --   type = 2,
        -- }
        --参数是(1,语音；2，文字;3,预设消息)
        local pase = {
            content = _text,
            type = 2,
        }
        ChatServer:sendTeamMessage(pase)

    elseif chattematype == FuncChat.CHAT_TYPE.GUILDBOSSGVE then
        local params = {}
        params.battleId = GuildBossModel:getGuildBossBattleId()
        params.type = 2
        params.content = _text
        TeamFormationServer:doFormationChat(params)
    end
end

--//发送私人聊天事件
function ChatMainView:clickButtonSendPrivateMessage()
    local    _text = self.mc_6:getViewByFrame(1).input_1:getText()
    local  bad;

    _text = FuncChat.ruleOutText(_text)

      local    _size=string.len(_text);
      self.mc_6:getViewByFrame(1).input_1:setText("");

--//字数显示
    if(_size<=0)then
        WindowControler:showTips(GameConfig.getLanguage("chat_words_too_little_1002"));
        return;
    end
    if(_size>600)then
        WindowControler:showTips(GameConfig.getLanguage("chat_words_too_long_1003"));
        return;
    end

--//发送聊天协议
    
    local isbadword,_text = Tool:checkIsBadWords(_text)
    if isbadword == true then
        _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
        WindowControler:showTips(_tipMessage);
    else   
        self:requestPrivateMessage(_text,self.targetPlayer.rid);
    end
      
end
--//聊天协议
function ChatMainView:requestPrivateMessage(_text,_rid)
        local function callback(param)
        -- dump(param,"聊天数据")
            if(param.result~=nil)then--//没有其他操作
                if param.result.data ~= nil then
                    if param.result.data.online ~= nil then
                        if param.result.data.online == false then
                            WindowControler:showTips(GameConfig.getLanguage("chat_chat_target_offline_1011"));
                        end
                    end
                end
            elseif(param.error.message=="string_illegal")then
                    WindowControler:showTips(GameConfig.getLanguage("chat_illegal_word_1005"));
            elseif(param.error.message=="ban_word")then--//敏感词
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_ban_word_1004"));
            elseif(param.error.message=="ban_chat")then--//被禁言
                    WindowControler:showTips(GameConfig.getLanguage("chat_extra_forbid_chat_1001"));
            else
                    echo("---ChatMainView:requestPrivateMessage--",param.error.message);
            end
        end
        local  _param={};
        _param.type = 1
        _param.target=_rid;
        _param.content=_text;
        ChatServer:sendPrivateMessage(_param,callback);


end

function ChatMainView:addFriendButton()---添加好友按钮
    
    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.FRIEND)
    if not isopen then
        return 
    end
    if self.targetPlayer.isRobot then
        WindowControler:showTips(GameConfig.getLanguage("#tid_chat_011"))
        return 
    end

    local _param = { };
    local one = string.find(self.targetPlayer.rid,"_")
    if one then
        local _id =  string.sub(self.targetPlayer.rid, one + 1, -1)
        local sce = string.sub(self.targetPlayer.rid,1, one-1)
        -- self.params.sec or ServiceData.Sec
        -- echo("=====sce====_id=========",sce,_id)
        local friendlist = FriendModel:getFriendList()
        -- dump(friendlist,"111111111111111111111111111111111111111111111111111111")
        local seavefriend = false
        for k,v in pairs(friendlist) do
            if v._id == self.targetPlayer.rid then
                seavefriend = true
            end
        end
        if seavefriend == false then
            local _param = {}
            _param.ridInfos = {}
            _param.ridInfos[1] = {[tostring(sce)] = self.targetPlayer.rid}
            FriendServer:sendapplyFriend(_param,self.targetPlayer.rid)
        else
            self:VisibleinFalse()
            WindowControler:showTips(GameConfig.getLanguage("#tid_chat_012"))
        end
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_chat_011"))
    end
end

---删除聊天内的临时聊天玩家
function ChatMainView:DeleteFriendChat(_item)
    -- dump(_item,"删除的数据")
    -- self.temporaryfriend
    self:setUIShow()
    -- self.mc_scroll:getViewByFrame(1).scroll_1:clearCacheView( )
    -- dump(self.temporaryfriend,"66666666666666")
    self.mc_scroll:getViewByFrame(1).scroll_1:clearOneView(_item);
    table.remove(self.temporaryfriend, _item.index);
    -- dump(self.temporaryfriend,"66666666666666")
    local inde = 1

    local alldata = {}
    for k,v in pairs(self.temporaryfriend) do
        v.index = inde
        alldata[inde] = v
        inde = inde  + 1
    end
    -- dump(alldata,"===========================")
    ChatModel:removefastPrivateMap(_item.rid)
    ChatModel:setPrivateMessageFriend(alldata)
    self:clickButtonPrivate()
end



---[[
--//发送聊天信息
function  ChatMainView:clickButtonSendWorldMessage()

--//如果仍处于冷却中
        if(self.flagButtonGray)then
             WindowControler:showTips(GameConfig.getLanguage("#tid_chat_013"))--GameConfig.getLanguage("chat_cool_down_1007"));
             return;
        end

        local  bad;
        local _text = self.mc_6:getViewByFrame(1).input_1:getText()
        -- _text = FuncChat.ruleOutText(_text)

      -- local isbadword,_text = Tool:checkIsBadWords(_text)
        echo("========_text========",isbadword,_text)
        --//发言次数判断
        local   _ramind_chat_count=ChatModel:getFreeOfChatCount();
        if(_ramind_chat_count<=0)then
            -- WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
        	if ChatModel:getRMBOfChatCount() <= 0 then
        		WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
        		self.mc_6:getViewByFrame(1).input_1:setText("");
        		return
        	else
        		if UserModel:getGold() < ChatModel:getChatCost()  then
        			WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"));
        			self.mc_6:getViewByFrame(1).input_1:setText("");
        			return
        		end
        	end
        end

        local  _size=string.len(_text);
        -- echo("===========_size===========================",_size)
        local  _other_size=string.len4cn2(_text);
         --      local  _other_size=string.len(_other_text);
        if(_other_size<=0)then--//字数过少
            WindowControler:showTips(GameConfig.getLanguage("chat_words_too_little_1002"));
            return;
        end
        --//字数过多
        if(_other_size>100)then
            WindowControler:showTips(GameConfig.getLanguage("chat_words_too_long_1003"));
            return;
        end



        -- local isbadword,_text = Tool:checkIsBadWords(_text)
        -- echo("========_text========",isbadword,_text)
        if isbadword == true then
            echoError("=====================",GameConfig.getLanguage("tid_friend_ban_word_1004"))
            _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
            WindowControler:showTips(_tipMessage);
        else   
        	self.mc_6:getViewByFrame(1).input_1:setText("");
            self:sendWorldChat(_text);
        end
end

--//发送世界聊天信息
function  ChatMainView:sendWorldChat(_text)
      local    function  _delayCall()
        FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
        FilterTools.clearFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
        self.flagButtonGray=nil;


        local   _ramind_chat_count=ChatModel:getFreeOfChatCount();
        if(_ramind_chat_count > 0)then
            self.mc_6:getViewByFrame(1).mc_1:showFrame(1)
            self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.SendinputTextButton,self))
        else


            local costNum = ChatModel:getRMBOfChatCount()
            if costNum > 0 then
                self.mc_6:getViewByFrame(1).mc_1:showFrame(2)
                self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.SendinputTextButton,self))
                self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:getUpPanel().txt_2:setString(ChatModel:getChatCost())
            else
                self.mc_6:getViewByFrame(1).mc_1:showFrame(1)
                FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
                FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);

                self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.costRMBNotCount,self))
                self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.costRMBNotCount,self))

            end
        end

      end
      local function callback(_param)
                if(_param.result~=nil)then--//发言成功后需要置灰冷却发送信息按钮
 
				    ChatModel.worldChatCD = TimeControler:getServerTime()
                    FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1);
                    FilterTools.setGrayFilter(self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1);
                    self.flagButtonGray=true;
                    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.coolingTo,self))
                    self.mc_6:getViewByFrame(1).mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.coolingTo,self))


                    self:delayCall(_delayCall,cdTime);
                elseif(_param.error.message=="ban_word")then--//敏感词
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_ban_word_1004"));
                elseif(_param.error.message=="string_illegal")then
                    WindowControler:showTips(GameConfig.getLanguage("chat_illegal_word_1005"));
                elseif(_param.error.message=="chat_times_max")then--//次数上限
                    WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
                elseif(_param.error.message=="chat_in_cd")then
                    WindowControler:showTips(GameConfig.getLanguage("chat_cool_down_1006"));
                elseif(_param.error.message=="ban_chat")then--//被禁言
                    WindowControler:showTips(GameConfig.getLanguage("chat_extra_forbid_chat_1001"));
                else
                            echo("--ChatMainView:sendWorldChat-",_param.error.message);
                end
      end
      self.lastWorldChatContent=_text;
      local  param={};

      param.content= _text; --{_text};
      param.type = 1
      -- WindowControler:showTips(GameConfig.getLanguage("#tid_Talk_101"))
      ChatServer:sendWorldMessage(param,callback);
      -- ChatServer:sendvoiceServer(1)
end
--冷却中
function ChatMainView:coolingTo()
    WindowControler:showTips(GameConfig.getLanguage("chat_cool_down_1006"))
end
--//设置世界聊天界面
function ChatMainView:setWorldChat()

end

--//辅助函数,格式化时间
function  FormatChatTime(_time)
    -- echo("_time ===============",_time)
       local    _format;
       _format=os.date("%X",_time)--//string.format("%02d:%02d",math.floor(_time/3600),math.floor(_time%3600/60));
       local timeData = os.date("*t",_time)
       return _format  --timeData.month.."-"..timeData.day.." ".._format;
end



--//分享战斗情况
function ChatMainView:updateBattleInfoCell(_item,_item)

end
---退出
function ChatMainView:closeChat()
      -- ChatModel:clearPrivateQueue();
      local function _closeCallback()
            -- ChatModel:setSelectType(self.chatType)
            -- self:Savedatalocal()
            
            -- self:delayCall(function ()
            --     EventControler:dispatchEvent("Chat_Server_land_data")
            -- end,0.5)
            ChatModel:setPrivateTargetPlayer(nil);
            self:removeUI();
      end
      local  _rect=self._root:getContainerBox();
       local  _mAction=cc.MoveBy:create(0.2,cc.p(-_rect.width,0));
       local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(_closeCallback));
       self._root:runAction(_mSeq);

end 
function ChatMainView:Savedatalocal()  ---本地数据保存
  local world =  ChatModel:getWorldMessage()
  local League = ChatModel:getLeagueMessage()
  local Private =ChatModel:getPrivateMessage()
  -- dump(Private,"2222222222222222222")
  -- LS:pub():get("worldchatdata",nil)
  -- LS:pub():set("worldchatdata",world)
  local typedata = ChatModel:getchatStract()
  local data = {
    [1] = world,
    [2] = League,
    [3] = Private,
    [4] = world,
    [5] = world,
  }
   LS:pub():set("userID",UserModel:rid())
  for i=1,#typedata do
    if i <= 3 then
      local value = typedata[i]
      echo("========value===========",value)
      if data[i] ~= nil then
        -- if #data[i] >= ChatModel:getSeavDatanumber() then
          -- local number = #data[i] - ChatModel:getSeavDatanumber()
          -- for _i=1,number do
            -- table.remove(data[i],1)
          -- end
        -- end
        -- if data[i] ~= 0 then
          LS:pub():set(UserModel:rid()..value,json.encode(data[i]))
        -- end
      end
    end
  end

end

----显示图片试图
function ChatMainView:setIconView()
    -- self:addIcon()
    -- self.panel_biaoqing:setVisible(true)
    local callback = function ( name )
        echo("===============name==================",name)
        local    _text = self.mc_6:getViewByFrame(1).input_1:getText()
        _text = FuncChat.ruleOutText(_text)
        local    _size=string.len(_text);
        if _size > 0 then
            _text = _text..name
        else
            _text = name
        end
        self.mc_6:getViewByFrame(1).input_1:setText(_text);
        self.ctn_press:removeAllChildren()
        self.FriendEmailview = nil
    end
    if self.FriendEmailview == nil then
        self.FriendEmailview =  WindowControler:createWindowNode("ChatExpression")
        self.FriendEmailview:callbackiconname(callback)
        self.FriendEmailview:setPosition(cc.p(-245,-270))
        self.ctn_press:addChild(self.FriendEmailview)
    else
        self.ctn_press:removeAllChildren()
        self.FriendEmailview = nil
    end

end



return ChatMainView 
-- endregion
