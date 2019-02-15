--[[
	继承的AnimModelNPC
	奇侠传记的接引NPC
]]

AnimModelBiographyNPC = class("AnimModelBiographyNPC", AnimModelNPC)

-- 暂时只重写点击
function AnimModelBiographyNPC:doNPCClick()
	echo("奇侠传记接引NPC被！点！了！")

	local function onClick()
		local function gotoMisiion()
			-- 进入当前剧情
			BiographyControler:enterCurBiography()			
		end

		if self.cfgData.plotEvent then -- 对话事件
			PlotDialogControl:init() 
			PlotDialogControl:showPlotDialog(self.cfgData.plotEvent, gotoMisiion)
			return
		end

		gotoMisiion()
	end

	AnimDialogControl:moveBodyToPoint(self.posX, self.posY, onClick, true)
end

return AnimModelBiographyNPC