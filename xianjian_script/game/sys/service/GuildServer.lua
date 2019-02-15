--
-- Author: guanfeng
-- Date: 2016-1-07
--

local GuildServer = class("GuildServer")

function GuildServer:init()
	echo("GuildServer:init");
	--[[
	--创建公会
	-- EventControler:addEventListener(GuildEvent.CREATE_GUILD_EVENT,
	-- 	self.createGuild, self);
	--查询公会
	EventControler:addEventListener(GuildEvent.FIND_GUILD_EVENT,
		self.findGuild, self);
	--公会列表
	EventControler:addEventListener(GuildEvent.LIST_GUILD_EVENT,
		self.listGuild, self);

	--加入公会
	EventControler:addEventListener(GuildEvent.GUILD_APPLY_EVENT,
		self.joinGuild, self);

	--公会信息
	EventControler:addEventListener(GuildEvent.GUILD_GET_MEMBERS_EVENT,
		self.getMembers, self);

	--得到公会申请列表
	EventControler:addEventListener(GuildEvent.GUILD_GET_APPLY_LIST_EVENT,
		self.getApplyList, self);

	--修改公会配置
	EventControler:addEventListener(GuildEvent.GUILD_MODITY_CONFIG_EVENT,
		self.modifyConfig, self);	

	--取消申请
	EventControler:addEventListener(GuildEvent.GUILD_CANCEL_APPLY_EVENT,
		self.cancelApply, self);	

	--入会审批
	EventControler:addEventListener(GuildEvent.GUILD_APPLY_JUDGE_EVENT,
		self.judgeApply, self);

	--踢人
	EventControler:addEventListener(GuildEvent.GUILD_KICK_GUILD_EVENT,
		self.kickMember, self);

	--修改会员权限
	EventControler:addEventListener(GuildEvent.GUILD_MODIFY_MEMBER_RIGHT_EVENT,
		self.modifyMEmberRight, self);

	--退出公会
	EventControler:addEventListener(GuildEvent.GUILD_QUIT_EVENT,
		self.quitGuild, self);

	--邀请玩家
	EventControler:addEventListener(GuildEvent.GUILD_invite_EVENT,
		self.inviteMember, self);
	--]]
	

end
--一键加入公会
function GuildServer:oneAddGuild(params,cellBack)
	Server:sendRequest(params, MethodCode.guild_one_add_1367,cellBack);
end
--创建公会
function GuildServer:createGuild(params,cellBack)
	Server:sendRequest(params, MethodCode.guild_create_1301,cellBack);
end

--查询公会
function GuildServer:findGuild(params,_callback)
	Server:sendRequest(params, MethodCode.guild_find_1303,_callback)
end


--公会列表
function GuildServer:listGuild(params,_callback)
	Server:sendRequest(params, MethodCode.guild_list_1305,_callback)
end

--加入公会
function GuildServer:joinGuild(params,_callback)
	Server:sendRequest(params, MethodCode.guild_apply_1309,_callback)
end


--公会所有成员
function GuildServer:getMembers(params,_callback)
	Server:sendRequest(params, MethodCode.guild_members_1307,_callback)
end

--得到申请列表
function GuildServer:getApplyList(params,_callback)
	Server:sendRequest(params, MethodCode.guild_apply_list_1311,_callback)
end

--更改配置
function GuildServer:modifyConfig(params,_callback)
	Server:sendRequest(params, MethodCode.guild_modify_info_1315,_callback)
end


--取消申请
function GuildServer:cancelApply(params,_callback)


	Server:sendRequest(params, MethodCode.guild_cancel_apply_1323,_callback)
		-- c_func(GuildServer.cancelApplyOk, self, index));
end

function GuildServer:cancelApplyOk(index, event)
	echo("cancelApplyOk");
	
	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_CANCEL_APPLY_OK_EVENT, 
	    	{index = index});
	end 
end

--入会申请
function GuildServer:judgeApply(params,_callback)
	Server:sendRequest(params, MethodCode.guild_apply_judge_1313,_callback)
end

