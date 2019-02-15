--
-- Author: xd
-- Date: 2016-01-14 14:42:07
--


--邮件配置文件相关

local mailData = nil

FuncMail = FuncMail or {}





FuncMail.Event_Type = {
	PVP_EVERYDAY_REWARD = 1,  --登仙台每日结算奖励
	PVP_MAX_REWARD = 2,--登仙台最高排名奖励
	GUILD_POS_EXCHANG = 3,	--仙盟职位变更

	KICKEDOUT_GUILD = 6,--逐出仙盟
	GUILD_DISSOLVE = 7,--仙盟解散
	WORSHIP_REWARD = 8,--膜拜奖励
	REISSUE_ACT_REWARD = 9,--补发活动奖励
	WELCOME_TO_XIAN = 11,--补发活动奖励
	ENDLESS_REWARD = 12,--幻境协战奖励
	GUILD_WISH_CHIP = 13,--祈愿获得碎片通知
	GUILD_ACT_REWARD = 14,--仙盟酒家活动奖励
	CROSSPEAK_DAN_ASCENSION = 15,--仙界对决段位提升奖励
	CROSSPEAK_REWARD = 16,--仙界对决赛季结算奖励
	GUILD_BOSS_MODEL_REWARD = 17,--共闯秘境奖励
	GUILD_EXCHANGE_SUCCESSFUL = 18,--仙盟交换成功
	GUILD_EXCHANG_FAILURE = 19,--仙盟交换失败
	REPLACEMENT_DAN_REWARD = 20,--段位补发奖励
	GUILD_RANK_REWARD = 21,--仙盟排行奖励
	GUILD_SKILL_PARTNER_REWARD = 22,--仙盟击杀伙伴奖励
	SHAREBOSS = 25,---幻境邪战
}

function FuncMail.init(  )
	mailData = Tool:configRequire("mail.Mail")
end

--获取邮件信息
function FuncMail.getMailCfg( id )
	local cfgs = mailData[tostring(id)]
	if not cfgs  then
		echoError("没有这个id数据:",tostring(id))
		return mailData[tostring(1)]
	end
	return cfgs
end

--获取邮件标题
function FuncMail.getMailTitle( id,replaceInfo )
	local info = FuncMail.getMailCfg( id )
	local str = info.title;
	replaceInfo = replaceInfo or {}
	--获取占位符
	return GameConfig.getLanguageWithSwap(str,unpack(replaceInfo))

end

--获取邮件内容
function FuncMail.getMailContent( id,replaceInfo )
	local info = table.copy(FuncMail.getMailCfg( id ))
	local str = info.content;
	replaceInfo = replaceInfo or {}
	--获取占位符
	return GameConfig.getLanguageWithSwap(str,unpack(replaceInfo))
end


--获取邮件发件人
function FuncMail.getMailSec( id,replaceInfo )
	local info = FuncMail.getMailCfg( id )
	local str = info.sec;
	replaceInfo = replaceInfo or {}
	--获取占位符
	return GameConfig.getLanguageWithSwap(str,unpack(replaceInfo))
end






