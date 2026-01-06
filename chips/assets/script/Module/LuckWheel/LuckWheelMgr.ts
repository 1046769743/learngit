// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { RewardType, UserTag } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import ClientConfig, { ConfigKey, LuckySpinConfig } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { GameMgr } from "../Game/GameMgr";
import RewardMgr from "../Reward/RewardMgr";
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

    private KEY_LUCK_WHEEL_ID = "luck_wheel_id";
    private KEY_CURRENT_LUCK_WHEEL_REWARD = "current_luck_wheel_reward";
    private KEY_GOLDEN_WHEEL_CLOSE_COUNT = "golden_wheel_close_count";
    private KEY_GOLDEN_WHEEL_MISS_COUNT = "golden_wheel_miss_count";


    private _luckyWheelConfig: Map<number, LuckySpinConfig> = new Map<number, LuckySpinConfig>();

    private _currentLuckWheelID: number = 0;
    private _currentFinishWheelTypeCount: number = 0;
    // 本次转盘的奖励值 显示用
    private _currentLuckWheelShowReward: LuckWheelReward[] = [];
    // 普通转盘的金币奖励概率 0-100
    private _currentGoldRewardRate: number = 0;
    // 黄金转盘的金币奖励概率 0-100
    private _currentGoldenGoldRewardRate: number = 0;
    // 本次转盘的奖励索引
    private _currentLuckWheelRewardIndex: number = -1;
    // 黄金转盘的奖励索引
    private _currentGoldenWheelRewardIndex: number = -1;
    // 黄金转盘展示奖励
    private _currentGoldenLuckWheelShowReward: LuckWheelReward[] = [];
    // 本次转盘的奖励是否已领取
    private _isClaimed: boolean = false;
    // 黄金转盘连续关闭的次数
    private _goldenWheelCloseCount: number = 0;
    // 黄金转盘连续几次没有命中金卡
    private _goldenWheelMissCount: number = 0;

    public init() {
        let luckyWheelConfig = ClientConfig.getConfig(ConfigKey.LuckyWheel);
        this._luckyWheelConfig = new Map<number, LuckySpinConfig>();
        for (let key in luckyWheelConfig) {
            this._luckyWheelConfig.set(parseInt(key), luckyWheelConfig[key]);
        }

        this._currentLuckWheelID = StorageManager.Instance.getNumber(this.KEY_LUCK_WHEEL_ID, 1);
        this._currentFinishWheelTypeCount = StorageManager.Instance.getNumber(this.getKeyFinishWheelTypeCount(), 0);
        this._goldenWheelCloseCount = StorageManager.Instance.getNumber(this.KEY_GOLDEN_WHEEL_CLOSE_COUNT, 0);
        this._goldenWheelMissCount = StorageManager.Instance.getNumber(this.KEY_GOLDEN_WHEEL_MISS_COUNT, 0);

        let currentLuckWheelReward = StorageManager.Instance.getJson(this.KEY_CURRENT_LUCK_WHEEL_REWARD);
        if (currentLuckWheelReward && currentLuckWheelReward.rewardIndex >= 0 && currentLuckWheelReward.goldenRewardIndex >= 0 && currentLuckWheelReward.luckyWheelReward.length > 0 && currentLuckWheelReward.goldenWheelReward.length > 0) {
            this._currentLuckWheelShowReward = currentLuckWheelReward.luckyWheelReward;
            this._currentGoldRewardRate = currentLuckWheelReward.goldRewardRate;
            this._isClaimed = currentLuckWheelReward.isClaimed;
            this._currentGoldenLuckWheelShowReward = currentLuckWheelReward.goldenWheelReward;
            this._currentGoldenGoldRewardRate = currentLuckWheelReward.goldenGoldRewardRate;
            this._currentGoldenWheelRewardIndex = currentLuckWheelReward.goldenRewardIndex;
            this._currentLuckWheelRewardIndex = currentLuckWheelReward.rewardIndex;
        } else {
            this.updateCurrentLuckWheelReward();
        }
    }

    // 判断功能是否开启
    public isFunctionOpen() {
        if (UserDataMgr.Instance.isWhiteBao) {
            return false;
        }
        let openLevel = ClientConfig.globalConfig.LuckySpinBegin.Value;
        openLevel = parseInt(openLevel);
        let currentLevel = GameMgr.Instance.GetCurProgress();
        return currentLevel >= openLevel;
    }

    // 初始化本次转盘的奖励值
    private updateCurrentLuckWheelReward() {
        Log.Debug("LuckWheelMgr updateCurrentLuckWheelReward -----------------------");
        let rewardCfg = RewardMgr.Instance.getRewardConfig();
        if (!rewardCfg) {
            return;
        }

        this._isClaimed = false;

        // 提现时间限制结束
        let configKey = "LuckySpin_100";
        let goldenConfigKey = "GoldSpin_100";
        if (UserDataMgr.Instance.userTag == UserTag.User101) {
            configKey = "LuckySpin_101";
            goldenConfigKey = "GoldSpin_101";
        }

        // 普通转盘
        const normalSpin = this.buildSpinRewards(LuckWheelType.Money, rewardCfg.LuckySpinReward, configKey);
        this._currentLuckWheelShowReward = normalSpin.rewards;
        this._currentGoldRewardRate = normalSpin.goldRate;
        this._currentLuckWheelRewardIndex = normalSpin.rewardIndex;

        // 黄金转盘
        const goldenSpin = this.buildSpinRewards(LuckWheelType.Golden, rewardCfg.GoldenSpinReward, goldenConfigKey);
        this._currentGoldenLuckWheelShowReward = goldenSpin.rewards;
        this._currentGoldenGoldRewardRate = goldenSpin.goldRate;
        this._currentGoldenWheelRewardIndex = goldenSpin.rewardIndex;

        let data = {
            goldRewardRate: this._currentGoldRewardRate,
            luckyWheelReward: this._currentLuckWheelShowReward,
            rewardIndex: this._currentLuckWheelRewardIndex,
            goldenGoldRewardRate: this._currentGoldenGoldRewardRate,
            goldenWheelReward: this._currentGoldenLuckWheelShowReward,
            goldenRewardIndex: this._currentGoldenWheelRewardIndex,
            isClaimed: this._isClaimed,
        }

        Log.Debug("LuckWheelMgr updateCurrentLuckWheelReward", JSON.stringify(data));

        StorageManager.Instance.set(this.KEY_CURRENT_LUCK_WHEEL_REWARD, JSON.stringify(data));
    }

    // 获取本次转盘显示的奖励值列表
    public getCurrentLuckWheelShowRewardList() {
        return this._currentLuckWheelShowReward;
    }

    public getCurrentLuckWheelRewardIndex() {
        return this._currentLuckWheelRewardIndex;
    }

    public getCurrentGoldenLuckWheelShowRewardList() {
        return this._currentGoldenLuckWheelShowReward;
    }

    public getCurrentGoldenLuckWheelRewardIndex() {
        return this._currentGoldenWheelRewardIndex;
    }

    public resetGoldenWheelMissCount() {
        this._goldenWheelMissCount = 0;
        StorageManager.Instance.set(this.KEY_GOLDEN_WHEEL_MISS_COUNT, this._goldenWheelMissCount);
    }

    public addGoldenWheelMissCount() {
        this._goldenWheelMissCount++;
        StorageManager.Instance.set(this.KEY_GOLDEN_WHEEL_MISS_COUNT, this._goldenWheelMissCount);
    }

    // 是否已领取普通转盘奖励
    public isClaimMoneyReward() {
        return this._isClaimed;
    }

    public claimMoneyReward() {
        this._isClaimed = true;
        this.saveCurrentLuckWheelReward();
    }

    // 获取本次奖励的索引
    private getRandomLuckWheelRewardIndex(luckyWheelType: LuckWheelType, rewardList: LuckWheelReward[], goldRewardRate: number) {
        if (!rewardList || rewardList.length === 0) {
            return -1;
        }

        let forceGoldCard = false;
        if (UserDataMgr.Instance.userTag == UserTag.User101 && luckyWheelType == LuckWheelType.Golden) {

            let maxGoldCardCount = parseInt(ClientConfig.globalConfig.GoldenCardAmount.Value);
            let totalGoldCardCount = UserDataMgr.Instance.goldenCardNumber;
            if (totalGoldCardCount < maxGoldCardCount) {
                let missGoldCardCountCfg = ClientConfig.globalConfig.GoldSpinCardMin;
                if (this._goldenWheelMissCount >= parseInt(missGoldCardCountCfg.Value)) {
                    forceGoldCard = true;
                }
            }
        }

        if (forceGoldCard) {
            for (let i = 0; i < rewardList.length; i++) {
                if (rewardList[i].type == RewardType.GoldenCard) {
                    return i;
                }
            }
        }

        const randomPercent = Math.floor(Math.random() * 100);
        const targetType = randomPercent < goldRewardRate ? RewardType.GoldenCard : RewardType.Money;
        Log.Debug("PopLuckWheel targetType", targetType, randomPercent, goldRewardRate);
        // 根据目标类型筛选奖励
        const candidates = rewardList
            .map((reward, index) => ({ reward, index }))
            .filter(item => item.reward.type === targetType);

        if (candidates.length === 0) {
            return -1;
        }

        const selected = candidates[Math.floor(Math.random() * candidates.length)];
        return selected.index;
    }

    private buildSpinRewards(luckyWheelType: LuckWheelType, spinReward: string[], typeConfigKey: string) {
        const result = {
            rewards: [] as LuckWheelReward[],
            goldRate: 0,
            rewardIndex: -1,
        };

        if (!spinReward || spinReward.length == 0) {
            return result;
        }

        const moneyRewardNumList = this.parseMoneyRewardList(spinReward[0]);
        let goldRewardValue = 0, goldRewardRate = 0;
        if (spinReward.length == 2) {
            goldRewardValue = this.parseValueAndRate(spinReward[1]).value;
            goldRewardRate = this.parseValueAndRate(spinReward[1]).rate;
        }

        const typeConfigStr = ClientConfig.getConfigValue(ConfigKey.GlobalConfig, typeConfigKey)

        if (!typeConfigStr) {
            return result;
        }

        const rewardTypeList = typeConfigStr.split(";");
        const rewards: LuckWheelReward[] = [];
        for (let i = 0; i < rewardTypeList.length; i++) {
            const typeStr = rewardTypeList[i];
            if (!typeStr) {
                continue;
            }
            let rewardType = parseInt(typeStr) as RewardType;
            let value = 0;
            if (rewardType === RewardType.Money) {
                value = RewardMgr.Instance.getRandomReward(moneyRewardNumList);
            } else if (rewardType === RewardType.GoldenCard) {
                value = goldRewardValue;
            }
            rewards.push({
                type: rewardType,
                value,
            });
            if (rewards.length >= 8) {
                break;
            }
        }

        result.rewards = rewards;
        result.goldRate = goldRewardRate;
        result.rewardIndex = this.getRandomLuckWheelRewardIndex(luckyWheelType, rewards, goldRewardRate);
        return result;
    }

    private parseMoneyRewardList(moneyRewardStr: string) {
        if (!moneyRewardStr) {
            return [];
        }
        const list = moneyRewardStr.split(";");
        const numberList: number[] = [];
        for (let i = 0; i < list.length; i++) {
            const num = parseFloat(list[i]);
            if (!isNaN(num)) {
                numberList.push(num);
            }
        }
        return numberList;
    }

    private parseValueAndRate(dataStr: string) {
        Log.Debug("LuckWheelMgr parseValueAndRate dataStr", dataStr);
        const result = { value: 0, rate: 0 };
        if (!dataStr) {
            return result;
        }
        const delimiter = dataStr.includes(":") ? ":" : ";";
        const parts = dataStr.split(delimiter);
        if (parts.length > 0) {
            const value = parseFloat(parts[1]);
            result.value = isNaN(value) ? 0 : value;
        }
        if (parts.length > 1) {
            const rate = parseFloat(parts[0]);
            result.rate = isNaN(rate) ? 0 : rate;
        }
        Log.Debug("LuckWheelMgr parseValueAndRate result", result);
        return result;
    }

    // 领取奖励, 返回奖励类型和奖励值
    public getLuckWheelReward(type: LuckWheelType): { type: RewardType, value: number } {
        let reward = { type: RewardType.Money, value: 0 };
        if (type === LuckWheelType.Money) {
            let index = this.getCurrentLuckWheelRewardIndex();
            if (index >= 0) {
                reward.value = this._currentLuckWheelShowReward[index].value;
                reward.type = this.getRewardType(this._currentLuckWheelShowReward[index].type);
            }
            this.saveCurrentLuckWheelReward();
        } else if (type === LuckWheelType.Golden) {
            let index = this.getCurrentGoldenLuckWheelRewardIndex();
            if (index >= 0) {
                reward.value = this._currentGoldenLuckWheelShowReward[index].value;
                reward.type = this.getRewardType(this._currentGoldenLuckWheelShowReward[index].type);
            }
        }
        return reward;
    }

    private getRewardType(type: RewardType): RewardType {
        if (type === RewardType.Money) {
            return RewardType.Money;
        } else if (type === RewardType.GoldenCard) {
            return RewardType.GoldenCard;
        }
        return RewardType.Money;
    }

    public getTargetWordCount() {
        let wheelConfig = this.getCurrentLuckWheelConfig();
        return wheelConfig.Amount;
    }

    public getCurrentFinishWordCount() {
        return this._currentFinishWheelTypeCount;
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

        this._currentFinishWheelTypeCount++;

        if (this._currentFinishWheelTypeCount > this.getTargetWordCount()) {
            return;
        }

        StorageManager.Instance.set(this.getKeyFinishWheelTypeCount(), this._currentFinishWheelTypeCount);
        EventCenter.dispatchEvent(EventName.UpdateLuckWheelProgress, 1);
    }

    public isFinishLuckWheel() {
        return this._currentFinishWheelTypeCount >= this.getTargetWordCount();
    }

    public getCurrentLuckWheelConfig(): LuckySpinConfig {
        // 如果当前转盘ID大于配置数量，则返回最后一个配置
        if (this._currentLuckWheelID > this._luckyWheelConfig.size) {
            this._currentLuckWheelID = this._luckyWheelConfig.size;
        }
        return this._luckyWheelConfig.get(this._currentLuckWheelID);
    }

    // 是否需要展示黄金转盘
    public isShowGoldWheel() {
        let config = this.getCurrentLuckWheelConfig();
        return config.IsGoldedWheel == 1;
    }

    public addGoldenWheelCloseCount() {
        this._goldenWheelCloseCount++;
        StorageManager.Instance.set(this.KEY_GOLDEN_WHEEL_CLOSE_COUNT, this._goldenWheelCloseCount);
    }

    public getGoldenWheelCloseCount() {
        return this._goldenWheelCloseCount;
    }

    public resetGoldenWheelCloseCount() {
        this._goldenWheelCloseCount = 0;
        StorageManager.Instance.set(this.KEY_GOLDEN_WHEEL_CLOSE_COUNT, this._goldenWheelCloseCount);
    }

    // 黄金转盘点关闭是否展示广告
    public isShowGoldenWheelAd() {
        return this._goldenWheelCloseCount >= 2;
    }

    // 进行下一轮
    public nextLuckWheel() {
        this._currentLuckWheelID++;
        if (this._currentLuckWheelID > this._luckyWheelConfig.size) {
            this._currentLuckWheelID = this._luckyWheelConfig.size;
        }
        StorageManager.Instance.set(this.KEY_LUCK_WHEEL_ID, this._currentLuckWheelID);
        this._currentFinishWheelTypeCount = 0;
        StorageManager.Instance.set(this.getKeyFinishWheelTypeCount(), this._currentFinishWheelTypeCount);
        EventCenter.dispatchEvent(EventName.UpdateLuckWheelProgress, 0);
        this.updateCurrentLuckWheelReward();
    }

    public getCurrentLuckWheelID() {
        return this._currentLuckWheelID;
    }

    private getKeyFinishWheelTypeCount() {
        return `finish_luck_wheel_type_count_${this.getCurrentLuckWheelConfig().GoalType}`;
    }

    private saveCurrentLuckWheelReward() {
        let data = {
            goldRewardRate: this._currentGoldRewardRate,
            luckyWheelReward: this._currentLuckWheelShowReward,
            rewardIndex: this._currentLuckWheelRewardIndex,
            goldenGoldRewardRate: this._currentGoldenGoldRewardRate,
            goldenWheelReward: this._currentGoldenLuckWheelShowReward,
            goldenRewardIndex: this._currentGoldenWheelRewardIndex,
            isClaimed: this._isClaimed,
        }
        StorageManager.Instance.set(this.KEY_CURRENT_LUCK_WHEEL_REWARD, JSON.stringify(data));
    }

    // 测试
    public test() {
        this._currentFinishWheelTypeCount = this.getTargetWordCount() - 1;
        this.addFinishLuckWheelTypeCount(1);
    }

}
