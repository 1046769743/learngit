--//聊天事件
--//2016-5-10
--//author:xiaohuaxiong
local   ChatEvent=ChatEvent or {};

ChatEvent.WORLD_CHAT_CONTENT_UPDATE="world_chat_content_update"--世界聊天内容更新
ChatEvent.LEAGUE_CHAT_CONTENT_UPDATE="league_chat_content_update"--联盟聊天内容更新
ChatEvent.LOVE_CHAT_CONTENT_UPDATE="LOVE_CHAT_CONTENT_UPDATE"--联盟缘伴内容更新
ChatEvent.PRIVATE_CHAT_CONTENT_UPDATE="private_chat_content_update"--私人聊天 内容更新
ChatEvent.FRIEND_REMOVE_ONE_PLAYER = "friend_remove_one_player"   ---删除其中一个人
ChatEvent.CHAT_SEND_SP_REWARD = "chat_send_sp_reward"  ---赠送体力回调函数
ChatEvent.CHAT_SHARE_EVENT = "CHAT_SHARE_EVENT" ----分享回调事件
ChatEvent.SYSTEM_CHAT_CONTENT_UPDATE = "SYSTEM_CHAT_CONTENT_UPDATE" ---系统的回调
ChatEvent.CHATMAIN_MESSAGE = "CHATMAIN_MESSAGE"  ---主城聊天显示
ChatEvent.TEAM_CHAT_CONTENT_UPDATE = "TEAM_CHAT_CONTENT_UPDATE" --队伍聊天内容更新
ChatEvent.REFRESH_PLAYER_ONLOINE = "REFRESH_PLAYER_ONLOINE" ---好友是否在线
ChatEvent.REFRESH_PLAYER_TIHUAN_SERVER = "REFRESH_PLAYER_TIHUAN_SERVER"  --好友替换服
ChatEvent.REMOVE_CHAT_UI = "REMOVE_CHAT_UI" ---移除聊天界面
ChatEvent.REMOVE_VOICE_UI = "REMOVE_VOICE_UI"  --移除语音发送界面
ChatEvent.SHOW_RED_TRACK = "SHOW_RED_TRACK"   --追踪栏的红点显示问题

return  ChatEvent;