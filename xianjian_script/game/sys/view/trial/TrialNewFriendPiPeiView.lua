-- TrialNewFriendPiPeiView
-- TrialNewFriendPiPeiView
--time 2017/05/13
----@Author:wukai
 ---玩家推送
local TrialNewFriendPiPeiView = class("TrialNewFriendPiPeiView", UIBase);
--[[  local data = {
        name = frienddata.name,
        id = tonumber(frienddata.uid),
        avatar = frienddata.avatar,
        _type = types,
        diffic =  index,
        sec = frienddata.sec,
        rid = friendRid,
        friendalldata = frienddata,
    }]]

function TrialNewFriendPiPeiView:ctor(winName,data)
    TrialNewFriendPiPeiView.super.ctor(self, winName);
    self._trialtype =  data._type or 1
    self.difficid =  data.diffic or 1
    self.pipeiLoadDotime = 0
    dump(data,"试炼匹配的==========")
    TrailModel:InPipeiViewGetdata(data)
    self.twodata = data
    self.playdata = {}
    self.proesstable = {}
    self.ispipeiplay = false
    self.peopleindex = 2 
    self.twoPipeiTiem = nil
  	self.pipeiren = false
  	TrailModel:setbattleTypeAndId(self._trialtype,self.difficid)
end

function TrialNewFriendPiPeiView:loadUIComplete()
	-- self:registClickClose(1, c_func( function()
 --            self:startHide()
 --    end , self))
	TrailModel:setispipeizhong(true)
	self:registerEvent();
	-- self.panel_Bg.btn_close:setTap(c_func(self.startHide, self));
	-- self.btn_1:setTap(c_func(self.addTeam, self));
	 -- local TrailID = self:getIdByTypeAndLvl(self._trialtype, self.difficid)
	local sre =  FuncTrail.byIdgetdata( self.difficid )
	-- dump(sre.loadingDes3,"3333")
	-- dump(sre.loadingDes2,"444444")
    self.new_rewards = string.split(sre.loadingDes3[1], ",")
    self.new_rsets = string.split(sre.loadingDes2[1], ",")
    -- dump(self.new_rewards,"11111111")
    -- dump(self.new_rsets,"222222")
	self:setLoadingTitle()
	self:addTypePeople()
	self:MyselfData()
	self:createUI()
	-- self:updateUI()
	-- self:delayCall(function ()
	-- 	self:Addplaydata()
	-- end,5)
	-- if self.twodata.id ~= nil then
	-- 	self:addtwodata()
	-- end

end 
function TrialNewFriendPiPeiView:addtwodata()
	
	-- self:Addplaydata(self.twodata)
end
function TrialNewFriendPiPeiView:registerEvent()
	TrialNewFriendPiPeiView.super.registerEvent();
	-- EventControler:addEventListener("notify_trial_match_end_1806", self.PipeiToTime, self)

end

function TrialNewFriendPiPeiView:getIdByTypeAndLvl(kind, lvl)
    return (kind - 1) * 5 + lvl + 3000;
end

function TrialNewFriendPiPeiView:setLoadingTitle()
	self.mc_da:showFrame(self._trialtype)
	-- local TrailID = self:getIdByTypeAndLvl(self._trialtype, self.difficid)
	local Trialdata = FuncTrail.byIdgetdata( self.difficid )
	self.mc_da:getViewByFrame(self._trialtype).txt_2:setString(GameConfig.getLanguage(Trialdata.describe))
	-- echo("333333333333333333====",self.new_rsets[1])
	self.txt_1:setString(GameConfig.getLanguage(self.new_rsets[1]))
	-- local bg = Trialdata.imgBg
	-- echo("===================bg===========",bg)
	-- if self.__bgView ~= nil then
		-- self.__bgView:setSpriteFrame(display.newSprite(FuncRes.iconPVE(bg)):getSpriteFrame())
	-- end
end
function TrialNewFriendPiPeiView:addTypePeople()
	local ctn = self.ctn_ren
    ctn:removeAllChildren();
    local bossConfig = FuncTrail.getTrialResourcesData(self._trialtype, "dynamic");
    local arr = string.split(bossConfig, ",");
    -- dump(arr, "bossConfig");
    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    self.spinBoss = sp
    -- sp:setScale(0.9)
    sp:playLabel(arr[2]);
    ctn:addChild(sp);
 --    	local lihuiname =  FuncTrail.getTrialResourcesData(self._trialtype,"dynamic")
	-- -- self.ctn_lihui:removeAllChildren()
	-- local npcSpine = FuncRes.getArtSpineAni(lihuiname)
	-- -- npcSpine:setScale(1.1)
	-- npcSpine:gotoAndStop(1)
 --    npcSpine:setOpacityModifyRGB(true)
	-- -- npcSpine:setPositionY(-182)
	-- ctn:addChild(npcSpine)
