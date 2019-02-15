--
-- Author: xd
-- Date: 2015-11-26 16:50:11
--本地存储的一些key

--用户模块
local StorageCode ={}
StorageCode.username = "username" 					--用户名
StorageCode.userpassword = "userpassword" 			--用户密码
StorageCode.debugInputData = "debugInputData" 		--调试输出的数据 json串

StorageCode.romance_interact_sweep_open_mark = "romance_interact_sweep_open_mark"
StorageCode.romance_interact_first_open_mark = "romance_interact_first_open_mark"

StorageCode.login_last_server_id = "login_last_server_id"
StorageCode.login_last_server_index = "login_last_server_index"
StorageCode.login_last_server_name = "login_last_server_name"

StorageCode.device_id = "device_id" --记录设备id
StorageCode.login_type = "login_type" --记录是游客登录(guest),还是账号登录(account)
StorageCode.last_login_type = "last_login_type" --用于新游客第一次登录之后判断是否提示账号升级

StorageCode.login_is_switch_acccount = "is_switch_acccount"
StorageCode.login_is_quick_restart = "login_is_quick_restart"

-- 选择的角色ID
StorageCode.login_select_role_id = "login_select_role_id"
-- 送李逍遥提醒
StorageCode.login_give_lxy_tip = "login_give_lxy_tip"

-- 游戏启动是否播放情怀动画
StorageCode.star_play_memory_anim = "star_play_memory_anim"
-- 游戏启动是否播放CG视频
StorageCode.star_play_cgvideo = "star_play_cgvideo"

-- MostSdk 
-- APP_ID
StorageCode.mostsdk_app_id = "mostsdk_app_id"
StorageCode.mostsdk_token = "mostsdk_token"
StorageCode.mostsdk_account_id = "mostsdk_account_id"
StorageCode.mostsdk_channel_alias = "mostsdk_channel_alias"
StorageCode.mostsdk_account_name = "mostsdk_account_name"
StorageCode.mostsdk_account_usertype = "mostsdk_account_usertype"

--设置
StorageCode.setting_music_st = "setting_music_st"
StorageCode.setting_sound_st = "setting_sound_st"
StorageCode.setting_teaminvite_player_st = "setting_teaminvite_player_st"
StorageCode.setting_show_player_st = "setting_show_player_st"
StorageCode.setting_battle_music_st = "setting_battle_music_st"
StorageCode.setting_battle_sound_st = "setting_battle_sound_st"
StorageCode.setting_music_volume = "setting_music_volume" --背景音量
StorageCode.setting_sound_volume = "setting_sound_volume" --音效音量

-- 体力满提醒
StorageCode.setting_notice_maxsp = "setting_notice_maxsp"
-- 领取体力提醒
StorageCode.setting_notice_getsp = "setting_notice_getsp"
-- 六界答案提醒
StorageCode.setting_notice_world_answer = "setting_notice_world_answer"
-- 公会共创秘境
StorageCode.setting_notice_guild = "setting_notice_guild"
-- 仙界对决提醒
StorageCode.setting_notice_fairylandbattle = "setting_notice_fairylandbattle"
-- 仙盟酒家提醒
StorageCode.setting_notice_guildactivity = "setting_notice_guildactivity"


--新手引导发送给数据中心的最后一步
StorageCode.tutorial_last_send_to_center = "tutorial_last_send_to_center"
--没有完成的非强制引导
StorageCode.tutorial_showing_triggerGroup = "tutorial_showing_triggerGroup"
-- 引导，保证首次进入进行引导，登仙台;试炼窟
StorageCode.tutorial_first_trial = "tutorial_first_trial"
StorageCode.tutorial_first_pvp = "tutorial_first_pvp"
-- 首次自动战斗的引导
StorageCode.tutorial_first_autofight = "tutorial_first_autofight"
-- 战斗加速引导（表示引导过几倍速了）
StorageCode.tutorial_first_battlespeed = "tutorial_first_battlespeed"
-- 引导防卡死机制
StorageCode.tutorial_avoid_stuck = "tutorial_avoid_stuck"
-- 引导记录是否播放过新功能开启
StorageCode.tutorial_sysopen_check = "tutorial_sysopen_check"
-- 是否进行过某特殊失败引导
StorageCode.tutorial_battle_fail = "tutorial_battle_fail"
--[[
所有的阵型信息保存在本地
]]
StorageCode.all_team_formation = "all_team_formation__"



--[[
当前pvp使用的阵容 1 or 2
]]
StorageCode.currentPVEFormation = "current_pve_formation__"

StorageCode.chat_userID = "chat_userID"

---[[
	-- 好友列表的缓存
--]]
StorageCode.friend_list = "friend_list"
StorageCode.ChatSwtInfoData = "ChatSwtInfoData"
StorageCode.ChatVoiceInfoData = "ChatVoiceInfoData"

--[[
	试炼断线重连保存时间
]]
StorageCode.trialTime = "trialTime"

--[[
	查看阵容界面，点击机器人时候的赞的信息保存在本地
	{
		{
			doLike = 1,
			likeNum = 10,
			timeStamp = 1231231,	
		}
	}
]]
StorageCode.lineup_robot_praise = "lineup_robot_praise"

