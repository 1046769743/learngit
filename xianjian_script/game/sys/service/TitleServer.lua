-- TitleServe  称号系统
-- Author wk
-- time 2017/7/14
local TitleServer = class("TitleServe")


-- function TitleServer:customItems(itemId,itemNum,callBack)
-- 	echo("···TitleServe:customItems")
-- 	local params = {
-- 		itemId = itemId,
-- 		num = itemNum
-- 	}
-- 	Server:sendRequest(params,MethodCode.item_customItem_801, callBack ,false,false,true)
-- end




--激活按钮
function TitleServer:sendActivation(params,callBack)
	Server:sendRequest(params,MethodCode.title_Action_5201, callBack ,false,false,true)
end
--卸载按钮
function TitleServer:senduninstall(params,callBack)
	Server:sendRequest(params,MethodCode.title_wear_uninstall_5203, callBack ,false,false,true)
end
--佩戴按钮
function TitleServer:sendwear(params,callBack)
	Server:sendRequest(params,MethodCode.title_wear_uninstall_5203, callBack ,false,false,true)
end






return TitleServer