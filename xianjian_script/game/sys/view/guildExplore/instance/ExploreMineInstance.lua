--
-- Author: xd
-- Date: 2018-07-17 15:17:44
--

local ExploreMineInstance = class("ExploreMineInstance", ExploreBaseInstance)

function ExploreMineInstance:initViewSize(  )
	self.mySize = {width=FuncGuildExplore.gridWidth * 2,height =FuncGuildExplore.gridHeight *4}
end


local stateToFrameMap = {
	[0] = 3,
	[1] =2,
	[2] =1
}

--当数据发生变化
function ExploreMineInstance:onDataChange( changeData )
	if not self.myView then
		return
	end
	-- dump(self._data.params,"___params")
	if self._data.type == FuncGuildExplore.gridTypeMap.mine then
		--获取3个矿洞状态
		for i=1,3 do
			local state = self._data.params["state"..i] or 0
			self.myView.panel_player["mc_"..i]:showFrame(stateToFrameMap[state])
		end
	end
	-- self:updateLeftTime()
	
end

--计算矿脉 倒计时
function ExploreMineInstance:updateLeftTime(  )

	--暂时废弃
	local targetTime = self._data.params.finishTime
	if targetTime == -1 then
		self.myView.panel_time.txt_1:setVisible(false)
	else
		local leftTime = targetTime -TimeControler:getServerTime() 
		local str = TimeControler:turnTimeSec( leftTime,TimeControler.timeType_hhmmss )
		self.myView.panel_time.txt_1:setString(str)
		self.myView.panel_time.txt_1:setVisible(true)
	end
	

end



return ExploreMineInstance