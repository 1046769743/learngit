--伙伴系统
--2016-12-6 14:29:19
--@Author:狄建彬
local PartnerModel = class("PartnerModel",BaseModel)

function PartnerModel:init( d,_skillPoint)
    PartnerModel.super.init(self,d)
    -- dump(d,"------init 伙伴")
    self._partners=d--伙伴集合
    --伙伴技能点
    self._skillPoint =_skillPoint
    --伙伴红点开关
    self._redPoindKaiGuan = {}
    self:initRedPoindKaiGuan()
    --升品动画IDtable
    self.upQualityAnimT = {}
    --红点显示
    self:homeRedPointEvent()
    --主城奇侠按钮可提升特效
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.dispatchShowApproveAnimEvent, self);

    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.dispatchShowApproveAnimEvent, self);

    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.homeRedPointEvent, self);  

    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.homeRedPointEvent, self); 

    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_LOVE_LEVEL_UP_GRADE, 
        self.homeRedPointEvent, self)
    -- 伙伴共鸣升阶成功
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_PARTNER_RESONATE_ONE_STEP, 
        self.homeRedPointEvent, self)
    --更新红点
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_UPDATE_RED,
        self.homeRedPointEvent, self)
    --奇侠传记发生变化时 更新红点
    EventControler:addEventListener(BiographyUEvent.EVENT_REFRESH_UI,
        self.homeRedPointEvent, self)
    
    -- 新合成伙伴集合
    self._newCombinePartners = {} 
      
    -- 对道具的监听先关掉 避免重复调用 
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.partnerRedPoint, self);  
    --主角星级发生变化
    EventControler:addEventListener(UserEvent.USEREVENT_STAR_CHANGE,
        self.partnerRedPoint, self)
    --主角品质发生变化
    EventControler:addEventListener(UserEvent.USEREVENT_QUALITY_POSITION_CHANGE,
        self.partnerRedPoint, self)

    if not IS_TODO_MAIN_RUNCATION then
        -- 判断前后端 主角战力是否一致
        -- self:checkPartnerPower( )
    end

    --在model初始化的时候 计算下各模块是否处于 熟练期  如果是 将状态保存本地 这样之后就不用每次都去计算了
    if not LS:prv():get(StorageCode.partner_skilledForUpgrade) then
        self:isSkilledPlayerForUpgrade()
    end
    
    if not LS:prv():get(StorageCode.partner_skilledForUpQuality) then
        self:isSkilledPlayerForUpQuality()
    end
    
    if not LS:prv():get(StorageCode.partner_skilledForSkill) then
        self:isSkilledPlayerForSkill()
    end
    
    if not LS:prv():get(StorageCode.partner_skilledForStar) then
        self:isSkilledPlayerForStar()
    end

    if not LS:prv():get(StorageCode.partner_skilledForEquipmentEnhance) then
        self:isSkilledPlayerForEquipmentEnhance()
    end

    if not LS:prv():get(StorageCode.partner_skilledForEquipmentAdvance) then
        self:isSkilledPlayerForEquipmentAdvance()
    end
end

function PartnerModel:checkPartnerPower( )
    local ability = UserModel:getUserData().abilityNew 
    if not ability then
        -- echoError("此时是新建角色，服务器还没有战力")
        return
    end
    local abilityPartner = ability.partners 
    if abilityPartner then
        for i,v in pairs(abilityPartner) do
            local power = PartnerModel:getPartnerAbility(tostring(i))
            if  math.abs(power-v.total) > 1 then
                -- echoError("前后端战力不一致，请通知程序排查")
                echo("========主角rid== ",UserModel:getUserData()._id)
                local smark = LoginControler:getServerInfo()
                echo("=========区服== ".. smark._id.."_"..smark.sortId)
                if device.platform == "windows" then
                    dump(v,"---服务器战力-----",5)
                    PartnerModel:getPartnerAbility(tostring(i),true)
                    dump(smark,"---服务器战力-----",5)
                end
                echoError("前后端战力不一致，请通知程序排查")
                -- WindowControler:showTips( { text = "前后端战力不一致，请通知程序排查" });
            end
        end
    end
    
end

function PartnerModel:initRedPoindKaiGuan()
    local data =table.copy(self._partners)
    table.insert(data,CharModel:getCharData())
    for i,v in pairs(data) do
        local _isShow = FuncPartner.getPartnerRedPoint(tostring(v.id));
        self._redPoindKaiGuan[tostring(v.id)] = _isShow
    end
    -- dump(self._redPoindKaiGuan,"self._redPoindKaiGuan")
    self.changrRedPoind = {}
end
-- 获得总开关
function PartnerModel:getZongKG( )
    local kaiguanKey = "zongkaiguai";
    return FuncPartner.getPartnerRedPoint(kaiguanKey)
end
function PartnerModel:isAllKaiGuanClose()
    for i,v in pairs(self._redPoindKaiGuan) do
        if v == true then
            return false
        end
    end
    return true
end
function PartnerModel:getRedPoindKaiGuanById(_partnerId)
    return self._redPoindKaiGuan[tostring(_partnerId)]
end
function PartnerModel:setRedPoindKaiGuanById(_partnerId,_isShow)
    self._redPoindKaiGuan[tostring(_partnerId)] = _isShow
    self.changrRedPoind[tostring(_partnerId)] = _isShow

    EventControler:dispatchEvent(PartnerEvent.PARTNER_REDPOINT_KAIGUAN_UI_EVENT)
    
end
--将红点信息保存到本地
function PartnerModel:saveRedPoindLocal()
    local _index = 1;
    for i,v in pairs(self.changrRedPoind) do
        _index = _index + 1
        WindowControler:globalDelayCall(function()
	        FuncPartner.setPartnerRedPoint(i,v);
	    end,0.05 * _index)
        
    end
    self.changrRedPoind = {}
end
-- 伙伴内红点变化监听
function PartnerModel:partnerRedPoint()
    WindowControler:globalDelayCall(c_func(function()
        EventControler:dispatchEvent(PartnerEvent.PARTNER_COST_ITEM_ENHANCE_EVENT)
        EventControler:dispatchEvent(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT)
        EventControler:dispatchEvent(PartnerEvent.PARTNER_LEVEL_RED_EVENT)
    end),0.1)
end
-- 判断主角红点是否显示
function PartnerModel:charShowRedPoint(_partnerId)
    if not PartnerModel:getRedPoindKaiGuanById(_partnerId) then
        return false
    end
    return true
end

--伙伴数目发生变化 红点的显示
function PartnerModel:homeRedPointEvent()
    WindowControler:globalDelayCall(c_func(function()
        EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                { redPointType = HomeModel.REDPOINT.DOWNBTN.PARTNER, isShow = self:redPointShow() })
    end),0.1)
end
--伙伴装备材料变化 红点显示
function PartnerModel:equipmentRedPointEvent()
    EventControler:dispatchEvent(PartnerEvent.PARTNER_EQUIPMENT_ENHANCE_EVENT)
    EventControler:dispatchEvent(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT)
end

--某个伙伴的所有绝技等级
function PartnerModel:getUniqueSkillTotalLevelByPartnerId(partnerId)
    if self:isHavedPatnner(partnerId) == false then
        return false;
    end 
    local partner = self:getPartnerDataById(partnerId);

    local totalLvl = 0;
    local uniqueSkills = partner.souls;

    for _, v in pairs(uniqueSkills) do
        if v.level ~= nil then 
            totalLvl = totalLvl + v.level;
        end 
    end

    return totalLvl;
end

