--
-- Author: xd
-- Date: 2015-11-28 14:38:15
--主要是用来一些通知事件  格式  methodcode = 事件name 收到通知的时候 会发送一个消息出去  
local NotifyEvent = {
	["340"] = "notify_trot_lamp_340",						--//系统公告消息推送

	["704"] = "notify_battle_userJoinRoom_704", 			--战斗 玩家加入房间
	["708"] = "notify_battle_start_708",					--战斗开始 
	["710"] = "notify_battle_pushTimeLine_710",			--战斗 服务器拉取时间片
	["716"] = "notify_battle_useTreasure_716" , 			--战斗 广播 使用法宝
	["724"] = "notify_battle_useAutoFight_724" , 			--战斗 自动战斗
	["720"] = "notify_battle_gameResult_720",				--战斗广播结果
	["732"] = "notify_battle_userQuitRoom_732",			--战斗 玩家退出房间
	["736"] = "notify_battle_loadBattleResOver_736",		--战斗 加载战斗资源完成，开始战斗
	["740"] = "notify_battle_userDrop_740",				--战斗 玩家掉线(暂离)
	["744"] = "notify_battle_addOnePlayer_744",			--战斗 加入新玩家
	["748"] = "notify_battle_addToBattle_748",			--战斗 玩家中途加入
	["756"] = "notify_battle_user_quit_battle_756",		--战斗 玩家离开,不玩了
	["760"] = "notify_battle_someOne_hasReady_760",		--战斗 玩家中途加入

	["5008"]= "notify_battle_formationComp_5008", 		--布阵完毕
	["5016"]= "notify_battle_formation_update_5016",  	--多人布阵阵容发生改变
	["5034"]= "notify_battle_loadingRes_timeOut_5034",    --多人布阵loading超时
	["5036"]= "notify_battle_battleStart_5036", 		--收到战斗开始通知所有人资源加载完毕
	["5040"]= "notify_battle_recevieHandle_5040", 		--战斗中收到操作信息
	["5922"]= "notify_battle_crossPeak_battleResult_5922", 		--巅峰竞技场战斗结果推送
	["5048"]= "notify_battle_recevieHBattleResult_5048", 		--收到战斗结果的通知
	["5052"]= "notify_battle_player_level_5052", 			--多人布阵玩家离开
	["5012"]= "nofify_battle_multi_lockstate_changed_5012",  --多人布阵玩家阵型发生改变消息通知
	["5020"]= "nofify_battle_multi_chat_msg_5020", 			--多人布阵中收到的聊天信息
	["5060"]= "notify_battle_player_BuZhen_5060",			--在布阵界面退出

	["906"] = "notify_match_intive_906",					--邀请加入系统匹配
	["908"] = "notify_match_timeout_908",					--匹配超时失败
	
	["1116"] = "notify_pvp_new_fight_resport_1116",		--竞技场有新的战报

	["1208"] = "notify_world_gve_match_battle_end_1208",	--六界GVE战斗结束
	["1506"] = "notify_mail_receive_1506",				--收到邮件

	-- [1806] = "notify_trial_match_end_1806",      --试炼匹配结束
	["1810"] = "notify_trial_match_battle_end_1810",      --试炼战斗结束
	["1814"] = "notify_trial_add_team_1814",      --试炼战斗结束
	["5004"] = "notify_trial_Doing_Array_5004",      --试炼布阵

    ["2924"] = "notify_friend_apply_request_2924",		--收到其他玩家申请加好友的请求
    ["2926"] ="notify_friend_send_sp_2926",           	--收到好友赠送的体力
   	["2928"] ="notify_friend_Agreed_2928",           		--同意加为好友推送


    ["3512"] = "notify_chat_world_3512",					--//聊天系统,世界聊天消息推送
    ["3514"] = "notify_chat_league_3514",					--//聊天系统,仙盟聊天消息推送
    ["3516"] = "notify_chat_private_3516",					--//私聊消息推送
    ["3520"] = "notify_chat_system_3520",					--- 系统消息推送
    ["3528"] = "notify_chat_love_3528" ,                    --缘伴消息推送

    ["4720"] = "notify_mu_formation_start_battle_4720",		--多人布阵开始战斗
    ["4712"] = "notify_mu_formation_update_formation_4712",	--多人布阵真行信息发生改变   拿到这个信息，直接更新信息，客户端人物这个真行信息就是当前的最新阵型
    ["2932"] = "notify_friend_tihuan_server_2932",           ----好友替换服务器
    
    ["1328"] = "notify_guild_app_1328",					--- 公会邀请，其他玩家收到 信息，展示列表
    ["1330"] = "notify_guild_add_1330",					--- 加入，其他玩家收到 信息，展示列表
    ["1356"] = "notify_guild_remove_player_1356",			-- 剔除仙盟玩家
    ["1358"] = "notify_guild_reject_1358",    			-- 拒绝玩家
    ["1378"] = "notify_guild_beapp_1378",             -- 被邀请玩家

    ["5096"] = "notify_battleCheck_info",               --收到服务器推送的战斗校验信息
    ["5604"] = "notify_guild_activity_champions_open_act_5604",-- 开启gve活动
    ["5612"] = "notify_guild_activity_teamMemer_changed_5612",-- 队内成员发生变化
    ["5620"] = "notify_guild_activity_beinginvited_5620",-- 某人被邀请

    ["5624"] = "notify_guild_activity_start_challenge_5624",-- 队伍开始挑战
    ["5628"] = "notify_guild_activity_quit_challenge_5628",-- 队伍退出挑战
    ["5632"] = "notify_guild_activity_mark_monster_5632",-- 标记怪物
    ["5636"] = "notify_guild_activity_unmark_monster_5636",-- 取消标记怪物
    ["5640"] = "notify_guild_activity_defeat_monster_5640",-- 打败怪物
    ["5644"] = "notify_guild_activity_round_account_5644",-- 战斗结算 新的一轮
    ["5646"] = "notify_guild_activity_last_round_account_5646",-- 战斗结算 最后一轮，包括发奖励的结算
    ["5656"] = "notify_guild_activity_someone_put_ingredients_5656",-- 某玩家向仙盟大锅中投入了食材
    ["5662"] = "notify_guild_activity_be_kickout_5662",-- 某玩家向仙盟大锅中投入了食材
    ["5660"] = "notify_guild_activity_chat_5660", -- 仙盟gve聊天
    ["5666"] = "notify_guild_activity_sync_player_pos_5666", -- 同步玩家走动坐标
    ["5670"] = "notify_guild_activity_start_count_down_5670", -- 开始一轮倒计时


    ["398"] = "notify_sys_GM_push",			--收到GM主动push消息

    ["5918"] = "notify_crosspeak_match_quxiao_5918",-- 巅峰竞技场 匹配取消
    ["5920"] = "notify_crosspeak_match_failed_5920",-- 巅峰竞技场 匹配失败
    ["5522"] = "notify_mission_quest_enter_body_5522", --进入答题 服务器主动推送给房间里的其他人
    ["5524"] = "notify_mission_quest_quit_body_5524", --退出答题 服务器主动推送给房间里的其他人
    ["5526"] = "notify_mission_quest_answer_body_5526", --答题广播 服务器主动推送给房间里的其他人


    ["6210"] = "notify_guildBoss_open_one_ectype_6210", -- 开启一个仙盟副本
    ["5098"] = "notify_battle_check_error",			--战斗校验错误

    ["7002"] = "notify_crosspeak_match_success" ,   --巅峰竞技场普配成功

    ["battle.pushBattleOperation"] = "notify_crosspeak_battleOperation", --仙界对决战斗操作消息推送
    
    ["debug.push1"] = "notify_debug_command", --测试的指令处理

    ["6212"] = "notify_guildBoss_HP_6212",            -- 仙盟Boss血量同步
    ["6410"] = "notify_guild_red_packet_6410", -- 发红包推送


    ["6906"] = "notify_yuanban_addRomm",         --进入缘伴房间推送
    ["6908"] = "notify_yuanban_leaRoom",         --退出缘伴房间推送
    ["6910"] = "notify_yuanban_sysRoomMsg",         --缘伴房间系统推送

    ["5408"] = "notify_shareBoss_data_changed_5408",   --幻境协战推送

    ["6230"] = "notify_guildBoss_invite_team_6230",  --共闯秘境邀请推送
    ["6232"] = "notify_guildBoss_add_team_6232",  ---仙盟Boss加入队伍推送
    ["6234"] = "notify_guildBoss_remove_team_6234",  ---仙盟Boss离开队伍推送
    ["6236"] = "notify_guildBoss_add_team_6236",  ---仙盟Boss踢出队伍推送
    ["6240"]= "notify_battle_guildBoss_battleResult_6240",      --共闯秘境Gve结果推送

    ["2210"] = "notify_sdk_charge_2210",         --sdk支付回调

    ["3532"] = "notify_shore_World_3532",         --分享法宝和神器的推送


    ["map.enterMap"] = "notify_explore_map_enterMap",      --有角色进入场景
    ["map.leaveMap"] = "notify_explore_map_leaveMap",      --有角色退出场景
    ["map.pushMove"] = "notify_explore_map_pushMove",      --有角色退出场景
    ["map.eventChange"] = "notify_explore_map_eventChange",   --地图事件的visible变化
    ["map.pushEvent"] = "notify_explore_map_pushEvent",   --地图事件的推送
    ["task.pushProcess"] = "notify_explore_task_pushProcess",   --任务事件的推送


    ["role.offlineReward"] = "notify_explore_role_offlineReward",  --离线数据奖励
    ["role.pushRelease"] = "notify_explore_map_role_pushRelease"  --收到主动断开连接请求

}


return NotifyEvent

