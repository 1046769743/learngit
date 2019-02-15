--//走马灯,消息通知
--//2016-6-14 14:45:28
--//author:小花熊
local   TrotHoseLampView=class("TrotHoseLampView",UIBase);

function TrotHoseLampView:ctor(_name)
   TrotHoseLampView.super.ctor(self,_name);
   self.lampSequence={};
--//当前是否处于消息演示中
   self.inAction=false;
--//文字显示的实际宽度
   self.readWidth=0;
end
--//
function TrotHoseLampView:loadUIComplete()
   self:registerEvent();
   local  _rich=self.rich_1;
   local   y=_rich:getPositionY();
   local  _size=_rich:getContentSize();
   _rich:setAnchorPoint(cc.p(0,0));
--//记录富文本最初的坐标,以便到后来动画结束后恢复
   self.originX,self.originY=self.rich_1:getPosition();
--//由于富文本上的字体显示与flash上的位置有一定的差距,大概搓动8像素(垂直上),所以需要将模板手动调整
   local    _stencil=self.panel_stencil:getChildren()[1];--cc.Sprite:create("uipng/lamp_template.png");
   _stencil:retain();
   _stencil:removeFromParent(false);
   _stencil:setAnchorPoint(cc.p(0,0));
   local _stencil_size=_stencil:getContentSize();  
   if(device.platform=="android")then
   _stencil:setPositionY(14);
   _stencil:setScaleY((_stencil_size.height-14)/_stencil_size.height);
   else
   _stencil:setPositionY(17);
   _stencil:setScaleY((_stencil_size.height-17)/_stencil_size.height);
   end
   self.stencilWidth=_stencil_size.width;
   local    _clipNode=cc.ClippingNode:create(_stencil);
   _stencil:release();
   _clipNode:setAnchorPoint(cc.p(0,0));
   _clipNode:setPosition(cc.p(self.originX,self.originY-_size.height));
   _rich:setPosition(cc.p(0,0));
   _clipNode:setCascadeOpacityEnabled(true);
   local  _parent=_rich:getParent();

   _rich:parent(_clipNode)
--//将富文本设置到最右边缘
   _rich:setPosition(cc.p(self.stencilWidth,0));
   _rich:release();
   _parent:addChild(_clipNode);
   _parent:setCascadeColorEnabled(true);
    _parent:setOpacity(0);
    self.rootNode=_parent;
--//原始尺寸
    self.originSize=self.rich_1:getContentSize();
end
--//
function TrotHoseLampView:registerEvent()
    TrotHoseLampView.super.registerEvent(self);
end
--//设置页面
function TrotHoseLampView:updateLampTips(_lampTips)
    local   _lampId=_lampTips.id;
    local   _lamp_table=FuncLamp.getLamp();
    echo("-----TrotHoseLampView-------- lamp is",_lampId);
    local   _lamp_item=_lamp_table[_lampId];
    local   _lamp_name=_lampTips.name;
    local   _lamp_treasure=nil;
    if(_lampTips.treasureId~=nil)then
           local  _treasure_table=FuncTreasure.getTreasureAllConfig();
           local  _treasure_item=_treasure_table[_lampTips.treasureId];
           _lamp_treasure=GameConfig.getLanguage(_treasure_item.name);
    end
    local   _rich=self.rich_1;
--//在富文本中合成消息提示
    _rich:initRichText();--//初始化富文本
