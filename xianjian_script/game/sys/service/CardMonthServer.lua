local CardMonthServer = class("CardMonthServer")

function CardMonthServer:getEveryDayReward(cmId,callBack)
    Server:sendRequest({id = tostring(cmId)},MethodCode.card_month_reward_7301, callBack)
end

return CardMonthServer