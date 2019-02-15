--//好友事件
--//2016-5-4
--author xiaohuaxiong
local    FriendEvent=FriendEvent or {};

FriendEvent.FRIEND_SEND_SP_UPDATE="friend_send_sp_update";--//好友体力赠送
FriendEvent.FRIEND_APPLY_REQUEST="friend_apply_request";--//好友申请请求
FriendEvent.FRIEND_INFORMATION_REQUEST = "friend_information_request"; --玩家详情好友申请请求
FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION = "friend_add_driend_button_action"; --好友申请特效按钮
FriendEvent.FRIEND_MODIFY_NAME = "friend_modify_name";
FriendEvent.FRIEND_REMOVE_SOME_PLAYER = "friend_remove_some_player";
FriendEvent.FRIEND_FINED_FRIEND = "friend_find_friend";
FriendEvent.FRIEND_REFRESH_FIREND_COUNT = "FRIEND_REFRESH_FIREND_COUNT"  --刷新数据

return  FriendEvent;