--注意,尽可能的少发送事件
function PartnerModel:updateData( d )
    --注意,伙伴的数目只会变大而不会变小
    -- dump(d,"============= huo ban shua xin ============")
    local    _numChanged = false--table.length(self._partners) == table.length(d)
    --注意,一些细节可能会发生变化
    --这里需要使用 setmetable函数,因为后面会拿着个数据去创建组件

    -- PartnerModel.super.updateData(self, d)

    local _changedPartner = {}

    for _key,_value in pairs(d) do
        _key = tostring(_key)
        if self._partners[_key] ~=nil then
               -- setmetatable(_value,getmetatable(self._partners[_key])); 
            -- 伙伴战力old
            echo("________key, ",_key)
            local _oldPower = PartnerModel:getPartnerAbility(tostring(_key))
            local _oldLevel = self._partners[_key].level
            --count发生变化
            if _value.count ~= nil then
                self._partners[_key].count = _value.count
            end
            --技能是否发生了变化
            if _value.skills ~=nil then   
                local _skill 
                for _otherKey,_otherValue in pairs(_value.skills)do
                    self._partners[_key].skills[_otherKey] = _otherValue
                    _skill ={ id = _otherKey,level = _otherValue }
                end
                EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.PARTNER_SKILL});
                EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_CHANGED_EVENT,{id = tonumber(_key),skills = _skill})
            end
            --仙魂是否发生了变化
            if _value.souls ~=nil then
                local _soul
                for _otherKey,_otherValue in pairs(_value.souls)do--仙魂每次只可能会变化一个
                    if _otherValue.level ~=nil then--级别发生变化,此时经验也必定会发生变化
                        self._partners[_key].souls[_otherKey] = {id = tonumber(_otherKey),level =_otherValue.level ,exp = _otherValue.exp}
                    elseif _otherValue.exp ~=nil then--如果只有经验发生变化
                        self._partners[_key].souls[_otherKey].exp = _otherValue.exp
                    end
                    _soul = self._partners[_key].souls[_otherKey]
                end
                EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.PARTNER_SPECIAL});
                EventControler:dispatchEvent(PartnerEvent.PARTNER_SOUL_CHANGE_EVENT,{id=tonumber(_key),souls=_soul})
            end
            --星级发生了变化 
            if _value.star ~=nil and _value.star ~= self._partners[_key].star then
                -- echo("===============此时 升星了 -==================")
                self._partners[_key].star = _value.star
                EventControler:dispatchEvent(PartnerEvent.PARTNER_STAR_LEVELUP_EVENT,{id = tonumber(_key),star = _value.star})
                
                EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.PARTNER_STAR})
            end
            --星级节点发生了变化
            if _value.starPoint ~=nil and _value.starPoint ~= self._partners[_key].starPoint then
                self._partners[_key].starPoint = _value.starPoint
                EventControler:dispatchEvent(PartnerEvent.PARTNER_STAR_POINT_CHANGE_EVENT,{id = tonumber(_key), starPoint=_value.starPoint})
                -- echoError("===============此时星级节点==",_value.starPoint)
            end
            
            --经验发生变化
            if _value.exp ~=nil then
                self._partners[_key].exp =_value.exp 
                EventControler:dispatchEvent(PartnerEvent.PARTNER_EXP_CHANGE_EVENT,{id=tonumber(_key),exp = _value.exp})
            end
            --等级发生变化
            if _value.level ~=nil and _value.level ~= self._partners[_key].level then
                self._partners[_key].level = _value.level
                WindowControler:globalDelayCall(c_func(function()
                    EventControler:dispatchEvent(PartnerEvent.PARTNER_LEVELUP_EVENT,{id =tonumber(_key), level = _value.level, 
                                                                                            exp = _value.exp, oldLevel = _oldLevel})
                    end),0.05)
                -- EventControler:dispatchEvent(PartnerEvent.PARTNER_ATTR_CHANGE_EVENT)
                EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.PARTNER_LVL})
            end
            --品质发生变化
            if _value.quality ~=nil and _value.quality ~= self._partners[_key].quality then
                self._partners[_key].quality = _value.quality
                EventControler:dispatchEvent(PartnerEvent.PARTNER_QUALITY_CHANGE_EVENT,{id=tonumber(_key),quality =_value.quality})
            end
            --升品装备变化
            if _value.position ~=nil then
                local position = {}
                local oldPosition = self._partners[_key].position
                self._partners[_key].position = _value.position
                if _value.position > 0 then
                    -- 此处目的是 屏蔽升品
                    -- EventControler:dispatchEvent(PartnerEvent.PARTNER_ATTR_CHANGE_EVENT)
                    local tempValue = _value.position - oldPosition
                    local toBit = number.splitByNum(tempValue, 2)
                    for i = 4, 5 - #toBit, -1 do
                        position[tostring(i)] = toBit[#toBit - (4 - i)]
                    end
                end
                EventControler:dispatchEvent(PartnerEvent.PARTNER_QUALITY_POSITION_CHANGE_EVENT,{id=tonumber(_key),position = position})
            end
            --伙伴皮肤变化
            if _value.skin ~=nil then
                echo("---- 此时 伙伴皮肤发生变化")
                self._partners[_key].skin = _value.skin
                EventControler:dispatchEvent(PartnerEvent.PARTNER_SKIN_CHANGE_SUCCESS_EVENT,{id=tonumber(_key),skin =_value.skin})
            end
            --装备升级变化
            if _value.equips ~= nil then
                for i,v in pairs(_value.equips) do
                    if v.level then
                        self._partners[_key].equips[i].level = v.level
                    elseif v.awake then
                        self._partners[_key].equips[i].awake = v.awake
                    end
                end
                EventControler:dispatchEvent(PartnerEvent.PARTNER_QUALITY_LEVEL_CHANGE_EVENT)
                EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.PARTNER_EQUIP})
            end
            -- 情缘 情缘等级发生变化
            if _value.loves ~= nil then
                for i,v in pairs(_value.loves) do
                    if not self._partners[_key].loves then   
                        self._partners[_key].loves = {}
                    end
                    if not self._partners[_key].loves[i] then
                        self._partners[_key].loves[i] = {}
                    end
                    if v.id then
                        self._partners[_key].loves[i].id = v.id
                    end
                    if v.lv then
                        self._partners[_key].loves[i].lv = v.lv
                    end
                    if v.value then
                        self._partners[_key].loves[i].value = v.value
                    end
                end
            end
            -- 情缘 伙伴共鸣等级发生变
            if _value.resonanceLv ~= nil then
                self._partners[_key].resonanceLv = _value.resonanceLv
            end

            --最后将变化的信息写入到集合中
            local _somePartner=table.copy(self._partners[_key])
            _changedPartner[_key] = _somePartner

            local _curPower = PartnerModel:getPartnerAbility(_key)
            -- dump(_value, "_value _____________ ", 4)
            -- 升星 升品 装备 战力单独处理
            if _curPower > _oldPower and _value.star == nil 
                and _value.starPoint == nil 
                and _value.quality == nil 
                and _value.equips == nil
                and _value.position == nil
                and _value.skills == nil 
                and _value.loves == nil 
                and _value.resonanceLv == nil then
                    FuncCommUI.showPowerChangeArmature(_oldPower or 10, _curPower or 10 );
            end
            --情缘与伙伴的联系过于紧密，需要判断条件过多，在这里发消息
             EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_UPDATE_RED)
        else
                _numChanged = true
                self._partners[_key] = _value
                _changedPartner[_key] = _value

                -- PartnerModel:showPartnerSkin( tostring(_value.id) )
                
                local kaiguanKey = "zongkaiguai";
                local zong_bool = FuncPartner.getPartnerRedPoint(kaiguanKey)
               -- local _isShow = FuncPartner.getPartnerRedPoint(tostring(_value.id));
                self._redPoindKaiGuan[tostring(_value.id)] = zong_bool

                table.insert(self._newCombinePartners, _key)
                -- 新合成的伙伴设置红点开关
                PartnerModel:setRedPoindKaiGuanById(_key,PartnerModel:getZongKG())

                EventControler:dispatchEvent(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT,_key)
                EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_UPDATE_RED)
                local hasIdlePosition = TeamFormationModel:hasIdlePosition()
                EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,{redPointType = HomeModel.REDPOINT.DOWNBTN.ARRAY, isShow = hasIdlePosition})
                
        end
        
        -- if TeamFormationModel:isPartnerInFormation(_key, FuncTeamFormation.formation.pve) then
        --     self:dispatchShowApproveAnimEvent()
        -- end
    end
    -- 伙伴的数目发生了变化,此时也默认伙伴的信息发生了变化 
    -- 有新伙伴合成
    if( _numChanged )then
         EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.COLLECT_PARTNER})
    -- 否则,伙伴的信息一定发生了变化
    else
        EventControler:dispatchEvent(PartnerEvent.PARTNER_INFO_CHANGE_EVENT,_changedPartner)
    end

    self:partnerRedPoint()
    self:homeRedPointEvent()
end

function PartnerModel:showPartnerSkin( partnerId )
    local data = FuncPartnerSkinShow.getDataByParIdAndType( partnerId,"1" )
    if data then
        local param = {
            id = partnerId,
            skin = "1",
        }

        WindowControler:showWindow("PartnerSkinFirstShowView",param)
    end
end

-- 删除新合成的伙伴
function PartnerModel:removeNewCombinePartner( id )
    table.remove(self._newCombinePartners,id)
end
--  获得新合成的伙伴
function PartnerModel:getNewCombinePartner()
    return self._newCombinePartners or {}
end
-- 判断是否开启
function PartnerModel:isOpenByType(_select,_partnerId)
    if _select == 1 then -- 品质
        return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_QUALITY)
    elseif _select == 2 then -- 升星
        if _partnerId and FuncPartner.isChar(_partnerId) then
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHARSTAR)
        else
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SHENGXING)
        end
        
    elseif _select == 3 then -- 技能
        if _partnerId and FuncPartner.isChar(_partnerId) then
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_NEW)
        else
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL)
        end
    elseif _select == 4 then -- 绝技
    elseif _select == 5 then -- 装备
        return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_ZHUANGBEI)
    end
