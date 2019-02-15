--
-- Author: xd
-- Date: 2015-11-24 20:55:40
--
--
local MethodCode = {}

MethodCode.sys_heartBeat = "heartBeat" 			--请求心跳
MethodCode.sys_init = "init" 					--系统初始化

MethodCode.sys_reauth = "reauth" 				--重连接口
MethodCode.sys_sync_user_data_345 = 345 			--同步玩家数据
MethodCode.sys_updateUserState = 363  			--同步用户状态
--测试通信协议请求json串接口
MethodCode.test_getJsonDesc_100105 = 100105 	
MethodCode.test_getJsonDesc2_100103 = 100103 	

--用户相关模块
MethodCode.user_loginout_203 = 203 				--用户登出
MethodCode.user_login_205 = 205 				--用户登入
MethodCode.user_register_207 = 207 				--注册用户
MethodCode.user_serverList_211 = 211 			--服务器列表
MethodCode.user_sdk_login_213 = 213 			--most sdk登录接口
MethodCode.user_ourpalm_login_223 = 223 		--掌趣sdk登录接口

MethodCode.user_guest_login_217 = 217			--试玩登录
MethodCode.user_bind_account_219 = 219			--账号绑定
MethodCode.user_loginByUid	 = 221			--用指定的uid登入

MethodCode.user_getUserInfo_301 = 301 			--拉取用户信息
MethodCode.user_relogin_359 = 359 				--重新登入



MethodCode.user_buySp_305 = 305 				--购买体力
MethodCode.base_dataUpdate_308 = 308			--底层数据更新
MethodCode.user_getEventReward_309 = 309		--领取事件奖励
MethodCode.user_getMp_311 = 311					--领取法力
MethodCode.user_clearCD_313 = 313				--清空cd
MethodCode.user_state_315 = 315					--连接
MethodCode.user_updateTime_317 = 317					--主动同步服务器时间
MethodCode.user_set_avatar_323 = 323			--设置主角形象
MethodCode.user_set_role_name_325 = 325			--设置角色名字
MethodCode.user_check_role_name_327 = 327		--检查主角名字
MethodCode.user_change_role_name_329 = 329		--修改主角名字
MethodCode.user_resetUserStatus = 371 --重置用户在线状态

MethodCode.player_online_361 = 361   			--玩家是否在线 

--家园系统
MethodCode.user_getOnlinePlayer_319 = 319       --获取在线玩家
--购买铜钱/金币
MethodCode.user_buyCoin_331 = 331     --购买金币

MethodCode.get_recharge_reward_341=341    --领取首冲奖励

MethodCode.get_TILI_365 = 365 --领取体力


--法宝系统
MethodCode.treasure_upgradeLevel_401 = 401 		--法宝强化
MethodCode.treasure_upgradeStar_403 =403 		--法宝升星
MethodCode.treasure_upgradeState_405 =405 		--法宝进阶   
MethodCode.treasure_setFormula_407 =407 		--设置法宝阵型
MethodCode.treasure_combine_409 =409 		    --法宝合成

--战斗模块
MethodCode.battle_joinRoom_701 = 701 			--加入房间
MethodCode.battle_start_705 = 705 				--战斗开始
MethodCode.battle_receiveFragment_711 = 711 	--接收时间片
MethodCode.battle_releaseMagic_713 = 713 		--释放法宝
MethodCode.battle_reveiveBattleResult_717 = 717 		--战斗结果验证
MethodCode.battle_receiveCheatCase_725 = 725 			--客户端上报发现作弊

MethodCode.battle_user_quit_battle_753 = 753 	-- 玩家退出战斗

MethodCode.battle_treasure_on_5021 = 5021			--多人战斗法宝上阵下阵
MethodCode.battle_partner_on_5023 = 5023 			--多人战斗伙伴的上阵下阵
MethodCode.battle_lock_formation_5027 = 5027 		--多人布阵 锁定阵型
MethodCode.battle_formation_timeOut_5029 = 5029 	--多人布阵 布阵超时
MethodCode.battle_formation_level_5049 = 5049 		--多人布阵点击离开
MethodCode.battle_multi_chat_5025 = 5025      		--多人布阵中的聊天
MethodCode.battle_multi_lineUp_5053 = 5053          --多人布阵中的一键布阵
MethodCode.battle_multi_resume_5055 = 5055			--多人试炼后台切换回前台请求战斗进度

MethodCode.battle_throw = 5065			--巅峰竞技场认输
MethodCode.battle_get_operation = 5067 --获取操作序列


MethodCode.battle_loadBattleResOver_5031 = 5031 			--加载战斗资源完成


MethodCode.battle_handle_5037 = 5037 		--战斗中的操作
MethodCode.battle_sumbitResult_5045 = 5045 		--上报战斗结果


-- 背包模块
MethodCode.item_customItem_801 = 801 			--使用道具
MethodCode.item_buyKey_803 = 803 				--购买钥匙
MethodCode.item_piece_compose_805 = 805 		--道具碎片合成
MethodCode.item_buyCount_809 = 809 				-- 快捷购买次数
--匹配模块
-- MethodCode.match_battleStart_901 = 901 			--战斗开始匹配
-- MethodCode.match_joinIntive_903 = 903 			--战斗加入邀请


