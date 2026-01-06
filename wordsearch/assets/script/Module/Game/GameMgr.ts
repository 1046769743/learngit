import { TaskType } from "../../Common/EnumDefine";
import ClientConfig, { ConfigKey, LevelConfig } from "../../Data/ClientConfig";
import { Log } from "../../FrameWork/Log";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { NativeApi } from "../../Platform/Android/NativeApi";
import GameUI from "../../View/Game/GameUI";
import LuckWheelMgr from "../LuckWheel/LuckWheelMgr";
import PigMgr from "../Pig/PigMgr";
import RewardMgr from "../Reward/RewardMgr";
import TaskMgr from "../TaskModule/TaskMgr";
import UserDataMgr from "../UserData/UserDataMgr";
import WheelMgr from "../Wheel/WheelMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export class GameMgr {
    public static readonly TAG: string = "GameMgr"

    // 创建单例
    private static _instance: GameMgr;
    static get Instance() {
        if (this._instance) {
            return this._instance;
        }

        this._instance = new GameMgr();
        return this._instance;
    }

    public isInitOk = false;

    // Word Search 游戏数据
    private _wordSearchConfig: LevelConfig[] = [];
    private _currentLevelConfig: LevelConfig = null;
    private _currentLevelData: LevelGameData = null;
    private _gameUI: GameUI = null; // GameUI 引用

    InitData(data: GameStatusData) {
        Log.Debug(GameMgr.TAG + " GameMgr InitData");

        // 初始化Word Search游戏
        this.initWordSearchGame();
        this.saveGameData(this._currentLevelData);
    }

    public getGameUI(): GameUI {
        return this._gameUI;
    }

    /**
     * 初始化Word Search游戏
     */
    private initWordSearchGame() {
        Log.Debug(GameMgr.TAG + " 初始化Word Search游戏");
        this._wordSearchConfig = ClientConfig.getConfig(ConfigKey.Level);
        Log.Debug(GameMgr.TAG + " 初始化Word Search游戏配置: " + JSON.stringify(this._wordSearchConfig));
        // 初始化Word Search游戏
        this._currentLevelData = StorageManager.Instance.getJson("wordSearchGameData") as LevelGameData;
        if (!this._currentLevelData) {
            // 如果本地没有游戏数据，则创建第一关游戏数据
            this._currentLevelData = this.createGameDataFromConfig(this._wordSearchConfig[0], 1);
        } else {
            // 确保从本地存储加载的数据结构正确
            this.validateAndFixGameData();
        }

        this.isInitOk = true;
        this._currentLevelConfig = this.getWordSearchLevelById(this._currentLevelData.levelId);
    }

    /**
     * 验证和修复游戏数据
     */
    private validateAndFixGameData() {
        if (!this._currentLevelData) return;

        // 确保 foundWords 是数组
        if (!Array.isArray(this._currentLevelData.foundWords)) {
            this._currentLevelData.foundWords = [];
            Log.Debug(GameMgr.TAG + " 修复 foundWords 数据类型");
        }

        // 确保其他必要字段存在
        if (!this._currentLevelData.words) {
            this._currentLevelData.words = [];
        }
        if (!this._currentLevelData.grid) {
            this._currentLevelData.grid = [];
        }
        if (typeof this._currentLevelData.levelId !== 'number') {
            this._currentLevelData.levelId = 1;
        }

        if (typeof this._currentLevelData.gameState !== 'number') {
            this._currentLevelData.gameState = 0;
        }

        // 保存修复后的数据
        this.saveGameData(this._currentLevelData);
    }

    /**
     * 获取所有关卡配置
     */
    public getWordSearchLevels(): any[] {
        if (!this.isInitOk) {
            Log.Warning(GameMgr.TAG + " Word Search配置未加载");
            return [];
        }
        return this._wordSearchConfig;
    }

    /**
     * 获取当前level
     */
    public getCurrentLevel(): any {
        return this._currentLevelData.levelId;
    }

    /**
     * 根据关卡ID获取关卡配置
     */
    public getWordSearchLevelById(levelId: number): LevelConfig {
        if (!this.isInitOk) {
            Log.Warning(GameMgr.TAG + " Word Search配置未加载");
            return null;
        }

        // 判断当前关卡id 是否 越界
        // 在完成所有关卡后，重复之前的关卡，重复关卡的起点总是83关
        if (levelId > this._wordSearchConfig.length) {
            const totalLevels = this._wordSearchConfig.length;
            const startRepeatLevel = 82; // 重复关卡的起点

            // 计算超出部分
            const overflow = levelId - totalLevels;

            // 重复关卡的范围是83到totalLevels，共(totalLevels - 81)个关卡
            const repeatRange = totalLevels - startRepeatLevel + 1;

            // 计算在重复范围内的偏移（从0开始）
            const offset = (overflow - 1) % repeatRange;

            // 映射到82到totalLevels的范围
            levelId = startRepeatLevel + offset;

            Log.Debug(GameMgr.TAG + " 关卡ID越界，重新计算关卡ID: " + levelId);
        }

        return this._wordSearchConfig[levelId - 1];
    }

    /**
     * 开始Word Search关卡
     */
    public startWordSearchLevel(levelId: number, isFoce: boolean = false): boolean {
        Log.Debug(GameMgr.TAG + " 开始Word Search关卡: " + levelId);

        const levelConfig = this.getWordSearchLevelById(levelId);
        if (!levelConfig) {
            Log.Error(GameMgr.TAG + " 无法开始关卡，配置不存在: " + levelId);
            return false;
        }

        this._currentLevelConfig = levelConfig;

        if (this._currentLevelData.levelId != levelId || isFoce) {
            Log.Debug(GameMgr.TAG + " 创建新的关卡数据: " + levelId);
            this._currentLevelData = this.createGameDataFromConfig(levelConfig, levelId);
            this.saveGameData(this._currentLevelData);
        }

        Log.Debug(GameMgr.TAG + " 关卡 " + levelId + "开始，网格大小: " + levelConfig.Xaxis + "x" + levelConfig.Yaxis);

        return true;
    }

    /**
     * 从配置创建游戏数据
     */
    private createGameDataFromConfig(config: LevelConfig, levelId: number): LevelGameData {

        let cfgGrid = config.WordGroup;
        Log.Debug(GameMgr.TAG + " 创建游戏数据，配置grid: " + JSON.stringify(cfgGrid));
        //  现在的grid是以左上为原点，需要转换为以左下为原点
        // let newGrid = [];
        // for (let i = 0; i < cfgGrid.length; i++) {
        //     newGrid[i] = [];
        //     for (let j = 0; j < cfgGrid[i].length; j++) {
        //         // 将行索引从左上角原点转换为左下角原点
        //         let newRowIndex = cfgGrid.length - 1 - i;
        //         newGrid[i][j] = cfgGrid[newRowIndex][j];
        //     }
        // }

        // Log.Debug(GameMgr.TAG + " 创建游戏数据，转换后的grid: " + JSON.stringify(newGrid));

        const gameData = {
            levelId: levelId,
            difficulty: 0,
            gridSize: { rows: config.Xaxis, cols: config.Yaxis },  // 修正：Yaxis是行数，Xaxis是列数
            words: config.Goal,
            grid: cfgGrid,
            gameState: 0, // 0:Playing
            foundWords: []
        } as LevelGameData;

        let esData = {
            leveiid: levelId,
            Amonut: UserDataMgr.Instance.moneyNumber,
            BulbAmount: UserDataMgr.Instance.tipNumber,
            WordCardAmount: UserDataMgr.Instance.goldenCardNumber,
        }
        NativeApi.instance.buryPoint("LevelNow", JSON.stringify(esData));

        return gameData;
    }

    /**
     * 获取当前游戏数据
     */
    public getCurrentWordSearchGameData(): LevelGameData {
        return this._currentLevelData;
    }

    /**
     * 获取当前关卡配置
     */
    public getCurrentWordSearchLevelConfig(): LevelConfig {
        return this._currentLevelConfig;
    }

    /**
     * 设置 GameUI 引用
     */
    public setGameUI(gameUI: any): void {
        this._gameUI = gameUI;
        Log.Debug(GameMgr.TAG + " 设置 GameUI 引用");
    }

    /**
     * 开始下一关
     */
    public startNextLevel(): void {
        if (!this._currentLevelData) {
            Log.Error(GameMgr.TAG + " 没有当前游戏数据");
            return;
        }

        const currentLevelId = this._currentLevelData.levelId;
        const nextLevelId = currentLevelId + 1;
        NativeApi.instance.passLevel(currentLevelId);
        Log.Debug(GameMgr.TAG + " 开始下一关: " + nextLevelId);

        TaskMgr.Instance.addTaskFinishCount(TaskType.LevelFinish);
        PigMgr.Instance.addTaskProgress(TaskType.LevelFinish);
        WheelMgr.Instance.addFinishWheelTypeCount(TaskType.LevelFinish);

        // 清除当前关卡数据
        StorageManager.Instance.remove(`wordSearchLevel_${currentLevelId}`);
        Log.Debug(GameMgr.TAG + " 已清除关卡数据: " + currentLevelId);

        // 通知 GameUI 开始下一关
        if (this._gameUI) {
            this._gameUI.startLevel(nextLevelId);
        }
    }

    /**
     * 完成一个单词
     */
    public onFoundWord(word: string): boolean {
        if (this._currentLevelData.foundWords.indexOf(word) !== -1) {
            return false;
        }
        this._currentLevelData.foundWords.push(word);
        this.saveGameData(this._currentLevelData);
        TaskMgr.Instance.addTaskFinishCount(TaskType.WordFinish);
        PigMgr.Instance.addTaskProgress(TaskType.WordFinish);
        WheelMgr.Instance.addFinishWheelTypeCount(TaskType.WordFinish);
        LuckWheelMgr.Instance.addFinishLuckWheelTypeCount(TaskType.WordFinish);

        return true;
    }

    /** 判断是否完成所有单词 */
    public isAllWordsFound(): boolean {
        return this._currentLevelData.foundWords.length >= this._currentLevelData.words.length;
    }

    public addWordFinishReward(): number {
        if (!this.isAllWordsFound()) {
            let reward = RewardMgr.Instance.getWordFinishRewardConfig();
            UserDataMgr.Instance.addMoneyNumber(reward);
            return reward;
        }
        return 0;
    }

    /**
     *  未完成的单词
     */
    public getUnfinishedWords(): string[] {
        let unfinishedWords = [];
        for (let i = 0; i < this._currentLevelData.words.length; i++) {
            let word = this._currentLevelData.words[i];
            if (this._currentLevelData.foundWords.indexOf(word) === -1) {
                unfinishedWords.push(word);
            }
        }
        return unfinishedWords;
    }

    // 保存游戏数据
    public saveGameData(gameData: any) {
        this._currentLevelData = gameData;
        // 保存到本地
        StorageManager.Instance.set("wordSearchGameData", gameData);
    }

    // 测试用 开始指定关卡
    public startTestLevel(levelId: number) {
        this.startWordSearchLevel(levelId, true);


        let currentLevelId = levelId;

        // 清除当前关卡数据
        StorageManager.Instance.remove(`wordSearchGameData`);

        // 通知 GameUI 开始下一关
        if (this._gameUI) {
            this._gameUI.startLevel(currentLevelId);
        }
    }
}

