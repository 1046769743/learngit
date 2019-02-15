local GuildDetailView = class("GuildDetailView", UIBase);

function GuildDetailView:ctor(winName,data)
    GuildDetailView.super.ctor(self, winName);
    self.guildData = data
end

function GuildDetailView:loadUIComplete()
	self:registerEvent();

    self:updateUI()
end 

function GuildDetailView:registerEvent()
	GuildDetailView.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));
end

function GuildDetailView:press_btn_close()
    self:startHide()
end

function GuildDetailView:updateUI()
    local guildData = self.guildData
    -- 仙盟icon
    local guildIconCtn = self.panel_2.ctn_1
    local guildIcon = display.newSprite(FuncRes.iconGuild(guildData._id)):anchor(0.5,0.5)
    guildIconCtn:setScale(0.8)
    guildIconCtn:addChild(guildIcon)

    --战斗力
    self.txt_1:setString(GameConfig.getLanguageWithSwap("tid_rank_1005", guildData.score)) 

    -- 仙盟名字
    self.txt_2:setString(guildData.name) 

    -- 等级
    self.txt_3:setString(GameConfig.getLanguageWithSwap("rank_2", guildData.level)) 

    -- 盟主
    local leaderName = guildData.leaderName
    if leaderName == nil or leaderName == "" then
        leaderName = "无"
    end
    self.txt_4:setString(GameConfig.getLanguageWithSwap("tid_rank_1006", leaderName)) 

    -- 仙盟ID
    self.txt_5:setString(GameConfig.getLanguageWithSwap("tid_rank_1007", guildData._id))

    -- 总贡献
    self.txt_6:setString(GameConfig.getLanguageWithSwap("tid_rank_1008", guildData.coinTotal))

    -- 仙盟宣言
    self.txt_7:setString(GameConfig.getLanguage("tid_rank_1009", guildData._id))

    -- 仙盟宣言内容
    self.txt_8:setString(guildData.desc)
end


return GuildDetailView;
