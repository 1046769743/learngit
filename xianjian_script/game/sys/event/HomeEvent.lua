--家园系统相关事件
local HomeEvent = {}

HomeEvent.GET_ONLINE_PLAYER_EVENT = "GET_ONLINE_PLAYER_EVENT";
HomeEvent.GET_ONLINE_PLAYER_OK_EVENT = "GET_ONLINE_PLAYER_OK_EVENT";
HomeEvent.GET_ONLINE_PLAYER_EVENT_AGAIN = "GET_ONLINE_PLAYER_EVENT_AGAIN";
HomeEvent.GET_ONLINE_PLAYER_EVENT_OK_AGAIN = "GET_ONLINE_PLAYER_EVENT_OK_AGAIN";

HomeEvent.RED_POINT_EVENT = "RED_POINT_EVENT";
HomeEvent.CHANGE_INAITATION_MATCH_ID_EVENT = "CHANGE_INAITATION_MATCH_ID_EVENT";

HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW = "HOMEEVENT_COME_BACK_TO_MAIN_VIEW";

HomeEvent.SHOW_HOME_VIEW = "SHOW_HOME_VIEW";
HomeEvent.OTHER_VIEW_ON_HOME = "OTHER_VIEW_ON_HOME";

HomeEvent.TELL_HOME_VIEW_ADD_NPC_HEAD_GLOW_EVENT = "TELL_HOME_VIEW_ADD_NPC_HEAD_GLOW_EVENT";

HomeEvent.CLICK_NPC_EVENT = "CLICK_NPC_EVENT";

--//走马灯消息
HomeEvent.TROT_LAMP_EVENT = "TROT_LAMP_EVENT";

HomeEvent.CHANGE_CAMERA_POSX = "CHANGE_CAMERA_POSX";

HomeEvent.SYSTEM_OPEN_EVENT = "SYSTEM_OPEN_EVENT";

HomeEvent.SHOW_RES_COMING_ANI = "SHOW_RES_COMING_ANI";

HomeEvent.REFRESH_HONOR_EVENT = "REFRESH_HONOR_EVENT";  --刷新主城六界第一的玩家

HomeEvent.HOME_MODEL_BUTTON_SHOW = "HOME_MODEL_BUTTON_SHOW";   --主界面按钮是否显示

HomeEvent.HOME_VOICE_PLAY = "HOME_VOICE_PLAY";    ---主城背景音乐恢复

HomeEvent.BLACK_TO_MAINVIEW_FRESH_MAP_COT = "BLACK_TO_MAINVIEW_FRESH_MAP_COT";--回到主界面刷新地图和按钮

HomeEvent.SHOW_AIR_BUBBLE_UI = "SHOW_AIR_BUBBLE_UI"  --显示气泡的事件监听


HomeEvent.HIDDEN_MORE_VIEW = "HIDDEN_MORE_VIEW";  --隐藏更多的按钮面板

HomeEvent.LIMIT_NEXT_UI = "LIMIT_NEXT_UI"; --限时活动入口的下一



--充值返利的事件
HomeEvent.SHOW_CHONGZHI_UI_EVENT = "SHOW_CHONGZHI_UI_EVENT"  --隐藏更多的按钮面板
--点击gohome键回到主城事件
HomeEvent.CLICK_GOHOME_EVENT = "HomeEvent.CLICK_GOHOME_EVENT"

--显示主界面的所有按钮和动画
HomeEvent.SHOW_BUTTON_UI_VIEW = "SHOW_BUTTON_UI_VIEW"

--主城按钮特效添加
HomeEvent.SHOW_BUTTON_EFFECT = "SHOW_BUTTON_EFFECT"


return HomeEvent


