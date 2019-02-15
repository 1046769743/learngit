--[[
	触发技能控制器
	lcy 2018.2.28

	用来注册和释放触发的技能，按照触发顺序入队执行，期望用这种方式拉开独立时间
	并且保证复盘流程一致
]]
local Fight = Fight
-- local BattleControler = BattleControler
TriggerSkillControler = class("TriggerSkillControler")

TriggerSkillControler.callFuncArr = nil -- 将触发的内容存放在队列里
TriggerSkillControler._completeCallBack = nil -- 队列清空的回调

function TriggerSkillControler:ctor(controler)
	self.controler = controler

	self.callFuncArr = {}
	self._completeCallBack = nil
end

--[[
	入队执行Skill的回调
	@@ model 绑定到的对象，认为注册的行为与model相关
	@@ func 注册的行为
	@@ frame 当注册的是一个技能时，不能有此字段，继续触发依赖技能完成，
	当注册的不是技能时，frame表示一个帧数，依赖此帧数继续后续回调
]]
function TriggerSkillControler:pushOneSkillFunc(model, func, frame)
	if not func then
		echoError("空触发技能")
		return
	end

	self.callFuncArr[#self.callFuncArr + 1] = {
		model = model,
		func = func,
		frame = frame,
	}
end

-- 执行触发技能队列
function TriggerSkillControler:excuteTriggerSkill(callBack)
	-- 如果已经出结果了就不再进行触发了
	if self.controler and self.controler.__gameStep == Fight.gameStep.result then
		return
	end

	-- 只接收首次执行的回调，因为后续的都为触发技能，不需要走完整流程
	if not self._completeCallBack then
		self._completeCallBack = callBack
	end

	-- 已经执行完成，执行初始回调
	if self:empty() then
		if self._completeCallBack then
			local func = self._completeCallBack
			self._completeCallBack = nil
			return func()
		end
	else -- 未执行完成
		local info = self:popOneSkillFunc()

		if info.frame then
			info.func()
			if Fight.isDummy then
				return self:excuteTriggerSkill()
			else
				self:pushOneCallFunc(info.frame, "excuteTriggerSkill")
			end
		else
			return info.func()
		end
	end
end

-- 出队并执行SKill的回调
function TriggerSkillControler:popOneSkillFunc()
	if #self.callFuncArr == 0 then return end

	local result = self:frontOneSkillFunc()
	self:removeOneSkillFuncByIdx(1)

	return result
end

-- 队列是否为空
function TriggerSkillControler:empty()
	return #self.callFuncArr == 0
end

-- 返回首元素
function TriggerSkillControler:frontOneSkillFunc()
	return self.callFuncArr[1]
end

-- 删除一个回调
function TriggerSkillControler:removeOneSkillFuncByIdx(idx)
	table.remove(self.callFuncArr, idx)
end

-- 删除若干回调
function TriggerSkillControler:removeOneSkillFuncByModel(model)
	for i,info in ripairs(self.callFuncArr) do
		if info.model == model then
			self:removeOneSkillFuncByIdx(i)
		end
	end
end

-- 注册回调
function TriggerSkillControler:pushOneCallFunc(delayFrame, func, params)
	if Fight.isDummy  then
		echo(debug.traceback("___dumy should run rightway") )
		delayFrame = 0
	end

	params = params or {}
	if type(func) == "string" then
		func = self[func]
		params = Tool:getTableNoNil(params)
		table.insert(params, 1,self)
	end

	self.controler:pushOneCallFunc(delayFrame, func, params)
end

-- 清除一个回调
function TriggerSkillControler:clearOneCallFunc( func )
	if type(func) == "string" then
		func = self[func]
		self.controler:clearOneCallFunc(func,self)
	else
		self.controler:clearOneCallFunc(func,self)
	end
end

-- 清除所有注册事件
function TriggerSkillControler:clearAllCallFunc()
	for i=1,#self.callFuncArr do
		self.callFuncArr[i] = nil
	end
end