--
-- Author: xd
-- Date: 2015-11-19 17:37:08
--

local UserExtModel = class("UserExtModel",BaseModel)

UserExtModel.INIT_TYPES = {
	AVATAR_INITED = {key = "AVATAR_INITED", bit=1}, --是否设置过形象
	NAME_CHANGE = {key = "NAME_CHANGE", bit = 2}, --是否改过名字
}

function UserExtModel:ctor()
	
end

function UserExtModel:init(d)
	self.modelName = "userExt"
    UserExtModel.super.init(self,d)
    self:registerEvent()

    self._datakeys = {
        avatar = "",                    --玩家头像/形象
        holySpace = numEncrypt:ns0(),   --神器占用空间
        sp = numEncrypt:ns0(),          --体力值
        upSpTime = "",                  --上次体力更新时间

        stageId = "",                  --主线章节Id
        eliteId = "",                  --精英章节Id
        currentStage = 0,               --标记状态：当前正在进行的副本id，为0表示当前没有进行中的副本
        loginTime = 0,      
        logoutTime = 0,  
        upSpTime = 0,
        totalSignDays = 0,  -- 累计签到天数
        totalSignDaysReceiveDetail = {}, -- 签到领取情况
        totalSoul = 0, --历史宝物精华数量
        hasInit = 0, --按二进制数看待，每一位代表不同的含义，见UserExtModel.INIT_TYPES
        -- PVE特等总星数量
        totalStageStar = 0,
        
        --存需要进行的，不是已经完成的 "waitForSystemOpen" 这个是完成没类强制引导的中间状态
        guide = "2;1;1", 
        -- guide = "waitForSystemOpen", 
        pulseNode = numEncrypt:ns0(), --灵脉修炼进度
        firstRechargeGift = 0, --是否领过首冲奖励
        buyVipGift = 0, --是否买过首冲礼包
        partnerSkill =0, --伙伴系统技能点
        upPartnerSkillTime =0,--伙伴技能点更新时间
        backgroundId = 1, -- 查看阵容系统，背景ID

        garmentId = "", --当前穿戴的时装
        sign = "", -- 当前签名
        currentTitle = "", --当前称号ID
        cimeliaTotalTimes = 0,
        fiveSoulPoint = numEncrypt:ns0(),
        fiveSoulResetTimes = numEncrypt:ns0(),
        delegateCount = 0,
        endlessId = 0,       --无底深渊ID
        endlessTime = 0,
        currRingLoveId = "",   --当前正在进行的跑环任务
		-- 仙盟酒家是否领取新手引导奖励 标记
        gveGuideFlag = "",
        discountId = "",
        discountExpireTime = 0,
        biographyNodeId = "0", -- 当前正在进行任务的partnerId
        buyCoinTimes = 0,      --购买铜钱累计次数

        rouletteTime = 0,   ---转盘期数
        rouletteLucky = 0,  ---幸运值
        roulettes = {},

        firstSharePartner = 0, --首次分享领取时的时间戳(不仅是奇侠，任何分享都算)
    }

    self:createKeyFunc()
    --记录初始的体力 
    self._initSp = self:sp()
    if not PrologueUtils:showPrologue() then
        -- 根据时间差更新体力
        self:updateSpByUpTime()
        --计算技能点上限
        self:setPartnerSkillPoint()
        --VIP监听
        EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE,self.setPartnerSkillPoint,self)
    end
end

-- 是否做了首次分享
function UserExtModel:hasFirstShared()
    return self:firstSharePartner() > 0
end

function UserExtModel:hasInited()
    if not self._data then
        return false
    end
	return self:hasInitAvatar()
	--local hasInit = self._data.hasInit
	--return hasInit~=nil and hasInit > 0
end

function UserExtModel:hasInitAvatar()
	return self:checkInitByType(self.INIT_TYPES.AVATAR_INITED.key)
end

function UserExtModel:hasChangedName()
	return self:checkInitByType(self.INIT_TYPES.NAME_CHANGE.key)
end

--initType must in UserExtModel.INIT_TYPES
function UserExtModel:checkInitByType(initType)
	local info = self.INIT_TYPES[initType]
	if not info then
		return false
	end
	local bitNum = info.bit
	local hasInit = self:_getHasInitValue()
	local convertResult = bit.rshift(hasInit, bitNum - 1)
	if convertResult % 2 > 0 then
		return true
	else
		return false
	end
end

function UserExtModel:_getHasInitValue()
	return self._data.hasInit or 0
end

function UserExtModel:getRenameCost()
	local key = "PlayerModifyName"
	local cost = FuncDataSetting.getDataByConstantName(key)
	return tonumber(cost)
end

--是否改过名字
function UserExtModel:hasChangeNameBefore()
	return self:checkInitByType(self.INIT_TYPES.NAME_CHANGE.key)
end

function UserExtModel:getMainStageId()
    local raidId = self:stageId()
    if raidId == nil or raidId == "" or raidId == 0 then
        return 0
    end
    
    return raidId
