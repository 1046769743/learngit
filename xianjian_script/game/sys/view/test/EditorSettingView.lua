--[[
    Author: pangkangning
    Date:2018-07-02
    Description: 地形编辑器设置界面
]]

local EditorSettingView = class("EditorSettingView", UIBase);

function EditorSettingView:ctor(winName)
    EditorSettingView.super.ctor(self, winName)
end
function EditorSettingView:loadUIComplete()
	self.btn_close:setTouchedFunc(c_func(self.closeBtnClick,self))
	self.btn_save:setTouchedFunc(c_func(self.saveBtnClick,self))
	self.btn_reset:setTouchedFunc(c_func(self.resetBtnClick,self))
	self.btn_load:setTouchedFunc(c_func(self.loadBtnClick,self))
	self.btn_resee:setTouchedFunc(c_func(self.reviewBtnClick,self))
	self.input_fileName:setText("ExploreMap1")
	if EditorControler.currFileName then
		self.txt_save:setString(EditorControler.currFileName) --保存的文件
	end
	self.input_x:setText(EditorControler.max.x)
	self.input_y:setText(EditorControler.max.y)
	self.txt_total:setString("总："..EditorControler.maxGrid)
end
function EditorSettingView:closeBtnClick(  )
	self:startHide()
end
function EditorSettingView:reviewBtnClick( )
	EventControler:dispatchEvent(EditorEvent.EDITOR_REVIEW)
	self:startHide()
end
function EditorSettingView:saveBtnClick(  )
	EditorControler:saveMapFile()
	WindowControler:showTips("保存成功!")
	self:startHide()
end
function EditorSettingView:resetBtnClick(  )
	local x = self.input_x:getText()
	if not x or x == "" or (not (tonumber(x) and tonumber(x) > 0 ))  then
		WindowControler:showTips("请先输入为数字的且大于0的x!")
		return
	end
	local y = self.input_y:getText()
	if not y or y == "" or (not (tonumber(y) and tonumber(y) > 0 )) then
		WindowControler:showTips("请先输入为数字的且大于0的y!")
		return
	end
	EditorControler:resetMapSize(tonumber(x),tonumber(y))
	self:startHide()
	WindowControler:showTips("重设尺寸成功!")
end
function EditorSettingView:loadBtnClick(  )
	local fNameStr = self.input_fileName:getText()
	if (not fNameStr) or fNameStr == "" then
		WindowControler:showTips("请先输入要打开的文件名!")
		return
	end
	local data = Tool:configRequire("exploreMap." .. fNameStr)
	if not data then
		echoError ("未存在的地图配置文件",fNameStr)
		return
	end
	EditorControler:setMapData(fNameStr)
	WindowControler:showTips("载入地形成功!")
	self:startHide()
end

return EditorSettingView