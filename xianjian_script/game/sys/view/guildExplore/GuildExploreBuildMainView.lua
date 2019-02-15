-- GuildExploreBuildMainView
--[[
	Author: wk
	Date:2018-07-05
	Description: TODO
]]

local GuildExploreBuildMainView = class("GuildExploreBuildMainView", UIBase);
local buildNameFrmae = {
	["101"] = 2,
	["102"] = 1,
}

local buildName = {
	["101"] = "蚩尤冢",
	["102"] = "神农庙",
}
function GuildExploreBuildMainView:ctor(winName,allData)
    GuildExploreBuildMainView.super.ctor(self, winName)
    self:createData(allData)
end

function GuildExploreBuildMainView:createData( allData )
	self.allData = allData
    self.cityID = self.allData.eventModel.tid or 101
end

function GuildExploreBuildMainView:loadUIComplete()
	self:registerEvent()
	self:initViewAlign()
	self:addSprite()
	self:initData()
	self.mc_name:showFrame(buildNameFrmae[tostring(self.cityID)])
	self.panel_tips.txt_2:setString("占领"..buildName[tostring(self.cityID)].."任意区域可开采        资源")
	self:setCitypos()
end 


function GuildExploreBuildMainView:setCitypos()
	local posArr = self:getFuncCityData("ExploreCity",self.cityID,"size" )
	local bgName = self:getFuncCityData("ExploreCity",self.cityID,"bg" )
	self:changeBg(bgName)
	for i=1,3 do
		local res = string.split(posArr[i], ",")
		local x = res[1]
		local y = res[2]
		local scale = res[3]
		self["ctn_"..(i+1)]:setPosition(cc.p(x,-y))
		self["ctn_"..(i+1)]:setScale(scale/100)
		self["panel_"..i]:setPosition(cc.p(x,-y))
		self["panel_"..i]:setScale(scale/100)
	end
end




function GuildExploreBuildMainView:onBattleExitResume()
	echo("=========建筑重取数据==========")
	local eventdata = GuildExploreEventModel:getMonsterEventModel()
	self:getServerData(eventdata)
end

function GuildExploreBuildMainView:getServerData( eventModel )
	-- eventModel = eventModel or self.allData.eventModel


	if eventModel.params and eventModel.params == FuncGuildExplore.lineupType.building then
		eventModel = self.allData.eventModel
	else
		eventModel = eventModel
	end
	if eventModel then
		local function cellFunc(data)
			self:createData( data )
			self:initData()
			local nameArr =  self:getFuncCityData("ExploreCity",self.cityID,"bottomName2" )
			local index = GuildExploreEventModel:getBuildPosGroup()
			local datas = {
				id = self.cityID,
				text = GameConfig.getLanguage(nameArr[index]),
				index = index,
				allData = self.allData,
			}
			GuildExploreEventModel:setcityData(datas)
			EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLORE_CITY_SERVE_ERROR_POS_REFRESHUI)
		end
		GuildExploreEventModel:showBuildUI(eventModel,cellFunc)
	end
end



function GuildExploreBuildMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_tips,UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_1,UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_name,UIAlignTypes.LeftTop)

end

function GuildExploreBuildMainView:registerEvent()
	GuildExploreBuildMainView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.startHide,self))
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPOREEVENT_DISPATCH_PANTNER,self.initData, self)
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPOREEVENT_SEND_PANTNER_UI,self.initData, self)

	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLORE_CITY_SERVE_ERROR_REFRESHUI, self.getServerData,self)

end

function GuildExploreBuildMainView:getFuncCityData( cfgsName,id,key )
	local cfgsName = cfgsName --"ExploreCity"
	local id = id
	local keyData 
	if key == nil then
		keyData = FuncGuildExplore.getCfgDatas( cfgsName,id )
	else
		keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,id,key)
	end
	
	return keyData
end


function GuildExploreBuildMainView:addSprite()
	local baseData  =  self:getFuncCityData("ExploreCity",self.cityID,"base" )
	local res = string.split(baseData[1], ",")
	local ability = res[1]
	local addAdility = res[2]
	local time = res[3]
	local _type = res[4]
	local itemId = res[5]
	local count = res[6]
	local addNum = res[7]
	local sprite = nil
	local icon = nil
	if _type == FuncGuildExplore.guildExploreResType  then
		local image   =  self:getFuncCityData("ExploreResource",itemId,"icon" )
		icon = FuncRes.getIconResByName(image)
		
	else
		local iconNme = FuncDataResource.getIconPathById(_type)
		icon = FuncRes.getIconResByName(iconNme)
	end
	sprite = display.newSprite(icon)
	sprite:size(35,35)
	self.ctn_1:removeAllChildren()
	self.ctn_1:addChild(sprite)

