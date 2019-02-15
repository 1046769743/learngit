-- CompAirBubblesView
--气泡功能
--2017-09-09
--@Author:wk

--[[
"1": {
      "Appear": 30,     ---显示时间(单位为帧数,30帧为1秒）
      "display": 60,	----停留时间(单位为帧数）
      "function": "world",	----需要配置的功能
      "interval": 120,		---间隔时间(单位为帧数）
      "invalidtime": [    --失效条件
        "1,10204"
      ],
      "quote" : 1,    ---quote类型
      "ico" : "star",
      "language": "#tid6001",   --配置语言
      "npc": 1,
      "prior": 1,		---优先级
      "taketime": [   --生效条件
        "1,10203"
      ]
    },
]]


local CompAirBubblesView = class("CompAirBubblesView", InfoBubbleBase);
--引用类型枚举(1奇侠头像、2道具、3功能、4宝箱）
local _iconType = {
	partnerIcon = 1,
	item = 2,
	system = 3,
	treasureBox = 4,
	monster = 5,
	head = 6,
}
local preames_type = {
	USER_NAME = "1" ---主角名称

}



--大背景方向枚举
local bigBgFrameType = {
	[1] = 3,--右下
} 
--小背景方向枚举
local smallBgFrameType = {
	lower_right_corner = 1,--右下角
	right_level = 2,--水平向右
	following = 4,--下面
	above = 5,--上面
	max_lower_left = 6,--带大图的左下
	lower_left = 7,--不带大图左下
	
}


-- datainfor --数据详情
function CompAirBubblesView:ctor(winName,datainfor)
    CompAirBubblesView.super.ctor(self, winName);
    self.datainfor = datainfor
end

function CompAirBubblesView:loadUIComplete()

	-- self:initData()
	-- self.appeartime = 1
	-- self.displaytime = 3
	-- self.intervaltime = 4
	-- self:startAnimation()
	-- self.panel_1.mc_1:showFrame(4)
	self.callback = nil
	self.showNum = 0
end 

function CompAirBubblesView:registerEvent()

end
--数据是否为空  datatable = {systemname = ,npc = true or false}
function CompAirBubblesView:dataIsNil(datatable)
	--eg: world --六界第一
	self.datatable = datatable
	local systemname = datatable.systemname
	local alldata = FuncHome.getBubbleData()
	local singedata = alldata[systemname]
	local npc  = datatable.npc 
	local issubtypes = datatable.issubtypes


	if singedata == nil then
		return false
	end
	dump(singedata,"单个气泡数据数据",9)
	self.datainfor = nil
	for i=1,table.length(singedata) do
		local index = tostring(i)
		local bubbledata = singedata[index]
		local taketime = bubbledata.takeTme
		local invalidTime = bubbledata.invalidTime
		local valueA = {} --{t = nil,v =nil }
		local valueB = {}
		for _a = 1,#taketime do
			valueA[_a] = {}
			local arrTable = string.split(taketime[_a], ",")
			valueA[_a].t = tonumber(arrTable[1])
			valueA[_a].v = tonumber(arrTable[2])
		end
		for _b = 1,#invalidTime do
			valueB[_b] = {}
			local arrTable = string.split(invalidTime[_b], ",")
			valueB[_b].t = tonumber(arrTable[1])
			valueB[_b].v = tonumber(arrTable[2])
		end
		local iscompleteA =  UserModel:checkCondition( valueA )
		local iscompleteB =  UserModel:checkCondition( valueB )
		
		if iscompleteA == nil  and iscompleteB ~= nil then  --完成
			if issubtypes then
				if valueA[2] ~= nil then
					if systemname  == FuncCommon.SYSTEM_NAME.ROMANCE then
							self.datainfor = bubbledata
					elseif systemname  == FuncCommon.SYSTEM_NAME.PVE then
						if WorldModel:hasPVEStarBoxes() then
							self.datainfor = bubbledata
						else
							self.datainfor = nil
						end
					end
					break
				end
			else
				self.datainfor = bubbledata
				break
			end
		end
		
		-- dump(valueA,"33333333333")
	end
	if self.datainfor == nil then
		return false
	end
	if npc then
		if self.datainfor.npc == nil then
			return false
		end
	end


	local pos = self:setCtnPos(systemname)
	return true,pos

end
function CompAirBubblesView:revertData(newData)
	-- self.datainfor = newData
	-- self:initData()
	-- dump(self.datainfor,"获得的数据结构")
end

function CompAirBubblesView:initData()
	
	local sprite = self:byTypegetResourse()
	if sprite ~= nil then
		self:showIconDataView(sprite)
	else 
		self:showNotIconDataView()
	end

end

function CompAirBubblesView:setCtnPos( systemname )
	self.bgFrame = nil
	local _pos = {x = 0,y = 0,node_x = 0,node_y = 0}
	local offset = 50
	if systemname == FuncCommon.SYSTEM_NAME.PVE or systemname == FuncCommon.SYSTEM_NAME.PVP then--FuncCommon.SYSTEM_VIEW_TO_NAME.WorldMainView then
		_pos.x = -(offset*2)
		_pos.y = offset - 20
	elseif systemname == FuncCommon.SYSTEM_NAME.QUEST then
		-- _pos.x = offset-40
		-- _pos.y = -(offset*1.8)
		-- _pos.node_x = -(offset*2) 
		-- _pos.node_y = offset - 20
		_pos.x = offset*4
		_pos.y = offset *3.5
		self.bgFrame = smallBgFrameType.lower_left --smallBgFrameType.above
		self.selecttype = systemname
	elseif systemname == FuncCommon.SYSTEM_NAME.FRIEND then
		_pos.x = offset*5
		_pos.y = offset	
		self.bgFrame = smallBgFrameType.lower_left
		self.selecttype = systemname
	else
		_pos.x = -offset+10
		_pos.y = offset
		self.bgFrame = smallBgFrameType.following
		self.iconFrame = 3
	end
	return _pos
end

function CompAirBubblesView:getIntervalTime()
	local appeartime = 1
	local displaytime = 3
	local intervaltime = 1
	if self.datainfor ~= nil then
		local appear = self.datainfor.appear
		local display = self.datainfor.display
		-- local interval = self.datainfor.interval
		local gametime = GameVars.GAMEFRAMERATE
		appeartime = math.floor(appear/gametime)
		displaytime = math.floor(display/gametime)
		-- intervaltime = math.floor(interval/gametime)
	end
	return appeartime,displaytime--,intervaltime
end

--显示带资源图标的
function CompAirBubblesView:showIconDataView(_sprite)
	local modefFrame = 1
	if self.selecttype == FuncCommon.SYSTEM_NAME.FRIEND then
		self.bgFrame = smallBgFrameType.max_lower_left
		modefFrame = 3
	elseif self.selecttype == FuncCommon.SYSTEM_NAME.QUEST then
		self.bgFrame = smallBgFrameType.max_lower_left
		modefFrame = 3
	end
	self.panel_1.mc_1:showFrame(self.bgFrame or 3)   --显示最长的那个背景
	self.panel_1.mc_2:showFrame(modefFrame)   --显示带图标圆框
	local panel = self.panel_1.mc_2:getViewByFrame(modefFrame)
	panel.panel_1.ctn_1:removeAllChildren()
	panel.panel_1.ctn_1:addChild(_sprite)


	local skillsArrtStr = self:setStringPrames()

	-- if string.find(skillsArrtStr,"#1") then
	-- 	local itemnumber = self:getcheckpointNumber()  ---剩余的次数 
	-- 	skillsArrtStr = string.gsub(skillsArrtStr,"#1", tostring(itemnumber));
	-- 	panel.rich_1:setString(skillsArrtStr)
	-- else
		panel.rich_1:setString(skillsArrtStr)
	-- end
	
	if self.datainfor.parameter ~= nil then
		local str = GameConfig.getLanguage(self.datainfor.parameter)
		panel.txt_1:setString(str)
		panel.txt_1:setVisible(true)
	else
		panel.txt_1:setVisible(false)
	end
end
function CompAirBubblesView:setcellString(cellBack)
	self.showNum = self.showNum + 1
	local language =  self.datainfor.language
	local strArr = string.split(language,",")

	if self.showNum > table.length(strArr) then
		self.showNum = 1
	-- elseif self.showNum ==  table.length(strArr) then
		if not self.datatable.npc then
			if self.callback == nil then
				if cellBack then
					cellBack(self.datainfor.intervalTime)
					self.callback = cellBack
				end
			end
		end
	end
	local sprite = self:byTypegetResourse()
	if sprite ~= nil then
		local panel = self.panel_1.mc_2.currentView
		local skillsArrtStr = self:setStringPrames(nil,self.showNum)
		panel.rich_1:setString(skillsArrtStr)
	else 
		local panel = self.panel_1.mc_2.currentView
		local str = self:setStringPrames(nil,self.showNum)
		panel.rich_1:setString(str)
	end
end

function CompAirBubblesView:setStringPrames(data,index)
	data = data or self.datainfor 
	local language = data.language
	local preames = data.preames
	local strArr = string.split(language,",")
	local stringArr = {}

	if preames ~= nil then
		for i=1,#preames do
			local preamesArr = string.split(preames[i],",")
			for x=1,#preamesArr do
				local str  = GameConfig.getLanguage(strArr[x])
				if tostring(preamesArr[x]) == preames_type.USER_NAME then
					local name = UserModel:name()
					str = string.gsub(str, "#" .. tostring(i), name)
					stringArr[x] =  str 
				else
					stringArr[x] =  str 
				end
			end
		end
	else
		stringArr[1] = GameConfig.getLanguage(strArr[1])
	end

	return stringArr[index] or stringArr[1]
end




function CompAirBubblesView:getcheckpointNumber()
	local bubbledata = self.datainfor
	local taketime = bubbledata.takeTme
	local invalidTime = bubbledata.invalidTime
	local valueA = {}
	local valueB = {}
	local number = 0
	for _a = 1,#taketime do
		valueA[_a] = {} 
		local arrTable = string.split(taketime[_a], ",")
		valueA[_a].t = tonumber(arrTable[1])
		valueA[_a].v = tonumber(arrTable[2])
		-- local iscompleteA =  UserModel:checkCondition( valueA )
		-- if  iscompleteA == nil then
		-- 	number = number + 1
		-- end
	end
	for _b = 1,#invalidTime do
		valueB[_b] = {}
		local arrTable = string.split(invalidTime[_b], ",")
		valueB[_b].t = tonumber(arrTable[1])
		valueB[_b].v = tonumber(arrTable[2])
	end


	local riaddata =  FuncChapter.getRaidData()
	local numberraid = {}
	local _index = 1
	for k,v in pairs(riaddata) do
		if tonumber(k) >= tonumber(valueA[1].v)   and tonumber(k) <= tonumber(valueB[1].v) then
			numberraid[_index] = {}
			numberraid[_index].t  = 4
			numberraid[_index].v = k
			_index = _index+1
		end
	end
	-- dump(numberraid,"333333333",6)
	for i=1,#numberraid do
		local iscompleteA =  UserModel:checkCondition( {numberraid[i]} )
		if  iscompleteA == nil then
			number = number + 1
		end
	end
	-- local sumtimes =  valueB[1].v - valueA[1].v
	-- echo("+==============",valueB[1].v,valueA[1].v)
	local sumtimes = 5--WorldModel:getBetweenRaidNum(valueA[1].v, valueB[1].v) 
	-- echo("============sumtimes=====",sumtimes,number,sumtimes - number + 1)
	return sumtimes - number + 1

end

--显示不带资源图标的
function CompAirBubblesView:showNotIconDataView()
	local modefFrame = 2
	if self.selecttype == FuncCommon.SYSTEM_NAME.FRIEND then
		self.bgFrame = smallBgFrameType.lower_left
		-- modefFrame = 
	end
	self.panel_1.mc_1:showFrame(self.bgFrame or 1)   --显示最短的那个背景默认右下角箭头、
	self.panel_1.mc_2:showFrame(modefFrame)   --显示不带图标圆框，只显示文字资源
	local panel = self.panel_1.mc_2:getViewByFrame(modefFrame)

	local str = self:setStringPrames()

	-- local str = GameConfig.getLanguage(strArr)
	panel.rich_1:setString(str)

end

--获取图片资源
function CompAirBubblesView:byTypegetResourse()
	local _sprite = nil
	local typeID =  tonumber(self.datainfor.quote)
	local image = self.datainfor.ico
	if image ~= nil then
		if typeID == _iconType.partnerIcon then   ---伙伴道具
			local partner =  FuncPartner.getPartnerById(image)
			_sprite = FuncRes.iconHead( partner.icon )	
			-- return self:setIconRound(_sprite)
		elseif typeID == _iconType.item   then  ---道具图标
			_sprite =  FuncRes.iconItem(image)
		elseif typeID == _iconType.system   then   ---系统图标资源
			_sprite = FuncRes.iconSys(image)
		elseif typeID == _iconType.treasureBox   then   ---宝箱资源
			_sprite = FuncRes.iconTowerEvent(image)
		elseif typeID == _iconType.monster   then   ---怪物资源
            local data = FuncHome.getBossInfo(image)
            local icon = data.icon
            _sprite = FuncRes.iconHead(icon )
            -- return self:setIconRound(_sprite)
        elseif typeID ==  _iconType.head then
        	_sprite = FuncRes.iconHead( image )
		end

		return self:setIconRound(_sprite)
	else
		return nil
	end
end
function CompAirBubblesView:setIconRound(icon,_Scale)
	local iconSprite = display.newSprite(icon)
	iconSprite:setScale(_Scale or 1)
    local headMaskSprite = display.newSprite(FuncRes.iconOther("icon_other_bgMask1"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:setScale(0.2)
    local spritesico = FuncCommUI.getMaskCan(headMaskSprite,iconSprite)
    -- spritesico:setScale(0.8)
    -- _ctn:addChild(spritesico,10)
    return spritesico
end
function CompAirBubblesView:startAnimation()
-- self.Appeartime  --显示时间(单位为帧数,30帧为1秒）
-- self.displaytime  --停留时间(单位为帧数
-- self.intervaltime --间隔时间(单位为帧数）
	-- local anchor = 
	self.appeartime = 1
	self.displaytime = 3
	self.intervaltime = 4

	local view = self.panel_1
	view:setScale(0)
	view:setAnchorPoint(cc.p(1,0))
	local delaytime_1 = act.delaytime(self.appeartime)
	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(self.displaytime)
 	local scaleto_3 = act.scaleto(0.1,0)
 	local delaytime_3 = act.delaytime(self.intervaltime - 1)

	local seqAct = act.sequence(delaytime_1,scaleto_1,scaleto_2,delaytime_2,scaleto_3,delaytime_3)
	view:runAction(act._repeat(seqAct))


end
--//关闭页面
function CompAirBubblesView:pressButtonClose()
		-- self:startHide();
end


return CompAirBubblesView;
