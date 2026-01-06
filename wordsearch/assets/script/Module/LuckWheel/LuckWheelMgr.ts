// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { RewardType, TaskType, UserTag } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import { Tools } from "../../Common/Tools";
import ClientConfig, { ConfigKey, GoldWheelRewardConfig, LuckySpinConfig, RewardConfig } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { GameMgr } from "../Game/GameMgr";
import PopupSequenceConfig, { PopupSequenceType } from "../PopupSequence/PopupSequenceConfig";
import PopupSequenceMgr from "../PopupSequence/PopupSequenceMgr";
import RewardMgr from "../Reward/RewardMgr";
import TaskMgr from "../TaskModule/TaskMgr";
import UserDataMgr from "../UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;


export enum LuckWheelType {
    Money = 1,  // 普通转盘
    Golden = 2,  // 黄金转盘
}

// 转盘每个节点的奖励类型和值
export interface LuckWheelReward {
    type: RewardType;
    value: number;
}

// 转盘数据
export interface LuckWheelData {
    wheelID: number;
    luckyWheelReward: LuckWheelReward[];
    rewardIndex: number;
    lastLuckWheelReward: LuckWheelReward[];
    lastRewardIndex: number;
    progress: number;
    isClaimed: boolean;
}

@ccclass
export default class LuckWheelMgr {

