
local FriendViewControler = class("FriendViewControler");

function FriendViewControler:ctor()

end

function FriendViewControler:showView()
--//检查等级限制
    local _open,_level = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FRIEND);
    local _user_level = UserModel:level();
    if(_user_level<_level)then
      WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
      return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            local data = _param.result.data
            FriendModel:setFriendList(data.friendList);
            FriendModel:setFriendCount(data.count);
            WindowControler:showWindow("FriendMainView",data,1);
        else
            echo("---get friend list error--", _param.error.code, _param.error.message);
        end
    end
    -- if(FriendModel:isFriendApply())then
    --     local _friendUI=WindowControler:showWindow("FriendMainView",nil,3);

    local param3 = { };
    param3.page = 1;
    FriendServer:getFriendListByPage(param3, _callback);
end

function FriendViewControler:forceShowFriendList(_type,table,todotype)
    local  sharedata = nil
    if _type ~= nil then
      sharedata = {
          _type = _type,
          data = table,
      } 
    end
    local index = 1
    if todotype ~= nil then
      index = todotype
    end
    local   _open,_level=FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FRIEND);
    local  _user_level=UserModel:level();
    if(_user_level<_level)then
             WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
             return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            local _friendUI = WindowControler:showWindow("FriendMainView",_param.result.data,index,sharedata);
        else
            echo("---get friend list error--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.page = 1;
    FriendServer:getFriendListByPage(param, _callback);
end

--//打开好友详情页面,传入玩家的role id
function FriendViewControler:showPlayer(_playerId, playerInfo)
    local function _callback(param)
            if(param.result~=nil)then
--//必须满足等级要求
                 local   _fdetail=param.result.data.data[1];

                 -- dump(_fdetail, "---_fdetail---");
                 local   _playerUI=WindowControler:showWindow("CompPlayerDetailView",_fdetail,nil,3);
            end
    end
    local  _param={};
    _param.rids={};
    _param.rids[1]=_playerId;
    if playerInfo ~= nil then
        -- WindowControler:showWindow("CompPlayerDetailView", playerInfo, nil, 3);
        -- return 
    end

    if playerInfo.isRobot == true then 
      WindowControler:showWindow("CompPlayerDetailView", playerInfo, nil, 3);
    else 
      ChatServer:queryPlayerInfo(_param,_callback);
    end 
end
--//
return FriendViewControler;











