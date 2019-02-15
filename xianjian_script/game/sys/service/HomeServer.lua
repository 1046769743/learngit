--
-- Author: guanfeng
-- Date: 2016-1-06
--
--家园人物进出

local HomeServer = class("HomeServer")

function HomeServer:init()
	echo("HomeServer:init");
	EventControler:addEventListener(HomeEvent.GET_ONLINE_PLAYER_EVENT,
		self.checkOnlinePlayer, self);

	EventControler:addEventListener(HomeEvent.GET_ONLINE_PLAYER_EVENT_AGAIN,
		self.checkOnlinePlayerAgain, self);
end

function HomeServer:checkOnlinePlayer()
	local params = {
		rids = nil,
		limit = 20,
	};

	if Server._isClose == true then 
		return;
	end

	--如果已经存储这个请求了 不执行 
	if Server:checkHasMethod(MethodCode.user_getOnlinePlayer_319) then
		return
	end

	Server:sendRequest(params, MethodCode.user_getOnlinePlayer_319,
		c_func(HomeServer.checkOnlinePlayerCallBack, self), false, true);
end

function HomeServer:checkOnlinePlayerCallBack(event)
	if event.error ~= nil then
		return 
	end
	if event.result ~= nil then
		--发事件
		EventControler:dispatchEvent(HomeEvent.GET_ONLINE_PLAYER_OK_EVENT, 
	    		{onLines = event.result.data.onlines});
	end
end

function HomeServer:checkOnlinePlayerAgain(data)
	-- dump(data.params.rids, "HomeServer:checkOnlinePlayerAgain")

	local params = {
		rids = data.params.rids,
		limit = 20,
	};
	
	if Server._isClose == true then 
		return;
	end

	Server:sendRequest(params, MethodCode.user_getOnlinePlayer_319,
		c_func(HomeServer.checkOnlinePlayerAgainCallBack, self), false, true);
end

function HomeServer:checkOnlinePlayerAgainCallBack(event)
	-- dump(event, "__checkOnlinePlayerCallBack__");
	if event.error ~= nil then
		return 
	end
	if event.result ~= nil then
		--发事件
	    EventControler:dispatchEvent(HomeEvent.GET_ONLINE_PLAYER_EVENT_OK_AGAIN, 
	    	{onLines = event.result.data.onlines});
	end
end

--获得最屌玩家
function HomeServer:getDiaoestPlayer(callBack)
	echo(" getDiaoestPlayer ");
	local params = {

	}
	Server:sendRequest(params, MethodCode.home_getBest_3401, callBack)
end

function HomeServer:worship(typeworship,callBack)
	echo(" worship " , tostring(typeworship));
	local params = {
		type = typeworship,
	}
	Server:sendRequest(params, MethodCode.home_worship_3403, callBack)
end

-- 获取问卷调查网址
function HomeServer:getQuestionnaireUrl(callBack)
	local params = {
		type = typeworship,
	}
	Server:sendRequest(params, MethodCode.questionnaire_get_url_7101, callBack,false,false,true)
end

HomeServer:init();

return HomeServer












