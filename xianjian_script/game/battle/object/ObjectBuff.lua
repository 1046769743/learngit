--
-- Author: XD
-- Date: 2014-07-24 10:44:47

local globalCfgKey = {
    "hid","replace","icon","buffFla","runType","enterAni",
    "aniArr","endAni","routAni","useAniArr","flowWord",
    "style","time","costTimes","followClear","type",
    "changeType","value","ratio","routAction",
    "expandP","antiPurify","expandAniArr","calValue","valueLimit",
    "chkAction","coexist","beresist"
}


--打击数据
ObjectBuff = class("ObjectBuff")
ObjectCommon.mapFunction(ObjectBuff,globalCfgKey)

ObjectBuff.hid = nil
ObjectBuff.time = -1 --剩余作用时间(回合 -1表示永久)
ObjectBuff.initTime = -1 	--初始化的作用时间 --用来刷新buff

ObjectBuff.hero = nil 	--buff的释放着
ObjectBuff.useHero = nil 	--buff的作用着 
ObjectBuff.aniArr = nil 	--特效数组
ObjectBuff.enterAniArr = nil    --出场特效数据
ObjectBuff.endAniArr = nil    --结束特效数组
ObjectBuff.runType = 1 		--执行时机  1 是立刻执行 2 是回合开始前执行 3是我方下回合执行
ObjectBuff.ratio = 10000      --触发概率

ObjectBuff.isRout = false       --标记是否处于崩溃阶段 ,当一个人攻击完毕的时候 受击着需要判断是否崩溃并给反馈 

ObjectBuff.orderIndex =  0      --被创建的顺序 

ObjectBuff.costTimes = nil -- buff使用次数

ObjectBuff._isValid = nil -- 是否生效

ObjectBuff._canReduce = nil -- 用于判断回合buff，是否减少回合计数（伙伴行动过（被控制不算）与否是唯一标准）

ObjectBuff.atkType = nil

function ObjectBuff:ctor( hid,skill )
    self.hid = hid
    self.__staticData = ObjectCommon.getPrototypeData("battle.Buff",hid)
    self.type = self:sta_type()
    self.time = self:sta_time() or -1
    --如果是复活 不走 time
    if self.type == Fight.buffType_relive  then
        self.time = -1
    end



    self.runType = self:sta_runType() or Fight.buffRunType_now
    self.value = self:sta_value()
    self.changeType = self:sta_changeType()
    -- self.kind = self:sta_kind()

    self.replace = self:sta_replace()
    self.coexist = self:sta_coexist() -- 强制共存（1表示同id也可共存，具体共存方式依然由replace字段控制）
    self.ratio = self:sta_ratio() or 10000
    -- 是否是随机buff
    self._isRandom = (self.ratio < 10000)
    self.skill = skill
    -- 按属性修改 value 通过其他字段读取
    if self.changeType == Fight.valueChangeType_attr then
        if not self:sta_calValue() then
            echoError("找策划，这个buff calValue没有填值,hid:",self.hid)
        else
            local calValue = table.copy(self:sta_calValue()[1])
            for k,value in pairs(calValue) do
                -- if type(value) == "number" and value < 0 and value > -11 then
                    -- calValue[k] = skill:getSkillParamsByValue(value, string.format("buffHid:%s",self.hid))
                -- end
                if k ~= "attr" then -- 这个字段一定不会传值
                    calValue[k] = self:checkValue(value)
                end
            end
            self.calValue = calValue
        end
    end

    self.value = self:checkValue(self.value)

    -- 处理来自技能脚本的buff额外值
    self:checkExbuffValueFromSkillExpand()

    if self:sta_valueLimit() then
        self.valueLimit = self:sta_valueLimit()[1]
    end
    
    if not self.replace then
    	self.replace = Fight.buffMulty_all
    end
 --    if self.time > 0 then
	-- 	self.time = self.time + 1
	-- end

    -- 作用次数，每生效一次会消耗一次（不填默认很大，不会被消耗干净）
    self.costTimes = self:sta_costTimes() or 9999

    self.initTime = self.time

    self._isValid = true -- 生效状态

    self._canReduce = true
    -- 抵抗驱散
    self.antiPurify = (self:sta_antiPurify() and self:sta_antiPurify() == 1) and true or false

    --扩展参数
    if self:sta_expandP() then
        self.expandParams = table.copy(self:sta_expandP())
    end
    if self.expandParams then
        for i,v in ipairs(self.expandParams) do
            self.expandParams[i] = self:checkValue(self.expandParams[i])
        end
    end

    self.chkAction = (self:sta_chkAction() == 1)
    
    --判断复活参数
    self:checkReliveParams()
    self:checkKind()
    --冰符参数
    self:checkBingfuParams()
    --处理炸弹参数
    self:checkBombParams()
    -- 处理灵泉参数
    self:checkLingquanParams()
    -- 处理刑锁buff参数
    self:checkXingsuoParams()
    -- 初始化一下 Fight.buffType_atkcarrier buff的参数
    self:checkAtkCarrierParams()
    -- 初始化一下庇护参数
    self:checkBihuParams()
    -- 初始化一下炎波参数
    self:checkYanboParams()
