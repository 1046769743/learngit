--
-- Author: pangkangning
-- Note:六界轶事玩法刷怪界面
-- Date: 2017-12-23 
--
local BattleRefreshView = class("BattleRefreshView", UIBase)

local POSX = {200,135,70}
local POSY = -116
local tmpT = 0.2 --动画时间
function BattleRefreshView:loadUIComplete(  )
    FuncCommUI.setViewAlign(self.widthScreenOffset,self,UIAlignTypes.LeftTop)

	self.monsterArr = {}

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_REFRESH_COUNT, self.onRefreshMonster, self)
end
function BattleRefreshView:initControler( view,controler )
    self._battleView = view
    self.controler = controler
    if self.controler.levelInfo:chkIsRefreshType() then
	    local refreshArr = self.controler.reFreshControler:getRefreshArr()
	    if not refreshArr then
	    	echoError ("找策划，level 表中refresh 字段没有填相关的刷怪逻辑",self.controler.levelInfo.hid)
	    	return
	    end
	    self:updateVisible(true)
	    self:updateMonsterCount(#refreshArr)
	    for i=1,3 do
            local icon = self.controler:getIconByAttr(refreshArr[i])
            local view = self:getOneMonsterIcon(icon):addTo(self)
            view:pos(POSX[i],POSY)
            table.insert(self.monsterArr,view)
	    end
    end
end
-- 更新怪物数量
function BattleRefreshView:updateMonsterCount( num )
    if num < 10 then
        self.mc_gjj:showFrame(1)
        self.mc_gjj.currentView.mc_1:showFrame(num+1)
    else
        self.mc_gjj:showFrame(2)
        local a = math.floor(num/10)
        local b = num - a*10
        self.mc_gjj.currentView.mc_1:showFrame(a+1)
        self.mc_gjj.currentView.mc_2:showFrame(b+1)
    end
end
-- 初始化一个怪物头像
function BattleRefreshView:getOneMonsterIcon(icon)
	local view = UIBaseDef:cloneOneView(self.panel_2)

    local iconSpr = display.newSprite( FuncRes.iconHero(icon))
    iconSpr:setScale(0.6)
	view:addChild(iconSpr)
	return view
end
-- 头像刷新飞出
function BattleRefreshView:iconMoveOut( view )
	local a1 = cc.FadeOut:create(tmpT)
	local a2 = cc.MoveTo:create(tmpT, cc.p(300,POSY))
	view:runAction(cc.Sequence:create(cc.Spawn:create(a1,a2),cc.CallFunc:create(function( )
		view:removeFromParent()
	end)))
end
-- 头像刷新位置
function BattleRefreshView:iconMoveToIdx(view,f,t,cb)
	local time = tmpT * (f - t)
	local a1 = cc.MoveTo:create(time, cc.p(POSX[t],POSY))
	view:runAction(cc.Sequence:create(a1,cc.CallFunc:create(function( )
		if cb then cb() end
	end)))
end
-- 将一个头像移除
function BattleRefreshView:removeOneHead(idx,iconName)
    local view = nil
    if #self.monsterArr > 0 then
        view = self.monsterArr[1]
        table.remove(self.monsterArr,1)--始终移除第一个
    else
        view = self:getOneMonsterIcon(iconName):addTo(self)
    end
    if idx == 1 then
        self:iconMoveOut(view)
    else
        local tmp = idx > 3 and 3 or idx --从3的位置飘走
        self:iconMoveToIdx(view,tmp,1,function( )
            self:iconMoveOut(view)
        end)
    end
end
-- 添加一个头像
function BattleRefreshView:addOneHead( idx,icon )
    local view = nil
    if #self.monsterArr >= idx then
        view = self.monsterArr[idx]
    else
        view = self:getOneMonsterIcon(icon):addTo(self)
        table.insert(self.monsterArr,view)
    end
    self:iconMoveToIdx(view,3,idx)
end

function BattleRefreshView:onRefreshMonster( event )
    if self.controler:isQuickRunGame() then
        return
    end
    local refreshArr = self.controler.reFreshControler:getRefreshArr()
    if not refreshArr then
        -- 没有可刷的怪了
        return
    end
    local count = #refreshArr
	self:updateMonsterCount(count)

    local tmpArr = event.params
    -- 移除刷新的怪
    for i=1,#tmpArr do
        self:delayCall(function( )
            local icon = tmpArr[i].data:getIcon()
            self:removeOneHead(i,icon)
        end,(i-1) * tmpT)
    end
    -- 刷新新的怪
    count = count > 3 and 3 or count
    for i=1,count do
        self:delayCall(function( )
            local icon = self.controler:getIconByAttr(refreshArr[i])
            self:addOneHead(i,icon)
        end,(#tmpArr-1 + i) * tmpT)
    end
end

-- 展示ui
function BattleRefreshView:updateVisible(value)
	self:visible(value)
	self.panel_2:visible(false)
end
return BattleRefreshView