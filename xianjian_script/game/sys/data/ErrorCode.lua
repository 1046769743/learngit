--
-- Author: xd
-- Date: 2015-12-02 10:31:12
--主要记录一些需要特殊处理的code
--
ErrorCode = {
	sec_maintain = 10053, 	--服务器维护
	sec_close = 10054, 		--服务器关闭
	kickouted_by_server = 999721, 	--被服务器踢下线
	kakura_getCacheError =999713 , --拿缓存失败
	kakura_needClientUpdate = 999726,		--有版本更新 取消了NotifyEvent.notifyUpdateClientCode这个变量
	kakura_server_error = 999723,	--kakura与php服务器之间通信的各种异常
	duplicate_login=999722,			--被挤掉线
	need_client_relogin=999724,			--需要客户端重新登入
	other_client_response=999725,			--需要客户端重新登入
	kaura_getResponceError = 999716, --拿缓存请求失败
	lua_runtime_error = 10061 , 	--战斗服务器故障
	user_need_queue_time = 10089,   --登录排队等待
	logintoken_expire = 19001, 		--token错误 请重新登入
	sec_no_open = 10072 ,			--暂未开服
	sys_error = 99999999,			--系统错误
	account_forbided = 10006,		--账号被封禁
	sys_overTime_error = 9999998,	--战斗服连不上
	battle_not_exisit = 505501, 	--战斗不存在
	battle_open_speed = 594102,		--玩家开了加速器
	
	battle_server_error = 10061,   	-- 战斗服故障
	battle_result_error = 10062,   	-- 战斗服结果错误
	battle_star_error = 10063 ,		--战斗星级错误
	-- battle_is_finished = 71703, --战斗已经结束

	-- realtimeserver
	battle_id_illegal = 1001 ,	--战场ID不合法
	battle_finished = 1002,		--战斗已经结束
	battle_player_not_bout = 1003,	--不属于该玩家回合
	battle_result_client_error = 1004 ,	--战斗结束result信息错误
	battle_lose = 1005 ,	--战斗结束result信息错误

	explore_isFast = 760156,		--移动速度过快 
	explore_notInOpen = 760158,		--不在开启时间----

}

--不需要弹errorTips 的code数组
NoErrorTipsCode = {
	5107, -- 情缘布阵错误，布阵正在改版，不满足需求的布阵返回错误信息
			-- 给用户相应提醒即可，暂时不弹窗	
	1303,
	1307, --异常处理仙盟清退报错
	5519, --答题间隔小于5秒
	270109, --cdkey  tips特殊处理
	650302, --开服抢购 售罄提示
	5001,--战斗已经结束key:71703 请求
	1005, --共闯秘境切换后台后报错
	10006,--账号封禁
	}





return ErrorCode
