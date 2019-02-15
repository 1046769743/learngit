-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成


local ChatViewItem = class("ChatViewItem", UIBase)


function ChatViewItem:ctor(winName, _sire)
    ChatViewItem.super.ctor(self, winName)
 

end
function ChatViewItem:initData(data)

end  
function ChatViewItem:updateSignItem()
 
end 
 

function ChatViewItem:updateItem(view, data)
 
end 
 

function ChatViewItem:loadUIComplete()
    self:registerEvent()
    self:initData()
 
end

function ChatViewItem:registerEvent()

    EventControler:addEventListener(StarlightEvent.STARLIGHT_EVENT_UPDATE, self.updateSignItem, self)
end 
function ChatViewItem:updateCombineState()
 
end 

function ChatViewItem:updateUI(isShow)
 

end
 

function ChatViewItem:chooseItem(itemView, index, _itemdata)
 

end


function ChatViewItem:deleteMe()
    ChatViewItem.super.deleteMe(self)
    self.controler = nil
end

return ChatViewItem  
-- endregion
