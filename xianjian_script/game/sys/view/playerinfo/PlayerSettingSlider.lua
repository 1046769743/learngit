--
--Author:      zhuguangyuan
--DateTime:    2017-07-14 10:05:18
--Description: 系统设置里开关的滑动器
--

local PlayerSettingSlider = class("PlayerSettingSlider", UIBase)
local SWITCH_ON = 1
local SWITCH_OFF = 2
local POS_ON_X = 104;
local POS_OFF_X = 0;

function PlayerSettingSlider:ctor(winName)
	PlayerSettingSlider.super.ctor(self, winName)
end

function PlayerSettingSlider:loadUIComplete()
    self.panel_slider.mc_2:showFrame(SWITCH_ON)
	-- self.container_box = self:getContainerBox()
	self:registerEvent()
end

function PlayerSettingSlider:registerEvent()
	self.panel_slider:setTouchedFunc(c_func(self.toggleSwitch, self))
end

function PlayerSettingSlider:toggleSwitch()
	--question 此处何意?
   -- 系统设置 音效
    if AudioModel:isSoundOn() then
		AudioModel:playSound("s_com_click2")
	end
    
	if not self.info then return end

	local slider_block = self.panel_slider.mc_1
	-- local box = self.container_box
	local state = self:getStorageState()
	local moveX = 0
	local newState

	--如果是开换成关，如果是关换成开
	if state == FuncSetting.SWITCH_STATES.ON then
		moveX = POS_OFF_X
		newState = FuncSetting.SWITCH_STATES.OFF
	else
		newState = FuncSetting.SWITCH_STATES.ON
		moveX = POS_ON_X
	end

	if newState then
		LS:pub():set(self.info.sc, newState)
	end

	--将开关上的圆钮移动到另一端
	slider_block:runAction(act.moveto(0.1, moveX, 0)) 

	--
	--Author:      zhuguangyuan
	--DateTime:    2017-07-14 11:28:41
	--Description: 开关处理事件待进一步处理
	--
	--开关设置后分发实际的处理事件
	local event = self.info.event
	if event then
		EventControler:dispatchEvent(event, {state = newState})
	end
	self:setStateStr(newState)
end

function PlayerSettingSlider:setInfo(info)
	self.info = info
end

function PlayerSettingSlider:updateUI()
	self:initState()
end

function PlayerSettingSlider:setStateStr(state)
	if state == FuncSetting.SWITCH_STATES.ON then
		self.panel_slider.mc_2:showFrame(SWITCH_ON)
	else
		self.panel_slider.mc_2:showFrame(SWITCH_OFF)
	end
end

function PlayerSettingSlider:initState()
	local state = self:getStorageState()
	local slider_block = self.panel_slider.mc_1
	if state == FuncSetting.SWITCH_STATES.OFF then
		-- local box = slider_block:getContainerBox()
		local x,y = slider_block:getPosition()
		slider_block:pos(cc.p(0,y))
	end
	self:setStateStr(state)
end

function PlayerSettingSlider:getStorageState()
    local state = FuncSetting.SWITCH_STATES.ON
    if self.info.key == "show_palyer" then
        state = FuncSetting.SWITCH_STATES.OFF
    end
	state = LS:pub():get(self.info.sc, state)
	return state
end

return PlayerSettingSlider