-- PVP模块
MethodCode.pvp_buyPVP_1101 = 1101             -- 购买pvp挑战次数
MethodCode.pvp_refreshPVP_1103 = 1103         -- 刷新pvp数据
MethodCode.pvp_startChallenge_1105 = 1105     -- pvp开始战斗
MethodCode.pvp_reportBattleResult_1107 = 1107 -- pvp上报战斗结果
MethodCode.pvp_pullBattleRecord_1109 = 1109   -- pvp拉取战斗记录
MethodCode.pvp_flushShop_1111 = 1111          -- 刷新pvp商店
MethodCode.pvp_shopBuyItem_1113 = 1113        -- pvp购买商店物品
MethodCode.pvp_recordTitle_1117 = 1117		  -- 记录已经获得的最大称号
MethodCode.pvp_player_detail_1119 = 1119   --查看角色详情
MethodCode.pvp_challenge_player_1121 = 1121 --竞技场挑战对手
MethodCode.pvp_challenge5_times_1123 = 1123 --挑战5次
MethodCode.pvp_get_pvp_report_1125 = 1125           --获取竞技场战报详情
MethodCode.pvp_rank_exchange_1127 = 1127            --竞技场排名兑换 
MethodCode.pvp_score_reward_1129 = 1129                 --竞技场积分奖励
MethodCode.pvp_rank_reward_1131 = 1131                --竞技场排名奖励

-- MethodCode.pve_upLoadStage_1201 = 1201 			--上传PVE章节完成状态
MethodCode.pve_enterMainStage_1201 = 1201 		--PVE进入副本
MethodCode.pve_reportBattleResult_1203 = 1203 	--PVE汇报战斗结果
MethodCode.pve_openStarBox_1209 = 1209 			--PVE打开星宝箱
MethodCode.pve_openExtraBox_1211 = 1211 		--打开额外宝箱,2018.2.24精英探索功能场景宝箱
MethodCode.pve_sweep_1213 = 1213				--PVE扫荡接口
MethodCode.pve_buy_challenge_times_1215 = 1215  --精英副本购买挑战次数

--公会
MethodCode.guild_create_1301 = 1301        --公会创建
MethodCode.guild_find_1303 = 1303          --查询公会
MethodCode.guild_list_1305 = 1305 		   --公会列表
MethodCode.guild_members_1307 = 1307 	   --公会成员
MethodCode.guild_apply_1309 = 1309 		   --申请加入公会
MethodCode.guild_apply_list_1311 = 1311    --公会申请列表
MethodCode.guild_apply_judge_1313 = 1313    --入会审批
MethodCode.guild_modify_info_1315 = 1315   --修改公会信息
MethodCode.guild_modify_member_right_1317 = 1317   --修改权限
MethodCode.guild_kick_member_1319 = 1319   --踢人
MethodCode.guild_quit_1321 = 1321   --退出公会
MethodCode.guild_cancel_apply_1323 = 1323  --取消申请
MethodCode.guild_invite_1325 = 1325  --公会邀请
MethodCode.guild_one_add_1367 = 1367  --一键加入
MethodCode.guild_impeachment_1375 = 1375  --弹劾

MethodCode.guild_sign_1331 = 1331    			-- //公会签到
MethodCode.guild_pray_rewawrd_1333 = 1333       --//领取祈福宝箱
MethodCode.guild_bonus_1335 = 1335     			--//领取红利	
MethodCode.guild_building_1337 = 1337     		--//建设
MethodCode.guild_building_vote_1339 = 1339      --//建设投票
MethodCode.guild_pray_1341 = 1341     			--//祈福
MethodCode.guild_donate_1343 = 1343     		--//捐献
MethodCode.guild_WishList_1345 = 1345     		--//公会心愿
MethodCode.guild_sendWish_1347 = 1347     		-- //发出心愿
MethodCode.guild_helpWish_1349 = 1349     		--//帮助心愿
MethodCode.guild_getEvent_1351 = 1351     		--//查看公会事件
MethodCode.guild_getWishEvent_1353 = 1353       -- //查看心愿事件

MethodCode.guild_exchanegReward_367 = 367			-- // 兑换宝箱	
MethodCode.guild_Rmb_exchanegReward_369 = 369			-- // 元宝兑换宝箱
MethodCode.guild_exchange_1359 = 1359  --公会兑换
MethodCode.guild_send_exchange_request_1361 = 1361  --发送兑换请求
MethodCode.guild_not_exchange_1363 = 1363  --取消兑换
MethodCode.guild_get_exchange_list_1365 = 1365  --兑换列表

MethodCode.guild_donateBox_1369 = 1369       	-- //缴纳玄盒
MethodCode.guild_skillGroupLevelUp_1371 = 1371  -- //精研
MethodCode.guild_skillLevelUp_1373 = 1373       -- //修炼


