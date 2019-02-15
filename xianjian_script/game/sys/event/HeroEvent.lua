
--英雄系统相关事件
local HeroEvent = {}
--英雄升级事件  参数 table = {heroid =did,level =1}   
HeroEvent.HEROEVENT_UPLEVE = "HEROEVENT_UPLEVE"

--选择一个英雄上阵 参数 table = {hid}
HeroEvent.HEROEVENT_SELECT_ONE_HERO = "HEROEVENT_SELECT_ONE_HERO"
--检查是否可以上阵后的结果 参数 table = {hid,canSelect}
HeroEvent.HEROEVENT_SELECT_ONE_HERO_RESULT = "HEROEVENT_SELECT_ONE_HERO_RESULT"
--选择一个英雄下阵 参数 table = {hid，canSelect,canNotStatus}
HeroEvent.HEROEVENT_UNSELECT_ONE_HERO = "HEROEVENT_UNSELECT_ONE_HERO"
--更新item的追击关系 参数 table = {charsingArr={}}
HeroEvent.HEROEVENT_UPDATE_LIS_ITEM_CHARSING = "HEROEVENT_UPDATE_LIS_ITEM_CHARSING"


-- 英雄列表刷新事件
HeroEvent.HEROEVENT_HEROLIST_UPDATE = "HEROEVENT_HEROLIST_UPDATE"
-- 英雄列表中英雄ITEM的更新
HeroEvent.HEROEVENT_HEROITEM_UPDATE = "HEROEVENT_HEROITEM_UPDATE"
-- 英雄列表中选择一个英雄显示详细属性
HeroEvent.HEROEVENT_HERO_SHOWDETAILES = "HEROEVENT_HERO_SHOWDETAILES"
-- 显示上/下一个英雄的详细属性
HeroEvent.HEROEVENT_HERO_SHOWPERORNEXT = "HEROEVENT_HERO_SHOWPERORNEXT"
-- 刷新英雄详情界面
HeroEvent.HEROEVENT_UPDATE_HERODETAILS = "HEROEVENT_UPDATE_HERODETAILS"
-- 关闭英雄详情界面
HeroEvent.HEROEVENT_CLOSE_HERODETAILS = "HEROEVENT_CLOSE_HERODETAILS"


--更新英雄数据 参数   table  =  {hid = hero1,hid =hero2}  是 更新的hero对象 key hash  数组
HeroEvent.HEROEVENT_UPDATEHERODATA = "HEROEVENT_UPDATEHERODATA"

--添加一个英雄数据  参数 hero对象
HeroEvent.HEROEVENT_ADDHERO = "HEROEVENT_ADDHERO"

--删除一个英雄数据   str , hid 只用传 hid 即可
HeroEvent.HEROEVENT_DELHERO = "HEROEVENT_DELHERO"

return HeroEvent