end

--取已拥有最强伙伴
function PartnerModel:getFirstPartner( )
    local partners = {}
    for i,v in pairs(self._partners) do
        table.insert(partners, v)
    end
    if table.length(partners) > 0 then
        
        table.sort(partners,c_func(self.partner_table_sort,self))
        return partners[1]
    else
        echoError("此时没有已拥有奇侠")
    end
end

--对已拥有 的奇侠进行排序
function PartnerModel:partner_table_sort( a,b )
    -- 不知道为什么会传入两个相同的
    if a.id == b.id then
        return false
    end
    
    --战力
    local powreA = PartnerModel:getPartnerAbility(a.id)
    local powreB = PartnerModel:getPartnerAbility(b.id)
    if powreA > powreB then
        return true
    elseif powreA < powreB then
        return false
    end
    --星级
    if a.star > b.star then
        return true
    elseif a.star < b.star then
        return false
    end
    --品质
    if a.quality > b.quality then
        return true
    elseif a.quality < b.quality  then
        return false
    end
    --等级
    if a.level > b.level then
        return true
    elseif a.level < b.level then
        return false
    end
    return tonumber(a.id) < tonumber(b.id)
end


--获取所有伙伴的集合
function PartnerModel:getAllPartner()
    return  self._partners
end

-- 判断是否拥有该奇侠
function PartnerModel:checkOwnPartnerById(_partnerId)
    local partners = self:getAllPartner()
    for k,v in pairs(partners) do
        if tostring(_partnerId) == tostring(k) then
            return true
        end
    end
    return false
end

--获取单个伙伴数据by id
function PartnerModel:getPartnerDataById(_partnerId)
    local data = nil
    if tonumber(_partnerId) > 5000 then
        if not self:isHavedPatnner(_partnerId) then
            return nil
        end
        if self._partners then
            data = self._partners[tostring(_partnerId)]
        end
    else
        if tostring(_partnerId) == "101" or tostring(_partnerId) == "104"  then
            data = CharModel:getCharData()
            data.treasures = TreasureNewModel:data()
        end        
    end
    if not data then
        echoWarn("获取不到此伙伴id ",_partnerId,UserModel:avatar())
    end

    return data
end
-- 获得奇侠名字
function PartnerModel:getQiXiaName(partnerData)
    local quaData = FuncPartner.getPartnerQuality(partnerData.id)
    quaData = quaData[tostring(partnerData.quality or 1)]
    local nameColor = quaData.nameColor
    nameColor = string.split(nameColor,",") 
    if tonumber(nameColor[2]) > 1 then
        local colorNum = tonumber(nameColor[2]) - 1
        return FuncPartner.getPartnerName(partnerData.id).."+"..colorNum
    else
        return FuncPartner.getPartnerName(partnerData.id)
    end
end

--获取伙伴数量
function PartnerModel:getPartnerNum()
    local num = 0;
    for i,v in pairs(self._partners) do
        num = num + 1
    end
    return num
end
--获取技能点
function PartnerModel:getSkillPoint()
    return self._skillPoint
end
-- 判断伙伴是否可以合成
function PartnerModel:isCanCombienPartner(id)
    local _data = FuncPartner.getPartnerById(id)
    local haveNum = ItemsModel:getItemNumById(id)
    local needNum = _data.tity
    if haveNum >= needNum then
        return true 
    end
    return false
end
--通过技能ID和伙伴ID判断 技能是否解锁
function PartnerModel:isUnlockSkillById(partnerId,skillId)
    local data = self:getPartnerDataById(tostring(partnerId))
    if data then
        for i,v in pairs(data.skills) do
            if i == tostring(skillId) then
                return true, v
            end
        end
    end
    return false, 0
end
--获得有几个所有技能都大于level的伙伴个数
function PartnerModel:partnerSkillLevelGreaterThenParamLevel(level)
    local allData = self:getAllPartner();
    local num = 0
    for i,v in pairs(allData) do 
        local isEnough = true
        for key,value in pairs(v.skills) do
            if tonumber(value) <= tonumber(level) then
                isEnough = false
                break
            end
        end
        if isEnough then
            num = num + 1
        end
    end
--    echo("--------num = "..num)
    return num
end

-- 默认选中的
function PartnerModel:getInitPartner(_currentSelect,partnerId)
    -- 判断此ID是不是伙伴
    if _currentSelect and partnerId then
        local data = FuncPartner.getAllPartner()
        for i,v in pairs(data) do
            if v.id == partnerId then
                return partnerId
            end
        end
    
        if _currentSelect ~= 6 then
            return UserModel:avatar()
        else
            -- echoError("此时有问题 传过来的数据 必须是伙伴ID")
            return partnerId
        end
    elseif _currentSelect and not partnerId then
        if _currentSelect ~= 6 then
            return UserModel:avatar()
        else
            -- echoError("此时有问题 传过来的数据 必须是伙伴ID")
            return partnerId
        end
    end
    return nil
end

function PartnerModel:getTopInitIndex()
    if self:haveCanCombinePartner() then
        return 6
    end
    return self:getTopIndex()
end
--获取默认的左侧列表index
function PartnerModel:getTopIndex()
    local function isOpenByType(_select)
        if _select == 1 then -- 品质
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_QUALITY)
        elseif _select == 2 then -- 升星
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SHENGXING)
        elseif _select == 3 then -- 技能
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL)
        elseif _select == 4 then -- 绝技
        elseif _select == 5 then -- 装备
            return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_ZHUANGBEI)
        end
    end
    
    for _select = 1,5 do
        local open, value, valueType = isOpenByType(_select) 
        if open then
            return _select
        end
    end
    echoError("伙伴没有一个功能是解锁的")
    return 1
    
end

--获得有几个所有装备都大于level的伙伴个数
function PartnerModel:partnerEquipLevelGreaterThenParamLevel(level)
    local allData = self:getAllPartner();
    local num = 0
    for i,v in pairs(allData) do 
        local isEnough = true
        for key,value in pairs(v.equips) do
            if tonumber(value.level) <= tonumber(level) then
                isEnough = false
                break
            end
        end
        if isEnough then
            num = num + 1
        end
    end
--    echo("--------num = "..num)
    return num
end

-- 获取 伙伴战力
function PartnerModel:getPartnerAbility(partnerId,isLog,starPoint,formation)
    --如果不传指定的point ,那么默认走服务器的伙伴战力 是为了节省计算开销
    if (not starPoint) and (not formation) then
        return AbilityModel:getPartnerAbility( partnerId )
    end

    if (not formation)   then
        formation = TeamFormationModel:getFormation( FuncTeamFormation.formation.pve)   
    end
    local partnerData1 = PartnerModel:getPartnerDataById(partnerId)
    if not partnerData1 then
        echo("此时还没有此伙伴 ID -==-== ",partnerId)
        return 0
    end
    partnerData = table.copy(partnerData1)
    if starPoint then
        partnerData.starPoint = starPoint
    end
    local ability = FuncPartner.getPartnerAbility(partnerData,UserModel:data(), formation)
    return ability
end


-- 升品道具装备ID
function PartnerModel:setShengPinId(_id,_partnerId)
    self.upQualityAnimT[_id] = {id = _id,partnerId = _partnerId}
end
function PartnerModel:getShengPinId(_id)
    return self.upQualityAnimT[_id]
end
function PartnerModel:cleanShengPinId(_id)
    self.upQualityAnimT[_id] = {id = nil,partnerId = nil}
end
--升品道具合成UI集
function PartnerModel:clearCombine()
    self.combineItems = nil
    self.combinePartnerId = nil
end
function PartnerModel:addCombineItemId(_id,parnterId)
    if self.combineItems == nil then
        self.combineItems = {}
        self.combinePartnerId = parnterId
    end
    if self.combinePartnerId ~= parnterId then
        self.combineItems = {}
        self.combinePartnerId = parnterId
    end
    if PartnerModel:getCombineLastItemId() == _id then
        return 
    end
    table.insert(self.combineItems,_id)
end
function PartnerModel:deleteCombineToItemId(_id)
    if self.combineItems == nil then
        self.combineItems = {}
    end
    for i = #self.combineItems,1,-1 do
        if self.combineItems[i] == _id then
            return
        end
        table.remove(self.combineItems,i)
    end
end

function PartnerModel:deleteCombineItemId(_id)
    if self.combineItems == nil then
        self.combineItems = {}
    end
    for i,v in pairs(self.combineItems) do
        if v == _id then
            table.remove(self.combineItems,i)
        end
    end
end
function PartnerModel:getCombineItemId()
    if self.combineItems == nil then
        self.combineItems = {}
    end
    return self.combineItems 