end

-- 处理value
function ObjectBuff:checkValue(value)
    if not value then 
        return  
    end
    local result = tonumber(value)

    if not result then
        if not self.skill then
            echoError("此buff没有传入skill，缺需要传入值，非正常情况，检查配表",self.hid)
            return 1
        end
        result = self.skill:getSkillParamsByValue(value, string.format("buffHid:%s",self.hid))
    end

    return result
end


-- 改成用表索引方式
-- 指定的减益buff
local sureBad = {
    Fight.buffType_xuanyun, Fight.buffType_chenmo, Fight.buffType_bingdong, Fight.buffType_mabi,
    Fight.buffType_DOT, Fight.buffType_nocureR, Fight.buffType_shufu, Fight.buffType_zhongshang,
    Fight.buffType_certainBbaoji, Fight.buffType_zhuoshao, Fight.buffType_fengnu, Fight.buffType_liuxue,
    Fight.buffType_sleep, Fight.buffType_wanghun, Fight.buffType_jianhen, Fight.buffType_chuangshang,
    Fight.buffType_sign, Fight.buffType_bingfu, Fight.buffType_dikangzengyi, Fight.buffType_hunluan,
    Fight.buffType_bomb,Fight.buffType_zhongchuang,Fight.buffType_tag_hanlingsha,Fight.buffType_tag_yuntianhe,
    Fight.buffType_huhun,Fight.buffType_klchong,Fight.buffType_tag_lingbo,Fight.buffType_huoshangjiaoyou,
    Fight.buffType_xingsuo,Fight.buffType_hanbing,Fight.buffType_yanbo,Fight.buffType_tag_daofu,
}
local sureBadMap = {
    
}

for k,v in pairs(sureBad) do
    sureBadMap[v] = true
end


-- 指定的增益buff
local sureGood = {
    Fight.buffType_mianyidmg, Fight.buffType_relive, Fight.buffType_HOT, Fight.buffType_bati,
    Fight.buffType_dikangjiannu, Fight.buffType_mianyijianyi, Fight.buffType_fantan, Fight.buffType_kuilei,
    Fight.buffType_sureBaoji, Fight.buffType_hpExDmg, Fight.buffType_bingtai, Fight.buffType_jinghua_hao,
    Fight.buffType_kezhi, Fight.buffType_energyCostUnchange, Fight.buffType_energyNoCost,Fight.buffType_wumian,
    Fight.buffType_famian,Fight.buffType_tag_wangpengxu,Fight.buffType_eNxixue,Fight.buffType_tag_gangzhan,
    Fight.buffType_mianyiputong,Fight.buffType_tag_yaoneng,
}

local sureGoodMap = {
    
}

for k,v in pairs(sureGood) do
    sureGoodMap[v] = true
end

function ObjectBuff:checkKind(  )
    local buffType = self.type
    local haoOrHuai = false
    
    if sureBadMap[buffType] then
        haoOrHuai = false 
    elseif sureGoodMap[buffType] then
        haoOrHuai = true
    else
        -- 根据属性的类型，是否是增益根据系数正负决定
        if self.changeType == Fight.valueChangeType_attr then
            if not self.calValue then
                haoOrHuai = true
            else
                haoOrHuai = (self.calValue.rate >= 0)
            end
        else
            local value  = self.value
            if not value then
                haoOrHuai = true
            else
                haoOrHuai = (value >= 0)
            end
        end
    end

    -- 特殊类型，负数为增益
    if buffType == Fight.buffType_energyCost then
        local value  = self.value
        if not value then
            haoOrHuai = true
        else
            haoOrHuai = (value <= 0)
        end
    end

    --判断回合
    --如果是-1 表示光环
    if self.time == -1 then
        if haoOrHuai == true then
            self.kind = Fight.buffKind_aura 
        else
            self.kind = Fight.buffKind_aurahuai 
        end
    else
        if haoOrHuai ==true then
            self.kind = Fight.buffKind_hao 
        else
            self.kind = Fight.buffKind_huai 
        end
    end

    -- 指定中性buff
    local sureNeutral = {
        [Fight.buffType_yuner] = true,
        [Fight.buffType_dingshen] = true,
        [Fight.buffType_atkcarrier] = true,
        [Fight.buffType_tag_tangxuejian] = true,
        [Fight.buffType_tag_mubei] = true,
        [Fight.buffType_tag_common] = true,
        [Fight.buffType_purify] = true,
        [Fight.buffType_tag_xienian] = true,
    }

    -- 个别buff为做标记用的，既非增益也非减益
    if sureNeutral[buffType] then
        self.kind = Fight.buffKind_neutral
    end

    -- echo(self.kind,self.value,self.time,self.type,self.hid,"___________自动判定buffkind")
