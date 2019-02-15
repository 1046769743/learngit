--
--Author:      zhuguangyuan
--DateTime:    2017-09-14 16:19:40
--Description: 嘉年华相关事件
--


local CarnivalEvent = {}

-- 一个主题开启
CarnivalEvent.ONE_THEME_OPENED = "ONE_THEME_OPENED"
-- 全目标任务开启（对应全目标奖励开始可领取）
CarnivalEvent.CARNIVAL_WHOLE_TARGET_REWARD_OPEN = "CARNIVAL_WHOLE_TARGET_REWARD_OPEN"
-- 嘉年华关闭(对应嘉年华倒计时)
CarnivalEvent.CARNIVAL_CLOSE = "CARNIVAL_CLOSE"



-- 领取一个任务奖励（对应更新全目标奖励进度）
CarnivalEvent.GOT_ONE_TASK_REWARD = "GOT_ONE_TASK_REWARD"
-- 领取全目标奖励
CarnivalEvent.GOT_WHOLE_TASK_REWARD = "GOT_WHOLE_TASK_REWARD"


-- 临时
-- 完成一个任务
CarnivalEvent.FINISH_ONE_TASK = "FINISH_ONE_TASK"

-- 嘉年华期数发生变化
CarnivalEvent.CARNIVAL_PERIOD_CHANGED = "CARNIVAL_PERIOD_CHANGED"

-- 嘉年华领取可选奖励
CarnivalEvent.GET_CARNIVAL_OPTION_REWARD = "GET_CARNIVAL_OPTION_REWARD"
-- 领取嘉年华可选奖励完毕
CarnivalEvent.CARNIVAL_OPTION_REWARD_CALLBACK = "CARNIVAL_OPTION_REWARD_CALLBACK"
return CarnivalEvent