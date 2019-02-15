--//购买天赋点资源条UI
--//2016-6-2 10:38:26
--//小花熊
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopTalentView=class("CompResTopTalentView",ResTopBase)

function CompResTopTalentView:ctor(_name)
    CompResTopTalentView.super.ctor(self,_name)
end
--//
function CompResTopTalentView:loadUIComplete()
     CompResTopTalentView.super.loadUIComplete(self);
    self:registerEvent()
--//加入动画
    self:updateUI();
end
--//
function CompResTopTalentView:getIconAnimName()
   return "UI_common_tianfusaoguang";
end
--//
function CompResTopTalentView:getIconAnimCtn()
  return self.ctn_2
end
--//
function CompResTopTalentView:getIconNode()
  return self.panel_icon_tianfu
end
--//
function CompResTopTalentView:registerEvent()
	CompResTopTalentView.super.registerEvent(self)
--//
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
    --用于切换用户数据更新显示
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.updateUI, self)
--//按钮事件
   self.btn_tilijiahao:setTap(c_func(self.clickButtonTalent,self));
end
--//UI
function CompResTopTalentView:updateUI()
--//显示目前的天赋点数,和上限
   local  talentNum=UserModel:getTalentPoint();
   self.txt_tili:setString(talentNum);
end
--//获取天赋点数途径
function  CompResTopTalentView:clickButtonTalent()
   WindowControler:showWindow("GetWayListView", "16");
end
return CompResTopTalentView
