-- GuildSureExchangeView
-- Author: Wk
-- Date: 208-03-12
-- 公会心愿界面
local GuildSureExchangeView = class("GuildSureExchangeView", UIBase);

function GuildSureExchangeView:ctor(winName,data,cellfunc)
    GuildSureExchangeView.super.ctor(self, winName);
    self.alldata = data
    self.cellfunc = cellfunc

    dump(self.alldata,"交换的按钮==")
end

function GuildSureExchangeView:loadUIComplete()

	self.UI_di.txt_1:setString(GameConfig.getLanguage("#tid_guild_049")) 
	self.UI_di.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:registClickClose("out")
	self:initData()

end 

function GuildSureExchangeView:initData()

	local name = self.alldata.name
	self.rich_1:setString("您将与"..name.."交换")

	local reward = "1,"..self.alldata.needExchang..",1"
	self.UI_1:setResItemData({reward = reward })
	local reward = "1,"..self.alldata.hasExchange..",1"
	self.UI_2:setResItemData({reward = reward })

	self.UI_di.mc_1:showFrame(1)
	self.UI_di.mc_1:getViewByFrame(1):setTouchedFunc(c_func(self.sendExchangeButton,self,1))
end

---交换的按钮
function GuildSureExchangeView:sendExchangeButton()
	echo("==========-交换的按钮======")
	-- dump(itemData,"交换的按钮==")
	local itemData = self.alldata
	local playerID = itemData.id
	local hasExchange = itemData.hasExchange
	local num = ItemsModel:getItemNumById(hasExchange)
	if num <= 0 then
		WindowControler:showTips(FuncGuild.Tranlast[17])
		return 
	end
	local function _callback(event)
		if event.result then
			dump(event.result,"===交换的按钮=返回的数据=")
			WindowControler:showTips(FuncGuild.Tranlast[19])
			GuildModel:removeExchangData(playerID)
		else
			if event.error then
				local code = event.error.code
				if tonumber(code) == FuncGuild.ErrorCode[2] then
					WindowControler:showTips(FuncGuild.Tranlast[18])
				end
				GuildModel:removeExchangData(playerID)
			end
		end
		if self.cellfunc then
			self.cellfunc()
			self:press_btn_close()
		end
	end

	local params = {
		trid = playerID
	}
	GuildServer:sendGuildExchange(params,_callback)
end




function GuildSureExchangeView:press_btn_close()
	self:startHide()
end


return GuildSureExchangeView;
