--成就的tips显示
local TipItemView6 = class("TipItemView6", InfoTipsBase);

function TipItemView6:ctor(winName)
    TipItemView6.super.ctor(self, winName);
end

function TipItemView6:loadUIComplete()
	self:registerEvent();
end 

function TipItemView6:registerEvent()
	TipItemView6.super.registerEvent();

end

--资源类型字符串
function TipItemView6:setUI(questId)

    local nameTid = FuncQuest.getQuestName(1, questId);
    local nameStr = GameConfig.getLanguage(nameTid);

    local desId = FuncQuest.getQuestDes(1, questId);
    local desStr = GameConfig.getLanguage(desId);

    self.txt_1:setString(nameStr)
    self.rich_2:setString(desStr)

    local iconName = FuncQuest.readMainlineQuest(questId, "icon");
    local iconPath = FuncRes.iconQuest(iconName)
    local iconSp = display.newSprite(iconPath); 

    self.ctn_icon:addChild(iconSp);
    self.ctn_icon:setScale(0.7);
end


function TipItemView6:updateUI()
	
end


return TipItemView6;
