--[[
    Author: pangkangning
    Date:2018-07-02
    Description: 地形编辑器新建或者打开窗口
]]

local EditorOpenView = class("EditorOpenView", UIBase);

function EditorOpenView:ctor(winName)
    EditorOpenView.super.ctor(self, winName)
end
function EditorOpenView:loadUIComplete()
	self.btn_open:setTouchedFunc(c_func(self.openBtnClick,self))
	self.btn_new:setTouchedFunc(c_func(self.newBtnClick,self))
	-- 设置默认值
	self.input_x:setText(50)
	self.input_y:setText(50)
	self.input_fileName:setText("ExploreMap")
end
-- 打开文件
function EditorOpenView:openBtnClick(  )
	local fNameStr = self.input_fileName:getText()
	if fNameStr and fNameStr ~= "" then
		if cc.FileUtils:getInstance():isFileExist(string.format("config/exploreMap/%s.lua",fNameStr)) then
			-- echo("aa===",fNameStr)
			-- local data = Tool:configRequire("exploreMap.exploreMap" .. fNameStr)
			-- if not data then
			-- 	echoError ("未存在的文件",exploreMap,fNameStr)
			-- end
			EditorControler:setMapData(fNameStr)
			WindowControler:showTips("载入地形成功!")
			self:startHide()
			return
		end
	end
	WindowControler:showTips(string.format("打开地形失败（文件名:%s)!",fNameStr))
end
-- 新建文件
function EditorOpenView:newBtnClick(  )
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
	local fNameStr = self.input_fileName:getText()
	if not fNameStr or fNameStr == "" then
		WindowControler:showTips(string.format("新建地形失败（文件名:%s)!",fNameStr))
		return
	end
	EditorControler:createMapData(fNameStr,tonumber(x),tonumber(y))
	WindowControler:showTips("新建地形成功!")
	self:startHide()
end

return EditorOpenView