    private static _instance: LuckWheelMgr;

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new LuckWheelMgr();
        return this._instance;
    }

    private KEY_LUCK_WHEEL_DATA = "luck_wheel_data";
    private KEY_GOLDEN_WHEEL_ROTATION_COUNT = "golden_wheel_rotation_count";

    private _luckyWheelConfig: Map<number, LuckySpinConfig> = new Map<number, LuckySpinConfig>();
    // 转盘数据
    private _luckWheelData: LuckWheelData = null;
    private _goldWheelData = null;

    // 黄金转盘的旋转次数
    private _goldenWheelRotationCount: number = 0;

    // 黄金转盘关闭次数
    private _goldenWheelCloseCount: number = 0;

    public init() {
        let luckyWheelConfig = ClientConfig.getConfig(ConfigKey.LuckyWheel);
        this._luckyWheelConfig = new Map<number, LuckySpinConfig>();
        for (let key in luckyWheelConfig) {
            this._luckyWheelConfig.set(parseInt(key), luckyWheelConfig[key]);
        }

        this._goldenWheelRotationCount = StorageManager.Instance.getNumber(this.KEY_GOLDEN_WHEEL_ROTATION_COUNT, 0);
        this._goldenWheelCloseCount = 0;

        this._luckWheelData = StorageManager.Instance.getJson(this.KEY_LUCK_WHEEL_DATA, null) as LuckWheelData;
        if (!this._luckWheelData) {
            this._luckWheelData = {
                wheelID: 1,
                luckyWheelReward: [],
                rewardIndex: -1,
                lastLuckWheelReward: [],
                lastRewardIndex: -1,
                progress: 0,
                isClaimed: false,
            } as LuckWheelData;
            this.updateCurrentLuckWheelReward();
        }
    }

    // 判断功能是否开启
    public isFunctionOpen() {
        if (UserDataMgr.Instance.isWhiteBao) {
            return false;
        }
        let targetCount = ClientConfig.globalConfig.LuckySpinBegin.Value;
        targetCount = parseInt(targetCount);
        let currentNumber = TaskMgr.Instance.getCompletedWordCount();
        return currentNumber >= targetCount;
    }

    // 初始化本次转盘的奖励值
    private updateCurrentLuckWheelReward() {
        Log.Debug("LuckWheelMgr updateCurrentLuckWheelReward -----------------------");
        let rewardCfg = RewardMgr.Instance.getRewardConfig();
        if (!rewardCfg) {
            return;
        }

        this._luckWheelData.isClaimed = false;
        this._luckWheelData.lastLuckWheelReward = this._luckWheelData.luckyWheelReward;
        this._luckWheelData.lastRewardIndex = this._luckWheelData.rewardIndex;

        // 普通转盘
        const normalSpin = this.buildSpinRewards(LuckWheelType.Money);
        this._luckWheelData.luckyWheelReward = normalSpin.rewards;
        this._luckWheelData.rewardIndex = normalSpin.rewardIndex;

        this.saveLuckWheelData();
    }

    // 上次转盘显示的奖励值列表
    public getLastLuckWheelShowRewardList() {
        return this._luckWheelData.lastLuckWheelReward;
    }

    // 上次转盘显示的奖励值索引
    public getLastLuckWheelRewardIndex() {
        return this._luckWheelData.lastRewardIndex;
    }

    // 获取本次转盘显示的奖励值列表
    public getCurrentLuckWheelShowRewardList() {
        return this._luckWheelData.luckyWheelReward;
    }

    public getCurrentLuckWheelRewardIndex() {
        return this._luckWheelData.rewardIndex;
    }

    public resetGoldenWheelData() {
        this._goldWheelData = this.buildSpinRewards(LuckWheelType.Golden);
    }

    public getCurrentGoldenLuckWheelShowRewardInfo() {
        return this._goldWheelData;
    }

    // 获取黄金转盘的旋转次数
    public getGoldenWheelRotationCount() {
        return this._goldenWheelRotationCount;
    }

    // 增加黄金转盘的旋转次数
    public addGoldenWheelRotationCount() {
        this._goldenWheelRotationCount++;
        StorageManager.Instance.set(this.KEY_GOLDEN_WHEEL_ROTATION_COUNT, this._goldenWheelRotationCount);
    }

    // 重置黄金转盘的旋转次数
    public resetGoldenWheelRotationCount() {
        this._goldenWheelRotationCount = 0;
        StorageManager.Instance.set(this.KEY_GOLDEN_WHEEL_ROTATION_COUNT, this._goldenWheelRotationCount);
    }

    // 增加黄金转盘关闭次数
    public addGoldenWheelCloseCount() {
        this._goldenWheelCloseCount++;
    }

    // 重置黄金转盘关闭次数
    public resetGoldenWheelCloseCount() {
        this._goldenWheelCloseCount = 0;
    }

    // 关闭黄金转盘 是否需要看插屏广告
    public isNeedShowInterstitialAd() {
        return this._goldenWheelCloseCount >= 2;
    }

    // 是否已领取普通转盘奖励
    public isClaimMoneyReward() {
        return this._luckWheelData.isClaimed;
    }

    public claimMoneyReward() {
        this._luckWheelData.isClaimed = true;
        this._luckWheelData.progress = 0;
        this.saveLuckWheelData();
    }

    private buildSpinRewards(luckyWheelType: LuckWheelType) {
        Log.Debug("LuckWheelMgr buildSpinRewards LuckWheelType = " + luckyWheelType);
        const result = {
            rewards: [] as LuckWheelReward[],
            rewardIndex: -1,
        };

        if (luckyWheelType == LuckWheelType.Money) {
            let rewardCfg = RewardMgr.Instance.getRewardConfig() as RewardConfig;
            for (let i = 0; i < 8; i++) {
                let key = `Wheel${i + 1}` as keyof RewardConfig;
                let data = rewardCfg[key] as string[];
                if (data) {
                    let rewardType = parseInt(data[0]);
                    let str = data[1];
                    let value = this.getRandomReward(str);
                    let reward = {
                        type: rewardType,
                        value: value,
                    };
                    result.rewards.push(reward);
                }
            }
            let wheelWeight = rewardCfg.WheelWeight;
            result.rewardIndex = Tools.getRandomByWeight(wheelWeight);

        } else if (luckyWheelType == LuckWheelType.Golden) {
            let watchedAdCount = UserDataMgr.Instance.watchedAdCount;
            let configKey = ConfigKey.GoldWheelReward;
            let rewardMap = ClientConfig.getConfig(configKey);
            let rewardConfig: GoldWheelRewardConfig = null;
            for (let key in rewardMap) {
                let item = rewardMap[key] as GoldWheelRewardConfig;
                if (watchedAdCount <= item.RewardAdsAmount) {
                    rewardConfig = item;
                    break;
                }
            }

            for (let i = 0; i < 8; i++) {
                let key = `Wheel${i + 1}` as keyof GoldWheelRewardConfig;
                let data = rewardConfig[key] as number[];
                if (data.length == 1) {
                    let rewardType = data[0];
                    let value = RewardMgr.Instance.getGoldWheelReward();
                    let reward = {
                        type: rewardType,
                        value: value,
                    };
                    result.rewards.push(reward);
                } else if (data.length == 2) {
                    let rewardType = data[0];
                    let value = data[1];
                    let reward = {
                        type: rewardType,
                        value: value,
                    };
                    result.rewards.push(reward);
                } else {
                    let rewardType = 1;
                    let value = 1;
                    let reward = {
                        type: rewardType,
                        value: value,
                    };
                    result.rewards.push(reward);

                    Log.Debug("LuckWheelMgr 配置出现异常，wheel1-8配置为1-2个数字，但是实际配置为：" + JSON.stringify(data));
                }
            }

            let wheelWeight = rewardConfig.RewardWeight;
            let rIndex = Tools.getRandomByWeight(wheelWeight);
            let currentCardNum = UserDataMgr.Instance.goldenCardNumber;
            let maxCardNum = parseInt(ClientConfig.globalConfig.GoldenCardAmount.Value);
            if (currentCardNum >= maxCardNum) {
                // 不再产出金卡，验证 rIndex 是否为金卡
                if (result.rewards[rIndex].type == RewardType.GoldenCard) {
                    // 是金卡，则重新随机
                    let times = 0;
                    while (result.rewards[rIndex].type == RewardType.GoldenCard && times < 10) {
                        times++;
                        rIndex = Tools.getRandomByWeight(wheelWeight);
                    }
                    if (times >= 10) {
                        rIndex = 2;
                    }
                }
            }

            result.rewardIndex = rIndex;
        }

        Log.Debug("LuckWheelMgr buildSpinRewards result", JSON.stringify(result));
        return result;
    }

    private getRandomReward(dataStr: string) {
        Log.Debug("LuckWheelMgr parseValueAndRate dataStr", dataStr);
        let list = dataStr.split(';').map(Number);
        return RewardMgr.Instance.getRandomReward(list);
    }

    // 领取奖励, 返回奖励类型和奖励值
    public getLuckWheelReward(type: LuckWheelType): { type: RewardType, value: number } {
        let reward = { type: RewardType.Money, value: 0 };
        if (type === LuckWheelType.Money) {
            let index = this.getCurrentLuckWheelRewardIndex();
            if (index >= 0) {
                reward.value = this._luckWheelData.luckyWheelReward[index].value;
                reward.type = this._luckWheelData.luckyWheelReward[index].type;
            }
        } else if (type === LuckWheelType.Golden) {
            let index = this._goldWheelData.rewardIndex;
            if (index >= 0) {
                reward.value = this._goldWheelData.rewards[index].value;
                reward.type = this._goldWheelData.rewards[index].type;
            }
        }
        return reward;
    }

    public getTargetCount() {
        let wheelConfig = this.getCurrentLuckWheelConfig();
        return wheelConfig.Amount;
    }

    public getProgress() {
        return this._luckWheelData.progress;
    }

    public addFinishLuckWheelTypeCount(type: number) {
        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (isWhiteBao) {
            return;
        }
        let currentKey = this.getCurrentLuckWheelConfig().GoalType;
        if (currentKey != type) {
            return;
        }

        this._luckWheelData.progress++;
        this.saveLuckWheelData();
        if (this._luckWheelData.progress > this.getTargetCount()) {
            return;
        }

        if (this._luckWheelData.progress == this.getTargetCount()) {
            const popupSequence = PopupSequenceConfig.Instance.getLuckWheelSequence();
            if (popupSequence && popupSequence.length > 0 && this._luckWheelData.wheelID != 1) {
                PopupSequenceMgr.Instance.showSequence(popupSequence);
            }
        }

        EventCenter.dispatchEvent(EventName.UpdateLuckWheelProgress, 1);
    }

    public isFinishLuckWheel() {
        return this._luckWheelData.progress >= this.getTargetCount();
    }

    public getCurrentLuckWheelConfig(): LuckySpinConfig {
        // 如果当前转盘ID大于配置数量，则返回最后一个配置
        if (this._luckWheelData.wheelID > this._luckyWheelConfig.size) {
            this._luckWheelData.wheelID = this._luckyWheelConfig.size;
        }
        return this._luckyWheelConfig.get(this._luckWheelData.wheelID);
    }

    // 进行下一轮
    public nextLuckWheel() {
        this._luckWheelData.wheelID += 1;
        if (this._luckWheelData.wheelID > this._luckyWheelConfig.size) {
            this._luckWheelData.wheelID = this._luckyWheelConfig.size;
        }
        this._luckWheelData.progress = 0;
        this._luckWheelData.isClaimed = false;
        this.updateCurrentLuckWheelReward();
        EventCenter.dispatchEvent(EventName.UpdateLuckWheelProgress, 0);
    }

    public getCurrentLuckWheelID() {
        return this._luckWheelData.wheelID;
    }

    private saveLuckWheelData() {
        StorageManager.Instance.set(this.KEY_LUCK_WHEEL_DATA, this._luckWheelData);
    }

    // 测试
    public test() {
        this.addFinishLuckWheelTypeCount(TaskType.WordFinish);
    }
}
