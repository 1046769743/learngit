
local GodServer = class("GodServer")
--MethodCode.god_activite_4101 = 4101 --神明激活
--MethodCode.god_setFormula_4103 = 4103 --神明上阵
--MethodCode.god_activiteGroove_4105 = 4105 --饰品激活
--MethodCode.god_upgradeLevel_4107 = 4107 --神明强化
--god激活 
function GodServer:godActivate(godId,callBack)
	Server:sendRequest({ godId = godId }, MethodCode.god_activite_4101, callBack );
end
--god上阵 
function GodServer:godFormula(godId,callBack)
	Server:sendRequest({ godId = godId }, MethodCode.god_setFormula_4103, callBack );
end
--god强化
function GodServer:godUpgrade(_godId,_isGold,callBack)
	Server:sendRequest({ godId = _godId ,isGold = _isGold }, MethodCode.god_upgradeLevel_4107, callBack );
end
--godGroove 激活
function GodServer:godGrooveActivate(godGrooveId,callBack)
	Server:sendRequest({ grooveId = godGrooveId }, MethodCode.god_activiteGroove_4105, callBack );
end

return GodServer