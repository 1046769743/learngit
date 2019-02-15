local LuckyGuyServer = class("LuckyGuyServer")

--幸运转盘协议    7701买券    7703抽奖

--买券
function LuckyGuyServer:bugTicket( params,callBack )
	Server:sendRequest(params, MethodCode.luckyguy_bug_Ticket_7701, callBack);
end

--抽奖
function LuckyGuyServer:playAward( params,callBack )
	Server:sendRequest(params, MethodCode.luckyguy_play_Award_7703, callBack);
end

return LuckyGuyServer