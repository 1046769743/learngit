-- TrailBOSSInfoView
--试炼系统
--2017-2-8 17:10
--@Author:wukai


local TrailBOSSInfoView = class("TrailBOSSInfoView", UIBase);
function TrailBOSSInfoView:ctor(winName,_trailKind,_selectindex)
    TrailBOSSInfoView.super.ctor(self, winName);
    self._trailKind = _trailKind
    self._selectindex = _selectindex
end

function TrailBOSSInfoView:loadUIComplete()
	
	self:registClickClose(nil, function ()
        self:press_btn_close()
    end);
	self:updateUI()
    self:addNPC()
    self:BoSSSkillInfo()

end 



function TrailBOSSInfoView:updateUI()
	local BossName = {
		[1] = "淮南王",
		[2] = "财神",
		[3] = "雪妖",
	}
	self.txt_1:setString(BossName[tonumber(self._trailKind)])
	local Trailid = TrailModel:getIdByTypeAndLvl(self._trailKind,self._selectindex)
    local location = FuncTrail.getTrailData(Trailid,"location")
    local bewrite = FuncTrail.getTrailData(Trailid,"bewrite")

    self.txt_2:setString(GameConfig.getLanguage(location))
    self.txt_3:setString(GameConfig.getLanguage(bewrite))
	
end
function TrailBOSSInfoView:BoSSSkillInfo()
    -- local  skillicon = nil
    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectindex)
    
    local skillname = GameConfig.getLanguage(FuncTrail.getTrailData(id, "skillDes"))
    local skillmiaoshu = GameConfig.getLanguage(FuncTrail.getTrailData(id, "skillId"))
    -- self.ctn_skill::addChild(skillicon)
    self.txt_4:setString(skillname)
    self.txt_5:setString(skillmiaoshu)
end
function TrailBOSSInfoView:addNPC()
	-- self.ctn_1
	local ctn = self.ctn_1
    ctn:removeAllChildren();
    local bossConfig = FuncTrail.getTrialResourcesData(self._trailKind, "dynamic");
    local arr = string.split(bossConfig, ",");
    -- dump(arr, "bossConfig");
    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    self.spinBoss = sp
    sp:playLabel(arr[2]);
    sp:setPositionX(- 25);
    sp:setPositionY(- 100);
    if self._trailKind == 1 then
        sp:setScale(1.2)
        sp:setPositionX(20);
        sp:setPositionY(- 140);
    elseif self._trailKind == 2  then
        sp:setScale(0.7)
    else
        sp:setPositionX(0)
        sp:setScale(1.2)
    end
    
    

    ctn:addChild(sp);
end




function TrailBOSSInfoView:press_btn_close()
    self:startHide()
end


return TrailBOSSInfoView;