-- 仙盟GVE活动
MethodCode.guildAct_openActivity_5601 = 5601  -- 开启gve活动 
MethodCode.guildAct_getTeamList_5605 = 5605   -- 获取房间(队伍)列表  
MethodCode.guildAct_createTeam_5607 = 5607    -- 创建房间(队伍)
MethodCode.guildAct_joinTeam_5609 = 5609  	  -- 进入房间
MethodCode.guildAct_leaveTeam_5613 = 5613     -- 离开房间
MethodCode.guildAct_kickOutOnePerson_5615 = 5615  -- 踢人
MethodCode.guildAct_inviteAllies_5617 = 5617  -- 邀请盟友

MethodCode.guildAct_startChallenge_5621 = 5621  -- 队伍挑战开始
MethodCode.guildAct_quitChallenge_5625 = 5625   -- 队伍挑战结束
MethodCode.guildAct_markMonster_5629 = 5629     -- 标记怪
MethodCode.guildAct_markMonsterCancel_5633 = 5633  -- 取消标记怪
-- MethodCode.guildAct_beatMonster_5637 = 5637  -- 打包子，战斗请求
MethodCode.guildAct_settleOneRoundAccounts_5641 = 5641  -- 一轮战斗结算
MethodCode.guildAct_putInMaterials_5647 = 5647  -- 投入食材

MethodCode.guildAct_getAccumulateReward_5649 = 5649  -- 领取积分奖励
MethodCode.guildAct_putInMaterials_5651 = 5651  -- 获取邀请列表
MethodCode.guildAct_getGVEData_5653 = 5653  -- 获取gve信息
MethodCode.guildAct_sync_player_pos_5663 = 5663  -- 同步玩家坐标信息
MethodCode.guildAct_start_countDown_5667 = 5667  -- 开始新一轮倒计时

MethodCode.guildAct_beatMonster_5671 = 5671  -- 打包子战斗请求
MethodCode.guildAct_report_battleResult_5673 = 5673  -- 上传战报
MethodCode.guildAct_has_finished_guide_5675 = 5675  -- 完成新手引导教学关卡



--邮件
MethodCode.mail_requestMail_1501 = 1501 		--取邮件
MethodCode.mail_getAttachment_1503 = 1503 		--领取附件



--商店
MethodCode.shop_getInfo_1601 = 1601 			--获取商店信息
MethodCode.shop_refresh_1603 = 1603 			--刷新商店
MethodCode.shop_unlockShop_1605 = 1605 			--解锁商店
MethodCode.shop_buyGoods_1607 = 1607 			--购买道具
MethodCode.norandshop_buygoods_3903 = 3903		--购买商品
MethodCode.norandshop_refresh_3901 = 3901		--刷新商品	

--商店
MethodCode.romance_giveGift_2401    = 2401			--赠送礼物
MethodCode.romance_interact_2405    = 2405			--进行一次互动
MethodCode.romance_story_2403		= 2403			--节点事件
MethodCode.romance_buyinteract_2407 = 2407			--购买互动次数

--出售道具
MethodCode.shop_sell_item_803 = 803	          --出售道具

--排行榜
MethodCode.rank_getRankList_1701 = 1701 		--获取各类排行榜排名信息
MethodCode.rank_getPlayerInfo_1703 = 1703 		--获取排行榜玩家数据
MethodCode.rank_getGuildInfo_1705 = 1705 		--获取公会数据


--试炼
MethodCode.trial_start_battle_1801 = 1801
MethodCode.trial_end_battle_1803 = 1803
MethodCode.trial_normal_battle_1805 = 1805
MethodCode.trial_sweep_battle_1807 = 1807
MethodCode.trial_create_team_1811 = 1811     --创建组队
MethodCode.trial_add_team_1815 = 1815     --加入组队

-- 新问情
MethodCode.elite_challenge_mark_2403 = 2403      -- 挑战
MethodCode.elite_exchange_mark_2405 = 2405       -- 兑换
MethodCode.elite_buy_2407 = 2407                 -- 购买

--签到
MethodCode.sign_mark_1901 = 1901 		    --签到
MethodCode.sign_markTotal_1903 = 1903		--总签到	   
MethodCode.sign_lucky_list_1905 = 1905		--上上签列表

--欢乐签到
MethodCode.happysign_mark_4001 = 4001 	

--抽卡
MethodCode.lottery_token_2101 = 2101 		--令牌抽
MethodCode.lottery_gold_one_2103 = 2103		--钻石单抽
MethodCode.lottery_gold_ten_2105 = 2105		--钻石十连抽
MethodCode.lottery_shoul_2107 = 2107		--魂匣抽卡
MethodCode.lottery_LintQuDrawcard_2109 = 2109 --造物符替换
MethodCode.lottery_speedUpLottery_2111 = 2111  --加速造物
MethodCode.lottery_finishLottery_2113 = 2113  --完成造物
MethodCode.lottery_quickSoul_2115 = 2115 		--快速聚魂


