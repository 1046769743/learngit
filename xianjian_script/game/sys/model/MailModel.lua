--
-- Author: xd
-- Date: 2016-01-14 18:06:21
--

--邮件信息
--[[
	 1 = {
[LUA-print] -                     "delTime"  = 1455165575
[LUA-print] -                     "get"      = 0
[LUA-print] -                     "param" = {
[LUA-print] -                         1 = "dev_30"
[LUA-print] -                         2 = 20001
[LUA-print] -                         3 = 11369
[LUA-print] -                     }
[LUA-print] -                     "personal" = 1
[LUA-print] -                     "reward" = {
[LUA-print] -                         1 = "3,100001"
[LUA-print] -                     }
[LUA-print] -                     "sendTime" = 1452573575
[LUA-print] -                     "tempId"   = 2
[LUA-print] -                 }

]]


--邮件model管理器
local MailModel  = class("MailModel ", BaseModel )

function MailModel:init( d )

    --延时发放邮件
    local data = self:updataBySendtime(d)
    -- 检查错误信息
    local _mail = self:checkErrorMailAll(data)
    -- 检查邮件是否超时
    local _mails = self:updataByDeleteTime(_mail)
	MailModel.super.init(self,_mails)
	self:checkShowRed()
  self._mailData = d

end

function MailModel:checkErrorMailAll(data)
    local  mails = {};
    for i,v in pairs(data) do
        local isRight = true
        if v.reward then
            for m ,n in pairs(v.reward) do
                if not self:checkErrorMail(n) then
                    isRight = false
                    break
                end
            end
        end     
        if isRight then
            table.insert(mails,v)
        end
    end
    return mails
end

function MailModel:checkErrorMail(reward)
 
    local data = string.split(reward,",")
    local rewardType = data[1]
    local rewardId = nil

    -- 如果奖品是道具
    if tostring(rewardType) == UserModel.RES_TYPE.ITEM then
        rewardId = data[2]
        if FuncItem.isValid(rewardId) then
            return true
        else    
            if rewardId then
                echoTag("tag_E_mail",5,"--------在道具中没找到该ID = ",rewardId)
            end
            return false
        end
    else
        -- 奖品为非道具资源
        -- 金币 钻石等
        local isValid = false
        for i,v in pairs(UserModel.RES_TYPE) do
            if tostring(rewardType) == v then
                isValid = true
            end
        end
        if isValid == false and rewardType then
            echoTag("tag_E_mail",5,"------没有此类新的资源 = ",rewardType)
        end
        
        return isValid
    end

    return true
end

function MailModel:updataBySendtime(d)
    self._hideData = {}
    if d then
      local data = {}
      for i,v in pairs(d) do
           if v.sendTime <= TimeControler:getServerTime()  then 
              table.insert(data,v)
           else
               table.insert(self._hideData,v)
               --实现一个倒计时的方法
               local _upDataMail = function ()
                   for k,n in pairs(self._hideData) do
                       if n.sendTime <= TimeControler:getServerTime() then
                           table.insert(self:data(),n)
                           table.remove(self._hideData,k)
                       end
                   end
                   self:checkShowRed()
               end
               WindowControler:globalDelayCall(c_func( _upDataMail),v.sendTime-TimeControler:getServerTime() )
           end
      end
      return data
    end
    return d
end
function MailModel:updataByDeleteTime(d)
    local delData = {}
    if d then
      self.willDellData = {}
      for i,v in pairs(d) do
           if v.delTime <= TimeControler:getServerTime()  then  -- 应该删除
              --
              self:deleteMail(v._id)
           else
               table.insert(self.willDellData,v)
               --实现一个倒计时的方法
               local _upDataMail = function ()
                   local data = {}
                   for k,n in pairs(self.willDellData) do
                       if n.delTime <= TimeControler:getServerTime() then
                           -- 删除此邮件
                           self:deleteMail(n._id)
                       else
                           table.insert(data,n)
                       end
                   end
