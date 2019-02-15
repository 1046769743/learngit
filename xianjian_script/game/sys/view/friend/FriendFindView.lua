
local FriendFindView = class("FriendFindView", UIBase);

function FriendFindView:ctor(_winName,_self)
    FriendFindView.super.ctor(self, _winName);
    -- self.newobject = _self
end
function FriendFindView:loadUIComplete()
	
    
    self:registerEvent()
    self.UI_1.btn_close:setTap(c_func(self.clickButtonClose,self));

end

function FriendFindView:registerEvent()
	FriendFindView.super.registerEvent(self);
    -- self:registClickClose(nil, c_func( function()
    --         self:clickButtonClose()
    -- end , self))
    self:registClickClose("out")

		-- self:sendServerdata()
        -- dump(LoginControler:getServerId(),"111111")
    local serverId = LoginControler:getServerId()--LoginControler:getServerName()
    local sname = self:getservername(serverId)
    -- self.panel_1.input_1:setText(LoginControler:getServerMark())
    -- self.panel_2.input_1:setText("点击输入")
    self.panel_1.input_1:set_defaultstr(LoginControler:getServerMark())
    self.panel_1.input_1:initDefaultText()
    
    self.UI_1.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.FindFirednData,self));
    self.UI_1.mc_1:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_friend_004"))
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_friend_005")) 
    
end
function FriendFindView:getservername(serverId)
    local serverlist =  LoginControler:getServerList()
    for k,v in pairs(serverlist) do
        if v._id == serverId then
            return v.name
        end
    end
end
function FriendFindView:FindFirednData()
    local Text1 = self.panel_1.input_1:getText()
    local Text2 = self.panel_2.input_1:getText()

    echo("========Text1=========Text2=============",Text1,Text2)    


    self:sendServerData(Text1,Text2)

    
end
local function CheckContainSpecialChar(_tex)
    local _special="`~!@#$%^&*().   ,./'\"\\|{}[]-_+="
    local _size=string.len(_tex)
    for _index=1,_size do
            local _char=string.sub(_tex,_index,_index)
            local _start=string.find(_special,_char)
            if(_start~=nil)then
                return true;
            end
    end
    return false
end
function FriendFindView:getServerID( serverid )
    echo("===========serverid======",serverid)
    local serverlist =  LoginControler:getServerList()
    -- dump(serverlist,"222222222",9)
    for k,v in pairs(serverlist) do
        -- echo("====v.mark=======serverid====",v.mark,serverid)
        if v.mark == serverid then
            return v._id
        end
    end
    return LoginControler:getServerId()
end
function FriendFindView:sendServerData(Text1,Text2)
    Text1 = self:getServerID(Text1)
    echo("=========服务器名称=======",Text1)
    if self:findServerIsSevar(Text1) == false then
        WindowControler:showTips(GameConfig.getLanguage("#tid_friend_006"))
        return; 
    end
    if(CheckContainSpecialChar(Text1)) or (CheckContainSpecialChar(Text2)) then
         WindowControler:showTips(GameConfig.getLanguage("friend_extra_can_not_blank"))
         return ;
    end
    if (string.len(Text1) <= 0) or (string.len(Text2) <= 0) then
        -- //搜索内容不能为空
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_research_can_not_empty_1028"));
        return;
    end
    if string.len(Text2) < 4 then
        WindowControler:showTips(GameConfig.getLanguage("tid_login_1017"));
        return 
    end
    local _userName = UserModel:name();
    local _uidMask=tostring(UserModel:uidMark())
    if (Text2 == _userName and Text2==_uidMask) then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_can_not_research_self_1035"));
        return;
    end
    local function _callback(_param)
        dump(_param.result,"搜索",8)
        if (_param.result ~= nil) then
            if #_param.result.data.searchList ~= 0 then
   
                EventControler:dispatchEvent(FriendEvent.FRIEND_FINED_FRIEND,_param.result.data.searchList)
            else
                WindowControler:showTips(GameConfig.getLanguage("#tid_friend_007"));
            end
        elseif(_param.error.message=="string_length_limit")then
           WindowControler:showTips(GameConfig.getLanguage("tid_login_1017"));
        else
            echo("-----FriendMainView:clickButtonResearchFriend-----", _param.error.code, _param.error.message);
            WindowControler:showTips(GameConfig.getLanguage("friend_extra_can_not_blank"));
            -- //实际上是不会产生错误的,这里只是为了测试,但是还是产生了
        end
        self:startHide()
    end  
    local param = { };
--//如果是纯数字

    -- dump(ServiceData,"服务器数据")

    param.tsec = Text1--ServiceData.Sec
    param.name = Text2;
    -- local isbadword,_text = Tool:checkIsBadWords(Text2)
    -- -- dump(param,"f")
    -- if isbadword == true then
    --     _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
    --     WindowControler:showTips(_tipMessage);
    -- else
        FriendServer:getFriendSearchList(param, _callback);
    -- end
end
function FriendFindView:findServerIsSevar(Text1)
    local serverlist =  LoginControler:getServerList()
    for k,v in pairs(serverlist) do
        echo("=========v.mark============",v.mark,Text1)
        if v._id == Text1 then
            return true
        end
    end
    return false
end


function FriendFindView:clickButtonClose()
    self:startHide()
end
return FriendFindView
