--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--
local Fight = Fight
--触发事件的名称数组  比如 生命值改变的时候 需要触发生命改变侦听 通知ui 去更新生命值
local eventNameArr = {  hp = BattleEvent.BATTLEEVENT_CHANGEHEALTH,
                        -- energy =BattleEvent.BATTLEEVENT_CHANGEENEGRY,
                        maxtreahp =BattleEvent.BATTLEEVENT_MAXHPCHANGE,
                        power = BattleEvent.BATTLEEVENT_CHANGEPOWER,
                        state = BattleEvent.BATTLEEVENT_PLAYER_STATE,
                        
                        }


--  每个数据对象 都有一个属性值 对应静态属性
ObjectHero = class("ObjectHero")


local __keyMap = {}
local __keyInitMap = {}
local __keyMaxMap = {}

--对应的静态数据库对象  是非修改的 每个数据对象的 静态数据格式对应 对影静态数据获取格式
--static  静态属性 会从数据库直接取过来  而且这个数值是不能更改的
-- ObjectHero.prototypeData= {
-- }

--实例属性
--一定要让这里的数值属性 和 传递过来的属性保持一致  这样是为了 保证 修改某个属性值的时候 方便拿到初始值          
        
--[[
    --记录自身的buff信息
    {
        --buff类型 ObjectBuff
        type = Fight.bufftType_resumeHealth,
        kind = 1
        value = 100,
        time  = 100,
    }  

]]
ObjectHero.treasures = nil      -- 对象带的技能对象数组

ObjectHero.posIndex = 0            --位置  


ObjectHero.gridPos = nil       --记录自己在第几个x 几个y 的格子


--[[
    --结构
    {
        buffType1:{ buff1,buff2 },
        buffType2:{ buff1,buff2 },
        buffType3:{ buff1,buff2 },
        ...
    }

]]

ObjectHero.buffInfo = nil       -- buff信息
--[[
    typeNum = {
        buffType1 = num
        ...
    }
    allNum = 0
]]
ObjectHero.buffNums = nil       -- 记录buff的数量，可以有效减少遍历次数
ObjectHero.chkActionBuff = nil  -- 需要检查行动情况的buff,维护这个表主要是为了加快遍历速度

ObjectHero.nextRoundBuffInfo = nil   -- 下回合才生效的buff信息

--[[
    结构
    {
        buffType1:{ani1,ani2,...},是一个特效数组

    }
]]

-- ObjectHero.__hp = 0
-- ObjectHero.__energy = 0


ObjectHero.rid = "bzd" -- 必须默认一个值，不能用nil 因为怪物的时候不会赋值rid
ObjectHero._curTreasureHid = 0
ObjectHero.curTreasureIndex = 0     --当前法宝序号 默认是0 表示默认法宝 1表示第一个位置 2表示第二个位置
ObjectHero.defArmature = nil
ObjectHero.defSpbName = nil
ObjectHero.curArmature = nil    --当前spine动画名称
ObjectHero.curSpbName = nil     --当前的spine 配置文件名称  这2个是独立的

-- 不需要备份的数据
ObjectHero.__heroModel = nil
ObjectHero.speed = 0   -- 配表数据不需要备份,创建时就会有
ObjectHero.curTreasure = nil  -- 当前所带法宝
ObjectHero.isCharacter = false    --是否是玩家
ObjectHero.sourceData = nil -- 人物的动作
ObjectHero.__actionExArr = nil
ObjectHero.attackDis = nil
ObjectHero.attackSep = nil

--重复播放的动作
ObjectHero._repeatActionArr =nil 

--小技能概率参数
ObjectHero.skillRatioParams  = nil


--标记这个 伙伴是属于谁的 
ObjectHero.characterRid = nil   --表示 这个伙伴是属于谁的

--记录受击前的信息
ObjectHero.dataBeforeHited = nil

function ObjectHero:ctor(hid, datas)
    --绑定侦听
    EventEx.extend(self)
    
    self.buffInfo = {}
    self.buffNums = {
        typeNum = {},
        allNum = 0,
        kindNum = {
            [Fight.buffKind_hao] = 0,
            [Fight.buffKind_huai] = 0,
            [Fight.buffKind_aura] = 0, 
            [Fight.buffKind_aurahuai] = 0, 
            [Fight.buffKind_neutral] = 0, 
        }
    }
    self.chkActionBuff = {}

    self.nextRoundBuffInfo = {}
    self.sourceData = {}
    self.__repeatActionArr ={}
    --目前暂时先采用固定配置 等策划需求跟上   然后需要根据datas的属性确定最终的实例属性
    self.hid = tostring(hid)
    self.rid = datas.rid
    --站位
    self.posIndex = datas.posIndex

    self.isCharacter = datas.isCharacter
    if not datas.isCharacter  then
        self.isCharacter =false
    end
    self.characterRid = datas.characterRid
    
    -- 觉醒资源
    self.awakenWeapon = datas.awakenWeapon

    local xIndex = math.ceil( self.posIndex /2 )
    local yIndex = self.posIndex %2 
    if yIndex == 0 then
        yIndex = 2
    end

    self.speed = datas.moveSpd

    local initTrea = nil

    self.defArmature = datas.armature
    self.defSpbName = datas.armature
    self.viewSize = datas.viewSize

    self.gridPos = {x=xIndex ,y =yIndex}
    self:updateDatas(datas,true)
    self.dataBeforeHited = {}
    

    -- echo("sel.hpAi------------------")
    -- dump(self:hpAi)
    -- echo("sel.hpAi------------------")
    self.hpAiObj = ObjectHpAi.new(self:hpAi() ,self  )

    --小技能参数管理
    local sskp = self.datas.sskp 
    --如果配置了小技能 那么小技能才能触发
    if sskp then
        self.skillRatioParams = {start = sskp[1],current = sskp[1],step = sskp[2], need=sskp[3]   }
    else
        self.skillRatioParams = nil
    end
    

end

--获取
function ObjectHero:getKey(key)
    return __keyMap[key]
end

function ObjectHero:getInitKey(key)
    return __keyInitMap[key]
end

function ObjectHero:getMaxKey(key)
    return __keyMaxMap[key]
end

--是否是默认法宝
function ObjectHero:isDefaultTreasure(  )
    return self.curTreasure == self.treasures[1]
end


--是否是大体型角色
function ObjectHero:isBigger(  )
    return self:figure() > 1
end

-- 是否占据某个格子
function ObjectHero:isHoldPosIndex(posIndex)
   return posIndex >= self.posIndex and posIndex <= self.posIndex + self:figure() - 1
end

--初始化各种二级属性
function ObjectHero:initSecondProp(  )
    local attr = self.datas
    -- local getKey = getKey
    
    for k,v in pairs(attr) do
        if k ~= "rid" and k ~= "hid" and k ~= "isCharacter" and k ~= "awakenWeapon" then
            
            if not __keyMap[k] then
                __keyMap[k] = "__"..k
                __keyInitMap[k] = "__init"..k
                __keyMaxMap[k] = "__max"..k
                if type(k) ~= "string" then
                    error(tostring(k).."___"..tostring(v) )
                end
            end
            local targetKey =self:getKey(k)
            self[targetKey] = v
            --同时存储下初始值,
            -- if type(v) == "number" then
                self[self:getInitKey(k)] = v
            -- end
            
            --必须动态设置 没有设定的属性方法,避免覆盖
            if  ObjectHero[k] == nil then
                ObjectHero[k] = function ( _self )
                    local value = _self[targetKey]
                    -- local value = _self["__"..k]
                    -- local ts = GameStatistics:costTimeEnd( "ObjectHero:getValue" ,ts)
                    return value
                    -- return _self[getKey(k)]
                end
            end
        end
    end
end

-- 获取属性初始值
function ObjectHero:getInitValue( name )
    local initValue = self[self:getInitKey(name)]
    if not initValue then
        initValue = 0
        echoWarn("key:",name,"没有获取到初始属性值")
    end
    return initValue
end

