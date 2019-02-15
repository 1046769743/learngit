local CompResTopBase = class("CompResTopBase", UIBase)

function CompResTopBase:ctor(winName)
	CompResTopBase.super.ctor(self, winName)
end

function CompResTopBase:loadUIComplete()
	self:playIconAnim()
end

function CompResTopBase:registerEvent()
	
end

--供子类重写
function CompResTopBase:getAnimTextNode()
end

--供子类重写 跳数字动画ctn
function CompResTopBase:getNumChangeEffecCtn()
end

--供子类重写 资源icon闪光的ctn
function CompResTopBase:getIconAnimCtn()
end

--供子类重写 资源icon
function CompResTopBase:getIconNode()
end

--供子类重写
function CompResTopBase:getIconAnimName()
end


--不重写，供子类调用 设置手动更新数字
function CompResTopBase:setUpdateNumManual()
	self._update_num_manual = true
end

--不重写，供子类调用 是否需要手动更新数字
function CompResTopBase:isManualUpdateNum()
	return self._update_num_manual == true
end

function CompResTopBase:updatePreNum(num)
	self.preNum = num
end

function CompResTopBase:getPreNum()
	return self.preNum or 0
end

function CompResTopBase:getDisplayNumStr(displayNum, isFloor)
	local suffix = ""
	local final = displayNum
	if isFloor == nil then isFloor = true end
	--if displayNum/10^8 > 1 then --亿
	--    suffix = "亿"
	--    displayNum = math.floor(displayNum/10^6)
	--    final = string.format("%.1f", displayNum/10^2)
	--    if isFloor then
	--        local newNum = math.ceil(tonumber(final))
	--        if newNum == tonumber(final) then
	--            final = newNum
	--        end
	--    end
	return FuncCommUI.turnOneNumToStr(displayNum )
end

--icon 闪光的特效
function CompResTopBase:playIconAnim()
	if not self.iconAnim then
		self:_createIconAnim()
	end
	local anim = self.iconAnim
	if anim then
		anim:gotoAndPause(1)
		anim:startPlay(false)
		local onAnimEnd = function()
			self:delayCall(c_func(self.playIconAnim, self), 2)
		end
		anim:registerFrameEventCallFunc(35, 1, c_func(onAnimEnd))
	end
end

function CompResTopBase:_createIconAnim()
	local animCtn = self:getIconAnimCtn()
	local iconNode = self:getIconNode()
	local animName = self:getIconAnimName()

	if not animName or not iconNode or not animCtn then
		return
	end

	local anim = self:createUIArmature("UI_common", animName, animCtn, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(anim, "icon", iconNode)
	FuncArmature.setArmaturePlaySpeed(anim, 0.8)
	anim:gotoAndPause(1)
	anim:scale(0.8)
	iconNode:pos(cc.p(0,0))
	self.iconAnim = anim
end

--数字放大效果
function CompResTopBase:playNumChangeEffect(fromNum, toNum)
	local textNode = self:getAnimTextNode()
	local textAnimCtn = self:getNumChangeEffecCtn()
	if not textNode or not textAnimCtn then
		return
	end
	local frameLen = 20
	local animName = "UI_common_res_num"
	if not self.ani_resNum then
		local textRect = textNode:getContainerBox()
		self.ani_resNum = self:createUIArmature("UI_common", animName, textAnimCtn, false, GameVars.emptyFunc)
		FuncArmature.changeBoneDisplay(self.ani_resNum , "layer6", textNode)
		textNode:pos(-textRect.width/2-5, textRect.height/2-3)
	end
	local setTextNum = function(num, isLastFrame)
		local isFloor = isLastFrame
		local numStr = self:getDisplayNumStr(num, isFloor) 
		textNode:setString(numStr)
		self:updatePreNum(num)
	end
	local numAnim = self.ani_resNum
	AudioModel:playSound("s_com_numChange")
	for frame=1,frameLen do
		local num = toNum
		if frame < frameLen then
			num = math.floor((toNum - fromNum)*1.0/frameLen * frame) + fromNum
		end
		numAnim:registerFrameEventCallFunc(frame, 1, c_func(setTextNum, num, frame==frameLen))
	end
	numAnim:startPlay(false)
end

return CompResTopBase
