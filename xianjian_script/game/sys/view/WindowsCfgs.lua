
local viewsPackage = "game.sys.view"

--窗口配置   目前手配, 会比较容易管理,主要负责管理ui 的显示层级,父子关系,显示样式等

--[[
    ui(string) 是否这个窗口 有 flash对应的UI配置,默认为空,  
    level(int) 显示层级 越高 越在上面,  比如 tip 层级最高 ,tip会盖住一般的window, 默认为2
    package(string) , ui对应的包路径,默认为空
    cache(bool):  是否缓存这个ui  ,有些窗口关闭以后 是需要缓存起来的,有些是需要立即销毁的,以后的扩展可能还会配置 clearTextrues 
    addTex(Array):  打开这个窗口需要加载的材质,默认为空,
    clearTex(Array): 关闭这个窗口后需要清除的材质, 默认为空, 当cache为true的时候 不执行clearTextures
    style 显示的过程  默认值 1(fadein) 2缩放 , 0
    pos 显示的初始位置 默认值 pos={x=0,y=GameVars.height}
    bgAlpha             --背景透明度 默认120
    bg          --背景图片 默认为空
    bgScale     --背景适配类型 默认和空 是等比缩放适配的 1是只适配x方向拉伸, 2只适配y方向拉伸, 3是不适配
    screen =    {1136,640},             --特殊适配方案 默认是 960 * 640 ,但是后面的ui会改成1136 * 640 慢慢做过渡
    full  = false  是否是全屏ui,如果配了bg 那么模式是全屏ui, 配置为true 那么强制是全屏ui
    scaleT = {scaleX,scaleY,isShow,offsetX,offsetY}  5个参数分别是宽缩放，高缩放，是否显示(用来测试用，默认false),X偏移量,Y偏移量
    foreverNew = true,       --代表每次show 这个window的时候 都会重新new 这个ui(如果这个ui已经在显示队列里面,会把他先销毁)

]] 

-- 1= scene  2= 1j window --------------5  6= tip
--每一个键名一定会有一个对应的view和他对应,这个名字一定要保证一致

local LocalZorder = {
    SystemOpenView_10 = 10,
}

