--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--

local globalCfgKey = {
    "hid","useWay","filterId","x","y",
    "final","attackNums","scoreT","scoreD",
    "shake","canDodge","canCrit","aniArr","dmg",
    "addHp","purify","buffs","summon","move",
    "specialRatio","dmg2hp",
    "bulletAni","bulletMove","doLattice"
}

--打击数据
ObjectAttack = class("ObjectAttack")
ObjectCommon.mapFunction(ObjectAttack,globalCfgKey)

ObjectAttack.hid = nil

ObjectAttack.xChooseArr = nil
ObjectAttack.yChooseType = 0
--如果不是final攻击包
ObjectAttack.isFinal = false
-- 加血的分割标记
ObjectAttack.isTreatFinal = false
--是否是第一个攻击包
ObjectAttack.isFirst = false

--伤害系数
ObjectAttack.dmgRatio = 1 

--已经选到的人
ObjectAttack.hasChooseArr = nil

ObjectAttack.filterObj = nil    --筛选ai
ObjectAttack.hasAtkRandom = nil    --是否具备随机ai性质

ObjectAttack.skillIndex  = 1

--子弹参数
ObjectAttack.bulletParams = nil

function ObjectAttack:ctor( hid )
    self.hid = hid

    self.__staticData =  ObjectCommon.getPrototypeData( "battle.Attack",hid )
    self.xChooseArr = self:sta_x()
    if self.xChooseArr[1] == 0 then
    	self.xChooseArr = {1,2,3}
    end
    -- 不是加血攻击包
    if self:sta_final() == 1 and not self:sta_addHp() then
        self.isFinal = true
    end
    -- 加血攻击包单独标记
    if self:sta_final() == 1 and self:sta_addHp() then
        self.isTreatFinal = true
    end
    self.yChooseType = self:sta_y()

    --判断是否带随机性质,如果带随机的 那么在点击选择攻击目标的时候 需要跳过
    local filterId = self:sta_filterId()
    if filterId then
        --攻击包附带的trigCount 是无限次
        self.filterObj = ObjectFilterAi.new(filterId)
        self.filterObj.trigCount = 99999
        --判断是否具备随机性质
        self.hasAtkRandom = self.filterObj:checkHasRandom()
    end

    -- 初始化子弹参数
    self:_initBulletParams()
end


--存储所有的 atk对象
local allAttackObj ={}

--获取某个hid的攻击包
function ObjectAttack.getAtkObjByHid(hid )
    -- if not allAttackObj[hid] then
    --     allAttackObj[hid] = ObjectAttack.new(hid)
    -- end
    return ObjectAttack.new(hid)
end

--是否是最后一次攻击
function ObjectAttack:checkIsFinal(  )
    return self.isFinal
end

--初始化子弹参数
function ObjectAttack:_initBulletParams()
    if self:sta_bulletAni() then
        local moveParams = self:sta_bulletMove()
        local bulletParams = {
            mType = moveParams[1], -- 子弹类型（0正向，1反向）
            eff = self:sta_bulletAni(), -- 特效名
            moveFrame = moveParams[2], -- 运动帧数
            height = moveParams[3] or 0, -- 运动高点（0为直线）
            fixFromPos = {w = moveParams[4] or 0, h = moveParams[5] or 0}, -- 出手位置修正
            fixToPos = {w = 0, h = moveParams[6] or 50}, -- 需求y方向配一个百分比
        }

        self.bulletParams = bulletParams
    end
end

-- 获取临时buffs列表,
function ObjectAttack:getTempBuffs(skill)
    local buffs = self:sta_buffs()
    local result = nil
    if buffs then
        local isRandom = false
        local spRatio = self:sta_specialRatio()
        if spRatio and spRatio < 10000 then
            isRandom = true
        end

        result = {}

        for i,v in ipairs(buffs) do
            local buff = ObjectBuff.new(v,skill)
            if isRandom then
                buff._isRandom = isRandom
            end
            table.insert(result, buff)
        end
    end

    return result
end

return  ObjectAttack