end
function PartnerModel:getCombineLastItemId()
    if self.combineItems == nil then
        self.combineItems = {}
    end
    return self.combineItems[#self.combineItems] 
end
function PartnerModel:getCombineFirstItemId()
    if self.combineItems == nil then
        self.combineItems = {}
    end
    return self.combineItems[1] 
end
function PartnerModel:getCombineSecondItemId()
    if self.combineItems == nil then
        self.combineItems = {}
    end
    return self.combineItems[2] 
end

-- 记录开始合成道具时拥有的铜钱数
function PartnerModel:setCombienCoinNum(coinNum)
    if coinNum then
        self.combineCoinNum = self.combineCoinNum + coinNum
    else
        self.combineCoinNum = nil
    end
    
end
function PartnerModel:getCombineCoinNum(  )
    if not self.combineCoinNum then
        self.combineCoinNum = 0
    end

    return self.combineCoinNum
end


--判断升品道具合成条件是否满足
-- 返回值 1道具或碎片不满足 2金币不满足 3满足
function PartnerModel:isCombineQualityItem(_item,isOneStep,noResetCoin)
    if FuncItem.getItemSubType(_item) == FuncItem.itemSubTypes_New.ITEM_SUBTYPE_203 then -- 碎片
        return 1
    end

    
    local itemCombineCostVec = FuncItem.getItemPropByKey(_item,"cost")
--    -- 判断是否时无消耗的道具
    if itemCombineCostVec == nil then -- 如果为空 
       return 1
    end
 
    for i,v in pairs(itemCombineCostVec) do
        local costStr = string.split(v,",")
        self.targetItemId = costStr[2]
        self.targetItemNum = tonumber(costStr[3])
        if tonumber(costStr[1]) == 1 then
            self.curTargetItem = _item
            if ItemsModel:getItemNumById(costStr[2]) < tonumber(costStr[3]) then
                if isOneStep then
                    return 1, self.targetItemId, self.targetItemNum
                else
                    if PartnerModel:isCombineQualityItem(costStr[2],nil,true) == 1 then
                        self:setCombienCoinNum( nil )
                        return 1, self.targetItemId, self.targetItemNum
                    elseif PartnerModel:isCombineQualityItem(costStr[2],nil,true) == 2 then
                        return 2
                    end
                end
            end
        elseif tonumber(costStr[1]) == 3 then
            local costCoinNum = tonumber(costStr[2])
            local haveCoinNum = UserModel:getCoin() - self:getCombineCoinNum(  )
            -- echo("当前 剩余铜钱数 ==== ",haveCoinNum)
            -- echo("当前 xiaohao铜钱数 ==== ",costCoinNum)
            if costCoinNum > haveCoinNum then
                return 2
            else
                self:setCombienCoinNum( costCoinNum )
            end
        end
    end
    if not noResetCoin then
        self:setCombienCoinNum( nil )
    end
    return 3
end
function PartnerModel:isCombineQualityOneItem(itemId,itemId2)
    local itemCombineCostVec = FuncItem.getItemPropByKey(itemId,"cost")
    if not itemCombineCostVec then
        return false
    end
    
    for i,v in pairs(itemCombineCostVec) do
        local costStr = string.split(v,",")
        if tonumber(costStr[1]) == 1 then
            -- if tostring(costStr[2]) == tostring(itemId) then
                if ItemsModel:getItemNumById(costStr[2]) < tonumber(costStr[3]) then
                    return false
                else
                    return true
                end
            -- end
        end
    end
    return false
end
-- 升品道具状态
-- 返回值为 1 2 3 4 5 6
-- 1 已装备 2 可装备 3 可合成 4 置灰 5 不做处理显示用 6 已拥有但不能装备
function PartnerModel:getItemFrame(itemId,itemId2,partnerId)
    -- 首先判断是否是碎片
    local itemData = FuncItem.getItemData(itemId)
    if itemData.subType == 299 then
        local enough = self:isCombineQualityItem(itemId2)
        if enough ~= 3 then
            return 4
        end
    end

--    -- 判断是否是整道具 无消耗
--    if itemData.subType == 314 then
--        local enough = self:isCombineQualityItem(itemId)
--        if enough ~= 3 then
--            return 4
--        end
--    end
    -- 首先判断是否满足消耗
    if itemData.subType == 310 then
        local _isCan = self:isCombineQualityOneItem(itemId,itemId2)
        if _isCan then
            return 6
        else
            local enough = self:isCombineQualityItem(itemId2)
            if enough == 3 then
                return 3
            end
        end
    end
    
    -- 判断是否可合成
    -- local enough = self:isCombineQualityOneItem(itemId,itemId2)
    -- if enough then
    --     return 6
    -- end
    
    return 4

end
--判断升品装备是否已装备
function PartnerModel:upQualityEquiped(itemId,itemId2,partnerId)
    local isAdd = false
    local positions = {}
    local value = PartnerModel:getPartnerDataById(tostring(partnerId)).position ----- 此处应为伙伴对应的position
    while value ~= 0 do
		local num = value % 2;
		table.insert(positions, 1, num);
		value = math.floor(value / 2);
	end
    for i = 1 ,4 do
        if positions[i] == nil then
            table.insert(positions, 1, 0);
        end
    end
    local upQualityDataVec = FuncPartner.getPartnerQuality(partnerId)
    local partnerData = self:getPartnerDataById(tostring(partnerId))
    local upQualityCostVec = upQualityDataVec[tostring(partnerData.quality)].pellet;

    for i,v in pairs(positions) do
        if v == 1 and upQualityCostVec[i] == itemId then
            isAdd = true
            break
        end
    end
    return isAdd
end
-- 获取升品装备位置 传 0 1 2 3
function PartnerModel:getUpqualityPosition(_item,_partnerId)
    local upQualityDataVec = FuncPartner.getPartnerQuality(_partnerId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    for m,n in pairs(upQualityDataVec[tostring(partnerData.quality)].pellet) do
        if n == _item then
            local pos = m - 1   
            return pos
        end
    end
    return -1
end

--奇侠类型（攻防辅）
function PartnerModel:partnerTypeShow(panel,partnerData )
    local id = partnerData.id
    if not id then
        id = partnerData.hid
    end
    if FuncPartner.isChar(id) then
        local treasureId = TeamFormationModel:getOnTreasureId()
        local treasCfg = FuncTreasureNew.getTreasureDataById(treasureId)
        panel:showFrame(treasCfg.type)
    else
        panel:showFrame(partnerData.type)
    end
end

-- 返回伙伴最大品级 
function PartnerModel:getPartnerMaxQuality(partnerId)
    return FuncPartner.getPartnerMaxQuality( partnerId )
end
--返回品质的颜色
function PartnerModel:getQualityColor(partnerId,quality)
    local partnerData = FuncPartner.getPartnerQuality(partnerId);
    local data = partnerData[tostring(quality)]
    echo("++++++++++++++++ color = " .. data.color)
    return data.color
end

--获取加成描述文字 例如：6,10 攻击力+10
function PartnerModel:getDesStahe(des)
    local buteData = FuncChar.getAttributeData()
    local buteName = GameConfig.getLanguage(buteData[tostring(des.key)].name)
    local str = buteName.."+"..des.value
    return str
end
--获取加成描述文字 例如：6,10 攻击力+10
function PartnerModel:getDesStaheTable(des)
    if des == nil then
        return ""
    end
    local buteData = FuncChar.getAttributeData()
    local buteName = GameConfig.getLanguage(buteData[tostring(des.key)].name)
    local str = buteName..": +"..des.value
    return str
end
-- 升星消耗是否满足 返回false的时候 会返回不足的类型 1 碎片 2铜钱
function PartnerModel:isCanUpStar(_partnerId)
    -- 升星消耗
    local vec = FuncPartner.getStarsByPartnerId(_partnerId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    if not partnerData then
        echoError("数据库里没找到伙伴数据 _partnerId == ",_partnerId)
        return false,1
    end
    local costVec = vec[tostring(partnerData.star)].cost
    if costVec then
        local cost = 0
        if partnerData.starPoint < 5 then
            cost = costVec[partnerData.starPoint + 1];
        end
    
        local haveNum = 0
        if FuncPartner.isChar(_partnerId) then
            haveNum = ItemsModel:getItemNumById("5000")
        else
            haveNum = ItemsModel:getItemNumById(_partnerId)
        end

        if partnerData.starPoint == 5 then
            if vec[tostring(partnerData.star)].coin > UserModel:getCoin() then
                return false ,2
            else
                return true ,0
            end
        else
            if haveNum >= cost then
                return true ,0
            else
                return false ,1
            end
        end
    else
        return true,0 -- 已满级
    end 
    
end
----------- 显示红点逻辑 ---------------
--主城红点显示
function PartnerModel:redPointShow()
    local allData = {}
    for i,v in pairs(self._partners) do
        table.insert(allData, v)
    end
    table.insert(allData, CharModel:getCharData()) -- 插入主角信息
    for i,v in pairs(allData) do
        --升品
        if self:isShowQualityRedPoint(v.id) then
            return true
        end
        --升级
        if self:isShowUpgradeRedPoint(v.id) then
            return true
        end
        --升星
        if self:isShowStarRedPoint(v.id) then
            return true
        end
        --技能
        if self:redPointSkillShow(v.id) then
            return true
        end
        --绝技
        -- 装备
        if self:isShowEquipRedPoint(v.id) then
            echo("-------------绝技红点显示----------------------------") 
            return true
        end
        -- 装备觉醒
        if PartnerModel:isEquipAwakeRedPoint(v.id) then
            return true
        end
        --情缘
        -- if PartnerModel:isLoveRedPoint(v.id) then 
        --     return true
        -- end
        --奇侠传记  有箱子可以领取
        if BiographyModel:hasBoxCanGet(v.id) then
            return true
        end
    end

    -- 是否有可合成伙伴
    if PartnerModel:haveCanCombinePartner() then
        return true
    end

    return false
end

function PartnerModel:dispatchShowApproveAnimEvent()
    local showAnim  = self:showApproveAnim()
    echo("\n\nshowAnim====", showAnim)
    EventControler:dispatchEvent(HomeEvent.SHOW_BUTTON_EFFECT,
            {
                systemName = FuncCommon.SYSTEM_NAME.PARTNER , --系统名称
                effectType = FuncCommUI.BUTTON_EFFECT_NAME.HOISTING, --显示那个特效文字
                isShow = showAnim --是不是显示
            })
end

function PartnerModel:setFormationPartners()
    self.formationPartners = {}
    local formation = TeamFormationModel:getFormation(FuncTeamFormation.formation.pve)
    if formation and formation.partnerFormation then
        for k,v in pairs(formation.partnerFormation) do
            if v.partner and v.partner.partnerId and tonumber(v.partner.partnerId) ~= 0 then
                if tonumber(v.partner.partnerId) == 1 then
                    table.insert(self.formationPartners, CharModel:getCharData())
                else
                    table.insert(self.formationPartners, self._partners[tostring(v.partner.partnerId)])
                end
            end
        end
    end
end

function PartnerModel:getFormationPartners()
    return self.formationPartners
end

function PartnerModel:showApproveAnim()
    local formationPartners = self:getFormationPartners()

    for i,v in ipairs(formationPartners) do
        --升品
        if self:isShowQualityRedPoint(v.id) then
            return true
        end
        --升级
        if self:isShowUpgradeRedPoint(v.id) then
            return true
        end
        --升星
        if self:isShowStarRedPoint(v.id) then
            return true
        end
        --技能
        if self:redPointSkillShow(v.id) then
            return true
        end
        -- 装备
        if self:isShowEquipRedPoint(v.id) then
            return true
        end
        -- 装备觉醒
        if PartnerModel:isEquipAwakeRedPoint(v.id) then
            return true
        end
    end

    return false
end

-- 判断是否有可合成伙伴
function PartnerModel:haveCanCombinePartner()
    --有关伙伴的表格数据
    local _partnerTable = FuncPartner.getAllPartner()
    --所有现在存在的伙伴数据
    local _nowPartners = PartnerModel:getAllPartner()
    --
    local _combinePartner = {} --待合成的伙伴的集合
    for _key,_value in pairs(_partnerTable) do
        if not _nowPartners[_key] then--如果该伙伴还没有被合成
            -- 是否要合成 
            local _data = FuncPartner.getPartnerById(_key)
            local _isShow = _data.isShow
            if _isShow == 1 then
                local haveNum = ItemsModel:getItemNumById(_data.id)
                local needNum = _data.tity
                if haveNum >= needNum then
                    return true 
                end
            end
        end
    end
    return false
end
--主城装备红的显示
function PartnerModel:redPointEqiupShow()
    
    for i,v in pairs(self._partners) do
        if self:isShowEquipRedPoint(v.id) then
            return true
        end
    end
    return false
end
--技能红点
function PartnerModel:redPointSkillShow( partnerId )
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL) == false then
        return false
    end
    if PartnerModel:getRedPoindKaiGuanById(partnerId) == false then
        return false
    end
    if FuncPartner.isChar(partnerId) then
        return TreasureNewModel:homeRedPointEvent()
    else
        return PartnerModel:isShowSkillRedPoint(partnerId, true)
    end
end
-- 升品红点显示 
function PartnerModel:isShowQualityRedPoint(_partnerId)
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_QUALITY) == false then

        return false
    end
    if PartnerModel:getRedPoindKaiGuanById(_partnerId) == false then
        return false
    end

    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    if not partnerData then
        echoError("------------",_partnerId)
    end
    local upQualityDataVec = FuncPartner.getPartnerQuality(tostring(_partnerId))[tostring(partnerData.quality)]
    local isShow = true

    local currentPartnerLevle = partnerData.level
    local maxQuality = FuncPartner.getPartnerMaxQuality( _partnerId )
    local needPartnerLevle = upQualityDataVec.partnerLv
    if maxQuality == partnerData.quality then
        return false
    end
    if needPartnerLevle then
        local isEatStatus = false
        if partnerData.position ~= 15 then
            local positions = {}
            local value = partnerData.position
            while value ~= 0 do
                local num = value % 2;
                table.insert(positions, 1, num);
                value = math.floor(value / 2);
            end
            for i = 1 ,4 do
                if positions[i] == nil then
                    table.insert(positions, 1, 0);
                end
            end

            -- 判断每一个是否 装备 可装备 
            -- 有一个可添加的 就显示红点
            local itemsV = upQualityDataVec.pellet
            for i,v in pairs(itemsV) do                   
                if positions[i] == 0 then
                    local enough = PartnerModel:isCombineQualityItem(v, nil)
                    if ItemsModel:getItemNumById(v) > 0 or enough == 3 then
                        isShow = true
                        isEatStatus = true
                        break
                    else
                        isShow = false
                    end
                else
                    isShow = false
                end
            end
        end

        -- echo("\n\nisShow=====", isShow, "isEatStatus====", isEatStatus, "_partnerId===", _partnerId)
        --铜钱判断
        if upQualityDataVec.coin then
            if not isEatStatus and (UserModel:getCoin() < upQualityDataVec.coin or currentPartnerLevle < needPartnerLevle) then
                isShow = false  
            end
        else
            return false
        end
    else  
        return false 
    end
    
    return isShow
end
-- 升星红点显示
function PartnerModel:isShowStarRedPoint(_partnerId)
    if FuncPartner.isChar(_partnerId) then
        if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHARSTAR) == false then
            return false
        end
    else
        if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SHENGXING) == false then
            return false
        end
    end
    
    if PartnerModel:getRedPoindKaiGuanById(_partnerId) == false then
        return false
    end
    local maxStar = FuncPartner.getPartnerMaxStar( _partnerId )
    local currentStar = self:getPartnerDataById(tostring(_partnerId)).star
    if maxStar == currentStar then -- 已经升到最大行
        return false
    else
        return self:isCanUpStar(_partnerId)
    end
