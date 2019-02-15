--三皇抽奖系统
--2016-1-4 20:20
--@Author:wukai

--//三皇抽奖事件
local   NewLotteryEvent=NewLotteryEvent or {};

NewLotteryEvent.REFRESH_FREE_UI = "REFRESH_FREE_UI"  --刷新免费抽奖界面
NewLotteryEvent.REFRESH_RMBPAY_UI = "REFRESH_RMBPAY_UI" --刷新元宝抽奖界面
NewLotteryEvent.START_LOTTERY = "START_LOTTERY" --开始抽奖
NewLotteryEvent.RESUME_REWARD_ITEMS = "RESUME_REWARD_ITEMS" --繼續顯示獎勵
NewLotteryEvent.BLACK_LOTTERY_MAIN = "BLACK_LOTTERY_MAIN" --返回到
NewLotteryEvent.DELETE_LITTERY_LAYER = "DELETE_LITTERY_LAYER" ---删除商店层
NewLotteryEvent.REFRESH_MAIN_UI = "REFRESH_MAIN_UI" ---替换特效监听界面
NewLotteryEvent.ADD_EILLPSE_EFFECT = "ADD_EILLPSE_EFFECT" -- 添加抽奖后的替换特效
NewLotteryEvent.REFRESH_LOTTERY_SHOP_UI = "REFRESH_LOTTERY_SHOP_UI"
NewLotteryEvent.GET_AUDIO_BLACK_MAIN = "GET_AUDIO_BLACK_MAIN"  --获得界面音乐返回
-- NewLotteryEvent.CD_ID_NEWLOTTERY_TOKEN_FREE = "CD_ID_NEWLOTTERY_TOKEN_FREE" --给主界面发消息
NewLotteryEvent.REFRESH_REPLACE_VIEW = "REFRESH_REPLACE_VIEW"   --刷新替换界面的数据
NewLotteryEvent.ONTIME_REFRESH_SHOP_VIEW = "ONTIME_REFRESH_SHOP_VIEW"  --时间到刷新福利商店数据

NewLotteryEvent.REFRESH_CREATE_VIEW = "REFRESH_CREATE_VIEW"   --刷新造物界面的事件

NewLotteryEvent.CLOSS_JIEGUO_VIEW = "CLOSS_JIEGUO_VIEW"  --退出结果界面

NewLotteryEvent.REFRESH_CHOUKA_MAIN_UI = "REFRESH_CHOUKA_MAIN_UI"  --刷新抽卡主界面

--三皇台四测功能
NewLotteryEvent.NEXT_VIEW_UI = "NEXT_VIEW_UI"  --跳转到下一页
NewLotteryEvent.SHOW_ALL_BUTTON_EVENT = "SHOW_ALL_BUTTON_EVENT"  --显示界面上所有按钮的监听事件
NewLotteryEvent.MOVE_CELL_RUNACTION = "MOVE_CELL_RUNACTION"  --灯笼飞的位置
NewLotteryEvent.GATHERSOUL_ALL_TODO_VIEW = "GATHERSOUL_ALL_TODO_VIEW" --时候存在化形的灯
NewLotteryEvent.TOUCH_UI_STOP_RUNACTION = "TOUCH_UI_STOP_RUNACTION"  --停止动画

NewLotteryEvent.SHOW_SPEEDUP_BUTTON = "SHOW_SPEEDUP_BUTTON"   --显示加速按钮事件

NewLotteryEvent.REMOVE_ALL_VIEW_CELL =  "REMOVE_ALL_VIEW_CELL"   --删除主界面的上的造物控件
NewLotteryEvent.REFRESH_ZAOWU_FINISH_UI = "REFRESH_ZAOWU_FINISH_UI"  --点击造物完成的事件

NewLotteryEvent.ADD_JUHUN_EFFECT = "ADD_JUHUN_EFFECT"  --添加聚魂特效

NewLotteryEvent.CLOSE_FINISH_UI_TOBACK_FRAME = "CLOSE_FINISH_UI_TOBACK_FRAME"  --点击确定回到最下面的位置

NewLotteryEvent.QUICK_BUY_SOUL = "QUICK_BUY_SOUL"  ----点击自动购买

NewLotteryEvent.CONTINUE_BUTTON = "CONTINUE_BUTTON"  --继续购买按钮

NewLotteryEvent.CONTINUE_BUTTON_FINISH = "CONTINUE_BUTTON_FINISH"  --继续购买完成按钮
NewLotteryEvent.ALLFINISH_JUHUN = "ALLFINISH_JUHUN"  --所有聚魂完成

return  NewLotteryEvent;