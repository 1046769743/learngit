-- ChatExpression
-- Author Wk
-- time  2017/05/26 14:10

local ChatExpression = class("ChatExpression", UIBase);

function ChatExpression:ctor(_winName)
    ChatExpression.super.ctor(self, _winName);

end
function ChatExpression:loadUIComplete()
    self:registerEvent()
 	self.imagename = {}
 	-- 	[1] = "tu1001",
 	-- 	[2] = "tu1001",
 	-- 	[3] = "tu1001",
 	-- 	[4] = "tu1001",
 	-- 	[5] = "tu1001",
 	-- 	[6] = "tu1001",
 	-- }
 	for i=1,6 do
 		self.imagename[i] = "tu100"..i
 	end



    self:iconname()
    self:setTouchSwallowEnabled(true)
    self:addIcon()

end
function ChatExpression:iconname()
	self.iconnametable = {}
	
	for i=1,30 do
		local types = self.imagename[1]
		if i <= 6 then
			types = self.imagename[i]
			-- echo("=========11111=================",types)
			-- name = ChatModel:getBiaoqingIcon(types)
		end
		self.iconnametable[i] = types
	end
end


function ChatExpression:registerEvent()
	ChatExpression.super.registerEvent(self);
	-- self:setTouchedFunc(c_func(self.touchremoveAllChildren,self),nil,true);
	-- self.panel_biaoqing:setTouchedFunc(c_func(self.touchremoveAllChildren,self),nil,true);
end
function ChatExpression:touchremoveAllChildren()
	-- echo("111111111111111111111111111111")
	-- EventControler:dispatchEvent("REMOVEBIAOQINGICON");
end

function ChatExpression:addIcon()
	local sumicon = 30
	local allcion = {}
	for i=1,sumicon do
		allcion[i] = i
	end

	-- self.panel_biaoqing.
	local genPrivateObject = function (itemdata)
		local itemView = UIBaseDef:cloneOneView( self.panel_biaoqing.panel_1)
		self:updateItem(itemView, itemdata)
		return itemView
	end

	local param={
		{
	       data = allcion,
	       createFunc = genPrivateObject,
	       perNums= 10 ,
	       offsetX= 5,
	       offsetY= 0,
	       widthGap=0,
	       itemRect={x=0,y= -30,width = 45,height = 30},
	       perFrame=0,
	    };
	}
	self.panel_biaoqing.scroll_1:setVisible(true)
    self.panel_biaoqing.scroll_1:styleFill(param);

end
function ChatExpression:updateItem(itemView,itemdata)
	-- itemView.scale9_1:setVisible(false)
	-- itemView.scroll_1:setVisible(false)

	local sprite = display.newSprite("icon/chat/"..self.imagename[1]..".png") 	
	sprite:anchor(0.5,0.5)
	-- sprite:setScale(1.5)
	itemView.ctn_1:addChild(sprite)
	sprite:setTouchedFunc(c_func(self.ShowPrivateChatView,self,itemdata),nil,true);

end
function ChatExpression:ShowPrivateChatView(itemdata)
	echo("=========itemdata================",itemdata)
	-- local name = self.iconnametable[tonumber(itemdata)]
	-- dump(self.iconnametable,"00000000000")
	local types = self.iconnametable[itemdata]
	local name = ChatModel:getBiaoqingIcon()[types]
	self:Landbackiconname("["..name.."]")
end
--当前view
function ChatExpression:Landbackiconname(name)
	return self.callback(name)
end
--主界面view
function ChatExpression:callbackiconname(callback)
	self.callback = callback
end


function ChatExpression:clickButtonClose()
    self:startHide()
end
return ChatExpression