end
-- 升级红点显示
function PartnerModel:isShowUpgradeRedPoint(_partnerId)
    -- 判断是否是主角
    if tonumber(_partnerId) < 5000 then
        return false
    end
    
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SHENGJI) == false then
        return false
    end
    if PartnerModel:getRedPoindKaiGuanById(_partnerId) == false then
        return false
    end
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    local partnerLevel = partnerData.level;
    if false then
        return false
    elseif (UserModel:level() - partnerLevel) <= 0 then
        return false
    else
        -- 判断材料 是否满足
        local expItem = FuncPartner.getPartnerById(_partnerId).expItem
        for i,v in pairs(expItem) do
            local currentExp = partnerData.exp;
            local levelData = FuncPartner.getConditionByLevel(partnerLevel)
            local maxExp = levelData[tostring(FuncPartner.getPartnerById(_partnerId).aptitude)].exp
            if ItemsModel:getItemNumById(v) > 0 then
                local _itemData = FuncItem.getItemData(v)
                if _itemData.subType == 308 then
                    return true
                else
                    local addExp = _itemData.useEffect * ItemsModel:getItemNumById(v)
                    if maxExp <= (addExp + currentExp) then
                        return true
                    end 
                end
                
            end
        end
        return false
    end
end

-- 装备红点显示
function PartnerModel:isShowEquipRedPoint(_partnerId)
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_ZHUANGBEI) == false then
        return false
    end
    if PartnerModel:getRedPoindKaiGuanById(_partnerId) == false then
        return false
    end
    local equipment = FuncPartner.getPartnerEquipment(_partnerId);
    
    for i,v in pairs(equipment) do
        if self:isShowEquipRedPointByEquipId(_partnerId,v) then
            return true ,i
        end
    end
    return false