--更新数据 --是否是初始化
function ObjectHero:updateDatas( datas ,init )
    --这里需要做下安全校验 否则可能会出现问题
    self.datas = table.copy(datas)
    --初始化治疗上限 ,生命上限不能超过治疗上限
    self.datas.maxtreahp = self.datas.maxhp
    --初始化二级属性
    self:initSecondProp()
    self.treasures = {}

    local treasurArr = self.datas.treasures
    -- 法宝
    for i=1,#treasurArr do
        local num = #self.treasures + 1
        local treasueObj = ObjectTreasure.new(treasurArr[i].hid,treasurArr[i])
        self.treasures[num] = treasueObj
        treasueObj.treaType = treasurArr[i].treaType
        if treasurArr[i].treaType == Fight.treaType_base then
            --上来使用的法宝都是默认法宝 baseTrea
            self:useTreasure(treasueObj,nil,true)
        end
    end
    self.exTreasures = {}
end
-- 额外缓存的法宝纹理
function ObjectHero:addExTreasuresCache(treasure )
    local treasueObj = ObjectTreasure.new(treasure.hid,treasure)
    table.insert(self.exTreasures,treasueObj)
end

--插入一个法宝 返回法宝的treasureIndex
function ObjectHero:insterTreasure( treasureHid )
    local treasueObj = ObjectTreasure.new(treasureHid,{})
    -- 2017.09.16 pangkangning 修改法宝插入次数,这里以前为什么些的是4，当法宝超过4个的时候，就不能在插入法宝了
    -- for i=1,4 do
    for i=1,6 do
        if not self.treasures[i] then
            self.treasures[i] = treasueObj
            treasueObj:setHero(self.__heroModel)
            return i -1
        --如果已经和这个法宝id相同了
        elseif treasureHid == self.treasures[i].hid  then
            return i-1
        end
    end
    echoWarn("_插入一个法宝的时候没有插入进去",self.hid,"法宝id:",treasureHid)
    return 0
end


-- 使用法宝的数据
-- 增加初始化参数 isInit
function ObjectHero:useTreasure(treasure,treasureIndex,isInit)
    -- 首先清除光环这个法宝自带的光环
    local isChangeTreasure = false
    -- pangkangning 2018.03.05 添加not isInit判断，否则cancleAure 中的__heroModel还没有初始化
    if self.curTreasure and treasure ~= self.curTreasure and not isInit then
        self:cancleAure()
        isChangeTreasure = true
    end
    self.curTreasureIndex = treasureIndex
    treasure:initData()
    self.curTreasure = treasure
    self._curTreasureHid = self.curTreasure.hid

    -- 动作 获取法宝对应的所有动作
    self:getAllAction()

    -- 如果是初始化不在这里作用光环，会在阵营初始化后统一作用，不然会报错，因为__heroModel还没有初始化
    if not isInit then
        self:initAure()
    end

    -- 2017.08.09 pangkangning 这里给职业赋值 当更换法宝的时候也应该发一个角色更换的方法
    self.datas.profession = self.curTreasure:sta_profession()
end

--初始化一个法宝的光环 或者说是天赋
function ObjectHero:initAure(  )
    local skill5 =self.curTreasure.skill5
    if skill5 then
        skill5:doAtkDataFunc()
    end 
    local skill6 =self.curTreasure.skill6
    if skill6 then
        skill6:doAtkDataFunc()
    end
    -- 技能7也当做光环处理 2017.12.05
    local skill7 =self.curTreasure.skill7
    if skill7 then
        skill7:doAtkDataFunc()
    end
end

--取消这个英雄附带的光环
function ObjectHero:cancleAure(  )
    -- 没有对象证明已经死亡，没有必要再做取消了
    if not self.__heroModel then return end
    
    local allModelArr = self.__heroModel.controler.allModelArr
    local length = #allModelArr
    for i=length,1,-1 do
        local hero = allModelArr[i]
        if hero.data and hero.data.clearAuraByTargeHero then
            --让每个英雄都取消掉作用在他身上的光环
            hero.data:clearAuraByTargeHero(self.__heroModel)
        end
    end
end


--当换法宝的时候 需要遍历所有人取消掉所有的光环
function ObjectHero:clearAuraByTargeHero(heroModel  )
    for k,v in pairs(self.buffInfo) do
        local length = #v
        local hasClear = false
        for i=length,1,-1 do
            local buffObj = v[i]
            --必须是同一个作用着 而且 time < 0  而且
            -- 首先必须是光环 2017.12.06
            if buffObj:isValid() 
                and buffObj:checkIsAura() 
                and buffObj.hero == heroModel 
                and buffObj.time < 0 
                and buffObj:sta_followClear() == 1 
            then
                -- table.remove(v,buffObj)
                self:clearOneBuffObj(buffObj)
                -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
                --移除这个buff
                
                hasClear = true
            end
        end
        if hasClear then
            self:useLastBuffAni(k)
        end
    end
end


-- 获得法宝的所有动作
function ObjectHero:getAllAction()
    local treasure = self.curTreasure


    -- 动作序列
    self.curArmature = treasure.spineName
    self.curSpbName = self.curArmature
    if self.curArmature == "0" then
        self.curArmature = self.defArmature
        self.curSpbName = self.defSpbName
    end

    if not self.curSpbName then
        echoError("_找策划_没有找到spine文件ingz",treasure.hid,treasure.spineName)
    end
    if Fight.isDummy then 
        self.sourceData = {}
        return
    end
    --直接拿法宝的动作
    self.sourceData = self.curTreasure.sourceData

    -- 动作特效跟sourceId 绑定
    local sourceId = self.curTreasure:sta_source()
    self.__actionExArr = ObjectCommon:getSourceEx(sourceId)

    --记录能重复播放的动作
    --
    local repeatArr = {"stand","walk","run","giveOutBM","rushMiddle","win","repelledMiddle"}
    for i,v in ipairs(repeatArr) do
        local act = self.sourceData[v]
        if act then
            if type(act) == "string" then
                self.__repeatActionArr[ act  ] = true
            else
                for kk,vv in pairs(act) do
                    self.__repeatActionArr[ vv ] = true 
                end
            end
        end
    end

end

function ObjectHero:getActionEx( action )
    if not self.__actionExArr then
        return nil
    end
    return self.__actionExArr[action]
end




function ObjectHero:setHeroModel( hero )
    self.__heroModel = hero
    for i,v in pairs(self.treasures) do
        v:setHero(hero)
    end
end

--改变某个属性
--[[
    name  属性名称
    value 改变值
    changeType 类型 1 是按数值变化 2是按照比例变化
    min 最小值 限制
    max 最大值 限制
    atkType 伤害类型（物理/法术）非必须
    skillIndex 技能类型 （普通仙术/...）
]]
function ObjectHero:changeValue( name,value,changeType ,min,max,atkType,skillIndex)
    -- local t1 = GameStatistics:costTimeBegin( "ObjectHero:changeValue" )
    if name == Fight.value_health and self:isImmnueDmg(atkType, skillIndex) then
        return 0,0
    end

    local keyName = self:getKey(name)
    local old = self[keyName]
    local new = nil

    changeType = changeType or 1

    local changeNum
    -- 真实改变的值
    local realChangeNum 
    --按数值改变
    if changeType ==Fight.valueChangeType_num then
        new = old + value
        changeNum = value
    else
        local initValue = self[self:getInitKey(name)]
        
        if initValue then
            changeNum = initValue * value
            new =old + initValue * value
        else
            echoError ("key:",name,"按比例修改属性但是没有获取到初始属性值")
            return 0,0
        end
    end

    max = max or self[self:getMaxKey(name)]
    min = min or 0

    if min then
        if new < min then
            new = min
        end
    end

    if max then
        --如果是改变生命
        if name == Fight.value_health and value > 0  then
            max = self:maxtreahp()
        end

        if new > max then
            new = max
        end
    end

    -- 取整
    new = math.round(new)
    self[keyName] = new
    realChangeNum = new - old

    -- 如果改变的是真正的生命上限"maxhp"生命值和治疗上限也要改变
    if name == Fight.value_maxhp then
        local hpPer = self:hp() / old
        -- 上限改变后的血量
        local hp = math.round(new * hpPer)
        -- 直接给血量赋值
        self[self:getKey( Fight.value_health)] = hp
        -- 治疗上限
        local oldtreahp = self[self:getKey(Fight.value_maxtreahp)]
        -- 改变的值与治疗上限一致
        oldtreahp = oldtreahp + (new - old)
        
        if oldtreahp < 0 then oldtreahp = 0 end

        self[self:getKey( Fight.value_maxtreahp)] = oldtreahp
    end

    --发送一个对应属性改变的侦听  比如 攻击改变 或者防御 生命改变之后 是需要发送侦听的
    local eventName = eventNameArr[name]
    if eventName and self.__heroModel then
       self:dispatchEvent(eventName,{changeNum})
    end
    if name == Fight.value_health then
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TALKBUBBLE,{tType = Fight.talkTip_onHp})
        -- boss 试炼玩法掉血掉落道具相关处理
        if self.__heroModel then
            self.__heroModel.controler:chkOnHpCountBuckle(self.__heroModel)
        end
    end
    return changeNum,realChangeNum
