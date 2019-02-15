
local UserModel = class("UserModel",BaseModel)
UserModel.USER_TYPE = {
    NORMAL = "1", --正常
    TEST = "2", --测试
}
--DataResource表
UserModel.RES_TYPE = FuncDataResource.RES_TYPE

--满足的条件
UserModel.CONDITION_TYPE = {
    LEVEL = 1,      --等级条件
    STATE = 2,      --境界    
    VIP = 3,        --vip 级别
    STAGE = 4,      --主线进度
    ELITE = 5,      --精英进度
    INTERACT = 6,   --奇缘指定NPC是否开启
    QUEST_GET = 8,  --任务已经领取
    STAR_CHEST = 9, --星际宝箱
    ARR_PARTNER_NUM = 10, --上阵伙伴数量
    PARTNER_NUM = 11, --伙伴数量
}

--不知为啥要有这个，为啥不是nil？
UserModel.DEFAUTL_RID = "1";

--Player={};
function UserModel:init(d)
    -- dump(d.loves, " 用户数据------------", 8)
    self.modelName = "user"
    UserModel.super.init(self, d)
--    Player.roleInfo=d;
    self._datakeys = {
        avatar = "101",              --char id
        _id = "",                   --角色ID
        --_it = "",                   --初始化时间init time
        ctime = 0,                  ---初始化时间戳
        uid = "",                   --账号ID
        uidMark = "",               --显示给玩家的id
        name = "",                   --玩家名
        vip = numEncrypt:ns0(),     --VIP等级
        vipExp = numEncrypt:ns0(),  -- vip经验
        level = numEncrypt:ns0(),     --等级
        exp = numEncrypt:ns0(),       --经验
        state = numEncrypt:ns0(),     --境界
        quality = numEncrypt:ns1(),   --品阶
        position = numEncrypt:ns1(),  --升品装备位
        star = numEncrypt:ns1(),      --星级
        starPoint = numEncrypt:ns1(),      --星级装备位
        equips = {},                 -- 主角装备
        head = "",     --头像
        frame = "",     --头像框

        gold = numEncrypt:ns0(),      --钻石数量（充值）
        giftGold = numEncrypt:ns0(),  --累计钻石数量（非充值)
        goldTotal = numEncrypt:ns0(), --累计钻石数量（充值）
        giftGoldTotal = numEncrypt:ns0(), --累计钻石数量（非充值)
        -- goldConsumeCoin = numEncrypt:ns0(), --锁妖塔魔石
        finance = {},                   --货币

        counts = {},    --次数列表
        score = {},                   --战力表

        -- 一些列表
        states = {},                 --境界列表
        treasureFormula = {},        --防守法宝阵型

        -- server端没有的字段
        stateName = "啥是境界名称",   --境界名称
        factionName = "朱雀门",
        factionID = 123456,

        events = {},
        type = "", --用户类型，是一个逗号分割的串， "1,2,3,4" ; 1正常/2测试

        guildExt = {},
        guildId = "",
        guildName = "", --仙盟名称
        guildSkills = {},
        trials = {},
        trialPoints = {},

        -- 章节成绩等数据
        chapters = {},
        -- 快乐签到
        happySign = {},

        -- 问情
        romances = {},
        romanceInteracts = {},
        -- todo 上面的两个数组，清理奇缘时可以删除掉 by ZhangYanguang
        stageCounts = {},

        --商品购买次数
        buyProductTimes = {},

        --战力
        abilityNew = {},
        goldConsumeCoin = 0,
        goldConsumeCoinInner = 0,
        goldConsumeExpireTime = 0,

        -- 主角天赋列表
        talents = {},
        -- 主角特权列表
        privileges = {},
        -- 主角星魂信息列表
        starInfo = {},
        --试炼的星级
        -- trials = {},
        --领取等级奖励列表
        receiveLevelRewards = {},
        --领取的成就奖励 
        receiveAchievementIds = {},

        --完成的成就
        achievements = {},

        --统计
        frequencies = {},

        --历史道具
        historyItems = {},

        --将要触发的新手组
        guide = {},

        -- 挂机数据
        delegates = {},
    
        --  头衔ID
        crown = 1,
        towerFloor = {},
        -- 五灵
        fivesouls = {},
        fiveSoulLevel = 1,

        --须臾仙境数据        
        wonderFloors = {},
        ---评论的次数数据
        commentTimes = {},
       
        --无底深渊数据
        endlessFloors = {},

        --锁妖塔
        towerExt = {},

        --资源找回
        retrieveList = {},
        --红包发送列表
        redPackets = {},
        --三皇台造物数据
        lotteryQueues = {},
        
        lotteryExt = {},
        -- 特权
        privilege = {},

        -- 名册系统
        handbooks = {},

        --是否有充值行为  月卡 基金  购买仙玉等
        buyProductTimes = {},

        --充值的金额
        rechargeTotal = 0,
    }

    --缓存登陆的等级
    self._lvUpViewPreLv = d.level or 1;

    self:createKeyFunc()

end

-- 获得锁妖塔历史到达层数
-- 只要到达,不需通关,重置后也保存历史最高值
function UserModel:getTowerFloor()
    -- if self._data.towerExt then
        local num = TowerMainModel:getMaxReachFloor() 
        if not num then
            if self._data.towerExt then
                num = self._data.towerExt.maxReachFloor or 0
            else
                num = 0
            end
        end
        return num
    -- else
    --     local num = TowerMainModel:getMaxReachFloor()
    --     return num
    -- end
end

function UserModel:getUserData()
    return self._data
end

--[[
    从出生到现在一共消耗的钻石数
]]
function UserModel:totalCostGold()
    return self:giftGoldTotal() + self:goldTotal() - self:gold() - self:giftGold();
end

--登陆游戏后，所有model都初始化后执行 LoginControler:doGetUserInfoBack 中执行
function UserModel:initPlayerPower()
    self._playerPower = self:getAbility();
end

function UserModel:updatePlayerPower()
    local oldPower = self._playerPower;
    self._playerPower = self:getAbility();

    echo("---updatePlayerPower---updatePlayerPower---updatePlayerPower---updatePlayerPower--",  self._playerPower);

    if oldPower == nil then 
        echo("warning!!! UserModel:updatePlayerPower oldPower is nil!");
    end 

    if oldPower ~= self._playerPower then 
        EventControler:dispatchEvent(UserEvent.USEREVENT_PLAYER_POWER_CHANGE, 
            {prePower = oldPower, curPower = self._playerPower}); 

        EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, 
            {questType = TargetQuestModel.Type.POWER});  
    end 

