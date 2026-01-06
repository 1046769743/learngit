
export enum WordSearchGameState {
    Playing = 0,        // 游戏中
    Paused = 1,         // 暂停
    Completed = 2,      // 完成
    Failed = 3,         // 失败
}

export enum RewardType {
    None = 0,
    Money = 1,
    Bulb = 2,
    GoldenCard = 3,
}

export enum TaskType {
    NotStarted = 0,
    ActiveDay = 1, // 今日活跃
    WordFinish = 2, // 单词完成
    AdFinish = 3, // 广告完成
    WheelFinish = 4, // 轮盘完成
    LevelFinish = 5, // 关卡完成
    AllTypeAd = 6, // 所有类型广告
    BoxAd = 7, // 宝箱广告
}

// 用户标签
export enum UserTag {
    User100 = 100, // 用户标签：没有提现或首次提现仍在7天冷却时间内的用户
    User101 = 101, // 用户标签：首次提现7天冷却时间已过的用户
}