--任务
MethodCode.quest_getDailyQuest_reward_2503 = 2503
MethodCode.quest_getMainLineQuest_reward_2501 = 2501
MethodCode.quest_lvl_reward_2505 = 2505   --等级奖励
MethodCode.quest_achievement_reward_2507 = 2507   --成就奖励





--cdkey兑换
MethodCode.cdkey_exchange_2701 = 2701 --cdkey兑换
MethodCode.passCode_exchange_2703 = 2703 --passCode兑换

--好友系统
MethodCode.friend_user_motto2901=2901           --修改玩家的签名
MethodCode.friend_page_list2903=2903            --获取好友列表中的好友信息
MethodCode.friend_apply_list2905=2905           --获取好友申请列表
MethodCode.friend_recommend_list2907=2907   	--获取推荐好友列表
MethodCode.friend_search_list2909=2909          --获取搜索好友列表
MethodCode.friend_apply_request2911=2911        --请求向对方申请好友请求
MethodCode.friend_approve_request2913=2913      --同意对方好友申请请求
MethodCode.friend_reject_request2915=2915       --拒绝对方申请好友请求
MethodCode.friend_remove_request2917=2917       --删除好友
MethodCode.friend_send_sp2919 =2919                 --向好友赠送体力
MethodCode.friend_achieve_sp2921=2921             --获取好友赠送的体力
MethodCode.friend_modifyname_sp2929 = 2929        ---修改好友昵称

--获取公告
MethodCode.get_notice_3101 = 3101 --获取公告

--获取维护公告
MethodCode.get_maintain_notice_3103 = 3103 --获取维护公告

-- 主角
MethodCode.char_qualitry_levelup_349 = 349				--主角升品
MethodCode.char_qualitry_equip_357 = 357				--主角升品道具装备
MethodCode.char_star_levelUp_353 = 353				--主角升星
MethodCode.char_equip_levelUp_355 = 355				--主角升星
MethodCode.char_equip_awake_373 = 373				--主角装备觉醒

MethodCode.char_Buy_touxian_351 = 351                   --主角头衔

--新手引导
MethodCode.tutor_finish_groupId_333 = 333
MethodCode.tutor_save_unlockId_335 = 335


--荣耀事件
MethodCode.home_getBest_3401 = 3401
MethodCode.home_worship_3403 = 3403

MethodCode.starlight_activate_3301 = 3301

--聊天系统

MethodCode.chat_send_message_world_3501=3501 --向世界聊天中发送信息
MethodCode.chat_send_message_league_3503=3503--向联盟聊天中发送信息
MethodCode.chat_send_message_private_3505=3505--向私聊页面中发送信息
MethodCode.chat_send_battle_info_3507=3507--分享战报
MethodCode.chat_battle_info_play_3509=3509--战报回放
MethodCode.query_player_info_337=337--//查询角色信息
MethodCode.chat_Get_inf_2801 = 2801 --获得设置属性
MethodCode.chat_Set_inf_2803 = 2803 ---设置聊天设置属性
MethodCode.chat_get_notline_data_3521 = 3521 --取离线私聊消息   参数rid
MethodCode.chat_get_guild_notline_3523 = 3523 --3523 取离线公会消息	 没有参数
MethodCode.chat_get_Love_3525 = 3525 -- 发送缘伴聊天	
MethodCode.chat_share_treasure_artifact_3529 = 3529 --	法宝神器分享




--活动
MethodCode.act_finish_task_3601 = 3601 --完成活动任务、领奖励、或者兑换奖励
-- 嘉年华系统
MethodCode.activity_getTaskReward_3601	=	3601	--领取任务奖励
MethodCode.activity_getWholeTaskReward_3603	=	3603	--领取全目标任务奖励

--开服抢购
MethodCode.act_getKaiFuQGData_6501 = 6501 -- 获取抢购信息
MethodCode.act_getKaiFuQG_6503 = 6503    -- 抢购


--充值
MethodCode.recharge_temp_2203 = 2203    --临时充值接口
MethodCode.recharge_2205 = 2205    --临时充值接口

--购买礼包
MethodCode.vip_buy_gift_343 = 343    --购买vip礼包

--伙伴
MethodCode.partner_combine_4201 = 4201 --伙伴合成
MethodCode.partner_equipment_levelup_4203 = 4203 --伙伴装备升级
MethodCode.partner_star_leveup_4205 = 4205 --伙伴升星
MethodCode.partner_quality_levelup_4207 =4207 --伙伴升品
MethodCode.partner_skill_levelup_4209 = 4209 --伙伴技能升级
-- MethodCode.partner_soul_levelup_4211 = 4211 --伙伴仙魂升级
MethodCode.partner_fragment_exchange_4217 = 4217 --伙伴碎片兑换
MethodCode.partner_quality_item_combine_4219 = 4219--伙伴升品道具合成
MethodCode.partner_quality_item_equip_4213 = 4213--伙伴升品道具装备
MethodCode.partner_skill_point_buy_4215 = 4215--伙伴技能点购买
MethodCode.partner_equipment_upgrade_4221 = 4221--伙伴装备升级
MethodCode.partner_equipment_awake_4223 = 4223--伙伴装备觉醒