end

--获取飘字动画对应的帧数 和样式 空表示没有
function ObjectBuff:getEffWordFrame(  )

    local kind = self.kind
    if kind == Fight.buffKind_aura or kind == Fight.buffKind_aurahuai   then
        return nil
    end

    local frame 
    local style = 1
    local buffType = self.type
    frame = Fight.buffMapFlowWordHao[buffType]
    if not frame then
        frame = Fight.buffMapFlowWordHuai[buffType]
        style = 2
    end
    if not frame then
        return nil
    end
    return frame, style
end

--判断是否是光环
function ObjectBuff:checkIsAura(  )
	return self.kind == Fight.buffKind_aura  or self.kind == Fight.buffKind_aurahuai 
end

function ObjectBuff:tostring( )
    return "Buff--id:"..self.id..",type:"..self.type..",chooseType:"..self.value..",ani:"..tostring(self.ani)
end
--[[
    使用buff
    特殊buff要单独调用
]]
function ObjectBuff:useBuff( )
	self.costTimes = self.costTimes - 1
    -- echo("buff",self.hid,"被使用了一次，还剩:",self.costTimes)
    if self.costTimes <= 0 then -- 没次数了
        -- 调用附着的人物清掉自己
        if self.useHero then -- 如果没有就不正常
            self.useHero.data:clearOneBuffByHid(self.hid)
        end
    end
end

--[[
    判断是否是减益buff
    标准：
    导致角色属性减少
    修改定义，buffKind为 Fight.buffKind_huai
]]
function ObjectBuff:checkIsJianyi()
    return self.kind == Fight.buffKind_huai
end

--[[
    获取buff作用值
    目前有些需求需要获得作用值
]]
function ObjectBuff:getEffValue( baseValue )
    local changeNum = 0
    if self.changeType == Fight.valueChangeType_num then
        changeNum = self.value
    elseif self.changeType == Fight.valueChangeType_ratio then
        changeNum = baseValue * self.value / 10000
    end
    return changeNum
end

--清除buff isRout 是否是崩溃清除的
function ObjectBuff:clearBuff( isRout )
    local aniArr
    if isRout then
        aniArr = self:sta_routAni()
    else
        aniArr = self:sta_endAni()
    end
    if aniArr then
        if self.useHero then
            self.useHero:createEffGroup(aniArr,false,true,self.useHero)
        end
    end
	self:deleteMe()
end

-- 处理生效特效
function ObjectBuff:showUseEff()
    if Fight.isDummy then return end
    
    --判断是否有作用动画
    local useAniArr = self:sta_useAniArr()
    if useAniArr and self.useHero then
        self.useHero:createEffGroup(useAniArr, false,true,self.useHero)
    end
end

--清除这个buff
function ObjectBuff:deleteMe()
	if self.aniArr then
		for k,v in pairs(self.aniArr) do
			--必须这个特效没有被干掉 
			if not v._isDied then
				v:deleteMe()
			end
		end
		self.aniArr = nil
	end
	self.hero = nil
    self.useHero = nil
end

-- 设置生效状况
function ObjectBuff:setValid(value)
    self._isValid = value
end

-- 获取buff是否生效
function ObjectBuff:isValid()
    return self._isValid
end

-- 返回是否可减回合
function ObjectBuff:canReduce()
    return self._canReduce
end

-- 设置是否可减回合
function ObjectBuff:setCanReduce(value)
    self._canReduce = value
end

-- 返回是否需要检查是否行动过
function ObjectBuff:needChkAction()
    return self.chkAction
end

------------------------------ buff的特性设定 ------------------------------
-- **目前涉及到的buff不多，每个buff直接写在这，如果之后涉及大量buff，一定要考虑拆分

--特殊buff炸弹自有参数
function ObjectBuff:checkBombParams()
    -- 记录带有buff的人已经受到了多少伤害
    self._bombRecDmg = 0
