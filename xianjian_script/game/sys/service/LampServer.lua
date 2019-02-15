--//走马灯消息推送
--//2016-6-15 18:26:50
--//小花熊
local   LampServer=class("LampServer");
--//初始化并注册监听事件
function  LampServer:init()
    EventControler:addEventListener("notify_trot_lamp_340",self.notifyTrotLamp,self);
end
--//消息推送,经过处理之后
function LampServer:notifyTrotLamp(_param)
   local   _lamps=_param.params.params.data;
   local   _lamp_table={};
   local  _type=type(_lamps.lanternId);
   if(type(_lamps.lanternId)~="table")then
         local   _item={};
         _item.id=tostring(_lamps.lanternId);
         if(_lamps.param1=="")then
                _lamps.param1=GameConfig.getLanguage("tid_common_2006");
         end
         _item.name=_lamps.param1;
         if(_lamps.param2~=nil)then
               _item.treasureId=tostring(_lamps.param2);
         end
         table.insert(_lamp_table,_item);
   else
         _lamps.param2=_lamps.params or {};
         for _index=1,#_lamps.lanternId do
                local  _item={};
                _item.id=tostring(_lamps.lanternId[_index]);
                if(_lamps.param1[_index]=="")then
                     _lamps.param1[_index]=GameConfig.getLanguage("tid_common_2006");
                end
                _item.name=_lamps.param1[_index];
                _item.treasureId=tostring(_lamps.param2[_index]);
                table.insert(_lamp_table,_item);
         end
   end
--//分发消息
   EventControler:dispatchEvent(HomeEvent.TROT_LAMP_EVENT,_lamp_table);
end

LampServer:init()

return  LampServer;