end

function UserExtModel:getEliteStageId()
    local raidId = self:eliteId()
    if raidId == nil or raidId == "" or raidId == 0 then
        return 0
    end
    
    return raidId
end

function UserExtModel:getEndlessId()
    local endlessId = self:endlessId()
    if endlessId == nil or endlessId == "" or endlessId == 0 then
        return 0
    end
    
    return endlessId
end

-- 注册事件监听
function UserExtModel:registerEvent()
    EventControler:addEventListener(TimeEvent.TIMEEVENT_ONSP, self.updateSpByTimeEvent, self)
end

--更新data数据
function UserExtModel:updateData(data)
    UserExtModel.super.updateData(self,data);

    -- PVE 从非特等打到特等或者第一次打就打了特等
    if data.totalStageStar ~= nil then
        EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CHAPTER_STAGE_SCORE_UPDATE, {});
    end
    --体力的发生了变化
    if(data.sp ~=nil )then
        self._data.sp = data.sp
        self._initSp = data.sp  
        self:updateSpByUpTime()
        
        EventControler:dispatchEvent(UserEvent.USEREVENT_SP_CHANGE)
    end
    --伙伴技能点发生了变化
    if data.partnerSkill then
        self:resetSkillPointTime()
        EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_POINT_CHANGED,data.partnerSkill)
    end
    --伙伴技能点更新时间发生了变化
    if data.upPartnerSkillTime then
        EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_POINT_UPDATE_TIME_CHANGED,data.upPartnerSkillTime)
    end
    --技能点发生变化
    if data.partnerSkill ~=nil then
        EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_POINT_CHANGED,data.partnerSkill)
    end

    if data.fiveSoulPoint ~= nil then
        EventControler:dispatchEvent(UserEvent.USEREVENT_FIVESOULPOINT_CHANGE)
    end

    if data.endlessId ~= nil then
        -- EventControler:dispatchEvent(EndlessEvent.ENDLESS_DATA_CHANGED)
    end

    if data.biographyNodeId ~= nil then
        EventControler:dispatchEvent(BiographyUEvent.EVENT_REFRESH_UI)
    end

    EventControler:dispatchEvent(UserExtEvent.USEREXTEVENT_MODEL_UPDATE,data);

    WorldModel:sendRedStatusMsg()

end

-- 通过upSpTime更新体力
function UserExtModel:updateSpByUpTime()
    
    local maxSpLimit = UserModel:getMaxSpLimit()
    local curSp = self:sp()

    if curSp <  maxSpLimit then
        --体力恢复间隔(秒)
        local secondInterval = FuncDataSetting.getDataByConstantName("HomeSPRecoverSpeed")
        local upSpTime = self:upSpTime()

        -- 增加的sp 为解决延时的问题 时间比服务器慢2秒
        local dt = TimeControler:getServerTime()-2  - upSpTime
        if dt < 0 then
            dt = 0
        end
        --直接用时差除以间隔 向下取整
        local addSp = math.floor( dt/secondInterval ) --TimeControler:countIntervalTimes(secondInterval,upSpTime,TimeControler:getServerTime()-2 )
        local newSp = self._initSp + addSp
        if tonumber(newSp) >= tonumber(maxSpLimit) then
            newSp = maxSpLimit
        end

        self:setSp(newSp)
        echo(newSp,"______更新体力-111111111111111----",self:sp())
    end
    -- echo("根据上次体力变化",TimeControler:getServerTime() -self:upSpTime() ,    curSp,self:sp())
    -- echo("根据上次体力更新时间",self:upSpTime(), TimeControler:getServerTime())
end

-- 通过事件更新体力
function UserExtModel:updateSpByTimeEvent(times)
    --目前为了更好的同步 暂定是60秒刷新一次时间 
    if self._data ~= nil then

        self:updateSpByUpTime()

        -- local maxSpLimit = UserModel:getMaxSpLimit()
        -- times = times or 1
        -- local curSp = self:sp()
        -- local newSp = tonumber(curSp) + times
        -- if newSp >  maxSpLimit then
        --     newSp = maxSpLimit
        -- end
        -- if tonumber(curSp) < tonumber(maxSpLimit) then
        --     -- newSp = maxSpLimit
        --     self:setSp(newSp)
        -- end
    end
end

-- 更新sp的值
function UserExtModel:setSp(newSp)
    --如果数据没发生变化 就不发事件了
    if self._data.sp == newSp then
        return
    end
    local maxSpLimit = UserModel:getMaxSpLimit()

    if tonumber(newSp) <= tonumber(maxSpLimit) then
        self._data.sp = newSp
        EventControler:dispatchEvent(UserEvent.USEREVENT_SP_CHANGE);
    end

end

-- 获取灵穴修炼节点
function UserExtModel:getPulseNode( ) 
    local pulseNode = self:pulseNode()
    if pulseNode == nil then
        return 0
    end

    -- return 40
    return pulseNode
end
--伙伴技能点
function UserExtModel:getPartnerSkillPoint()
    return  self:partnerSkill()
