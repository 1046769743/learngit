




--[[
战斗伤害统计
]]
local BattleAnalyze = class("BattleAnalyze", UIBase);


function BattleAnalyze:ctor(winName,params)
    BattleAnalyze.super.ctor(self, winName);
    --self.isUpgrade = false
    --self.battleDatas = params
    self.data = params 
end

function BattleAnalyze:loadUIComplete()
    self:registerEvent();
    self:uiAdjust()
    self:updateUI()
    --self:setViewStyle()
    --WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor):addto(self, -2)
   
end 

function BattleAnalyze:setViewStyle()


end 


--[[
界面进行适配
]]
function BattleAnalyze:uiAdjust()
    --Title左上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1,UIAlignTypes.LeftTop)
    --按钮右上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)

    -- 居上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_redup,UIAlignTypes.MiddleTop)
    local _,y = self.scroll_1:getPosition()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_1,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_2,UIAlignTypes.MiddleTop)
    local _,newY = self.scroll_1:getPosition()
    local tmpY = newY - y
    local rect1 = self.scroll_1:getViewRect()
    local height = rect1.height + tmpY*2
    local newRect1 = {
        x = rect1.x,
        y = -height,
        height = height,
        width = rect1.width,
    }
    self.scroll_1:updateViewRect(newRect1)

    local rect2 = self.scroll_2:getViewRect()
    local height = rect2.height + tmpY*2
    local newRect2 = {
        x = rect2.x,
        y = -height,
        height = height,
        width = rect2.width,
    }
    self.scroll_2:updateViewRect(newRect2)

    -- 居下
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bluedown,UIAlignTypes.MiddleBottom)
end




function BattleAnalyze:registerEvent()
    self.btn_back:setTap(c_func(self.doCloseSelf,self))
end


 

function BattleAnalyze:updateUI()

    --self:playWinEff()
    self:updateList()

    --self.
end


--[[
更新列表中的数据
]]
function BattleAnalyze:updateList(  )
    self.panel_left_1:setVisible(false)
    self.panel_right_1:setVisible(false)

    local leftData = table.values(self.data.camp1)
    local function createLeftFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_left_1)
        self:updateItem(_view,_item,_index)
        return _view
    end
    local leftParam = {
        data  = leftData,
        createFunc = createLeftFunc,
        offsetX =0,
        offsetY = 0,
        widthGap =0,
        heighGap =0,
        perFrame =1,
        perNums =1,
        itemRect = {x =0, y= -90,width = 560,height = 90},
    }
    self.scroll_1:styleFill({leftParam})

    local rightData = table.values(self.data.camp2)
    local function createRightFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_right_1)
        self:updateItem(_view,_item,_index)
        return _view
    end
    local rightParam = {
        data  = rightData,
        createFunc = createRightFunc,
        offsetX =0,
        offsetY = 0,
        widthGap =0,
        heighGap =0,
        perFrame =1,
        perNums =1,
        itemRect = {x =0, y= -90,width = 560,height = 90},
    }
    self.scroll_2:styleFill({rightParam})


    -- dump(rightData)
end

--[[
更新每一项的数据
]]
function BattleAnalyze:updateItem( view,data,index)
    view:visible(true)
    local  _spriteIcon = display.newSprite( FuncRes.iconHero(data.icon ))
    _spriteIcon:setScale(1.2)

    local quality = data.quality or 1
    local star = data.star or 1

    view.panel_1.panel_1.mc_1:showFrame(tonumber(FuncChar.getBorderFramByQuality(quality) ) )

    view.panel_1.panel_1.mc_1.currentView.ctn_1:addChild(_spriteIcon )
    view.panel_1.panel_1.mc_2:showFrame(star)

    view.panel_1.panel_1.txt_2:visible(false)
    view.panel_1.panel_1.progress_1:visible(false)
    view.panel_1.panel_1.scale9_1:visible(false)
    view.panel_1.panel_1.txt_3:setString(data.lv or 1)
    view.txt_1:setString(math.round(data.damage) )
    view.txt_2:setString(data.name)
    view.txt_3:setString("("..data.percent.."%)")
    view.progress_1:setPercent(data.percent)
end





function BattleAnalyze:doCloseSelf(  )
    echo("点击关闭按钮---------")
    self:startHide()
end


function BattleAnalyze:hideComplete()
    BattleAnalyze.super.hideComplete(self)
    -- FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
end


function BattleAnalyze:deleteMe()
    BattleAnalyze.super.deleteMe(self)
    self.controler = nil
end 

return BattleAnalyze;
