
local TreasureNewServer = class("TreasureNewServer")
--MethodCode.treasure_combine_413 = 413   -- 法宝合成或解锁
--MethodCode.treasure_up_star_403 = 403   -- 法宝升星
--MethodCode.treasure_up_quality_405 = 405   -- 法宝进阶
--MethodCode.treasure_juexing_411 = 411      -- 法宝觉醒
--MethodCode.treasure_wnsp_415 = 415         -- 法宝碎片兑换
--合成/解锁 
function TreasureNewServer:combineTreasure(id,callBack)
	Server:sendRequest({ treasureId = id }, MethodCode.treasure_combine_413, callBack );
end
--升星 
function TreasureNewServer:treasureUpStar(id,callBack)
	Server:sendRequest({ treasureId = id }, MethodCode.treasure_up_star_403, callBack );
end
--升品
function TreasureNewServer:treasureUpQuality(id,callBack)
	Server:sendRequest({ treasureId = id }, MethodCode.treasure_up_quality_405, callBack );
end

--碎片兑换
function TreasureNewServer:treasureDuihuan(id,number,callBack)
	Server:sendRequest({ treasureId = id ,num = number}, MethodCode.treasure_wnsp_415, callBack );
end
return TreasureNewServer