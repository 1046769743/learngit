--
-- Author: ZhangYanguang
-- Date: 2015-12-16
--
--用户模块，网络服务类

local UserServer = class("UserServer")
--//购买铜钱/金币
function      UserServer:buyCoin( _param,_callback  )
	local Coindata = UserModel:getBenDataCoinAndPs(1,_param.times)
    Server:sendRequest(_param,MethodCode.user_buyCoin_331,_callback)--,nil,true,true);
         
end
-- 购买体力
function UserServer:buySp(callBack)
	local params = {}
	local Coindata = UserModel:getBenDataCoinAndPs(2)
	Server:sendRequest(params, MethodCode.user_buySp_305, callBack)
end 

--灵力事件
function UserServer:MpEvent(callBack, isVip)
	local params = {
		vip = isVip
	};
	Server:sendRequest(params, MethodCode.user_getMp_311, callBack)
end

function UserServer:setHero(hid, name, callBack)
	local params = {avatar = hid, name = name};
	Server:sendRequest(params, MethodCode.user_set_avatar_323, callBack)
end

--初次设置
function UserServer:setRoleName(name, callBack)
	local params = {name = name}
	Server:sendRequest(params, MethodCode.user_set_role_name_325, callBack, nil, nil, true)
end

--更改名字
function UserServer:changeRoleName(name, freeType, callBack)
	local params = {name = name, isFree=freeType}
	Server:sendRequest(params, MethodCode.user_change_role_name_329, callBack, nil, nil, true)
end

-- 更换头像
function UserServer:changeUserHead(head,callBack)
    Server:sendRequest({value = head }, MethodCode.change_user_head_2805, callBack, nil, nil, true)
end
-- 更换头像框
function UserServer:changeUserHeadFram(fram,callBack)
    Server:sendRequest({value = fram }, MethodCode.change_user_head_kuang_2807, callBack, nil, nil, true)
end

function UserServer:checkRoleName(name, callBack)
	local params ={name = name}
	Server:sendRequest(params, MethodCode.user_check_role_name_327, callBack, nil, nil, true)
end

function UserServer:exchangeCdkey(code, callBack)
	local params = {code = code, channel = UserModel:getChannelName()}
	Server:sendRequest(params, MethodCode.cdkey_exchange_2701, callBack)
end

function UserServer:exchangePassCode(passcode, callBack)
	local params = {passcode = passcode}
	Server:sendRequest(params, MethodCode.passCode_exchange_2703, callBack)
end

return UserServer