end

--特殊的携带攻击包的buff
function ObjectBuff:checkAtkCarrierParams()
    if self.type == Fight.buffType_atkcarrier then
        if self.expandParams then
            self.expandParams[1] = tonumber(self.expandParams[1])
            for i=2,#self.expandParams do
                self.expandParams[i] = ObjectAttack.new(self.expandParams[i])
            end
        end
    end
end

function ObjectBuff:checkReliveParams(  )
    if self.type == Fight.buffType_relive  then
        if not self.expandParams  then
            echoWarn("复活buff参数配置错误id:",self.hid)
            return 
        end
    else
        return
    end
    --dump(self.expandParams)
    if not self.expandParams then
        return
    end
    local oldParams = self.expandParams
    --数据克隆一次
    self.expandParams = table.copy(oldParams)
    --判断是否需要动态取值得的
    --如果血量是要取百分比的
    if self.expandParams[2] < 0 and self.skill then
        -- self.expandParams[2] = self.skill.skillParams[math.abs(oldParams[2])]
        self.expandParams[2] = self.skill:getSkillParamsByValue(p .. math.abs(oldParams[2]))
        if not self.expandParams[2] then
            dump(self.skill.skillParams,"__技能伤害参数")
            echoWarn("技能id:%s,伤害参数位置:%d 复活buff没有配置对应的生命系数,buffid:%s",self.skill.hid,oldParams[2])
        end
        if self.expandParams[1] == Fight.valueChangeType_ratio  then
            self.expandParams[2] = self.expandParams[2]/10000
        end
    end

    if self.expandParams[4] < 0 and self.skill then
        -- self.expandParams[4] = self.skill.skillParams[math.abs(oldParams[4])]
        self.expandParams[4] = self.skill:getSkillParamsByValue(p .. math.abs(oldParams[4]))
        if not self.expandParams[4] then
            dump(self.skill.skillParams,"__技能伤害参数")
            echoWarn("技能id:%s,伤害参数位置:%d配置,复活buff没有配置对应的怒气系数, buffid:%s",self.skill.hid,oldParams[4])
        end
         if self.expandParams[3] == Fight.valueChangeType_ratio  then
            self.expandParams[4] = self.expandParams[4]/10000
        end
    end
end
--[[
    特殊buff
    冰符参数处理
]]
function ObjectBuff:checkBingfuParams()
    if self.type == Fight.buffType_bingfu then
        self._bingfuP = {
            trigger = false,
            buffId = self.value,
        }
    end
end

--[[
    特殊buff
    冰符触发函数
    返回是否触发
]]
function ObjectBuff:checkBingfuTrigger()
    local result = false
    if self._bingfuP then
        if self._bingfuP.trigger then
            -- 冰符产生作用
            if self.useHero then
                echo("冰符产生作用，冰冻目标")
                self.useHero:checkCreateBuff(self._bingfuP.buffId,self.hero,self.skill)
                result = true
            else
                echoError("错误情况，冰符:%s没有useHero:%s", self.hid,self.useHero == nil)
            end
            -- self:useBuff()
        else
            -- 回合前作用时重置为触发
            self._bingfuP.trigger = true
        end
    end
    return result
end

--[[
    特殊buff
    冰符缓解（释放大招时调用下回合开始不会触发）
]]
function ObjectBuff:delayBingfu()
    if self._bingfuP then
        self._bingfuP.trigger = false
    end
end

-- 刑锁技能
function ObjectBuff:checkXingsuoParams()
    if self.type == Fight.buffType_xingsuo then
        self._xingsuoP = {
            trigger = false,
            buffId = self.value,
        }
    end
end

-- 检查刑锁触发
function ObjectBuff:doXingsuoTrigger()
    local result = false
    if self._xingsuoP then
        if self._xingsuoP.trigger then
            -- 刑锁产生作用
            if self.useHero then
                echo("刑锁产生作用，眩晕目标")
                self.useHero:checkCreateBuff(self._xingsuoP.buffId, self.hero, self.skill)
                result = true
            else
                echoError("错误情况，刑锁:%s没有useHero:%s",self.hid,self.useHero == nil)
            end
        end
    end
    return result
end

-- 检查刑锁
function ObjectBuff:checkXingsuoTrigger()
    if self._xingsuoP then

        self._xingsuoP.trigger = true
    end
end

-- 灵泉buff（来自灵泉杖）
function ObjectBuff:checkLingquanParams()
    if self.type == Fight.buffType_lingquan then
        self._lingquanP = {
            count = tonumber(self.value),
            buff1 = self.expandParams[1],
            buff2 = self.expandParams[2],
        }
    end
