-- FuncWelfare
--[[
	wk
	2017.8.9
]]

FuncWelfare = FuncWelfare or {}

FuncWelfare.WELFARE_TYPE = {
	DAILYSIGN = 1,  --每日签到
    REBATE = 2,   --三皇替换奖池
    TILIREAWRD = 3,--领取体力的系统 
}
--标签名称
FuncWelfare.NEW_SIGN_TYPE_STR = {
    [1] = "每日签到",
    [2] = "消费返利",
    [3] = "领取体力",
}
FuncWelfare.TYPE_TO_INDEX = {
    [1] = "DAILYSIGN",
    [2] = "REBATE",
	[3] = "TILIREAWRD",
}
FuncWelfare.VIEW_TO_TYPE = {
    [1] = "NewSignView",
    [2] = "WelfareShopView",
    [3] = "WelfareTiLiRewardView",---领取体力界面
}
FuncWelfare.VIEW_SYSTEM_NAME_TYPE = {
    [1] = "sign",
    [2] = "shop7",
    [3] = "spFood",  -- 体力奖励
}
FuncWelfare.XIANSHI_TYPE = {
    [1] = 4, --热门
    [2] = 4, --热门
    [3] = 4, --热门
}

FuncWelfare.BGNAME = {
    [1] = "sign_bg_beijing",
    [2] = "activity_bg_kezhan",
}



function FuncWelfare.init()
	
end

function FuncWelfare.getValue(id, key)

end
-- function FuncWelfare:get( ... )
-- 	local shoptype = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
-- end
function FuncWelfare.HEXtoC3b(hex)
    local flag = string.lower(string.sub(hex,1,2))
    local len = string.len(hex)
    if len~=8 then
        print("hex is invalid")
        return nil 
    end
    if flag ~= "0x" then
        print("not is a hex")
        return nil
    end
    local rStr =  string.format("%d","0x"..string.sub(hex,3,4))
    local gStr =  string.format("%d","0x"..string.sub(hex,5,6))
    local bStr =  string.format("%d","0x"..string.sub(hex,7,8))

    -- local ten = string.format("%d",hex)
    ten = cc.c3b(rStr,gStr,bStr)
    return ten
end
