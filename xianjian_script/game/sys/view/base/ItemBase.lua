-- User: cwb
-- Date: 2015/5/11
-- item界面基础类


--------------------------------
-- @module HeroListItem


local ItemBase = class("ItemBase", UIBase)

function ItemBase:ctor(winName)
	ItemBase.super.ctor(self,winName)
	
	self:ignoreAnchorPointForPosition(false)
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)
end

-- 加载完毕
function ItemBase:loadUIComplete()
	--self._root:setPosition(cc.p(0,self.itemSize.height))	

	--self:setItemRect(self:getContainerBox() )
end

-- 刷新函数
function ItemBase:updateUI()
	return self
end


--设置itemdata
function ItemBase:setItemData( data )
	self._itemData = data
end

--获取itemdata
function ItemBase:getItemData()
	return self._itemData
end

-- 设置元素的大小
function ItemBase:setItemSize(size)
	self.itemSize = size
	self:setItemRect({x=0,y = -size.height,width = size.width,height = size.height })
end

-- 设置元素的矩形区域
function ItemBase:setItemRect( rect )
	self.itemRect = rect
end

--获取元素矩形区域 
function ItemBase:getItemRect(  )
	if not self.itemRect then
		self.itemRect = self:getContainerBox( )
	end
	return self.itemRect
end

-- 获取元素的大小
function ItemBase:getItemSize()
	if not self.itemSize then
		echo("___ItemBase:没有设置 item 的大小！")
		return nil
	end
	return self.itemSize
end

--  设置该元素存放的 scrollview
function ItemBase:setScrollView(scroll)
	self.scrollView = scroll
end

-- 检测元素存放的 scrollveiw 是否处在滑动的状态
function ItemBase:checkCanClick(  )

	if self.scrollView then
		return not self.scrollView:isMoving()
	end
	return true
end


return ItemBase