end

-- 检查灵泉
function ObjectBuff:checkLingquanTrigger(attacker)
    if not self._lingquanP then return end
    if not self.useHero then
        echoError("错误情况，灵泉:%s没有useHero:%s",self.hid,self.useHero == nil)
        return
    end
    -- 攻击者属性为水
    if attacker:getHeroElement() == Fight.element_water then
        self._lingquanP.count = self._lingquanP.count - 1
        -- 条件满足可以触发了
        if self._lingquanP.count == 0 then
            echo("灵泉buff触发冰冻")
            -- 直接让自己给自己加
            self.useHero:checkCreateBuff(self._lingquanP.buff1, self.hero, self.skill)
            -- 调用附着的人物清掉自己
            self.useHero.data:clearOneBuffByHid(self.hid)
        end
    else
        if self._lingquanP.count > 0 then
            -- 是进阶版
            if self._lingquanP.buff2 then
                echo("灵泉buff触发寒冰")
                -- 直接让自己给自己加
                self.useHero:checkCreateBuff(self._lingquanP.buff2, self.hero, self.skill)
            end

            -- 调用附着的人物清掉自己
            self.useHero.data:clearOneBuffByHid(self.hid)
        end
    end
end

-- 检查庇护参数
function ObjectBuff:checkBihuParams()
    if self.type == Fight.buffType_bihu then
        if self.expandParams then
            self.expandParams[1] = ObjectAttack.new(self.expandParams[1])
        end
    end
end

-- 处理庇护触发
function ObjectBuff:checkBihuTrigger(defender)
    if self.expandParams then
        echo("庇护触发额外逻辑")
        defender:sureAttackObj(defender,self.expandParams[1],self.skill)
    end
end

function ObjectBuff:doBuffTriggerFunc(...)
    if self.type == Fight.buffType_lingquan then
        self:checkLingquanTrigger(...)
    elseif self.type == Fight.buffType_bihu then
        self:checkBihuTrigger(...)
    end
end

-- 检查炎波参数（来自神力技能）
function ObjectBuff:checkYanboParams()
    if self.type == Fight.buffType_yanbo then
        self._yanboP = {
            count = 0, -- 记录伤害
            attacker = {}, -- 攻击者
        }
    end
end

-- 记录伤害
function ObjectBuff:checkYanboTrigger(attacker,dmg)
    self._yanboP.attacker[attacker] = true
    self._yanboP.count = self._yanboP.count + math.abs(dmg)
    -- echoError("记录伤害",self._yanboP.count,math.abs(dmg))
end

-- 获取伤害值和攻击者，并重置数据
function ObjectBuff:popYanboInfo()
    if self._yanboP.count == 0 then return end
    local dmg = math.round(self._yanboP.count * self.value / 10000)
    local attacker = nil
    -- 随便找一个没死的人
    for hero,_ in pairs(self._yanboP.attacker) do
        -- 没死
        if hero and not hero.hasHealthDied then
            attacker = hero
            break
        end
    end

    self._yanboP.count = 0
    self._yanboP.attacker = {}

    return dmg,attacker
end

-- 返回是否需要检查抵抗
function ObjectBuff:needChkResist()
    -- 减益buff且概率<10000(非必中buff)
    -- return self.kind == Fight.buffKind_huai and self.ratio < 10000
    -- 减益buff且可以被抵抗
    return self.kind == Fight.buffKind_huai and self:sta_beresist() == 1
end

-- 当被驱散时
function ObjectBuff:onBePurify()
    -- 当自己被驱散时
    if self.type == Fight.buffType_DOT then
        -- 有扩展参数的特殊毒
        if self.expandParams and self.expandParams[1] then
            if self.useHero then
                echo("特殊毒")
                self.useHero:checkCreateBuff(self.expandParams[1], self.useHero, self.skill)
            end
        end
    end
end

-- 处理来自技能脚本的额外值
function ObjectBuff:checkExbuffValueFromSkillExpand()
    if not self.skill or not self.skill.skillExpand or not self.skill.skillExpand:isUseBuffEx(self.hid) then return end

    self.value = self.value + self.skill.skillExpand:getBuffExValue(self.hid)
    self.ratio = self.ratio + self.skill.skillExpand:getBuffExRatio(self.hid) 

    if self.calValue then
        local exrate,exn = self.skill.skillExpand:getBuffExCalValue(self.hid)
        self.calValue.rate = self.calValue.rate + exrate
        self.calValue.n = self.calValue.n + exn
    end
end

return  ObjectBuff