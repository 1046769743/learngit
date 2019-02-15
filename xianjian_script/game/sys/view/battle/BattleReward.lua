



--[[
战斗奖励
]]
local BattleReward = class("BattleReward", UIBase);




BattleReward.winRwd= 
{
    [1]="10,101,100" ,
    [2]="10,101,101", 
    [3]="10,102,300", 
    [4]="10,104,100" ,
    [5]="10,105,100", 
    [6]="10,105,100",
    [7]="10,105,100",
    [8]="10,105,100",
    [9]="10,105,100",
    [10]="10,105,100",
}




--[[
@params params 表示的是奖励宝箱
]]
function BattleReward:ctor(winName,params)
    BattleReward.super.ctor(self, winName);
    -- echo("战斗结算的  数据")
    -- dump(params)
    -- echo("战斗结算的  数据")
    self.params = params

    --self.isLvUp = params.preLv < UserModel:level()

    echo("是否升级--------",isLvlUp,"============")
    if not LoginControler:isLogin() then
        self.isLvUp = false
    else
        self.isLvUp = UserModel:isLvlUp() --params.preLv < UserModel:level()
    end
    
    if not LoginControler:isLogin() then
        self.rwd = self.winRwd
    else
        self.rwd = self.params.reward
        self.rwdRatio = self.params.ratio or 1
    end

    --test 
    --self.isLvUp = true


end

function BattleReward:loadUIComplete()
    self:registerEvent();
    self.panel_shipei:setVisible(false)
    self.mc_yueka:visible(false)
    -- 居中
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_1,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_2,UIAlignTypes.MiddleTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1,UIAlignTypes.MiddleBottom)

    --
    AudioModel:playMusic(MusicConfig.s_com_reward, false)

    -- 注册点击任意地方事件

    --3秒后才可以点击胜利界面关闭
    local tempFunc = function (  )
        self:registClickClose(nil, c_func(self.pressClose, self))
    end


    --self.txt_2:visible(false)

    self:delayCall(tempFunc, 1.5)

    --FuncArmature.loadOneArmatureTexture("UI_tongyonghuode",nil,true)
    -- 使用 UI_zhandoujiesuan_chutubiao
    --FuncArmature.loadOneArmatureTexture("UI_zhandoujiesuan",nil,true)
    

    self:delayCall(c_func(self.loadAni,self), 1/GameVars.GAMEFRAMERATE)
    -- self:loadAni()


    self:loadItems()

end 





--[[
加载动画
]]
function BattleReward:loadAni(  )
    local tempY = (GameVars.height - GameVars.gameResHeight)/2

    local callBack
    callBack = function()
        self.boxAni:pause(false) 
        self.boxAni:getBoneDisplay("xuhuan"):playWithIndex(0, true)   
    end
   

    -- self.boxAni = FuncArmature.createArmature("UI_zhandoujiesuan_baoxiang",self.ctn_1,false,GameVars.emptyFunc)
    self.boxAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_baoxiang",self.ctn_1,false,function()
       callBack()
    end)
    -- self.boxAni:pos(-20,-50)
    self.boxAni:removeFrameCallFunc()
    -- self.boxAni:registerFrameEventCallFunc(nil, false, callBack)
    -- self.boxAni:visible(false)
    self.ctn_1:pos(0,40)

    -- self.bgAni = FuncCommUI.createSuccessArmature(10):addto(self.ctn_1):pos(0,-60)
    -- self.bgAni:getBone("di2"):visible(false)
    -- self.bgAni:getBoneDisplay("di1"):getBone("renyi"):visible(true)

    --
    -- self.txt_2:visible(true)
    -- self.txt_2:pos(-310,16)
    -- FuncArmature.changeBoneDisplay(self.bgAni:getBoneDisplay("di1"),"renyi",self.txt_2)
    local bgAni = self:createUIArmature("UI_tongyongjiesuan", "UI_tongyongjiesuan_gongxihuode", self.ctn_2, false);

    bgAni:registerFrameEventCallFunc(10,1,function ()
        -- self.boxAni:visible(true)
    end)
    bgAni:registerFrameEventCallFunc(60,1,function ()
        bgAni:pause(false)
        bgAni:getBoneDisplay("saoguang"):playWithIndex(0, true)
    end)
    bgAni:pos(550,-180-tempY)
    FuncArmature.changeBoneDisplay(bgAni,"node",self.ctn_1)
end



