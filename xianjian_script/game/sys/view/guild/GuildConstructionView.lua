-- GuildConstructionView
-- Author: Wk
-- Date: 2017-09-30
-- 公会建筑升级界面
local GuildConstructionView = class("GuildConstructionView", UIBase);

function GuildConstructionView:ctor(winName)
    GuildConstructionView.super.ctor(self, winName);
end

function GuildConstructionView:loadUIComplete()

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_1,UIAlignTypes.Left)

	FuncCommUI.setScrollAlign(self.widthScreenOffset, self.scroll_1,UIAlignTypes.Middle,1,0)

	-- self:initData()
	self.Updatetime = 0
	-- self:addbubblesRunaction()
	-- self:scheduleUpdateWithPriorityLua(c_func(self.bubbles, self) ,0)

end 

function GuildConstructionView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end
--[[
function GuildConstructionView:addbubblesRunaction()
	-- local delaytime_1 = act.delaytime(0.2)
	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(4.4)
 	local scaleto_3 = act.scaleto(0.1,0)
 	local delaytime_3 = act.delaytime(0.5)
 	local callfun = act.callfunc(function ()
 		self:bubbles()
 	end)
	local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
	self.panel_qipao:runAction(act._repeat(seqAct))

end
--气泡
function GuildConstructionView:bubbles()
	local sumtime = FuncGuild.getBoundsTime()
	-- if self.Updatetime == 0 or math.fmod(self.Updatetime, sumtime) == 0 then
		local ischampions = GuildModel:judgmentIsForZBoos()  --是否是盟主
		local strtable = nil
		if ischampions then
			strtable =  {
				[1] = "#tid_group_qipao_101",
				[2] = "#tid_group_qipao_102",
				[3] = "#tid_group_qipao_103",
				[4] = "#tid_group_qipao_104",
				[5] = "#tid_group_qipao_105",
			} 
		else
			strtable =  {
				[1] = "#tid_group_qipao_103",
				[2] = "#tid_group_qipao_104",
				[3] = "#tid_group_qipao_105",
			} 
		end

		local idex = math.random(1,#strtable)
		local str = GameConfig.getLanguage(strtable[idex])
		local panel = self.panel_qipao
		panel.txt_story2:setString(str)
	-- end
	-- self.Updatetime = self.Updatetime + 1

end
]]
function GuildConstructionView:initData()

	local alllocalbuild = FuncGuild.getguildBuildAllData()
	local allData = {1,2,3,4,6}
	self.panel_1:setVisible(false)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_1);
        self:updateItem(view,itemData)
        return view        
    end
	local params =  {
        {
            data = allData,  ---alldata
            createFunc = createCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 15,
            offsetY = 0,
            widthGap = 10,
            heightGap = 5,
            itemRect = {x = 0, y = -410, width = 270, height =410},
            perFrame = 0,
        }
        
    }
    self.scroll_1:cancleCacheView();
    self.scroll_1:hideDragBar()
	self.scroll_1:styleFill(params)