--主角
MethodCode.char_quality_item_equip_4213 = 349--主角升品道具装备


--伙伴皮肤
MethodCode.skin_buy_4901 = 4901  -- 伙伴皮肤购买
MethodCode.skin_on_4903 = 4903  -- 伙伴皮肤穿戴

--上阵  执行上阵操作
MethodCode.formation_doformation_347 = 347


--多人布阵  加入房间
MethodCode.formation_doJoinRoom_4715 = 4715
--多人布阵  离开房间
MethodCode.formation_doLevelRoom_4717 = 4717
--上阵法宝
MethodCode.formation_onTrea_4701 = 4701
--上阵伙伴
MethodCode.formation_onPartner_4703 = 4703
--锁定阵型
MethodCode.formation_lock_formation_4707 = 4707
--超时
MethodCode.formation_timeOver_4709 = 4709





--新抽奖
MethodCode.lottery_replace_2105 = 2105   ---奖池替换
MethodCode.lottery_freeDrawcard_2101 = 2101 --免费抽奖
MethodCode.lottery_consumeDrawcard_2103 = 2103 --元宝抽

-- 查看阵容
MethodCode.lineup_get_formation_4501 = 4501 -- 获取阵容信息
MethodCode.lineup_give_praise_4503 = 4503 -- 点赞
MethodCode.lineup_cancel_praise_4505 = 4505 -- 取消点赞
MethodCode.lineup_set_bg_4507 = 4507 -- 设置背景
MethodCode.lineup_get_praiselist_4509 = 4509 -- 查看赞我的人
-- 获取自己被点赞的信息(玩家查看自己的阵容信息时，阵容相关信息从内存中可以获得，自己被点赞总数量和自己是否对自己点赞需要通过这个请求获得)
MethodCode.lineup_get_ownpraise_info_4511 = 4511 
 
 
--修炼
MethodCode.practice_shengji_4601  = 4601   ---升级
MethodCode.practice_tupo_4603  = 4603   ---突破
MethodCode.practice_startpractice_4605  = 4605   ---修炼
MethodCode.practice_getreward_4607  = 4607   ---获得数据
MethodCode.practice_CDpractice_4609  = 4609   ---秒CD


--买个主角衣服
MethodCode.garment_buy_4801  = 4801   ---买衣服
MethodCode.garment_On_4803  = 4803   ---买衣服

-- 挂机
MethodCode.delegate_get_list_4401 = 4401 -- 获取任务列表
MethodCode.delegate_start_task_4403 = 4403 -- 开始任务
MethodCode.delegate_finish_task_4405 = 4405 -- 完成任务
-- MethodCode.delegate_speedup_task_4407 = 4407 -- 加速任务
MethodCode.delegate_refresh_task_4409 = 4409 -- 刷新任务
MethodCode.delegate_recall_task_4411 = 4411 -- 召回任务
MethodCode.delegate_refresh__special_task_4413 = 4413 -- 刷新特殊委托
MethodCode.delegate_refresh__normal_task_4415 = 4415 -- 刷新普通
MethodCode.delegate_speedup_task_4417 = 4417 -- 刷新特殊委托

-- 修改头像
MethodCode.change_user_head_2805 = 2805
-- 修改头像框
MethodCode.change_user_head_kuang_2807 = 2807
--新法宝
MethodCode.treasure_combine_413 = 413   -- 法宝合成或解锁
MethodCode.treasure_up_star_403 = 403   -- 法宝升星
MethodCode.treasure_up_quality_405 = 405   -- 法宝进阶
MethodCode.treasure_wnsp_415 = 415         -- 法宝碎片兑换

-- 情缘系统
MethodCode.love_activite_5101 = 5101   -- 情缘激活
-- 新版情缘系统
MethodCode.love_levelUp_5103 = 5103    -- 情缘阶升级
MethodCode.love_resonanceUp_5105 = 5105   -- 奇侠共鸣阶升级
MethodCode.love_enterPlotBattle_5107 = 5107   -- 进入剧情战斗
MethodCode.love_reportBattleResult_5109 = 5109   -- 上传战报
MethodCode.love_Lighten_One_Cell_5111 = 5111	--解锁全局情缘

MethodCode.title_Action_5201 = 5201 --激活
MethodCode.title_wear_uninstall_5203 = 5203 --穿戴和卸载

