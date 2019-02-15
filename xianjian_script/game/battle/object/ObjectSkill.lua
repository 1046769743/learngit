--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--
local Fight = Fight
-- local BattleControler = BattleControler
local globalCfgKey = {
    "hid","name","lock","appear","pos",
    "atkOffset","action",
    "enterType","aniArr","audioInfo","atkInfoA1",
    "blackFrame",
    "cameraSpineParams","cameraSpineExpand","cameraUIArr","atkType","injCond",
    "canCrit","expand","passiveTrig",
    "passiveParams","xRange","helpSkill","artifactSkill"

}
ObjectSkill = class("ObjectSkill")
ObjectCommon.mapFunction(ObjectSkill,globalCfgKey)
--实例属性
ObjectSkill.__originData = nil -- 原始数据
ObjectSkill.action = "attack"
ObjectSkill.attackInfos = nil

ObjectSkill.__treasure = nil -- 当前技能属于哪个法宝， 不需要备份

ObjectSkill.__alertEff = nil --境界区域特效
ObjectSkill.__skillEffArr = nil
ObjectSkill.__summonInfo = nil


--需要执行的skillAi对象
ObjectSkill.skillExpand = nil 

--起始的xindex,后面的攻击包都需要根据这个来向后推移 1 2 3 对应左中右
ObjectSkill.startXIndex = 1
--起始的yIndex 1 是上 2 是下 
ObjectSkill.startYIndex = 0
ObjectSkill.yChooseType = 0
ObjectSkill.xChooseArr = nil
ObjectSkill.skillIndex = 0
--[[
--技能的数值参数  是一个数组
skillParams:

]]

ObjectSkill.damageR = 1     --技能伤害系数
ObjectSkill.damageN = 0     --技能伤害常量
ObjectSkill.treaR = 1       --治疗百分比
ObjectSkill.treaN = 0       --治疗系数

ObjectSkill.firstHeroPosIndex = 1   --技能找到的第一个英雄 坐标

ObjectSkill.hasSummonInfo = nil        --是否有召唤信息

ObjectSkill.showTotalDamage = true     --是否显示总伤害（默认显示）

ObjectSkill.isAttackSkill = false       --是否是攻击性技能

ObjectSkill.speciaFilterAtkData = nil       --带特殊筛选的atk, 用来决定技能占位的依据

ObjectSkill.helpSkillAtk = nil -- 协助技

ObjectSkill.skillFrame = nil -- 技能帧长度（取决于释放技能的人物的动作长度，在第一次取值时会做缓存）

ObjectSkill.isStitched = false -- 作为拼接技能的技能（和前面的技能视为同一个技能）

ObjectSkill.appointChooseArr = nil -- 钦定攻击范围（有些要求要攻击指定的人又不好扩展filterAi）

ObjectSkill.skillFrameArr = nil -- 技能帧事件，以前只有攻击包直接用attackInfos来完成，现在引入脚本的时间，新加一个字段