end




--获取属性 根据key
function ObjectHero:getAttrByKey( key )
    if not self[key] then
        echoError ("没有这个属性:",key)
    end
    return self[key](self)
end

--获取某个属性的比例
function ObjectHero:getAttrPercent( key )
    local value1 = self:getAttrByKey(key)
    local value2 = self:getAttrByKey("max"..key)
    return value1/value2 
end


--判断是否生命虚弱 true 表示虚弱 false 表示不虚弱
function ObjectHero:isHealthWeek(  )
    return self:getAttrPercent(Fight.value_health ) <Fight.weekHpPercent
end

--受击前记录一下自己当前的一些信息，以供使用
function ObjectHero:setDataBeforeHited()
    -- 血量
    self.dataBeforeHited[Fight.value_health] = self[Fight.value_health](self)
end
function ObjectHero:getDataBeforeHited(key)
    local key = key or "none"
    return self.dataBeforeHited[key]
end
-----------------------------------------------------------------------------------------
-----------------------------buff相关------------------------------------------------------------
-----------------------------------------------------------------------------------------

----------------------------------------------------------------------
---------------------设置buff-----------------------------------------
--[[
    
]]
--[[
    判断某buff是否可以被添加
    比如免晕时不能添加眩晕buff
    -- 系统级
]]
function ObjectHero:chkBuffCanBeUse(buffObj)
    -- 傀儡不能上负面buff（有标记非活人buff的都不能上，可能直接被毒死）
    if self:hasNotAliveBuff() 
        and buffObj.kind == Fight.buffKind_huai
    then
        return false
    end

    return true
end

function ObjectHero:chkBuffBeImmune(buffObj)
    --对有些buff天生免疫
    local buffImune = self.curTreasure.__buffImmune
    if buffImune[buffObj.type] 
        and buffObj:checkIsJianyi()
    then -- 免疫且是负面
        return true
    end

    -- 免减益buff
    if self:checkHasOneBuffType(Fight.buffType_mianyijianyi) 
        and buffObj:checkIsJianyi()
    then
        return true
    end

    -- 抵抗增益
    if self:checkHasOneBuffType(Fight.buffType_dikangzengyi)
        and buffObj.kind == Fight.buffKind_hao
    then
        return true
    end

    return false
end
-- buffObj
-- 添加一个返回值，返回是否被添加了
function ObjectHero:setBuff(buffObj )
    local result = false

    if buffObj.runType == Fight.buffRunType_nRound then
        -- 标记buff当前加入的回合数
        buffObj.__currRound = self.__heroModel.controler.logical.roundCount
        if buffObj.expandParams and #buffObj.expandParams > 0 then
            buffObj.__nRound = buffObj.expandParams[1]
        else
            buffObj.__nRound = 1
        end
        table.insert(self.nextRoundBuffInfo,buffObj)
        echo("添加该延迟回合生效buff的标记")
        -- todo:添加加改buff的标记
        return result
    end

    local buffType = buffObj:sta_type()
    if not self.buffInfo[buffType] then
        self.buffInfo[buffType] = {}
    end
    local arr = self.buffInfo[buffType]

    -- self:doBuffPropChange(buffObj,1)

    --如果是马上执行的
    if buffObj.runType == Fight.buffRunType_now then
        -- 打上就又效果
        self:doBuffFunc(buffObj)
    end
    
    --如果次数为0 表示是一次性行为
    if buffObj.time == 0 then
        -- self:clearOneBuffObj(buffObj)
        -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
        return result
    end
    if self:hp() <= 0 and buffType ~= Fight.buffType_relive  then
        -- self:clearOneBuffObj(buffObj)
        -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
        return result
    end
    local length = #arr
    -- 判断是否可以叠加
    if length > 0 then

        if buffObj.coexist ~= 1 then -- 不强制共存的才需要检查同Id覆盖
            --相同id的buff直接移除
            for i=length,1,-1 do
                local tempObj = arr[i]
                --同一个hid的buff 直接后面覆盖前面的
                if tempObj:isValid() and tempObj.hid == buffObj.hid then
                    -- table.remove(arr,i)
                    echo("___同种Id buff 覆盖",buffObj.hid)
                    self:clearOneBuffObj(tempObj)
                    
                    self:sureInsertBuff( arr, buffObj )
                    result = true
                    -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
                    return result
                end
            end
        end

        --判断叠加方式
        local replace  = buffObj.replace
        --如果是并行的
        if replace == Fight.buffMulty_all then
            self:sureInsertBuff( arr, buffObj )
            result = true
        --如果是直接替换的
        elseif replace == Fight.buffMulty_replace  then
            --移除所有的老buff
            for i,v in ipairs(arr) do
                if v:isValid() then
                    self:clearOneBuffObj(v,nil,true)
                end
            end
            --清空数组
            -- table.clear(arr)
            self:sureInsertBuff( arr, buffObj )
            result = true
            -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
        --如果是比较剩余最大次数的/或保留最大回合数(buff不替换)
        elseif replace == Fight.buffMulty_max
            or replace == Fight.buffMulty_refresRound
        then
            local maxTime = 0
            local length = #arr
            local hasCompare = false
            for i=length,1,-1 do
                local obj = arr[i]
                -- 只比较生效的
                if obj:isValid() then
                    hasCompare = true 
                    --如果有 永久的同类型buff 那么不执行
                    if obj.time == -1 then
                        break
                    end
                    --如果新来的buff 次数大于老buff
                    if obj.time < buffObj.time or buffObj.time == -1 then
                        if replace == Fight.buffMulty_refresRound then
                            -- 只修改buff times
                            obj.time = buffObj.time
                        else
                            -- table.remove(arr,i)
                            self:clearOneBuffObj(obj)
                            self:sureInsertBuff( arr, buffObj )

                            result = true
                        end
                        
                        -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
                        break
                    end
                end
            end
            -- 如果都没有做过比较那么其他的应该都失效了应该直接添加
            if not hasCompare then
                self:sureInsertBuff( arr, buffObj )
                result = true
            end
            --如果没有替换成功 那么 直接清掉这个buff
            -- 没有被上过的buff应该不存在清理的逻辑2017.12.22
            -- self:clearOneBuffObj(buffObj)
            -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
        end
    else
        self:sureInsertBuff( arr, buffObj )
        result = true
        -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
    end

    return result
end

--做buff 飘字特效
--resist 表示被抵抗飘字
function ObjectHero:doBuffFlowEff(buffObj,resist,immune)
    if self.__heroModel.controler:isQuickRunGame()  
        or Fight.isDummy
    then
        return
    end

    -- 如果被免疫了（免疫飘字与其他配置无关）
    if immune then
        self.__heroModel:insterEffWord({1, Fight.wenzi_mianyi, Fight.buffKind_hao})
    end
    
    -- 如果被抵抗了（抵抗飘字与其他配置无关）
    if resist then
        self.__heroModel:insterEffWord({1, Fight.wenzi_dikang, Fight.buffKind_hao})
    end

    if buffObj:sta_flowWord() ~= 1 then
        return
    end 

    --判断是用哪种动画
    local kind = buffObj.kind
    local buffType = buffObj.type
    if kind == Fight.buffKind_aura or kind == Fight.buffKind_aurahuai   then
        echoWarn("光环不应该有,hid:",buffObj.hid)
        return
    end
    local frame,style = buffObj:getEffWordFrame() 
    if not frame then
        echoWarn("____这个buff 配置了飘字动画但是没有对应的帧数,",buffObj.hid,buffType)
        return
    end
    self.__heroModel:insterEffWord( {style, frame,kind})
