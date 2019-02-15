-- GuildBlessingOneView
-- Author: Wk
-- Date: 2017-10-11
-- 公会祈福界面
local GuildBlessingOneView = class("GuildBlessingOneView", UIBase);

function GuildBlessingOneView:ctor(winName)
    GuildBlessingOneView.super.ctor(self, winName);
end

function GuildBlessingOneView:loadUIComplete()
	
	self:registerEvent()
	-- self:initData()
end 

function GuildBlessingOneView:registerEvent()
	-- EventControler:addEventListener(GuildEvent.GET_QIFU_REWARD, self.lingquButton, self)
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
	EventControler:addEventListener(GuildEvent.GUILD_REFRESH_BOX_EVENT, self.initData, self)
end

function GuildBlessingOneView:initData(_file)

	self.iscanblessing = CountModel:getGuildPrayCount()
	if self.iscanblessing  == 0 then
		FilterTools.clearFilter(self.btn_qifu);
		self.btn_qifu:setTouchedFunc(c_func(self.qifuButton, self),nil,true);
	else
		FilterTools.setGrayFilter(self.btn_qifu);
		self.btn_qifu:setTouchedFunc(c_func(self.notqifuButton, self),nil,true);
	end
	
	local panel = self.panel_jdt
	-- local level = GuildModel:getGuildLevel()
	-- local data = FuncGuild.getGuildLevelByPreserve(tostring(level))
	local buildUpdata = FuncGuild.getguildBuildUpAllData()
	local buildsLevel = GuildModel:getBuildsLevel()
	local buildid =  FuncGuild.guildBuildType.PRAyERHALL
	local level = tostring(buildsLevel[buildid])
	local data = buildUpdata[tostring(buildid)][tostring(level)]

	local percentpeople = GuildModel._baseGuildInfo.prayCount   --祈福人数
	local _time =  GuildModel._baseGuildInfo.prayExpireTime
	local isok = false
	if  _time > TimeControler:getServerTime() then
		isok = true
	end
	if not isok then
		percentpeople = 0
	end

	local sum = tonumber(data.paryNum[3])
	local percent = self:setpercent(percentpeople,sum)

	panel.txt_13:setString(percentpeople..GameConfig.getLanguage("#tid_guildBlessingOne_001")) 

	if  _file then
		self:addRedLight(percent)
	end
	self:addQifuNumeffEct(percent)
	
	-- echoError("=======percent===========",percent)
	self.panel_jdt.panel_jin.progress_huang:setPercent(percent)


	-- self.isCanreward  = {    ---调用服务器的数据
	-- 	[1] = 1,
	-- 	[2] = 0,
	-- 	[3] = 0,
	-- }
	self.isCanreward = GuildModel:getPrayReCount()

	for i=1,#self.isCanreward do
		local peoplenum = data.paryNum[i] -- data["paryNum"..i]
		local ctn_eff = panel["panel_box"..i].ctn_effect
		ctn_eff:removeAllChildren()
		if self.isCanreward[i] == 2 then
			panel["panel_box"..i].mc_box:showFrame(2)
		else
			panel["panel_box"..i].mc_box:showFrame(1)
			if tonumber(percentpeople) >= tonumber(peoplenum) then
				local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctn_eff, true, GameVars.emptyFunc)
				anim:setScale(0.8)
			end
		end
		panel["panel_box"..i].txt_1:setString(peoplenum)
		panel["panel_box"..i]:setTouchedFunc(c_func(self.isCanReceive, self,data,i),nil,true);
		
		
	end
end
function GuildBlessingOneView:isCanReceive(data,index)
	if not GuildControler:touchToMainview() then
		return 
	end
	self.alldata = data
	self._index = index
	local isCanreward = self.isCanreward[index]
	local itemArray = data["paryReward"..index]

	local level = GuildModel:getGuildLevel()
	-- local data = FuncGuild.getGuildLevelByPreserve(level)

	local buildUpdata = FuncGuild.getguildBuildUpAllData()
	local buildsLevel = GuildModel:getBuildsLevel()
	local buildid =  FuncGuild.guildBuildType.PRAyERHALL
	local level = tostring(buildsLevel[buildid])
	local data = buildUpdata[tostring(buildid)][tostring(level)]

	local percentpeople = GuildModel._baseGuildInfo.prayCount or 0   --祈福人数
	local sum = tonumber(data.paryNum[index])---data["paryNum"..index]
	if percentpeople < sum then
		isCanreward = 0
	end
	local _table = {
		title = "奖励预览",
		des = "祈福达到"..sum.."人可领取",
		reward = itemArray,
		-- callback = self.lingquButton,--回调函数
		parameter = {data,index},
		isPickup = isCanreward,--是否可领取  -- 0 --预览不可领取  1领取   2已领取

	}
	WindowControler:showWindow("GuildBlessingRewardView",_table );

end

function GuildBlessingOneView:lingquButton()
	local itemArray = self.alldata["paryReward"..self._index]
	WindowControler:showWindow("RewardSmallBgView", itemArray);