--                   self:setData(data)
                   self:updateData( data )
                   self:checkShowRed()
               end
               WindowControler:globalDelayCall(c_func( _upDataMail),v.delTime-TimeControler:getServerTime() )
           end
      end
      return self.willDellData
    end
    return d
end

 
--更新邮件
function MailModel:updateData( data )
	self:init(data)
	EventControler:dispatchEvent(MailEvent.MAILEVENT_UPDATEMAIL)
end


--邮件排序
function MailModel:getSortMail(  )
	local mails = table.copy( self:data() )

	--[[
		1.	邮件的排列顺序按照收件时间排列，收件时间由早到晚，由下至上排列 
		2.	未读邮件优先级大于已读邮件
		3.	同为未读，奖励类邮件排列优先级大于通知类邮件
		4.	未读邮件读取后变为已读邮件，位置置底（无需实时）
	]]
	-- read,sendTime,reward
	local sortFunc = function ( mail1,mail2 )


		local isReward1 = mail1.reward and 1 or 0
		local isReward2 = mail2.reward and 1 or 0

		local read1 = mail1.read or 0
		local read2 = mail2.read or 0


		if isReward1 > isReward2 then
			return true

		elseif isReward1 == isReward2 then
			if(read1 < read2 ) then 
				  if isReward1 == 0 then
            return true
          else 
            return false
          end
			elseif  read1 == read2 then
				return mail1.sendTime > mail2.sendTime

			else
				return false

			end



			--邮件时间 越晚  越靠上
			-- if mail1.sendTime > mail2.sendTime then
			-- 	return true

			-- elseif mail1.sendTime == mail2.sendTime then
			-- 	local isReward1 = mail1.reward and 1 or 0
			-- 	local isReward2 = mail2.reward and 1 or 0
			-- 	return isReward1 > isReward2
			-- end
			-- return false


		else
			return false

		end

	end

	table.sort( mails, sortFunc )
  local realMailData = self:updataByDeleteTime(mails)
	return realMailData

end


--判断是否显示小红点
function MailModel:checkShowRed(  )
	local data = self:data()
	local showRed = false
	for i,v in pairs(data) do
		if v.read ~= 1 then
			showRed = true
			break
		end
		if v.reward then
			showRed = true
			break
		end
	end
  local isopen=  FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIL)
  if not isopen then
    showRed = false
  end
	--发送邮件小红点
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
{redPointType = HomeModel.REDPOINT.LEFTMARGIN.MAIL, isShow = {[2] = showRed}});	
end

--判断是否显示小红点
function MailModel:checkShowRedForFriend()
  local data = self:data() or {}
	local showRed = false
	for i,v in pairs(data) do
		if v.read ~= 1 then
			showRed = true
			break
		end

		if v.reward then
			showRed = true
			break
		end
	end
  local isopen=  FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIL)
  if not isopen then
    showRed = false
  end

    return showRed
end
--read一个邮件
function MailModel:readMail( mailId )
	local data = self:data()

	for k,v in pairs(data) do
		if v._id == mailId then
			local mailInfo = v
			if mailInfo then
				mailInfo.read = 1
			end
		end
	end

	self:checkShowRed()

end




--删除邮件 也用一样的 方法
function MailModel:deleteData( keydata )
	MailModel.super.deleteData(self,keydata)
	EventControler:dispatchEvent(MailEvent.MAILEVENT_DELMAIL)
	self:checkShowRed()
end


function MailModel:deleteMail( mailId )
	for i=#self._data,1,-1 do
		local info = self._data[i]
		if info._id ==mailId then
			table.remove(self._data,i)
		end
	end
	self:checkShowRed()
	EventControler:dispatchEvent(MailEvent.MAILEVENT_DELMAIL)
end

function MailModel:mailDetail(mailId)
    for i = 1,#self._data do
        local info = self._data[i]
        if tonumber(info._id) == tonumber(mailId) then
          return info.param 
        end
    end