end

function UserModel:getUserData(  )
    return self._data
end

--是否设置过名字
function UserModel:isNameInited()
    local name = self._data.name
    if name =="" or name ==nil then
        return false
    end
    return true
end

--//主角的性别,返回 1:男,2:nv
function UserModel:sex()
    if LoginControler:isLogin() then
        return FuncChar.getCharSex(self:avatar())
    else
        -- 序章中有可能会设置avatar
        local avatar = "101"
        if self._data then
            if self._data.avatar and self._data.avatar ~= "" then
                avatar = self._data.avatar
            end
        end
        return FuncChar.getCharSex(avatar)
    end
end

--[[
    设置avatar
    序章中引导选择角色后会设置avatar    
]]
function UserModel:setAvatar(avatar)
    if PrologueUtils:showPrologue() then
        -- 如果序章没有initRes，该值为nil
        if self._data then
            self._data.avatar = avatar
        end
    end
end

--获取用户的名字
function UserModel:name(  )
    if self._data.name =="" or not self._data.name then
        if self:sex() == 1 then
            return GameConfig.getLanguage("tid_common_2001")
        elseif self:sex() == 2 then
            return "女侠"
        end
    end
    return  self._data.name
end

-- 二测升级奖励临时逻辑
function UserModel:levelUpRewardAction()
    local currentLevel = self:level()
    local levels = {4,5,7,13}
    if table.indexof(levels,currentLevel) then
        -- 判断
        -- LS:prv():set("LevelUpRewardShow",currentLevel) 
    end
end

--更新data数据
function UserModel:updateData(data)
    -- dump(data,"====主角更新数据=====")
    local  old_coin=self:getCoin();
    local  _old_level=self:level()

    local  _old_exp=self:exp();
    local  _old_vip=self:vip();
    local  _old_coin=self:getCoin();
    local  _old_gold = self:getGold();
    local _old_quality = self:quality();
    local _old_char_ability = self:getCharAbility();
    local _old_goldConsumeCoin = self:getGoldConsumeCoin()
    local _old_position = self:position()

    UserModel.super.updateData(self, data);

    -- 发送升级消息
    if data.level ~= nil and data.level ~=_old_level then
        if WindowControler:isCurViewIsGm() == true then 
            EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE, {level = data.level}); 
        else 
            self:cacheLvUp(data.level);
        end
        EventControler:dispatchEvent(UserEvent.USER_INFO_CHANGE_EVENT)

        self:levelUpRewardAction()
    end
    
--//exp发生变化
    if(data.exp ~=nil and data.exp ~=_old_exp)then
        EventControler:dispatchEvent(UserEvent.USEREVENT_EXP_CHANGE,{exp = data.exp});
    end
    if data.vip ~= nil and data.vip ~=_old_vip then 
        EventControler:dispatchEvent(UserEvent.USEREVENT_VIP_CHANGE, 
            {vip = data.vip}); 
    end

    -- 特权变化
    if data.privileges ~= nil then
        EventControler:dispatchEvent(UserEvent.USEREVENT_TEQUAN_CHANGE);
    end

--//铜钱发生变化.0
    if  data.finance  then
        if(data.finance.coin and  data.finance.coin ~=_old_coin)then
            EventControler:dispatchEvent(UserEvent.USEREVENT_COIN_CHANGE,{coinChange=data.finance.coin-old_coin});
            --伙伴红点
--            PartnerModel:partnerRedPoint()
            EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT);
        end
        --竞技场货币
        if data.finance.arenaCoin then
            EventControler:dispatchEvent(UserEvent.USEREVENT_PVP_COIN_CHANGE,data.finance.arenaCoin)
        end
        
        -- 天赋点 废弃 
        -- if data.finance.talentPoint then
        --     EventControler:dispatchEvent(UserEvent.USEREVENT_TALENT_POINT_CHANGE)
        -- end
        --成就点
        if data.finance.achievementPoint then
            EventControler:dispatchEvent(UserEvent.USEREVENT_ACHIEVMENT_POINT_CHANGE)
        end
        
        -- 伙伴皮肤卷变化
        if data.finance.skinCoin then
            EventControler:dispatchEvent(UserEvent.USEREVENT_PARTNER_SKINCOIN_CHANGE)
        end

        -- 主角五彩线变化
        if data.finance.garmentCoin then
            EventControler:dispatchEvent(UserEvent.USEREVENT_GARMENT_CHANGE)
        end

        -- 锁妖塔魔石发生变化
        if data.finance.dimensity then
            EventControler:dispatchEvent(UserEvent.USEREVENT_DIMENSITY_CHANGE)
        end
        if data.finance.fiveSoulCoin then
             EventControler:dispatchEvent(UserEvent.USEREVENT_FIVESOULCOIN_CHANGE)
        end

        if data.finance.wonderLandCoin then
             EventControler:dispatchEvent(UserEvent.USEREVENT_XIANFU_CHANGE)
        end
        if data.finance.guildCoin then
             EventControler:dispatchEvent(UserEvent.USEREVENT_GUILDCOIN_SUCCESS)
        end
        -- 仙气
        if data.finance.crosspeakCoin then
             EventControler:dispatchEvent(UserEvent.USEREVENT_CROSSPEAKCOIN_CHANGE)
        end

        --转盘抽奖券
        if data.finance.rouletteCoin then
            EventControler:dispatchEvent(UserEvent.USEREVENT_ROULETTE_COIN_CHANGE)
        end
        
        --主角头衔变化
        EventControler:dispatchEvent("BUY_TOUXIAN_EVENT")
        
    end
    --灵石变化
    if data.goldConsumeCoin and data.goldConsumeCoin ~= 0 then
        local tempNum = data.goldConsumeCoin - _old_goldConsumeCoin
        EventControler:dispatchEvent(UserEvent.USEREVENT_CHANGE_SPIRITSTONES,{tempNum = tempNum})
    end
    local newGold = self:getGold()
    --仙玉变化
    if data.giftGold ~= nil or (data.gold ~= nil  and _old_gold~=newGold ) then 
        -- 和后端确认，data.gold发生变化时候一定有充值行为发生
        if data.gold ~= nil and newGold >  _old_gold  then
            echo("有充值行为,充值金额", newGold - _old_gold)
            EventControler:dispatchEvent(RechargeEvent.FINISH_RECHARGE_EVENT,newGold-_old_gold)
        end
        EventControler:dispatchEvent(UserEvent.USEREVENT_GOLD_CHANGE); 
        EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT);
    end 

   

    

    --主角战力变化

   
    
    -- 主角品阶变化
    if data.quality ~= nil and (_old_quality ~= data.quality)  then 
        EventControler:dispatchEvent(UserEvent.USEREVENT_QUALITY_CHANGE); 
        EventControler:dispatchEvent(UserEvent.USER_INFO_CHANGE_EVENT)
    end 
    -- 主角品阶装备位变化
    if data.position ~= nil then
        local oldPosition = _old_position
        local position = {}
        if data.position > 0 then
            -- EventControler:dispatchEvent(PartnerEvent.PARTNER_ATTR_CHANGE_EVENT)
            local tempValue = data.position - oldPosition
            local toBit = number.splitByNum(tempValue, 2)
            for i = 4, 5 - #toBit, -1 do
                position[tostring(i)] = toBit[#toBit - (4 - i)]
            end
        end
        -- if data.quality == nil then
        --     FuncCommUI.showPowerChangeArmature(_old_char_ability or 10, self:getCharAbility() or 10);
        -- end
        EventControler:dispatchEvent(UserEvent.USEREVENT_QUALITY_POSITION_CHANGE, 
                                {id = tonumber(UserModel:avatar()), position = position})
    end
    -- 主角星级
    if data.star ~= nil then
        EventControler:dispatchEvent(UserEvent.USEREVENT_STAR_CHANGE);
        EventControler:dispatchEvent(UserEvent.USER_INFO_CHANGE_EVENT)
    end
    -- 主角星级装备位
    if data.starPoint ~= nil then
        EventControler:dispatchEvent(UserEvent.USEREVENT_STAR_POINT_CHANGE);
    end
    -- 主角装备
    if data.equips ~= nil then
        EventControler:dispatchEvent(UserEvent.USEREVENT_EQUIPS_CHANGE);
        if WindowControler:checkHasWindow("PartnerView") then
            local showPower = false
            for m,n in pairs(data.equips) do
                if n.awake and n.awake == 1 then
                    showPower = true
                end
            end
            if showPower then
                FuncCommUI.showPowerChangeArmature(_old_char_ability or 10, self:getCharAbility() or 10);
            end
            
        end
    end

    -- 副本精英战斗次数发生变化
    if data.stageCounts ~= nil then
        EventControler:dispatchEvent(UserEvent.USEREVENT_STAGE_COUNTS_CHANGE); 
    end

    

    if data.frequencies ~= nil then 
        EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT); 
    end 

    

    if data.guildId ~= nil then
        EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT);
    end

   
    EventControler:dispatchEvent(UserEvent.USEREVENT_MODEL_UPDATE,data);