--踢人
function GuildServer:kickMember(params,_callback)
	Server:sendRequest(params, MethodCode.guild_kick_member_1319,_callback)
end

--修改会员权限
function GuildServer:modifyMEmberRight(params,_callback)
	Server:sendRequest(params, MethodCode.guild_modify_member_right_1317,_callback)
end

--退出公会
function GuildServer:quitGuild(params,_callback)
	Server:sendRequest(params, MethodCode.guild_quit_1321,_callback)
end

--邀请玩家
function GuildServer:inviteMember(params,_callback)
	Server:sendRequest(params, MethodCode.guild_invite_1325,_callback);
end


------------------------新加协议--------------------------------------
--公会签到
function GuildServer:sendSign(params,_callback)
	Server:sendRequest(params, MethodCode.guild_sign_1331,_callback);
end
-- 领取祈福宝箱
function GuildServer:sendPrayRewawrd(params,_callback)
	Server:sendRequest(params, MethodCode.guild_pray_rewawrd_1333,_callback);
end
--领取红利
function GuildServer:sendBonus(params,_callback)
	Server:sendRequest(params, MethodCode.guild_bonus_1335,_callback);
end
--建设
function GuildServer:sendBuilding(params,_callback)
	Server:sendRequest(params, MethodCode.guild_building_1337,_callback);
end
--建设投票
function GuildServer:sendBuildingVote(params,_callback)
	Server:sendRequest(params, MethodCode.guild_building_vote_1339,_callback);
end
--祈福
function GuildServer:sendPray(params,_callback)
	Server:sendRequest(params, MethodCode.guild_pray_1341,_callback);
end
--捐献
function GuildServer:sendDonate(params,_callback)
	Server:sendRequest(params, MethodCode.guild_donate_1343,_callback);
end
--公会心愿
function GuildServer:sendWishList(params,_callback)
	Server:sendRequest(params, MethodCode.guild_WishList_1345,_callback);
end
--发出心愿
function GuildServer:sendSendWish(params,_callback)
	Server:sendRequest(params, MethodCode.guild_sendWish_1347,_callback);
end
--帮助心愿
function GuildServer:sendHelpWish(params,_callback)
	Server:sendRequest(params, MethodCode.guild_helpWish_1349,_callback);
end
--查看公会事件
function GuildServer:sendGetEvent(params,_callback)
	Server:sendRequest(params, MethodCode.guild_getEvent_1351,_callback);
end
--查看心愿事件
function GuildServer:sendGetWishEvent(_callback)
	Server:sendRequest({}, MethodCode.guild_getWishEvent_1353,_callback);
end

--弹劾
function GuildServer:sendImpeachmentEvent(_callback)
	Server:sendRequest({}, MethodCode.guild_impeachment_1375,_callback);
end






-------------------------- 仙盟科技接口 -----------------------------------------
-- 缴纳玄盒 donateId=1,2,3 而不是玄盒id
function GuildServer:donateBox(donateId,_callback)
	Server:sendRequest({id = donateId}, MethodCode.guild_donateBox_1369,_callback);
end
-- 精研
function GuildServer:skillGroupLevelUp(toLevelUpGroupId,_callback)
	Server:sendRequest({groupId = toLevelUpGroupId}, MethodCode.guild_skillGroupLevelUp_1371,_callback);
end
-- 修炼
function GuildServer:skillLevelUp(toLevelUpSkillId,_callback)
	Server:sendRequest({id = toLevelUpSkillId}, MethodCode.guild_skillLevelUp_1373,_callback);
end

--------------------------------宝箱兑换------------------------------------------
--宝箱兑换
function GuildServer:sendExchangeBoxData(params,_callback)
	Server:sendRequest(params, MethodCode.guild_exchanegReward_367,_callback);
end

--仙玉宝箱兑换
function GuildServer:sendRmbExchangeBoxData(params,_callback)
	Server:sendRequest(params, MethodCode.guild_Rmb_exchanegReward_369,_callback);
end
--------------------------------------------------------------------------



