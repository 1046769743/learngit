-- GuildTaskAchievementView
-- Author: Wk
-- Date: 2017-09-30
-- 仙盟任务成就界面
local GuildTaskAchievementView = class("GuildTaskAchievementView", UIBase);

function GuildTaskAchievementView:ctor(winName)
    GuildTaskAchievementView.super.ctor(self, winName);
end

function GuildTaskAchievementView:loadUIComplete()

end 

function GuildTaskAchievementView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

--初始化寻仙问道的界面
function GuildTaskAchievementView:initData()

	if not GuildControler:touchToMainview() then
		return 
	end

	for i=1,3 do
		local panel =  self["panel_"..i]
		panel:setVisible(false)
	end


	local function _callback(_param)
		if _param.result then
			dump(_param.result,"==获取寻仙问道的数据排行数据===",8)
			self.allData = _param.result.data
			GuildModel:setrenownGlorys(self.allData)
		else

		end
		self:setDataView()
		-- self.getsserveData = true
	end
	GuildServer:sendRinkGuildTask({},_callback)
end



function GuildTaskAchievementView:setDataView()
	local data = FuncGuild:getguildGloryData()
	-- dump(data,"寻仙问道的所有数据 =========")
	-- self.allData
	for i=1,table.length(data) do
		self:setguildGloryUI(data[i],i)
	end
end

function GuildTaskAchievementView:setguildGloryUI(data,_type)
	local i = _type
	local panel =  self["panel_"..i]
	panel:setVisible(true)
	local condition = data.condition
	local popularity = data.popularity


	local str = FuncTranslate._getLanguageWithSwap(data.des1,condition,popularity)
	panel.txt_3:setString(str)
	panel.txt_1:setString(GameConfig.getLanguage(data.des3))
	local rankType = data.rankType
	local plarId = GuildModel:getrenownGlorys(rankType)
	-- echo("=======rankType=========",rankType,plarId)
	if plarId then
		panel.mc_1:showFrame(2)
		
		local view = panel.mc_1:getViewByFrame(2).panel_tou
		self:showPlayIcon(view,plarId)
	else
		panel.mc_1:showFrame(1)
		panel.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.getButton, self,i),nil,true);
	end
end



--显示玩家头像
function GuildTaskAchievementView:showPlayIcon(_view,plarId)
	local playData = {}
	if plarId == UserModel:rid() then
		playData = {
			name = UserModel:name(),
			level = UserModel:level(),
			-- star = UserModel:star(),
			head = UserModel:head(),
			frame = UserModel:frame(),
			avatar = UserModel:avatar(),
			_id = UserModel:rid(),
		}
	else
		local data = GuildModel:getMemberInfo(plarId)
		playData = {
			name = data.name,
			level = data.level,
			-- star = data.star,
			head = data.head,
			frame = data.frame,
			avatar = data.avatar,
			_id = plarId,
		}
	end

	_view.txt_name:setString(playData.name)
	_view.txt_level:setString(playData.level)
	-- _view.mc_dou:showFrame(playData.star)
	_view.ctn_1:removeAllChildren()
	_view.ctn_1:setScale(0.7)
	local _avatar = playData.avatar
	local _headId = playData.head
	local _headFrameId = playData.frame
    GuildRedPacketModel:setPlayerHead(_view.ctn_1,_avatar,_headId)
	GuildRedPacketModel:setPlayerFrame(_view.ctn_1,_headFrameId)
	_view.mc_dou:setVisible(false)
	
	_view:setTouchedFunc(c_func(self.playInfoButton,self,playData),nil,true);

end


--玩家详情
function GuildTaskAchievementView:playInfoButton(playerInfo)
	local _playerId = playerInfo._id
	FriendViewControler:showPlayer(_playerId, playerInfo)
end



function GuildTaskAchievementView:getButton(_type)
	-- local isok = GuildModel:taskFanishIsAll()
	-- if isok then
	-- 	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3001"))
	-- 	return
	-- end

	-- echo("=====_type=====",_type)

	local data = FuncGuild:getguildGloryData()
	local taskId = data[_type].id

	local myRank = self.allData.myRank
	local rank =  myRank[tostring(data[_type].rankType)]
	if rank  and rank ~= nil then
		if rank > data[_type].condition then
			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3002"))--"条件不达标,不能抢")
			return
		end
	elseif rank == false then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3002")) --"条件不达标,不能抢")
		return
	end

	local function _callback(_param)
		if _param.result then
			-- dump(_param.result,"==揭榜数据===",8)

			local newdata = {
				[tostring(data[_type].rankType)] = UserModel:rid()
			}
			GuildModel:setrenownGlorys(newdata)


			local eventchat = {
				param1 =  UserModel:rid(),
				param2 = taskId,
				time   = TimeControler:getServerTime(),
				type   = 13,
			}
			
			GuildModel:insertDataToList(eventchat)


			EventControler:dispatchEvent(GuildEvent.REFRESH_UI)

			-- local data = FuncGuild:getguildGloryData()
			-- self:setguildGloryUI(data[tonumber(_type)],tonumber(_type))
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
		end
		self:initData()

	end

	local params = {
		id = taskId
	}
	GuildServer:sendRenwngloryGuildTask(params,_callback)
end



function GuildTaskAchievementView:press_btn_close()
	
	self:startHide()
end


return GuildTaskAchievementView;
