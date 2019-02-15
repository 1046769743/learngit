local packageName = "game.sys.controler."
require(packageName .. "EventControler")
BattleControler = require(packageName.."BattleControler")
MiniBattleControler = require(packageName.."MiniBattleControler")
LoginControler = require(packageName.."LoginControler")
LoginInfoControler = require(packageName.."LoginInfoControler")
if DEBUG_SERVICES  then
	return
end

LogsControler = require(packageName.."LogsControler")
WindowControler = require(packageName.."WindowControler")
VerControler = require(packageName.."VerControler")
NotifyControler = require(packageName.."NotifyControler")
TimeControler = require(packageName.."TimeControler")
PlotDialogControl = require(packageName.."PlotDialogControl")
AnimDialogControl = require(packageName.."AnimDialogControl")
ServerErrorTipControler = require(packageName..'ServerErrorTipControler')
VersionControler = require(packageName.."VersionControler")
ClientActionControler = require(packageName.."ClientActionControler")
FriendViewControler = require(packageName.."FriendViewControler");
BattleLoadingControler = require(packageName.."BattleLoadingControler");
LineUpViewControler = require(packageName.."LineUpViewControler")
ChatShareControler = require(packageName.."ChatShareControler")
TowerControler = require(packageName.."TowerControler")
TextureControler = require(packageName.."TextureControler")
TextureControler:init()
NewLoadingControler = require(packageName.."NewLoadingControler")
GuildControler = require(packageName.."GuildControler")
ShareBossControler = require(packageName.."ShareBossControler")
WorldControler = require(packageName.."WorldControler")
EaseMapControler = require(packageName.."EaseMapControler")
RankAndcommentsControler = require(packageName.."RankAndcommentsControler")
EndlessControler = require(packageName.."EndlessControler")
GameFeedBackControler = require(packageName.."GameFeedBackControler")
BarrageControler = require(packageName.."BarrageControler")
BiographyControler = require(packageName.."BiographyControler")

QuestAndChatControler = require(packageName.."QuestAndChatControler")

if IS_EDITER then
	EditorControler = require(packageName.."EditorControler")
end
