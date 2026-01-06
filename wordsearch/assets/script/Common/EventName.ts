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
    onInterstitialAdComplete = "onInterstitialAdComplete",

    // 任务
    WithdrawTaskOpen = "WithdrawTaskOpen",

    // 完成单词
    UpdateCompletedWordCount = "UpdateCompletedWordCount",

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
    GuideGoldenLuckWheelClick = "GuideGoldenLuckWheelClick",
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

    // 功能开启
    CashOutPopupOpened = "CashOutPopupOpened",
}