end
function PartnerModel:isEquipAwakeRedPoint( _partnerId )
    if self:checkJXSystemOpen( ) == false then
        return false
    end
    if PartnerModel:getRedPoindKaiGuanById(_partnerId) == false then
        return false
    end
    local equipment = FuncPartner.getPartnerEquipment(_partnerId);
    for i,v in pairs(equipment) do
        local isCan = self:canAwake(_partnerId,v)
        local isAwake = PartnerModel:checkEquipAwakeById( _partnerId,v )
        if isCan and not isAwake and self:checkEquipAwake(v,_partnerId) then
            return true
        end
    end
    return false
end

function PartnerModel:isShowBiographyRedPoint(_partnerId)
    if BiographyModel:hasBoxCanGet(_partnerId) then
        return true
    else
        local curPartnerId = BiographyModel:getCurrentTaskInfo()
    
        if curPartnerId then
            if tonumber(curPartnerId) == tonumber(_partnerId) then
                return true
            end
        else
            local canGet = BiographyModel:isHasTaskCanGet(_partnerId)
            if canGet then
                return true
            end
        end
    end

    return false
end

function PartnerModel:checkEquipAwake(equipId,partnerId)
    local awakeEquipId = FuncPartner.getAwakeEquipIdByid( partnerId,equipId )
    local partnerData = PartnerModel:getPartnerDataById(partnerId)
    local equipData = partnerData.equips[equipId]
    local costT = FuncPartnerEquipAwake.getEquipAwakeCost( awakeEquipId )
    local resType,resId = UserModel:isResEnough(costT)
    if not resId and resType == true then
        return true
    else
        if tonumber(resType) == 1 then
            return false,2
        elseif tonumber(resType) == 2 then
            return false,3
        end
    end
    return false
end
-- 情缘红点显示
function PartnerModel:isLoveRedPoint(_partnerId)
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.LOVE) == false then
        return false
    end
    if PartnerModel:getRedPoindKaiGuanById(_partnerId) == false then
        return false
    end
    
    return NewLoveModel:isShowMainPartnerRedPoint(_partnerId)
end


function PartnerModel:isShowEquipRedPointByEquipId(_partnerId,equipId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    if partnerData.equips == nil then
        echoError(_partnerId .. "该伙伴没有装备信息")
        return false
    end
    if not partnerData.equips[equipId] then
        -- dump(partnerData,"服务器 数据")
        echoError("当前装备ID == ",equipId," 也是现在表里的,去查找表char装备ID" )
        return false
    end
    local level = partnerData.equips[equipId].level
    local equData = FuncPartner.getEquipmentById(equipId)
    local needLevel = equData[tostring(level)].needLv or 0 
    equData = equData[tostring(level)]
    if needLevel <= partnerData.level then --是否解锁
        if self:equipLevelMax(equipId,level) then
            return false
        end
        local costVec = equData.lvCost or equData.qualityCost;
        for i,v in pairs(costVec) do
            local str = string.split(v,",")
            if tonumber(str[1]) == 1 then
                local num = ItemsModel:getItemNumById(str[2]);
                if num < tonumber(str[3]) then
                    return false
                end
            elseif  tonumber(str[1]) == 3 then -- 铜钱   
                if tonumber(str[2]) > UserModel:getCoin() then
                    return false
                end
            end
        end
    else
        return false    
    end
    return true
end

-- 获得技能所需要的星级
function PartnerModel:getAwakenSkillStar(_partnerId)
    if FuncPartner.isChar(_partnerId) then
        return CharModel:getCurrentTreasureStar( )
    else
        if PartnerModel:isHavedPatnner(_partnerId) then
            local partnerData = PartnerModel:getPartnerDataById(_partnerId)
            return partnerData.star
        end
        return 1
    end
end

--判断装备是否满级
function PartnerModel:equipLevelMax(_equipId,level)
    local equData = FuncPartner.getEquipmentById(_equipId)
    equData = equData[tostring(level)]
    if equData.lvCost == nil and equData.qualityCost == nil then
        return true
    else
        return false
    end
end
--是否有技能可以升级  isNotAll 传true是仙术页签上的红点显示 只要有仙术能升级即返回true
function PartnerModel:isShowSkillRedPoint(_partnerId, isNotAll)
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL) == false then
        return false
    end
    if PartnerModel:getRedPoindKaiGuanById(_partnerId) == false then
        return false
    end

    local coinCostSum = 0
    local _realCost = 0
    local _user_coin = UserModel:getCoin()
    local _user_level = UserModel:level()
    local _partnerInfo = self._partners[tostring(_partnerId)]
    local _partDataCfg = FuncPartner.getPartnerById(tostring(_partnerId))
    local _partnerLevel = _partnerInfo.level
    local _red_point = false
    local _skill_table = FuncPartner.getPartnerById(_partnerId)
    --首先统计星级约束
    local _star_condition = {}
    local _starInfos = FuncPartner.getStarsByPartnerId(_partnerInfo.id)
    for _key, _value in pairs(_starInfos) do
        if _value.skillId ~= nil then
            for k, v in pairs(_value.skillId) do
                _star_condition[v] = tonumber(_key)
            end
        end
    end

    --遍历所有的伙伴技能
    -- dump(_star_condition,"\nsssx------",5)
    for _key,_skillId in pairs(_skill_table.skill)do
        local _now_level = _partnerInfo.skills[_skillId] or 1
        if _partDataCfg.awakeSkillId ~= _skillId then
            --等级约束,星级约束
            if _now_level < math.floor(_partnerLevel) and _star_condition[_skillId] and _star_condition[_skillId] <= _partnerInfo.star then
                local _partnerSkill = FuncPartner.getSkillInfo(_skillId)
                local _skillCost = FuncPartner.getSkillCostInfo(_partnerSkill.quality)
                for i = _now_level, math.floor(_partnerLevel - 1) do
                    _realCost = _skillCost[tostring(i)].coin
                    if isNotAll and _realCost <= _user_coin then
                        return true
                    end     
                    coinCostSum = coinCostSum + _realCost
                end                        
            end
        end
        
    end
    
    local awakeSkillId = _skill_table.awakeSkillId
    if _partnerInfo.skills[awakeSkillId] then
        local _now_level = _partnerInfo.skills[awakeSkillId] or 1
        --等级约束,星级约束
        if _now_level < math.floor(_partnerLevel) then
            local _star = PartnerModel:getAwakenSkillStar(_partnerInfo.id)
            local treasureId = TeamFormationModel:getOnTreasureId()
            local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(_partnerInfo,_star,treasureId)
            local _skillCost = FuncPartner.getSkillCostInfo(awakeSkillData.quality)
            for i = _now_level, math.floor(_partnerLevel - 1) do
                _realCost = _skillCost[tostring(i)].coin
                if isNotAll and _realCost <= _user_coin then
                    return true
                end       
                coinCostSum = coinCostSum + _realCost
            end                        
        end    
    end

    local weaponAwakeSkillId = _skill_table.weaponAwakeSkillId
    if _partnerInfo.skills[weaponAwakeSkillId] then
        local _now_level = _partnerInfo.skills[weaponAwakeSkillId] or 1
        --等级约束,星级约束
        if _now_level < math.floor(_partnerLevel) then
            local isAwake, awakeSkillData = FuncPartner.checkWuqiAwakeSkill(_partnerInfo)
            local _skillCost = FuncPartner.getSkillCostInfo(awakeSkillData.quality)
            for i = _now_level, math.floor(_partnerLevel - 1) do
                _realCost = _skillCost[tostring(i)].coin
                if isNotAll and _realCost <= _user_coin then
                    return true
                end      
                coinCostSum = coinCostSum + _realCost
            end                        
        end    
    end

    --铜钱约束 花费铜钱为0时说明技能都已升至当前最高等级
    if coinCostSum > 0 and coinCostSum <= _user_coin then
        _red_point = true
    else
        _red_point = false
    end

    return _red_point
end
--仙魂红点事件
function PartnerModel:isShowSoulredPoint(_partnerId)
    --统计几种道具可以产生的升级经验
    local _soul_item = {}
    for _key,_value in pairs(FuncPartner.SoulItemId)do
        local _item_item = FuncItem.getItemData(_key)
        _soul_item[_key] = ItemsModel:getItemNumById(_key) * _item_item.useEffect
    end
    --计算所能产生的
end
-------------------- 初始NPC ---------------------
function PartnerModel:initNpc(_partnerId)
    local t1 = os.clock()
    local partnerData = FuncPartner.getPartnerById(_partnerId);
    local bossConfig = partnerData.dynamic
    local arr = string.split(bossConfig, ",");