------------------------------公会兑换----------------------------------------
--公会兑换
function GuildServer:sendGuildExchange(params,_callback)
	Server:sendRequest(params, MethodCode.guild_exchange_1359,_callback);
end

--发送兑换请求兑换
function GuildServer:sendExchangeRequest(params,_callback)
	Server:sendRequest(params, MethodCode.guild_send_exchange_request_1361,_callback);
end


--取消兑换
function GuildServer:sendNotGuildExchange(_callback)
	Server:sendRequest({}, MethodCode.guild_not_exchange_1363,_callback);
end


--获取兑换列表
function GuildServer:getGuildExchangeList(_callback)
	Server:sendRequest({}, MethodCode.guild_get_exchange_list_1365,_callback);
end

---------------------------------------------------




function GuildServer:sendMotched(cafunback)
    -- local param = {rids = {}}
        local param = {}
        param.infos = {}
    
    local guildMembersList =  GuildModel:getGuildMembersInfo()
    local index = 1
	for k,v in pairs(guildMembersList) do
        local rid = k
        if index <= 20 then
	        param.infos[index] = {}
	        param.infos[index].sec = ChatModel:getRidBySec(rid,true)
	        param.infos[index].rid = rid
	        index = index + 1
	    end
    end

    local function _callback(_param)
        dump(_param.result,"在线请求返回数据")
        if _param.result ~= nil then
            local onlinedata = _param.result.data.onlines
            cafunback(onlinedata)
        end
    end
    ChatServer:sendPlayIsonLine(param,_callback)

end








--获取红包列表
function GuildServer:getRedPacketLast(_callback)
	Server:sendRequest({}, MethodCode.guildRedPacket_getListData_6401,_callback);
end

--发红包
function GuildServer:sendRedPacket(params,_callback)
	Server:sendRequest(params, MethodCode.guildRedPacket_offpacket_6403,_callback);
end


--抢红
function GuildServer:grabRedPacket(params,_callback)
	Server:sendRequest(params, MethodCode.guildRedPacket_grab_6405,_callback);
end


--红包详情界面
function GuildServer:getRedPacketInFoLast(params,_callback)
	Server:sendRequest(params, MethodCode.guildRedPacket_getPacketInfo_6407,_callback);
end


--申请和加入
function GuildServer:sendAppAndAdd(guildID,callBack)
   	local isopen =  FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GUILD)
  	if not isopen then
    	WindowControler:showTips(GameConfig.getLanguage("#tid_ranklisttips_2003"));
    	return
 	end

	local function _callback(_param)
	    -- dump(_param.result,"申请加入的数据返回",8)
	    if _param.result then
	    	
	      	if callBack then
	        	callBack()
	      	else
	       		WindowControler:showTips(GameConfig.getLanguage("#tid_guildAddCell_004"))
	      	end 
	    else
	      --错误和没查找到的情况
	    end
	end 
	local params = {
	    id = guildID
	};
	GuildServer:joinGuild(params,_callback)
end

--发送完成仙盟任务
function GuildServer:sendFinishGuildTask(params,_callback)
	Server:sendRequest(params, MethodCode.finish_guild_task_7401,_callback);
end

--获取内榜
function GuildServer:sendRinkGuildTask(params,_callback)
	Server:sendRequest(params, MethodCode.get_guild_task_rink_7403,_callback);
end

--揭榜
function GuildServer:sendRenwngloryGuildTask(params,_callback)
	Server:sendRequest(params, MethodCode.get_guild_task_renwnglory_7405,_callback);
end


--领取声望排名奖励
function GuildServer:sendRinkRewardGuildTask(params,_callback)
	Server:sendRequest(params, MethodCode.get_guild_task_rink_reward_7407,_callback);
end


--仙盟挖宝
function GuildServer:sendGuildDigBox( params,_callback )
	Server:sendRequest(params, MethodCode.guild_dig_box,_callback)
end

--仙盟挖宝界面获取挖宝列表
function GuildServer:getGuildDigList(_callback)
	Server:sendRequest({}, MethodCode.get_guild_dig_list,_callback)
end


GuildServer:init();

return GuildServer











