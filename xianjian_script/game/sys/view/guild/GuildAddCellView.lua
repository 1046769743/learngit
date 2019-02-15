-- GuildAddCellView
-- Author: Wk
-- Date: 2017-09-30
-- 公会创加入通用cell界面
local GuildAddCellView = class("GuildAddCellView", UIBase);

function GuildAddCellView:ctor(winName)
    GuildAddCellView.super.ctor(self, winName);
end

function GuildAddCellView:loadUIComplete()

end 

function GuildAddCellView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

function GuildAddCellView:initData(itemdata,selectType)
	local level = itemdata.level
	local guildname = itemdata.name
	local guilddata = FuncGuild.getGuildLevelByPreserve(level)
	local sumpeoplenum =  tonumber(guilddata.nop)
	local hasnum = itemdata.members  or itemdata.count or 0--有几个成员
	local des = FuncGuild.getdefaultDec()--仙盟描述
	if itemdata.desc ~= nil then
		if itemdata.desc ~= "" then
			des = itemdata.desc
		end
	end

	local frame = itemdata.afterName or 1  ---那个盟

	local panel = self.panel_1
	local guildIcon =  {
		borderId = itemdata.logo or 1,
		bgId = itemdata.color or 1,
		iconId = itemdata.icon or 1,
	}
	panel.UI_1:initData(guildIcon)
	--等级
	local levelpanel = panel.txt_1  
	levelpanel:setString(level..GameConfig.getLanguage("#tid_guildAddCell_001"))
	--描述
	local describe = panel.txt_4
	describe:setString(des)

	local groupID  = itemdata.qqGroup
	if groupID == nil or  tonumber(groupID) == 0 then
		groupID = GameConfig.getLanguage("#tid_group_guild_1506")
	end

	panel.txt_6:setString("  "..groupID)

	local peoplenumber = panel.txt_3
	peoplenumber:setString(hasnum.."/"..sumpeoplenum)

	local button =  panel.mc_1

	local guildName = GuildModel.guildName
	local data = FuncGuild.getguildType()
	
	local namestid  = data[tostring(frame)].afterName
	local names = GameConfig.getLanguage(namestid)
		--仙盟名称
	local name = panel.txt_2
	name:setString(guildname..names)


	panel.mc_wenzi:setVisible(false)
	--:showFrame(frame)
	if hasnum == sumpeoplenum then
		button:showFrame(5)
	else
		--处理按钮
		self:disposeButton(itemdata)
	end

	if selectType == 3 then
		button:showFrame(4)
		button:getViewByFrame(4).btn_1:setTouchedFunc(c_func(self.notagreebutton, self,itemdata),nil,true);
		button:getViewByFrame(4).btn_2:setTouchedFunc(c_func(self.agreebutton, self,itemdata),nil,true);
	end
end

--不同意
function GuildAddCellView:notagreebutton(itemdata)
	-- if not GuildControler:touchToMainview() then
	-- 	return 
	-- end

	GuildModel:removeinvitedToList(itemdata)
	EventControler:dispatchEvent(GuildEvent.GUILD_REFRESH_invite_EVENT)
end
---同意
function GuildAddCellView:agreebutton(itemdata)
	-- if not GuildControler:touchToMainview() then
	-- 	return 
	-- end
	local function _callback(_param)
		-- dump(_param.result,"申请加入的数据返回",8)
		if _param.result then
			--加入按钮
			GuildModel:removeinvitedToList(itemdata)
			-- EventControler:dispatchEvent(GuildEvent.GUILD_REFRESH_invite_EVENT)
			EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.RAID});
			self:press_btn_close()
			function callfun()
				WindowControler:showTips("等待盟主确认")
				EventControler:dispatchEvent(GuildEvent.GUILD_REFRESH_invite_EVENT)
			end
			GuildControler:getMemberList(1,callfun)		
			-- GuildControler:getMemberList(1)
		else
			--错误和没查找到的情况
		end
	end 

	local guildId = itemdata._id
	local params = {
		id = guildId
	};
	GuildServer:joinGuild(params,_callback)
end


function GuildAddCellView:disposeButton(itemdata)
	local button = self.panel_1.mc_1
	local needApply = itemdata.needApply
	if needApply ~= 0 then 
		local _applist = GuildModel:applyingGuild()
		dump(UserModel:guildExt(),"申请列表数据11111111",9)
		local app = false
		if _applist ~= nil then
			for k,v in pairs(_applist) do
				if k == itemdata._id then
					if v ~= 1 then
						app = true
					end
				end
			end
		end
		if app then
			button:showFrame(2)
			button:getViewByFrame(2).btn_1:setTouchedFunc(c_func(self.sendnotAppAndAdd, self,itemdata),nil,true);
		else
			button:showFrame(1)
			button:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.sendAppAndAdd, self,itemdata,1),nil,true);
		end
	else
		button:showFrame(3)
		button:getViewByFrame(3).btn_1:setTouchedFunc(c_func(self.sendAppAndAdd, self,itemdata,2),nil,true);
	end
end
function GuildAddCellView:sendnotAppAndAdd(itemdata)

	local function _callback(_param)
		dump(_param.result,"取消申请加入的数据返回",8)
		if _param.result then
			itemdata.app = nil

			
			self:disposeButton(itemdata)  
			WindowControler:showTips(GameConfig.getLanguage("#tid_guildAddCell_002"))
		else
			--错误和没查找到的情况
		end
	end 

	local guildId = itemdata._id
	local params = {
		id = guildId
	};
	GuildServer:cancelApply(params,_callback)

end
--申请和加入
function GuildAddCellView:sendAppAndAdd(itemdata,_type)

	if _type == 1 then
	 	local num =	GuildModel:getUserModelguildExt()
	 	if num >=  FuncGuild.getAppNum() then  
	 		WindowControler:showTips(GameConfig.getLanguage("#tid_guildAddCell_003")) 
	 		return 
	 	end
	end


	local function _callback(_param)
		dump(_param.result,"申请加入的数据返回",8)
		if _param.result then
			if _type == 1 then  ----申请按钮
				itemdata.app = true
				self:disposeButton(itemdata)
				
				WindowControler:showTips(GameConfig.getLanguage("#tid_guildAddCell_004"))
			else    --加入按钮
				EventControler:dispatchEvent(GuildEvent.CLOSE_ADD_GUILD_VIEW_EVENT)
				local _str = string.format(GameConfig.getLanguage("#tid_guildAddCell_005"), itemdata.name) 
				WindowControler:showTips(_str)
				-- GuildControler:getGuildInfoData()
				GuildControler:getMemberList(1)
				GuildBossModel:updateTimeFrame()
			end
		else
			--错误和没查找到的情况
		end
	end 


	local guildId = itemdata._id
	local params = {
		id = guildId
	};
	GuildServer:joinGuild(params,_callback)
end



function GuildAddCellView:press_btn_close()
	
	self:startHide()
end


return GuildAddCellView;
