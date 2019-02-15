-- BarrageControler

--[[
	Author: wk
	Date:2018-01-30
	Description: 弹幕控制器
]]

local BarrageControler = BarrageControler or {}

BarrageControler.ItemType = {
	rich = 1,--纯文本
	praise_rich = 2,--赞加文本
	chat = 3,	--聊天相关
	voice = 4, --纯语音
}


local BarrageTextCell = require("game.sys.view.barrage.BarrageText")
local BarrageChatTextCell = require("game.sys.view.barrage.BarrageChatText")
local BarragePraiseAndTextCell = require("game.sys.view.barrage.BarragePraiseAndText")
local BarrageVoiceCell = require("game.sys.view.barrage.BarrageVoice")

function BarrageControler:init()
	self:registEvent()
end

function BarrageControler:registEvent()
	EventControler:addEventListener(BarrageEvent.REMOVE_BARRAGE_UI,self.byNameRemoveChild,self)
	-- EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP ,self.byNameRemoveChild,self)
end

 --[[
	local arrPame = {
		system = FuncBarrage.SystemType.plot,  --系统参数
		btnPos = {x = ,y = }  --弹幕按钮的位置
		barrageCellPos = {x = ,y =}, 弹幕区域的位置
		addview = ,--索要添加的视图
		_player = ,---玩家数据
		plotData = , --剧情数据
	}
 ]]

--显示通用弹幕主界面  (系统名)
function BarrageControler:showBarrageCommUI(arrPame)

	local btnPos = arrPame.btnPos
	local system = arrPame.system
	local addview = arrPame.addview
	if system == nil then
		return 
	end

	if PrologueUtils:showPrologue() or PrologueUtils:isInPrologue()  then
		return 
	end


	---新手引导，和新系统开启
	if TutorialManager.getInstance():isHomeExistGuide() 
		or TutorialManager.getInstance():isHomeExistSysOpen() 
		or TutorialManager.getInstance():isHasTriggerSystemOpen()
	then
		if system ~= FuncBarrage.SystemType.plot then
        	return 
        end
    end

    -- if system == FuncBarrage.SystemType.world then  --六界
    -- 	local isOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHAT)
    -- 	if not isOpen then
    -- 		return
    -- 	end
    -- end


    --添加弹幕主界面
	local view = self:addUIToView(arrPame)
	if view == nil then
		return
	end
	if system == FuncBarrage.SystemType.plot then  --剧情
		arrPame = self:ployIDSort(arrPame)
		self:setPlotAllData(arrPame,view)
	elseif system == FuncBarrage.SystemType.crosspeak then --巅峰竞技场 
		local _player = arrPame._player
		_player.rid = _player._id or _player.rid
		ChatModel:setPrivateTargetPlayer(_player)
		self:setPrivateChatData(arrPame,view,_player.rid)
	elseif system == FuncBarrage.SystemType.tower then  --锁妖塔
		self:setTowerData(arrPame,view)
	elseif system == FuncBarrage.SystemType.world then  --六界
		self:setWorldData(arrPame,view)
	elseif system == FuncBarrage.SystemType.guild then  --仙盟
		self:setGuildData(arrPame,view)
	end
end

function BarrageControler:setGuildData( arrPame,view )
	if view == nil then
		return 
	end
	local allCommentData =  BarrageModel:getWorldChatData("guild")
	view.btn_danmu:setVisible(false)
	view:initData(arrPame,allCommentData)
	-- view.btn_danmu:setPosition(cc.p(pos.x,pos.y))
end
function BarrageControler:ployIDSort(arrPame)
	local plotData = arrPame.plotData
	local minID
	for k,v in pairs(plotData) do
		if minID ~= nil then
			if minID >= tonumber(v) then
				minID = tonumber(v)
			end
		else
			minID = tonumber(v)
		end
	end
	arrPame.plotData[1] = minID
	return arrPame
end

--获取剧情的所有对话
function BarrageControler:setPlotAllData(arrPame,view)
	if view == nil then
		return
	end
	local pos = arrPame.btnPos
	local plotData = arrPame.plotData
	local function cellfunc(data)
		-- dump(data,"剧情获得所有数据====22222222222=")
		if view ~= nil and view.initData ~= nil then
			view:initData(arrPame,data)
		end
	end
	local allCommentData =  BarrageModel:getPlotCommentData(plotData,cellfunc)
	view.btn_danmu:setVisible(true)
	view.btn_danmu:setPosition(cc.p(pos.x,pos.y))
	


end

--六界数据相关设计
function BarrageControler:setWorldData(arrPame,view)
	if view == nil then
		return 
	end
	local allCommentData =  BarrageModel:getWorldChatData()
	view.btn_danmu:setVisible(false)
	view:initData(arrPame,allCommentData)
