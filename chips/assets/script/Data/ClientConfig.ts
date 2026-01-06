// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { Log } from "../FrameWork/Log";

const { ccclass, property } = cc._decorator;

export class ConfigKey {
    static Currency: string = "currency";
    static GlobalConfig: string = "config";
    static Language: string = "language";
    static Level: string = "level";
    static marquee: string = "marquee";
    static Reward100: string = "reward100";
    static Reward101: string = "reward101";
    static LuckyWheel: string = "luckywheel";
    static Quest: string = "quest";
    static DailyQuest: string = "dailyquest";
    static DailyLogin: string = "dailylogin";


    private static _configList: Map<string, string> = new Map<string, string>([
        [ConfigKey.GlobalConfig, "config/config"],
        [ConfigKey.Language, "config/language"],
        [ConfigKey.Level, "config/level"],
        [ConfigKey.marquee, "config/marquee"],
        [ConfigKey.Reward100, "config/rewad_100"],
        [ConfigKey.Reward101, "config/rewad_101"],
        [ConfigKey.Currency, "config/currency"],
        [ConfigKey.LuckyWheel, "config/luckyspin"],
        [ConfigKey.Quest, "config/quest"],
        [ConfigKey.DailyQuest, "config/dailyquest"],
        [ConfigKey.DailyLogin, "config/dailylogin"],
    ]);

    static getPath(name: string): string {
        return this._configList.get(name);
    }

    static getConfigList(): string[] {
        return Array.from(this._configList.values());
    }
}

/**
 * 客户端本地配置表的数据
 * 
 */
@ccclass
export default class ClientConfig {
    private static configMap = new Map<string, any>();

    static globalConfig: GlobalConfig = null;
    static isInitOk = false;

    static init() {
        Log.Debug("ClientConfig 初始化 start time = " + new Date().getTime());
        let startTime = new Date().getTime();
        let configList = ConfigKey.getConfigList();
        Log.Debug("ClientConfig 初始化配置列表: " + JSON.stringify(configList));
        for (let i = 0; i < configList.length; i++) {
            let key = configList[i];
            cc.resources.load(key, (err, asset) => {
                if (err) {
                    Log.Error("ClientConfig 加载配置失败: " + key + " " + err);
                }

                this.configMap.set(key, asset.json);
                Log.Debug("ClientConfig 初始化完成: " + key);
                if (this.configMap.size == configList.length) {
                    this.globalConfig = this.getConfig(ConfigKey.GlobalConfig);
                    this.isInitOk = true;
                    Log.Debug("ClientConfig 初始化完成 end time = " + new Date().getTime() + " cost time = " + (new Date().getTime() - startTime));
                    Log.Debug("ClientConfig 初始化完成 config.length: " + this.configMap.size);
                }
            });
        }
    }

    static getConfig(key: string) {
        let path = ConfigKey.getPath(key);
        if (!this.configMap.has(path)) {
            Log.Error("ClientConfig 配置未加载: " + path);
            return null;
        }
        return this.configMap.get(path);
    }

    // 获取配置值
    static getConfigValue(fileKey: string, key: string): string {
        let config = this.getConfig(fileKey);
        if (!config) {
            return null;
        }

        if (!config[key]) {
            Log.Error("ClientConfig 配置未加载: " + fileKey + " " + key);
            return null;
        }

        if (!config[key].Value) {
            Log.Error("ClientConfig 配置未加载: " + fileKey + " " + key);
            return null;
        }

        return config[key].Value;
    }
}

export interface GlobalConfig {
    InitMoneyCount: any;
    InitBulbCount: any;
    BulbShowLevel: any;
    RotateShowLevel: any;
    User100: any;
    User101: any;
    LuckySpinBegin: any;
    LuckySpin_100: any;
    GoldSpin_100: any;
    LuckySpin_101: any;
    GoldSpin_101: any;
    GoldSpinCardMin: any;
    PiggyQuestBegin: any;
    PiggyQuestCardMin: any;
    DailyLoginBegin: any;
    DailyLoginCardLimit: any;
    GoldenCardAmount: any;
    WithdrawList: any;
    WithdrawListCondition: any;
    WithdrawGoldenCard: any;
    PrivacyPolicy: any;
    TermsOfUse: any;
}

export interface LevelConfig {
    Level: number;
    Xaxis: number;
    Yaxis: number;
    Goal: string[];
    WordGroup: string[][];
    IsRewardedADShow: number;
    ADRewardClaim: number;
}

export interface RewardConfig {
    ID: number;
    UserDollar: number;
    PigReward: string[];
    LevelFinishReward: string;
    ADRewardBet: number;
    RewardShowBet: number;
    LuckySpinReward: string[];
    GoldenSpinReward: string[];
    WordChestReward: string;
    ADBulbAmount: number;
    H5Reward: number[];
    RedScratchReward: number[];
}

export interface WheelConfig {
    WheelID: number;
    Amount: number;
    GoalType: number;
    IsRewardedADShow: number;
    ADRewardClaim: number;
    ADRewardAmount: number;
}

export interface TaskConfig {
    ID: number;
    TaskLanguageID: string;
    TaskType: number;
    TaskGoal: number;
    TipLanguageID: string;
}


export interface LuckySpinConfig {
    WheelID: number;
    GoalType: number;
    Amount: number;
    IsGoldedWheel: number;
}

export interface QuestConfig {
    QuestID: number;
    QuestType: number;
    Goal: number;
    QuestLanguageid: string;
    HammerAmount: number;
}

export interface DailyQuestConfig {
    ID: number;
    UserDollar: number;
    QuestID: number[];
}

export interface DailyLoginConfig {
    Date: number;
    RewardType: number[];
    RewardAmount: number[];
    RewardAmountCardLimit: number[];
}