end
function TrialNewFriendPiPeiView:createUI()
    self.sumtime = {}
	for i=1,2 do
		if i == 2 then
			self["mc_"..i]:showFrame(2)
			local ctn = self["mc_"..i]:getViewByFrame(2).ctn_1
			ctn:removeAllChildren()
			-- local index = math.random(101,102)

			local npcSpine =  self:breakIcon(101,ctn)  ---默认101
			-- ctn:addChild(npcSpine)
			-- FilterTools.setGrayFilter( npcSpine)
			FilterTools.setViewFilter(npcSpine,FilterTools.colorTransform_lowLight3)
			-- self["mc_"..i]:getViewByFrame(2).panel_progress:setVisible(false)
			-- self["mc_"..i]:getViewByFrame(2).txt_zhudui:setVisible(false)
			self.sumtime[i] = FuncTrail.PiPeiSumTime() 
			self["mc_"..i]:getViewByFrame(2).txt_pipei:setString(GameConfig.getLanguage("#tid_trail_021")..self.sumtime[i])
			self["mc_"..i]:getViewByFrame(2).panel_progress.txt_1:setVisible(false)
			self["mc_"..i]:getViewByFrame(2).panel_progress.progress_1:initPercent(0)
		end

		
	end
	self.indextime = 1
	-- self:scheduleUpdateWithPriorityLua(c_func(self.updataTime,self),0)