--[[
加载 奖励
]]
function BattleReward:loadItems(  )
    self.mc_1:showFrame(#self.rwd)
    local handledReward = {}
    for i,v in ipairs(self.rwd) do
        local str_table = string.split(v, ",")
        local quility = FuncDataResource.getQualityById(str_table[1], str_table[2])
        handledReward[i] = {reward = v, quility = quility}
    end
    table.sort(handledReward, function (a, b)
            if tonumber(a.quility) > tonumber(b.quility) then
                return true
            end
            return false
        end)

    for k = 1, #self.rwd, 1 do
        local itemStr = handledReward[k].reward
        self.mc_1.currentView["panel_"..k].UI_1:visible(false)

        local createAniFunc = function(index,data)
            self.mc_1.currentView["panel_"..index].showAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_chutubiao",self.mc_1.currentView["panel_"..index].ctn_1, false, GameVars.emptyFunc)    
            local itemNode = self.mc_1.currentView["panel_"..index].UI_1
            itemNode:visible(true):pos(5, -5)
            -- echo("data--------------",self.rwdRatio)
            -- dump(data)
            -- echo("data--------------")
            -- local dataArr = string.split(data, ",")
            -- dump(dataArr)
            -- local itemData = {}
            -- itemData.type = dataArr[1]
            -- itemData.itemId = dataArr[2]
            -- itemData.itemNum = dataArr[3]
            
            -- dump(itemData)
            dump(data, "单个奖励数据")
            local tmp = string.split(data,",")
            local rwd = {}
            if self.rwdRatio and tmp and #tmp == 3 then
                rwd.reward = string.format("%s,%s,%s",tmp[1],tmp[2],tmp[3]*self.rwdRatio)
            else
                -- echo("数据---",data,self.rwdRatio)
                -- echoWarn("资源的物品没有个数，所以没有tmp[3]")
                rwd.reward = data
            end
            dump(rwd, "处理后 单个奖励数据")

            itemNode:setRewardItemData(rwd)
            itemNode:showResItemName(true, true)
            itemNode:showResItemNameWithQuality()
            FuncArmature.changeBoneDisplay(self.mc_1.currentView["panel_"..index].showAni,"node1",itemNode)
            if tonumber(tmp[1]) ~= FuncGuildExplore.guildExploreResType then  ---wk  临时添加奖励点击不显示详情
                local needNum, hasNum, isEnough, resType, resId = UserModel:getResInfo(rwd.reward)
                FuncCommUI.regesitShowResView(itemNode, resType, needNum, resId, rwd.reward, true, true)
                itemNode:setTouchSwallowEnabled(true)
            end
        end
        self.mc_1.currentView["panel_"..k]:delayCall(c_func(createAniFunc,k,itemStr),(15+(k-1)*2)/GameVars.GAMEFRAMERATE)
        self.mc_1:setPositionX(195)
    end
    if #self.rwd >4 then
        local tempY = (GameVars.height - GameVars.gameResHeight)/2
        self.mc_1:setPositionY(-270)
    end
end




function BattleReward:setViewStyle()


end 
-- 退出战斗
function BattleReward:pressClose()
    if self.isUpgrade then
        
    end
    local hasMemory,charId,chipId = self:hasMemoryChips()
    if hasMemory then
        WindowControler:showBattleWindow("MemoryCardChipsShowView",charId,chipId,isLevelUp)
    elseif  self.isLvUp then
        --echo("展示升级界面--------------------")
        WindowControler:showBattleWindow("CharLevelUpView", UserModel:level(),true);
    else
        --echo("不升级------------")
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    end

    self:delayCall(function( )
        self:startHide()
    end, 0.5) 
end


function BattleReward:registerEvent()

end

function BattleReward:playWinEff()
    
end 
 
 

function BattleReward:updateUI()

end

function BattleReward:hasMemoryChips( )
    -- 判断如果有情景卡碎片 弹窗
    -- for k = 1, #self.rwd, 1 do
    --     local data = self.rwd[k]
    --     local tmp = string.split(data,",")
    --     if tonumber(tmp[1]) == 1 then
    --         local itemData = FuncItem.getItemData(tmp[2])
    --         if itemData.subType == 403 then

    --             local chipId = tmp[2]
    --             local charId = tostring(itemData.subType_display)
                
    --             return true,charId,chipId
    --         end
    --     end
    -- end
    return false
end

function BattleReward:hideComplete()
    
    --echo("调用到了这里-=--------------------------------")

    

    -- if self.isLvUp then
    --     EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE)
    -- else
    --     FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    -- end

    BattleReward.super.hideComplete(self)
end


function BattleReward:deleteMe()
    BattleReward.super.deleteMe(self)
    self.controler = nil
end 

return BattleReward;