--    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    local sp = FuncRes.getArtSpineAni(arr[1])
--    local sp = FuncPartner.getHeroSpine(_partnerId)
    if arr[3] == "1" then 
        sp:setRotationSkewY(180);
    end 
    
    if arr[4] ~= nil then -- 缩放
        local scaleNum = tonumber(arr[4])
        if scaleNum > 0 then
            scaleNum = 0 - scaleNum    
        end
        echo("放大倍数=======",scaleNum)
        sp:setScaleX(scaleNum)
        sp:setScaleY(-scaleNum)
    end
    if arr[5] ~= nil then -- x轴偏移
        sp:setPositionX(sp:getPositionX() + tonumber(arr[5]))
    end
    if arr[6] ~= nil then -- y轴偏移
        sp:setPositionY(sp:getPositionY() + tonumber(arr[6]))
    end
    
--    sp:setShadowVisible(false)
    echo(os.clock() - t1,"-------- spin ddddd 消耗时间");
    return sp
end
--判断伙伴已存在
function PartnerModel:isHavedPatnner(_partnerId)
    if not self._partners then
        return false
    end
    for i,v in pairs(self._partners) do
        if tostring(v.id) == tostring(_partnerId) then
            return true
        end
    end
    return false
end
--伙伴合成需要碎片数量
function PartnerModel:getCombineNeedPartnerNum(_partnerId)
    return FuncPartner.getPartnerById(_partnerId).tity
end
--伙伴升星需要碎片数量
function PartnerModel:getUpStarNeedPartnerNum(_partnerId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    local costVec = FuncPartner.getStarsByPartnerId(_partnerId)
    local costFrag = 0
    for i,v in pairs(costVec) do
        if v.star == partnerData.star then
            local starStage = partnerData.starPoint+1;
            if starStage > 4 then
                costFrag = 0
            else
                -- 判断是否满级
                if v.cost then
                    costFrag = (v.cost)[starStage]
                end
            end
            
            break
        end
    end
    return costFrag
end
--获得有几个大于level参数级别的伙伴
function PartnerModel:partnerNumGreaterThenParamLvl(level)
    local num = 0
    if not self._partners then
        return num
    end
    for i,v in pairs(self._partners) do
        if v.level and v.level > level then
            num = num + 1
        end
    end
    return num
end
-- 获得大于xx品质装备数
function PartnerModel:getEquipmentNumByMorethanquality(_quality)
    local num = 0
    if not self._partners then
        return num
    end
    for i,v in pairs(self._partners) do
        local partnerCfgData = FuncPartner.getPartnerById(v.id);
        for m,n in pairs(partnerCfgData.equipment) do
            local level = v.equips[n].level
            local equData = FuncPartner.getEquipmentById(n)
            equData = equData[tostring(level)]
            if equData.quality > _quality then
                num = num + 1
            end
        end
    end
    echo("获得大于".._quality.."品质装备数 === "..num)
    return num
end
--获得有几个大于quality参数品质的伙伴
function PartnerModel:partnerNumGreaterThenParamQuality(quality)
    local num = 0
    if not self._partners then
        return num
    end
    for i,v in pairs(self._partners) do
        if v.quality > quality then
            num = num + 1
        end
    end
    return num
end
--获得有几个大于star参数星级的伙伴
function PartnerModel:partnerNumGreaterThenParamStar(star)
    local num = 0
    if not self._partners then
        return num
    end
    for i,v in pairs(self._partners) do
        if v.star > star then
            num = num + 1
        end
    end
    return num
end

--大于num的绝技数
function PartnerModel:getUniqueSkillLevelOverThenParamNum(num)
    local totalNum = 0;
    if not self._partners then
        return num
    end
    echo("--------------------rrrrrrrrrrr---",num )
    for partnerId, value in pairs(self._partners) do
        for _, v in pairs(value.souls) do
            if v.level ~= nil and v.level > num then 
                totalNum = totalNum + 1;
            end 
        end
    end

    return totalNum;
end

--计算所有伙伴战力总和
function PartnerModel:getAllPartnerAbility( )
    local _ability = 0
    if self._partners then
        for i,v in pairs(self._partners) do
            _ability = _ability + PartnerModel:getPartnerAbility(v.id)
        end
    end
    return _ability
end
--检查伙伴是否存在
function PartnerModel:isPartnerExist(_partnerId)
    return self._partners[tostring(_partnerId)] ~= nil 
end
--给定伙伴id,获取其所有的属性加成
--注意,给定的伙伴一定要存在
function PartnerModel:getPartnerAttr(_partnerId)
    local _partnerInfo = self._partners[tostring(_partnerId)]
    assert(_partnerInfo ~= nil ,"Partner must exist!,but gived id is not exist,id==",_partnerId)

    local skins = PartnerSkinModel:getEnableSkins()

    return FuncPartner.getPartnerAttribute(_partnerInfo,UserModel:data(),nil)
end



-- 引导的合成 伙伴ID
function PartnerModel:setYDCombinePartnerId(_partnerId)
    self.ydCombinePartnerId = _partnerId
end


-- 记录奇侠选中ID 方便下次进入再次养成该ID
function PartnerModel:setPartnerId(_id)
    self.ycId = _id
end
function PartnerModel:getPartnerId( )
    return self.ycId
end
-- 记录奇侠选中页签 方便下次进入再次养成该页签
function PartnerModel:setPartnerYeQian(yeqian)
    self.ycYeQian = yeqian
end
function PartnerModel:getPartnerYeQian( )
    return self.ycYeQian
end
-- 判断此伙伴是否可合成或养成
function PartnerModel:getPartnerTypeById( _id )
    -- 先判断是否是主角
    if FuncPartner.isChar(_id) then
        return self.ycYeQian or 1
    end
    -- 此伙伴是否存在
    if self._partners[tostring(_id)] then
        return self.ycYeQian or 1
    else
        return 6
    end
end

function PartnerModel:getMainSkillById(id)
    local tempSkillList = {}
    local partnerData = FuncPartner.getPartnerById(id) 
    for k=1,#partnerData.skill do
        if partnerData.skill[k] then
            local tempSkillData = FuncPartner.getSkillInfo(partnerData.skill[k])
            if tempSkillData.order == 3 and tempSkillData.priority == 1 then
                table.insert(tempSkillList,partnerData.skill[k])
            end
            if tempSkillData.order == 4 then
                table.insert(tempSkillList,partnerData.skill[k])
            end
        end
    end
    return tempSkillList
end

-- 使用经验药跳转到奇侠
--[[
包裹中点击“使用”经验药，跳转到了主角养成界面，
应该跳转到一个低于主角等级的奇侠的界面，且打开升级小窗口
]]
function PartnerModel:useExpItemOpenId( )
    local userLevel = UserModel:level()
    local allPartners = self:getAllPartner() or {}
    local selectParterId = nil
    for k,v in pairs(allPartners) do
        if v.level < userLevel then
            selectParterId = k
        end
    end
    return selectParterId
end

-------------------------------------------------------------
-------------------------装备觉醒----------------------------
-------------------------------------------------------------
-- 装备觉醒相关
function PartnerModel:checkJXSystemOpen( )
    return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EQUIPAWAKE)
end

-- 判断装备是否可觉醒
function PartnerModel:canAwake(partnerId,equipId)
    if not PartnerModel:checkJXSystemOpen( ) then
        return false
    end
    -- 解锁条件是否满足
    local awakeEquipId = FuncPartner.getAwakeEquipIdByid( partnerId,equipId )
    local unlockType = FuncPartnerEquipAwake.getEquipAwakeUnlockTy( awakeEquipId )
    local partnerData = PartnerModel:getPartnerDataById(partnerId)
    local tipStr = ""

    for i,v in pairs(unlockType) do
        if v.key == 1 then -- 装备等级解锁
            local equipData = partnerData.equips[equipId]
            if equipData.level < v.value  then
                local level = v.value
                if v.value > 10 then
                    level = FuncPartner.getEquipmentShowLevelByIdAndLevel(equipId, level)
                end
                
                tipStr = GameConfig.getLanguageWithSwap("#tid_partner_awaken_009", level)
                return false,i,tipStr
            end
        elseif v.key == 2 then -- 奇侠品质
            if partnerData.quality < v.value then
                local qualityData = FuncPartner.getPartnerQuality(partnerId)[tostring(v.value)]
                local nameColor = qualityData.nameColor
                local houzhui = ""
                nameColor = string.split(nameColor,",")
                if tonumber(nameColor[2]) > 1 then
                    houzhui = "+"..(tonumber(nameColor[2]) - 1)
                end
                local des = FuncPartner.nameColor[tonumber(nameColor[1])]..houzhui
                tipStr = GameConfig.getLanguageWithSwap("#tid_partner_awaken_010", des)
                return false,i,tipStr
            end
        elseif v.key == 3 then -- 奇侠星级
            if FuncPartner.isChar(partnerId) then
                for kk,vv in pairs(partnerData.treasures) do
                    if vv.star >= v.value then
                        return true
                    end
                end

                tipStr = GameConfig.getLanguageWithSwap("#tid_partner_awaken_011", v.value)
                return false,i,tipStr
            else
                if partnerData.star < v.value then
                    tipStr = GameConfig.getLanguageWithSwap("#tid_partner_awaken_012", v.value)
                    return false,i,tipStr
                end
            end            
        end
    end

    return true
