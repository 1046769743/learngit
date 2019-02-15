ViewBasic = class("ViewBasic", function ( )
	return display.newNode()
end)


--初始化传入一个 viewId 进来  然后通过id 取 view素材
--ctn 传入的 容器 
ViewBasic._myImage = nil


function ViewBasic:ctor(fileName)
	--echo("____________filename = ",fileName)
	--self:setTextureName(fileName)
	self.imageView = display.newSprite(fileName)
	self.imageView:addTo(self):pos(0, 0)

end


return ViewBasic