-- 锁妖塔
MethodCode.tower_get_map_2601 = 2601 		--获取锁妖塔数据
MethodCode.tower_open_grid_2605 = 2605 		--翻格子
MethodCode.tower_get_item_2619 = 2619 		--捡道具
MethodCode.tower_getBox_2621    =   2621    --捡宝箱
MethodCode.tower_talkNpc_2623   =   2623    --触发npc事件
MethodCode.tower_attackMonster_2625 =   2625    --挑战怪物
MethodCode.tower_finishMonster_2627 =   2627    --怪物战斗结算
MethodCode.tower_reset_2603 =   2603    --进入下一层
MethodCode.tower_receiveTowerAchievement_2613   =   2613    --领取爬塔成就奖励
MethodCode.tower_finishBattle_2611  = 2611     --购买地图内buff
MethodCode.tower_dropGoods_2617 =   2617    --丢弃道具
MethodCode.tower_passMonster_2641 = 2641   --跳过怪物
MethodCode.tower_resetFloor_2607 = 2607     -- 重置锁妖塔
MethodCode.tower_openChests_2609 = 2609     --扫荡锁妖塔
MethodCode.tower_useItem_2615 = 2615  --使用道具
MethodCode.tower_sweepBuff_2613 = 2613 --获取扫荡buff
MethodCode.tower_getFloorReward_2629    =   2629    --获取首登奖励
MethodCode.tower_attackNpc_2643 = 2643    --攻击npc
MethodCode.tower_finishNpc_2645 = 2645    --npc战斗结算
MethodCode.tower_getTowerInfo_2647 = 2647   --获取塔外数据(包含搜刮信息)
MethodCode.tower_takeAltar_2649 =   2649  --破阵

MethodCode.tower_getBeforeShopReward_2651 =   2651  --获取弹出商店前的奖励
MethodCode.tower_employMercenary_2653 =   2653  --雇佣兵
MethodCode.tower_robSomething_2655 =   2655  --劫财劫色劫魔石
MethodCode.tower_getWulingSoul_2657 =   2657  --获取五灵池的五灵

MethodCode.tower_start_collection_2659 =   2659  --开始搜刮
MethodCode.tower_collection_accelerate_2661 =   2661  --搜刮加速
MethodCode.tower_handle_collection_event_2663 =   2663  --处理搜刮事件
MethodCode.tower_receive_collection_rewards_2665 =   2665  --领取搜刮奖励
MethodCode.tower_change_rune_property_2667 =   2667  --改变聚灵格子属性
MethodCode.tower_pass_door_2669 =   2669  --过门



MethodCode.cimelia_lottery_5305 = 5305   --抽奖购买  --神器
MethodCode.cimelia_cimeliaUpgrade_5301 = 5301   --单件进阶
MethodCode.cimelia_cimeliaGroupUpgrade_5303 = 5303   --组合进阶
MethodCode.cimelia_decompose_5307 = 5307   --分解

-- 共享副本
MethodCode.shareBoss_get_5401 = 5401    --获取共享副本数据
MethodCode.shareBoss_challenge_5403	=	5403   --挑战共享副本
MethodCode.shareBoss_report_5405	=	5405   --共享副本结算
MethodCode.shareBoss_openShareBoss_5409 = 5409

--五行布阵
MethodCode.battle_setElement_5061   =   5061 --上下阵五行
MethodCode.battle_exchange_5063 =   5063    --交换位置


MethodCode.guild_gve_chat_5657 = 5657		--仙盟聊天

--[[
	5501    => 'Mission.getReward',             //领取奖励
    5503    => 'Mission.getRank',               //取排行列表
    5505    => 'Mission.getBattleInfo',         //获取比武对手信息
	5507    => 'Mission.startSoloMission',      //进入轶事：单人战斗
    5509    => 'Mission.finishSoloMission',     //完成轶事：单人战斗
    5511    => 'Mission.startBattleMission',    //进入轶事：pvp战斗
    5513    => 'Mission.finishBattleMission',   //完成轶事：pvp战斗
    5515    => 'Mission.startExamMission',      //进入轶事：答题
    5517    => 'Mission.quitExamMission',       //完成轶事：答题
    5519    => 'Mission.reportExamMission',     //提交轶事答题
]]
MethodCode.mission_getReward_5501 = 5501
MethodCode.mission_getRank_5503 = 5503
MethodCode.mission_getBattleInfo_5505 = 5505
MethodCode.mission_startMission_5507 = 5507
MethodCode.mission_finishMission_5509 = 5509
MethodCode.mission_startBattleMission_5511 = 5511
MethodCode.mission_finishMission_5513 = 5513
MethodCode.mission_startExamMission_5515 = 5515
MethodCode.mission_quitExamMission_5517 = 5517
MethodCode.mission_reportExamMission_5519 = 5519

--五灵养成
-- MethodCode.fivesouls_upgradeLevel_5701 = 5701  --提升法阵
MethodCode.fivesouls_activate_5701 = 5701      --激活五灵
MethodCode.fivesouls_upgradeSoulsLevel_5703 = 5703 --提升五灵
MethodCode.fivesouls_resetSoulsLevel_5705 = 5705 --重置五灵点

--须臾系统
MethodCode.challenge_WonderLand_5801 = 5801       --挑战
MethodCode.finish_WonderLand_5803 = 5803       --挑战
MethodCode.sweep_WonderLand_5805 = 5805      --挑战