end
function TrialNewFriendPiPeiView:updataTime()
	self.indextime  = self.indextime + 1 
	if math.fmod(self.indextime,30) == 0 then
		-- self:pipeiTimechaole()
		for i=1,2 do
			if i == 2 then
				self.sumtime[i] = self.sumtime[i] - 1
				self["mc_"..i]:getViewByFrame(2).txt_pipei:setString(GameConfig.getLanguage("#tid_trail_021").."("..self.sumtime[i]..")")
				if self.sumtime[i] == 10 then
					self:pipeiTimechaole()
				elseif self.sumtime[i] == 0 then
					if self.pipeiren == false then
						self:pipeiTuichu()
						self:btn_close() 
						self["mc_"..i]:getViewByFrame(2).txt_pipei:setVisible(false)
					end
				end
				if math.fmod(self.indextime,60) == 0 then
					local index = math.random(1,#self.new_rewards)
					-- echo("111111111111111111111")
					self["mc_"..i]:getViewByFrame(2).txt_zhudui:setString(GameConfig.getLanguage(self.new_rewards[index]))
					-- echo("222222222222222")
					-- self.txt_1:setString(GameConfig.getLanguage(self.new_rsets[]))
				end
				if math.fmod(self.indextime,30) == 0 then
					local index = math.random(1,#self.new_rsets)
					self.txt_1:setString(GameConfig.getLanguage(self.new_rsets[index]))
				end

			end
		end
	end
	-- if math.fmod(self.indextime,150) == 0 then
	-- 	self:pipeiTimechaole()
	-- end
	-- if self.twoPipeiTiem ~= nil then
	-- 	if  TimeControler:getServerTime() -  self.twoPipeiTiem >= 0 then
	-- 		if self.pipeiren == false then
	-- 			self:pipeiTuichu()
	-- 		end
	-- 	end
	-- end 
end
---匹配时间超了
function TrialNewFriendPiPeiView:pipeiTimechaole()
	echo("=======#self.proesstable=============",#self.proesstable)
	if self.ispipeiplay == false then
		-- WindowControler:showTips("匹配超时")
		-- self:btn_close()
		-- EventControler:dispatchEvent(TrialEvent.AGAIN_MATCHING)
		self:twoPipeiview()
		self.ispipeiplay = true
	end

end
function TrialNewFriendPiPeiView:pipeiTuichu()
	WindowControler:showTips(GameConfig.getLanguage("#tid_trail_022"))
	self:btn_close()
end
function TrialNewFriendPiPeiView:twoPipeiview()
-- _trialtype
-- difficid
    -- local id = TrailModel:getIdByTypeAndLvl(self._trialtype, self.difficid);
    TrialServer:startBattle(c_func(self.PipeiToTime, self), self.difficid, 2);
end
---第二次匹配数据返回
function TrialNewFriendPiPeiView:twoPipeiCallback(_param)
	-- echo("11111111111111111111111")
    -- dump(_param.result,"组队玩家的数据")
    -- if _param.result ~= nil then
    --     -- self:button_btn_close()
    --     local data = {
    --         _type =  self._trialtype,
    --         diffic = self.difficid,
    --     }
    --     WindowControler:showWindow("TrialNewFriendPiPeiView",data);
    -- end
end
--匹配超时
function TrialNewFriendPiPeiView:PipeiToTime(_param)
	-- WindowControler:showTips("匹配超时")
	if _param.result ~= nil then
		dump(_param.result,"第二次匹配路人数据")
		local time = _param.result.data.idleExpireTime
		self.twoPipeiTiem = time + 5
	else
		if _param.error ~= nil then
			self:btn_close()
		end
	end
	-- self:btn_close()
	--[[
	 "匹配超时" = {
     "method"   = 1806
     "result" = {
         "data" = {
             "idleExpireTime" = 1497257253
         }
         "serverInfo" = {
             "serverTime" = 1497257247524
         }
     }
     "uniqueId" = "0_11_1497257247473_1805"
	}
	]]
end
function TrialNewFriendPiPeiView:setPipeiTime(time)
	self.pipeiLoadDotime = time
end

---设置进度条的数据 方法
function TrialNewFriendPiPeiView:setCommProgress(Progress,index)
	-- echo("222222222222222222222222")
	table.insert(self.proesstable,Progress)
	self.pipeiDoTime = 0
	self:scheduleUpdateWithPriorityLua(c_func(self.CommProgressupdata,self,index),0)


end
function TrialNewFriendPiPeiView:CommProgressupdata(index)
	-- echo("11111111111111111111111111")
	index = index + 1
	for i=1,#self.proesstable do
		local  progress_bar = self.proesstable[i].progress_1
		local percent = progress_bar:getPercent()
		if i == 1 then
			-- if math.floor(percent) <= 50 then
				if percent <= 100 then
					self.proesstable[i].txt_1:setString(math.floor(percent).."%")
				end
				if math.fmod(index,30) == 0 then
					progress_bar:stopTween()
				else
					progress_bar:tweenToPercent(100, 5, c_func(self.onProgressEnd, self,i))
				end
				-- echo("11111111111111111111111111111111")
			-- else
			-- 	progress_bar:stopTween()
			-- 	self:unscheduleUpdate()
			-- 	self:scheduleUpdateWithPriorityLua(c_func(self.updataTime,self),0)
			-- end
		else
			self.pipeiDoTime = self.pipeiDoTime + 1
			-- TrailModel:setPiPeiDoTimes(index,self.pipeiDoTime)
			if percent >= 100 then
				percent = 100
			end

			self.proesstable[i].txt_1:setString(math.floor(percent).."%")
			-- if tonumber(percent) >= 100 then
				if math.floor((self.pipeiDoTime-self.pipeiLoadDotime)/30) >= 5 then
					self.proesstable[i].txt_1:setString("100%")
					self:unscheduleUpdate()
					self:delayCall(function ()
						self:onProgressEnd(i)
					end,0.2)
				end
			-- end
			-- echo("22222222222222222222")
			-- if math.fmod(index,40) == 0 then
			-- 	progress_bar:stopTween()
			-- else
				self.pipeiren = true
				progress_bar:tweenToPercent(100, 10, c_func(self.nullCallfun, self,i))
			-- end
			-- self.proesstable[1].progress_1:initPercent(self.proesstable[1].progress_1:getPercent()+ 2)
		end
	end
	TrailModel:setPiPeiDoTimes(index,self.pipeiDoTime)
	self:updataTime()
end
function TrialNewFriendPiPeiView:nullCallfun()
	

end
function TrialNewFriendPiPeiView:onProgressEnd(index)
	-- echo("=========index=======",index)
	if index == self.peopleindex then
		-- WindowControler:showTips("进入布阵界面")
		local trailPve = nil
	    if self._trialtype == TrailModel.TrailType.ATTACK then
	        trailPve = FuncTeamFormation.formation.trailPve1;
	    elseif self._trialtype == TrailModel.TrailType.DEFAND then
	        trailPve = FuncTeamFormation.formation.trailPve2;
	    else
	        trailPve = FuncTeamFormation.formation.trailPve3;
	    end
	    ChatModel:settematype(nil)
	    ChatModel:setChatTeamData(nil)
    	TrailModel:setTrailPve(trailPve)
		WindowControler:showWindow("WuXingTeamEmbattleView",trailPve,nil,false,true)
		EventControler:dispatchEvent("TRIAL_PIPEI_END_CALLBACK")
		self:btn_close()
		
	end
	
end
-- function TrialNewFriendPiPeiView:addlihui(charId,ctn)
function TrialNewFriendPiPeiView:addlihui(garmentId,avatar,ctn)
		local lihuiname =  FuncTrail.getTrialResourcesData(1,"staticId")
	ctn:removeAllChildren()
	-- local npcSpine = FuncRes.getArtSpineAni(lihuiname)
	-- npcSpine:setScale(0.6)
	-- npcSpine:gotoAndStop(1)
 --    npcSpine:setOpacityModifyRGB(true)

 	----charId
 	-- echo("========charId=========",charId)
 -- 	local charInitData = FuncChar.getHeroData(charId)
 -- 	local artMaskData = charInitData.artMask
	-- local artMaskSprite = display.newSprite(FuncRes.iconOther(artMaskData[1]))
	-- artMaskSprite:pos(artMaskData[2],artMaskData[3])

	-- local artName = charInitData.art[1]
	-- local artScale = charInitData.art[2]
	-- local artPosX = charInitData.art[3]
	-- local artPosY = charInitData.art[4]

	-- -- 主角立绘动画
	-- local heroAnim = FuncRes.getArtSpineAni(artName)
	-- heroAnim:pos(artPosX,-75+artPosY)
	-- heroAnim:setScaleX(-0.5)
	-- heroAnim:setScaleY(0.5)
		
	local sprint = FuncGarment.getGarmentLihui( garmentId,avatar )

	-- local newHeroAnim = FuncCommUI.getMaskCan(artMaskSprite,heroAnim)
	sprint:setPosition(cc.p(0,-80))
	sprint:setScaleX(-0.3)
	sprint:setScaleY(0.3)
	ctn:addChild(sprint)

	-- npcSpine:setPositionY(-182)
	return sprint
	-- self.ctn_lihui:addChild(npcSpine)
end
function TrialNewFriendPiPeiView:breakIcon(charId,ctn)
	-- ctn:removeAllChildren()
	--  	local charInitData = FuncChar.getHeroData(charId)
 -- 	local artMaskData = charInitData.artMask
	-- local artMaskSprite = display.newSprite(FuncRes.iconOther(artMaskData[1]))
	-- artMaskSprite:pos(artMaskData[2],artMaskData[3])
	-- local artName = charInitData.art[1]
	-- local artScale = charInitData.art[2]
	-- local artPosX = charInitData.art[3]
	-- local artPosY = charInitData.art[4]
	-- local heroAnim = display.newSprite(FuncRes.iconChar(artName))  --iconHead
	-- heroAnim:pos(0,15)
	-- heroAnim:setScaleX(0.3)
	-- heroAnim:setScaleY(0.3)
	-- local newHeroAnim = FuncCommUI.getMaskCan(heroAnim,heroAnim)
	-- ctn:addChild(newHeroAnim)


	local sprint = FuncGarment.getGarmentLihui(nil,charId )
	sprint:setPosition(cc.p(0,-80))
	sprint:setScaleX(-0.3)
	sprint:setScaleY(0.3)
	ctn:addChild(sprint)
	sprint:gotoAndStop(1)
	return sprint


end
-- function TrialNewFriendPiPeiView:getplayData(playdata)
-- 	if #self.playdata ~= 2 then
-- 		table.insert(self.playdata,playdata)
-- 	end
-- 	self:updateUI()
-- end
--[[
function TrialNewFriendPiPeiView:updateUI()
	-- self.playdata = {[1] = 1,[2]=1}

	if #self.playdata ~= 0 then
		for i=1,#self.playdata do
			self["mc_"..i]:showFrame(1)
			local ctn = self["mc_"..i]:getViewByFrame(1).ctn_1
			ctn:removeAllChildren()
			local npcSpine =  self:addlihui()
			ctn:addChild(npcSpine)
			local data = {
				dev = "105", 
				name = "李逍遥",
				level = 80,
				battle = 1500,  --战力

			}
			-- string.len(data.battle)

			self["mc_"..i]:getViewByFrame(1).txt_1:setString("【"..data.dev.."服】"..data.name.." "..data.level.."级")
			self["mc_"..i]:getViewByFrame(1).panel_power.UI_number:setPower(data.battle)

		end
	end
end
--]]
function TrialNewFriendPiPeiView:MyselfData()
	self["mc_"..1]:showFrame(1)
	local ctn = self["mc_"..1]:getViewByFrame(1).ctn_1
	ctn:removeAllChildren()


	local npcSpine =  self:addlihui(UserExtModel:garmentId(),UserModel:avatar(),ctn)--UserModel:getCharId(),ctn)
	-- ctn:addChild(npcSpine)
	local data = {
		dev = self:getservername(tostring(LoginControler:getServerId())),
		name = UserModel:name(),
		level = UserModel:level(),
		battle = UserModel:getAbility(),  --战力
	}
	local fuStr = GameConfig.getLanguage("tid_common_2050")
	local jiStr = GameConfig.getLanguage("tid_common_2049")
	self["mc_1"]:getViewByFrame(1).txt_1:setString("【"..data.dev..fuStr.."】"..data.name.." "..data.level..jiStr)
	self["mc_1"]:getViewByFrame(1).panel_power.UI_number:setPower(data.battle)

	
	local frame = 30
	-- self["mc_1"]:getViewByFrame(1).panel_progress.progress_1:tweenToPercent(100, frame, c_func(self.onProgressEnd, self))
	local Progress = self["mc_1"]:getViewByFrame(1).panel_progress
	local index = 1
	self:setCommProgress(Progress,index)
end

function TrialNewFriendPiPeiView:Addplaydata(Infoplaydata)
	-- dump(Infoplaydata,"匹配玩家的数据")
	TrailModel:setPiPeiPlayer(Infoplaydata)

	local Infoplaydata = {
		avatar = Infoplaydata.avatar or "101",
		dev = Infoplaydata.sec,
		name = Infoplaydata.name or GameConfig.getLanguage("tid_common_2006"),
		level = Infoplaydata.level,
		battle = Infoplaydata.battle,
		head = Infoplaydata.head or "",
		garmentid = Infoplaydata.garmentid,
	}

	self["mc_2"]:showFrame(1)
	local ctn = self["mc_2"]:getViewByFrame(1).ctn_1
	ctn:removeAllChildren()
	local npcSpine =  self:addlihui(Infoplaydata.garmentid,Infoplaydata.avatar,ctn)--Infoplaydata.CharId,ctn)
	-- ctn:addChild(npcSpine)
	local serverlist =  LoginControler:getServerList()
	local data = {
		dev =  self:getservername(Infoplaydata.dev),--Infoplaydata.dev,
		name = Infoplaydata.name,
		level = Infoplaydata.level,
		battle = Infoplaydata.battle,  --战力
	}
	local fuStr = GameConfig.getLanguage("tid_common_2050")
	local jiStr = GameConfig.getLanguage("tid_common_2049")
	self["mc_2"]:getViewByFrame(1).txt_1:setString("【"..data.dev..fuStr.."】"..data.name.." "..data.level..jiStr)
	self["mc_2"]:getViewByFrame(1).panel_power.UI_number:setPower(data.battle)

	self["mc_2"]:getViewByFrame(1).panel_progress.txt_1:setString(math.floor(0).."%")
	local frame = 15
	self["mc_2"]:getViewByFrame(1).panel_progress.progress_1:tweenToPercent(100, frame, c_func(self.TwoOnProgressEnd, self))
	local Progress = self["mc_2"]:getViewByFrame(1).panel_progress
	local progress_1 = self["mc_1"]:getViewByFrame(2).panel_progress.progress_1
	self.ispipeiplay = true
	-- progress_1:initPercent(progress_1:getPercent()+2)
	local index = 1
	self:setCommProgress(Progress,index)

end
function TrialNewFriendPiPeiView:getservername(serverId)

    local serverlist =  LoginControler:getServerList()
    -- dump(serverlist,"1111111111111")
    -- echo("==============",serverId)
    for k,v in pairs(serverlist) do
        if v._id == serverId then
            return v.name
        end
    end
    return serverId
end
function TrialNewFriendPiPeiView:TwoOnProgressEnd()
	

end

function TrialNewFriendPiPeiView:btn_close()
	self:startHide()

	
end


return TrialNewFriendPiPeiView;

