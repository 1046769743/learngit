-- GuildDailyWelfareView
-- Author: Wk
-- Date: 2017-10-12
-- 公会每日红利界面
local GuildDailyWelfareView = class("GuildDailyWelfareView", UIBase);

function GuildDailyWelfareView:ctor(winName)
    GuildDailyWelfareView.super.ctor(self, winName);
end

function GuildDailyWelfareView:loadUIComplete()

	-- self:initData()

end 

function GuildDailyWelfareView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end


function GuildDailyWelfareView:initData()

	-- local getRewarddata = {
	-- 	[1] = true,
	-- 	[2] = false,
	-- 	[3] = false,
	-- }
	self.lockAni = {}
	local armature = {
		[1] = "UI_xianmeng_zhangfang_xianyu",
		[2] = "UI_xianmeng_zhengti_jinbi",
		[3] = "UI_xianmeng_zhangfang_yueshi",
	}

	local  getRewarddata = GuildModel:getbonusList()
	for i=1,3 do
		if getRewarddata[i] == 1 then
			self["panel_"..i].mc_1:showFrame(2)
			self["panel_"..i]:setTouchedFunc(c_func(self.yetgetReward, self,i),nil,true);
		else
			self["panel_"..i].mc_1:showFrame(1)
			self["panel_"..i]:setTouchedFunc(c_func(self.getReward, self,i),nil,true);
			local ctn_texiao = self["panel_"..i].ctn_texiao
			local armaturename = armature[i]
			ctn_texiao:removeAllChildren()
			self.lockAni[i] = self:createUIArmature("UI_xianmeng", armaturename,ctn_texiao, true,function ()
			
			end)
			if i ~= 2 then
				self.lockAni[i]:setPosition(cc.p(-323/2,317/2))
			end
		end
	end
end
function GuildDailyWelfareView:yetgetReward()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_025"))
end

function GuildDailyWelfareView:getReward(index)
	if not GuildControler:touchToMainview() then
		return 
	end
	-- if GuildModel:isWoodFull() == false then
	-- 	return 
	-- end

	-- local guildbuildId = FuncGuild.guildBuildType.OFFICES
	-- local guildlevel = GuildModel:getGuildLevel()
	-- local alldata = FuncGuild.getguildBuildUpAllData()
	-- local data = alldata[tostring(guildbuildId)][tostring(guildlevel)]
	-- local everyDayReward =  data.everyDayReward
	-- dump(everyDayReward[index],"111111111111111",7)
	local ctn_texiao = self["panel_"..index].ctn_texiao
	self.lockAni[index]:setVisible(false)
	local function _callback(_param)
		-- dump(_param.result,"领取红利数据返回",8)
		if _param.result then
			self.reward = _param.result.data.reward
			self:createUIArmature("UI_xianmeng", "UI_xianmeng_zhangfanglingqu",ctn_texiao, false,function ()
				self:getsucces(index)
			end)
			EventControler:dispatchEvent(GuildEvent.REFRESH_BOUNS_EVENT)
		else
			--错误和没查找到的情况
		end
	end
	self:disabledUIClick(  )
	local params = {
		id = index,
	}
	GuildServer:sendBonus(params,_callback)

end

function GuildDailyWelfareView:getsucces(index)
	local guildbuildId = FuncGuild.guildBuildType.OFFICES
	-- local guildlevel = GuildModel:getGuildLevel()
	-- local alldata = FuncGuild.getguildBuildUpAllData()
	-- local data = alldata[tostring(guildbuildId)][tostring(guildlevel)]
	-- local everyDayReward =  data.everyDayReward
	self["panel_"..index].mc_1:showFrame(2)
	self["panel_"..index]:setTouchedFunc(c_func(self.yetgetReward, self,i),nil,true);
	self["panel_"..index].ctn_texiao:removeFromParent()
	-- local rearwd = string.split(self.reward,",")
	WindowControler:showWindow("RewardSmallBgView", {self.reward})
	self:resumeUIClick()
end


function GuildDailyWelfareView:press_btn_close()
	
	self:startHide()
end


return GuildDailyWelfareView;
