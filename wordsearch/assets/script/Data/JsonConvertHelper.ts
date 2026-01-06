interface GameStatusData {
    language: string; //语言
    country: string; //国家
    moneyCount: number; //金币
    exchangeRate: number; //兑换率
}

interface LevelGameData {
    levelId: number;
    difficulty: number;
    gridSize: { rows: number, cols: number };
    words: string[];
    grid: string[][];
    gameState: number;
    foundWords: string[];
}

interface SysGuide {
    id: string;//引导id
    type: number;//引导类型
    step: number;//引导步骤
    is_save: boolean;//是否保存
    tips: string;//提示
    sound: string;//音效
    auto_next: boolean;//是否自动下一步
}

