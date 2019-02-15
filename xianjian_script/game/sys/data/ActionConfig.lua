--[[
	Author: ZhangYanguang
	Date:2017-09-19
	Description: 客户端行为日志配置
]]

-- action中不能有下划线_
ActionConfig = {
	-- 启动游戏与登录注册相关
	login_game_start = "login-game-start",		 		--启动APP
	login_check_version = "login-check-version",		--检查更新
	login_update_version = "login-update-version",		--执行更新
	login_main_view = "login-main-view",				--进入登录主界面
	login_select_server = "login-select-server",		--选服界面
	login_click_enter_game = "login-click-enter-game", 	--点击进入游戏
	login_load_game_res = "login-load-game-res",		--加载游戏资源
	login_enter_home = "login-enter-home",				--进入主城

	-- 序章及新手引导相关
	guide_select_role = "guide-select-role",			--创建角色（男女）
	guide_enter_world = "guide-enter-world",			--进入六界地图

	-- 网络相关
	-- 收到通知
	push_receive = "push-receive",
	-- 通知被点击
	push_clicked = "push-clicked",
}	

return ActionConfig