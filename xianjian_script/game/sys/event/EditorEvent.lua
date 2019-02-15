--[[
    Author: pangkangning
    Date:2018-07-03
    Description: 地形编辑器事件相关处理
]]


local EditorEvent = {}

EditorEvent.EDITOR_LOAD_COMP = "EDITOR_LOAD_COMP" --数据加载完成
EditorEvent.EDITOR_RESET_SIZE = "EDITOR_RESET_SIZE" --地图尺寸变化
EditorEvent.EDITOR_GRID_CLICK = "EDITOR_GRID_CLICK" --地图坐标点击
EditorEvent.EDITOR_HANDLE_CHANGE = "EDITOR_HANDLE_CHANGE" --操作模式变化
EditorEvent.EDITOR_GRID_CHANGE = "EDITOR_GRID_CHANGE" --格子数据刷新
EditorEvent.EDITOR_REVIEW = "EDITOR_REVIEW" --预览模式

return EditorEvent