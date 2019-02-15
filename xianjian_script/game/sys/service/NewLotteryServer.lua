--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai


local NewLotteryServer = { }

function NewLotteryServer:ctor()


end 
--开始免费抽奖协议 一次（次数）
--开始免费抽奖协议 五次（次数）
--(参数0 免费，1造物卷，5造物卷)

function NewLotteryServer:freeDrawcard(type,_cllback)
	local Params = {type = type} 
	Server:sendRequest( Params, MethodCode.lottery_freeDrawcard_2101, _cllback,false,false,true)
end
--开始消耗元宝抽奖协议 0,1,10（次数）
function NewLotteryServer:consumeDrawcard(type,isGold,_cllback)
	local Params = {
		type = type,
		isGold = isGold,
	}
	Server:sendRequest( Params, MethodCode.lottery_consumeDrawcard_2103, _cllback,false,false,true)
end

--加速造物
function NewLotteryServer:speedUpLottery(params,_cllback)
	Server:sendRequest( params, MethodCode.lottery_speedUpLottery_2111, _cllback,false,false,true)
end

--完成造物
function NewLotteryServer:finishLottery(params,_cllback)
	Server:sendRequest( params, MethodCode.lottery_finishLottery_2113, _cllback,false,false,true)  
end



--刷新按钮协议
function NewLotteryServer:Refreshbutton(shopType,_cllback)
	ShopServer:refreshShop( shopType ,_cllback )
end

---奖池替换协议(商店类型，商店第几个物品，替换那个位置的物品)
function NewLotteryServer:requestpoolCombineData( shopType ,shopIndex,replaceLotteryIndex,_cllback )
 	local Params = {
 		shopType = tostring(shopType),
 		shopIndex = tostring(shopIndex),
 		replaceLotteryIndex = tostring(replaceLotteryIndex),
	}

	Server:sendRequest( Params, MethodCode.lottery_replace_2105, _cllback,false,false,true)
end

-- 魂匣抽奖
--[[
	@@tType 抽卡类型 1次 5次
	@@id 活动id
]]
function NewLotteryServer:requestSoulDrawCard(tType, id, callBack)
	Server:sendRequest(
		{type = tType, scheduleId = id}, 
		MethodCode.lottery_shoul_2107, 
		function ( data )
			-- echo("魂匣抽奖返回值",json.encode(data))
			local result = data.result
			if result then
				NewLotteryModel:setSoulReward( result.data.reward )
				if callBack then callBack() end
			else
				echo("error MethodCode.lottery_shoul_2107")
			end
		end
	)
end


function NewLotteryServer:LingQuZhaowuFu()
	-- if UserModel:totalCostGold() == 0 then
	-- 	WindowControler:showTips("没有可领取的灵石")
	-- 	return 
	-- end
	local goldnumber =  UserModel:getGoldConsumeCoinInner()
	if  goldnumber  == 0 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_welfare_008"))
		return
	end


	local _cllback = function (_params)
		if  _params.error ~= nil then
			-- WindowControler:showTips("没有可领取的灵石")--_params.error.message)
		else
			-- dump(_params.result,"111111111111111111")
			local ConsumeCoin = UserModel:goldConsumeCoin()
			local number = _params.result.data.dirtyList.u.goldConsumeCoin 
			local lingqu  = number - ConsumeCoin

			-- WindowControler:showTips("成功领取灵石")
			EventControler:dispatchEvent(NewLotteryEvent.REFRESH_REPLACE_VIEW)
			LS:pub():set("SAVELOCALLINGSHI"..UserModel:rid(),UserModel:totalCostGold())
			-- WindowControler:showTips("成功领取"..goldnumber.."灵石")
			NewLotteryModel:sendMainLotteryRed()
			local id = FuncDataResource.RES_TYPE.LINGSHI
			local reward = id..","..goldnumber
			WindowControler:showWindow("RewardSmallBgView", {reward});

		end
		NewLotteryModel:saveLocalGold(UserModel:totalCostGold())
	end
	local Params = {} 
	Server:sendRequest( Params, MethodCode.lottery_LintQuDrawcard_2109, _cllback,false,false,true)
end




--快捷抽卡
function NewLotteryServer:doQuickLottery( callBack )
	local params = {}

	Server:sendRequest(params,MethodCode.lottery_quickSoul_2115, callBack )

end


return NewLotteryServer

