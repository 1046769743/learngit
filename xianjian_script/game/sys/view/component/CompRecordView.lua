--成就的tips显示
local CompRecordView = class("CompRecordView", UIBase);

function CompRecordView:ctor(winName)
    CompRecordView.super.ctor(self, winName);

end

function CompRecordView:loadUIComplete()
	self:registerEvent();
end 

function CompRecordView:registerEvent()
	CompRecordView.super.registerEvent();
end

--资源类型字符串
function CompRecordView:setUI(questId)
    local nameTid = FuncQuest.getQuestName(1, questId);
    local nameStr = GameConfig.getLanguage(nameTid);

    local desId = FuncQuest.getQuestDes(1, questId);
    local desStr = GameConfig.getLanguage(desId);

    self.txt_1:setString(nameStr)
    self.rich_2:setString(desStr)

    local iconName = FuncQuest.readMainlineQuest(questId, "icon");
    local iconPath = FuncRes.iconQuest(iconName)
    local iconSp = display.newSprite(iconPath); 

    self.ctn_1:addChild(iconSp);
end

function CompRecordView:updateUI()
	
end


return CompRecordView;
