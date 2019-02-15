-- TriaNewlTeamView
--time 2017/05/13
----@Author:wukai
 ---玩家推送
local TriaNewlTeamView = class("TriaNewlTeamView", UIBase);


function TriaNewlTeamView:ctor(winName)
    TriaNewlTeamView.super.ctor(self, winName);
    
end

function TriaNewlTeamView:loadUIComplete()
	self:registerEvent();
	self.btn_close:setTap(c_func(self.button_btn_close, self));
	self.btn_1:setTap(c_func(self.addTeam, self));

	-- self:registClickClose(-1, c_func( function()
 --            self:startHide()
 --    end , self))


	-- self:updateUI()
	-- self:scheduleUpdateWithPriorityLua(c_func(self.Ontime_black,self),0)
	self:scheduleUpdateWithPriorityLua(c_func(self.Ontime_black,self),0)
end 


function TriaNewlTeamView:onShowCompData(  )
	-- TriaNewlTeamView.super.onShowCompData(self)
	-- if self.colorLayer then 
	-- 	self.colorLayer:setTouchSwallowEnabled(false)
	-- end
	-- return nil
	-- body
end
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
function TriaNewlTeamView:addTeam()
	echo("==========加入组队===============")
	-- 
	-- WindowControler:showWindow("TrialNewFriendPiPeiView", self.SelectType,playdata);
	local function _callback(_param)
        dump(_param.result,"加入组队数据")
        if _param.result ~= nil then
        	-- self:button_btn_close()
        	TrailModel:setispipeizhong(true)
        	-- TrailModel:addteamData(self.playdata)
        	local Windownames =  WindowControler:getWindow( "WuXingTeamEmbattleView" )

        	if Windownames  ~= nil then
        		Windownames:doBackClick()
        	end

        	WindowControler:showWindow("TrialNewFriendPiPeiView",self.playdata);
        	EventControler:dispatchEvent(TrialEvent.CLOSE_BLACK_EVENT)
        else
        	local errorInfo = _param.error
        	local errorstring = ServerErrorTipControler:checkShowTipByError(errorInfo)
        	-- echo("================",errorstring)
        	WindowControler:showTips(errorstring)
        	self:button_btn_close()
        end
       
	end
	local params = {}
	params.trid =   self.playdata.rid--角色id
	params.tsec = 	self.playdata.sec--角色大区
	-- echo("============发送加入组队协议====================")
	--发送加入组队协议
	TrialServer:sendAddteam(params,_callback)
	-- echo("================================")
end
function TriaNewlTeamView:registerEvent()
	TriaNewlTeamView.super.registerEvent();

end

 -- self.playdata = data
--[[
		name = "仙侠",
		avatar = 101,
		_type = 1,
		diffic =  3,
		sec = "dev",
]]

function TriaNewlTeamView:updateUI(data)
	self:visible(true)
	self.onclosstime = FuncTrail.clossOnTime()  ----退出总时间
	self.playdata = data
	self.index = 0
	local inf = {
		name = self.playdata.name,
		avatar = self.playdata.avatar,
		_type = self.playdata._type,
		diffic =  self.playdata.diffic,
	}
	self.txt_name:setString(inf.name)
	local types = FuncTrail.gettrialResourcesName(inf._type)
	-- self.txt_1:setString(types) --试炼推送类型
	self.txt_2:setString(GameConfig.getLanguage(types))	---对象
	local TrailID = TrailModel:getIdByTypeAndLvl(inf._type, inf.diffic)
	local diffic_name = FuncTrail.byIdgetdata( TrailID ).diffName
	self.txt_3:setString(GameConfig.getLanguage(diffic_name))	---难度

	 local _node = self.ctn_1
    _node:removeAllChildren()
    local _icon = FuncChar.icon(tostring(inf.avatar or 101));
    local _sprite = display.newSprite(_icon);
    local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
    -- iconAnim:setScale(0.8)
    FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)
    -- local index = 0
    

end
function TriaNewlTeamView:Ontime_black()
	if self.index ~= nil then
		self.index = self.index + 1
		if self.index  == self.onclosstime * 30 then
			self:button_btn_close()
		end
	end
end
function TriaNewlTeamView:button_btn_close()
	self:visible(false)
	EventControler:dispatchEvent(TrialEvent.CLOSE_BLACK_EVENT)
	self.index = nil
end


return TriaNewlTeamView;