--//如果该向含有1个课替换的参数
    local   _content=GameConfig.getLanguage(_lamp_item.text);
    if(#_lamp_item.typeArr<2)then
          local    _text=string.split(_content,"#1");
          self.realWidth=FuncCommUI.getStringWidth(_text[1].._lamp_name.._text[2],22,GameVars.systemFontName);
    --      _rich._richText :setContentSize(cc.size(self.realWidth,self.originSize.height));
          self.lampIndex=1;
          local    _label1=_rich:getRichElementText(1,cc.c3b(255,255,255),255,_text[1],GameVars.systemFontName,22);
          _rich:pushBackElement(_label1);
          
          local   _size2=string.lenword(_lamp_name);
          local   _index=0;
          while(_index<_size2)do
                 local    real_size=(_size2<_index+50) and  (_size2-_index) or 50;
                local   _other_string=string.subcn(_lamp_name,_index+1,real_size);
  --              echo(_other_string)
                local    _label2=_rich:getRichElementText(1,cc.c3b(0x65,0xFA,0xFF),255,_other_string,GameVars.systemFontName,22);
                _rich:pushBackElement(_label2);
                _index=_index+50;
          end
          local    _label3=_rich:getRichElementText(1,cc.c3b(255,255,255),255,_text[2],GameVars.systemFontName,22);
          _rich:pushBackElement(_label3);
    else
         local    _text=string.split(_content,"#1");
         local    _other_text=string.split(_text[2],"#2");
         local   _label1=_rich:getRichElementText(1,cc.c3b(255,255,255),255,_text[1],GameVars.systemFontName,22);
         _rich:pushBackElement(_label1);
          local   _label2=_rich:getRichElementText(1,cc.c3b(0x65,0xFA,0xFF),255,_lamp_name,GameVars.systemFontName,22);
           _rich:pushBackElement(_label2);

         local   _label3=_rich:getRichElementText(1,cc.c3b(255,255,255),255,_other_text[1],GameVars.systemFontName,22);
         _rich:pushBackElement(_label3);
         local   _label5=_rich:getRichElementText(1,cc.c3b(0xFF,0xDB,0x4C),255,_lamp_treasure,GameVars.systemFontName,22);
        _rich:pushBackElement(_label5);
         if(_other_text[2]~=nil)then
                  local   _label4=_rich:getRichElementText(1,cc.c3b(255,255,255),255,_other_text[2],GameVars.systemFontName,22);
                  _rich:pushBackElement(_label4);
                  self.realWidth=FuncCommUI.getStringWidth(_text[1].._lamp_name.._other_text[1].._lamp_treasure.._other_text[2],22,GameVars.systemFontName);
        else
                  self.realWidth=FuncCommUI.getStringWidth(_text[1].._lamp_name.._other_text[1].._lamp_treasure,22,GameVars.systemFontName);
         end
         self.lampIndex=2;
    end
    self.realWidth=self.realWidth+16;
end
function TrotHoseLampView:showComplete()

end
--//将消息加入到缓存队列中
function TrotHoseLampView:insertMessage(_lamp)
--//计算是否超过了30条
     if(#self.lampSequence>=30)then
           table.remove(self.lampSequence,1);
     end
     table.insert(self.lampSequence,_lamp);
     self:notifyShowLamp();
end
--//通知有新消息,但是具体是否要显示这个通知,则取决于实际的情况
function TrotHoseLampView:notifyShowLamp()
--//如果没有消息,需要直接返回,因为这个函数可能要循环回调
   if(#self.lampSequence<=0)then
        return ;
   end
--//如果处于现实动作中,则直接返回
    if(self.inAction)then--//检查看门狗
         return ;
    end
    self.inAction=true;--//禁止二次重入
--//删除队列
    local   _lamp=self.lampSequence[1];
    table.remove(self.lampSequence,1);
--//计算总的时间
    local  _size=self.rich_1:getContentSize();
--    local  _time=_size.width/60*2;--//速度,每秒60像素,从完全遮蔽到完全展现再到完全消失
--//循环回调函数
   local   function _cycleCallback()
        self.inAction=false;
        self:notifyShowLamp();
   end
--//动作设置
    local function _callback() --//最后的回调函数
--//富文本位置重置
         self.rich_1:setPositionX(_size.width);
--//判断是否需要继续将动作执行下去
         local  _cycleCall=cc.CallFunc:create(_cycleCallback);
         if(#self.lampSequence>0)then--//如果还有公告,则持续延迟一秒后继续显示
                    local  _mDelay=cc.DelayTime:create(1.0);
                    local  _seqCycleAction=cc.Sequence:create(_mDelay,_cycleCall);
                    self.rich_1:runAction(_seqCycleAction);
         else--//否则,页面淡出
                    local  _mFadeOut=cc.FadeOut:create(0.3);
                    local   _seqCycleAction2=cc.Sequence:create(_mFadeOut,_cycleCall);
                    self.rootNode:runAction(_seqCycleAction2);
         end
    end
    local  otherOffset={[1]=60,[2]=80};
--//移动富文本
   local  function _delayCallback()
        local _offsetX=(_size.width-self.realWidth)/2;
        if(_offsetX<0)then--//截断
                     self.realWidth=_size.width;
        end
        self.rich_1:setPositionX(self.stencilWidth);
        local  _time=(self.realWidth+self.stencilWidth)/60
        local  _mMove=cc.MoveBy:create(_time,cc.p(-self.realWidth-self.stencilWidth,0));
        local  _mCall=cc.CallFunc:create(_callback);
        local  _seqAction=cc.Sequence:create(_mMove,_mCall);
        self.rich_1:runAction(_seqAction);
   end
   local  function _moveCallback()
            self:updateLampTips(_lamp);--//更新富文本内容
            _size.width=self.realWidth;
            self.rich_1._richText:setContentSize(_size);
            self.rich_1._richText:setPositionX(-_size.width/2);
--//延迟一帧调用
            local  _delayCall=cc.CallFunc:create(_delayCallback);
            local  _delayTime=cc.DelayTime:create(0.01);
            local  _seqAction=cc.Sequence:create(_delayTime,_delayCall);
            self.rich_1:runAction(_seqAction);
   end
--//淡入
   local  _mFadeIn=cc.FadeIn:create(0.3);
   local _richCallback=cc.CallFunc:create(_moveCallback);
   local _seqParentCall=cc.Sequence:create(_mFadeIn,_richCallback);
   self.rootNode:runAction(_seqParentCall);
end
return  TrotHoseLampView;