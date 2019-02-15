
local NumberEffect = class("NumberEffect", function()
    return display.newNode()
end )

local numerToFrameMap = {
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["0"] = 10,
    ["."] = 11,
    ["+"] = 12,
    ["-"] = 13,
    ["*"] = 14,
    ["/"] = 15,
    ["%"] = 16,
    [":"] = 17,

}

--存储数字mc的数组 格式 {1=mc1,2=mc2,...}
NumberEffect.numMcArr = nil

-- @function 构造函数默认参数
-- @param userData  :view 数字绘制底板
-- @param string or integer  :number 1 - 9 ,0  . +  *  / % : 数值
-- @param  integer  :width  单个字符宽度
-- @param ........... 待扩展 特效 动作.....
-- @param  { uiCfg = xxx, number = 53421.+*/% , width = 50,halign="left",valign ="up"} 
function NumberEffect:ctor(param)
    param = param or {}
    self.numberRes = param.uiCfg or nil
    if not self.numberRes then
        echoError("没有找到uiCfg--")
    end
    self.numMcArr = {}
    -- ##默认有缺省view
    self.text = param.number or ""
    self.numberVer = { }
    self._length = 0
    self.singleNumWidth = param.width or 40 
    self.halign = param.halign or "left"
    self.valign = param.valign or "up"
    self._height = param.height
    self.strNode = nil
    self:initData()


end


--对齐view
function NumberEffect:alignView(  )
    
end


--获取一个mc
function NumberEffect:getOneNums( index,frame )
    if not self.numMcArr[index] then
        self.numMcArr[index] =   display.newSprite("a/a2_4.png"):addto(self) --MultiStateExpand.new(self.numberRes,true):addto(self)
    end
    local sp = self.numMcArr[index]
    local cfgs =self.numberRes
    local frameInfo  =cfgs.fm[frame]
    if not frameInfo then
        echoError("取不到frameInfo====",index,frame)
        dump(cfgs.fm,"cfgs.fm====",2)
    end
    if  #frameInfo ==0  then
        sp:visible( false)
    else
        local childInfo = frameInfo[1]

        sp:visible( true)
        local pngName = childInfo.img
        --如果是用散图的
        if CONFIG_USEDISPERSED then
            sp:setTexture("uipng/"..pngName)
        else
            if UIBaseDef:isGlobalPng( pngName ) then
                sp:setTexture("uipng/"..pngName)
            else
                sp:setSpriteFrame(pngName)
            end
            --local spframe = display.newSpriteFrame(pngName)
            
        end
        local xpos,ypos = childInfo.m[1],childInfo.m[2]
        sp:setPosition(xpos,ypos)
        sp:anchor(0,1)
        -- UIBaseDef:setTransform( sp,cfgs )
    end


   
    return sp
end

--隐藏多余的mc
function NumberEffect:hideNoneUseMc(  )
    for i=self._length+1,#self.numMcArr do
        self.numMcArr[i]:visible(false)
    end
end


-- 初始化默认值
function NumberEffect:initData()
    self.numberVer = { }
    --先移除所有子对象
    -- self:removeAllChildren()
    self._length = string.len(self.text)
    local _text = self.text
    local _str = _yuan3(type(_text) ~= "string", tostring(_text), _text)

    --记录总宽度 然后做偏移
    local totalWid = self.singleNumWidth * self._length
    local widOffset 
    if self.halign =="left" then
        widOffset =0
    elseif self.halign =="center" then
        widOffset = -totalWid/2
    else
        widOffset = -totalWid
    end
    local heiOffset = self._height
    if heiOffset then
        if self.valign == "up" then
            heiOffset =0
        elseif  self.valign =="center" then
            heiOffset = heiOffset/2
        else
            heiOffset = -heiOffset
        end
    end
   
    for i = 1, self._length do
        local _node = self:getOneNums(i,numerToFrameMap[string.sub(_str, i, i)])  --self:getStrView(string.sub(_str, i, i)) 
        -- _node:showFrame()
        if not heiOffset then
            heiOffset = _node:getContainerBox().height
            if self.valign =="up" then
                heiOffset =0
            elseif  self.valign =="center" then
                heiOffset = heiOffset/2
            else
                heiOffset = -heiOffset
            end
        end
        local oldx,oldy = _node:getPosition()
        _node:pos( (i - 1) * self.singleNumWidth +  widOffset +oldx ,heiOffset + oldy) 
        
    end
    self:hideNoneUseMc()



end
 
--设置字符串
function NumberEffect:setString(_text , cfgs)

    if not _text then
        echoError("没有传入字符串")
        return
    end
    _text = tostring(_text)
    if cfgs then
        self.numberRes = cfgs
    end
    
    self.text = _text or ""
    self:initData()
    return self
end


--获取某个字段的view
function NumberEffect:getStrView( key,cfgs)
    cfgs = cfgs or self.numberRes
    local view = MultiStateExpand.new(cfgs,true)  --UIBaseDef:createViewByCfgs(cfgs)
    view:showFrame(numerToFrameMap[key])
    return view
end

return NumberEffect