end
function GuildConstructionView:updateItem(view,itemData)
	-- dump(itemData,"222222222222")
	local buildtable = GuildModel:getBuildsLevel()
	local buildvotes = GuildModel:getBuildsVotes()
	-- dump(buildtable, "\n\nbuildtable===")
	-- dump(buildvotes,"建议人数==")
	local level = buildtable[tonumber(itemData)]
	local jianyiNum =  buildvotes[tonumber(itemData)] ---建议人数
	if not level then
		return
	end
	local buildID = itemData
	local woodnum = GuildModel:getWoodCount()   ---树木的资源
	view.txt_lv:setString(level..GameConfig.getLanguage("#tid_guildAddCell_001")) 
	view.txt_jianyi:setString(jianyiNum..GameConfig.getLanguage("#tid_guildConstruction_001")) 
	local alldata = FuncGuild.getguildBuildUpAllData()
	-- dump(alldata,"222222222222",9)
	local lastdata  = alldata[tostring(buildID)][tostring(level)]
	local data  = alldata[tostring(buildID)][tostring(level)]
	local builddata =  FuncGuild.getguildBuildAllData()
	-- dump(builddata,"=====ffffff=====7记得数据",9)

	local buildname =  builddata[tostring(buildID)].name
	local name = GameConfig.getLanguage(buildname)
	view.txt_1:setString(name)
	-- dump(data,"==========7记得数据",9)
	if data.cost ~= nil then
		view.txt_jianyi:setVisible(true)
		view.rich_2:setVisible(true)
		view.txt_3:setVisible(true)
		view.panel_icon:setVisible(true)
		view.rich_2:setString(GameConfig.getLanguage(data.lvUpDes))
		local issendsuggest = false
		local issuggest = false
		local memberExts = GuildModel.memberExts
		-- dump(memberExts,"233333333333333333333333332")
		for k,v in pairs(memberExts) do
			if k == UserModel:rid()	then
				if v.buildId ~= nil then
					issendsuggest = true
					if v.buildId == buildID then
						issuggest = true
					end
				end
			end
		end


		-- local isischampions  = GuildModel:judgmentIsForZBoos()  ----是否是盟主和副盟主
		local appointRight = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"development")
		if appointRight == 1 then
			view.mc_1:showFrame(1)
			view.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.upgrade, self,buildID,data),nil,true);	
			-- FilterTools.clearFilter(view.mc_1:getViewByFrame(1).btn_1)
		else
			if issendsuggest then
				if issuggest then
					view.mc_1:showFrame(4)
					view.mc_1:getViewByFrame(4).btn_1:setTouchedFunc(c_func(self.nosuggestupgrade, self,view,buildID),nil,true);
				else
					--置灰，不可建议
					FilterTools.setGrayFilter(view.mc_1:getViewByFrame(3).btn_1)
					view.mc_1:showFrame(3)
					view.mc_1:getViewByFrame(3).btn_1:setTouchedFunc(c_func(self.yiJInsuggestupgrade, self,view,buildID),nil,true);
				end
			else
				view.mc_1:showFrame(3)
				view.mc_1:getViewByFrame(3).btn_1:setTouchedFunc(c_func(self.suggestupgrade, self,view,buildID),nil,true);
			end
		end

		local cost = data.cost -- string.split(data.cost[1],",")
		-- if cost == FuncDataResource.RES_TYPE.WOOD then
		if cost ~= nil then
				if woodnum >= cost then
					view.txt_3:setColor(cc.c3b(40,0, 0))
				else
					view.txt_3:setColor(self:HEXtoC3b("0x7D563C"))
				end
			-- end
			view.txt_3:setString(cost)
		else
			view.txt_3:setVisible(false)
		end
	else
		view.mc_1:showFrame(2)
		view.txt_jianyi:setVisible(false)
		view.rich_2:setVisible(false)
		view.txt_3:setVisible(false)
		view.panel_icon:setVisible(false)
	end

	if jianyiNum == nil or jianyiNum == 0 then
		view.txt_jianyi:setVisible(false)
	end

	self:addBuildIcon(view,itemData)
end

function GuildConstructionView:yiJInsuggestupgrade()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showTips(GameConfig.getLanguage("#tid_guildConstruction_002")) 
end

function GuildConstructionView:addBuildIcon(view,itemData)
	local builddata = FuncGuild.getguildBuildAllData()
	local buildID =  itemData
	local buildicon =  builddata[tostring(buildID)].buildid

	view.mc_jianzhu:showFrame(buildID)

	-- local buildspritename = FuncRes.iconGuild(buildicon)
	-- buildsprite = display.newSprite(buildspritename)
	-- buildsprite:anchor(0.5,0.5)
	-- buildsprite:setPosition(cc.p(0,0))
	-- view.ctn_1:addChild(buildsprite)
	-- if buildID ~= 3 then
	-- 	buildsprite:size(view.ctn_1.ctnWidth - 10, view.ctn_1.ctnHeight - 10);
	-- else
	-- 	buildsprite:setScale(0.50)
	-- end
end

--升级
function GuildConstructionView:upgrade(buildID,data)
	if not GuildControler:touchToMainview() then
		return 
	end
	-- echo("升级==============",buildID)
	-- local isok = GuildControler:notpermissions()
	-- if not isok then
	-- 	return 
	-- end
	self.buildID = buildID
	local dailyCost =  GuildModel:dailyCost()
	local cost = data.cost
	local woodnum = GuildModel:getWoodCount() 
	if woodnum < cost then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guildCompText_006")) 
		return
	elseif woodnum < cost + dailyCost  then
		WindowControler:showWindow("GuildTwoSureView",c_func(self.sendupgrade, self))
		return
	end

	local buildtable = GuildModel:getBuildsLevel()
	local mainlevel = buildtable[1]
	local level = buildtable[tonumber(buildID)]
	if tonumber(buildID) ~= 1 then
		if level >= mainlevel then
			WindowControler:showTips(GameConfig.getLanguage("#tid_guildConstruction_003")) 
			return 
		end
	end

	self:sendupgrade()
	