end

-- 聊天相关数据设置
function BarrageControler:setPrivateChatData(arrPame,view,player_rid)
	if view == nil then
		return
	end
	local allCommentData =  BarrageModel:getPrivateChatCommentData(player_rid)
	-- if #allCommentData ~= 0 then
		view.btn_danmu:setVisible(true)
		view:initData(arrPame,allCommentData)
	-- end
end



--设置锁妖塔的评论数据
function BarrageControler:setTowerData(arrPame,view)
	if view == nil then
		return
	end
	view.btn_danmu:setVisible(false)
	local allCommentData =  BarrageModel:gettowerCommentData()
	if #allCommentData ~= 0 then
		view:initData(arrPame,allCommentData)
	end

end



---创建控件的方法
function BarrageControler:createCellModels(barrageType,view)
	local cell = nil--BarrageTextCell.new(self,view)
	-- echo("=====弹幕类型=========",barrageType)
	if barrageType == FuncBarrage.BarrageType.plot then --剧情
		cell = BarragePraiseAndTextCell.new(self,view)
	elseif barrageType == FuncBarrage.BarrageType.chat then--聊天 
		cell = BarrageTextCell.new(self,view)
	elseif barrageType == FuncBarrage.BarrageType.comments then --排行评论弹幕
		cell = BarrageTextCell.new(self,view)
	elseif barrageType == FuncBarrage.BarrageType.PVE then  --六界弹幕
		cell = BarrageChatTextCell.new(self,view)  
	end
	return cell
end

			
--添加弹幕界面到每个系统界面
function BarrageControler:addUIToView(arrPame)
	local addview = arrPame.addview
	local btnPos = arrPame.btnPos
	local system = arrPame.system
	if system == FuncBarrage.SystemType.plot then
		if arrPame.plotData ~= nil and type(arrPame.plotData) == "table" then
			if table.length(arrPame.plotData) ~= 0 then
				BarrageControler:showBarrageView(false)
				local scene = display.getRunningScene()
				local barrageMainView = WindowControler:createWindowNode("BarrageMainView")
				-- barrageMainView:setPositionY(btnPos.y or 0)
				barrageMainView:setName("BarragePlotMainView")
				scene._topRoot:addChild(barrageMainView)
				return barrageMainView
			end
		end
	elseif system == FuncBarrage.SystemType.world  or system == FuncBarrage.SystemType.guild  then
			local barrageMainView = WindowControler:createWindowNode("BarrageMainView")
			barrageMainView:setPositionY(btnPos.y or 0)
			addview:addChild(barrageMainView,100)
			return barrageMainView
	else
		BarrageControler:showBarrageView(false)
		local barrageMainView = WindowControler:createWindowNode("BarrageMainView")
		echo("\n\n\n添加BarrageMainView======")
	    -- barrageMainView:setName("BarrageMainView")
	    if addview ~= nil then
		    addview:addChild(barrageMainView,99999)
		    barrageMainView:setPositionY(btnPos.y or 0)
		    return barrageMainView
		end
	end
end

function BarrageControler:showBarrageView(isShow)
	local scene = display.getRunningScene()
	local view = scene._topRoot:getChildByName("BarrageMainView")
	if view then
		view:setVisible(isShow)
	end
end

--根据名字去掉界面
function BarrageControler:byNameRemoveChild(e)
	-- local params = e.params
	-- local scene = WindowControler:getWindow("HomeMainView")
	local scene = display.getRunningScene()
	local view = scene._topRoot:getChildByName("BarragePlotMainView")
	if view then
		view:setVisible(false)
		view:startHide()
		-- scene._topRoot:removeChildByName("BarragePlotMainView", true)
	end
end




function BarrageControler:getRankAndCommentsData(arrayData,ishowUI,callback)
	-- local arrayData = {
	-- 	systemName = FuncCommon.SYSTEM_NAME.TOWER,---系统名称
	-- 	diifID = monsterId,  --关卡ID
	-- 	flagCommentOnly = 1,
	-- 	view = "TowerMapView"
	-- }
	local function cellfunc()
		if ishowUI then
			local arrPame = {
				system = FuncBarrage.SystemType.tower,  --系统参数
				btnPos = {x = 0,y = -50},  --弹幕位置
				barrageCellPos = {x = 0,y = 50}, --弹幕区域的位置
				addview = arrayData.view,
			}

			BarrageControler:showBarrageCommUI(arrPame)   ---弹幕测试
		end
		if callback then
			callback()
		end
	end
	RankAndcommentsControler:getRankAndCommentAllData(arrayData,cellfunc)
end



























BarrageControler:init()

return BarrageControler
