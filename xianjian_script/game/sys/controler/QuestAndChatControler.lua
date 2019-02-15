-- QuestAndChatControler


--通知管理
local QuestAndChatControler = QuestAndChatControler or  {}

QuestAndChatControler.systemView = {"home","world","mission","partner","love","treasure","cimelia","guild"}  --需要显示的系统

--[[
	local data = {
		systemView = "",--系统
		view = self,---界面
        system = "",--系统名称
        data = ,---系统数据
        pos = {x,y}
	}
]]

function QuestAndChatControler:createInitUI(arrData)

    if PrologueUtils:showPrologue() or PrologueUtils:isInPrologue()  then
        return 
    end



    if arrData.systemView == "home" then
        self:showUI(arrData)
    elseif  arrData.systemView == "mission"  then
        if arrData.data then
            self:showUI(arrData)
        end
    end

end

function QuestAndChatControler:showUI(arrData)

    -- local scene = display.getRunningScene()
    local questAndChatMainView =  arrData.view:getChildByName("QuestAddMainListView")
    -- echoError("======questAndChatMainView====12222222222=======",questAndChatMainView)
    if not questAndChatMainView then
        local view = arrData.view
        self.questView = WindowControler:createWindowNode("QuestAddMainListView")
        self.questView:setName("QuestAddMainListView")
        self.questView:setArrData(arrData)
        self.questView:pos(0,GameVars.UIOffsetY)
        view:addChild(self.questView)
        FuncCommUI.setViewAlign(self.questView.widthScreenOffset,self.questView, UIAlignTypes.Left);
    end

end




return QuestAndChatControler
