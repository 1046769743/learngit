-- RankAndcommentsServer
local RankAndcommentsServer = class("RankAndcommentsServer")


function RankAndcommentsServer:LotteryBuyOneAndFive(params, callBack)
	-- Server:sendRequest(params,MethodCode.cimelia_lottery_5305, callBack)
end

--根据系统名，来获取数据
function RankAndcommentsServer:getDataBySystemName(params, callBack)
	Server:sendRequest(params,MethodCode.RANK_COMMENTS_6001, callBack)
end

----添加评论
function RankAndcommentsServer:addCommentsToserver(params, callBack)
	Server:sendRequest(params,MethodCode.ADD_COMMENTS_6003, callBack)
end


----点赞和点踩
function RankAndcommentsServer:goodAndStopOnToServer(params, callBack)
	Server:sendRequest(params,MethodCode.PRAISE_STOPON_6005, callBack)
end


-- --举报
function RankAndcommentsServer:reportToServe(params, callBack)
	Server:sendRequest(params,MethodCode.COMMENTS_REPORT_6007, callBack)
end



return RankAndcommentsServer