end

-- 主角伙伴战力变化
function UserModel:getCharAbility()
    local _ability = CharModel:getCharAbility()
    return _ability
end

--删除数据
function UserModel:deleteData( keyData ) 
    -- dump(keyData, "deleteData");
    --深度删除 key
    table.deepDelKey(self._data, keyData, 1)

    

    EventControler:dispatchEvent(UserEvent.USEREVENT_MODEL_UPDATE);
end

function UserModel:cacheLvUp(lvl)
    self._lvUp = lvl;
    self._isLvUp = true;
end

function UserModel:resetLvUp()
    self._lvUp = nil;
    self._isLvUp = false;
end

function UserModel:lastLv(lvl)
    self._lvUpViewPreLv = lvl;
end

function UserModel:getlastLv()
    return self._lvUpViewPreLv;
end

--[[
    是否升级
]]
function UserModel:isLvlUp()
    if self._isLvUp == true then 
        return true, self._lvUp;
    else 
        return false;
    end 
end

-- 战斗前缓存用户数据
function UserModel:cacheUserData( ) 
    if self._cacheUserData == nil then
        self._cacheUserData = {}
    end

    self._cacheUserData.preExp = self:exp()
    self._cacheUserData.preLv = self:level()
end

-- 获取战斗前缓存数据
function UserModel:getCacheUserData( ) 
    return self._cacheUserData
end

--[[
    资源是否足够
    resTable = {[1]="1,1001,20",[2]="1,1002,20",[3]="1,1003,20",[4]="2,30009",}

    <1,1001,20;1,1002,20;1,1003,20;2,30000>配表中形态 

    都满足return true 否则返回不足的资源类型
]]
function UserModel:isResEnough(resTable)
    for i, v in ipairs(resTable) do
        local needNum,hasNum,isEnough, resType,resId = self:getResInfo(v)
        if hasNum < tonumber(needNum) then
            return resType,resId;
        end 
    end
    return true;
end

-- 该id材料碎片合成时需要的消耗的材料list
function UserModel:getCombineResCost(itemPieceId)
    local composeItemId = FuncItem.getComposeItemId(itemPieceId)
    if composeItemId == nil then
        echoError("ItemListView:doItemPieceComposeAction itemPieceId 没有合成配置")
        return
    end

    local itemPieceNums = ItemsModel:getItemNumById(itemPieceId)
    local itemData = FuncItem.getItemData(composeItemId)
    local costTable = itemData.cost
    
    return costTable
end

-- 该id材料碎片合成时能得到的最大数目
function UserModel:maxCombineNums(itemPieceId)
    local costTable = self:getCombineResCost(itemPieceId)
    local numTable = {}
    for i,v in ipairs(costTable) do
        local needNum, hasNum, isEnough, resType, resId = self:getResInfo(v)
        local num = math.floor(hasNum / needNum)
        table.insert(numTable, num)
    end
    local sortFunc = function (a, b)
        return tonumber(a) < tonumber(b)
    end

    table.sort(numTable, sortFunc)
    return numTable[1]
end

