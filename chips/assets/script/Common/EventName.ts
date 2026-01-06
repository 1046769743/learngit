export enum EventName {
    ScreenClick = "ScreenClick",
    EnterGame = "EnterGame", // 进入游戏, cocos场景初始化成功
    EnterGameUI = "EnterGameUI", // 进入游戏UI

    // 道具
    UpdateTipNumber = "UpdateTipNumber",
    UseHitEvent = "UseHitEvent",
    // 提现
    ItemWithdrawSelect = "ItemWithdrawSelect",
    RefreshMoneyNumber = "RefreshMoneyNumber",
    RefreshMoneyShow = "RefreshMoneyShow",
    UpdateWheelProgress = "UpdateWheelProgress",
    CloseGameWinPopup = "CloseGameWinPopup",
    UpdateLuckWheelProgress = "UpdateLuckWheelProgress",

    // 广告
    onAdComplete = "onAdComplete",

    // 任务
    WithdrawTaskOpen = "WithdrawTaskOpen",

    // 过关
    LevelFinish = "LevelFinish",
    PopRewardClose = "PopRewardClose",

    // 弹窗序列管理
    PopupClose = "PopupClose", // 通用弹窗关闭事件（参数：popupName）

    // 轮盘
    WheelFinish = "WheelFinish",
    LuckWheelAdComplete = "LuckWheelAdComplete",

    // H5
    ShowH5ViewIcon = "ShowH5ViewIcon",

    // 引导转盘点击
    GuideLuckWheelClick = "GuideLuckWheelClick",

    // 黄金卡数量
    UpdateGoldenCardNumber = "UpdateGoldenCardNumber",

    // 引导
    GuideClickMask = "GuideClickMask",
    GuideClick = "GuideClick",
    GuideSwipeComplete = "GuideSwipeComplete",
    GuideEndEvent = "GuideEndEvent",
    GuideStep1Finished = "GuideStep1Finished",
    GuideStep2Finished = "GuideStep2Finished",
    GuideStep3Finished = "GuideStep3Finished",

    // 弹窗顶部
    ShowPopTop = "ShowPopTop",

    // 完成小猪任务
    CompletePigTask = "CompletePigTask",

    // 红点刷新
    DailyLoginRedDotRefresh = "DailyLoginRedDotRefresh",
    PigRedDotRefresh = "PigRedDotRefresh",



    //
    ShowDebugInfo = "ShowDebugInfo",
    GridMouseDown = "GridMouseDown",
    GridMouseUp = "GridMouseUp",
    GridSelect = "GridSelect",
    GridSelectEnd = "GridSelectEnd",
    ChessSelected = "ChessSelected",
    ChessDestroy = "ChessDestroy",
    GrideFake = "GrideFake",
    GrideReal = "GrideReal",
    UpdateFakeInfo = "UpdateFakeInfo",
    UpdateRealInfo = "UpdateFakeInfo",
    RefreshRedBubble = "RefreshRedBubble",// 刷新红包气泡

    PlayFakeAnimation = "PlayFakeAnimation",
    PlayRealAnimation = "PlayRealAnimation",
    RefreshSeoce = "RefreshSeoce",
    RefreshTaskInfo = "RefreshTaskInfo",
    RefreshCombo = "RefreshCombo",
    CreateFloatBox = "CreateFloatBox",
    RefreshTaskStatus = "RefreshTaskStatus",
    OnShowWithdrawGuide = "OnShowWithdrawGuide",
    ShowLotteryRemind = "ShowLotteryRemind",
    RefreshNewUserIcon = "RefreshNewUserIcon",
    RefreshFreeIngotStatus = "RefreshFreeIngotStatus",
    RefreshWechatWithdrawTips = "RefreshWechatWithdrawTips",
    RefreshInvitationStatus = "RefreshInvitationStatus",

    StartGame = "StartGame",
    RefreshScore = "RefreshScore",
    RefreshEndlessScore = "RefreshEndlessScore",
    BlockShapeTouchStart = "BlockShapeTouchStart",

    RefreshProgress = "RefreshProgress",
    GameOverRefesh = "GameOverRefesh",
    RefreshRedInfo = "RefreshRedInfo",//cocos刷新红包播放飞行动效事件
    UpdateRedInfo = "UpdateRedInfo",//安卓发起红包刷新(播放增量动画)

    UpdateCoinInfo = "UpdateRedInfo",//安卓发起钻石刷新(播放增量动画)
    RefreshCoinInfo = "RefreshRedInfo",//cocos刷新红包播放飞行动效事件
    PlayNpcAnimation = "PlayNpcAnimation",
    RefreshGuide = "RefreshGuide",
    ClickGuide = "ClickGuide", // 点击引导

    GuideDeal = "GuideDeal",
    GuideMerge = "GuideMerge",
    GuidShuff = "GuidShuff",

    AutoMerge = "AutoMerge", //自动合成

    NewUserWelfareReceivedEvent = "ShowRewardProgressEvent", //展示奖励进度条
    RemoveChipEvent = "RemoveChipEvent", //移除筹码
    AutoUnlockSlotEvent = "AutoUnlockSlotEvent", //自动解锁槽位

}