function ObjectSkill:ctor( hid,origin, charIdx,skillParams )
    self.hid = hid    
    self.__originData = origin
    -- dump(origin,"origin =========")
    self.__staticData = ObjectCommon.getPrototypeData( "battle.Skill",hid )

    self.attackInfos = {}
    self.audioInfos = {}
    self.skillFrameArr = {}
    self.skillParams = skillParams

    self.hasSummonInfo = false
    self.isAttackSkill = false
    local atkInfos = self["sta_atkInfo"..charIdx](self)
    if atkInfos then
        if type(atkInfos) ~= "table" then
            echoError("找战斗策划，skill:%d的atkInfos%s配置的不是数组",self.hid,charIdx)
        end
        for i,v in ipairs(atkInfos) do
            table.insert(self.attackInfos,{Fight.skill_type_attack,v.fm,v.at})
        end
    end

    local audioInfos = self:sta_audioInfo()
    if audioInfos then
        if type(audioInfos) ~= "table" then
            echoError("找战斗策划，skill:% audioInfos配置的不是数组",self.hid)
        end
        for k,v in pairs(audioInfos) do
            table.insert(self.audioInfos, {v.fm, v.ad})
        end
    end

    if #self.skillParams < 4 then
        echoError("找策划,技能id:%s的技能参数数量不对",hid)
    end

    --[[
        --伤害系数
        self.damageR = self.skillParams[1]
    
        --伤害常量
        self.damageN = self.skillParams[2]
        --治疗系数
        self.treaR = self.skillParams[3]
        --治疗常量
        self.treaN = self.skillParams[4]
    ]]
    -- 作用技能参数中的前四个
    self:updateSkillParams()

    --x方向范围
    self.xRange = self:sta_xRange() or 1
    --协助技
    if self:sta_helpSkill() then
        self.helpSkillAtk = ObjectAttack.getAtkObjByHid(self:sta_helpSkill())
    end
    
    self:update(datas)

    self:initSkill()

    --如果是有技能扩展的
    if self:sta_expand() then
        local expandInfo  = self:sta_expand() 
        local id  = expandInfo[1]

        local fileName = "game/battle/skillAi/"..id .. ".lua"
        local luaFile =  "game.battle.skillAi."..id
        --先判断是否存在
        if Fight.isDummy  then
            local objClass
            local errorFunc = function ( msg )
            end
            local tempFunc = function (  )
                objClass = require(luaFile)
            end
            xpcall(tempFunc, errorFunc)
            if not objClass then
                echoError("fileName：",fileName,"没有给出返回值")
            else
                self.skillExpand = objClass.new(self,unpack(expandInfo))
            end
        else
            if cc.FileUtils:getInstance():isFileExist(fileName) then
                local objClass = require(luaFile)
                self.skillExpand = objClass.new(self,unpack(expandInfo))
            else 
                echoError("_找策划_这个技能扩展id没有找到对应的文件,skillId,%s,expandId:%s",self.hid,id)
            end
        end
        
    end
    -- 攻击类型
    self.atkType = self:sta_atkType() or 1
    -- 在技能序列中插入技能扩展中可能注册的帧函数
    self:checkSkillExpandFrameFunc()
end