--获取某种资源 信息, 返回5个值, 需要量, 拥有量,是否满足,资源类型,resId(如果是道具)    ------    ,resStr 格式 1,100 如果是道具  是1,10001,1,
function UserModel:getResInfo( resStr )
    if not resStr then
        echoError("没有传入资源信息")
        return 0,0,false,0
    end
    local res
    if type(resStr) == "table" then
        res = resStr
    else
        res =  string.split(resStr, ",")
    end  
    local resType = res[1];
    local hasNum;
    local needNum = 0;
    local resId;

    if resType == UserModel.RES_TYPE.ITEM then 
        hasNum = ItemsModel:getItemNumById(res[2]);
        resId = res[2]
        needNum = res[3];
    elseif resType == UserModel.RES_TYPE.EXP then 
        hasNum = self:exp();
        needNum = res[2];    
    elseif resType == UserModel.RES_TYPE.COIN then
        hasNum = self:getCoin();
        needNum = res[2];
    elseif resType == UserModel.RES_TYPE.DIAMOND or 
            resType == UserModel.RES_TYPE.GIFTGOLD then
        hasNum = self:getGold();
        needNum = res[2];
    elseif resType == UserModel.RES_TYPE.SP then
        hasNum = UserExtModel:sp();
        needNum = res[2];        

    --法力
    -- elseif resType == UserModel.RES_TYPE.MP then
    --     hasNum = self:getMp();
    --     needNum = res[2];        

    --竞技场币
    elseif resType == UserModel.RES_TYPE.ARENACOIN then
        hasNum = self:getArenaCoin();
        needNum = res[2];  
    --侠义值
    elseif resType == UserModel.RES_TYPE.CHIVALROUS then
        hasNum = self:getRescueCoin()
        needNum = res[2]
    --工会比
    elseif resType == UserModel.RES_TYPE.GUILDCOIN then
        hasNum = self:getGuildCoin();
        needNum = res[2];  

    --法宝
    elseif resType == UserModel.RES_TYPE.TREASURE then
        hasNum = 0
        resId = res[2]
        needNum = 1;  
    --伙伴整卡
    elseif resType == UserModel.RES_TYPE.PARTNER then
        hasNum = 0
        resId = res[2]
        needNum = 1;  
    elseif resType == UserModel.RES_TYPE.LINGSHI then
        hasNum = UserModel:goldConsumeCoin()
        needNum = res[2];
    --抽卡刷新令
    
    elseif resType == UserModel.RES_TYPE.GARMENT then
        hasNum = UserModel:getGarment()
        needNum= res[2];
    elseif resType == UserModel.RES_TYPE.CLOTHES then
        hasNum = 0
        needNum= 1;
        resId = res[2]
    elseif resType == UserModel.RES_TYPE.SKINCOIN then
        hasNum = UserModel:getSkinCoin()
        needNum= res[2];
    elseif resType == UserModel.RES_TYPE.DIMENSITY then
        hasNum = UserModel:getDimensity()
        needNum= res[2];
    elseif resType == UserModel.RES_TYPE.CIMELIACOIN then
        hasNum = UserModel:getCimeliaCoin()
        needNum= res[2];
    
    elseif resType == UserModel.RES_TYPE.WULINGPOINT then
        hasNum = UserExtModel:fiveSoulPoint()
        needNum= res[2];
    elseif resType == UserModel.RES_TYPE.PANRTNERSKIN then  --伙伴皮肤
        hasNum = 0
        needNum = 1
        resId = res[2]
    elseif resType == UserModel.RES_TYPE.USERHEADFRAME then  --头像框
        hasNum = 0
        needNum = 1
        resId = res[2]
    elseif resType == UserModel.RES_TYPE.XIANFU then
        hasNum = UserModel:getWonderLandCoin()
        needNum = res[2]
    elseif resType == UserModel.RES_TYPE.ACHIEVEMENT then
        hasNum = UserModel:getAchievementPoint()
        needNum= res[2];
    elseif resType == UserModel.RES_TYPE.GIFTGOLDVIP then
        hasNum = 0
        needNum = res[2]
    elseif resType == UserModel.RES_TYPE.VIPEXP then
        hasNum = 0
        needNum = res[2]
    elseif resType == UserModel.RES_TYPE.WOOD then
        hasNum = GuildModel:getOwnGuildWoodNum()
        needNum = res[2]
    elseif resType == UserModel.RES_TYPE.GUILD_JADE then
        hasNum = GuildModel:getOwnGuildJadeNum()
        needNum = res[2]
    elseif resType == UserModel.RES_TYPE.GUILD_STONE then
        hasNum = GuildModel:getOwnGuildStoneNum()
        needNum = res[2]

    elseif resType == UserModel.RES_TYPE.MONTH then
        hasNum =0 
        needNum = 1
        resId = res[2]
    elseif resType == UserModel.RES_TYPE.TOOL then
        hasNum = 1
        needNum = res[2]
    elseif resType == UserModel.RES_TYPE.EXPLORERES then
        hasNum =0 
        needNum = 0
    else 
        hasNum = 0
        needNum =0
        --todo 继续定义
        echoError("warning! UserModel:isResEnough undefined resType " 
            .. tostring(resType));
    end
    
    needNum = needNum or 0

    --添加补丁 needNum解析出来有空字符串的情况
    if needNum == "" then
        needNum = 0
    end
    needNum = tonumber(needNum)
    local isEnough = hasNum >= needNum 
    return  needNum,hasNum,isEnough ,resType,resId
end



--判断某种条件是否满足 传入的结构  { {t= 1,v = 2 }  ,...     }  返回 不满足的类型 按照顺序 只用返回一个
function UserModel:checkCondition( conditionGroup )

    --如果没有任何开启条件的 返回true
    if not conditionGroup then
        return nil
    end
    --先解密
    conditionGroup = numEncrypt:decodeObject(conditionGroup) 
    for k,v in pairs(conditionGroup) do
        local t = v.t
        local value = v.v

        --等级判断
        if t == self.CONDITION_TYPE.LEVEL then
            if self:level() < value then
                return t
            end
        --境界是否满足
        elseif t == self.CONDITION_TYPE.STATE then
            if self:state() < value then
                return t
            end
        --vip是否达到条件
        elseif t == self.CONDITION_TYPE.VIP then
            if self:vip() < value then
                return t
            end
        elseif t == self.CONDITION_TYPE.STAGE then
            local needRaidId = value
            -- 已经通关的最大ID
            local passMaxRaidId = UserExtModel:getMainStageId()
            if tonumber(passMaxRaidId) < tonumber(needRaidId) then
                return t
            end
        elseif t == self.CONDITION_TYPE.ELITE then
            local needRaidId = value
            -- 已经通关的最大ID
            local passMaxRaidId = UserExtModel:getEliteStageId()
            if tonumber(passMaxRaidId) < tonumber(needRaidId) then
                return t
            end
        elseif t == self.CONDITION_TYPE.INTERACT then
