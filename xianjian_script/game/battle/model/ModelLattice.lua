--[[
	格子实例
	目前目标功能是buff和表现
	buff行为类似object但是只能重写
	2018.01.11
]]
local Fight = Fight

ModelLattice = class("ModelLattice", ModelMoveBasic)

ModelLattice.buffInfo = nil
ModelLattice.buffNums = nil

function ModelLattice:ctor( controler, info )
	ModelLattice.super.ctor(self, controler)

	self.modelType = Fight.modelType_effect

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

	self:initLattice(info)
end

function ModelLattice:initLattice(info)
	local middlePos = self.controler.middlePos
	local x,y = self.controler.reFreshControler:turnPosition(info.camp,info.posIndex,1,middlePos)
	local pos = {x=x,y=y,z=0}

	self.camp = info.camp
	self.data = {}
	self.data.posIndex = info.posIndex
	self.data.viewSize = {50,50}

	self:setInitPos(pos)
	self._footRootPos = {x=0,y=0}

	-- 重写一些方法防止报错
	self:escapeErr()

	if not Fight.isDummy then
		-- 临时测试
		local tRect = cc.rect(0, 0, 0, 0)
		local nd = display.newRect(tRect,{fillColor = cc.c4f(0,1,0,0.3),borderColor = cc.c4f(1,0,0,1)})
		self:initView(self.controler.layer.a122, nd,pos.x,pos.y,0)
	end

	if self.camp == Fight.camp_1 then
		self.way = 1
	else
		self.way = -1
	end

	self:setWay(self.way)
end

-- 切波更新
function ModelLattice:waveUpdateLattice()
	local middlePos = self.controler.middlePos
	local x,y = self.controler.reFreshControler:turnPosition(self.camp,self.data.posIndex,1,middlePos)
	local pos = {x=x,y=y,z=0}

	self:setInitPos(pos)
	self:setPos(x,y,0)
	-- self._footRootPos = pos

	-- 清理buff
	self:clearAllBuff(true)
end

-- 重写一下防止报错 --
function ModelLattice:escapeErr()
	local _self = self

	function _self:getHeroProfession( ... )
		return Fight.profession_lattice
	end

	-- data类
	function _self.data:beusedScale()
		return 100
	end
end
-- 重写一下防止报错 --

--[[
    buff计数
    buffObj 是buff对象
    ctype 计数类型 1 增加 -1 减
]]
function ModelLattice:countBuff(buffObj, ctype)
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
    获取某个种类的buff 数量
]]
function ModelLattice:getBuffNumsByKind( buffKind )
    return self.buffNums.kindNum[buffKind]
end

--[[
    获取某个buff类型的数量
]]
function ModelLattice:getBuffNumsByType(buffType)
    return self.buffNums.typeNum[buffType] or 0
end

--获取身上的buff数量
function ModelLattice:getBuffNums(  )
    return self.buffNums.allNum
end

--是否有某种 kind buff 
function ModelLattice:checkHasKindBuff(buffKind)
    return self.buffNums.kindNum[buffKind] > 0
end

-- 添加buff
function ModelLattice:setBuff(buffObj)
	local result = false

	local buffType = buffObj:sta_type()
	if not self.buffInfo[buffType] then
	    self.buffInfo[buffType] = {}
	end
	local arr = self.buffInfo[buffType]

	--如果是马上执行的
	if buffObj.runType == Fight.buffRunType_now then
	    -- 打上就又效果
	    self:doBuffFunc(buffObj)
	end

	--如果次数为0 表示是一次性行为
	if buffObj.time == 0 then
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
	        self:sureInsertBuff( arr, buffObj )
	        result = true
	    --如果是比较剩余最大次数的
	    elseif replace == Fight.buffMulty_max then
	        local maxTime = 0
	        local length = #arr
	        local hasReplace
	        for i=length,1,-1 do
	            local obj = arr[i]
	            -- 只比较生效的
	            if obj:isValid() then 
	                --如果有 永久的同类型buff 那么不执行
	                if obj.time == -1 then
	                    break
	                end
	                --如果新来的buff 次数大于老buff
	                if obj.time < buffObj.time or buffObj.time == -1 then
	                    -- table.remove(arr,i)
	                    self:clearOneBuffObj(obj)
	                    self:sureInsertBuff( arr, buffObj )

	                    result = true
	                    return result
	                end
	            end
	        end
	    end
	else
	    self:sureInsertBuff( arr, buffObj )
	    result = true
	end

	return result
end

function ModelLattice:clearOneBuffObj(buffObj,isRout,noEvent)
	-- 容错，如果已经失效了就不做相关内容
	if not buffObj:isValid() then return end

	-- 将buff状态置为失效
	buffObj:setValid(false)
	self:countBuff(buffObj, -1)

	buffObj:clearBuff(isRout)
end

function ModelLattice:sureInsertBuff(buffArr, buffObj)
	table.insert(buffArr, buffObj)

	self:countBuff(buffObj, 1)
end

function ModelLattice:checkHasOneBuffType( buffType )
	return self:getBuffNumsByType(buffType) > 0
end

--@@force强制驱散，不考虑抵抗驱散
function ModelLattice:clearBuffByKind( ty, force )
    for k,v in pairs(self.buffInfo) do
        if #v > 0 then
            for i=#v,1,-1 do
                local info = v[i]
                -- 不抵抗驱散
                if info:isValid() and info.kind == ty and (not info.antiPurify or force) then
                    --清除这个buff的作用
                    -- table.remove(v,i)
                    self:clearOneBuffObj(info,nil,true)
                end
            end
        end
    end
    -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
