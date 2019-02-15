-- GuildPreviewView
-- Author: Wk
-- Date: 2017-09-29
-- 公会预览view
local GuildPreviewView = class("GuildPreviewView", UIBase);

function GuildPreviewView:ctor(winName)
    GuildPreviewView.super.ctor(self, winName);
end

function GuildPreviewView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initButton()
end 

function GuildPreviewView:registerEvent()
	EventControler:addEventListener(GuildEvent.GUILD_REFRESH_ICON, self.initData, self)
end
function GuildPreviewView:initData()
	local guildName = GuildModel.guildName
	local guildIcon = GuildModel.guildIcon
	self.UI_1:initData(guildIcon)
	local data = FuncGuild.getguildType()
	
	local namestid  = data[tostring(guildName._type)].afterName
	local names = GameConfig.getLanguage(namestid)
	self.txt_2:setString(guildName.name..names)
	-- self.mc_wenzi:showFrame(guildName._type)

end

function GuildPreviewView:initButton()
	self.costgold = FuncGuild.createGuidCostNumber()
	self.panel_1.txt_1:setString(self.costgold)
	self.btn_1:setTouchedFunc(c_func(self.createButton, self),nil,true);
	self.btn_2:setTouchedFunc(c_func(self.breakUI, self),nil,true);
end

--返回到第一个主界面
function GuildPreviewView:breakUI()
	EventControler:dispatchEvent(GuildEvent.BREAK_CREATE_TO_UI, self.successNextGuild, self)
end

function GuildPreviewView:createButton()
	-- if not GuildControler:touchToMainview() then
	-- 	return 
	-- end
	if UserModel:getGold() >= self.costgold then
		-- 发送协议  创建协议
		self:CellFunBacks()
	else
		-- WindowControler:showWindow("MallMainView")
		-- WindowControler:showTips(GameConfig.getLanguage("#tid_guild_039"));
		if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, self.costgold, true) then
	        return
	    end
	end

end
--发送协议回调
function GuildPreviewView:CellFunBacks()
	
	---成功发送这个回调函数 显示成功界面

	---[[  测试
		-- GuildModel:setceshi()
		-- self.cellBack()
	-- ]]
	local function callback(param)
        if (param.result ~= nil) then
        	-- dump(param.result,"创建仙盟数据格式",8)
 			local datalist = param.result.data.data
 			GuildModel._guildcharinfo.name = UserModel:name()
        	GuildModel:setInviteDataList(datalist)
        	GuildModel.iscreateGuild = true
			EventControler:dispatchEvent(GuildEvent.CREATE_GUILD_OK_EVENT)
			GuildBossModel:updateTimeFrame()
           	self.cellBack()
        else
            
        end
    end

    local guildName = GuildModel.guildName
	local guildIcon = GuildModel.guildIcon


	--发送的参数
	local params = {
		name = guildName.name,
		afterName = guildName._type,
		logo = guildIcon.borderId,
		color = guildIcon.bgId,
		icon = guildIcon.iconId,
		qqGroup = guildName.groupID,
	};
	dump(params,"发送协议参数",4)
	GuildServer:createGuild(params,callback)

end
function GuildPreviewView:setCellFun(cellBack)
	self.cellBack = cellBack
end



return GuildPreviewView;