--            if not EliteModel:isOpenXiaoGuanById(value) then
--                return t
--            end
        elseif t == self.CONDITION_TYPE.QUEST_GET then
            local questId = value;
            if TargetQuestModel:isMainLineQuestFinish(questId,nil,t) == false then 
                return questId;
            end
        elseif t ==  self.CONDITION_TYPE.STAR_CHEST then   --星级宝箱
            if  WorldModel:hasStarBoxes() == false then
                return 1   ---没有可领取的宝箱
            end
        elseif t == self.CONDITION_TYPE.ARR_PARTNER_NUM then
            local num = value
            local pantnernum =  TeamFormationModel:getPartnerNumBySystemId() --- 布阵了几个人 
            if pantnernum >= num and pantnernum <= 6 then
            else
                return 1
            end
        elseif t == self.CONDITION_TYPE.PARTNER_NUM then 
            local num = value
            local partnerCount = PartnerModel:getPartnerNum()
            if partnerCount < num then
                return 1   --伙伴数量不足
            end
        end
    end

    --返回空表示满足
    return nil
end

-- 通用条件不满足提醒tip
--判断某种条件是否满足 传入的结构  { {t= 1,v = 2 }  ,...     }
function UserModel:getConditionTip(conditionGroup )
    local lockTip = nil
    --如果没有任何开启条件的 返回true
    if not conditionGroup then
        return lockTip
    end

    --先解密
    conditionGroup = numEncrypt:decodeObject(conditionGroup) 
    for k,v in pairs(conditionGroup) do
        local t = v.t
        local value = v.v

        --等级判断
        if t == self.CONDITION_TYPE.LEVEL then
            lockTip = "等级达到" .. value .. "级开启"
        --境界是否满足
        elseif t == self.CONDITION_TYPE.STATE then
            
        --vip是否达到条件
        elseif t == self.CONDITION_TYPE.VIP then
            lockTip = "VIP达到" .. value .. "级开启"

        elseif t == self.CONDITION_TYPE.STAGE or t == self.CONDITION_TYPE.ELITE then
            local raidId = value
            local raidData = FuncChapter.getRaidDataByRaidId(raidId)
            local raidName = WorldModel:getRaidName(raidId)
            local chapter = WorldModel:getChapterNum(FuncChapter.getChapterByStoryId(raidData.chapter))
            local section = WorldModel:getChapterNum(FuncChapter.getSectionByRaidId(raidId))

            -- if t == self.CONDITION_TYPE.STAGE then
            --     lockTip = "通关六界第" .. chapter .. "章第" .. section .. "节" .. raidName .. "开启"
            -- else
            --     lockTip = "通关忆梦第" .. chapter .. "章第" .. section .. "节" .. raidName .. "开启"
            -- end

            lockTip = "通关第" .. chapter .. "章第" .. section .. "节" .. raidName .. "开启新故事"
            if t == self.CONDITION_TYPE.STAGE then
                lockTip = "通关剧情第" .. chapter .. "章第" .. section .. "节" .. raidName .. "开启"
            else
                lockTip = "通关回魂仙梦第" .. chapter .. "章第" .. section .. "节" .. raidName .. "开启"
            end
            -- lockTip = "通关第" .. chapter .. "章第" .. section .. "节" .. raidName .. "开启"
        elseif t == self.CONDITION_TYPE.INTERACT then
    
        elseif t == self.CONDITION_TYPE.QUEST_GET then
           
        end
    end

    return lockTip
end

-- 获取主角所有信息 包括各系统的数据   获取他人信息 传参数_playerInfo
function UserModel:getAbilityUserData(_playerInfo)
    local data = {}
    if _playerInfo then
        data = _playerInfo
    else
        data = table.copy(self._data)
        data.partners = PartnerModel:data()
        data.cimeliaGroups = ArtifactModel:data()
        data.title = TitleModel:getHisData()
        data.treasures = TreasureNewModel:data()
    end
    return data  
end




--获取战力接口迁移到 AbilityModel
function UserModel:getAbility(params)
    return AbilityModel:getAbility(params)
end
-- 阵容总战力 for 阵容
function UserModel:getTeamAbility(treasureId,teamFormation)
    local params = {
        treasureId = treasureId,
        team = teamFormation
    }
    local ability = UserModel:getAbility(params)
    -- echoError("abilityability === ",treasureId,ability)
    return ability
end


-- 计算竞技场防守阵容战力
function UserModel:getPvpAbility(_formationType)
    local ability = 0
    local charAbility = CharModel:getCharAbility()
    local teamFormation = TeamFormationModel:getFormation(_formationType)
    local treasureId = TeamFormationModel:getTreasueIdByFormation(_formationType)
    ability = UserModel:getTeamAbility(treasureId,teamFormation)

--    echoError("==============主角 总战力 ==== ",ability)
    return ability
end


function UserModel:getGoldConsumeCoin()
    return self:goldConsumeCoin()
end

-- 获取总钻石数量
function UserModel:getGold()
    local gold = self:gold() + self:giftGold()
    return gold
end

function UserModel:getFrequencyByKey(key, defaultValue)
    local defaultValue = defaultValue or 0;
    local ret = self:get2d("frequencies", key, defaultValue)
    return tonumber(ret);
end

-- 通过key，获取货币finance的二级属性
--[[
    coin                --银币
    mp                  --法力
    arenaCoin           --竞技场货币
    guildCoin           --公会声望货币
    token               --抽卡系统令牌
    talentPoint         --主角天赋系统天赋点
]]
function UserModel:getFinanceByKey(key,defaultValue)
    return self:get2d("finance", key, defaultValue)
end

-- 获取巅峰竞技场货币
function UserModel:getCrossPeakCoin()
    return self:getFinanceByKey("crosspeakCoin",0)
end
-- 获取巅峰竞技场最大货币
function UserModel:getMaxCrossPeakCoin()
    return self:getFinanceByKey("crosspeakCoinLimit",0)
end
-- 获取灵脉货币灵气数量
function UserModel:getPulseCoin()
    echoWarn("已废弃字段----")
    return  0
    -- return self:getFinanceByKey("pulseCoin",0)
end

-- 侠义值
function UserModel:getRescueCoin()
    return self:getFinanceByKey('rescueCoin', 0)
end

--五灵币
function UserModel:getResWuLingCoin()
   return self:getFinanceByKey('fiveSoulCoin', 0)
end


--//获取天赋点数
function UserModel:getTalentPoint()
    echoError("废弃的资源类型talentPoint")
   return 0  --self:getFinanceByKey("talentPoint",0);
end
-- 获取灵石(银币)数量
function UserModel:getCoin()
    return self:getFinanceByKey("coin",0)
end
-- 获取星尘数量
function UserModel:getStarDirt()
    echoError("废弃的资源类型StarDirt")
    return 0
end
-- 获取伙伴皮肤点券
function UserModel:getSkinCoin()
    return self:getFinanceByKey("skinCoin",0)