-- 巅峰竞技场
MethodCode.crosspeak_startMatch_5901 = 5901 -- 开始匹配
MethodCode.crosspeak_startMatch_5933 = 5933 --匹配机器人
MethodCode.crosspeak_robotReport_5935 = 5935 --发送打机器人战报结果
MethodCode.crosspeak_quxiaoMatch_5903 = 5903 -- 取消匹配
MethodCode.crosspeak_buyChallengeTimes_5907 = 5907 -- 购买挑战次数
MethodCode.crosspeak_receiveActiveReward_5911 = 5911 -- 领取活动奖励
MethodCode.crosspeak_request_rank_5923 = 5923 -- 请求排行奖励
MethodCode.crosspeak_request_crossPeak_rank_5925 = 5925 -- 请求巅峰排行榜
MethodCode.crosspeak_box_unlock_5927 = 5927 -- 宝箱解锁
MethodCode.crosspeak_box_remove_5929 = 5929 -- 扔掉宝箱
MethodCode.crosspeak_box_reward_5931 = 5931 -- 领取宝箱奖励
MethodCode.crosspeak_report_list_5937 = 5937 -- 获取战报简略信息列表
MethodCode.crosspeak_renwu_reward_5939 = 5939 -- 领取小任务奖励
MethodCode.crosspeak_renwu_refresh_5941 = 5941 -- 手动刷新小任务
MethodCode.crosspeak_renwu_box_5943 = 5943 -- 领取大宝箱奖励
MethodCode.crosspeak_guild_kill_5947 = 5947 -- 仙盟击杀奇侠数量
MethodCode.crosspeak_report_6301 = 6301 -- 查看战斗回放

--无底深渊
MethodCode.endless_startChallenge_6101 = 6101  --点击endless挑战
MethodCode.endless_reportResult_6103 = 6103  --上传战报
MethodCode.endless_getBoxReward_6105 = 6105  --获取宝箱奖励
MethodCode.endless_getFriendAndGuildData_6107 = 6107  --获取好友和盟友数据
MethodCode.endless_sweepChallenge_6109 = 6109   --扫荡无底深渊
MethodCode.endless_buyTimes_6111 = 6111    --购买无底深渊次数

MethodCode.RANK_COMMENTS_6001 = 6001 -- 获取排行和评论
MethodCode.ADD_COMMENTS_6003 = 6003 --添加评论
MethodCode.PRAISE_STOPON_6005 = 6005 --点赞和点踩
MethodCode.COMMENTS_REPORT_6007 = 6007 --点赞和点踩

-- 获取战报测试协议
MethodCode.test_get_battleInfo_5099 = 5099
-- 仙盟副本(共闯秘境)
MethodCode.guildBoss_getGuildBossList_6201 = 6201 -- 获取Boss列表
MethodCode.guildBoss_openGuildBoss_6203 = 6203 -- 开启boss -- 改成预约
MethodCode.guildBoss_attackGuildBoss_6205 = 6205 -- 挑战
MethodCode.guildBoss_finishGuildBoss_6207 = 6207 -- 结算

MethodCode.guildBoss_GuildBoss_rank_6209 = 6209 -- 结算

MethodCode.guildBoss_create_team_6213 = 6213  --创建队伍
MethodCode.guildBoss_Invite_6215 = 6215		--邀请消息
MethodCode.guildBoss_add_team_6217 = 6217	--加入队伍
MethodCode.guildBoss_leave_team_6219 = 6219	--离开队伍
MethodCode.guildBoss_out_team_6221 = 6221   --踢出队伍
MethodCode.guildBoss_rank_6227 = 6227   --排行榜
MethodCode.guildBoss_single_battle_6225  = 6225 --单人挑战
MethodCode.guildBoss_more_battle_6223  = 6223 --多人挑战
MethodCode.guildBoss_get_invited_6237  = 6237 --获取邀请列表

--红包
MethodCode.guildRedPacket_getListData_6401 = 6401 --获取红包列表
MethodCode.guildRedPacket_offpacket_6403 = 6403 --发红包
MethodCode.guildRedPacket_grab_6405 = 6405 		--抢红包
MethodCode.guildRedPacket_getPacketInfo_6407 = 6407 --获取红包列表

MethodCode.retrieve_retrieveGetReward_6701 = 6701 -- 领取奖励

--情景卡
MethodCode.memory_card_activity_6801 = 6801 --情景卡激活
MethodCode.memory_card_share_6803 = 6803 --情景卡分享

-- 问卷调查
MethodCode.questionnaire_get_url_7101 = 7101 --获取文件调查url

-- 名册系统
MethodCode.handbook_getUp_7501 = 7501 -- 上阵
MethodCode.handbook_getDown_7503 = 7503 -- 下阵
MethodCode.handbook_upLevel_7505 = 7505 -- 提升名册等级
MethodCode.handbook_buyPosition_7507 = 7507 -- 解锁册系内的阵位

MethodCode.battle_battleEnter  = "battle.battleEnter" 	--进入战斗

MethodCode.battle_battleReady  = "battle.battleReady" 	--战斗loading结束通知服务器准备好了

MethodCode.battle_battleOperation  = "battle.battleOperation" 	--战斗操作

MethodCode.battle_battleEnd  = "battle.battleEnd" 	--战斗结束操作

MethodCode.battle_battleGetOperation  = "battle.battleGetOperation" 	--请求进度

--多人测试接口[用于发送logsInfo然后服务端推送给别的玩家]
MethodCode.battle_debugCommand  = "debug.command1" 	