end

function GuildBlessingOneView:setpercent(number,sumber)
	local percent = (number*100)/sumber
	if tonumber(percent) >= 100 then
		percent = 100
	end
	return percent
end

function GuildBlessingOneView:qifuButton()
	if not GuildControler:touchToMainview() then
		return 
	end

	echo("=======祈福========")
	-- local isfull = GuildModel:isWoodFull()
	-- if isfull == false then
	-- 	return 
	-- end

	local function callback(param)
        if (param.result ~= nil) then
        	-- dump(param.result,"祈福返回数据",7)
        	-- local prayCount = GuildModel._baseGuildInfo.prayCount
        	local prayCount = param.result.data.prayCount
        	GuildModel._baseGuildInfo.prayCount = prayCount
        	local servertime = TimeControler:getServerTime()
        	local sumtime = FuncCommon.byTimegetleftTime(servertime)
        	GuildModel._baseGuildInfo.prayExpireTime = servertime  + sumtime
        	EventControler:dispatchEvent(GuildEvent.GET_QIFU_REWARD)
        	local ctn_texiao = self.ctn_texiao
        	local aockAni= self:createUIArmature("UI_xianmeng", "UI_xianmeng_qifu" ,ctn_texiao, false,function ()
				ctn_texiao:removeAllChildren()
				WindowControler:showTips(GameConfig.getLanguage("#tid_guildBlessingOne_002"))
			end) 

        	self:initData(true)
        else
            
        end
    end
    local params = {}
	GuildServer:sendPray(params,callback)

end
function GuildBlessingOneView:notqifuButton()
	if not GuildControler:touchToMainview() then
		return 
	end 
	WindowControler:showTips(GameConfig.getLanguage("#tid_guildBlessingOne_003"))

end


function GuildBlessingOneView:addQifuNumeffEct(percent)
	echo("==========percent==进度========",percent)
	local box =  self.panel_jdt.panel_jin.progress_huang:getContainerBox()
	local totalWidth = box.width
	local ctn_jindu = self.panel_jdt.ctn_jindu
	-- ctn_jindu:removeAllChildren()
	if not ctn_jindu:getChildByName("jindu") then
		local anim = self:createUIArmature("UI_xianmeng","UI_xianmeng_qifujintutiaoeff",ctn_jindu, true,function ()	end)
		anim:setPosition(cc.p(619/2,-19/2))
		anim:setName("jindu")
	end
	-- if not ctn_jindu:getChildByName("jinjiatou") then
	-- 	local animjiantou = self:createUIArmature("UI_xianmeng","UI_xianmeng_qifujintutiao_lizi",ctn_jindu, true,function ()	end)
	-- 	animjiantou:setName("jinjiatou")
	-- end

	local zhezhao = nil
	local anim1 = ctn_jindu:getChildByName("jindu")
	local anim2 = ctn_jindu:getChildByName("jinjiatou")
	if anim1 then
		zhezhao = anim1:getBoneDisplay("layer2")
		zhezhao:pos(-618/2 + percent*1.0/100 * totalWidth , 0)
		local dilayer  = anim1:getBoneDisplay("layer4")
		if dilayer ~= nil then
			dilayer:setVisible(false)
		end
	end
	if anim2 then
		if percent < 100  and percent > 0 then
			anim2:setVisible(true)
			anim2:setPosition( cc.p(percent*1.0/100 * totalWidth,-10))
		else
			anim2:setVisible(false)
		end
		local targetX = percent*1.0/100 * totalWidth
		local targetY = -10
		local act_move = act.moveto(0.5,targetX, targetY )
		local act_seq = act.sequence(act_move )
		anim2:runAction(act_seq)
	end

end

function GuildBlessingOneView:addRedLight(percent)
	local ctn_jindu = self.panel_jdt.ctn_jindu
	local box =  self.panel_jdt.panel_jin.progress_huang:getContainerBox()
	local totalWidth = box.width

	local animjiantou = self:createUIArmature("UI_xianmeng","UI_xianmeng_qifujintutiao_shanguang",ctn_jindu, false,function ()

	end)
	animjiantou:setPosition(cc.p(619/2,-19.3/2))
	local zhezhao =  animjiantou:getBoneDisplay("layer2")
	zhezhao:pos(64  , 0)
	-- animjiantou:startPlay(false, true)
	animjiantou:registerFrameEventCallFunc(24,1,function ()
		animjiantou:setVisible(false)
	end)





	-- local anim1 = ctn_jindu:getChildByName("jindu")
	-- local anim2 = ctn_jindu:getChildByName("jinjiatou")
	-- if anim2 then
		-- local targetX = percent*1.0/100 * totalWidth
		-- local targetY = -10
		-- local act_move = act.moveto(0.5,targetX, targetY )
		-- local act_seq = act.sequence(act_move )
		-- anim2:runAction(act_seq)
	-- end

end

function GuildBlessingOneView:press_btn_close()
	
	self:startHide()
end


return GuildBlessingOneView;
