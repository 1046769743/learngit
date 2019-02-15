-- TitleRewardView
--wk
--2016.7.15

local TitleRewardView = class("TitleRewardView", UIBase);

function TitleRewardView:ctor(winName,titleid)
    TitleRewardView.super.ctor(self, winName);
    self.titleid = titleid
end

function TitleRewardView:loadUIComplete()
	self:registerEvent();
	self.panel_1:setVisible(false)
	self.panel_sp:setVisible(false)
	self:addEffectBg()

end 

function TitleRewardView:addEffectBg()
	local _type = FuncCommUI.EFFEC_TTITLE.GONGXIHUODE
	local _bgctn = self.ctn_efbg
	local function _callback()
		self.panel_1:setVisible(true)
		self:initUI();
	    self:attributeandtitleicon(self.titleid)
	    self:registClickClose(nil, function ( ... )
			EventControler:dispatchEvent(TitleEvent.REFRESH_POWER_CHANRE_UI)
        	self:startHide();
        end)
	end

	FuncCommUI.addCommonBgEffect(_bgctn,_type,_callback)
end


function TitleRewardView:registerEvent()
	TitleRewardView.super.registerEvent();
end

--初始化界面
function TitleRewardView:initUI()
    -- 奖品特效
    -- local anim = FuncCommUI.playSuccessArmature(self.UI_1, 
    --     FuncCommUI.SUCCESS_TYPE.GET, 1, true);

    -- -- FuncCommUI.addBlackBg(self.widthScreenOffset,self._root);

    -- anim:registerFrameEventCallFunc(35, 1, function ( ... )
		
		-- end);
  --   end);

    self.panel_1.rich_1:setVisible(false)
    self.panel_1.rich_2:setVisible(false)
    self.panel_1.mc_1:setVisible(false)

    local titledata = FuncTitle.byIdgettitledata(self.titleid)
    local Attribute = titledata.battleAttribute
    if Attribute ~= nil then
	    for i=1,#Attribute do
	    	local des = TitleModel:getDesStaheTable(Attribute[i],true)
	    	self.panel_1["rich_"..i]:setString(des)
	    	self.panel_1["rich_"..i]:setVisible(true)
	    end
	    if #Attribute == 1 then
	    	local x = self.panel_1.rich_1:getPositionX()
	    	self.panel_1.rich_1:setPositionX(x + 100)
	    end
	end

    local notattribute = titledata.privileges
    if notattribute ~= nil then
    	self.panel_1.mc_1:setVisible(true)
    	if titledata.titleType == FuncTitle.titlettype.title_limit then  --限时的
    		local datalist = TitleModel:byTtetypegetTteData(titledata.titleType)
    		local time = nil 
    		if  TitleModel.alltitledata.titles[tostring(self.titleid)] ~= nil then
    			time = TitleModel.alltitledata.titles[tostring(self.titleid)].expireTime
    		end
	     	self.panel_1.mc_1:showFrame(2)
	     	if time ~= nil and  time - TimeControler:getServerTime() > 0 then
	     		local strn = "时"
		     	local times =  math.floor((time - TimeControler:getServerTime() ) /3600)
		     	if times == 0 then
		     		times = math.floor((time - TimeControler:getServerTime() ) /60)
		     		strn = "分"
		     	end
		     	if times == 0 then
		     		times = time - TimeControler:getServerTime()
		     		strn = "秒"
		     	end
				self.panel_1.mc_1:getViewByFrame(2).rich_1:setString(GameConfig.getLanguage("#tid_title_009"))  --限时称号有效时限为24小时
    		end                                                            
    	else    ---非限时的 
    		self.panel_1.mc_1:showFrame(1)
    		for i=1,#notattribute do
		    	local des = TitleModel:getDesStaheTable(notattribute[i])
		    	self.panel_1.mc_1:getViewByFrame(1).txt_1:setString(des)
		    end
		end
    end
    
end
-- 称号图标
function TitleRewardView:attributeandtitleicon(titleid)
	if titleid ~= nil then
		---加称号图标
		local titlepng = FuncTitle.bytitleIdgetpng(titleid)
		local titleicon = display.newSprite(titlepng)
		self.panel_1.ctn_name:addChild(titleicon)
	end

end

return TitleRewardView;