end

-- 判断装备是否已觉醒
function PartnerModel:checkEquipAwakeById( partnerId,equipId )
    if not PartnerModel:checkJXSystemOpen( ) then
        return false
    end
    local partnerData = self:getPartnerDataById(partnerId)
    local equipData = partnerData.equips[equipId]
    if not equipData then
        echoError("客户端的装备表和服务器记录的不一致")
        return false
    end
    local awake = equipData.awake
    if awake and awake == 1 then
        return true
    end
    return false
end

-- 通过装备id获得name
function PartnerModel:getEquipNameById(partnerId,equipId)
    local index = FuncPartner.getEquipIndexById( partnerId,equipId )
    local equipId = FuncPartner.getEquipIdByIndex( partnerId,index )
    -- 判断是否已经觉醒
    if self:checkEquipAwakeById( partnerId,equipId ) then
        local _equipId = FuncPartner.getAwakeEquipIdByIndex( partnerId,index )
        return FuncPartnerEquipAwake.getEquipAwakeName( _equipId )
    else
        return FuncPartner.getEquipmentName( equipId,partnerId )
    end
end
-- 通过装备id获得icon
function PartnerModel:getEquipIconById(partnerId,index)
    local equipId = FuncPartner.getEquipIdByIndex( partnerId,index )
    -- 判断是否已经觉醒
    if self:checkEquipAwakeById( partnerId,equipId ) then
        local _equipId = FuncPartner.getAwakeEquipIdByIndex( partnerId,index )
        return FuncPartnerEquipAwake.getEquipAwakeIcon( _equipId )
    else
        return FuncPartner.getEquipmentIcon( partnerId,index)
    end
end

function PartnerModel:getMaxAbilityPartnerData()
    local ability = 0
    local partnerData
    for k,v in pairs(self._partners) do
        local tempAbility = self:getPartnerAbility(k)
        if tempAbility > ability then
            ability = tempAbility
            partnerData = v
        end
    end

    return partnerData, ability
end

-- 获取某个伙伴的极限养成战力
-- 名册系统用到
function PartnerModel:getPartnerExtremeAbility(partnerId)
    return 10000
end

--判断玩家是否处于 升级 的熟练期
function PartnerModel:isSkilledPlayerForUpgrade()
    if IS_PARTNER_SKILLFULL then
        return true
    end

    local limitLevel, limitValue = FuncPartner.getSkilledLevelAndValueByKey("promote")
    if UserModel:level() < limitLevel then
        return false
    end

    local levelSum = 0
    for k,v in pairs(self._partners) do
        if v.level > 1 then
            levelSum = levelSum + v.level
        end
        
        if levelSum >= limitValue then
            if not LS:prv():get(StorageCode.partner_skilledForUpgrade) then
                LS:prv():set(StorageCode.partner_skilledForUpgrade, true)
            end

            return true
        end
    end
    return false
end

--判断玩家是否处于 升品 的熟练期
function PartnerModel:isSkilledPlayerForUpQuality()
    if IS_PARTNER_SKILLFULL then
        return true
    end

    local limitLevel, limitValue = FuncPartner.getSkilledLevelAndValueByKey("trait")
    if UserModel:level() < limitLevel then
        return false
    end

    local charInitData = FuncChar.getCharInitData()
    local qualitySum = UserModel:quality() - charInitData.initQuality or 0
    for k,v in pairs(self._partners) do
        local partnerCfg = FuncPartner.getPartnerById(v.id)
        qualitySum = qualitySum + (v.quality - partnerCfg.initQuality)
        
        if qualitySum > limitValue then
            if not LS:prv():get(StorageCode.partner_skilledForUpQuality) then
                LS:prv():set(StorageCode.partner_skilledForUpQuality, true)
            end 
            return true
        end
    end

    return false
end

--判断玩家是否处于 仙术修炼 的熟练期
function PartnerModel:isSkilledPlayerForSkill()
    if IS_PARTNER_SKILLFULL then
        return true
    end

    local limitLevel, limitValue = FuncPartner.getSkilledLevelAndValueByKey("magic")
    if UserModel:level() < limitLevel then
        return false
    end

    local skillLevelSum = 0
    for k,v in pairs(self._partners) do
        if v.skills then
            for kk,vv in pairs(v.skills) do
                if tonumber(vv) > 1 then
                    skillLevelSum = skillLevelSum + tonumber(vv)
                end
                
                if skillLevelSum > limitValue then
                    if not LS:prv():get(StorageCode.partner_skilledForSkill) then
                        LS:prv():set(StorageCode.partner_skilledForSkill, true)
                    end 
                    return true
                end
            end
        end
    end

    return false
end

--判断玩家是否处于  升星  的熟练期
function PartnerModel:isSkilledPlayerForStar()
    if IS_PARTNER_SKILLFULL then
        return true
    end

    local limitLevel, limitValue = FuncPartner.getSkilledLevelAndValueByKey("star")
    if UserModel:level() < limitLevel then
        return false
    end

    local charInitData = FuncChar.getCharInitData()
    local starSum = UserModel:star() - charInitData.initStar or 0
    for k,v in pairs(self._partners) do
        local partnerCfg = FuncPartner.getPartnerById(v.id)
        starSum = starSum + (v.star - partnerCfg.initStar)
        if starSum > limitValue then
            if not LS:prv():get(StorageCode.partner_skilledForStar) then
                LS:prv():set(StorageCode.partner_skilledForStar, true)
            end 
            return true
        end
    end

    return false
end

--判断是否处于 装备强化 的熟悉期
function PartnerModel:isSkilledPlayerForEquipmentEnhance()
    if IS_PARTNER_SKILLFULL then
        return true
    end

    local limitLevel, limitValue = FuncPartner.getSkilledLevelAndValueByKey("partnerEquipment")
    if UserModel:level() < limitLevel then
        return false
    end

    local enhanceLevel = 0
    if UserModel:equips() then
        for k,v in pairs(UserModel:equips()) do
            local tempLevel = FuncPartner.getEnhanceLevelAndAdvanceLevel(v.id, v.level)
            enhanceLevel = enhanceLevel + tempLevel
            if enhanceLevel > limitValue then
                if not LS:prv():get(StorageCode.partner_skilledForEquipmentEnhance) then
                    LS:prv():set(StorageCode.partner_skilledForEquipmentEnhance, true)
                end 
                return true
            end
        end
    end

    for k,v in pairs(self._partners) do
        if v.equips then
            for kk,vv in pairs(v.equips) do
                local tempLevel = FuncPartner.getEnhanceLevelAndAdvanceLevel(vv.id, vv.level)
                enhanceLevel = enhanceLevel + tempLevel
                if enhanceLevel > limitValue then
                    if not LS:prv():get(StorageCode.partner_skilledForEquipmentEnhance) then
                        LS:prv():set(StorageCode.partner_skilledForEquipmentEnhance, true)
                    end 
                    return true
                end
            end
        end   
    end

    return false
end

--判断是否处于 装备进阶 的熟悉期
function PartnerModel:isSkilledPlayerForEquipmentAdvance()
    if IS_PARTNER_SKILLFULL then
        return true
    end
    
    local limitLevel, limitValue = FuncPartner.getSkilledLevelAndValueByKey("partnerProgress")
    if UserModel:level() < limitLevel then
        return false
    end

    local advanceLevel = 0
    if UserModel:equips() then
        for k,v in pairs(UserModel:equips()) do
            local _, tempLevel = FuncPartner.getEnhanceLevelAndAdvanceLevel(v.id, v.level)
            advanceLevel = advanceLevel + tempLevel
            if advanceLevel > limitValue then
                if not LS:prv():get(StorageCode.partner_skilledForEquipmentAdvance) then
                    LS:prv():set(StorageCode.partner_skilledForEquipmentAdvance, true)
                end 
                return true
            end
        end
    end

    for k,v in pairs(self._partners) do
        if v.equips then
            for kk,vv in pairs(v.equips) do
                local _, tempLevel = FuncPartner.getEnhanceLevelAndAdvanceLevel(vv.id, vv.level)
                advanceLevel = advanceLevel + tempLevel
                if advanceLevel > limitValue then
                    if not LS:prv():get(StorageCode.partner_skilledForEquipmentAdvance) then
                        LS:prv():set(StorageCode.partner_skilledForEquipmentAdvance, true)
                    end 
                    return true
                end
            end
        end   
    end

    return false
end

return PartnerModel