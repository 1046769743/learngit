// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { RewardType, UserTag } from "../../Common/EnumDefine";
import { Tools } from "../../Common/Tools";
import ClientConfig, { ConfigKey, RewardConfig } from "../../Data/ClientConfig";
import { Log } from "../../FrameWork/Log";
import UserDataMgr from "../UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;

export enum WheelRewardType {
    Dollar = 1,
    Bulb = 2,
    Seven77 = 3,
}

@ccclass
export default class RewardMgr {

    private static _instance: RewardMgr;

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new RewardMgr();
        return this._instance;
    }

    private readonly TAG: string = "RewardMgr";

    public init() {
    }

    // 获取结算奖励
    public getLevelFinishRewardConfig() {
        let rewardCfg = this.getRewardConfig();
        if (!rewardCfg) {
            return 0;
        }
        let rewardList = rewardCfg.LevelFinishReward;
        if (!rewardList || rewardList.length == 0) {
            return 0;
        }
        return this.getRandomReward(rewardList);
    }

    // 获取单词奖励
    public getWordFinishRewardConfig() {
        return 0;
    }

    // 获取飞行宝箱奖励
    public getFlyBoxRewardConfig() {
        let rewardCfg = this.getRewardConfig();
        if (!rewardCfg) {
            return 0;
        }
        let rewardList = rewardCfg.WordChestReward;
        if (!rewardList) {
            return 0;
        }
        return this.getRandomReward(rewardList);

    }

    // 获取猪猪奖励
    public getPigRewardConfig(isForceGoldenCard: boolean): { type: RewardType, value: number }[] {
        Log.Debug(this.TAG + " getPigRewardConfig isForceGoldenCard: " + isForceGoldenCard);
        let rewardCfg = this.getRewardConfig();
        if (!rewardCfg) {
            return [{ type: RewardType.None, value: 0 }];
        }
        let rewardList = rewardCfg.PigReward;
        return this.getRandomRewardTypeAndValue(rewardList, isForceGoldenCard);
    }

    // 获取随机奖励的类型和数值
    public getRandomRewardTypeAndValue(rewardList: string[], isForceGoldenCard: boolean): { type: RewardType, value: number }[] {
        Log.Debug(this.TAG + " getRandomRewardTypeAndValue isForceGoldenCard: " + isForceGoldenCard + " rewardList: " + JSON.stringify(rewardList));
        let len = rewardList.length;
        if (len == 0) {
            return [];
        }

        let maxGoldCardCount = parseInt(ClientConfig.globalConfig.GoldenCardAmount.Value);
        let totalGoldCardCount = UserDataMgr.Instance.goldenCardNumber;
        Log.Debug(this.TAG + " getRandomRewardTypeAndValue maxGoldCardCount: " + maxGoldCardCount + " totalGoldCardCount: " + totalGoldCardCount);
        if (len == 1 || totalGoldCardCount >= maxGoldCardCount) {
            let rewardString = rewardList[0];
            let list = rewardString.split(';').map(Number);
            if (!list || list.length == 0) {
                return [];
            }
            let value = this.getRandomReward(list);
            if (value > 0) {
                return [{ type: RewardType.Money, value: value }];
            }
            return [];
        }

        let reward: { type: RewardType, value: number }[] = [];
        if (len == 2) {
            // 处理第一个奖励（金钱）
            let rewardString0 = rewardList[0];
            let list0 = rewardString0.split(';').map(Number);
            if (list0 && list0.length >= 1) {
                let value = this.getRandomReward(list0);
                if (value > 0) {
                    reward.push({ type: RewardType.Money, value: value });
                }
            }

            // 处理第二个奖励（可能是黄金卡）
            let rewardString1 = rewardList[1];
            let list1 = rewardString1.split(';').map(Number);
            if (list1 && list1.length == 2) {
                let rate = list1[0];
                let random = Math.random() * 100;
                Log.Debug(this.TAG + " getRandomRewardTypeAndValue random: " + random + " rate: " + rate + " isForceGoldenCard: " + isForceGoldenCard);
                if (random <= rate || !isForceGoldenCard) {
                    // 概率命中，添加黄金卡奖励
                    if (list1[1] > 0) {
                        reward.push({ type: RewardType.GoldenCard, value: list1[1] });
                    }
                }
                Log.Debug(this.TAG + " getRandomRewardTypeAndValue reward: " + JSON.stringify(reward));
            }
        } else {
            // len > 2 的情况，只处理第一个奖励
            Log.Warning(this.TAG + " getRandomRewardTypeAndValue len > 2 出现这种情况 查表的配置，有问题！！！");
            let rewardString = rewardList[0];
            let list = rewardString.split(';').map(Number);
            if (list && list.length >= 1) {
                let value = this.getRandomReward(list);
                if (value > 0) {
                    reward.push({ type: RewardType.Money, value: value });
                }
            }
        }
        Log.Debug(this.TAG + " getRandomRewardTypeAndValue reward: " + JSON.stringify(reward));
        return reward;
    }

    // 获取黄金转盘奖励
    public getGoldWheelReward() {
        let rewardCfg = this.getRewardConfig();
        if (!rewardCfg) {
            return 0;
        }
        let rewardList = rewardCfg.GoldSpinReward;
        return this.getRandomReward(rewardList);
    }

    // 获取随机奖励
    public getRandomReward(rewardList: number[]) {
        let len = rewardList.length;
        if (len == 1) {
            return rewardList[0];
        }
        if (len !== 3) {
            return 0.01;
        }
        let min = rewardList[0];
        let max = rewardList[1];
        Log.Debug('zq getRandomReward min = ' + min + ' max = ' + max + ' rewardList[2] = ' + rewardList[2]);
        // 第三个是保留的小数位数
        let random = Math.random() * (max - min) + min;
        random = Tools.toFixed(random, rewardList[2], true);
        Log.Debug('zq getRandomReward random = ' + random);
        return random;
    }

    // 根据当前用户金额数，获取对应的奖励配置
    public getRewardConfig(): RewardConfig {
        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (isWhiteBao) {
            return null;
        }

        let userMoney = UserDataMgr.Instance.totalMoneyNumber;
        let userTag = UserDataMgr.Instance.userTag;
        let configKey = ConfigKey.Reward100;
        let rewardMap = ClientConfig.getConfig(configKey);

        for (let key in rewardMap) {
            let rewardConfig = rewardMap[key];
            if (userMoney < rewardConfig.UserDollar) {
                return rewardConfig;
            }
        }
        return null;
    }
}
