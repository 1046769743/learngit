-- GuildHongBaoInfoView.lua
-- Author: Wk
-- Date: 2018-03-07
-- 公会红包详情界面
local GuildHongBaoInfoView = class("GuildHongBaoInfoView", UIBase);

function GuildHongBaoInfoView:ctor(winName,packetData,addeffect)
    GuildHongBaoInfoView.super.ctor(self, winName);
    self.packetData = packetData
    self.addeffect = addeffect

    -- dump(self.packetData,"99999999999999999")
end

function GuildHongBaoInfoView:loadUIComplete()
	self:registerEvent()
	-- self.panel_tou:setVisible(false)
	-- self.panel_info:setVisible(false)
	-- self.panel_bg:setVisible(false)
	self:initData()
end 

function GuildHongBaoInfoView:registerEvent()

	-- self:registClickClose("out")
	self.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	-- self.UI_1.txt_1:setString("红包详情")
	-- self.UI_1.mc_1:setVisible(false)

end


function GuildHongBaoInfoView:initData()
	local panel_tou = self.panel_tou
	local _ctn = panel_tou.ctn_touxiang


	local packetId = self.packetData.packetId 
	local baseData = FuncGuild.getpacketDataById(packetId)
	local description = baseData.description
	self.panel_info.txt_2:setString(GameConfig.getLanguage(description))

	local alldata = GuildRedPacketModel.allRedPacketData
	local itemData = alldata[self.packetData._id]
	local _avatar = itemData.avatar
	local _headId = itemData.head
	local _headFrameId = itemData.frame
	UserHeadModel:setPlayerHeadAndFrame(_ctn,_avatar,_headId)

	_ctn:anchor(0.5,0.5)
    _ctn:removeAllChildren()
    GuildRedPacketModel:setPlayerHead(_ctn,_avatar,_headId)
	GuildRedPacketModel:setPlayerFrame(_ctn,_headFrameId)

	-- local memberInfodata = GuildModel:getMemberInfo(self.packetData.rid)

	local guildID = GuildModel:gettMyselfpos()
    -- local postype =  memberInfodata.right

	-- local right = FuncGuild.byIdAndPosgetName(guildID,postype)

	-- panel_tou.txt_2:setString(right)

	self.panel_tou.txt_1:setString(itemData.name)

	local num = self:myselfGetNum()
	local isgrab = 1 --  1已经抢到，2没抢到
	if num <= 0 then
		isgrab = 2
	end
	if isgrab == FuncGuild.RedPacket_Grab_Type.GET then
		self.panel_info.mc_sml:showFrame(isgrab)
		self:grabPacketInfo()
	elseif isgrab == FuncGuild.RedPacket_Grab_Type.NOT_GET  then
		self.panel_info.mc_sml:showFrame(isgrab)
	end
	local icon_ctn = self.panel_info.mc_sml:getViewByFrame(1).ctn_1
	self:addicon(icon_ctn,0.5)


	self:showPacketBaseInFo()
	self:createData()

	if self.addeffect then
		self.panel_bg:setVisible(false)
		self:addEffect()
	else
		self:registClickClose("out")
		self.panel_bg:setVisible(true)
		self.panel_tou:setVisible(true)
		self.panel_info:setVisible(true)
	end
end

--添加特效
function GuildHongBaoInfoView:addEffect()
	local ctn = self.ctn_eff
	ctn:removeAllChildren()
	local flaName = "UI_xianmeng_hongbao" 
	local armatureName = "UI_xianmeng_hongbao_donghua"
	local aim = self:createUIArmature(flaName, armatureName ,ctn, false ,function ()
		self:registClickClose("out")
	end)
	self.panel_tou:setVisible(true)
	self.panel_info:setVisible(true)
	self.panel_tou:setPosition(cc.p(0,0))
	self.btn_close:setPosition(cc.p(0,0))
	self.panel_info:setPosition(cc.p(0,0))
	local aimdis = aim:getBoneDisplay("chutubiao")
	FuncArmature.changeBoneDisplay(aimdis, "node1", self.panel_tou)  --替换
	FuncArmature.changeBoneDisplay(aim, "guanbi", self.btn_close)  --替换
	FuncArmature.changeBoneDisplay(aim, "node1", self.panel_info)  --替换
	aim:startPlay(false, true )

