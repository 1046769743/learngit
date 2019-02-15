--用户系统相关事件
local TutorialEvent = {}

TutorialEvent.CustomParam = {
	FirstInHomeTown = "FirstInHomeTown", --首次进入主界面(主城与六界合并了，此消息废弃)
	LotterySuccess = "LotterySuccess", --完成抽卡
	PlotFinish = "PlotFinish", -- 对话完成触发类型
	AnimBoxLock = "AnimBoxLock", -- 箱子锁事件
	Skip = "Skip", -- 跳过当前步
	worldMoveFinish = "worldMoveFinish", -- 六界移动到指定位置(废弃)
	worldComeToTop = "worldComeToTop", -- 六界到顶层
	partnerAnimFinish = "partnerAnimFinish", -- 升星动画完毕
	ToNewMainView = "ToNewMainView",   --到新主城界面发送的事件
	partnerTabChange = "partnerTabChange_", -- 奇侠页签切换，连接系统名
	guildTabActivity = "guildTabActivity", -- 仙盟进入活动页签的消息
}

--界面改变
TutorialEvent.TUTORIALEVENT_VIEW_CHANGE = "TUTORIALEVENT_VIEW_CHANGE";

--功能开启
TutorialEvent.TUTORIALEVENT_SYSTEM_OPEN = "TUTORIALEVENT_SYSTEM_OPEN";

--所有的新手都完成
TutorialEvent.TUTORIALEVENT_FINISH_ALL = "TUTORIALEVENT_FINISH_ALL";

--序章触发新手消息
TutorialEvent.TUTORIALEVENT_PROLOGUE_TRIGGER = "TUTORIALEVENT_PROLOGUE_TRIGGER";

--通用新手引导需要的消息
TutorialEvent.CUSTOM_TUTORIAL_MESSAGE = "CUSTOM_TUTORIAL_MESSAGE";

--序章开启
TutorialEvent.PRO_LOGUE_OPEN = "PRO_LOGUE_OPEN";

--滑动结束
TutorialEvent.TUTORIAL_SLIDE_OVER_EVENT = "TUTORIAL_SLIDE_OVER_EVENT";

--伙伴进行攻击
TutorialEvent.TUTORIAL_PARTNER_ATK = "TUTORIAL_PARTNER_ATK";

--抽卡成功
TutorialEvent.TUTORIAL_FINISH_LOTTERY = "TUTORIAL_FINISH_LOTTERY";

--暂停恢复新手引导
TutorialEvent.TUTORIAL_SET_PAUSE = "TUTORIAL_SET_PAUSE"

-- 拖动布阵成功
TutorialEvent.TUTORIAL_FINISH_FORMATION = "TUTORIAL_FINISH_FORMATION"

-- 战斗结束
TutorialEvent.TUTORIAL_FINISH_BATTLE = "TUTORIAL_FINISH_BATTLE"

-- 视频播放完成
TutorialEvent.TUTORIAL_FINISH_VIDEO = "TUTORIAL_FINISH_VIDEO"

-- 特殊消息序章战斗结束（因为以前的序章战斗的结束判定很混乱）
TutorialEvent.TUTORIAL_FINISH_PROLOGUE_BATTLE = "TUTORIAL_FINISH_PROLOGUE_BATTLE"

-- 新手引导完成一个步的时候发出，解决延迟标记位更新的问题
TutorialEvent.TUTORIAL_FINISH_ONE_GROUP = "TUTORIAL_FINISH_ONE_GROUP"

-- 引导临时的升级消息
TutorialEvent.TUTORIAL_LEVEL_UP = "TUTORIAL_LEVEL_UP"

-- 引导DEBUG的标记
TutorialEvent.TUTORIAL_DEBUG = "TUTORIAL_DEBUG"

-- 聚魂(动画)播放完毕
TutorialEvent.TUTORIAL_FINISH_JUHUN = "TUTORIAL_FINISH_JUHUN"

-- 仙盟酒家特殊引导结束后的消息
TutorialEvent.TUTORIAL_FINISH_GUILDACTIVITY = "TUTORIAL_FINISH_GUILDACTIVITY"

-- 引导的UI出现与消失的消息
TutorialEvent.TUTORIAL_UI_SHOWORHIDE = "TUTORIAL_UI_SHOWORHIDE"

-- 触发式引导被去除
TutorialEvent.TUTORIAL_TRIGGER_REMOVE = "TUTORIAL_TRIGGER_REMOVE"

return TutorialEvent