end
  
--确认插入一个buff
function ObjectHero:sureInsertBuff( buffArr, buffObj )
    table.insert(buffArr, buffObj)

    self:countBuff(buffObj, 1)

    -- 如果是需要检查是否行动过的buff需要做一些处理 --
    if buffObj:needChkAction() then
        buffObj:setCanReduce(false)
        table.insert(self.chkActionBuff, buffObj)
    end

    -- 如果是需要检查是否行动过的buff需要做一些处理 --
    if not Fight.isDummy  then
        if not self.__heroModel.controler:isQuickRunGame() then
            --使用这个buff的最近一个动画
            self:useLastBuffAni(buffObj.type)
            -- 添加时做的飘字，即时作用的不在这里飘字
            if buffObj.runType ~= Fight.buffRunType_now then 
                self:doBuffFlowEff(buffObj)
            end
        end
        --如果是带滤镜样式的  那么 就配一个滤镜样式
        if buffObj:sta_style() then
            self.__heroModel:changeFilterStyleNums(buffObj:sta_style(),1)
        end
    end

    -- 改变属性
    self:doBuffPropChange(buffObj,1)
    -- 带有某些buff时，而不是在作用某种buff时需要处理一些事情
    if self.__heroModel then
        self.__heroModel:onOneBuffBeInsert(buffObj)
    end
    --发送buff改变事件
    self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )

end
-- 更新buff的显示、主要用于断线重连及追进度用
function ObjectHero:updateBuffs( )
    -- 同步身上buff的滤镜
    local buffInfo = self:getAllBuffs()
    for a,buffObj in pairs(buffInfo) do
        if buffObj:isValid() and buffObj:sta_aniArr() and (not buffObj.aniArr) then
            buffObj.aniArr = self.__heroModel:createEffGroup(buffObj:sta_aniArr(), 
                                                                true,true,buffObj.hero)
        end
    end
end
----------------------------------------------------------------------
---------------------清除buff-----------------------------------------
-- 获取所有buff
function ObjectHero:getAllBuffs()
    local result = {}
    for _,buffs in pairs(self.buffInfo) do
        if #buffs > 0 then
            for i=#buffs,1,-1 do
                local buff = buffs[i]
                if buff:isValid() then
                    table.insert(result, buff)
                end
            end
        end
    end

    return result
end
--清除一类buff  clearAura是否清除光环 默认是false
-- 这个方法不用了，统一使用 clearBuffByType 做清除
function ObjectHero:clearGroupBuff(buffType )
    -- 用已有方法重写一下
    -- 强制清除 不含光环 以前也没有处理光环类型，现在也没有需要暂不处理
    self:clearBuffByType(buffType, true)
end


--清除某一个buffid指定清理应该不需要考虑抵抗驱散,isRout是否以崩溃的形式清除
function ObjectHero:clearOneBuffByHid( buffHid,isRout )
    local flag = false
    for k,v in pairs(self.buffInfo) do
        local arr = v
        for i=#arr,1,-1 do
            local buffObj = arr[i]
            if buffObj:isValid() and buffObj.hid == buffHid then
                -- table.remove(arr,i)
                flag = true
                self:clearOneBuffObj(buffObj,isRout,true)
            end
        end
    end
    -- 最后一起发消息
    self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )

    return flag
end


--清除所有buff
function ObjectHero:clearAllBuff( handleClear )
    for buffType,arr in pairs(self.buffInfo) do
        if handleClear then
            for ii,vv in ipairs(arr) do
                vv:deleteMe()
            end
        else
            self:clearGroupBuff(buffType)
        end
        
    end
    -- self.buffInfo = {}
end
-- 清除所有光环对应的buff(此处不会发送BATTLEEVENT_ONBUFFCHANGE事件)
function ObjectHero:clearAllAuraBuff( )
    for buffType,arr in pairs(self.buffInfo) do
        if #arr > 0 then
            for _,buff in ipairs(arr) do
                if buff:isValid() and buff:checkIsAura() and 
                   (not buff.antiPurify) then
                    self:clearOneBuffObj(buff,nil,true)
                end
            end
        end
    end
end

--清除控制性的buff 
function ObjectHero:clearHandleBuff(  )
    --清除坏的光环
    self:clearBuffByKind(Fight.buffKind_huai )
end

--执行驱散
--@@force强制驱散，不考虑抵抗驱散
--@@isPurify 是否是驱散调用
function ObjectHero:clearBuffByKind( ty, force, isPurify )
    for k,v in pairs(self.buffInfo) do
        if #v > 0 then
            for i=#v,1,-1 do
                local info = v[i]
                -- 不抵抗驱散
                if info:isValid() and info.kind == ty and (not info.antiPurify or force) then
                    --清除这个buff的作用
                    -- table.remove(v,i)
                    self:clearOneBuffObj(info,nil,true,isPurify)
                end
            end
        end
    end
    self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
end