end
-- 获取法力数量
function UserModel:getMp()
    return self:getFinanceByKey("mp",0)
end

-- 获取委托币
function UserModel:getDeputeCoin( )
    return 0
end

-- 获取竞技场货币
function UserModel:getArenaCoin()
    return self:getFinanceByKey("arenaCoin",0)
end

-- 获取公会声望货币 （恭）
function UserModel:getGuildCoin()
    return self:getFinanceByKey("guildCoin",0)
end

-- 获取抽卡令牌(旧的抽卡)
function UserModel:getToken()
    return self:getFinanceByKey("token",0)
end
-- 获取（新）抽卡刷新令
function UserModel:getShopToken()
    return self:getFinanceByKey("lotteryShopToken",0)
end

--获取成就点
function UserModel:getAchievementPoint()
    return self:getFinanceByKey("achievementPoint", 0)
end

function UserModel:getCoinTotal()
    return self:getFinanceByKey("coinTotal", 0)
end

function UserModel:getGarment()
    return self:getFinanceByKey("garmentCoin", 0)
end

function UserModel:getCimeliaCoin()
    return self:getFinanceByKey("cimeliaCoin", 0)
end

function UserModel:getDimensity()
    return self:getFinanceByKey("dimensity", 0)
end
--仙符数量 --须臾灵元
function UserModel:getWonderLandCoin()
    return self:getFinanceByKey("wonderLandCoin", 0)
end

function UserModel:getRouletteCoin()
    return self:getFinanceByKey("rouletteCoin", 0)
end

--体力增加时检查体力是否溢出  addedNum需要增加的数目  tid如果溢出需要弹的tips
function UserModel:isSpOverflow(addedNum, tid)
    -- //购买后体力是否超过了上限
    local _maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax")
    if (UserExtModel:sp() + addedNum >= _maxSpNum) then
        local tips =  FuncTranslate._getLanguageWithSwap(tid, _maxSpNum)
        WindowControler:showTips(tips)
        WindowControler:showWindow("CompLevelUpTipsView")
        return true
    end
end

--花费货币的时候都走这里
--将来可能加入充值弹窗的弹出
function UserModel:tryCost(resType, needNum, isShowTip, costType)
    local RES_TYPES = UserModel.RES_TYPE -- ==FuncDataResource.RES_TYPE
    if isShowTip==nil then
        isShowTip = true
    end
    local hasNum = 0
    local tip = nil
    local tipWindow = nil
    if resType == RES_TYPES.COIN then --金币
        hasNum = self:getCoin()
        --tip = GameConfig.getLanguage("tid_common_1006")
        tipWindow = "CompBuyCoinMainView"
    elseif resType == RES_TYPES.ARENACOIN then --竞技场货币
        hasNum = self:getArenaCoin()
        tip = GameConfig.getLanguage("tid_common_1015")
    elseif resType == RES_TYPES.DIAMOND then --钻石
        --tip = GameConfig.getLanguage("tid_common_1001")
        hasNum = self:getGold()
        tipWindow = "CompGotoRechargeView"
    elseif resType == RES_TYPES.CHIVALROUS then -- 侠义值
        hasNum = UserModel:getRescueCoin()
        tip = GameConfig.getLanguage("tid_char_1010")
        if costType and costType == FuncCommon.CostType.REFRESH then
            tip = GameConfig.getLanguage("tid_tryCost_tips_0001")          
        end
    elseif resType == RES_TYPES.SP then --体力
        hasNum = UserExtModel:sp()
        tipWindow = "CompBuySpMainView"
    elseif resType == RES_TYPES.LINGSHI then
        hasNum = self:goldConsumeCoin() 
        tip = GameConfig.getLanguage("tid_tryCost_tips_0002")
    elseif resType == RES_TYPES.CIMELIACOIN then --神器精华
        hasNum = UserModel:getCimeliaCoin()
        tip = GameConfig.getLanguage("tid_tryCost_tips_0003")
        if costType and costType == FuncCommon.CostType.REFRESH then
            tip = GameConfig.getLanguage("tid_tryCost_tips_0004")
        end
    elseif resType == RES_TYPES.DIMENSITY then --锁妖塔魔石
        hasNum = UserModel:getDimensity()
        tip = GameConfig.getLanguage("tid_tryCost_tips_0005")
        if costType and costType == FuncCommon.CostType.REFRESH then
            tip = GameConfig.getLanguage("tid_tryCost_tips_0006")
        end
    elseif resType == RES_TYPES.GUILDCOIN then --仙盟贡献值
        hasNum = UserModel:getGuildCoin()
        tip = GameConfig.getLanguage("tid_tryCost_tips_0007")
    elseif resType == RES_TYPES.XIANFU then
        hasNum = UserModel:getWonderLandCoin()
        tip = GameConfig.getLanguage("tid_tryCost_tips_0008")
        if costType and costType == FuncCommon.CostType.REFRESH then
            tip = GameConfig.getLanguage("tid_tryCost_tips_0009")
        end
    elseif resType == RES_TYPES.DEPUTECOIN then
        hasNum = UserModel:getDeputeCoin()
        tip = GameConfig.getLanguage("tid_tryCost_tips_0010")
        if costType and costType == FuncCommon.CostType.REFRESH then
            tip = GameConfig.getLanguage("tid_tryCost_tips_0011")
        end
    elseif resType == RES_TYPES.LUCKYJIFEN then
        hasNum = UserModel:getRouletteCoin()
        tip = GameConfig.getLanguage("tid_tryCost_tips_0010")
        if costType and costType == FuncCommon.CostType.REFRESH then
            tip = GameConfig.getLanguage("tid_tryCost_tips_0011")
        end

	end

    echo("========hasNum==========",hasNum,needNum)
    local isEnough = hasNum >= needNum

    --不足并且需要tip提示不足时
    if not isEnough and isShowTip then
        if tip then
            WindowControler:showTips(tip)
        end
        if tipWindow then
            -- if tipWindow == "CompGotoRechargeView" then 
                -- WindowControler:showTips( GameConfig.getLanguage("tid_common_1001") )
            -- else 
                 WindowControler:showWindow(tipWindow)
            -- end 
        end
    end
    return isEnough
end

--获取资源根据id
function UserModel:getRes(resId )
    
end

--是否为测试用户
function UserModel:isTest()
    local userType = self:type()
    local arr = string.split(userType, ',')
    if table.find(arr, UserModel.USER_TYPE.TEST) then
        return true
    end
    return false
end

--获取主角形象
function UserModel:getCharSpine(action)

end

