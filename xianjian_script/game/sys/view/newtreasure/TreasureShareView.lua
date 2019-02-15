-- TreasureShareView
-- Author: Wk
-- Date: 2018-6-11
-- 法宝分享界面
local TreasureShareView = class("TreasureShareView", UIBase);

function TreasureShareView:ctor(winName,data)
    TreasureShareView.super.ctor(self, winName);
    self.allData = data

    dump(self.allData,"22222222222")
end

function TreasureShareView:loadUIComplete()
	self:registerEvent()
	self:initData()
end 

function TreasureShareView:registerEvent()

	self.panel_di.btn_close:setTouchedFunc(c_func(self.press_btn_close, self,nil,node,quality),nil,true);
	self:registClickClose("out")

end

function TreasureShareView:initData()

    self:addSpine()
    self:setLeftDataUI()
end


function TreasureShareView:addSpine()
	

	local treasureID = self.allData.id
	local treasLihui = FuncTreasureNew.getTreasLihui(treasureID)
    self.ctn_1:removeAllChildren()
    self.ctn_1:addChild(treasLihui)

    local dataCfg = FuncTreasureNew.getTreasureDataById(treasureID)
    local _name = GameConfig.getLanguage(dataCfg.name)

	local wuling = dataCfg.wuling
	self.mc_2:showFrame(wuling)


	local frame = FuncTreasureNew.getNameColorFrame(treasureID)
	local _type = dataCfg.type
	self.mc_1:showFrame(_type)
	self.mc_3:showFrame(frame-1)

    echo("=========_name===========",_name)
	self.mc_3:getViewByFrame(frame-1).txt_1:setString(_name)


	self:showStar()
end

--星级
function TreasureShareView:showStar()

	local star = self.allData.star
	self.mc_4:showFrame(star)
end

--设置左边UI
function TreasureShareView:setLeftDataUI()


    self.panel_jiacheng.panel_4:setVisible(false)
    self.panel_jiacheng.panel_2:setVisible(false)
    self.panel_jiacheng.panel_3:setVisible(false)
    self.panel_jiacheng.panel_1:setVisible(false)

	local function createFunc1(itemData)
		local view = UIBaseDef:cloneOneView(self.panel_jiacheng.panel_4)
        return view
	end

	local function createFunc2(itemData)
		local view = UIBaseDef:cloneOneView(self.panel_jiacheng.panel_2)
        self:updateTreasInfoItem2(view, itemData)
        return view
	end

	local function createFunc3(itemData)
		local view = UIBaseDef:cloneOneView(self.panel_jiacheng.panel_3)
        self:updateTreasInfoItem3(view, itemData)
        return view
	end

    local function createFunc4(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_jiacheng.panel_1)
        self:updateTreasInfoItem4(view, itemData)
        return view
    end

    local id = self.allData.id
    local avatar = self.allData.avatar
    local star = self.allData.star
    local starSkillT = FuncTreasureNew.getStarSkillMap(id,avatar)
    local skillArrTab = {}
    for k,v in pairs(starSkillT) do
        if star >= v.star then
            v.id = k
            table.insert(skillArrTab,v)
        end 
    end

    local sortFunc = function ( t1,t2 )
        return t1.star < t2.star
    end

    table.sort(skillArrTab,sortFunc)




    local desArr = {}

    for i=1,star do
        if i <= 6 then
            -- 获取星级属性加成
            local _starP = 6
            if i == star then
                _starP = self.allData.starPoint
            end
            local des = FuncTreasureNew.getTreaStarAttr( id,i,_starP )
            table.insert(desArr,des)
        end
    end




    local _scrollParams = {
        {
            data = {1},
            createFunc= createFunc1,
            -- updateFunc = updateFunc,
            perFrame = 1,
            offsetX = 20,
            offsetY = 50,
            itemRect = {x=0, y= -40,width = 295,height = 40},
            widthGap = 0,
            heightGap = 0,
            perNums = 1,
        },
        {
            data = skillArrTab,
            createFunc= createFunc2,
            -- updateFunc = updateFunc,
            perFrame = 1,
            offsetX = 40 ,
            offsetY = -30,
            itemRect = {x=0,y= -124, width = 140,height = 124},
            widthGap = 0,
            heightGap = 0,
            perNums = 2,
        },
        {
            data = {1},
            createFunc= createFunc3,
            -- updateFunc = updateFunc,
            perFrame = 1,
            offsetX = 0,
            offsetY = 0,
            itemRect = {x=0,y= -80,width=295,height = 80},
            widthGap = 0,
            heightGap = 0,
            perNums = 1,
        },

         {
            data = desArr,
            createFunc= createFunc4,
            -- updateFunc = updateFunc,
            perFrame = 1,
            offsetX = 40 ,
            offsetY = 15,
            itemRect = {x=0,y= -50,width= 180,height = 50},
            widthGap = 0,
            heightGap = 0,
            perNums = 2,
        },
    }
    self.panel_jiacheng.scroll_1:styleFill(_scrollParams);
    self.panel_jiacheng.scroll_1:hideDragBar()

end

function TreasureShareView:updateTreasInfoItem4(view,data)
    view.txt_1:setString(data)
end


function TreasureShareView:updateTreasInfoItem3(view,data)
    local id = self.allData.id
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    view.txt_biaoti:setString(GameConfig.getLanguage("#tid_treature_ui_003")..GameConfig.getLanguage(dataCfg.xianshiweizhi))
end


function TreasureShareView:updateTreasInfoItem2(view,itemData)
    local id = self.allData.id
    -- local skillID = itemData.id
    local star = itemData.star

    -- local avatar = itemData.avatar
    -- local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    -- -- local data = TreasureNewModel:getTreasureData(id)
    -- local skills = FuncTreasureNew.getTeasureSkillsByIdAndAvatar(id,avatar)
    -- local starSkillT = FuncTreasureNew.getStarSkillMap(id,avatar)

    -- for i,v in pairs(starSkillT) do
    local v = itemData
    local skillPanel = view
    local skillData = FuncTreasureNew.getTreasureSkillDataDataById(v.skill)
    local iconPath = FuncRes.iconSkill(skillData.icon)
    local skillIcon = display.newSprite(iconPath)
    if skillData.priority == 1 then
        skillIcon:setScale(0.75)
    end
    skillPanel.ctn_1:removeAllChildren()
    skillPanel.ctn_1:addChild(skillIcon)
    -- skillPanel.panel_number.txt_1:setString(UserModel:level())
    skillPanel.txt_1:setString(GameConfig.getLanguage(skillData.name))
    -- skillPanel.panel_suo:visible(false)
    skillPanel.mc_nu:showFrame(skillData.jiaobiao)


    FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
            {treasureId = id,skillId = v.skill,index = 1,data = data})

    
end

function TreasureShareView:press_btn_close()
	
	self:startHide()
end


return TreasureShareView;
