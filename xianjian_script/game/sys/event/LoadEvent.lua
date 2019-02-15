--
-- Author: xd
-- Date: 2016-02-25 11:07:12
--

local LoadEvent = {}
	
--有用户加入  { users = { { id= 1,  zoneId = "s16" ,uname ="玩家",lv = 1,state = 1 }    }     }
LoadEvent.LOADEVENT_USERENTER = "LOADEVENT_USERENTER"	

--某个用户加载完成{id = "hid"}
LoadEvent.LOADEVENT_USERCOMPLETE= "LOADEVENT_USERCOMPLETE"

--战斗中加载完成
LoadEvent.LOADEVENT_BATTLELOADCOMP = "LOADEVENT_BATTLELOADCOMP" 

-- 匹配超时
LoadEvent.LOADEVENT_MATCH_TIME_OUT = "LOADEVENT_MATCH_TIME_OUT"
return LoadEvent