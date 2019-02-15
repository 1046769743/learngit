-- 地形编辑器
local TerrainEditorScene = class("TerrainEditorScene", SceneBase)

function TerrainEditorScene:ctor(...)
	TerrainEditorScene.super.ctor(self, ...)
    --讲道理，这个应该放在SceneBase 中初始化
    self._tutoralRoot = display.newNode():addto(self.__doc)
    self._topRoot = display.newNode():addTo(self.__doc)
    self._highRoot = display.newNode():addTo(self.__doc)
end

function TerrainEditorScene:onEnter()
    TerrainEditorScene.super.onEnter(self)
    self:addMapView()
    self:addToolBar()
    -- 新建或者打开界面
    WindowControler:showWindow("EditorOpenView")
end
-- 初始化工具栏
function TerrainEditorScene:addToolBar( )
	self.barView = WindowControler:createWindowNode("EditorBarView"):addTo(self._root)
end
-- 初始化地图(空的)
function TerrainEditorScene:addMapView( )
    self.mapView = require("game.sys.view.test.EditorMapView").new():addTo(self._root)
end
function TerrainEditorScene:onExit()
    
end

return TerrainEditorScene