-- 根据buffType删除buff isRout是否以崩溃的形式清除
--@@isPurify 是否是驱散调用
function ObjectHero:clearBuffByType( buffType, force, isRout,isPurify )
    local buffArr = self.buffInfo[buffType]
    if not buffArr or (#buffArr==0) then
        return nil
    end

    for _,buff in ipairs(buffArr) do
        -- 有效并且不是光环
        if buff:isValid() and not buff:checkIsAura() and (not buff.antiPurify or force) then
            self:clearOneBuffObj(buff,isRout,true,isPurify)
        end
    end

    self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
end

--清除一个buffobj的效果
-- noEvent 不发buff变化消息
-- bePurify 被驱散的
function ObjectHero:clearOneBuffObj( buffObj,isRout,noEvent,bePurify)
    -- 当被驱散时
    if bePurify then
        buffObj:onBePurify()
    end

    -- 容错，如果已经失效了就不做相关内容
    if not buffObj:isValid() then return end

    -- 将buff状态置为失效
    buffObj:setValid(false)
    self:countBuff(buffObj, -1)

    local buffType = buffObj:sta_type()
    self:doBuffPropChange(buffObj,-1)
   
    --减少一次滤镜样式
    if buffObj:sta_style() then
        self.__heroModel:changeFilterStyleNums(buffObj:sta_style(),-1)
    end
    -- echo("清除某个buff",buffObj.hid)
    -- buff删除的时候可能触发特殊技能
    local specialSkill = self:getSpecialSkill()
    if specialSkill and specialSkill.skillExpand then
        specialSkill.skillExpand:onBuffBeClear(self.__heroModel, buffObj)
    end
    buffObj:clearBuff(isRout)

    self.__heroModel:onOneBuffClear(buffType)
    
    if not noEvent then
        --发送buff改变事件 通知血条变化
        self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
    end
end

--做buff属性变化事件 useWay 1 表示添加 -1表示清除
function ObjectHero:doBuffPropChange( buffObj,useWay )
    --判断是否加属性
    useWay = useWay or 1

    local buffType = buffObj.type
    local attrProp = Fight.buffMapAttrType[buffType]
    --如果是属性buff --那么直接修改属性 不用在每次获取属性的时候 修改属性了
    if attrProp then
        local result = true
        if buffObj.changeType == Fight.valueChangeType_attr then
            result,buffObj = Formula:_chkBuffValue(buffObj)
        end

        if not result then return end
        
        -- 添加时需要记录真实作用值,清除时直接使用此值返还，否则超出上/下限时会过量返还。
        if useWay == 1 then
            local value,realValue = nil,nil
            if buffObj.changeType == Fight.valueChangeType_num  then
                value,realValue = self:changeValue(attrProp, buffObj.value * useWay, buffObj.changeType)
            else
                --按比例的话需要除以100
                value,realValue = self:changeValue(attrProp, buffObj.value/10000 * useWay, buffObj.changeType)
            end
            buffObj.realValue = realValue
        elseif useWay == -1 then
            local realValue = buffObj.realValue
            if not realValue then
                echoError("为什么这个buff没有返还值",buffObj.hid)
                return 
            end
            self:changeValue(attrProp, realValue * useWay, Fight.valueChangeType_num)
        end
    end
end

----------------------------------------------------------------------
---------------------buff作用-----------------------------------------

--这里分化一些model的功能出来 是为了减轻 AutoFight的压力 主要分担的是 数据交互 以及buff这一块 因为涉及到数值

-- 检查怒气是否够
function ObjectHero:isEnergyEnough()
    if self.__heroModel then
        local energyControler = self.__heroModel.controler.energyControler
        return energyControler:isEnergyEnough(self.__heroModel:getEnergyCost(), self.__heroModel.camp)
    end
    
    return false
end
--判断能否释放大招或者法宝 普通攻击除外 --- 沉默的时候 
-- hasCheckSmall 不考虑普攻和是否能攻击
-- excludeEnergy 不考虑怒气
function ObjectHero:checkCanGiveSkill( hasCheckSmall,excludeEnergy )
    -- 沉默、傀儡、眩晕、冰冻、束缚、睡眠 状态的时候，不能释放大招
    local buffArr = {
        Fight.buffType_chenmo,
        Fight.buffType_kuilei,
        Fight.buffType_xuanyun,
        Fight.buffType_bingdong,
        Fight.buffType_shufu,
        Fight.buffType_sleep,
        Fight.buffType_bingfeng,
    }
    for k,v in pairs(buffArr) do
        if self:checkHasOneBuffType(v)  then
            return false
        end
    end
    -- if self:energy() < self:maxenergy() then
    --     return false
    -- end
    -- local energyControler = self.__heroModel.controler.energyControler

    -- if not energyControler:isEnergyEnough(self.__heroModel:getEnergyCost(), self.__heroModel.camp) then
    --     return false
    -- end
    -- 个别职业不能放大招
    local hero = self.__heroModel
    if hero and (hero:getHeroProfession() == Fight.profession_monster
            or hero:getHeroProfession() == Fight.profession_neutral
            or hero:getHeroProfession() == Fight.profession_obstacle)
    then
        return false
    end

    if not excludeEnergy then
        if not self:isEnergyEnough() then
            return false
        end
    end

    --如果是不能攻击的
    if not hasCheckSmall then
        if  not self:checkCanAttack() then
            return false
        end
    end

    return true
end

--判断本回合能否行动
function ObjectHero:checkCanAttack( isSpecielSkill  )
    if self:hp() <= 0 then
        return false
    end

    if not isSpecielSkill then
        --如果法宝是没有攻击技能的
        if not self.curTreasure.hasAttackSkill then
            return false
        end
    end
    
    if self:checkHasOneBuffType(Fight.buffType_bingdong) or  
        self:checkHasOneBuffType(Fight.buffType_xuanyun) or 
        self:checkHasOneBuffType(Fight.buffType_shufu) or 
        self:checkHasOneBuffType(Fight.buffType_mabi) or
        self:checkHasOneBuffType(Fight.buffType_sleep) or
        self:checkHasOneBuffType(Fight.buffType_bingfeng)
        then
        return false
    end

    --如果是不能放小技能 而且能量未满
    -- if self:checkHasOneBuffType(Fight.buffType_noSmallSkill ) then
    --     if not self:checkCanGiveSkill(true) then
    --         return false
    --     end
    -- end

    return true
end

--执行buff的函数
function ObjectHero:doBuffFunc( buffObj )
    local result = nil
    
    result,buffObj = Formula:_chkBuffValue(buffObj)

    if not result then
        echo("这个buff作用值处理有问题,hid:",buffObj.hid)
        return 
    end

    local buffType = buffObj.type
    local value = buffObj.value

    
    local changeType = buffObj.changeType or Fight.valueChangeType_num 
    if changeType == Fight.valueChangeType_ratio  then
        value = value /10000
    end

    value,changeType = self:checkBeforeDoBuff(buffObj)
    
    -- 使用buff的标志
    local useBuffFlag = true
    --如果是降低生命
    if Fight._BUFF_DOT[buffType] then
        if buffType == Fight.buffType_zhuoshao and self:checkHasOneBuffType(Fight.buffType_bingtai) then
            self:useBuffsByType(Fight.buffType_bingtai)
            -- 临时资源展示
            return
        end

        local changeNums,realChangeNum = self:changeValue(Fight.value_health,-value,changeType,0,nil,buffObj.atkType)

        local attacker = buffObj.hero or buffObj._backupHero
        StatisticsControler:statisticsdamage(attacker,self.__heroModel,buffObj.skill,-realChangeNum,-realChangeNum)
        self.__heroModel:createNumEff(changeNums < 0 and Fight.hitType_shanghai or Fight.hitType_zhiliao, changeNums)
        self.__heroModel:checkHealth(buffObj.hero)
    -- 生命恢复 
    elseif buffType == Fight.buffType_HOT then 
        local  changeNums = self:changeValue(Fight.value_health,value,changeType,0)
        self.__heroModel:createNumEff(Fight.hitType_zhiliao ,changeNums)
        self.__heroModel:checkHealth(buffObj.hero)

    --如果是复活
    elseif buffType == Fight.buffType_relive  then

    --如果是怒气（大）
    elseif buffType == Fight.buffType_nuqi  then
        if changeType == Fight.valueChangeType_num then
            local energyControler = self.__heroModel.controler.energyControler
            local etype = Fight.energy_entire
            -- 通过人物增长怒气
            energyControler:addEnergy(etype, value, self.__heroModel)

            if value > 0 then
                self.__heroModel:doGetEnergyEff(value)
            else -- 怒气减少的效果未定

            end
        else
            -- 怒气变化不提供百分比变化
            echoError("怒气buff:%s，怒气配置了百分比变化",buffObj.hid)
        end
    --如果是怒气（小）
    elseif buffType == Fight.buffType_nuqipiece then
        if changeType == Fight.valueChangeType_num then
            local energyControler = self.__heroModel.controler.energyControler
            local etype = Fight.energy_piece
            -- 通过人物增长怒气
            energyControler:addEnergy(etype, value, self.__heroModel)
        else
            -- 怒气变化不提供百分比变化
            echoError("怒气buff:%s，怒气配置了百分比变化",buffObj.hid)
        end
    elseif buffType == Fight.buffType_jinghua_hao then
        -- 净化掉坏的buff
        self.__heroModel.data:clearBuffByKind(Fight.buffKind_huai)
    elseif buffType == Fight.buffType_purify then -- 驱散（区别于上面的，这个是新加的，以前的保留）
        local p = buffObj.expandParams
        if p then
            if tonumber(p[1]) == 1 then -- 减益
                self:clearBuffByKind(Fight.buffKind_huai, false, true)
            elseif tonumber(p[1]) == 2 then -- 增益
                self:clearBuffByKind(Fight.buffKind_hao, false, true)
            elseif tonumber(p[1]) == 3 then -- 指定
                local buffs = {unpack(p,2)}
                for _,bt in ipairs(buffs) do
                    self:clearBuffByType(tonumber(bt), nil, nil, true)
                end
            end
        else
            echoError("此净化buff没有扩展参数",buffObj.hid)
        end
    elseif buffType == Fight.buffType_bingtai then
        echo("使用冰台buff=======")
    elseif buffType == Fight.buffType_sign then
        echo("被标记buff、实际上没有什么伤害")
    elseif buffType == Fight.buffType_bingfu then
        -- 检查冰符的触发
        useBuffFlag = buffObj:checkBingfuTrigger()
        -- 在触发方法里做减次处理/改了2018.05.11
        -- useBuffFlag = false
    elseif buffType == Fight.buffType_xingsuo then
        -- 检查刑锁触发
        useBuffFlag = buffObj:doXingsuoTrigger()
    elseif buffType == Fight.buffType_yanbo then
        -- 获取伤害和攻击者
        local dmg,attacker = buffObj:popYanboInfo()
        if dmg then
            local changeNums,realChangeNum = self:changeValue(Fight.value_health,-dmg,Fight.valueChangeType_num,0,nil,buffObj.atkType)
            StatisticsControler:statisticsdamage(attacker,self.__heroModel,buffObj.skill,-realChangeNum,-realChangeNum)
            self.__heroModel:createNumEff(Fight.hitType_shanghai ,changeNums)
            self.__heroModel:checkHealth(buffObj.hero)
        end
    else
        -- 目前走到else里证明这个buff没有被实际应用，只是加上了2017.6.26
        useBuffFlag = false
    end

    -- 表示此buff被用一次
    if useBuffFlag then
        buffObj:useBuff()
    end

    --判断是否有作用动画
    local useAniArr = buffObj:sta_useAniArr()
    if useAniArr then
        self.__heroModel:createEffGroup(useAniArr, false,true,self.__heroModel)
    end
    self:doBuffFlowEff(buffObj)
end

----------------------------------------------------------------------
---------------------获得信息-----------------------------------------
--判断是否中了从某人获得的某种buff
function ObjectHero:checkHasBuffFromOne(buffType, hero)
    local buffs = self:getBuffsByType(buffType)
    if not buffs then return false end

    for _,buff in pairs(buffs) do
        -- 是hero给的buff
        if buff.hero == hero then
            return true
        end
    end

    return false
end


-- 判断是否含有某种类型的buff
-- @@attacker buff的释放者
function ObjectHero:checkHasOneBuffType( buffType,attacker ) 
    -- 需要检查释放者，这样效率偏低
    if attacker then
        local buffs = self:getBuffsByType(buffType)
        if buffs then
            for _,bf in ipairs(buffs) do
                if bf.hero == attacker then
                    return true
                end
            end
        end

        return false
    else
        return self:getBuffNumsByType(buffType) > 0
    end
end

-- 判断是否含有某种kind的buff
function ObjectHero:checkHasOneBuffKind( kind )
    return self:getBuffNumsByKind(kind) > 0
end

-- 判断是否含有某种回合生效的buff
function ObjectHero:checkHasNextBuffType(buffType)
    for i,v in ipairs(self.nextRoundBuffInfo) do
        if v:sta_type() == buffType then
            return true
        end
    end
    return false
end

-- 标记某类型buff使用一次（返回是否使用成功）
function ObjectHero:useBuffsByType(buffType)
    local result = false

    local buffs = self:getBuffsByType(buffType)

    if buffs then
        result = true
        for _,buff in ipairs(buffs) do
            -- 标记使用一次buff
            buff:useBuff()
        end
    end

    return result
end

-- 根据buffType做buff的触发技能
function ObjectHero:doBuffTriggerFunc(buffType, params)
    local result = false

    local buffs = self:getBuffsByType(buffType)

    if buffs then
        result = false
        -- buff对应的需要执行的函数
        for _,buff in ipairs(buffs) do
            buff:doBuffTriggerFunc(unpack(params))
            buff:useBuff()
        end
    end

    return result
end

--[[
    获取一个buff的作用值
    要确定取的值得类型，如果同一个buff有多重作用类型（changeType）获取到的值就错了
    目前用到的地方取的都是作用值而非百分比
]]
function ObjectHero:getOneBuffValue( buffType )
    if not buffType then
        return 0
    end
    local buffArr = self:getBuffsByType(buffType)
    -- self.buffInfo[buffType]
    local value = 0
    if not buffArr or (#buffArr ==0) then
        return value
    end
    for i,v in ipairs(buffArr) do
        local num = v.value
        if not num then
            num = 0
            echoError("找策划buff:%s,没有获取到value",v.hid)
        end
        value  = value  + num
    end
    return value,buffArr
end

--[[
获取某种类型的buff 
]]
function ObjectHero:getBuffsByType(buffType)
    if not buffType then
        return nil
    end
    -- echo("#self.buffInfo",#self.buffInfo)
    -- local tab = table.keys(self.buffInfo)
    -- dump(tab)

    -- buffType = tonumber(buffType) 能保证的类型应该尽量减少不必要的转换
    -- 没有buff返回空
    if not self:checkHasOneBuffType(buffType) then return nil end    

    local buffArr = self.buffInfo[buffType]
    -- if not buffArr or (#buffArr==0) then
    --     return nil
    -- end
    local buffs = {}
    for k,v in ipairs(buffArr) do
        --echo("buffType === ",buffType,"=-========",v.type,v.type == buffType,"+++++++++")
        if v:isValid() and not v:checkIsAura() then
            table.insert(buffs,v)
        end
    end
    -- GameStatistics:statisticeCallTimes( "getBuffsByType" )
    return buffs
end

--[[
    获取某个种类的buff 好/坏 等
]]
function ObjectHero:getBuffsByKind( buffKind )
    local result = {}
    for _,buffs in pairs(self.buffInfo) do
        if #buffs > 0 then
            for i=#buffs,1,-1 do
                local buff = buffs[i]
                if buff:isValid() and buff.kind == buffKind then
                    table.insert(result, buff)
                end
            end
        end
    end

    return result
end

--[[
    获取某个种类的buff 数量
    @@exAntiPurify exculde 排除不可被驱散的buff（加这个参数后方法效率会大大降低）
]]
function ObjectHero:getBuffNumsByKind( buffKind, exAntiPurify )
    local allBuff = self.buffNums.kindNum[buffKind]

    -- 不需要排除不可驱散的buff或总量为0直接返回
    if not exAntiPurify or allBuff == 0 then return allBuff end

    local result = 0
    for _,buffs in pairs(self.buffInfo) do
        for _,bf in ipairs(buffs) do
            -- bf有效、类型相符、可驱散
            if bf:isValid() 
                and bf.kind == buffKind 
                and not bf.antiPurify
            then
                result = result + 1
            end
                
        end
    end

    return result
end

--[[
    获取某个buff类型的数量
]]
function ObjectHero:getBuffNumsByType(buffType)
    -- local buffArr = self.buffInfo[buffType]
    -- if buffArr then
    --     return #buffArr
    -- end

    -- return 0

    return self.buffNums.typeNum[buffType] or 0
end

--获取身上的buff数量
function ObjectHero:getBuffNums(  )
    -- local nums = 0
    -- for k,v in pairs(self.buffInfo) do
    --     nums = nums + #v
    -- end
    -- return nums

    return self.buffNums.allNum
end


--是否有某种 kind buff 
function ObjectHero:checkHasKindBuff(buffKind)
    -- for k,v in pairs(self.buffInfo) do
    --     if #v > 0 then
    --         for i=#v,1,-1 do
    --             local info = v[i]
    --             if info.kind == kind  then
    --                 return true
    --             end
    --         end
    --     end
    -- end
    -- return false

    return self.buffNums.kindNum[buffKind] > 0
end

--根据hid获取buff
function ObjectHero:getBuffByHid(buffHid)
    for k,v in pairs(self.buffInfo) do
        if #v > 0 then
            for i=#v,1,-1 do
                local info = v[i]
                if info:isValid() and info.hid == buffHid then
                    return info
                end
            end
        end
    end
    return nil
end

-- 判断是否是延迟一回合执行的buff并且当前生效
function ObjectHero:checkIsNextRoundAndDo(info )
    if info.runType == Fight.buffRunType_nRound then
        local nowRound = self.__heroModel.controler.logical.roundCount
        if info.__currRound and (info.__currRound + 3 * info.__nRound == nowRound) then -- 当前是敌方回合，所以切换至生效回合就是+3
            return true
        end
    end
    return false
end

-----------------------------------------------------------------------------------------
--------------------------刷新buff-------------------------------------------------------
--刷新函数目前主要是更新buff 回合前执行的buff
function ObjectHero:updateRoundFirst(  )
    local info 
    for i=#self.nextRoundBuffInfo,1,-1 do
        info = self.nextRoundBuffInfo[i]
        if self:checkIsNextRoundAndDo(info) then
            --直接将下回合执行修改为本回合执行，并且执行一次setBuff,然后从本数组移除
            info.runType = buffRunType_round 
            -- todo:移除回合执行buff标记
            echo("移除回合执行buff标记--",info.hid)
            self:setBuff(info)
            table.remove(self.nextRoundBuffInfo,i)
        end
    end
    --先将需要操作的元素取出来再进行遍历，否则在pairs遍历过程中改变了self.buffInfo会导致同一个元素多次遍历
    local t = {}
    for _,v in pairs(self.buffInfo) do
        table.insert(t, v)
    end
    --回合前只负责执行buff
    for _,v in ipairs(t) do
        --更新buff
        if #v > 0 then
            for i=#v,1,-1 do
                info = v[i]
                if info and info:isValid() and info.runType == Fight.buffRunType_round  then
                    -- 死了才有复活的事（删除复活的buff真正的复活逻辑在doReliveAction里做）
                    if info.type == Fight.buffType_relive then
                        if self.__heroModel.hasHealthDied then
                            -- self:doBuffFunc(info)
                            -- table.remove(v,i)
                            -- self:clearOneBuffObj(info)
                            --发送buff改变事件 通知血条变化
                            -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
                        end
                    else
                        self:doBuffFunc(info)
                    end
                end   
            end
        end
    end

    -- 回合前重置状态
    self:updateChkActionBuffRoundFirst()
end

--[[
    清理已经失效的buff 只要是失效的都清理，不管是buff还是光环
    此时buff相关逻辑已经做完，统一删除不会出现破坏循环的问题
]]
function ObjectHero:clearUnValidBuff()
    for _,buffs in pairs(self.buffInfo) do
        for i,buffObj in ripairs(buffs) do
            -- 已经失效
            if not buffObj:isValid() then
                table.remove(buffs, i)
            end
        end
    end
    -- 这个表也要维护一下
    for i,buffObj in ripairs(self.chkActionBuff) do
        -- 已经失效
        if not buffObj:isValid() then
            table.remove(self.chkActionBuff, i)
        end
    end
end

--回合后执行做的事情  主要是更新buff次数
function ObjectHero:updateRoundEnd(  )
    -- 回合结束后，处理一下检查行动行为的buff的状态
    self:updateChkActionBuffRoundEnd()
    --检查坏buff次数
    self:checkReduceBuff(Fight.buffKind_huai)

    -- 中性buff暂定在这里减
    self:checkReduceBuff(Fight.buffKind_neutral)

    -- 每个我方的回合结束后清理一波失效buff
    self:clearUnValidBuff()
end

--地方回合结束后我方做什么事情 需要减少正面buff的次数
function ObjectHero:updateToRoundEnd(  )
    --检查好buff次数
    self:checkReduceBuff(Fight.buffKind_hao)
end

--检查某种kind buff的次数 -1
function ObjectHero:checkReduceBuff( kind )
    local info = nil
    for k,v in pairs(self.buffInfo) do
        --更新buff
        if #v > 0 then
            for i=#v,1,-1 do
                info = v[i]
                if info:isValid() 
                    and info.time > 0 
                    and info:canReduce()
                    and info.kind == kind
                then
                    info.time = info.time - 1 
                    if info.time ==0 then
                        --移除这个数组
                        -- table.remove(v,i)
                        --清除这个效果
                        self:clearOneBuffObj(info)
                        --发送buff改变事件 通知血条变化
                        -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
                        self:useLastBuffAni(k)
                    end
                end
            end
        end 
    end
end
-- 根据kind延长某种类型buff的生效回合 +1
function ObjectHero:extendBuffByKind( kind,exRound )
    exRound = exRound or 1
    local buffs = self:getBuffsByKind(kind)
    if buffs then
        for _,buff in ipairs(buffs) do
            if buff.runType == Fight.buffRunType_round then
                buff.time = buff.time + exRound
            end
        end
    end
end
-- 根据buffType延长buff的生效回合
function ObjectHero:extendBuffByType( buffType,exRound )
    exRound = exRound or 1
    local buffs = self:getBuffsByType(buffType)
    if buffs then
        for _,buff in ipairs(buffs) do
            if buff.runType == Fight.buffRunType_round then
                buff.time = buff.time + exRound
            end
        end
    end
end

--使用某种buff的最后一个特效
function ObjectHero:useLastBuffAni( buffType,isDelay )
    if Fight.isDummy  then
        return
    end
    local buffArr = self.buffInfo[buffType]
    local buffObj
    local lastIndex 
    local needDelay
    if buffArr and  #buffArr >= 1  then
        for i =#buffArr, 1,-1 do
            buffObj = buffArr[i]
            if buffObj:isValid() then
                local aniArr = buffObj.aniArr
                if aniArr then
                    if not lastIndex then
                        lastIndex = i
                        for ii,vv in ipairs(aniArr) do
                            if needDelay then
                                vv.myView:visible(false)
                                vv.myView:stop()
                            else
                                vv.myView:visible(true)
                                vv.myView:play()
                            end
                            
                        end
                    else
                        for ii,vv in ipairs(aniArr) do
                            vv.myView:visible(false)
                            vv.myView:stop()
                        end
                    end
                end
            end
        end
    end
end

--隐藏某种buff的动画
function ObjectHero:hideOneBuffAni( buffType )
    local buffArr = self.buffInfo[buffType]
    local buffObj
    if buffArr and  #buffArr >= 1  then
        for i =#buffArr, 1,-1 do
            buffObj = buffArr[i]
            local aniArr = buffObj.aniArr
            if aniArr then
                for ii,vv in ipairs(aniArr) do
                    vv.myView:visible(false)
                    vv.myView:stop()
                end
            end
        end
    end
end


function ObjectHero:getAllBuffIcons(  )
    local iconGroups = {}
    for i,v in pairs(self.buffInfo) do
        for ii,vv in pairs(v) do
            --必须有icon 而且不是光环
            if vv:isValid() and vv:sta_icon()  and not vv:checkIsAura() then
                table.insert(iconGroups, { icon = vv:sta_icon(),id = vv.hid })
            end
        end
    end
    --

    return iconGroups
end



--事件-----------

function ObjectHero:checkChanceTrigger( event )
    --[[
    这样取主角法宝里的被动取不到
    for i=1,5 do
        local skill = self.curTreasure["skill"..i]
        if skill then
            -- echo(skill.heroModel,self.__heroModel.camp, self.rid,skill.hid,"_______判定事件")
            skill:checkChanceTrigger(event)
            --如果是有技能扩展的

        end
    end
    ]]
    local skills = self:getAllSkills(5)
    for _,skill in ipairs(skills) do
        skill:checkChanceTrigger(event)
    end
end

function ObjectHero:beKill(  )
    return self.datas.beKill 
end


--是否有大招
function ObjectHero:hasMaxSkill(  )
    if self.curTreasure.skill3 then
        return true
    end
    return false
end

--当释放小技能的时候
function ObjectHero:onGiveSmallSkill(  )
    --让当前值为0
    if self.skillRatioParams then
        self.skillRatioParams.current = 0
    end
    
end

-- 获取所有技能
--[[
    skillIdx 表示要取得skill的最大idx
]]
function ObjectHero:getAllSkills(skillIdx)
    local result = nil
    --主角的技能是素颜的小技能和法宝的其他技能
    if self.isCharacter then
        local max = skillIdx or Fight.maxSkillNums
        result = {}
        table.insert(result, self.treasures[1].skill2)
        for i=3,max do
            local skill = self.treasures[2]:getSkill(i)
            if skill then
                table.insert(result, skill)
            end
        end
    else
        result = self.curTreasure:getAllSkills(skillIdx)
    end
    
    return result
end

--获取特殊技（被动）
function ObjectHero:getSpecialSkill(  )
    local result
    -- 主角被动取法宝1的
    if self.isCharacter then
        result = self.treasures[2].skill4
    else
        result = self.curTreasure.skill4
    end

    return result
end

--获取某个技能
function ObjectHero:getSkillByIndex( index )
    if index == Fight.skillIndex_max  then
        if self.curTreasure.inSkill then
            return self.curTreasure.inSkill
        end
    end
    return self.curTreasure:getSkill(index)
end

--获取回合换法宝信息
function ObjectHero:getRoundTreasure(  )
    return self.datas.roundTreasure
end

--[[
    buff计数
    buffObj 是buff对象
    ctype 计数类型 1 增加 -1 减
]]
function ObjectHero:countBuff(buffObj, ctype)
    if not buffObj or not ctype then return end

    local buffType = buffObj.type
    local buffKind = buffObj.kind

    local typeNum = self.buffNums.typeNum[buffType]
    local kindNum = self.buffNums.kindNum[buffKind]
    local allNum = self.buffNums.allNum

    if not typeNum then typeNum = 0 end

    -- 不是光环才会做统计
    if not buffObj:checkIsAura() then
        typeNum = typeNum + ctype
        allNum = allNum + ctype
    end

    kindNum = kindNum + ctype

    if typeNum < 0 then
        echoError("手动报错，这里typeNum不应该小于0,hid:",buffObj.hid)
        typeNum = 0
    end

    if kindNum < 0 then
        echoError("手动报错，这里kindNum不应该小于0,hid:",buffObj.hid)
        kindNum = 0
    end

    if allNum < 0 then
        echoError("手动报错，这里allNum不应该小于0,hid:",buffObj.hid)
        allNum = 0
    end
    self.buffNums.typeNum[buffType] = typeNum
    self.buffNums.kindNum[buffKind] = kindNum
    self.buffNums.allNum = allNum
end
--[[
    改变所有需要检查行动行为的buff的可减回合状态
]]
function ObjectHero:setChkActionBuffState(value)
    for _,buffObj in ipairs(self.chkActionBuff) do
        if buffObj:isValid() then
            buffObj:setCanReduce(value)
        end
    end
end
-- 回合开始前更新需要检查行动行为的buff得可减回合状态
function ObjectHero:updateChkActionBuffRoundFirst()
    self:setChkActionBuffState(false)
end
-- 回合结束后更新需要检查行动行为的buff得可减回合状态
function ObjectHero:updateChkActionBuffRoundEnd()
    -- 不能攻击被控的情况下，将buff状态置为可减
    if not self:checkCanAttack() then
        self:setChkActionBuffState(true)
    end
end
-- 获取角色当前法宝对应的sourceId
function ObjectHero:getCurrTreasureSourceId( )
    return self.curTreasure:sta_source()
end
-- 获取角色当前法宝对应的性别
function ObjectHero:getCurrTreasureSex( )
    return self.curTreasure:sta_sex()
end
-- 获取角色对应的头像信息
function ObjectHero:getIcon()
    return self.curTreasure:sta_icon()
end
-- 获取boss血条上的头像
function ObjectHero:getHeadIcon( )
    return self.curTreasure:sta_head()
end
-- 获取角色对应的名字
function ObjectHero:getName( )
    local name = self.curTreasure:sta_name() or ""
    if not Fight.isDummy then
        if name == "" then
            name = GameConfig.getLanguage("tid_common_2006")
        else
            name = GameConfig.getLanguage(name)
        end
    end
    return name
end

function ObjectHero:hasNotAliveBuff()
    return (self:checkHasOneBuffType(Fight.buffType_kuilei) or self:checkHasOneBuffType(Fight.buffType_tag_mubei))
end
--[[
    返回是否免疫某种伤害
    return 是否免疫,免疫原因
]]
function ObjectHero:isImmnueDmg(atkType,skillIndex)
    local result = false
    local reason = nil

    if not result and self.__heroModel and self.__heroModel:isPet() then
        result = true
        reason = {pet = true}
    end

    -- 壁障
    if not result and self.__heroModel and self.__heroModel:getHeroProfession() == Fight.profession_obstacle then
        result = true
        reason = {profession = self.__heroModel:getHeroProfession()}
    end

    -- 伤害免疫buff，并且不是纯粹伤害（注意Fight.atkType_pure 类型不开放给策划）
    if not result and 
        self:checkHasOneBuffType(Fight.buffType_mianyidmg) 
        and not (atkType and Fight.atkType_pure == atkType)
    then
        result = true
        reason = {atkType = atkType, buffType = Fight.buffType_mianyidmg}
    end

    -- 伤害类型判断
    if not result and atkType then
        -- 物理免疫
        if atkType == Fight.atkType_wu and self:checkHasOneBuffType(Fight.buffType_wumian) then
            result = true
            reason = {atkType = atkType, buffType = Fight.buffType_wumian}
        end
        -- 法术免疫
        if atkType == Fight.atkType_fa and self:checkHasOneBuffType(Fight.buffType_famian) then
            result = true
            reason = {atkType = atkType, buffType = Fight.buffType_famian}
        end
    end

    -- 技能类型判断
    if not result and skillIndex then
        -- 普通仙术免疫
        if skillIndex == Fight.skillIndex_small and self:checkHasOneBuffType(Fight.buffType_mianyiputong) then
            result = true
            reason = {skillIndex = skillIndex, buffType = Fight.buffType_mianyiputong}
        end
    end

    -- 无敌调试开关
    if not result and ((self.__heroModel and self.__heroModel.camp == Fight.escape_damage) or Fight.escape_damage == 3) then
        result = true
        reason = {debug = true}
    end

    return result,reason
end
-- 在buff作用前检查影响buff的其他影响因素返回新的作用值和作用类型
-- return value,changeType
function ObjectHero:checkBeforeDoBuff(buffObj)
    local changeType = buffObj.changeType or Fight.valueChangeType_num
    local value = buffObj.value
    local buffType = buffObj.type
    
    if changeType == Fight.valueChangeType_ratio  then
        value = value /10000
    end
    
    -- 检查边界限定
    if buffObj.valueLimit then
        -- 这个地方值拿血量处理，因为底下changevalue都是对血量的处理
        local baseValue = self:getInitValue(Fight.value_health)
        local tmpValue = buffObj:getEffValue(baseValue)
        local newValue = Formula:getBuffLimitDmg(buffObj,tmpValue)
        if tmpValue ~= newValue then
            -- 如果扣血限制了，那直接将状态都修改为按照数值计算
            changeType = Fight.valueChangeType_num 
            value = newValue
            echo("buff扣血有限制",tmpValue,newValue)
        end
    end

    -- 降低生命值的buff
    if Fight._BUFF_DOT[buffType] then
        -- 处理持续类型buff的加强
        if buffObj.runType == Fight.buffRunType_round then
            -- 有重创buff
            local exRate = self:getOneBuffValue(Fight.buffType_zhongchuang)
            if exRate ~= 0 then
                -- 如果是百分比类型的就先转换一下
                if changeType == Fight.valueChangeType_ratio then
                    local baseValue = self:getInitValue(Fight.value_health)
                    value = math.round(buffObj:getEffValue(baseValue))
                    changeType = Fight.valueChangeType_num
                end
                echo("受到重创加成", exRate)
                value = value + math.round(value * exRate / 10000)
            end
        end
    end
    -- 检查是否有额外的buff伤害加成
    local expBuffArr = self.__heroModel.controler:getExpecialBuffArr()
    if expBuffArr then
        for k,v in pairs(expBuffArr) do
            if v.kName == Fight.value_buffBleeding and
             buffType == Fight.buffType_liuxue then
                 -- 如果是百分比类型的就先转换一下
                 if changeType == Fight.valueChangeType_ratio then
                    local baseValue = self:getInitValue(Fight.value_health)
                    value = math.round(buffObj:getEffValue(baseValue))
                    changeType = Fight.valueChangeType_num
                end
                echo("仙盟探索流血额外的伤害加成",value,math.round(value * v.value / 10000))
                value = value + math.round(value * v.value / 10000)
            end
            if v.kName == Fight.value_buffBurn and
             buffType == Fight.buffType_zhuoshao then
                 -- 如果是百分比类型的就先转换一下
                 if changeType == Fight.valueChangeType_ratio then
                    local baseValue = self:getInitValue(Fight.value_health)
                    value = math.round(buffObj:getEffValue(baseValue))
                    changeType = Fight.valueChangeType_num
                end
                echo("仙盟探索灼烧额外的伤害加成",value,math.round(value * v.value / 10000))
                value = value + math.round(value * v.value / 10000)
            end
        end
    end

    -- 检查脚本
    local specialSkill = self:getSpecialSkill()

    if specialSkill and specialSkill.skillExpand then
        value,changeType = specialSkill.skillExpand:onBuffBeDo(value, changeType, buffObj)
    end

    return value,changeType
end
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--清除
function ObjectHero:clear(  )
    self:clearAllBuff(true)
    self:clearAllEvent()
    self.__heroModel = nil
    --移除注册的
    FightEvent:clearOneObjEvent(self)
end

function ObjectHero:tostring(  )
    local attr =  "Heroes--id:"..self.hid..",maxhp:"..self.maxhp..",hp:"..self:hp()..",atk:"..self:atk()..",def:"..self:def()..",crit:"..self:crit()..",hit:"..self:hit()
    echo(attr)
end

return  ObjectHero