end


function MailModel:getPamesArr(info)

  dump(info,"邮件数据 ====")
    local tempId = info.tempId 
    local title = info.title -- 邮件数据本身的title
    local content = info.content
    local param = {}
    if info.param == nil  then
        param = {
            [1] = UserModel:name()
        }
      end
    -- else
    if tonumber(tempId) == FuncMail.Event_Type.ENDLESS_REWARD then
        param[1] = FuncTranslate._getLanguage(FuncShareBoss.getBossNameById(tostring(info.param.bossId)))
        param[2] = info.param.rank
    elseif tonumber(tempId) == FuncMail.Event_Type.GUILD_WISH_CHIP  then --仙盟赠卡
        param[1] = info.param[1]
    elseif tonumber(tempId) ==  FuncMail.Event_Type.GUILD_POS_EXCHANG  then   ---职位变动
        local guildType = info.param[4]
        if guildType == nil then
            guildType = 1
        end
        local framse3 = nil
        if tonumber(info.param[1]) < tonumber(info.param[1]) then
            framse3 = "降"
        else
            framse3 = "升"
        end
        local name1 =  FuncGuild.byIdAndPosgetName(guildType,info.param[1])
        local name3 =  FuncGuild.byIdAndPosgetName(guildType,info.param[3])
        param[1] = name1
        param[2] = framse3
        param[3] = name3
    elseif  tonumber(tempId) == FuncMail.Event_Type.CROSSPEAK_DAN_ASCENSION then  --巅峰竞技场段位
        local id = info.param[1]
        local name1 = FuncCrosspeak.getSegmentDataById( id ).segmentName
        param[1] = GameConfig.getLanguage(name1)
    elseif  tonumber(tempId) == FuncMail.Event_Type.REISSUE_ACT_REWARD then  --嘉年华奖励
        local data = FuncActivity.getActConfigById(info.param[1])
        param[1] = UserModel:name()
        param[2] = GameConfig.getLanguage(data.title)
    elseif tonumber(tempId) == FuncMail.Event_Type.GUILD_BOSS_MODEL_REWARD then  --秘境小仙
        local bossId = info.param.bossId
        local rank = info.param.rank
        local bossConfigData = FuncGuildBoss.getBossDataById(bossId)
        local ectypeName = FuncTranslate._getLanguage(bossConfigData.name)
        param[1] = ectypeName
        param[2] = rank
    elseif tonumber(tempId) == FuncMail.Event_Type.GUILD_EXCHANGE_SUCCESSFUL then  --仙盟兑换
        param[1] = info.param[1]
        param[2] = info.param[2]
    elseif tonumber(tempId) == FuncMail.Event_Type.PVP_EVERYDAY_REWARD then
        param[1] = UserModel:name()
        param[2] = info.param[1]
    elseif tonumber(tempId) == FuncMail.Event_Type.REPLACEMENT_DAN_REWARD then
        local danwei  = info.param[1]
        local data1 = FuncCrosspeak.getSegmentDataById(danwei)
        local inheritSegment = data1.inheritSegment
         local data2 = FuncCrosspeak.getSegmentDataById(inheritSegment)
        param[1] = GameConfig.getLanguage(data2.rankName) 
    elseif tonumber(tempId) == FuncMail.Event_Type.GUILD_RANK_REWARD then
        local rank  = info.param[1] 
        param[1] = rank
    elseif tonumber(tempId) == FuncMail.Event_Type.GUILD_SKILL_PARTNER_REWARD then

    elseif tonumber(tempId) == FuncMail.Event_Type.SHAREBOSS then
        local data = FuncShareBoss.getBossDataById(info.param.bossId)
        param[1] = GameConfig.getLanguage(data.name)
    elseif tonumber(tempId) == FuncMail.Event_Type.WELCOME_TO_XIAN then
        param[1] = UserModel:name()
    else
        param = info.param
    end
    return param
end

return MailModel 