--用户的 uid
function UserModel:uid(  )
    if self._data then
        return self._data.uid or "no_login"
    end

    return "111"
end


--角色id
function UserModel:rid()
    if not self._data then
        return UserModel.DEFAUTL_RID;
    end
    -- echo(self._data._id,"__self._data._id")
    return self._data._id or UserModel.DEFAUTL_RID;
end

function UserModel:isDefaultRid(rid)
    return rid == UserModel.DEFAUTL_RID
end

-- 根据传入的时间 获取当前是第几天 比如传入开服时间获取开服天数，传入创角时间获取创角天数
function UserModel:getCurrentDaysByTimes(_openTime)
    local openDays = 1
    local openTime = _openTime
    local currentTime = TimeControler:getServerTime()
    local leftTime = 0
    local openDate = os.date("*t", openTime)
    local currentDate = os.date("*t", currentTime)
    -- 第二天4点是跨天
    local openDaySec = openDate.hour * 60 * 60 + openDate.min * 60 + openDate.sec
    if openDate.hour >= 4 then
        leftTime = currentTime - openTime - ((24 * 60 * 60 - openDaySec) + 4 * 60 * 60)
    else
        leftTime = currentTime - openTime - (4 * 60 * 60 - openDaySec)
    end

    if leftTime < 0 then
        openDays = 1
    else
        openDays = math.floor(leftTime / (24 * 60 * 60)) + 2
    end
    return openDays
end

-- 主角id
function UserModel:getCharId()
    return self._data.avatar or "101"
end

-- 获取行动力上限增量
function UserModel:getSpLimit()
    local vipLevel = self:vip()
    local spLimit = FuncCommon.getVipPropByKey(vipLevel,"spLimit")
    return spLimit
end

-- 获取特权对行动力最大值的加成
function UserModel:getPrivilegeAdditionMaxSpLimit()
    local privilegeData = UserModel:privileges() 
    local additionType = FuncCommon.additionType.addition_sp_limit 
    local curTime = TimeControler:getServerTime()
    -- local fromSys = FuncCommon.additionFromType.GUILD
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime)
    local additionNum = 0
    if isHas then
        additionNum = additionNum + value  -- 体力上限增加默认加具体数值而不是万分比
    end
    return additionNum  
end

-- 根据等级获取体力上限值
function UserModel:getMaxSpLimitByLevel(level)
    local homeCharSPBase = FuncDataSetting.getDataByConstantName("HomeCharSPBase")
    local vipSp = self:getSpLimit()
    local privilegeAddition = self:getPrivilegeAdditionMaxSpLimit()
    local maxSpLimit = homeCharSPBase + level + vipSp + privilegeAddition
    return maxSpLimit
end

-- 获取最大Sp限制值
-- 计算方法：行动力结果 = 基础常量 + 虚拟主角等级 + Vip增量
function UserModel:getMaxSpLimit()
    -- local homeCharSPBase = FuncDataSetting.getDataByConstantName("HomeCharSPBase")
    -- local level = self:level()
    -- local vipSp = self:getSpLimit()
    -- local maxSpLimit = homeCharSPBase + level + vipSp
    -- return maxSpLimit
    local level = self:level()
    return self:getMaxSpLimitByLevel(level)
end

-- 获取购买体力次数上限 特权加成
function UserModel:getPrivilegeAdditionSpMaxBuyTimes()
    local privilegeData = UserModel:privileges() 
    local additionType = FuncCommon.additionType.addition_sp_canBuyTimes 
    local curTime = TimeControler:getServerTime()
    -- local fromSys = FuncCommon.additionFromType.GUILD
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime)
    local additionNum = 0
    if isHas then
        additionNum = additionNum + value  -- 体力上限增加默认加具体数值而不是万分比
    end
    return additionNum  
end

-- 获得体力最大购买次数
function UserModel:getSpMaxBuyTimes()
    local vipLevel = self:vip()
    local maxBuyTimes = FuncCommon.getVipPropByKey(vipLevel,"buyEnLimit")
    local privilegeAddition = self:getPrivilegeAdditionSpMaxBuyTimes()
    maxBuyTimes = maxBuyTimes + privilegeAddition
    return maxBuyTimes
end

--一共可以搞多少次灵力事件
function UserModel:getTotalEventCount()
    local level = self:level();

    if level < FuncDataSetting.getDataByConstantName("HomeMPEventUnlockLevel1") then 
        return 0;
    elseif level < FuncDataSetting.getDataByConstantName("HomeMPEventUnlockLevel2") then
        return 1;
    elseif level < FuncDataSetting.getDataByConstantName("HomeMPEventUnlockLevel3") then
        return 2;
    elseif level < FuncDataSetting.getDataByConstantName("HomeMPEventUnlockLevel4") then
        return 3;
    else 
        return 4;
    end 
end

-- 获取用户法宝阵型
function UserModel:getTreasureFormula()
    local treasureFormula = self:treasureFormula()
    if treasureFormula == nil then
        treasureFormula = {}
    end

    return treasureFormula
end


--是否有新功能开启了
--如果有新功能开启返回一个列表2017.7.11
function UserModel:isNewSystemOpenByLevel(level)
    local level = tonumber(level);
    -- 读的是 SystemOpen 读这个
    if level == 1 then 
        return true;
    end 

    local systemData = FuncCommon.getSysOpenData();
    local flag,result = false, {}
    for systemName, value in pairs(systemData) do
        local condition = value.condition;
        if condition~= nil and condition[1].t == 1 and condition[1].v == tonumber(level) then 
            -- return true, systemName;
            flag = true
            table.insert(result, systemName)
        end 
    end

    return flag, result;
end