end

--抢导红包的详情
function GuildHongBaoInfoView:grabPacketInfo()
	local num = self:myselfGetNum()  ---抢到了多少奖励
	self.panel_info.mc_sml:getViewByFrame(1).txt_2:setString(num)
end


--显示奖励总额
function GuildHongBaoInfoView:showPacketBaseInFo()
	local packetId = self.packetData.packetId ---红包ID
	local baseData = FuncGuild.getpacketDataById(packetId)
	local sumRewardnum = baseData.reward
	-- echo("=====sumRewardnum==========",sumRewardnum)
	self.panel_info.panel_zong.txt_2:setString(sumRewardnum)
	local getAll,getNum = self:getPacketIsNil() --领取的数量---已抢光，领取

	-- self.panel_info.panel_zong.txt_3:setString("已领取:"..getNum.."/"..baseData.num)


	self:addicon(self.panel_info.panel_zong.ctn_1)

	-- if getAll then
	-- 	self.mc_yi:showFrame(1)
	-- else
	-- 	self.mc_yi:showFrame(2)
	-- end

end

function GuildHongBaoInfoView:myselfGetNum()
	local data = self:getAllData()
	local num = 0
	for k,v in pairs(data) do
		if v.rid == UserModel:rid() then
			num = v.num
		end
	end
	return num
end

function GuildHongBaoInfoView:getPacketIsNil()
	local data = self:getAllData()
	local num = 0
	for k,v in pairs(data) do
		if v.rid then
			num = num + 1
		end
	end

	local packetId = self.packetData.packetId ---红包ID
	local baseData = FuncGuild.getpacketDataById(packetId)

	if num >= baseData.num then
		return true,num
	end
	return false,num
end

function GuildHongBaoInfoView:getAllData()
	local data = {}
	local index = 1
	for k,v in pairs(self.packetData) do
		if type(v) == "table"  then
			if v.rid ~= nil then
				data[index]	= v
				index = index + 1
			end
		end
	end

	local function sortFunc(a, b)
		if tonumber(a.num) > tonumber(b.num) then
			return true
		end
		return false
	end


	table.sort(data, sortFunc)

	return data
end



function GuildHongBaoInfoView:createData()

	-- local allData = {}
	local allData = self:getAllData()
	

	self.panel_info.panel_3:setVisible(false)
	local createCellFunc = function ( itemData ,index)
        local view = UIBaseDef:cloneOneView(self.panel_info.panel_3);
        self:updateLeftCell(view,itemData,index)
        return view        
    end

    local function updateCellFunc(itemData,view)
    	 self:updateLeftCell(view,itemData)
    end

	local params =  {
        {
            data = allData,
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -28, width = 450, height =28},
            perFrame = 1,
        }
    }
    self.panel_info.scroll_1:styleFill(params)
    self.panel_info.scroll_1:hideDragBar()
end

function GuildHongBaoInfoView:updateLeftCell(view,itemData,index)
	local name = itemData.name

	if itemData.rid == UserModel:rid() then
		view.mc_di:setVisible(true)
		view.mc_di:showFrame(1)
		view.txt_1:setVisible(true)
		-- view.txt_1:setString("")
	else
		view.mc_di:getViewByFrame(2).panel_e_bg:setVisible(false)
		view.txt_1:setVisible(false)
		view.mc_di:setVisible(true)
		view.mc_di:showFrame(2)
		view.mc_di:getViewByFrame(2).txt_3:setString(name)
	end


	

	self:addicon(view.ctn_1)
	local num = itemData.num  ---每个人分的红包奖励数量
	view.txt_3:setString(num)
	if index == 1 then
		view.txt_2:setVisible(true)
	else
		view.txt_2:setVisible(false)
	end

end

function GuildHongBaoInfoView:addicon(_ctn,scale)
	local id = self.packetData.packetId 
	local baseData = FuncGuild.getpacketDataById(id)
	local iconpath = FuncRes.iconRes(baseData.rewardType,baseData.rewardType)
	local icon = display.newSprite(iconpath)
	icon:setScale(scale or 0.4)
	_ctn:removeAllChildren()
	_ctn:addChild(icon)
end


function GuildHongBaoInfoView:press_btn_close()
	self:startHide()
end


return GuildHongBaoInfoView;