local windowsCfgs = {
    
    --基础UIBase
    UIBase = {ui = "*",style  = 0},
    -- 测试界面
    
    --通用Tip弹窗
    Tips = {ui="UI_comp_tcdan",  level = 999, package ="component", style = 2},

    BulleTip = {ui = "UI_comp_tipsItem5",package = "component"},

    --通用输出
    InputView = {ui="UI_inputModel",level = 999,package = "component"},

    --网络调试接口界面
    TestConnView = {ui = "UI_debug_interface" ,package = "test"   },
    --进入gm界面的入口
    GMEnterView = {ui = "UI_debug_GM" ,package = "test"   },
    -- 战斗显示详细数据入口
    BattleDebugAttrView = {ui = "UI_debug_attr" ,package = "test"},
    -- 地形编辑器相关
    EditorBarView = {ui = "UI_editor_bar" ,package = "test"},
    EditorOpenView = {ui = "UI_editor_open" ,package = "test"},
    EditorSettingView = {ui = "UI_editor_setting" ,package = "test"},
    
    DebugFilterView= {ui="UI_debug_filter",package ="test",bgAlpha=0},
    DebugColorView= {ui="UI_debug_color",package ="test",bgAlpha=0},

    DebugInfoView = {ui = "UI_debug_userInfo",package = "test",bgAlpha =0 },
    DebugPublicView = {ui = "UI_debug_public",package = "test",bgAlpha =0 },

    -- TestDebug_public= {ui="UI_@@debug_public",package ="test",bgAlpha=0},
    --战斗可以调试输出怪物
    BattleDebugHeroView = {ui = "UI_debug_changeHero",package = "test",bgAlpha = 0},
    DebugFormationView = {ui = "UI_debug_formation",package = "test",bgAlpha = 0},


    --日志
    LogsView = {ui = "UI_debug_log", package = "test", style = 0, level = 999999},
    GlobalServerSwitchView = {ui = "UI_debug_switchserver", package = "test", style = 0, level = 999999},
    LogsItem = {ui = "UI_debug_textItem", package = "test", style = 0, level = 1},
    -- 语音演示界面
    VoiceDemoView = {ui = "UI_debug_voice_demo", package = "test", style = 0, level = 1},
    
    -- 公共界面
    --gridView Test
    --GridViewTestView = {ui="UI_@@GridViewTest", package = "GridViewTest"},
    --GridItem = {ui="UI_@@itemTest", package = "GridViewTest"},
    --公共messageBox
    MessageBoxView = {ui = "UI_debug_tanchuang", package = "component", style = 0, level = 100},

    TipItemView = {ui = "UI_comp_tipsItem", package = "component"},
    TipItemView2 = {ui = "UI_comp_tipsItem2", package = "component"},
    TipItemView6 = {ui = "UI_comp_tipsItem6", package = "component"},
    --任务成就提示框
    CompRecordView = {ui = "UI_comp_reword", package = "component"},
    CompGoHome = {ui = "UI_comp_gohome" ,package = "component"},

    CompGoHome5 = {ui = "UI_comp_gohome5" ,package = "component"},

    CompGoHome2 = {ui = "UI_comp_gohome2" ,package = "component"},
    CompGoHome3 = {ui = "UI_comp_gohome3" ,package = "component"},
    CompGoHome4 = {ui = "UI_comp_gohome4" ,package = "component"},

    -- 战斗属性滚动tip
    TipFightAttrView = {ui = "UI_comp_tipsItem3", package = "component"},
       --剧情对话
    PlotDialogView = {ui = "UI_comp_plot", package = "plot", level = 999999,hideBg=true, screen = {1136,640}},
    AnimDialogView = {ui = "UI_comp_anim",package = "plot",level = 999998,full = true, screen = {1136,640},bgAlpha=0},

    -- 获得奖品界面
    RewardBgView = {ui = "UI_comp_huodegoods", package = "component"},

    --10个及以下获得奖品弹窗
    RewardSmallBgView = {ui = "UI_comp_comphuode", package = "component",bgAlpha = 255},

    -- 资源itemView公用UI
    CompResItemView = {ui = "UI_comp_goodsItem_mc", package = "component", style = 2, level = 2},

    -- 玩家明细
    -- PlayerDetailView = {ui = "UI_@@comp_playerDetail", package = "component", style = 2, level = 100},
    -- 仙盟明细
    -- GuildDetailView = {ui = "UI_@@comp_guildDetail", package = "component", style = 2, level = 100},
    -- 获取途径
    GetWayListView = {ui = "UI_comp_tongyong_tujing", package = "component", style = 2, level = 100, screen = {1136,640}},
    -- 获取途径窗口item
    GetWayListItemView = {ui = "UI_comp_getWayCell", package = "component", style = 0, level = 100},


    --UI_comp_shopItem
    CompShopItemView = {ui = "UI_comp_shopItem", package = "component", style=0, level=0},
    -- 法宝view
    -- CompTreasureView = {ui = "UI_@@comp_fb", package = "component", style = 0, level = 0},
    -- 恭喜获得
    CompRewardGetView = {ui = "UI_@@comp_tc", package = "component", style = 0, level = 0},

    Empty_Comp_tc = {ui = "UI_comp_tc", package = "component", style = 0, level = 0},

    --仙盟贡献
    CompResGongXianView = {ui = "UI_comp_res_gongxian", package = "component", style = 0, level = 0},

    -- 通用小弹窗
    CompPopSmallView = {ui = "UI_comp_tc2", package = "component", style=0, level=0,screen = {1136,640}},
    -- 通用小弹窗3
    CompPopSmallView3 = {ui = "UI_comp_tc3", package = "component", style=0, level=0},

    -- 通用弹窗  可以隐掉标题的
    CompPopSmallView4 = {ui = "UI_comp_tc4", package = "component", style=0, level=0},

    -- 购买体力: 已废弃
    --CompBuySpView = {ui = "@@@UI_comp_maitili", package = "component", style = 0, level = 0},
--
    CompXiaYiView  = {ui = "UI_comp_res_xiayi", package = "component", style=0, level=0},
    CompJinHuaView = {ui = "UI_comp_res_jinghua", package = "component", style=0, level=0},

    --出售道具弹窗 
    CompSellItemsView = {ui="UI_comp_sale",package="component",style=2,level=2, bgAlpha=180},
    CompBuyCoinMainView ={ui="UI_comp_buymoney",package="component",style=2,level=2, bgAlpha=180,screen = {1136,640}},
    CompBuySpMainView={ui="UI_comp_buytili",package="component",style=2,level=2, bgAlpha=180,screen = {1136,640}},
    -- 顶部资源条体力
    CompResTopSpView = {ui = "UI_comp_res_tili", package = "component", style = 0, level = 0},

    CompResTopSpView2 = {ui = "UI_comp_res_tili2", package = "component", style = 0, level = 0},

    -- 顶部资源条银币
    CompResTopCoinView = {ui = "UI_comp_res_tongqian", package = "component", style = 0, level = 0},
    -- 顶部资源条元宝
    CompResTopGoldView = {ui = "UI_comp_res_yuanbao", package = "component", style = 0, level = 0},
    CompResTopGoldView2 = {ui = "UI_comp_res_yuanbao2", package = "component", style = 0, level = 0},

    -- 顶部资源条赤铜
    CompResTopCopperView = {ui = "UI_comp_res_chitong", package = "component", style = 0, level = 0},
    -- 顶部资源魂牌
    CompResTopHunpaiView = {ui = "UI_comp_res_hunpai", package = "component", style=0, level=0},

    -- 顶部魔石
    CompResTopDimentsityView = {ui = "UI_comp_res_tower", package = "component", style=0, level=0},
    -- 顶部资源真气
    -- CompResTopZhenQiView = {ui = "UI_@@comp_res_zhenqi", package = "component", style=0, level=0},
    --购买天赋资源条UI
    CompResTopTalentView={ui="UI_comp_res_tianfu",package="component",style=2,level=2},
    --竞技场货币资源条
    CompResTopArenaCoinView = {ui = "UI_comp_res_xianyu", package = "component", style=2,level=0},
    --侠义值
    CompResTopXiayiView = {ui="UI_comp_res_xiayi", package="component", style=2, level=0},
    
    --仙气
    CompResTopXianqiView= {ui="UI_comp_res_xianqi", package="component", style=2, level=0},

    -- vip限制，引导去充值
    CompVipToChargeView = {ui = "UI_comp_vip_charge_tip", package = "component", style = 2, level = 3},
    -- 主角系统天赋点
    CompResTalentPointView = {ui = "UI_comp_res_tianfudian", package = "component", style = 2, level = 3},
    --主角星魂资源框
    CompStarSoulResView = {ui = "UI_comp_res_xinghun", package = "component", style = 0, level = 0},
    --五彩金丝线
    CompGarmentResView = {ui = "UI_comp_res_garment", package = "component", style = 0, level = 0},
    --须臾灵元
    CompResTopLingYuanView = {ui = "UI_comp_res_xuyulingyuan", package = "component", style = 0, level = 0},

    -- 委托币
    CompResTopDeputeView = {ui = "UI_comp_res_wtb", package = "component", style = 0, level = 0},
    --试炼组队令牌
    CompResTopSLView= {ui = "UI_comp_res_sl", package = "component", style = 0, level = 0},

    -- 通用商品详情
    CompGoodItemView = {ui = "UI_comp_xiangqing", package = "component", style = 2,screen = {1136,640}},

    -- 通用伙伴卡片UI
    CompPartnerCardView = {ui = "UI_comp_card", package = "component"},
    -- 通用玩家信息头像UI
    CompPlayerInfoView = {ui = "UI_comp_player",package = "component"},
    
    -- 充值跳转
    CompGotoRechargeView = {ui = "UI_comp_chongzhi", package="component", style =2,},
    --临时充值跳转
    -- TempGotoRechargeView = {ui = "UI_@@recharge_tishi",package="component", style =2,},

    CompNotifeAddFriendView = {ui = "UI_comp_friend_recommend", package="component", style =1,},
    -- loading
    -- CompLoading = {ui = "UI_comp_@@res_loading", package = "component", style = 0,screen = {1136,640} },
    -- new loading
    CompNewLoading = {ui = "UI_loading_new", package = "loading", style = 0,screen = {1136,640}},

    CompShareBtn = {ui = "UI_comp_sharegroup",package = "component"},

    --临时弹窗
    -- CompTC_TEMP  ={ui = "UI_@@comp_tc", package = "component", style = 0, }, 


    
    --断网弹窗
    CompServerOverTimeTipView = {ui = "UI_comp_duanwang", screen = {1136,640} ,package="component", style =2},
    Compnewbg1 = {ui = "UI_comp_newbg1", package="component", style =0},
    Compnewbg2 = {ui = "UI_comp_newbg2", package="component", style =0},
    Compnewbg3 = {ui = "UI_comp_newbg3", package="component", style =0},
    -- 联网失败解决方案列表界面
    CompNetworkSolutionList = {ui="UI_comp_gundong",screen = {1136,640},  package="component",stype=0},

    --
    CompScrollReward = {ui = "UI_comp_scrollReward", package = "component",bgAlpha = 0, style = 0, screen = {1136,640}},
    --邀请战斗
    -- BattleInvitationView = {ui = "UI_@@@comp_tuisong",  package = "component", style = 1, level = 1},

    PowerComponent = {ui = "UI_comp_powerNum",  package = "component"},

    --威力滚动
    PowerRolling = {ui = "UI_comp_rollingNumber",  package = "component",bgAlpha = 0 },

    --任务提示
    CompQuestInfo = {ui = "UI_comp_quest_info",  package = "component" },

    --主角升级提示面板 以及 体力消耗提示面板
    CompLevelUpTipsView = {ui = "UI_comp_zujueyindao", package = "component"},

    -- 更新版本界面
    VerView = {ui="UI_VersionUpdates",  package ="ver"},


    -- 主角升级
    CharLevelUpView = {ui="UI_char_levelUp",package = "char",
         level = 100, addTex = {"UI_char_common"},screen = {1136,640}},

    
    
    --战斗系统
    --战斗界面
    BattleView = {ui="UI_battle",package ="battle",bgAlpha =0, addTex = {"UI_battle_public"},screen = {1136,640}}, -- UI_battle  UI_zhandouzhong
    BattleMap = {ui="UI_map_1", package ="battle",},
    
    -- BattleTreasureView = {ui= "UI_@@battle_treasure",package = "battle" },
    --PVE战斗血条
    BattlePVEHpView = {ui="UI_battle_pve_hp",package="battle"},
    --PVP战斗血条
    BattlePVPHpView = {ui="UI_battle_pvp_hp",package="battle"},
    -- 战斗中可点击角色头像icon
    BattleIconView = {ui="UI_battle_4",package="battle"},
    -- 巅峰竞技场换人UI
    BattleCrossPeakView = {ui="UI_battle_5",package="battle"},
    -- 六界轶事刷怪玩法
    BattleRefreshView = {ui="UI_battle_6",package="battle"},
    -- 换灵
    BattleHuanLingView = {ui="UI_battle_huanling",package="battle"},
    -- -- 试炼战斗ui
    -- BattleTrialView = {ui="UI_battle_7",package="battle"},
    BattleBuffsView = {ui="UI_battle_buffs",package="battle"},
    -- 共闯秘境GVE
    BattleGuildView = {ui="UI_battle_8",package="battle"},
    BattleShenLiView = {ui="UI_battle_shenli",package="battle",style =2 },
    -- 新奇侠展示界面
    BattleParnterShowViewView = {ui="UI_battle_fang",package="battle"},
    -- 仙界对决bp选人
    BattleBpPartnerView = {ui="UI_battle_bppartner",package="battle",style =2 , bgAlpha = 100},
    -- 仙界对决bp选法宝
    BattleBpTreasureView = {ui="UI_battle_bptreasure",package="battle",style =2, bgAlpha = 100},
    -- 仙界对决bp结果展示界面
    BattleBpShowView = {ui="UI_battle_bpshow",package="battle",style =2, bgAlpha = 220},


    --暂停界面
    BattlePauseView ={ui = "UI_battle_pause",package = "battle",style =2 }, 
    --暂停界面内确认框
    BattlePauseTipView ={ui = "UI_battle_pause2",package = "battle",style =2 },


    --战斗胜利界面
    BattleWin ={ui = "UI_battle_win",package = "battle",screen = {1136,640}, bgAlpha = 255}, 
    --战斗失败界面
    BattleLose ={ui = "UI_battle_lose",package = "battle",screen = {1136,640}, bgAlpha = 255}, 
    -- 巅峰竞技场战斗结算界面
    BattleCrossPeakResult ={ui = "UI_battle_crosspeak_result",package = "battle"}, 
    -- 试炼战斗结算
    BattleTrialResult ={ui = "UI_battle_result_trial",package = "battle"}, 

 
    --新  战斗  伤害数据对比
    BattleAnalyze = {ui = "UI_battle_shuju",package = "battle",screen = {1136,640},bg = "battle_bg_dabeijing.png"},
    --新 战斗  宝箱奖励
    BattleReward = {ui = "UI_battle_jiangli",package = "battle",screen = {1136,640},bgAlpha = 255},
    BattleShareBossReward = {ui = "UI_battle_canzhanjianglixxx",package = "battle",screen = {1136,640}, bgAlpha = 255},

    -- 进行奇侠技能展示时的UI
    BattleSkillShowView = {ui="UI_battle_xianshuyanshi",package ="battle",bgAlpha =0,addTex = {"UI_battle_public"},screen = {1136,640}},

    --公共ui组件 不单独显示整个ui
    BattlePublic = {ui ="UI_battle_public",package="battle"},

    --网络请求
    ConnRepeateView = {ui ="UI_conn_reconnect",package ="conn" ,style =0,level = 20,bgAlpha =0  },
    ServerLoading = {ui ="UI_conn_loading",package ="conn",style = 0,screen = {1136,640} },


    --登入相关
    ---- 调试用登录界面
    ---- 正式版用登录界面
    LoginSelectWayView = {ui = "UI_login_select_way", package='login',screen = {1136,640} ,hideBg=true},
    LoginView = {ui = "UI_login_login", package='login',screen = {1136,640} ,style=2, level=3},
    LoginBindingAccount = {ui = "UI_login_up", package = "login",screen = {1136,640} , style = 2},
    --热更之后资源、lua加载界面 --用CompLoading
    --热更进度界面
    LoginLoadingView = {ui = "UI_login_loading", package = "login",screen = {1136,640} , style = 0,addTex = { "UI_login_common"}},
    --游戏更新异常
    LoginUpdateExceptionView = {ui = "UI_login_update_exception", package = "login",screen = {1136,640}, style = 2},
    ServerListView = {ui = "UI_login_xuanfu", package="login",screen = {1136,640} , style=2},
    SelectRoleView = {ui = "UI_login_select_role", package="login", screen = {1136,640},full = true,style=0},
    LoginSetNicknameView = {ui = "UI_login_name", package = "login",screen = {1136,640},style=2, level = 2},
    -- 热更确认
    LoginUpdateConfirmView = {ui = "UI_login_gengxinbao", package = "login",screen = {1136,640},style=0},
    -- 选服界面
    LoginEnterGameView = {ui = "UI_login_entergame", package='login', screen = {1136,640},hideBg=true},
    -- 协议界面
    GameAgreementView = {ui = "UI_login_xieyii", package='login', style=2, level=3,screen = {1136,640}},
    -- 登录排队界面
    LoginQueueUpView= {ui = "UI_login_paidui", package='login',screen = {1136,640} ,style=2, level=3},
    -- 首充
    ActivityFirstRechargeView = {ui = "UI_activity_1", package = "activity", screen = {1136,640}, style=2},

   
        
    --挑战
    ChallengeView = {ui = "UI_chal",package ="challenge",full = true},
    ChallengePvpView = {ui = "UI_chall",package ="challenge",full = true},


    -- 背包列表
    ItemListView = {ui = "UI_bag", package = "item", style = 0, level = 2,screen = {1136,640},bg="global_bg_tongyong.png"},
    -- 开宝箱奖品列表界面
    ItemBoxRewardView = {ui = "UI_bag_dakai", package = "item", screen = {1136,640}, style = 2, level = 2},
    -- 道具碎片合成结果界面
    ItemPieceComposeView = {ui = "UI_bag_hecheng", package = "item", screen = {1136,640}, style = 2, level = 2},
    ItemCombineView = {ui = "UI_bag_hecheng2", package = "item", style = 2, level = 2},
    ItemOptionView = {ui = "UI_bag_djxz", package = "item", style = 2, level = 2},
    ItemOptionRewardView = {ui = "UI_bag_huode", package = "item", style = 2, level = 2},
    
    -- 竞技场
    ArenaMainView = {ui = "UI_pvp", package = "pvp", style = 0,screen = {1136,640}, bg="arena_bg.png", level = 2,addTex= {"UI_pvp_common"}},
    -- 称号列表
    -- ArenaTitleView = {ui = "UI_pvp@@_chenghao", package = "pvp", style = 2, level = 2},
    -- 规则说明列表
    ArenaRulesView = {ui = "UI_pvp_shuoming", package = "pvp", style = 0, screen = {1136,640},bg="arena_bg.png" ,level = 2, scaleT = {0.85, 0.85, false, 50, -50}},
    -- 战斗回放列表
    ArenaBattlePlayBackView = {ui = "UI_pvp_huifang", package = "pvp",screen = {1136,640},bg="arena_bg.png", style = 0, level = 2},
    -- 战斗回放结果
    ArenaBattleReplayResult = {ui = "UI_pvp_replay_result", package = "pvp", style=2, },

    -- 竞技场天梯分割item 
    ArenaListCommonItem = {ui = "UI_pvp_rank_item_common", package = "pvp", style=2, },
    ArenaListTopItem = {ui = "UI_pvp_rank_item_top", package = "pvp", style=2},

    --竞技场主界面，显示挑战次数界面
    ArenaAddPvpCountView = {ui = "UI_pvp_add_count", package = "pvp", style=2},

    -- 清除挑战cd对话框
    ArenaClearChallengeCdPop = {ui = "UI_pvp_clearcd",screen = {1136,640}, package = "pvp", style=2},
    ArenaRefreshCdView = {ui = "UI_pvp_refresh_cd", package = "pvp", style=2},
    ArenaPlayerView = {ui = "UI_pvp_player", package = "pvp", style= 2 },
    -- 竞技场购买挑战次数
    ArenaBuyCountView = {ui = "UI_pvp_buycount", package = "pvp",screen = {1136,640}, style=2},

    -- 称号获得
    -- ArenaTitleAchieveView = {ui="UI_pvp_@@titlehuode", package = "pvp", style = 2, },

    ArenaBattleLoading = {ui="UI_pvp_loading", package = "pvp", screen = {1136,640}, style = 2},

    ArenaPlayerTalkView = {ui = "UI_pvp_player_talk", package = "pvp", style=2},
    --角色展示
    ArenaDetailView = {ui = "UI_pvp_information" ,package = "pvp",screen = {1136,640},style = 2,},

    -- 奖励主界面(奖励、兑换、排名)
    ArenaRewardMainView = {ui="UI_pvp_bg",package ="pvp",screen = {1136,640},bg = "arena_bg.png"},
    -- 奖励之奖励界面
    ArenaRewardScoreView = {ui="UI_pvp_jiangli",package="pvp",screen = {1136,640}},
    -- 奖励之兑换界面
    ArenaRankExchangeView = {ui="UI_pvp_duihuan",package ="pvp",screen = {1136,640}},
    -- 奖励之排名界面
    ArenaRewardRankView = {ui="UI_pvp_paiming",package ="pvp",screen = {1136,640}},
    
    --积分奖励
    -- ArenaScoreRewardView = {ui="UI_pvp_jiangli",package="pvp",screen = {1136,640},bg = "arena_bg.png"},
    --挑战5次
    ArenaChallenge5View = {ui = "UI_pvp_jieguo",package ="pvp",screen = {1136,640}, style = 2,},
    ArenaBuffView = {ui = "UI_pvp_benzhoujiacheng",package ="pvp",screen = {1136,640}, style = 1,},

    --家园 -- 主界面
    HomeMainView = {ui = "UI_world_cop", package = "home", style = 0,full = true, level = 0,  screen = {1136,640}},      
    HomeMainCompoment = {ui = "UI_world_downBtnsCompoment", package = "home"},   
    HomeMainUpBtnCompoment = {ui = "UI_world_upBtnsCompoment", package = "home"},   
    HonorView = {ui = "UI_honor", package = 'home', style = 0, level = 2,  bg = "arena_bg",screen = {1136,640}}, 
    SysWillOpenView = {ui = "UI_mainview_newsystips", package = 'home', style = 0, level = 2 ,bgAlpha = 110,screen = {1136,640}}, 
    -- 系统开启（因为和主城联系异常紧密，所以放在home里）
    SysOpenView = {ui = "UI_xitong_new", package = "home", style = 0, level = 0, hideBg=false, screen = {1136,640}, bgAlpha = 0},
    TrotHoseLampView={ui="UI_mainview_5",package="home",style=0,level=0 },--//跑马灯
    
    --玩家信息和设置
    PlayerInfoView = {ui = "UI_info", package = "playerinfo", style=0,screen={1136,640},bg = "char_bg_xiangqing" },
    PlayerSettingToggle = {ui = "UI_info_setting_toggle", package = "playerinfo", style=0},
    PlayerSettingSlider = {ui = "UI_info_setting_slider", package = "playerinfo", style=0},
    PlayerRenameView = {ui = "UI_info_rename", package = "playerinfo", style=2, level = 2,screen = {1136,640}},
    PlayerQianMingView = {ui = "UI_info_qianming", package = "playerinfo", style=2, level = 2,screen = {1136,640}},
    PlayerLogoutTipView = {ui = "UI_info_dengchu", package = "playerinfo",screen = {1136,640}, style=2, level = 2},
    PlayerHeadView = {ui = "UI_info_touxiang", package = "playerinfo", style=2, level = 2,screen={1136,640}},
    PushPermissionView = {ui = "UI_info_tiaozhuan", package = "playerinfo", style=2, level = 2,screen = {1136,640}},
    
    --主角购买头衔面板
    CharBuyTouXianView = {ui = "UI_info_touxian", package = "playerinfo", style = 0, level = 2,screen = {1136,640}},
    PlayerTouXianPromotion = {ui = "UI_info_touxiantisheng", bgAlpha = 200,package = "playerinfo", style = 0, level = 2,screen = {1136,640}},

    -- GameFeedBackView = {ui = "UI_info_fankui", package = "playerinfo", style=2,screen = {1136,640}},
    GameGonggaoView = {ui = "UI_info_gonggao", package = "playerinfo", style=1,screen={1136,640}, addTex = {"UI_info_common"}},
    CdkeyExchangeView = {ui = "UI_info_cdkey", package = "playerinfo", style=2},
    CdkeyExchangeResult = {ui = "UI_info_cdkey_reward", package="playerinfo", style=2},
    GameFeedBackView = {ui = "UI_info_fankui2", package = "playerinfo", style=1,screen = {1136,640}},
   

    --充值
    -- RechargeMainView = {ui = "UI_@@recharge",package = "recharge",style = 2, screen = {1136,640}},
    -- RechargeMainItemView = {ui = "UI_@@recharge_item",package = "recharge",style = 2},
    --新vip（package以前为vip但是UI在充值功能里）
    -- VipMainNewView = {ui = "UI_@@recharge_2",package = "recharge",style = 2, screen = {1136,640}},

    
    --商城 
    ShopView = { ui = "UI_shop",package = "shop" ,style = 1, addTex = {"UI_shop_common"} ,screen = {1136,640} },
    ShopNavBtnsView = {ui = "UI_shop_navbtns", package = "shop", style=2,screen = {1136,640} },
    ShopNavBtn = {ui = "UI_shop_nav_btn", package = "shop", style=2},
    --商店开启的时候也得打开 通用界面
    -- ShopKaiqi = {ui = "UI_@@shop_kaiqi",package = "shop", addTex = {"UI_shop_common"} ,level = 3, style=2,screen = {1136,640}},
    -- ShopJiefeng = {ui = "UI_shop_@@jiefeng",package = "shop",level =3 , bgAlpha=0, style=2},  
    --刷新界面
    ShopRefreshView = {ui = "UI_shop_shuaxin",package ="shop",level =3, style=2,screen = {1136,640} },
    -- ShopOpenConfirm = {ui = "UI_shop_@@open_confirm", package="shop", level=3, style=2,screen = {1136,640}},

    --试炼
    TrialNewEntranceView = {ui = "UI_trial_homepage2", package = "trial", style = 0, level = 2,screen = {1136,640}},
    TrialSweepNewView = {ui = "UI_trial_SaoDangNew", package = "trial", style = 2, level = 2},
    TrailRegulationView = {ui = "UI_trial_guize", package = "trial", style = 0, level = 2,screen = {1136,640}},
    -- TrialNewFriendPiPeiView = {ui = "UI_tria@@l_loading", package = "trial", style = 0, level = 2,bg = "trial_bg_loading",screen = {1136,640}},
    -- TriaNewlTeamView  = {ui = "UI_trial_tuis@@ong", package = "trial",bgAlpha=0,screen = {1136,640}},
  

--新版精英副本
    EliteMainView = {ui = "UI_elite_main", package = "elite", style = 0, level = 2,screen = {1136,640}, bg = "elite_bg_da.png"},
    EliteLieBiaoView = {ui = "UI_elite_liebiao", package = "elite",  style = 0, level = 2,screen = {1136,640} , bg = "bg_denglu.png",bgScale = 1},
    EliteConditionView = {ui = "UI_elite_tiaojian", package = "elite", style = 2, level = 3,hideBg=true},

    EliteRaidRetractView = {ui = "UI_elite_1", package = "elite", style = 2, level = 3,hideBg=true},
    EliteRaidUnfoldView = {ui = "UI_elite_2", package = "elite", style = 2, level = 3,hideBg=true},

    EliteMapView = {ui = "UI_elite_layer", package = "elite",  level = 3,full = true,hideBg=true,addTex = {"UI_elite_grid","UI_elite_grid2"}},
    EliteGearView = {ui = "UI_elite_jiguan", package = "elite", style = 2, level = 3,},
    ElitePoetryView = {ui = "UI_elite_shici", package = "elite", style = 2, level = 3,bgAlpha = 120},
    EliteMonsterView = {ui = "UI_elite_changjingjh", package = "elite", style = 2, level = 3},-- ,bg = "world_bg_beijing.png"
    EliteReExploreRecomfirmView = {ui = "UI_elite_queren", package = "elite", style = 2, level = 3,bgAlpha = 120},
    EliteItemView = { ui = "UI_elite_changjingitem",package = "elite", screen = {1136,640}},
    EliteGridView = {ui = "UI_elite_grid",style  = 0},
    EliteGridView2 = {ui = "UI_tower_grid2",style  = 0},
    EliteUIPowerComponent = {ui = "UI_elite_powerNum",  package = "elite"},
--新版精英副本


    --关卡loading
    RaidLoadingView = {ui = "UI_world_new_begin",addTex = {"UI_world_new_jump"},  package = "world", style = 0,bgAlpha = 0},
    WorldNewJump = {ui = "UI_world_new_jump",  package = "world", style = 0},
    --章节loadingView
    -- StoryLoadingView = {ui = "UI_world_new@@_end", package = "world", style = 0,bg = "arena_bg", screen = {1136,640}},
    -- 评级奖励界面
    WorldStarRewardView = {ui = "UI_world_6", package = "world", style = 2, level = 3},
    -- 扫荡结果界面
    WorldSweepListView = {ui = "UI_world_4", package = "world", style = 2, level = 3,screen = {1136,640}},
    -- 序章主界面
    -- WorldPrologueView = {ui = "UI_@@world_xuzhang", package = "world", style = 0, level = 2, full = true, bg = "world_bg_beijing.png"},
    -- 购买挑战次数 -- 20180403 这个界面目前只有精英副本在用
    WorldBuyChallengeTimesView = {ui = "UI_elite_buy", package = "world", screen = {1136,640},style = 2, level = 3},
    
    -- 新六界相关界面
    -- 六界主界面
    WorldMainView = {ui = "UI_world_new_main", package = "world", style = 0, level = 2,screen = {1136,640}, full = false,addTex = {"UI_shijieditu"}},
    -- 六界大地图界面
    WorldMainMapView = {ui = "UI_world_new_1", package = "world", style = 0, level = 2,screen = {1136,640}, full = true},
    -- 六界缩略图界面
    WorldAerialMapView = {ui = "UI_world_new_2", package = "world", style = 0, level = 2,screen = {1136,640}, full = true},
    -- 旧的回忆
    WorldPVEListView = {ui = "UI_world_new_3", package = "world", style = 0, level = 2,screen = {1136,640}, full = true,bg = "global_bg_tongyong.png"},
    -- 剧情动画使用的UI组件

    --称号和境界
    PlayerTitleAndCrown = {ui = "UI_world_playerTitle", package = "world"},

    -- 六界气泡界面
    WorldQiPaoView = { ui = "UI_world_paopao", package = "world"},

    WorldMainToMoreView = {ui = "UI_world_new_gengduo", package = "world", style = 0},









    --好友
    FriendMainView = {ui="UI_friend_main",package="friend",bg="global_bg_tongyong.png",screen = {1136,640}},
    FriendListView = {ui="UI_friend_haoyou_list",package="friend",screen = {1136,640}},

    FriendAddListView = {ui="UI_friend_tujian_list",package="friend",screen = {1136,640}},
    FriendAppListView = {ui="UI_friend_app_list",package="friend",screen = {1136,640}},

    FriendModifyNameView={ui="UI_friend_1",package="friend",style=2,level=2,screen = {1136,640}},
    FriendEmailview = {ui="UI_friend_mail2",package="friend",style=0,bg="global_bg_tongyong.png", level=2,screen = {1136,640}},
    -- FriendAddview = {ui="UI_friend_list",package="friend",style=2,level=2,screen = {1136,640}},
    CompModifyNameView = {ui="UI_comp_palyerxq_rename",package="component",style=2,level=2,screen = {1136,640}},
    FriendFindView = {ui="UI_friend_add",package="friend",style=2,level=2,screen = {1136,640}},



        
    --新手引导
    NpcContentWidget = {ui = "UI_novice", package = 'tutorial', style = 2}, 
    -- WrongClickTips = {ui = "UI_HongKui", package = 'tutorial', style = 2}, 
    GuideLine = {ui = "UI_guide_line", package = 'tutorial', style = 2}, 
    GuideVideoView = {ui = "UI_guide_Cartoon", package = 'tutorial', style = 2}, 

    --聊天
    ChatMainView = {ui = "UI_talk", package = 'chat', style = 0, level = 0},-- ,bgAlpha  = 0},
    ChatSetview  = {ui = "UI_talk_shezhi", package = 'chat', style = 0, level = 0,screen = {1136,640}},-- ,bgAlpha  = 0}, 
    ChatAddMainview = {ui = "UI_talk_talk", package = 'chat', style = 0, level = 0},-- ,bgAlpha  = 0},
    ChatExpression = {ui = "UI_talk_expression", package = 'chat', style = 0, level = 0},-- ,bgAlpha  = 0},
    CompPlayerDetailView={ui="UI_comp_palyerxq",package="component",style=2,level=2,screen = {1136,640}},
    ChatVoiceView = {ui="UI_talk_speak",package="chat",style = 2,level = 2,bgAlpha=0},
    ChatInfoCellView = {ui="UI_talk_1",package="chat",style = 2,level = 2},


    --欢乐签到
    HappySignView = {ui="UI_activity_happy_sign",package="happySign",bg = "global_bg_tongyong", screen = {1136,640}, style = 0, level = 2},
    HappySignShowView1 = {ui="UI_activity_tomorrow_nv",package="happySign",bg = "activity_bg_lyr", screen = {1136,640}, style = 1, level = 2},
    HappySignShowView2 = {ui="UI_activity_tomorrow_nan",package="happySign",bg = "activity_bg_yth", screen = {1136,640}, style = 1, level = 2},
    HappySignShowView3 = {ui="UI_activity_tomorrow_7tian",package="happySign",bg = "activity_bg_txj", screen = {1136,640}, style = 1, level = 2},
   

    --五行定位通用
    CompFivePosView = {ui="UI_comp_dingwei",package="component",style=2,level=2},
    --伙伴系统 
    PartnerView = {ui="UI_partner_main",package ="partner",style=0,bg="partner_bg_huobanbeijing.png", screen = {1136,640}},--伙伴系统主界面
    PartnerBtnView = {ui="UI_partner_list" , package ="partner", screen = {1136,640}}, --伙伴系统左侧伙伴列表管理
    PartnerTopView = {ui="UI_partner_func" , package="partner", screen = {1136,640}}, --伙伴系统功能按钮管理
    PartnerSkillView ={ui="UI_partner_skill",package="partner", screen = {1136,640},bg="partner_bg_xianshubeijing.png"}, --技能
    PartnerSkillSingleView ={ui="UI_partner_xianshuzhushi",package="partner", screen = {1136,640}},
    PartnerDisplayView = {ui="UI_partner_display", package="partner",bg="partner_bg_huobanbeijing.png", screen = {1136,640}}, 
    PartnerDisplayItemView = {ui="UI_partner_display_yong",package="partner", screen = {1136,640}}, 
    PartnerSkillDetailView = {ui="UI_partner_skil_tips",package="partner",bgAlpha=0,style = 2, screen = {1136,640}},
    PartnerCharSkillDetailView = {ui="UI_partner_skil_tips",package="partner",bgAlpha=0,style = 2, screen = {1136,640}},
    PartnerNewPartnerView = {ui="UI_partner_new_partner",package="partner", screen = {1136,640}},
    PartnerStarTips = {ui="UI_partner_star_levelup_tips",package="partner", screen = {1136,640}},
    PartnerEquipAwakInfoView = {ui="UI_partner_zbjx",package="partner", screen = {1136,640}},
    PartnerCompTitleView = {ui="UI_partner_title",package="partner", screen = {1136,640}},
    PartnerQingBaoView = { ui="UI_partner_qingbao",package="partner" , screen = {1136,640}},
    --PartnerCharSkillView = {ui="UI_@@partner_FaBao",package="partner", screen = {1136,640},bg="world_bg_beijing.png"}, --技能
    --伙伴主角升级提示
    PartnerCharTiShiView = {ui="UI_partner_ShengJiTiShi",package="partner",bgAlpha  = 100, screen = {1136,640}}, 
    --伙伴主角定位提示
    PartnerCharDWTiShiView = {ui="UI_partner_DingWeiTiShi",package="partner",bgAlpha  = 100, screen = {1136,640}}, 
    --升品
    PartnerUpQualityView = { ui="UI_partner_quality_levelup",package="partner" , screen = {1136,640}},
     --伙伴升级
    PartnerUpgradeView = {ui="UI_partner_ShengJi", package = "partner", bgAlpha  = 0,screen = {1136,640}},
    --伙伴升星
    PartnerUpStarView = {ui="UI_partner_star_levelup_2", package = "partner", screen = {1136,640}},--addTex = {"UI_lingmai_a","UI_lingmai_b"}
   
    --伙伴邀请
    PartnerCombineView = {ui="UI_partner_YaoQing" ,package="partner", screen = {1136,640}},
    --伙伴合成 
    PartnerCombineItemView = {ui="UI_partner_chengxu" ,package="partner", screen = {1136,640}},
    --伙伴升品道具合成UI
    PartnerUpQualityItemCombineView = {ui="UI_partner_combine" ,package="partner", screen = {1136,640}},
    --伙伴详情
    PartnerInfoUI = {ui="UI_df_info" ,package="partner", screen = {1136,640},scaleT = {1,0.45,false,0,0}},

    --伙伴装备强化
    PartnerEquipmentEnhanceView = {ui="UI_partner_zbqh" ,package="partner", screen = {1136,640}},
    -- PartnerEquipmentShenzhuangView = {ui="UI_@@partner_sz" ,package="partner",},
    --伙伴属性增加显示UI
    PartnerPropertyShowView =  {ui = "UI_star_levelup_info",package = "partner" ,bgAlpha = 255, screen = {1136,640}},
    PartnerOpenSkillShowView =  {ui = "UI_star_levelup_info2",package = "partner" ,bgAlpha = 255, screen = {1136,640}},
    PartnerTips = {ui = "UI_comp_tipsItem4", package = "partner", screen = {1136,640}},
    
    PartnerCrosspeakInfoView = {ui="UI_df_info" ,package="partner", screen = {1136,640},scaleT = {0.80,0.344,false,-30,433}},
    --伙伴皮肤券
    CompPartnerSkinResView = {ui = "UI_comp_res_partnerskin", package = "component", style = 0, level = 0},

    PartnerEquipAwakenShowView = {ui = "UI_star_levelup_info_copy",package = "partner" ,bgAlpha = 255, screen = {1136,640}}, 
    -- 奇侠霓裳 首次获得 分享
    PartnerSkinFirstShowView = {ui = "UI_paitnershow_main", package = "partnerSkinShow",bg="paternerskin_bg_lanbeijing.png", style = 0, level = 0},
    

    --通用伙伴详情显示界面
    PartnerCompInfoView = {ui = "UI_partner_compshuxing", package = "partner",style = 2, level = 0, scaleT = {0.9, 0.9, false, 30, -30}},
    
    --三皇抽卡
    NewLotterySpeedUpView = {ui="UI_lottery_jiasu", package = "newlottery",level = 2,screen = {1136,640}},
    -- 魂匣奖励
    -- NewLotterySoulRewardView = {ui = "UI_@@lottery_hunxia_reward", package = "newlottery", style = 0, screen = {1136,640}},
    -- NewLotterySoulView = {ui = "UI_@@lottery_hunxia", package = "newlottery", style = 0},
    -- NewLotteryTwoSureView = {ui = "UI_@@lottery_xf", package = "newlottery", style = 0, screen = {1136,640}},
    -- 预览列表界面
    NewLotteryPreviewListView = {ui = "UI_lottery_yvlan", package = "newlottery", style = 0, screen = {1136,640}},
    --]]
    CompSanhuangcoinview = {ui = "UI_comp_res_sanhuang", package = "component", style=0, level = 2},
    --聚魂
    GatherSoulMainView= {ui="UI_lottery_main", package = "gathersoul",level = 1, full = true,screen = {1136,640}},
    GatherSoulSpineView= {ui="UI_lottery_main_1", package = "gathersoul",level = 1, screen = {1136,640}},
    GatherSoulBtnView= {ui="UI_lottery_main_2", package = "gathersoul",level = 1, screen = {1136,640}},
    GatherSoulHuaXingView = {ui="UI_lottery_jvhun", package = "gathersoul",level = 1, screen = {1136,640}},
    GatherSoulContinueView = {ui="UI_lottery_main2", package = "gathersoul",level = 1},

    GatherSoulSpinePartnerListView= {ui="UI_lottery_yulan_pantner", package = "gathersoul",level = 1},
    
    GatherSoulRewardUIView = {ui="UI_lottery_m2", package = "gathersoul",level = 1, screen = {1136,640}},
    --聚魂快速消耗界面
    GatherSoulQuickCostView = {ui = "UI_lottery_tc", package = "gathersoul",style =2 },


    --目标总页面
    QuestMainView = {ui = "UI_task_main", package = "quest", style=0, level = 0, bg = "global_bg_tongyong.png", screen = {1136,640}},
    --成就界面
    QuestAhievementView = {ui = "UI_task_achievement", package = "quest", style = 0, level = 0},
    QuestEveryDayView = {ui = "UI_task_everyday", package = "quest", style = 0, level = 0},
    QuestTargetView = {ui = "UI_task_target", package = "quest", style = 0, level = 0},
    QuestUpgradeView = {ui = "UI_task_upgrade", package = "quest", style = 0, level = 0},
    QuestBiographyView = {ui = "UI_task_zhuanji", package = "quest", style = 0, level = 0},
    QuestAchieveRewardView = {ui = "UI_task_reward", package = "quest", style=0},

    -- 查看阵容系统
    -- LineUpMainView = {ui = "UI_view@@lineup", package = "lineup", style = 0, screen = {1136,640}},
    OtherTeamFormationDetailView = {ui = "UI_viewlineup_details", package = "viewlineup", style = 0, bg = "global_bg_teaminfo.png", screen = {1136,640}},
    LineUpPraiseListView = {ui = "UI_viewlineup_zan", package = "lineup", style = 0, screen = {1136,640}},
    LineUpEquipTipsView = {ui = "UI_viewlineup_tips_Fb", package = "lineup", bgAlpha=0, screen = {1136,640}},
    LineUpShareView = {ui = "UI_viewlineup_share", package = "lineup", style = 0, screen = {1136,640}},
    LineUpChPartnerView = {ui = "UI_viewlineup_genghuanHb", package = "lineup", style = 0, screen = {1136,640}},
    LineUpChTreasureView = {ui = "UI_viewlineup_genghuanFb", package = "lineup", style = 0, screen = {1136,640}},
    LineUpChBgView = {ui = "UI_viewlineup_genghuanBg", package = "lineup", style = 0, screen = {1136,640}},
   
    --时装系统
    GarmentMainView = {ui = "UI_garment_main", package = "garment", style = 0, level = 104, bgAlpha=0,screen = {1136,640}},--, bg = "garment_bg_beijing"
    GarmentBuyView = {ui = "UI_garment_buy", package = "garment", style = 0, level = 104, bgAlpha= 180, screen = {1136,640}},
    -- GarmentShowView = {ui = "UI_garment@@_show", package = "garment", style = 0, level = 104, bgAlpha=255, screen = {1136,640}},
    -- GarmentStoryView = {ui = "UI_garment@@_strory", package = "garment", style = 0, level = 104, bgAlpha=0, screen = {1136,640}},
    GarmentRewardView = {ui = "UI_garment_hd", package = "garment", level = 2, style = 2, screen = {1136,640}},
    -- 新签到
    NewSignView = {ui = "UI_sign_main", package = "sign", style = 0, level = 0, screen = {1136,640}},
    NewSignGetQianView = {ui = "UI_sign_chou1", package = "sign", style = 0, level = 0, screen = {1136,640}},
    NewSignTodayRewardView = {ui = "UI_sign_chou2", package = "sign", style = 0, level = 0, screen = {1136,640}},
    NewSignGetTotalView = {ui = "UI_sign_chou3", package = "sign", style = 0, level = 0, screen = {1136,640}},
    NewSignTipsView = {ui = "UI_sign_chou4", package = "sign", style = 0, level = 0, screen = {1136,640}},

    -- 挂机系统
    DelegateMainView = {ui = "UI_entrust_main", package = "delegate", style = 0, bg="delegate_bg", level = 0, screen = {1136,640}},
    DelegateSelectView = {ui = "UI_entrust_paiqian", package = "delegate", style = 0,level = 0},
    DelegateRewardView = {ui = "UI_entrust_jieguo", package = "delegate",bgAlpha=255, style = 0, level = 0, screen = {1136,640}},
    DelegateRefreshView = {ui = "UI_entrust_refresh", package = "delegate", style = 0, level = 0, screen = {1136,640}},
    DelegateSpeedUpView = {ui = "UI_entrust_jiasu", package = "delegate", style = 0, level = 0, screen = {1136,640}},
    DelegatePkgTipsView = {ui = "UI_entrust_tips", package = "delegate", style = 0, level = 0, screen = {1136,640}},
    DelegateNPCUI = {ui = "UI_entrust_three", package = "delegate", style = 0, level = 0},
    DelegateRecallTipsView = { ui = "UI_entrust_erciquerne", package = "delegate",screen = {1136,640}},
    DelegateTipsView = {ui = "UI_entrust_xiaofei", package = "delegate", style = 0,screen = {1136,640}},
    DelegateHelpView = { ui = "UI_entrust_banban", package = "delegate",screen = {1136,640}},

    -- 新法宝系统
    TreasureMainView = {ui = "UI_treasure_main", package = "newtreasure", style = 0,bg="treasure_bg", level = 0, screen = {1136,640}},
    TreasureStarAttrView = {ui = "UI_treasure_3", package = "newtreasure", style = 0, level = 0, screen = {1136,640}},
    TreasureInfoNewView = {ui = "UI_treasure_2", package = "newtreasure", style = 0, level = 0, screen = {1136,640}},
    --TreasureJinJieView = {ui = "UI_@@treasure_jinjie", package = "newtreasure",bgAlpha=0, style = 0, level = 0, screen = {1136,640}},
    --TreasureJueXingView = {ui = "UI_@@treasure_juexing", package = "newtreasure",bgAlpha=0, style = 0, level = 0, screen = {1136,640}},
    -- TreasureInfoView = {ui = "UI_t@@reasure_xiangqing", package = "newtreasure", style = 0, level = 2,bg="treasure_bg_dabeijing2",screen = {1136,640}},
    -- TreasureUpQualityShowView = {ui = "UI_@@treasure_jinjiechenggong", package = "newtreasure",bgAlpha=0, style = 0, level = 0, screen = {1136,640}},
    TreasureUpStarShowView = {ui = "UI_treasure_1", package = "newtreasure", style = 0, level = 0, screen = {1136,640},bgAlpha = 255},
    TreasureWanNengSuiPianView = {ui = "UI_treasure_4", package = "newtreasure", style = 0, level = 2,screen = {1136,640}},
    TreasureNewTips = {ui = "UI_comp_tipsItem4", package = "newtreasure"},
    TreasureShowView = {ui="UI_treasure_zhanshi",package="newtreasure",bgAlpha=200,style = 2, screen = {1136,640}},
    TreasureSkillTips = {ui="UI_treasure_tips",package="newtreasure",bgAlpha=0,style = 2},
    TreasureGuiZeView = {ui="UI_treasure_guize",package="newtreasure",style = 2, scaleT = {0.85, 0.85, false, 50, -50}},

    TreasureShareView = {ui="UI_treasure_zhansh",package="newtreasure",bgAlpha=0,style = 1},
    TreasureJihuoView = {ui = "UI_treasure_jihuo", package = "newtreasure", style = 0, level = 2, screen = {1136,640},bgAlpha = 255},

    --情缘系统
    -- LoveView = {ui = "UI_love_@@main", package = "love", style = 0, bg="love_bg_beijing", level = 0, screen = {1136,640}},
    -- LoveDetailView = {ui = "UI_l@@ove_activation", package = "love", style = 0, bg="love_bg_beijing", level = 0, screen = {1136,640}},
    -- LoveTipsView = {ui = "UI_love_tips", package = "love"},
    
    -- 新版情缘系统
    NewLoveMainView = {ui = "UI_love_main",package = "newLove",style = 0, level = 0, bg="love_bg_da"  ,screen = {1136,640}}, -- bg="love_bg_beijing",
    NewLovePartnerView = {ui = "UI_love_activation",package = "newLove",style = 0,bg="partner_bg_huobanbeijing", level = 0, screen = {1136,640}},

    NewLoveLevelDetailView = {ui = "UI_love_prop", package = "newLove", style = 0},
    NewLoveResonanceView = {ui = "UI_love_11", package = "newLove", style = 0},
    NewLovePromoteView = {ui = "UI_love_tsani", package = "newLove", style = 0},

    --通用伙伴
    CompPartnerIconView = {ui = "UI_comp_partner", package = "component"},
    ---称号
    TitleMainView = {ui="UI_title_main",package="title",bgAlpha=0,style = 2, screen = {1136,640},bg="sign_bg_beijing"},
    TitleDataView = {ui="UI_title_1",package="title",bgAlpha=0,style = 2, screen = {1136,640}},
    TitlexinxiView  = {ui="UI_title_xinxi",package="title",style = 2, screen = {1136,640}},
    TitleRewardView = {ui="UI_titile_jieguo",package="title",style = 2,bgAlpha = 200, screen = {1136,640}},--,bg = "global_txt_heidi"},

    -- 神器
    ArtifactMainView = {ui="UI_artifact_main",package="artifact",style = 0,screen = {1136,640},full = true},
    ArtifactSingleView = {ui="UI_artifact_up",package="artifact",style = 0,screen = {1136,640}},
    ArtifactCombinationView = {ui="UI_artifact_up2",package="artifact",style = 2,screen = {1136,640}},
    ArtifactDrawCardView = {ui="UI_artifact_chouka",package="artifact",style = 2,screen = {1136,640},bg="artifacts_bg_choukabeijing"},
    ArtifactDecomposeView = {ui="UI_artifact_fenjie",package="artifact",style = 2,screen = {1136,640}},
    ArtifactDecomposeSuccess =  {ui="UI_artifact_fenjiehuode",package="artifact",style = 0,screen = {1136,640},bgAlpha = 255},
    ArtifactSingleSuccess =  {ui="UI_artifact_jinjie",package="artifact",style = 0,screen = {1136,640},bgAlpha = 255},
    ArtifactCombinSuccess =  {ui="UI_artifact_zongjinjie",package="artifact",style = 0,screen = {1136,640},bgAlpha = 255},
    ArtifactSkillTipsView =   {ui="UI_artifact_tips",package="artifact",style = 0,screen = {1136,640}},
    ArtifactShareView =   {ui="UI_artifact_zhanshi",package="artifact",style = 0,screen = {1136,640}},
    ArtifactDesTips = {ui = "UI_atrifact_qiyuan", package = "artifact"},
    ArtifactActivationSuccess =  {ui="UI_artifact_jihuo",package="artifact",style = 0,screen = {1136,640},bgAlpha = 255},

    CompAttributeNumList = {ui = "UI_comp_piaozi", package = "component"},

    ArtifactReasureView = {ui = "UI_artifact_tc", package = "artifact", style = 0, level = 0, screen = {1136,640}},
    --单个
    ArtifactCardView =   {ui="UI_artifact_fuzhou",package="artifact",style = 0,screen = {1136,640}},
    --连抽
    ArtifactLCCardView =   {ui="UI_artifact_lianchou",package="artifact",style = 0,screen = {1136,640}},

    ArtifactLCMainCardView =   {ui="UI_artifact_lianchouchou",package="artifact",style = 0,screen = {1136,640},bgAlpha = 0},--,,bg="artifacts_bg_choukabeijing"},

    ArtifactPreviewView =   {ui="UI_artifact_yulan",package="artifact",style = 0,screen = {1136,640}},



    -- 锁妖塔系统 ===begin 主界面 地图界面(固定事件 怪 npc 宝箱 商店 道具)
    TowerMainView = { ui = "UI_tower_main", package = "tower", bgAlpha=0,screen = {1136,640},bg="tower_bg_suoayota"},
    TowerMainRewardView = { ui = "UI_tower_reward", package = "tower",screen = {1136,640}},
    TowerRuleView = { ui = "UI_tower_rule",package = "tower", screen = {1136,640}, scaleT = {0.85, 0.85, false, 50, -50}},
    -- 地图
    TowerMapView = { ui = "UI_tower_layer", package = "tower",bgAlpha=0,screen = {1136,640},full = true,addTex = {"UI_tower_grid","UI_tower_grid2"}},
    TowerObstacleView = { ui = "UI_tower_mupai", package = "tower",screen = {1136,640}},
    -- 固定事件
    TowerMatrixMethodView = { ui = "UI_tower_pozhen",package = "tower", bgAlpha=0,screen = {1136,640},bg="tower_bg_suoayota"},
    TowerWuLingPoolView = { ui = "UI_tower_wulingchi",package = "tower", bgAlpha=0,screen = {1136,640},bg="tower_bg_suoayota"},
    -- 怪
    TowerMonsterView = { ui = "UI_tower_tiaozhan", package = "tower", screen = {1136,640}},
    TowerMonsterDescriptionView = { ui = "UI_tower_tiaozhan_tips", package = "tower", screen = {1136,640},bgAlpha=0},
    -- npc事件
    TowerNpcChooseView = { ui = "UI_tower_npc", package = "tower",screen = {1136,640}},
    -- npc拼图游戏
    TowerPuzzleGameView = {ui = "UI_tower_subject",package = "tower", screen = {1136,640}},
    -- TowerNpcPrisonerView = { ui = "UI_tower_npc", package = "tower",screen = {1136,640}},
    TowerNpcRobberView = { ui = "UI_tower_shijian", package = "tower",screen = {1136,640}},
    TowerNpcMercenaryView = { ui = "UI_tower_yongbing", package = "tower",screen = {1136,640}},
    TowerNpcMercenaryDiedView = { ui = "UI_tower_yongbingdead", package = "tower",screen = {1136,640}},
    TowerThanksEventView = { ui = "UI_tower_tanks", package = "tower",screen = {1136,640}},
    TowerTreasureChooseView = { ui = "UI_tower_fabaoxuanze", package = "tower",screen = {1136,640}},
    -- 宝箱
    TowerChestView = {ui = "UI_tower_reset",package = "tower", screen = {1136,640}},
    -- 商店
    TowerMapShopView = { ui = "UI_tower_buji",package = "tower", screen = {1136,640},bgAlpha=0,bg="tower_bg_suoayota"},
    TowerSweepShopView = { ui = "UI_tower_buji_shop",package = "tower", screen = {1136,640},bgAlpha=0,bg="tower_bg_suoayota"},
    TowerChooseBuffTarget = { ui = "UI_tower_resurrection",package = "tower", screen = {1136,640}},
    TowerBuffListView = { ui = "UI_tower_attribute",package = "tower", screen = {1136,640}},
    -- 道具
    TowerUseItemView = {ui = "UI_tower_prop",package = "tower", screen = {1136,640}},
    TowerGiveUpItemView = { ui = "UI_tower_discard",package = "tower", screen = {1136,640}},
    TowerItemView = { ui = "UI_tower_changjingitem",package = "tower", screen = {1136,640}},
    -- 其他弹窗
    TowerPerfectView = {ui = "UI_tower_tongguan",package = "tower",screen = {1136,640},bgAlpha=0},
    TowerChooseTipsView = { ui = "UI_tower_tishi", package = "tower",screen = {1136,640}},
    TowerGetRewardView = { ui = "UI_tower_huode",package = "tower", style = 2, screen = {1136,640},bgAlpha = 255},
    TowerGridView = {ui = "UI_tower_grid",style  = 0},
    TowerGridView2 = {ui = "UI_tower_grid2",style  = 0},
    TowerWorldBossView = { ui = "UI_tower_help", package = "tower",screen = {1136,640}},
    -- 一层奖励预览列表
    TowerRewardPreviewView = {ui = "UI_tower_jianglixiangqing",package = "tower",screen = {1136,640},bgAlpha=0},
    -- 散灵法阵
    TowerRuneTempleView = {ui = "UI_tower_slfz",package = "tower",screen = {1136,640},bgAlpha=0},
    -- 搜刮及搜刮事件
    TowerCollectionView = {ui = "UI_tower_sougua",package = "tower",screen = {1136,640},bgAlpha=0},
    TowerCollectionEventView = {ui = "UI_tower_shijian2",package = "tower",screen = {1136,640},bgAlpha=0},



    --从福利里抽出来的活动
    NewActivityMainView = { ui = "UI_fuli_main", package = "activity",bgAlpha=0,screen = {1136,640},bg = "partner_bg_huobanbeijing.png"},
    
    --福利
    WelfareShopView = { ui = "UI_fuli_2", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfaregGtLingShiView= { ui = "UI_fuli_3", package = "welfare",bgAlpha=180,screen = {1136,640}},
    --体力领取
    WelfareTiLiRewardView =  { ui = "UI_fuli_food", package = "welfare",bgAlpha=180,screen = {1136,640}},

    WelfareNewMinView = { ui = "UI_fuli_main", package = "welfare",bgAlpha=0,screen = {1136,640},bg = "partner_bg_huobanbeijing.png"},
    WelfareActOneView = { ui = "UI_fuli_activity_1", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfareActTwoView = { ui = "UI_fuli_activity_2", package = "welfare",bgAlpha=0,screen = {1136,640}},   -- 单笔充值
    WelfareActThrView = { ui = "UI_fuli_activity_3", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfareActFouView = { ui = "UI_fuli_activity_4", package = "welfare",bgAlpha=200,screen = {1136,640}},
    WelfareActFivView = { ui = "UI_fuli_activity_5", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfareActSixView = { ui = "UI_fuli_activity_6", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfareActSevView = { ui = "UI_fuli_activity_7", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfareActNineView = { ui = "UI_fuli_activity_9", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfareActEigView = { ui = "UI_fuli_activity_zhaohui", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfareChongZhiView = { ui = "UI_fuli_chongzhifanli", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfareLeiChongView = { ui = "UI_fuli_activity_11", package = "welfare",bgAlpha=0,screen = {1136,640}},
    WelfareDanBiView = { ui = "UI_fuli_activity_10", package = "welfare",bgAlpha=0,screen = {1136,640}},
    
    WanderMerchantMainView = { ui = "UI_traveller_main", package = "welfare",bgAlpha=120,screen = {1136,640}},

    --开服抢购 没有激活夕瑶赠灯的情况下的弹窗
    WelfareActViewPopupWindow = {ui = "UI_fuli_tc1", package = "welfare"},

    -- WelfareActThrView = { ui = "UI_fuli_activity_3", package = "welfare",bgAlpha=0,screen = {1136,640}},
    --五行布阵
    WuXingTeamEmbattleView = {ui = "UI_team_formation",package = "teamembattle",style = 0,bg = "team_img_dabg.png",bgScale = 1,  screen = {1136,640}, foreverNew = true},
    WuXingTeamPartnerView = {ui = "UI_team_chai2",package = "teamembattle",bgAlpha = 0,screen = {1136,640}},
    WuXingPartnerDetailView = {ui = "UI_team_xiangqing",package = "teamembattle",screen = {1136,640}},
    WuXingPubTeamEmbattleView = {ui = "UI_team_chai1",package = "teamembattle",bgAlpha = 0,screen = {1136,640}},
    WuXingCheckTeamEmbattleView  = {ui = "UI_iewlineup_formation",package = "teamembattle",screen = {1136,640},style = 2,bg = "spirit_bg_wxbz.png",bgScale = 1},    
    WuXingNowDetailTips = {ui = "UI_team_chai4",package = "teamembattle",bgAlpha = 0,screen = {1136,640}},
    WuXingSkillSettingView = {ui = "UI_team_chai6",package = "teamembattle",screen = {1136,640}},
    WuXingCrossPeakTeamView = {ui = "UI_team_chai_df", package = "teamembattle", bgAlpha = 0, screen = {1136, 640}},
    WuXingTreasureInfoView = {ui = "UI_team_chai7", package = "teamembattle", bgAlpha = 150, screen = {1136, 640},style = 2},
    WuXingTreasureAttrView = {ui = "UI_team_tankuang1", package = "teamembattle", screen = {1136, 640}},
    WuXingLookOverView = {ui = "UI_team_chakandiqing", package = "teamembattle", style = 1, screen = {1136, 640}, bg = "team_img_dabg.png"},
    WuXingEnemyDetailView = {ui = "UI_team_guaiwubuzhen", package = "teamembattle", screen = {1136, 640}},
    WuXingBattleConfirmView = {ui = "UI_team_tc", package = "teamembattle"},
    
   -- 嘉年华
    CarnivalMainView = { ui = "UI_carnival_main", package = "carnival",style=0,screen = {1136,640}},
    CarnivalWholeTargetRewardView = { ui = "UI_carnival_1", package = "carnival",style=0,screen = {1136,640}},
    CarnivalWholeTargetConfirmView = { ui = "UI_carnival_2", package = "carnival",style=0,screen = {1136,640}},
    CompAirBubblesView = { ui = "UI_mainview_qipao", package = "component"},
	--公会
    GuildCreateAndAddView = {ui="UI_guild_rukou", package = "guild",level = 2, screen = {1136,640}},
    GuildCreateView = {ui="UI_guild_chuangjian", package = "guild",level = 2, screen = {1136,640}},
    GuildLeafView = {ui="UI_guild_chuangjian1", package = "guild",level = 2, screen = {1136,640}},
    GuildSetNameView = {ui="UI_guild_chuangjian2", package = "guild",level = 2, screen = {1136,640}},
    GuildRecommendView = {ui="UI_guild_chuangjian5", package = "guild",level = 2, screen = {1136,640}},
    GuildAddQQTextView = {ui="UI_guild_chuangjian6", package = "guild",level = 2, screen = {1136,640}},
    
    GuildPreviewView = {ui="UI_guild_chuangjian4", package = "guild",level = 2, screen = {1136,640}},
    GuildSetIconView = {ui="UI_guild_chuangjian3", package = "guild",level = 2, screen = {1136,640}},
    CompGuildIconCellView = {ui="UI_comp_guild_tubiao", package = "component",level = 2, screen = {1136,640}},
    GuildSucceedView = {ui="UI_guild_cjcg", package = "guild",level = 2, screen = {1136,640}},
    GuildAddView = {ui="UI_guild_jiaru", package = "guild",level = 2, screen = {1136,640}},
    GuildAddCellView = {ui="UI_guild_jiaru1", package = "guild",level = 2, screen = {1136,640}},
    GuildInFoView = {ui="UI_guild_xiangqing", package = "guild",level = 2, screen = {1136,640},bg="global_bg_tongyong.png"},
    GuildAnnouncement = {ui="UI_guild_xuanyan", package = "guild",level = 2, screen = {1136,640}},
    GuildSignView = {ui="UI_guild_qiandao", package = "guild",level = 2, screen = {1136,640}},
    GuildMemberListView = {ui="UI_guild_chengyuanliebiao", package = "guild",level = 2, screen = {1136,640}},
    GuildExitGuildView = {ui="UI_guild_tuichu", package = "guild",level = 2, screen = {1136,640}},
    GuildPlayerInfoView = {ui="UI_guild_ckxq", package = "guild",level = 2, screen = {1136,640}},
    GuildCompTextView = {ui="UI_guild_ckmyxiangqing", package = "guild",level = 2, screen = {1136,640}},
    GuildApplyView = {ui="UI_guild_shenqing", package = "guild",level = 2, screen = {1136,640}},
    CompResTopWoodView = {ui = "UI_comp_res_guild_mutou", package = "component", style = 0, level = 0},
    CompResTopStoneView = {ui = "UI_comp_res_guild_xingshi", package = "component", style = 0, level = 0},
    CompResTopJadeView = {ui = "UI_comp_res_guild_yunyu", package = "component", style = 0, level = 0},
    CompResTopToolView = {ui = "UI_comp_res_guild_tool", package = "component", style = 0, level = 0}, ---- 仙盟藏宝图的铲子
    GuildMainView = {ui="UI_guild_mainview", package = "guild",level = 2, screen = {1136,640},addTex={ "UI_mainview_common"}},
    GuildMainBuildView = {ui="UI_guild_main_jianzhu", package = "guild",level = 2, screen = {1136,640},bg="guild_bg_tqd.png"},
    --仙盟宝库界面
    GuildTreasureMainView = {ui = "UI_guild_baoku", package = "guild",level = 2, screen = {1136,640}, bg = "global_bg_tongyong.png"},
    GuildDigMapMainView = {ui = "UI_guild_dig", package = "guild",level = 2, screen = {1136,640}, bg = "world_bg_aeria.png"},
    --仙盟挖宝10个及以下获得奖品弹窗
    GuildDigRewardView = {ui = "UI_guild_dig_reward", package = "guild",bgAlpha = 255},
    GuildDonationView = {ui="UI_guild_jianzhu1", package = "guild",level = 2, screen = {1136,640}},
    GuildConstructionView = {ui="UI_guild_jianzhu2", package = "guild",level = 2, screen = {1136,640}},
    GuildUseBoxView = {ui="UI_guild_jianzhu3", package = "guild",level = 2, screen = {1136,640}},
    GuildUpgSucView = {ui="UI_guild_jianzhushengji", package = "guild",level = 2, screen = {1136,640}},
    GuildBlessingView = {ui="UI_guild_qifu", package = "guild",level = 2, screen = {1136,640},bg="global_bg_tongyong.png"},
    GuildBlessingOneView = {ui="UI_guild_qifu1", package = "guild",level = 2, screen = {1136,640}},
    GuildBlessingWishView = {ui="UI_guild_qifu2", package = "guild",level = 2, screen = {1136,640}},
    GuildWishView = {ui="UI_guild_qifu3", package = "guild",level = 2, screen = {1136,640}},
    GuildHistorRecView = {ui="UI_guild_qifu4", package = "guild",level = 2, screen = {1136,640}},
    GuildBlessingRewardView = {ui="UI_guild_qifujiangli", package = "guild",level = 2, screen = {1136,640}},
    -- GuildMainMapCommon = {ui="map_xianmengzhucheng", package = "guild",level = 2, screen = {1136,640}},
    GuildTitleView = {ui = "UI_guild_titlename", package = "guild",style=0,bgAlpha=0},
    GuildRulseView = {ui = "UI_guild_rules", package = "guild",style=0,bgAlpha=110, scaleT = {0.85, 0.85, false, 50, -50}},
    GuildWelfareMainView = {ui="UI_guild_zhangfang", package = "guild",level = 2, screen = {1136,640},bg="global_bg_tongyong.png"},
    GuildDailyWelfareView = {ui="UI_guild_meirihongli", package = "guild",level = 2, screen = {1136,640}},
    GuildLapseView = {ui="UI_guild_jianzhubuzu", package = "guild",level = 1, screen = {1136,640},style = 2},

    GuildOtherGuildListView = {ui="UI_guild_otherguild", package = "guild",level = 1, screen = {1136,640},style = 2},
    GuildRedPacketCellView = {ui="UI_guild_redpacket_qiang", package = "guild",level = 1, screen = {1136,640},style = 2,bgAlpha = 200},


    GuildHongBaoGetPathView = {ui="UI_guild_hongbaox3", package = "guild",level = 1, screen = {1136,640},style = 1},
    GuildSendHongBaoView = {ui="UI_guild_hongbaox2", package = "guild",level = 1, screen = {1136,640},style = 2},
    GuildQiangHongBaoView = {ui="UI_guild_hongbaox1", package = "guild",level = 1, screen = {1136,640},style = 2},
    GuildHongBaoInfoView = {ui="UI_guild_hongbaoxiangqing", package = "guild",level = 1, screen = {1136,640},style = 0},
    GuildMianPacketView = {ui="UI_mainnew_packet", package = "guild",level = 1, screen = {1136,640},style = 2},



    GuildTwoSureView = {ui="UI_guild_shengjibuzu", package = "guild",level = 1, screen = {1136,640},style = 2},
    GuildActiveRukouView = {ui="UI_guildhuodong_rukou", package = "guild",level = 1, screen = {1136,640},style = 2},
    GuildInfoUIView = {ui="UI_guild_xianmengxiangqing", package = "guild",level = 1, screen = {1136,640},style = 2},

    GuildShouJiView = {ui="UI_guild_shouji", package = "guild",level = 1,style = 0,bgAlpha=0},
    GuildExchangeView = {ui="UI_guild_jiaohuan", package = "guild",level = 1,style = 0,bgAlpha=0},
    GuildOpenAgainView = {ui="UI_guild_zaikai", package = "guild",level = 1,style = 0,bgAlpha=200},
    GuildShouJiListView = {ui="UI_guild_xzwp", package = "guild",level = 1,style = 0,bgAlpha=200},
    GuildSureExchangeView = {ui="UI_guild_jhqr", package = "guild",level = 1,style = 0,bgAlpha=200},

    -- 仙盟建筑 -- 无极阁相关界面
    GuildSkillMainView  = { ui = "UI_guild_skill_main",package = "guild" , bg = "guildskill_bg_dachangjing", style = 1,screen = {1136,640}},
    GuildSkillPropertiesView = { ui = "UI_guild_skill_all",package = "guild" ,style = 1,screen = {1136,640}},
    GuildSkillThemeLevelUpView = { ui = "UI_guild_skill_levelup",package = "guild" ,style = 1,screen = {1136,640}},
    GuildSkillThemeReachNewGradeView = { ui = "UI_guild_skill_view",package = "guild" ,style = 1,bgAlpha=255,screen = {1136,640}},

    -- 六界轶事
    MissionMainView = { ui = "UI_anecdote_rukou", package = "mission",style=0,screen = {1136,640},bg = "global_bg_tongyong" },
    MissionBoxView = {ui = "UI_anecdote_baoxiang", package = "mission",style=0,screen = {1136,640}},
    MissionRewardView = {ui = "UI_anecdote_jiangli", package = "mission",style=0,screen = {1136,640}},
    MissionMiaoshuView = {ui = "UI_anecdote_miaoshu", package = "mission",style=0,screen = {1136,640}},    --五灵通用res
    MissionQuestView = {ui = "UI_anecdote_dati", package = "mission",bgAlpha =255,style=0,screen = {1136,640}},
    MissionPVPInforView = { ui = "UI_anecdote_information", package = "mission",style=0,screen = {1136,640}},

    -- 共享副本
    ShareBossMainView = { ui = "UI_gongxiang_main", package = "shareboss",bg="global_bg_tongyong.png",  bgAlpha = 200},
    ShareFindRewardView = { ui = "UI_gongxiang_faxian", package = "shareboss", bgAlpha = 255},
    ShareBossHelpView = {ui = "UI_gongxiang_help", package = "shareboss", scaleT = {0.85, 0.85, false, 50, -50}},
    ShareBossDetailView = { ui = "UI_shareboss_boss", package = "shareboss"}, 
    ShareBossNewMainView = { ui = "UI_shareboss_newmain", package = "shareboss", bg="dreamland_bg_dabeijing.png"},
    ShareBossCompView = { ui = "UI_shareboss_boss1", package = "shareboss"},
    ShareBossNoBossTipsView = { ui = "UI_shareboss_no", package = "shareboss"},
    
    WuLingMainView = { ui ="UI_fivesoul_main",package = "wuling",bg = "fivesoul_bg_beijing.png",bgScale = 1,  screen = {1136,640}},
    --五灵通用res

    CompWuLingPointView  = {ui = "UI_comp_res_fivesoul_wld", package = "component", style=0, level=0},
    --五灵重置弹窗
    WuLingResetTips =  {ui="UI_fivesoul_queren", package = "wuling",level = 2, screen = {1136,640}},
    WuLingDetailTips = {ui = "UI_fivesoul_tips",package = "wuling",level = 2, screen = {1136,640}},
    WuLingUpgradeMatrixMethod = { ui = "UI_fivesoul_tschenggong",package = "wuling",level = 2, screen = {1136,640},bgAlpha = 255},
    WuLingUpgradeSpirit =  { ui = "UI_fivesoul_zlchenggong",package = "wuling",level = 2, screen = {1136,640},bgAlpha = 255},
    WuLingRuleTips = {ui = "UI_fivesoul_guize",package = "wuling",level = 2, screen = {1136,640}, scaleT = {0.85, 0.85, false, 50, -50}},    

    -- 仙盟GVE活动
    GuildActivityMainView = { ui = "UI_guildwanfa_main", package = "guildActivity",style=0,screen = {1136,640},bg="food_bg_dabeijing"},
    GuildActivityInteractView = { ui = "UI_guildwanfa_zhandou", package = "guildActivity",bgAlpha=0,full = true,screen = {1136,640}},
    GuildActivitySceneRuleView = { ui = "UI_guildwanfa_sm", package = "guildActivity",bgAlpha=0,screen = {1136,640}},
    GuildActivityCookingView = { ui = "UI_guildwanfa_1", package = "guildActivity",style=0,screen = {1136,640}},
    GuildActivityTeamMainView = { ui = "UI_guildwanfa_tiaozhanduiwu", package = "guildActivity",style=0,screen = {1136,640}},
    GuildActivityTeamCreateView = { ui = "UI_guildwanfa_zudui", package = "guildActivity",style=0,screen = {1136,640}},
    GuildActivityTeamQuitReconfirmView = { ui = "UI_guildwanfa_tuisong2", package = "guildActivity",style=0,screen = {1136,640}},
    GuildActivityTeamChooseView = { ui = "UI_guildwanfa_xuanzeduiyou", package = "guildActivity",style=0,screen = {1136,640}},
    GuildActivityTeamInviteView = { ui = "UI_guildwanfa_tuisong", package = "guildActivity",style=0,screen = {1136,640}},
    GuildActivityRuleView = { ui = "UI_guildwanfa_guize", package = "guildActivity",style=0,screen = {1136,640}},
    -- GuildActivityRewardRuleView = { ui = "UI_guildwanfa_ddjiangli", package = "guildActivity",style=0,screen = {1136,640},bg="world_bg_beijing"},
    GuildActivityKillMonsterRewardView = { ui = "UI_guildwanfa_hdjl", package = "guildActivity",style=0,screen = {1136,640},bgAlpha = 255},
    -- GuildActivityAccumulateRewardView = { ui = "UI_guildwanfa_ljjiangli", package = "guildActivity",style=0,screen = {1136,640},bg="world_bg_beijing"},
   
    GuildActivityEntranceView = { ui = "UI_guildwanfa_rukou", package = "guildActivity",style=0,screen = {1136,640},bg="food_bg_changjing1"},

    GuildActivityRewardView = { ui = "UI_guildwanfa_ddjiangli", package = "guildActivity",style=0,screen = {1136,640}},
    GuildActivityRewardStarView = { ui = "UI_guildwanfa_xingjijiangli", package = "guildActivity",style=0,screen = {1136,640}},
    GuildActivityRewardAccumulateView = { ui = "UI_guildwanfa_jifenjiangli", package = "guildActivity",style=0,screen = {1136,640}},
    GuildActivityScorePopupView = { ui = "UI_food_score",level = 999, package = "guildActivity",style=2},
    -- GuildActivityTeachView = { ui = "UI_guildwanfa_shoujijiaoxue", package = "guildActivity",style=0,screen = {1136,640},bg="world_bg_beijing"},


    -- 仙盟副本(共闯秘境)
    -- GuildBossMainView = { ui = "UI_gcmj_main", package = "guildBoss",style=0,screen = {1136,640},bg="world_bg_beijing"},
    GuildBossRuleView = { ui = "UI_gcmj_guize", package = "guildBoss",style=0,screen = {1136,640}},
    GuildBossOpenView = { ui = "UI_gcmj_main", package = "guildBoss",style=0,screen = {1136,640},bg="guildboss_bg_1"},
    GuildBossInfoView = { ui = "UI_gcmj_paihang", package = "guildBoss",style=0,screen = {1136,640},bg="guildboss_bg_2"},
    GuildBossInviteView = { ui = "UI_guildboss_yaoqingmengyou", package = "guildBoss",style=0,screen = {1136,640}},
    GuildBossBeInvitedView = { ui = "UI_guildboss_mijingyaoqing", package = "guildBoss",style=0,screen = {1136,640}},
    GuildBossGoAloneView = { ui = "UI_guildboss_tankuang", package = "guildBoss",style=0,screen = {1136,640}},

    GuildBossNotifyView = { ui = "UI_guildboss_xinfeng", package = "guildBoss",style=0,screen = {1136,640}},


    --体力恢复展示面板
    CompBuyTiLiTips = {ui = "UI_comp_buytili_tips", package = "component",style=0,bgAlpha=0},
    --铜钱购买tipView
    CompBuyCoinTips = {ui = "UI_comp_buytilitips2", package = "component",style=0,bgAlpha=0},

    --奇侠唤醒
    AwakenView = {ui = "UI_partnerawaken_1", package = "partnerAwaken",style=0,bg="partnerawaken_bg_jiakuan"},
    --升级奖励提示UI
    LevelRewardView = {ui = "UI_partnerawaken_2", package = "partnerAwaken",style=0,bg="partnerawaken_bg_jiakuan"},

    ---须臾仙境主界面
    WonderlandMainView = { ui = "UI_wonderland_maiin", package = "wonderland",style=0,screen = {1136,640},bg="wonderland_bg_dabeijing.png"},
    WonderlandListView = { ui = "UI_wonderland_ph", package = "wonderland",style=0,screen = {1136,640}},
    WonderlandTipsView = { ui = "UI_wonderland_tips", package = "wonderland",style=0,screen = {1136,640},bgAlpha = 0},
    
    --巅峰竞技场
    CrosspeakSegmentView = {ui = "UI_df_ltsm", package = "crosspeak",style=0,bgAlpha=200,scaleT = {0.85,0.9,false,20,-30}},
    -- CrosspeakMainView = {ui = "UI_@@df_main", package = "crosspeak",style=0,bgAlpha=0,bg = "crosspeak_bg_duijuebg"},
    CrosspeakGuizetView = {ui = "UI_df_gz", package = "crosspeak",style=0,bgAlpha=200, scaleT = {0.85, 0.65, true, 50, -50}},
    CrosspeakUpSegmentView = {ui = "UI_df_dwjs", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakBuyView = {ui = "UI_df_buy_cishu", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakRewardView = {ui = "UI_df_jl", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakMatchView = {ui = "UI_df_dd", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakRankView = {ui = "UI_df_paihang", package = "crosspeak",style=0,bgAlpha=200,scaleT = {0.9,0.98,false,40,-10}},
    CrosspeakNewMainView = {ui = "UI_df_main", package = "crosspeak",style=0,bgAlpha=0,bg = "crosspeak_bg_duijuebg"},
    CrosspeakBoxInfoView = {ui = "UI_df_tips", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakHuiFangView = {ui = "UI_df_hf", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakBuyTipsView = {ui = "UI_df_buy_cishu", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakRenWuView = {ui = "UI_df_renwu", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakRenwuBoxInfoView = {ui = "UI_df_renwuBox", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakRenwuRfView = {ui = "UI_df_shuaxin_queren", package = "crosspeak",style=0,bgAlpha=200},
    CrosspeakPlayerTipsView = {ui = "UI_df_tips2", package = "crosspeak",style=0,bgAlpha=200},

    ---关卡评论和排行
    RankAndCommentsView = {ui = "UI_pinglun_main", package = "newRankAndcomments",style=0,bgAlpha=200},
    RankMainView = {ui = "UI_pinglun_1", package = "newRankAndcomments",style=0,bgAlpha=200},
    CommentsMainView = {ui = "UI_pinglun_2", package = "newRankAndcomments",style=0,bgAlpha=200},
    RankAndComentsTwoView = {ui = "UI_pinglun_3", package = "newRankAndcomments",style=0,bgAlpha=200},

    RankTwoMainView = {ui = "UI_pinglun_1x", package = "newRankAndcomments",style=0,bgAlpha=200},
    CommentsTwoMainView = {ui = "UI_pinglun_2x", package = "newRankAndcomments",style=0,bgAlpha=200},


    --无底深渊
    EndlessMainView = {ui = "UI_wdsy_main", package = "endless", style=0, bg = "wdsy_bg_01.png"},
    EndlessBossView = {ui = "UI_wdsy_renren", package = "endless", style=0},
    EndlessFloorBaseView = {ui = "UI_wdsy_level1", package = "endless", style=0},
    EndlessBossDetailView = {ui = "UI_wdsy_xiangqing", package = "endless", style=0, scaleT = {0.85, 0.85, false, 50, -50}},
    EndlessBossRankView = {ui = "UI_wdsy_paihang", package = "endless", style=0},
    EndlessBoxRewardView = {ui = "UI_wdsy_6", package = "endless", style=0},
    EndlessRuleView = {ui = "UI_wdsy_guize", package = "endless", style=0, scaleT = {0.85, 0.85, false, 50, -50}},

    ---弹幕
    BarrageMainView = {ui = "UI_barrage_main", package = "barrage", style=0,bgAlpha=0},
    BarrageBarrageCellView = {ui = "UI_barrage_barrage", package = "barrage", style=0},
    BarrageVoiceMainView = {ui = "UI_barrage_2", package = "barrage", style=0,bgAlpha=200},


    -- 情景卡
    MemoryCardMainView = {ui = "UI_memory_main", package = "memory", style=0,bg="memory_bg_bj"},
    MemoryCardView = {ui = "UI_memory_card", package = "memory", style=0,bg="memory_bg_dkbj"},
    MemoryCardInfoView = {ui = "UI_memory_card_info", package = "memory"},
    MemoryCardInfoTwoView = {ui = "UI_memory_card_info2", package = "memory"},
    MemoryPingLunView = {ui = "UI_memory_pinglun2", package = "memory"},
    MemoryAttrView = {ui = "UI_memory_attr", package = "memory"},
    MemoryCardShareView = {ui = "UI_memory_fenxiang", package = "memory"},
    MemoryCardChipsShowView = {ui = "UI_memory_show", package = "memory"},
    MemoryCardConditionView = {ui = "UI_memory_wanfashuoming", package = "memory"},
    MemoryCardInfoThrView = {ui = "UI_memory_juanzhou", package = "memory"},
    MemoryView = {ui = "UI_memory_card_info3", package = "memory", level = 999},



    --主城的目标和聊天按钮
    QuestAndChatMainView = {ui = "UI_track_main", package = "quest", style=0,bgAlpha=200},
    QuestAddMainListView = {ui = "UI_track_zhuizonglan", package = 'quest', style = 0, level = 0,bgAlpha=0},
    -- {ui = "UI_track_zhuizonglan", package = "quest", style=0, bgAlpha=200},

    -- 快捷购买
    QuickBuyItemMainView = {ui = "UI_comp_qbuy", package = "quickBuy"},
    QuickBuyItemBuySucceedView = {ui = "UI_buy_succeed", package = "quickBuy"},

    -- 月卡
    MonthCardMainView = {ui = "UI_monthcard_main", package = "monthCard"},
    MonthCardInfoView = {ui = "UI_monthcard_yueka", package = "monthCard"},
    MonthCardLSTQView = {ui = "UI_monthcard_lingshitequan", package = "monthCard"},
    --月卡商城
    MallMainView = {ui = "UI_mall_main", package = "mall",bg="global_bg_tongyong.png" },
    CompMallItemView = {ui = "UI_comp_mall", package = "component"},
    CompMallItemInfoView = {ui = "UI_comp_charge_xiangqing", package = "component"},

    --排行榜界面
    RankListMainView = {ui = "UI_ranklist_main", package = "rankList", style=0, bg="global_bg_tongyong.png"},
    RankListAbilityInfoView = {ui = "UI_ranklist_playerInfo", package = "rankList"},
    RankListPartnerInfoView = {ui = "UI_ranklist_partnerInfo", package = "rankList"},
    RankListArtifactInfoView = {ui = "UI_ranklist_artifactInfo", package = "rankList"},
    RankListGuildInfoView = {ui = "UI_ranklist_guildInfo", package = "rankList"},
    RankListTreasureInfoView = {ui = "UI_ranklist_treasureInfo", package = "rankList"},
    RankListTreasureDetailView = {ui = "UI_ranklist_list", package = "rankList"},
    RankListArtifactDetailView = {ui = "UI_ranklistl_shenqixiangqing", package = "rankList"},
    RankListPlayerIconView = {ui = "UI_ranklist_playericon", package = "rankList"},

    --仙盟主界面
    GuildTaskMainView = {ui = "UI_guild_task_main", package = "guildTask", style=0, bg = "store_bg_dabeijing.png"},
    GuildTaskUIView = {ui = "UI_guild_task_1", package = "guildTask", style=0},
    GuildTaskHistoryView = {ui = "UI_guild_task_lishi", package = "guildTask", style=0},
    GuildTaskRankingView = {ui = "UI_guild_task_paihang", package = "guildTask", style=0},
    GuildTaskAchievementView = {ui = "UI_guild_task_2", package = "guildTask", style=0},
    GuildTaskItemListView = {ui = "UI_guild_task_tj", package = "guildTask", style=0},

    -- HomeUIhuodongrukou = {ui = "UI_@@huodongrukou", package = "home", style=0},

    CompChongZhiShowUI = {ui = "UI_chongzhifanli_main", package = "component"},

    -- 名册系统
    HandbookMainView = {ui = "UI_handbook_main", package = "handbook", style=0, bg="memory_bg_dkbj.png"},
    HandbookOneDirDetailView = {ui = "UI_handbook_mingce", package = "handbook",bg="memory_bg_dkbj.png"},
    HandbookExchangeDirView = {ui = "UI_handbook_mingce2", package = "handbook"},
    HandbookUpgradeOneDirView = {ui = "UI_handbook_tishengmingce", package = "handbook"},
    HandbookUnlockApositionView = {ui = "UI_handbook_tankuang", package = "handbook"},
    HandbookRuleView = {ui = "UI_handbook_rule", package = "handbook", style=2},

    HomeActiveQuickEntry = {ui = "UI_huodongrukou", package = "home"},
    
    BiographyMainView = {ui = "UI_biography_main", package = "biography", style=0, bg = "beta_img_beijing.png"},
    BiographyRewardView = {ui = "UI_biography_jl", package = "biography", style=0},
    BiographyGuideView = {ui = "UI_biography_guize", package = "biography", style=0},
    BiographySureView = {ui = "UI_biography_tc", package = "biography", style=0,screen = {1136,640}},
    BiographyOpenView = {ui = "UI_biography_renwukaiqi", package = "biography", style=0,bg = "partner_bg_huobanbeijing.png", screen = {1136,640}},


    --仙盟探索主界面
    GuildExploreMainView = {ui = "UI_explore_main",package = "guildExplore",full = true,addTex = {"UI_explore_grid"}},
    --网格
    GuildExploreGrid = {ui = "UI_explore_grid",package = "guildExplore"},

    --花费精力界面
    GuildExploreCostEnergy = {ui = "UI_explore_cost",package = "guildExplore",style =2},
    GuildExploreBuyEnergy = {ui = "UI_explore_buy",package = "guildExplore",style =2},

    --采矿主界面
    GuildExploreMiningView = {ui = "UI_explore_kuangmai", package = "guildExplore",style=0,bg="explore_bg_kuangmaibg.png"},
    --采矿和建筑的布阵界面
    GuildExploreLineupView = {ui = "UI_explore_paiqian", package = "guildExplore",style=0},
    --仙盟探索的建筑占坑界面
    GuildExploreBuildMainView = {ui = "UI_explore_chiyouzhong", package = "guildExplore",style=0,bg="explore_bg_jiajianzhu1.png"},
    --仙盟探索的建筑占领界面
    GuildExploreBuildPosView = {ui = "UI_explore_chiyouzijiemian", package = "guildExplore",style=0},
    --查看挑战的界面
    GuildExploreCheckPlayerView = {ui = "UI_explore_chakan", package = "guildExplore",style=0},
    --派遣记录
    GuildExploreCheckDispatchView = {ui = "UI_explore_yipaiqian", package = "guildExplore",style=0},
    --仙盟探索的任务界面
    GuildExploreQuestView = {ui = "UI_explore_task", package = "guildExplore",style=0},
    --排行榜界面
    GuildExploreRankView = {ui = "UI_explore_rank", package = "guildExplore",style=0},
    --事件记录界面
    GuildExploreEventView = {ui = "UI_explore_shijian", package = "guildExplore",style=0},
    --装备界面
    GuildExploreEquipmentView = {ui = "UI_explore_zhuangbei", package = "guildExplore",style=0},
    --顶部资源处理
    GuildExploreTopRes = {ui = "UI_explore_res", package = "guildExplore",style=0},
    --资源收集tips
    GuildExploreResTipsView = {ui = "UI_explore_tips", package = "guildExplore",style=1},
    --挑战奖励
    GuildExploreRewardView = {ui = "UI_explore_reward", package = "guildExplore",style=1},
    --灵泉buff列表
    GuildExploreHippBuffView = {ui = "UI_explore_shuxing", package = "guildExplore",style=1},
    --普通怪
    GuildExploreOrdinaryMonsterView = {ui = "UI_explore_tiaozhanA", package = "guildExplore",style=0,bgAlpha=0},
    --精英怪
    GuildExploreEliteMonsterView = {ui = "UI_explore_tiaozhanB", package = "guildExplore",style=0,bgAlpha=0},

    GuildExploreGetResView = {ui = "UI_explore_surprise", package = "guildExplore",style=0,bgAlpha=0},

    GuildExploreSurpriseView = {ui = "UI_explore_surprise", package = "guildExplore",style=0,bgAlpha=0},

    -- 小游戏系统
    -- 神秘人小游戏-猜人玩法
    GameShenMiRenView = {ui = "UI_game_cairen", package = "game"},
    -- 我是谁小游戏-猜人玩法
    GameGuessMeView = {ui = "UI_game_guessme", package = "game"},

    TakeDiscountView = {ui = "UI_traveller_zhekou", package = "welfare", style=2},

    -- 小游戏-答题
    GameQuestionView = {ui = "UI_game_dati", package = "game"},

    LuckyGuyMainView = {ui="UI_roulette_main",package ="luckyguy",style=0,bg="partner_bg_huobanbeijing.png", screen = {1136,640}},
    LuckyGuyRulseView = {ui = "UI_roulette_guize", package = "luckyguy",style=0,bgAlpha=110, scaleT = {0.85, 0.85, false, 50, -50}},
    CompResLuckyJiFenView = {ui = "UI_comp_res_choujiang", package = "component", style = 0, level = 0},
    BuyRouletteCoinView = {ui = "UI_roulette_buy", package = "luckyguy", style = 2, level = 100, screen = {1136,640}},
    LuckyGuyRewardView = {ui = "UI_roulette_huode", package = "luckyguy",bgAlpha = 255},
    LuckyguyNotEnough = {ui = "UI_rouleette_tips", package = "luckyguy", style = 2, level = 100, screen = {1136,640}},

    -- 公告系统
    NoticeMainView = {ui="UI_ntice_main", package = "notice"},

    --漂数字
    CompAttributeNumList = {ui="UI_comp_piaozi", package = "component"},

}

WindowsTools= {
}

function WindowsTools:getWindowsCfgs()
    return windowsCfgs;
end 


function WindowsTools:getWindowNameByUIName(uiName )
    for k,v in pairs(windowsCfgs) do
        if v.ui ==uiName then
            return k
        end
    end
    error("not find cfgs by uiName:"..tostring(uiName))
    return nil
end


--根据UIname获取windowName
function WindowsTools:getClassByUIName( uiName )
    local url = viewsPackage
    local uiFileUrl = "game/sys/view/"
    for k,v in pairs(windowsCfgs) do
        if v.ui == uiName then
            --如果是没有包路径
            if v.package =="" or not v.package then
                url = url.."."..k
            else
                url = url..".".. v.package.."."..k
            end
            uiFileUrl = uiFileUrl..v.package.."/"..  k ..".lua"
            break
        end
    end

    if url == viewsPackage then
        echoError("这个ui没有出现在WindowConfigs:",uiName,url)
        return UIBase
        -- echoError("not file uinameCfgs:"..tostring(uiName))
        -- return
    end
    --如果这个ui不存在 那么就直接返回 uiBase
    if not cc.FileUtils:getInstance():isFileExist(uiFileUrl) then
        echoWarn("创建了不需要单列类的",uiName)
        return UIBase
    end

    -- echo(uiName,"_______________uiName",url)
    local windowClass = require(url)
    return windowClass
end

--根据WindowName 获取 class
function WindowsTools:getClassByWindowName(windowName )
    local url = viewsPackage
    local cfg = windowsCfgs[windowName]
    if cfg.package =="" or not cfg.package then
        url = url..".".. windowName
    else
        url = url.."." ..cfg.package.."." .. windowName
    end
    if url == viewsPackage then
        echoError("not file uinameCfgs:"..tostring(windowName))
        return
    end
    local windowClass = require(url)
    return windowClass
end

--获取uiname
function WindowsTools:getUiName(viewName )
    local cfg = windowsCfgs[viewName]
    if not viewName then
        error("not fint viewName cfgs:"..tostring(viewName))
    end
    return cfg.ui
end

-- 获得ui配置信息
function WindowsTools:getUiCfg(viewName )
    local cfg = windowsCfgs[viewName]

    if not cfg then
        cfg = {}
        echoError("没有对应窗口的ui配置"..viewName)
    end
    -- 设置默认值
    cfg.level = cfg.level and cfg.level or 2
    cfg.cache = cfg.cache and cfg.cache or false
    cfg.style = cfg.style and cfg.style or 0
    -- cfg.pos   = cfg.pos and cfg.pos or {x=0,y=GameVars.height}
    if not cfg.pos then
        --这里的坐标偏移需要兼容老板 960 640的
        if not cfg.screen then
            cfg.pos = {x=GameVars.widthDistance/2,y=GameVars.height}
        else
            cfg.pos = {x=0,y=GameVars.height}
        end
    end
    

    return cfg
end

--创建Window 
function WindowsTools:createWindow(windowName,...)
    if not windowsCfgs[windowName] then 
        return nil
    end
    
    local uiName = self:getUiName(windowName)
    local classModel = self:getClassByWindowName(windowName)

    local view = UIBaseDef:createUIByName(uiName,classModel,...)
    -- if IS_CLEAR_PACKAGE_AFTER_HIDE then
    --     view.__debugCache = self:manageUIData(uiName)
    -- end

    return view -- UIBaseDef:createUIByName(uiName,classModel,...)
end

function WindowsTools:manageUIData( uiName )
    local cache = {}
    local cfgUIUrl = "uiConfig."
    local uiDatas = require(cfgUIUrl .. uiName)

    cache[uiName] = 1

    local function checkUI( chs )
        if chs then
            for i,v in ipairs(chs) do
                if v.t == "UI" then
                    cache[v.cl] = 1
                end
                checkUI(v.ch)
            end
        end
    end

    checkUI(uiDatas.ch)

    for k,v in pairs(windowsCfgs) do
        if cache[v.ui] then
            cache[v.ui] = viewsPackage..".".. v.package.."."..k
        end
    end

    return cache
end

function WindowsTools.showFloatBar(text, x, y, handler)
    local scene = display.getRunningScene()
    local barX = x or GameVars.cx-- + 80
    local barY = y or GameVars.cy-- - 150

    local layer = display.newColorLayer(cc.c4b(0,0,0,150)):addTo(scene):zorder(6)

    layer:setTouchEnabled(true)
    layer:setTouchSwallowEnabled(true)
    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "ended" then
            if not scene.updateNewer then
                if handler then handler() end
                layer:removeSelf()
            end
        end     
        return true
    end)    

    local textF = display.newTTFLabel({text = text, size = 24, color = cc.c3b(255,0,0)})
            :addTo(layer)
            :pos(barX,barY)

    textF:runAction( 
        transition.sequence({
        act.delaytime(0.5), 
        act.spawn(act.moveby(1, cc.p(0, 150)), act.fadeto(1, 1)), 
        act.callfunc(function() 
            layer:removeSelf() 
            if handler then handler() end 
            end)
        }))
end

