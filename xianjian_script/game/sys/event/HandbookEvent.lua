--
--Author:      zhuguangyuan
--DateTime:    2018-05-22 16:49:26
--Description: 名册系统相关消息定义
--


local HandbookEvent = {}
-- 一个奇侠上阵(注意不是布阵,而是上名册的阵位)
HandbookEvent.ONE_PARTNER_ENTER_FIELD = "ONE_PARTNER_ENTER_FIELD"
-- 一个奇侠下阵
HandbookEvent.ONE_PARTNER_LEAVE_FIELD = "ONE_PARTNER_LEAVE_FIELD"
-- 一个奇侠换阵
HandbookEvent.ONE_PARTNER_EXCHANGE_FIELD = "ONE_PARTNER_EXCHANGE_FIELD"
-- 解锁一个阵位
HandbookEvent.UNLOCK_ONE_POSITION = "UNLOCK_ONE_POSITION"
-- 一个名册升级成功
HandbookEvent.ONE_DIR_UPGRADE_SUCCEED = "ONE_DIR_UPGRADE_SUCCEED"

-- 数据更新
HandbookEvent.HANDBOOK_DATA_UPDATA = "HANDBOOK_DATA_UPDATA"


return HandbookEvent
