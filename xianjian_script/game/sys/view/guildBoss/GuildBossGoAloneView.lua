-- GuildBossGoAloneView
--Author:      wk
--DateTime:    2018-05-15 
--Description: 单独进入共闯秘境的界面
--


local GuildBossGoAloneView = class("GuildBossGoAloneView", UIBase);


-- _type == 1 是单人进入战斗  2 是否踢出此人
function GuildBossGoAloneView:ctor(winName,data,_type,bossId)
    GuildBossGoAloneView.super.ctor(self, winName)
    self.bossId = bossId
    self._type = _type
    self.playerData = data
end

function GuildBossGoAloneView:loadUIComplete()
	self:registerEvent()
	-- echoError("111111111111111111")

end 

function GuildBossGoAloneView:registerEvent()
	GuildBossGoAloneView.super.registerEvent(self);
	self.panel_1.btn_close:setTouchedFunc(c_func(self.close, self))
	self:registClickClose("out")
	self:initData()
end


function GuildBossGoAloneView:initData()
	if self._type == 1  then
		self:onleView()
		self.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_guildBoss_013"))--"独闯秘境")
	elseif self._type == 2  then
		self:outView()
		self.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_guildBoss_014"))--"踢人")
	end

end

function GuildBossGoAloneView:onleView()
	self.mc_2:showFrame(1)
	local panel =  self.mc_2:getViewByFrame(1)
	panel.btn_1:setTouchedFunc(c_func(self.close, self))
	panel.btn_2:setTouchedFunc(c_func(self.gotoBattle, self))
end

--进入战斗布阵
function GuildBossGoAloneView:gotoBattle()
	echo("=======进入单人战斗布阵========")

	local params = {}
	params[FuncTeamFormation.formation.guildBoss] = {
		raidId = FuncGuildBoss.getLevelIdById(self.bossId),
 	}
 	WindowControler:showWindow("WuXingTeamEmbattleView", FuncTeamFormation.formation.guildBoss, params)

 	self:close()
	-- local function _callback(event)
	-- 	if event.result then
			
	-- 	else
	-- 	end
	-- end
	-- local params = {}
	-- GuildBossServer:doingSingleBattleGuildBoss(params,_callback)
end


function GuildBossGoAloneView:outView()
	self.mc_2:showFrame(2)
	local panel =  self.mc_2:getViewByFrame(2)


		
	local str = FuncTranslate._getLanguageWithSwap("#tid_guildboss_1007",self.playerData.name)
	panel.txt_2:setString(str or "少侠" )
	-- panel.txt_3:setString( self.playerData.name or "少侠" )
	panel.btn_1:setTouchedFunc(c_func(self.close, self))
	panel.btn_2:setTouchedFunc(c_func(self.kickOutPlrayer, self))
end

--踢出玩家
function GuildBossGoAloneView:kickOutPlrayer()
	-- self.playerData.id
	dump(self.playerData,"=======踢出玩家========")
	local function _callback(event)
		if event.result then
			dump(event.result,"========踢出玩家返回数据========")
			-- WindowControler:showWindow("GuildBossInviteView")
			EventControler:dispatchEvent(GuildBossEvent.REMOVE_OTHER_DATA)
			WindowControler:showTips(GameConfig.getLanguage("#tid_guildboss_1005"))
			self:close()
		else

		end

	end


	local params = {
		trid =self.playerData._id 	
	}
	GuildBossServer:kickOutGuildBoss(params,_callback)
end




function GuildBossGoAloneView:close()
	self:startHide()
end
function GuildBossGoAloneView:deleteMe()
	GuildBossGoAloneView.super.deleteMe(self);
end

return GuildBossGoAloneView;