end
function GuildConstructionView:sendupgrade()
		local function _callback(_param)
		if _param.result then
			-- dump(_param.result,"建筑升级返回数据",8)
			local num = _param.result.data.wood
			local builddata = _param.result.data.builds
			GuildModel:setBuildsLevel(builddata)
			-- GuildModel:setWoodCount(num)
			GuildModel:updateGuildResource(_param.result.data)
			GuildModel:updateSkillGroupsData( _param.result.data )
			EventControler:dispatchEvent(GuildEvent.REFRESH_GUILD_WOOD_EVENT, {currentShopId = FuncShop.SHOP_TYPES.GUILD_SHOP})

			self:initData()
			-- WindowControler:showTips("升级成功")
			local builddata = {
				buildID = self.buildID,
				level = builddata[tostring(self.buildID)]
			}
			WindowControler:showWindow("GuildUpgSucView",builddata)
		else
			--错误的情况
		end
	end 

	local params = {
		id = self.buildID,
	}
	GuildServer:sendBuilding(params,_callback)
end

--建议升级
function GuildConstructionView:suggestupgrade(view,buildID)
	-- echo("建议升级")
	if not GuildControler:touchToMainview() then
		return 
	end
	local function _callback(_param)
		if _param.result then
			-- dump(_param.result,"建筑升级建议返回数据",8)
			local buildvotes = GuildModel:getBuildsVotes()
			local jianyiNum =  buildvotes[tonumber(buildID)] ---建议人数
			GuildModel:getBuildsVotes()[tonumber(buildID)] = jianyiNum + 1
			-- dump(GuildModel.memberExts,"344444444444444",8)
			local rid = UserModel:rid()
			-- if GuildModel.memberExts[rid] ~= nil then
				GuildModel.memberExts[tostring(rid)] = {
					buildId = buildID
				}
			-- dump(GuildModel.memberExts,"555555555555555",8)
			-- end

			-- view.txt_jianyi:setString((jianyiNum) .."人建议提升")
			-- view.txt_jianyi:setVisible(true)
			-- view.mc_1:showFrame(4)
			-- view.mc_1:getViewByFrame(4).btn_1:setTouchedFunc(c_func(self.nosuggestupgrade, self,view,buildID),nil,true);
			self:initData()
			WindowControler:showTips(GameConfig.getLanguage("#tid_guildConstruction_004")) 
		else
			--错误的情况
		end
	end 


	local params = {
		id = buildID,
	}
	GuildServer:sendBuildingVote(params,_callback)
end
--取消升级
function GuildConstructionView:nosuggestupgrade(view,buildID)
	-- echo("取消升级")
	if not GuildControler:touchToMainview() then
		return 
	end

	local function _callback(_param)
		if _param.result then
			-- dump(_param.result,"建筑升级取消建议返回数据",8)
			-- local count = -(_param.result.data.count)
			local rid = UserModel:rid()
			if GuildModel.memberExts[rid] ~= nil then
				GuildModel.memberExts[rid] = nil
			end

			local buildvotes = GuildModel:getBuildsVotes()
			local jianyiNum =  buildvotes[tonumber(buildID)] ---建议人数
			if jianyiNum - 1 >= 0 then
				GuildModel:getBuildsVotes()[tonumber(buildID)] = jianyiNum - 1
			end
			-- if jianyiNum <= 0 then
			-- 	view.txt_jianyi:setVisible(false)
			-- else
			-- 	view.txt_jianyi:setString((jianyiNum) .."人建议提升")
			-- 	view.txt_jianyi:setVisible(true)
			-- end
			-- view.mc_1:showFrame(3)
			-- view.mc_1:getViewByFrame(3).btn_1:setTouchedFunc(c_func(self.suggestupgrade, self,view,buildID),nil,true);
			
			self:initData()
			WindowControler:showTips(GameConfig.getLanguage("#tid_guildConstruction_005")) 

		else
			--错误的情况
		end
	end 

	local params = {
		id = 0,
	}
	GuildServer:sendBuildingVote(params,_callback)



end

function GuildConstructionView:press_btn_close()
	
	self:startHide()
end
function GuildConstructionView:HEXtoC3b(hex)
    local flag = string.lower(string.sub(hex,1,2))
    local len = string.len(hex)
    if len~=8 then
        print("hex is invalid")
        return nil 
    end
    if flag ~= "0x" then
        print("not is a hex")
        return nil
    end
    local rStr =  string.format("%d","0x"..string.sub(hex,3,4))
    local gStr =  string.format("%d","0x"..string.sub(hex,5,6))
    local bStr =  string.format("%d","0x"..string.sub(hex,7,8))

    -- local ten = string.format("%d",hex)
    ten = cc.c3b(rStr,gStr,bStr)
    return ten
end

return GuildConstructionView;
