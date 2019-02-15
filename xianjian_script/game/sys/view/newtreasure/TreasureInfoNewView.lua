

local TreasureInfoNewView = class("TreasureInfoNewView", UIBase);


function TreasureInfoNewView:ctor(winName, id)
    TreasureInfoNewView.super.ctor(self, winName);
    self.treaId = id
end

function TreasureInfoNewView:loadUIComplete()
	self:registerEvent();
	self:updateUI();
end 

function TreasureInfoNewView:registerEvent()
	TreasureInfoNewView.super.registerEvent();
	self:registClickClose("out")
    self.UI_tc.btn_close:setTap(function(  )
        self:startHide()
    end)
end

function TreasureInfoNewView:updateUI()
    self.UI_tc.txt_1:visible(false)
    self.UI_tc.mc_1:visible(false)
    -- name
    local dataCfg = FuncTreasureNew.getTreasureDataById(self.treaId)
    local _name = GameConfig.getLanguage(dataCfg.name)
    local _type = dataCfg.type --定位 攻防辅
    local _aptitude = dataCfg.aptitude -- 资质
    self.panel_1.mc_1:showFrame(FuncTreasureNew.getNameColorFrame(self.treaId))
    self.panel_1.mc_1.currentView.txt_1:setString(_name)
    self.panel_1.mc_dingwei:showFrame(_type)
    self.panel_1.mc_tu2:showFrame(dataCfg.wuling)
    self.panel_1.btn_1:setVisible(false)
    -- 佩戴属性 -- 一星属性
    local key = "attribute"..1
    local sxArra = FuncTreasureNew.getTreasureDataByKeyID(self.treaId, key)
    for i,v in ipairs(sxArra) do
        if i <= 4 then
            local des = FuncTreasureNew.getAttrDesTable(v)
            self.panel_2["txt_"..i]:setString(des)
        end
    end
    -- 永久属性
    local starAttrT = FuncTreasureNew.getStarAttrMap( self.treaId )
    local index = 1
    for i,v in pairs(starAttrT) do 
        local des = FuncTreasureNew.getAttrDesTable(starAttrT[i].attr[1],false)
        self.panel_3["txt_"..i]:setString(des..GameConfig.getLanguage("#tid_treature_ui_002"))
    end
    self.panel_3["txt_"..7]:visible(false)
    self.panel_3.txt_biaoti:setString(GameConfig.getLanguage("#tid_treature_ui_003")..GameConfig.getLanguage(dataCfg.xianshiweizhi))
    -- 技能
    self:initAllSkill()
end
function TreasureInfoNewView:initAllSkill(  )
    local createFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_4.panel_skill)
        self:updateItem(view, itemData)
        return view
    end
    self.panel_4.panel_skill:visible(false)
    local updateFunc = function (_item,_view)
        self:updateItem(_view,_item)
    end
    local dataCfg = FuncTreasureNew.getTreasureDataById(self.treaId)
    local _scrollParams = {
            {
                data = dataCfg.skill,
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX =30,
                offsetY =5,
                itemRect = {x=0,y= -107,width=126,height = 107},
                widthGap = 10,
                heightGap = 0,
                perNums = 2,
            }
        }
    self.panel_4.scroll_1:styleFill(_scrollParams);
    self.panel_4.scroll_1:hideDragBar()
end
function TreasureInfoNewView:updateItem( view,skillId )
    local skillPanel =  view

    local skillData = FuncTreasureNew.getTreasureSkillDataDataById(skillId)
    local iconPath = FuncRes.iconSkill(skillData.icon)
    local skillIcon = display.newSprite(iconPath)
    skillPanel.ctn_1:removeAllChildren()
    skillPanel.ctn_1:addChild(skillIcon)

    if skillData.priority == 1 then
        skillIcon:setScale(0.69)
    end
    skillPanel.panel_number.txt_1:setString(UserModel:level())
    skillPanel.txt_1:setString(GameConfig.getLanguage(skillData.name))
    skillPanel.mc_nu:showFrame(skillData.jiaobiao)
    local index = 1
    local dataCfg = FuncTreasureNew.getTreasureDataById(self.treaId)
    for i,v in pairs(dataCfg.skill) do
        if v == skillId then
            index = i
            break
        end
    end
    local data = TreasureNewModel:getTreasureData(self.treaId)
    FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
            {treasureId = self.treaId,skillId = skillId,index = index,data = data})

end
return TreasureInfoNewView;
