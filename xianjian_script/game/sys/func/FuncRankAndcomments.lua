-- FuncRankAndcomments
--[[
	wk
]]

FuncRankAndcomments = FuncRankAndcomments or {}

FuncRankAndcomments.SYSTEM  = {
	elite = "elite",
	wonderLand = "wonderLand",
	trial = "trial",
	tower = "tower", --锁妖塔
	endless = "endless",--无底生源
}
FuncRankAndcomments.RankAndCommentd_type = {
	rankAndComment = 1,
	rank = 2,
	comment = 3,	
}

FuncRankAndcomments.COMMENTTYPE = {
	praise = 1, ---点赞
	stepOn = 2, --点踩
}
FuncRankAndcomments.COMMENTSSUMNUM = 30  --	评论数量最多暂时可保留50条
FuncRankAndcomments.GOODANDNOTGOOD = 999  --	被赞和被踩数量都最多显示999，

FuncRankAndcomments.STR_EVERYDAY =	"每个关卡每日最多评论2条"


function FuncRankAndcomments.init()

end

--每个关卡每个玩家每日最多评论2条
function FuncRankAndcomments.getCommentNumber(system)
	if system == FuncCommon.SYSTEM_NAME.PARTNER then
		return 1 --FuncDataSetting.getDataByConstantName("PartnerCommentTimes") 
	else	
		return FuncDataSetting.getDataByConstantName("CommentTimes")  
	end
end

---有关星级的系统判断
function FuncRankAndcomments.showStarBySystemName(systemname)
	local showStarSys = {"elite","endless"}
	for k,v in pairs(showStarSys) do
		if v == systemname then
			return true
		end
	end
	return false
end