--在等级之间(p1,p2】，有没有开启的新功能
function UserModel:isNewSystemOpenInRange(p1, p2)
    --区间不对！
    if p1 >= p2 then 
        return {};
    end 
    local retSysArray = {};
    for level = tonumber(p1) + 1, tonumber(p2) do
        local isSystemOpen, sysNameKeys = UserModel:isNewSystemOpenByLevel(level);
        if isSystemOpen == true then
            for i,sysNameKey in ipairs(sysNameKeys) do
                table.insert(retSysArray, sysNameKey)
            end
        end 
    end

    return retSysArray;
end

--通关某个 raidId 有没有新功能产生 2017.7.11从HomeModel挪到这里
--同时开2个，先显示六界的 再显示升级的开启（以前的注释直接拿过来了，暂时没有看到做什么操作）
function UserModel:isNewSystemOpenByRaidId( raidId )
    local systemOpenConfig = FuncCommon.getSysOpenData();

    local flag,result = false, {}
    for sysName, value in pairs(systemOpenConfig) do
        local cond = value.condition;
        if cond ~= nil then 
            -- 4主线/5精英
            if (cond[1].t == 4 or cond[1].t == 5) 
                and cond[1].v == tonumber(raidId) 
            then 
                flag = true
                table.insert(result, sysName)
            end
        end  
    end

    return flag, result
end

--是否达到最大vip等级
function UserModel:isMaxVipLevel()
    local maxVipLevel = FuncCommon.getMaxVipLevel()
    local currentVip = self:vip()
    return tonumber(currentVip) >= tonumber(maxVipLevel)
end


--[[
--竞技场战斗需要提供的数据
{
    level = 1,      --等级
    state =1,       --境界
    states = {      --境界归属数据
        ["1"] = {   
            advId = 1,
            points= {
                101 = {
                    id = 101,
                    level =1,
                }
            }
        },

        ["2"] = {
            ...
        }
    }
    _id = dev_29,       --id
    treasure = {
                {hid="101",state = 1,star = 1,level = 2},
                {hid="102",state = 1,star = 1,level = 2},
                {hid="103",state = 2,star = 1,level = 2},
              }, 
}
]]
function UserModel:getChannelName()
    return AppInformation:getChannelName()
end

-- 获取主角穿戴法宝动画
function UserModel:getCharOnTreasure(treaHid, isWhole)
    local avatar = self:avatar()

    avatar = "101"

    local charView = FuncChar.getCharOnTreasure(avatar, treaHid, isWhole)
    return charView
end


--快速获取本地结算数据
function UserModel:getBenDataCoinAndPs(BuyType,items)
    local DataTable = {}
    local SpBuyCount = CountModel:getSpBuyCount()
    local CoinBuyTimes = CountModel:getCoinBuyTimes()
    if BuyType == 1 then
        local items = tonumber(items)
        DataTable.result = {}
        DataTable.result.data = {}
        if items == nil then
            return DataTable
        end
        DataTable.result.data.detailCoin = {}
        DataTable.result.data.hit = {}
        
        DataTable.result.data.dirtyList = {u={}}
        -- DataTable.result.data.dirtyList.u = {}
        DataTable.result.data.dirtyList.u.counts = {}
        local countsid = FuncCount.COUNT_TYPE.COUNT_TYPE_USER_BUY_COIN_TIMES
        DataTable.result.data.dirtyList.u.counts[countsid] = {}
        DataTable.result.data.dirtyList.u.counts[countsid].count = CoinBuyTimes + items
        -- DataTable.result.data.dirtyList.u.counts[countsid].count = 
        DataTable.result.data.dirtyList.u.counts[countsid].id = tostring(countsid)
        DataTable.result.data.dirtyList.u.finance = {}
        local sumcoin = UserModel:getCoin()
        local giftGold = UserModel:getGold()
        local goldConsumeCoin = 0
        for i=1,items do
            DataTable.result.data.hit[i] = 1
            local Price,coinnumber = FuncCommon.getCoinPriceByTimes(CoinBuyTimes + 1,UserExtModel:buyCoinTimes())
            DataTable.result.data.detailCoin[i] = coinnumber
            sumcoin = sumcoin +  coinnumber 
            giftGold = giftGold - Price
            -- goldConsumeCoin = goldConsumeCoin + Price
        end
        DataTable.result.data.dirtyList.u.finance.coin = sumcoin
        -- DataTable.result.data.dirtyList.u.goldConsumeCoin = goldConsumeCoin
        DataTable.result.data.dirtyList.u.giftGold = giftGold
        DataTable.result.data.dirtyList.u.everydayQuest = {}
        DataTable.result.data.dirtyList.u.everydayQuest.todayEverydayQuestCounts= {}
        DataTable.result.data.dirtyList.u.everydayQuest.todayEverydayQuestCounts["13"] = items
    elseif BuyType == 2 then
        -- if items == nil then
        --     items = 1
        -- end
        -- local items  = tonumber(items)
        local goldConsumeCoin = FuncCommon.getSpPriceByTimes(SpBuyCount + 1)
        local giftGold = UserModel:getGold() -  goldConsumeCoin --todo
        local  spFixedNum = FuncDataSetting.getDataByConstantName("HomeCharBuySP");
        local sumsp = UserExtModel:sp() + spFixedNum
        DataTable.result = {
            data = {
                dirtyList = {
                    u = {
                        counts = {
                            ["1"] = {
                               count = SpBuyCount + 1, 
                               id = "1",
                            },
                        },
                        everydayQuest = {
                            todayEverydayQuestCounts = {
                                ["12"] = 1,
                            },
                        },
                        giftGold = giftGold,
                        -- goldConsumeCoin = goldConsumeCoin,
                        userExt = {
                            sp = sumsp,
                            -- upSpTime = 0,
                        },
                    }
                }
            }
        }
    end
    return DataTable
end


--是否获得过某道具，即使之后把它使用了 itemId要添加找后端，现在他就写死了几个
function UserModel:isOwnItemEver(itemId)
    local isOwn = self:historyItems()[tostring(itemId)];
    if isOwn ~= nil then
        return true
    end
    return false;
end

--获得主角的总战力 --服务器数据
function UserModel:getcharSumAbility()
    local sumAbility = 0
    if self:abilityNew().formationTotal and self:abilityNew().formationTotal ~= 0 then
        sumAbility = self:abilityNew().formationTotal
    else
        local partnerAbilitys = 0
        -- for k,v in pairs(self:abilityNew().partners) do
        --     partnerAbilitys = partnerAbilitys + AbilityModel:getPartnerAbility(k)
        -- end
        sumAbility = AbilityModel:getCharAbility() + partnerAbilitys
    end
    return sumAbility
end

---保存重登是否在战斗中的数据
function UserModel:saveLoginData(_data)
    self.LoginData = _data
end




function UserModel:getGoldConsumeCoinInner( )
    -- local expireTime = self._data.goldConsumeExpireTime or 0
    -- local currentTime = TimeControler:getServerTime()

    -- if MonthCardModel:checkLingShiShopOpen() then
    --     return self._data.goldConsumeCoinInner or 0
    -- end

    -- expireTime = tonumber(expireTime)
    -- if expireTime > 0 and currentTime > expireTime then
    --     self._data.goldConsumeCoinInner = 0
    -- end

    -- echoError("剩余时间 === ",expireTime - currentTime)
    return self._data.goldConsumeCoinInner or 0

end

return UserModel

