--[[
    Filename:    TeamFormationEvent
    Author:      caocheng@playcrab 
    Datetime:    2017-06-30 10:29:09
    Description: 现在是五行布阵使用的这个event
--]]
local TeamFormationEvent = {}

--系统阵容消息变化
TeamFormationEvent.TEAMFORMATIONEVENT_CHANGE_TEAMFORMATION = "TEAMFORMATIONEVENT_CHANGE_TEAMFORMATION"
TeamFormationEvent.PVP_DEFENCE_CHANGED = "PVP_DEFENCE_CHANGED"
--更新法宝
TeamFormationEvent.UPDATA_TREA = "TeamFormationEvent.UPDATA_TREA"
--更新滑动条
TeamFormationEvent.UPDATA_SCROLL = "TeamFormationEvent.UPDATA_SCROLL"
--更新spine站位
TeamFormationEvent.UPDATA_HEROANIMATION = "TeamFormationEvent.UPDATA_HEROANIMATION"
--更新站位数目
TeamFormationEvent.UPDATA_POSNUMTEXT = "TeamFormationEvent.UPDATA_POSNUMTEXT"
--更新五行信息
TeamFormationEvent.UPDATA_WUINGDATA = "TeamFormationEvent.UPDATA_WUINGDATA"
--关闭主界面
TeamFormationEvent.CLOSE_TEAMVIEW = "TeamFormationEvent.CLOSE_TEAMVIEW"
--关闭详情界面
TeamFormationEvent.CLOSE_TEAMDETAILVIEW = "TeamFormationEvent.CLOSE_TEAMDETAILVIEW"
--播放上阵特效
TeamFormationEvent.PLAY_UPTOTEAMANIMATION = "TeamFormationEvent.PLAY_UPTOTEAMANIMATION"
--多人上阵特效
TeamFormationEvent.PLAY_UPTOMULTITEAMANITION = "TeamFormationEvent.PLAY_UPTOMULTITEAMANITION"
--播放下阵特效
TeamFormationEvent.PLAY_GIVEUPTEAMANITION = "TeamFormationEvent.PLAY_GIVEUPTEAMANITION"
--屏蔽界面点击
TeamFormationEvent.CLOSE_SCREANONCLICK = "TeamFormationEvent.CLOSE_SCREANONCLICK"
--打开界面点击
TeamFormationEvent.OPEN_SCREANONCLICK = "TeamFormationEvent.OPEN_SCREANONCLICK"
--竞技场进攻阵容变化
TeamFormationEvent.PVP_ATTACK_CHANGED = "TeamFormationEvent.PVP_ATTACK_CHANGED"
--候补阵容发生变化
TeamFormationEvent.CANDIDATE_CHANGED = "TeamFormationEvent.CANDIDATE_CHANGED"
--候补阵容未满
TeamFormationEvent.CANDIDATE_NOT_FULL = "TeamFormationEvent.CANDIDATE_NOT_FULL"
--点击切换到五灵
TeamFormationEvent.CHANGED_TO_WULING = "TeamFormationEvent.CHANGED_TO_WULING"
--点击切换到奇侠
TeamFormationEvent.CHANGED_TO_PARTNER = "TeamFormationEvent.CHANGED_TO_PARTNER"
--上阵五灵法阵发生变化
TeamFormationEvent.TEAM_WULING_CHANGED = "TeamFormationEvent.TEAM_WULING_CHANGED"
--竞技场出手顺序设置界面关闭
TeamFormationEvent.PVP_SKILLVIEW_CLOSED = "TeamFormationEvent.PVP_SKILLVIEW_CLOSED"
--五行特效发生变化
TeamFormationEvent.WUXING_ANIM_CHANGED = "TeamFormationEvent.WUXING_ANIM_CHANGED"
--点击奇侠上阵事件
TeamFormationEvent.TEAMFORMATIONEVENT_UP_PARTNER = "TEAMFORMATIONEVENT_UP_PARTNER"
--点击五灵上阵事件
TeamFormationEvent.TEAMFORMATIONEVENT_UP_WULING = "TEAMFORMATIONEVENT_UP_WULING"
--关闭奇侠详情界面
TeamFormationEvent.CLOSE_PARTNER_DETAILVIEW = "CLOSE_PARTNER_DETAILVIEW"
--关闭查看敌情界面
TeamFormationEvent.CLOSE_LOOK_OVER_VIEW = "CLOSE_LOOK_OVER_VIEW"
--多人布阵上阵操作
TeamFormationEvent.MULTI_UP_PARTNER = "MULTI_UP_PARTNER"
--多人布阵交换奇侠操作
TeamFormationEvent.MULTI_EXCHANGE_PARTNER = "MULTI_EXCHANGE_PARTNER"
--多人布阵结束
TeamFormationEvent.MULTI_FINISH_TEAM = "MULTI_FINISH_TEAM"
--多人布阵更换法宝
TeamFormationEvent.MULTI_UP_TREASURE = "MULTI_UP_TREASURE"
--多人布阵上阵操作
TeamFormationEvent.MULTI_UP_WULING = "MULTI_UP_WULING"
--多人布阵交换奇侠操作
TeamFormationEvent.MULTI_EXCHANGE_WULING = "MULTI_EXCHANGE_WULING"
--被第二阵型下阵了一个奇侠
TeamFormationEvent.DISCHARGE_ONE_PARTNER = "TeamFormationEvent.DISCHARGE_ONE_PARTNER"
--布阵主界面已被关闭
TeamFormationEvent.TEAMVIEW_HAS_CLOSED = "TeamFormationEvent.TEAMVIEW_HAS_CLOSED"
--关闭五行加成详情界面
TeamFormationEvent.CLOSE_WUXING_DETAILVIEW = "TeamFormationEvent.CLOSE_WUXING_DETAILVIEW"
--点击了查看敌情界面返回按钮
TeamFormationEvent.CLICK_LOOKOVER_BACK_EVENT = "TeamFormationEvent.CLICK_LOOKOVER_BACK_EVENT"
--战力发生了变化
TeamFormationEvent.RESET_POWER_EVENT = "TeamFormationEvent.RESET_POWER_EVENT"
return TeamFormationEvent