--[[
    Author: pangkangning
    Date:2017-08-17
    Description: 战斗中显示伙伴当前属性
]]

local BattleDebugAttrView = class("BattleDebugAttrView", UIBase);


function BattleDebugAttrView:ctor(winName)
    BattleDebugAttrView.super.ctor(self, winName)
    self.selectIdx = 1
end

function BattleDebugAttrView:loadUIComplete()
	self:registerEvent()

    self:loadData()
end 

function BattleDebugAttrView:registerEvent()
	BattleDebugAttrView.super.registerEvent()

    self.btn_back:setTap(c_func(self.press_btn_back, self));
    self.panel_md:visible(false)
end
function BattleDebugAttrView:loadData( )
    
    local userData = {}
    local objTbl = BattleControler.gameControler.campArr_1
    for k,obj in pairs(objTbl) do
        table.insert(userData,{obj.data.hid,obj.data,})
    end

    local mtScroll = self.scroll_mt
    self.txt_mt:parent(mtScroll.scrollNode)
    --初始设置scrollNodeRect为基础大小
    mtScroll:setScrollNodeRect(table.copy(mtScroll.viewRect_ ))
    local createFunc = function (itemData  )
        local view = UIBaseDef:cloneOneView(self.panel_md)
        local name = itemData[2]:getName() or "未知名字"
        view.txt_md:setString(name)
        view.itemData = itemData
        view:setTouchedFunc(c_func(self.showModelData,self,itemData[2]) )
        return view
    end
    local params = {
        {
            data = userData,
            createFunc = createFunc,
            itemRect = self.panel_md:getContainerBox(), --{x=0,y=-46,width = 142,height = 46},
            perNums= 1,
            offsetX =2,
            offsetY = 2,
            widthGap =10,
            heightGap =5,
            perFrame = 5
        }

    }
    self.scroll_md:styleFill(params)
end

function BattleDebugAttrView:updateUI()
    self:visible(true)
    self:loadData()
    self.txt_mt:setString("")
end
function BattleDebugAttrView:showModelData(data)
    local txtView = self.txt_mt
    txtView:pos(0,-10)
    local newStr = "角色属性【入场时】【当前】\n"
    local oldData
    for k,obj in pairs(BattleControler.gameControler.levelInfo.campData1) do
        if tostring(data.hid) == tostring(obj.hid) then
            -- echo("sss-----初始数值---:%s",obj.def)
            oldData = obj
            break
        end
    end
    if not oldData then
        if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPvp then
            local bechData = BattleControler.gameControler.levelInfo:getBenchData(Fight.camp_1)
            for k,obj in pairs(bechData) do
                if tostring(data.hid) == tostring(obj.datas.hid) then
                    oldData = obj.datas
                    break
                end
            end
        end
    end
    if not oldData then
        echoError ("没有获取到对应的角色的数据===",data.hid)
        return
    end
    newStr = newStr.."生命 hp:    "..oldData.hp.."    "..data:hp().."\n"..
            "最大生命 maxhp:    "..oldData.maxhp.."    "..data:maxhp().."\n"..
            -- "当前怒气 energy:"    ..oldData.energy.."    "..data:energy().."\n"..
            "最大怒气 maxenergy:    "..oldData.maxenergy.."    "..data:maxenergy().."\n"..
            "攻击 atk:    "..oldData.atk.."    "..data:atk().."\n"..
            "物防 def:    "..oldData.def.."    "..data:def().."\n"..
            "暴击率 crit:    "..oldData.crit.."    "..data:crit().."\n"..
            "抗暴击率 resist:    "..oldData.resist.."    "..data:resist().."\n"..
            "暴击强度 critR:    "..oldData.critR.."    "..data:critR().."\n"..
            "格挡率 block:    "..oldData.block.."    "..data:block().."\n"..
            "破击率 wreck:    "..oldData.wreck.."    "..data:wreck().."\n"..
            "伤害率 injury:    "..oldData.injury.."    "..data:injury().."\n"..
            "免伤率 avoid:    "..oldData.avoid.."    "..data:avoid().."\n"..
            "吸血率 suckR:    "..oldData.suckR.."    "..data:suckR().."\n"..
            "反伤率 thorns:    "..oldData.thorns.."    "..data:thorns().."\n"..
            "法防 magdef:    "..oldData.magdef.."    "..data:magdef().."\n"..
            "效果命中 buffHit:    "..oldData.buffHit.."    "..data:buffHit().."\n"..
            "效果抵抗 buffResist:    "..oldData.buffResist.."    "..data:buffResist().."\n"..
            "治疗效果比率 cureR:    "..oldData.cureR.."    "..data:cureR().."\n"..
            "被治疗效果比率 curegetR:    "..oldData.curegetR.."    "..data:curegetR().."\n"

    local allView = self.scroll_md:getAllView()
    for i,v in ipairs(allView) do
        if v.itemData[2] == data then
            v.mc_1:showFrame(2)
            self.selectIdx = i
        else
            v.mc_1:showFrame(1)
        end
    end
    local height = 800
    txtView:setTextHeight(height)
    txtView:setString(newStr)
    self.scroll_mt:setScrollNodeRect( cc.rect( 0,-height,txtView:getContentSize().width,height ) )
end
function BattleDebugAttrView:press_btn_back( )
    self:visible(false)
end


return BattleDebugAttrView