-- 爬塔主角位置
StorageCode.tower_char_pos = "tower_char_pos"
StorageCode.elite_char_pos = "elite_char_pos"

-- 地图位置
StorageCode.tower_map_pos = "tower_map_pos"
StorageCode.elite_map_pos = "elite_map_pos"

--锁妖塔完美通关动画次数
StorageCode.tower_clearance_time = "tower_clearance_time"
-- 锁妖塔商店本地信息
StorageCode.tower_shop_info = "StorageCode.tower_shop_info"

-- 六界主角坐标
StorageCode.world_char_info = "world_char_info"

-- 战斗相关
-- 战斗速率
StorageCode.battle_game_speed = "battle_game_speed"
-- 普通副本自动战斗状态
StorageCode.battle_world_pve_auto = "battle_world_pve_auto"
-- 试炼pve
StorageCode.battle_trail_pve_auto = "battle_trail_pve_auto"
-- 锁妖塔
StorageCode.battle_tower_auto = "battle_tower_auto"
-- 轶事玩法
StorageCode.battle_mission_auto = "battle_mission_auto"
--情缘选择
StorageCode.love_choose_id = "love_choose_id"
-- 共享副本
StorageCode.battle_shareboss_auto = "battle_shareboss_auto"
-- 须臾仙境
StorageCode.battle_wonderland_auto = "battle_wonderland_auto"
-- 轶事冰封玩法
StorageCode.battle_ice_auto = "battle_ice_auto"
-- 轶事爆炸玩法
StorageCode.battle_bomb_auto = "battle_bomb_auto"
-- 无尽深渊
StorageCode.battle_endless_auto = "battle_endless_auto"
-- 仙盟boss
StorageCode.battle_guildboss_auto = "battle_guildboss_auto"
-- 仙盟boss
StorageCode.battle_guildGve_auto = "battle_guildGve_auto"
-- 仙盟探索普通玩法
StorageCode.battle_guildExplore_auto = "battle_guildExplore_auto"
-- 仙盟探索精英玩法
StorageCode.battle_exploreElite_auto = "battle_exploreElite_auto"
-- 跑环
StorageCode.battle_ringtask_auto = "battle_ringtask_auto"
-- 仙盟boss上一次打通的副本
StorageCode.guildBoss_lastPass_ectypeId = "guildBoss_lastPass_ectypeId"

--弹幕显示保存本地
StorageCode.barrage_type = "barrage_type"

--聊天里面的设置内容保存本地
StorageCode.chat_type = "chat_type"

--主界面红包的位置
StorageCode.red_packet_pos = "red_packet_pos"

--三皇台造物的位置
StorageCode.lottery_pos_save = "lottery_pos_save"

--三皇台造物下个界面按钮
StorageCode.lottery_next_btton = "lottery_pos_save"

--是否显示协议信息
StorageCode.show_agreement_info = "show_agreement_info"

--主界面红包的位置
StorageCode.guildBoss_notify_pos = "guildBoss_notify_pos"

-- 实时语音喇叭状态
StorageCode.realTime_voice = "realTime_voice"
-- 实时语音麦克风状态
StorageCode.realTime_mic = "realTime_mic"
--每日首次登陆游戏
StorageCode.first_loginTime = "first_loginTime"
--每日是否点击进入过商城
StorageCode.enter_mallMainView = "enter_mallMainView"

StorageCode.luckyGuy_save = "luckyGuy_save"

--幻境协战 已死亡boss 信息
StorageCode.dead_shareBoss = "dead_shareBoss"

--快速聚魂
StorageCode.gatherSoul_quickSoul = "gatherSoul_quickSoul"
-- 自动购买聚魂相关材料 字符串1 表示 勾选
StorageCode.gatherSoul_autoBuy = "gatherSoul_autoBuy"
--本次登录不在提示，聚魂
StorageCode.gatherSoul_LoginBuy = "gatherSoul_LoginBuy"
--升级 新手期以及老手期状态标记
StorageCode.partner_skilledForUpgrade = "partner_skilledForUpgrade"
--升品 新手期以及老手期状态标记
StorageCode.partner_skilledForUpQuality = "partner_skilledForUpQuality"
--奇侠仙术 新手期以及老手期状态标记
StorageCode.partner_skilledForSkill = "partner_skilledForSkill"
--装备强化 新手期以及老手期状态标记
StorageCode.partner_skilledForEquipmentEnhance = "partner_skilledForEquipmentEnhance"
--装备进阶 新手期以及老手期状态标记
StorageCode.partner_skilledForEquipmentAdvance = "partner_skilledForEquipmentAdvance"
--奇侠升星 新手期以及老手期状态标记
StorageCode.partner_skilledForStar = "partner_skilledForStar"

-- 第一次打主线10101关卡
StorageCode.FIRST_SHOW = "FIRST_SHOW"
--坊市刷新时间 用于判断是否显示主城特效
StorageCode.SHOP_ANIM_SHOW = "SHOP_ANIM_SHOW"

return StorageCode