end

-- 根据buffType删除buff isRout是否以崩溃的形式清除
function ModelLattice:clearBuffByType( buffType, force, isRout )
    local buffArr = self.buffInfo[buffType]
    if not buffArr or (#buffArr==0) then
        return nil
    end

    for _,buff in ipairs(buffArr) do
        -- 有效并且不是光环
        if buff:isValid() and not buff:checkIsAura() and (not buff.antiPurify or force) then
            self:clearOneBuffObj(buff,isRout,true)
        end
    end

    -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
end

--清除某一个buffid isRout是否以崩溃的形式清除
function ModelLattice:clearOneBuffByHid( buffHid,isRout )
    for k,v in pairs(self.buffInfo) do
        local arr = v
        for i=#arr,1,-1 do
            local buffObj = arr[i]
            if buffObj:isValid() and buffObj.hid == buffHid then
                -- table.remove(arr,i)
                self:clearOneBuffObj(buffObj,isRout,true)
            end
        end
    end
    -- 最后一起发消息
    -- self:dispatchEvent(BattleEvent.BATTLEEVENT_ONBUFFCHANGE )
end

-- 清除所有buff
function ModelLattice:clearAllBuff( handleClear )
	for buffType,arr in pairs(self.buffInfo) do
	    if handleClear then
	        for ii,vv in ipairs(arr) do
	            vv:deleteMe()
	        end
	    else
	        self:clearGroupBuff(buffType)
	    end
	end
	self.buffInfo = {}
end

function ModelLattice:clearGroupBuff( buffType )
	self:clearBuffByType(buffType, true)
end

function ModelLattice:checkReduceBuff(kind)
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
	                    -- self:useLastBuffAni(k)
	                end
	            end
	        end
	    end 
	end
end

function ModelLattice:doBuffFunc( buffObj )
	-- body
end

-- 我方回合结束后
function ModelLattice:updateRoundEnd()
	--检查坏buff次数
	self:checkReduceBuff(Fight.buffKind_huai)

	-- 中性buff暂定在这里减
	self:checkReduceBuff(Fight.buffKind_neutral)
end

-- 敌方回合结束后
function ModelLattice:updateToRoundEnd()
	--检查好buff次数
	self:checkReduceBuff(Fight.buffKind_hao)
end

function ModelLattice:checkCreateBuff( buffHid,attacker,skill )
	attacker = attacker or self
	skill = skill or attacker.currentSkill
	skill = skill or attacker.data:getSkillByIndex(Fight.skillIndex_small)

	local buffObj = ObjectBuff.new(buffHid,skill)

	self:checkCreateBuffByObj(buffObj,attacker,skill )

	return buffObj
end

-- 使用object创建buff
function ModelLattice:checkCreateBuffByObj( buffObj,attacker,skill )
	attacker = attacker or self
	skill = skill or attacker.currentSkill
	skill = skill or attacker.data:getSkillByIndex(Fight.skillIndex_small)

	local kind = buffObj.kind
	local buffType = buffObj.type

	buffObj.skillIndex  = skill.skillIndex

	--判断概率
	local random = BattleRandomControl.getOneRandomFromArea(0,10000)
	--如果 不在概率范围内 那么不命中这个buff
	if random > buffObj.ratio then
		return
	end

	--buffObj 特效数组
	local buffAniArr

	local enterAniArr
	--如果有出场的
	if buffObj:sta_enterAni() then
		enterAniArr = self:createEffGroup(buffObj:sta_enterAni(), false,true,attacker)
	end

	if buffObj:sta_aniArr() then
		buffAniArr = self:createEffGroup(buffObj:sta_aniArr(), true,true,attacker)
		buffObj.aniArr = buffAniArr
		--如果有出场动画的 先隐藏掉循环动画
		if enterAniArr then
			for i,v in ipairs(buffAniArr) do
				v:stopFrame()
				v.myView.currentAni:visible(false)
			end

			local tempFunc = function (  )
				if buffObj.aniArr then
					for i,v in ipairs(buffObj.aniArr) do
						v:playFrame()
						v.myView.currentAni:visible(true)
					end
				end
			end

			enterAniArr[1]:setCallFunc(tempFunc)
		end
	end

	--记录buff的释放着 是攻击方
	buffObj.hero = attacker
	--buff的作用着  是自己
	buffObj.useHero = self

	local flag = self:setBuff(buffObj)
end

function ModelLattice:runBeHitedFunc( attacker,atkData,skill )
	-- 处理格子被攻击包击中的逻辑
	AttackUseType:expandLattice(attacker, self, atkData, skill)
end

-- 重写下
function ModelLattice:getHeroMass()
	return 1
end
-- 断线重连更新格子上对应的buff显示
function ModelLattice:updateBuffs( )
	for k,v in pairs(self.buffInfo) do
		for _,buffObj in pairs(v) do
	        if buffObj:isValid() and buffObj:sta_aniArr() and (not buffObj.aniArr) then
	            buffObj.aniArr = self:createEffGroup(buffObj:sta_aniArr(),true,true,buffObj.hero)
	        end
		end
    end
end

return ModelLattice