end
--技能点更新
--VIP变化
--设置技能点变化
function UserExtModel:setPartnerSkillPoint()
    local _newVIP = UserModel:vip() 
    local _now_limit = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillMax")
    local _time_interval = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillInterval")
    local _last_update_time = self:upPartnerSkillTime()
    local _skill_point_inc = TimeControler:countIntervalTimes(_time_interval,_last_update_time)
    local _now_skill_point = self:partnerSkill()
    
    local _after_fix_skill_point = _now_skill_point + _skill_point_inc
    if  _after_fix_skill_point> _now_limit then
        _after_fix_skill_point = _now_limit
    end
    --上限
    self._data.partnerSkill = _after_fix_skill_point
--    TimeControler:registerCycleCall(TimeEvent.TIMEEVENT_PARTNER_SKILL_POINT_RESUME_EVENT,_time_interval)
    self:setSkillPointTimer(_time_interval)
    EventControler:addEventListener(TimeEvent.TIMEEVENT_PARTNER_SKILL_POINT_RESUME_EVENT,self.onPartnerSkillPointInc,self)
end
--重新设置技能点冷却时间
function UserExtModel:resetSkillPointTime()
    local _newVIP = UserModel:vip() 
    local _now_limit = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillMax")
    local _now_skill_point = self:partnerSkill()
    --检测是否达到了最大值-1
    if _now_skill_point == _now_limit-1 then
        local _time_interval = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillInterval")
        self:setSkillPointTimer(_time_interval)
    end
end
--技能点增加
function UserExtModel:onPartnerSkillPointInc()
    local _newVIP = UserModel:vip() 
    local _now_limit = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillMax")
    local _time_interval = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillInterval")
    local _now_skill_point = self:partnerSkill()
    
    local _after_fix_skill_point = _now_skill_point + 1
    local _old_skill_point = _now_skill_point
    if  _after_fix_skill_point>= _now_limit then
        _after_fix_skill_point = _now_limit
    end
    --上限
    self._data.partnerSkill = _after_fix_skill_point
    --派发事件
    if _old_skill_point ~= _after_fix_skill_point then
        EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_POINT_CHANGED,_after_fix_skill_point)
    end
    self:setSkillPointTimer(_time_interval)
end
--获取恢复到下一个技能点所需要的时间
function UserExtModel:getSkillPointResumeTime()
    return TimeControler:getCdLeftime(TimeEvent.TIMEEVENT_PARTNER_SKILL_POINT_RESUME_EVENT)
end
--设定伙伴技能恢复计时器
function UserExtModel:setSkillPointTimer( left_time)
    TimeControler:startOneCd(TimeEvent.TIMEEVENT_PARTNER_SKILL_POINT_RESUME_EVENT,left_time)
end
-- 检查是否可以进行特殊委托
function UserExtModel:chkCanDoExpecialDelelagte( ... )
    return self:getDelelagteDoCount() >= FuncDataSetting.getUnLockSpecialTaskNum()
end
-- 获取当前已经进行的委托数
function UserExtModel:getDelelagteDoCount( ... )
    local dcount = self._data.delegateCount or 0
    return dcount
end

-- 获取体力满剩余时间,秒
function UserExtModel:getFullSPLeftTime()
    local leftTime = 0
    local sp = UserExtModel:sp()
    local maxSp = UserModel:getMaxSpLimit()
    if self:checkIsMaxSp() then
        return leftTime
    end

    local secondInterval = FuncDataSetting.getDataByConstantName("HomeSPRecoverSpeed")
    local upSpTime = self:upSpTime()
    local dt = TimeControler:getServerTime()- upSpTime
    local nextLeftTime = secondInterval - math.fmod(dt, secondInterval)
    
    if (sp + 1) >= maxSp then
        leftTime = nextLeftTime
    else
        leftTime = nextLeftTime + ( (maxSp - (sp + 1)) ) * secondInterval
    end

    return leftTime
end

-- 检查体力是否已满
function UserExtModel:checkIsMaxSp()
    local sp = UserExtModel:sp()
    local maxSp = UserModel:getMaxSpLimit()

    return sp >= maxSp
end

--判断登入时间是否不一致 ,true表示正常 false 表示不正常
function UserExtModel:checkLoginTime(lastLoginTime, currentTime )
    local loginTime = self._data.loginTime or 0
    echo("last:",loginTime,"____currentTime_",lastLoginTime)
    if loginTime == 0 then
        self._data.loginTime = currentTime
        return true
    end
    if loginTime ~= lastLoginTime then
        echoError("登入时间不一致,可能在异地已经登入了,current:",lastLoginTime,'last:',loginTime)
        local errorCode =  ErrorCode.duplicate_login
        Server:checkError( {error = {code =errorCode,message =GameConfig.getErrorLanguage("#error"..errorCode)}}, hideCommonTips,isInitError)
        return  false
    end
    self._data.loginTime = currentTime
    return true
    

end

return UserExtModel