-- 在技能序列中插入技能扩展中可能注册的帧函数
function ObjectSkill:checkSkillExpandFrameFunc()
    local skillFunc = nil
    if self.skillExpand and not empty(self.skillExpand:getAllSkillFunc()) then
        skillFunc = self.skillExpand:getAllSkillFunc()
    else
        -- 没有技能序列直接使用攻击包
        self.skillFrameArr = self.attackInfos
        return
    end

    local i,j = 1,1
    local frame1,frame2 = nil,nil
    -- 合并两个有序数组
    while i <= #self.attackInfos or j <= #skillFunc do
        frame1 = self.attackInfos[i] and self.attackInfos[i][2] or nil
        frame2 = skillFunc[j] and skillFunc[j].frame or nil
        if not frame1 then 
            self.skillFrameArr[#self.skillFrameArr + 1] = skillFunc[j]
            j = j + 1
        elseif not frame2 then
            self.skillFrameArr[#self.skillFrameArr + 1] = self.attackInfos[i]
            i = i + 1
        
        elseif frame1 <= frame2 then
            self.skillFrameArr[#self.skillFrameArr + 1] = self.attackInfos[i]
            i = i + 1
        else
            self.skillFrameArr[#self.skillFrameArr + 1] = skillFunc[j]
            j = j + 1
        end
    end
end

--[[
    设置技能参数
    exlvl == 0 时为还原，不用读传进来的
]]
function ObjectSkill:setSkillParams( exlvl,skillParams )
    if exlvl == 0 then
        self.skillParams = self.__originData.skillParams or self.skillParams

        self:updateSkillParams()
    else
        if skillParams and type(skillParams) == "table" then
            self.skillParams = skillParams
        end

        self:updateSkillParams()
    end
end
--[[
    更新技能参数
    使用 self.skillParams 更新
]]
function ObjectSkill:updateSkillParams()
    --伤害系数
    self.damageR = self.skillParams[1]

    --伤害常量
    self.damageN = self.skillParams[2]
    --治疗系数
    self.treaR = self.skillParams[3]
    --治疗常量
    self.treaN = self.skillParams[4]
end

-- 设置一下原始数据
function ObjectSkill:setOriginalData(origin)
    if not origin then return end
    
    self.__originData = origin
end

-- 获取原始数据
function ObjectSkill:getOriginData()
    return table.copy(self.__originData)
end

--[[
    取技能参数的方法
    2017.10.14
    这个方法之前代码里有，但是奇怪没有实现
    这里改变传参方式，顺便实现出来

    value 约定值为"p+number"开头的字符串时认为是需要传参的
    logs 传入的log方便错误时找错用
]]
function ObjectSkill:getSkillParamsByValue(value,logs)
    local result = value
    local idx = nil
    local str = logs or ""

    -- 如果是数值直接返回
    if tonumber(value) then
        return tonumber(value)
    end
    
    if string.find(value, "p") then
        idx = tonumber(string.sub(value,2,-1))
    else
        echoError(str .. " getSkillParamsByValue不满足需求的传入参数:%s",value)
    end
    

    if idx then
        local p = self.skillParams[idx]
        if p then
            result = tonumber(p)
        else
            echoError(str .. " skillParams没有第%s个技能参数",idx)
        end
    end

    return result
end

--初始化技能属性
function ObjectSkill:initSkill(  )
end

--更行技能
function ObjectSkill:update( datas )
    for i,v in pairs(self.attackInfos) do
        v[3] = ObjectAttack.getAtkObjByHid(v[3])

        if v[3].filterObj and v[3]:sta_useWay() == 2 then
            --记录下第一个带特殊筛选的atk
            if not self.speciaFilterAtkData  then
                self.speciaFilterAtkData = v[3]
            end
        end
    end

    --这里需要遍历所有的攻击包  来判断下
    self.xChooseArr = {}
    self.yChooseType = 0
    self.isAttackSkill = false

    local yIndexMap = {}


    --把攻击包按时间顺序排序
    local sortFunc = function ( info1,info2 )
        return info1[2] < info2[2]
    end

    local cloneAtkInfo = table.copy (self.attackInfos)
    table.sort(cloneAtkInfo,sortFunc)

    for i,v in ipairs(cloneAtkInfo) do
        if v[1] == Fight.skill_type_attack  then
            local atkData = v[3]
            local xArr =atkData.xChooseArr
            -- 非伤害的攻击包但是对敌的也需要攻击范围
            if atkData:sta_dmg() or atkData:sta_useWay() == 2 then
                --找到所有的攻击包 合并他的选择范围
                for ii,vv in ipairs(xArr) do
                    if not table.indexof(self.xChooseArr, vv) then
                        table.insert(self.xChooseArr, vv)
                    end
                end
                if not yIndexMap[atkData.yChooseType] then
                    yIndexMap[atkData.yChooseType] = true
                end
                -- if self.yChooseType == 0 then
                --     self.yChooseType = atkData.yChooseType
                -- end
                self.isAttackSkill = true
            end
            --如果是有召唤的
            if atkData:sta_summon() then
                self.hasSummonInfo =true
            end

        end
    end

    --如果是有打上下排的
    if yIndexMap[0] then
        self.yChooseType = 0
    --如果既有上 又有下的
    elseif yIndexMap[1] and yIndexMap[2] then
        self.yChooseType = 0
    --否则只打对位的y
    elseif yIndexMap[2] then
        self.yChooseType = 2
    elseif yIndexMap[3] then
        self.yChooseType = 3
    end

    --在把xchooseArr排序
    table.sort(self.xChooseArr)
    --那么固定插入一个 表示这是只会作用在己方身上的
    if #self.xChooseArr == 0 then
        table.insert(self.xChooseArr, 1)
    end
    --倒着遍历attackInfos 找到最后一个攻击包
    local info
    --判断是不是最后一个攻击包
    for i=#cloneAtkInfo,1,-1 do
        info = cloneAtkInfo[i]
        if info[1] == Fight.skill_type_attack then
            local atkData = info[3]
            --必须是作用在敌方的 而且是伤害性的攻击包
            if atkData:sta_dmg() then
                atkData.isFinal = true
                break
            end
        end
    end
    --判断是不是第一个攻击包
    for i=1,#cloneAtkInfo do
        info = cloneAtkInfo[i]
        if info[1] == Fight.skill_type_attack then
            local atkData = info[3]
            --必须是作用在敌方的 而且是伤害性的攻击包
            if atkData:sta_dmg() then
                atkData.isFirst = true
                break
            end
        end
    end

    --初始化攻击包伤害系数
    self:initAtkDmgRatio()

    
    --重新缓存排序后的攻击序列
    self.attackInfos = cloneAtkInfo
end

--计算攻击包伤害系数
function ObjectSkill:initAtkDmgRatio(  )
    local index = 1
    local percentInfoArr = {

    }

    for k,v in ipairs(self.attackInfos) do
        local atkData = v[3]
        if not percentInfoArr[index] then
            percentInfoArr[index] = {0,0 }
        end
        local infoArr = percentInfoArr[index]
        if atkData:sta_dmg() then
            infoArr[1] = infoArr[1] + atkData:sta_dmg()
        end

        -- 这个写在外面是顺便给个初始值
        atkData.__tempValueIndex = index
        
        --如果是最后一个攻击包
        if atkData.isFinal then
            index = index +1
        end
    end

    index = 1
    -- 治疗单独计算一次
    for k,v in ipairs(self.attackInfos) do
        local atkData = v[3]
        if not percentInfoArr[index] then
            percentInfoArr[index] = {0,0 }
        end

        local infoArr = percentInfoArr[index]
        --如果是治疗的
        if atkData:sta_addHp() then
            infoArr[2] = infoArr[2] + atkData:sta_addHp()
            -- 这里写在里面是为了不覆盖dmg攻击包的值
            atkData.__tempValueIndex = index
        end
        
        --如果是治疗分割（最后一个）
        if atkData.isTreatFinal then
            index = index +1
        end
    end

    local function dmgFunc( per, base, isFinal )
        if isFinal then
            -- @@accuDmg 累加伤害
            -- @@totalDmg 总伤害
            return function ( totalDmg, accuDmg )
                local nowDmg = totalDmg - accuDmg
                return nowDmg,totalDmg
            end
        else
            return function ( totalDmg, accuDmg )
                local nowDmg = math.round(totalDmg * per / base)
                accuDmg = accuDmg + nowDmg
                return nowDmg, accuDmg
            end
        end
    end

    for i,v in ipairs(self.attackInfos) do
        local atkData = v[3]
        local info = percentInfoArr[atkData.__tempValueIndex]
        if atkData:sta_dmg() then
            -- atkData.dmgRatio = math.round(atkData:sta_dmg() / info[1] * 1000) / 1000
            atkData.dmgRatio = dmgFunc(atkData:sta_dmg(), info[1], atkData.isFinal)
        --如果是治疗百分比的
        elseif atkData:sta_addHp() then
            -- 加血直接在最终计算结果处取整，对于多段准确取整要求不高（不好记录因取整导致的数据丢失）
            atkData.dmgRatio = math.round(atkData:sta_addHp() / info[2] * 1000) / 1000
        end
    end
end


function ObjectSkill:setTreasure(treasure,skillIndex)
    self.__treasure = treasure
    self.skillIndex = skillIndex
    --遍历所有的攻击包 设置他的skillIndex
    for i,v in ipairs(self.attackInfos) do
        v[3].skillIndex  = skillIndex
    end

end

-- 获取法宝
function ObjectSkill:getTreasure()
    return self.__treasure
end

-- 获取skillIndex
function ObjectSkill:getSkillIndex()
    return self.skillIndex
end

--获取攻击数据
function ObjectSkill:getAttackDatas(index )
    return self.attackInfos
end

--判断是否是打子弹的技能体
function ObjectSkill:isMissleSkill(  )
    for i,v in ipairs(self.attackInfos) do
        if v[1] == Fight.skill_type_missle then
            return true
        end
    end
    return false
end

--判断这个攻击包是否是最后一下 只有是最后一下的时候 才判定从数组移除英雄
function ObjectSkill:checkAtkDataIsEnd( atkData )
    return atkData.isFinal
end


--设置hero 必须要调用这个接口
function ObjectSkill:setHero( hero )
    self.heroModel = hero

    -- 关联人物时
    if self.skillExpand then
        self.skillExpand:onSetHero(hero)
    end
end

--判断特殊技能触发
function ObjectSkill:checkChanceTrigger(params )
    self:doChanceExpand(params)
end

--立即做攻击包行为,主要是天赋技和击杀技会做
function ObjectSkill:doAtkDataFunc(  )
    if self.heroModel then
        for i,v in ipairs(self.attackInfos) do
            local atkData = v[3]
            self.heroModel:checkAttack(atkData,self)
        end
    else
        echoError("技能id%s,在初始化的时候，调用了heroModel",self.hid)
    end
end

--判断一个技能是否是aoe
function ObjectSkill:getAtkNums(  )
    if not self.isAttackSkill then
        return 0
    end
    local xNums = #self.xChooseArr
    local yNums 
    if self.yChooseType == 0 then
        yNums = 2
    else
        yNums = 1
    end
    return xNums * yNums


end

--清除攻击包的选择数组
function ObjectSkill:clearAtkChooseArr(  )
    for i,v in ipairs(self.attackInfos) do
        if v[1] ==Fight.skill_type_attack then
            local atk = v[3]
            atk.hasChooseArr = nil
        end
    end
end





function ObjectSkill:doChanceExpand( params )
    if not self.skillExpand then
        return
    end

    --如果是攻击开始
    if params.chance == Fight.chance_atkStart  then
        self.skillExpand:onHeroStartAttck(self.heroModel,params.attacker,params.skill)
    elseif params.chance == Fight.chance_roundStart then
        self.skillExpand:onMyRoundStart(self.heroModel)
    elseif params.chance == Fight.chance_toStart then
        self.skillExpand:onEnemyRoundStart(self.heroModel)
    elseif params.chance == Fight.chance_roundEnd then
        self.skillExpand:onMyRoundEnd(self.heroModel)
    elseif params.chance == Fight.chance_toEnd then
        self.skillExpand:onEnemyRoundEnd(self.heroModel)
    elseif params.chance == Fight.chance_onHeroWillDied  then
        self.skillExpand:beforeWillDied(self.heroModel,params.defender,params.damage)
    elseif params.chance == Fight.chance_onHeroRealWillDied  then
        self.skillExpand:beforeRealDied(params.attacker, params.defender)
    elseif params.chance == Fight.chance_atkend then
        self.skillExpand:willNextAttack(params.attacker)
    elseif params.chance == Fight.chance_onDied then
        self.skillExpand:onOneHeroDied(params.attacker, params.defender)
    elseif params.chance == Fight.chance_onOneBeUseBuff then
        self.skillExpand:onOneBeUseBuff(params.attacker, params.defender, params.skill, params.buffObj)
    end

end

-- 获取技能帧长度
function ObjectSkill:getSkillFrame()
    if self.skillFrame then return self.skillFrame end

    if not self.heroModel then return 1 end

    self.skillFrame = self.heroModel:getTotalFrames(self:sta_action())
    
    return self.skillFrame        
end

-- 钦定攻击范围
function ObjectSkill:setAppointAtkChooseArr(atkArr)
    self.appointChooseArr = atkArr
end

-- 获取钦定的攻击范围
function ObjectSkill:getAppointAtkChooseArr()
    return self.appointChooseArr
end

--获取rid 拼hidkey
function ObjectSkill:getSkillHidHeroRid(  )
    if not self._skillHidRid then
        self._skillHidRid = self.heroModel.data.rid..self.hid
    end
    return self._skillHidRid
end


return  ObjectSkill