-- 仙界对决结算超时请求
MethodCode.battle_crosspeak_result_timeout_5001 = 5001


-- 道具快捷购买
MethodCode.item_quick_buy_807 = 807

--月卡奖励领取
MethodCode.card_month_reward_7301 = 7301

-- 支付订单轮询接口
MethodCode.sdk_charge_query_bill = 2207


MethodCode.finish_guild_task_7401 = 7401 --完成仙盟任务
MethodCode.get_guild_task_rink_7403 = 7403 --获取内榜
MethodCode.get_guild_task_renwnglory_7405 = 7405 --揭榜
MethodCode.get_guild_task_rink_reward_7407 = 7407 --领取声望排名奖励

-- 奇侠传记协议
MethodCode.biography_change_partner_7801 = 7801 -- 切换当前进行任务的奇侠
MethodCode.biography_finish_task_7803 = 7803 -- 完成子节点
MethodCode.biography_get_box_7805 = 7805 -- 领取宝箱
MethodCode.biography_start_battle_7807 = 7807 -- 开始战斗
MethodCode.biography_finish_battle_7809 = 7809 -- 战斗结算

MethodCode.luckyguy_bug_Ticket_7701 = 7701  --幸运转盘买券
MethodCode.luckyguy_play_Award_7703 = 7703  --幸运转盘抽奖

--仙盟挖宝借口
MethodCode.guild_dig_box = 1379       ---挖宝
MethodCode.get_guild_dig_list = 1381  ---取挖宝列表
MethodCode.explore_enterMap_7601 = 7601 -- 连接进入地图

MethodCode.explore_login = "login.login" --登入请求
MethodCode.explore_login_loginClient = "login.clientLogin" --获取地图信息
MethodCode.explore_map_move = "map.move" --玩家移动信息
MethodCode.explore_map_moveConfirm = "map.moveConfirm" --玩家确认

MethodCode.explore_get_data_mine_info = "mine.info" --获取矿脉数据
MethodCode.explore_mine_occupy = "mine.occupy" --矿脉占领协议  --派遣奇侠
MethodCode.explore_mine_invite = "mine.invite"   --邀请挑战矿脉
MethodCode.explore_mine_leave  = "mine.leave" --撤离矿脉
MethodCode.explore_mine_battleStart  = "mine.battleStart" --战斗开始
MethodCode.explore_mine_battleFinish  = "mine.battleFinish" --战斗结束

MethodCode.explore_city_invite = "city.invite"  ---矿脉邀请协议


MethodCode.explore_get_city_info = "city.info"-- 获取建筑数据
MethodCode.explore_city_occupy = "city.occupy" --建筑占领协议  --派遣奇侠
MethodCode.explore_city_leave  = "city.leave" --撤离建筑
MethodCode.explore_city_battleStart  = "city.battleStart" --战斗开始
MethodCode.explore_city_battleFinish  = "city.battleFinish" --战斗结束

MethodCode.explore_challeng_monster_battleStart = "monster.battleStart"--挑战普通怪
MethodCode.explore_monster_battleFinish = "monster.battleFinish"--结束挑战普通怪

MethodCode.explore_get_eliteMonster_info = "eliteMonster.info"--精英怪信息
MethodCode.explore_get_eliteMonster_invite = "eliteMonster.invite"--邀请攻打精英怪
MethodCode.explore_get_eliteMonster_reward = "eliteMonster.reward"--领取精英怪奖励
MethodCode.explore_challeng_eliteMonster_fightStart = "eliteMonster.battleStart"--挑战精英怪怪
MethodCode.explore_challeng_eliteMonster_fightFinish = "eliteMonster.battleFinish"--结束挑战精英怪

MethodCode.explore_map_record = "map.record"--获取地图事件


MethodCode.explore_get_map_rank = "map.rank"--获取排行榜数据
MethodCode.explore_get_res_pickup = "res.pickup"--拾取地上的资源
MethodCode.explore_get_buff_pickup = "buff.pickup"--拾取灵泉

MethodCode.explore_get_task_info = "task.info"--获取任务列表
MethodCode.explore_get_task_reward = "task.reward"--领取任务奖励
MethodCode.explore_get_equip_info = "equip.info"--取换装备信息
MethodCode.explore_equip_upgrade = "equip.upgrade"--提升装备信息

MethodCode.explore_buy_energy = "role.buyEnergy" 	--购买精力

MethodCode.explore_role_getOfflineReward = "role.getOfflineReward" 	---领取离线奖励

MethodCode.GM_GET_RES = "gm.addResource"  ---gmhuo获得资源

MethodCode.explore_heartbeat = "role.heartbeat"  ---心跳包

MethodCode.explore_map_occupyRecord = "map.occupyRecord"  ---获取查看已派遣


--分享成功后发送计数接口
MethodCode.shared_success_375 = 375
-- 获取首次分享的奖励
MethodCode.get_first_share_reward_377 = 377

--六界游商
MethodCode.travel_shop_take_discount_7705 = 7705

return MethodCode