end


function GuildExploreBuildMainView:initData()

	local baseData  =  self:getFuncCityData("ExploreCity",self.cityID)
	local num = 3 
	for i=1,num do
		local panel = self["panel_"..i]
		-- panel.mc_1:showFrame(i)
		self:setPanelData(panel,i,baseData)
	end
end

--参加人数
function GuildExploreBuildMainView:getjoinCount(index)
	local occupy = self.allData.occupy
	local count = 0
	if occupy then
		local data = occupy[tostring(index)]
		if data then
			count = table.length(data)
		end
	end
	return count
end

--第几个位置有人
function GuildExploreBuildMainView:byIndexHavePeople(group,index)
	local occupy = self.allData.occupy
	local data = occupy[tostring(group)]
	if data then
		if data[tostring(index)] then
			return true
		end
	end
	return false
end

--我是不是存在
function GuildExploreBuildMainView:meIsExist(index,pos)
	local occupy = self.allData.occupy
	if occupy then
		local data = occupy[tostring(index)]
		if data then
			for k,v in pairs(data) do
				if v.roleInfo.id == UserModel:rid() then
					if tonumber(pos) == tonumber(k) then
						return true
					end
				end
			end
		end
	end
	return false
end

function GuildExploreBuildMainView:setPanelData(view,index,baseData)
	local blockNum = baseData.blockNum
	local levelArr = baseData.level
	local base = baseData.base
	local buff = baseData.buff
	local bottomName = baseData.bottomName
	local bottomMap = baseData.bottomMap

	local frame = tonumber(blockNum[index])
	echo("=====frame=========",frame,type(frame))
	view.mc_3:showFrame(frame)
	local playArr_mc = view.mc_3:getViewByFrame(frame)

	local haveNum = self:getjoinCount(index) --里面有几个人
	local buffFrame = nil
	if haveNum >= frame then
		buffFrame = 2
		view.mc_2:showFrame(buffFrame)
	else
		buffFrame = 1
		view.mc_2:showFrame(buffFrame)
	end
	
	--buff图片添加
	local image = self:getFuncCityData( "ExploreCity",self.cityID,"buffIcon" )
	local icon = FuncRes.iconBuff(image[index])
	local sprite = display.newSprite(icon)
	-- sprite:anchor(0,1)
	sprite:size(30,30)
	local panel = view.mc_2:getViewByFrame(buffFrame)
	local ctn = panel.ctn_1
	ctn:removeAllChildren()
	ctn:addChild(sprite)

	local des = self:getFuncCityData( "ExploreCity",self.cityID,"buffDes" )
	panel.txt_1:setString(GameConfig.getLanguage(des[index]))
	
	for i=1,frame do
		local hasPeople_mc = playArr_mc["mc_"..i]

		local isok = self:byIndexHavePeople(index,i)
		if isok then
			local isMe = self:meIsExist(index,i)  --自己是不是存在
			if isMe then
				hasPeople_mc:showFrame(1)
			else
				hasPeople_mc:showFrame(2)
			end
		else
			hasPeople_mc:showFrame(3)
		end

	end

	---入口名字
	local entranceIcon = bottomName[index]
	local iconPath = FuncRes.getGuildExporeIcon(entranceIcon)
	local nameSprite =  display.newSprite(iconPath)
	nameSprite:anchor(0,1.0)
	view.ctn_1:addChild(nameSprite)

	local mapIcon = bottomMap[index]
	local mapIconPath = FuncRes.getGuildExporeIcon(mapIcon)
	local nameSprite =  display.newSprite(mapIconPath)
	self["ctn_"..(1+index)]:addChild(nameSprite)

	view:setTouchedFunc(c_func(self.showBuildPosView, self,index),nil,true);

end

--显示建筑的坑位界面
function GuildExploreBuildMainView:showBuildPosView(index)
	echo("=======显示建筑的坑位界面========",index)
	self.group_index =  index
	GuildExploreEventModel:setBuildPosGroup(index)
	local nameArr =  self:getFuncCityData("ExploreCity",self.cityID,"bottomName2" )
	local name = GameConfig.getLanguage(nameArr[self.group_index])
	local arr = {
		eventId = self.allData.eventModel.eventId,
		id = self.cityID,
		text = name,
		index = index,  ---组
		allData = self.allData,
	}
	GuildExploreEventModel:setcityData(arr)
	WindowControler:showWindow("GuildExploreBuildPosView",arr)
end




function GuildExploreBuildMainView:initView()
	-- TODO
end


function GuildExploreBuildMainView:updateUI()
	-- TODO
end

function GuildExploreBuildMainView:deleteMe()
	-- TODO

	GuildExploreBuildMainView.super.deleteMe(self);
end

return GuildExploreBuildMainView;
