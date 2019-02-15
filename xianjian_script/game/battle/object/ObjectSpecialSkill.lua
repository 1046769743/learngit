--
-- Author: XD
-- Date: 2017-01-16 10:44:47
--特殊技被动技能
ObjectSpecialSkill = class("ObjectSpecialSkill",ObjectSkill)

--剩余使用次数
ObjectSpecialSkill.leftUseTimes = 0

--作用方式  1 ,是走正常攻击包模式 2,是 后面攻击的人会获得buff
ObjectSpecialSkill.useStyle = 0 

--触发方式 1是普攻触发,2是小技能之后 3是大招之后
ObjectSpecialSkill.trigType = 0

--触发概率  万份比
ObjectSpecialSkill.trigRatio = 10000

function ObjectSpecialSkill:ctor( hid,lv, charIdx,skillParams )
   ObjectSpecialSkill.super.ctor(self,hid,lv, charIdx,skillParams)
   self.passiveParams = self:sta_passiveParams()

   if not self.passiveParams then
       echoError("找策划,skillhid:%s,没有配置passiveParams这个参数 ",hid)
   end
   --取数组第一个
   self.passiveParams = self.passiveParams[1]
   self.leftUseTimes = self.passiveParams.times
   self.useStyle = self.passiveParams.style
   self.passivetrigArr = self:sta_passiveTrig()
end

--作用 被动技能的攻击包
function ObjectSpecialSkill:usePassiveAtkDatas(beUsedHero )
    local attackId = self.passiveParams.atkId
    local atkData = ObjectAttack.new(attackId)
    --如果没有指定作用的英雄
    if not beUsedHero then
        self.heroModel:checkAttack(atkData, self)
    else
        --如果没有作用次数了 那么就不执行
        if self.leftUseTimes == 0 then
            return 
        end
        self.leftUseTimes = self.leftUseTimes -1
        --那么作用buff
        local buffIds = atkData:sta_buffs()
        AttackUseType:buffs(nil,0,self.heroModel,beUsedHero, atkData,self,buffIds)

    end

end




--判断一个技能能否被触发
function ObjectSpecialSkill:checkCanTrig( skillIndex )
    if table.find(self.passivetrigArr,skillIndex) then
        return true
    end
    return false
end





return ObjectSpecialSkill