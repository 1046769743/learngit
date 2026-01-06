// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { CollectEffectType, CollectMultipleEffect, EffectManager } from "../../Common/EffectManager";
import { RewardType } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import { Tools } from "../../Common/Tools";
import ClientConfig, { ConfigKey, DailyLoginConfig } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { GameMgr } from "../Game/GameMgr";
import UserDataMgr from "../UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;

export enum DailyLoginRewardState {
    Normal = 0,      // 正常显示状态（未到可领取时间）
    CanClaim = 1,   // 奖励可领取，但未领取状态
    Claimed = 2,    // 已领取状态
}

export interface DailyLoginData {
    index: number;  // 当前可领取的最大天数（1-7），如果index=5，说明可以领取Day1-5的奖励
    isClaim: boolean; // 当前天数是否已领取（保留用于兼容，实际使用claimedDays）
    claimedDays: number[]; // 已领取的奖励天数列表，如[1,2,3]表示已领取Day1、Day2、Day3
    lastLoginTime: number; // 上次登录时间
    lastPopupTime: number; // 上次弹出界面的时间（用于判断是否首次登录）
    goldenCardCount: number; // 金卡数量
}

export interface DailyLoginRewardItem {
    rewardType: RewardType;
    rewardAmount: number;
}

export interface DailyLoginRewardInfo {
    rewards: DailyLoginRewardItem[]; // 奖励列表（支持多个奖励，如Day7）
    shouldShowAd: boolean; // 是否需要显示广告（Day3、Day7）
}

@ccclass
export default class DailyLoginMgr {
    private static _instance: DailyLoginMgr = null;

    public static get Instance(): DailyLoginMgr {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new DailyLoginMgr();
        return this._instance;
    }

    public readonly TAG: string = "DailyLoginMgr";

    private readonly KEY_DAILY_LOGIN_DATA: string = "daily_login_data";
    private readonly KEY_DAILY_LOGIN_REWAED_CFG: string = "daily_login_reward_cfg";

    private _isInitOk: boolean = false;
    private _isFunctionOpen: boolean = false;
    private _dailyLoginData: DailyLoginData = null;
    private _dailyLoginConfig: Map<number, DailyLoginConfig> = new Map<number, DailyLoginConfig>();
    private _dailyLoginRewardCfg: any = null;

    public init() {
        Log.Debug(this.TAG + " init");
        this._dailyLoginData = StorageManager.Instance.getJson(this.KEY_DAILY_LOGIN_DATA, null) as DailyLoginData;
        if (!this._dailyLoginData || this._dailyLoginData === null) {
            this._dailyLoginData = {
                index: 1,
                isClaim: false,
                claimedDays: [],
                lastLoginTime: 0,
                lastPopupTime: 0,
                goldenCardCount: 0,
            };
        }

        if (this._dailyLoginData.lastLoginTime === 0) {
            this._dailyLoginData.lastLoginTime = Date.now();
        }

        let cfg = ClientConfig.getConfig(ConfigKey.DailyLogin);
        for (let key in cfg) {
            this._dailyLoginConfig.set(parseInt(key), cfg[key] as DailyLoginConfig);
        }

        this._dailyLoginRewardCfg = StorageManager.Instance.getJson(this.KEY_DAILY_LOGIN_REWAED_CFG, null) as any;
        if (!this._dailyLoginRewardCfg) {
            this.resetDailyLoginRewardCfg();
        }
        // 初始化时检查跨天逻辑
        this.checkAndUpdateDailyLogin();

        this._isInitOk = true;
    }

    public isInitOk(): boolean {
        return this._isInitOk;
    }

    private duration: number = 0;
    public update(deltaTime: number) {
        if (!this._isInitOk || !this._isFunctionOpen || !this._dailyLoginData) {
            return;
        }
        // 每秒运行一次
        this.duration += deltaTime;
        if (this.duration >= 1) {
            this.duration = 0;
            // this.checkAndUpdateDailyLogin();
        }
    }

    private resetDailyLoginRewardCfg() {
        this._dailyLoginRewardCfg = {};
        for (let i = 1; i <= 7; i++) {
            this._dailyLoginRewardCfg[i] = this.getRewardInfo(i);
        }
        StorageManager.Instance.set(this.KEY_DAILY_LOGIN_REWAED_CFG, this._dailyLoginRewardCfg);
    }

    // 功能是否已开启
    public isFunctionOpen(): boolean {
        let currentLevel = GameMgr.Instance.GetCurProgress();
        let openLevel = ClientConfig.globalConfig.DailyLoginBegin.Value;
        openLevel = parseInt(openLevel);
        if (currentLevel < openLevel) {
            this._isFunctionOpen = false;
            return false;
        } else {
            this._isFunctionOpen = true;
        }
        return true;
    }

    // 计算两个时间戳之间的天数差
    private getDaysDifference(lastTime: number, currentTime: number): number {
        if (lastTime === 0) {
            return 0; // 首次登录，不跨天
        }

        const lastDate = new Date(lastTime);
        const currentDate = new Date(currentTime);

        // 将时间设置为当天的0点0分0秒，只比较日期
        lastDate.setHours(0, 0, 0, 0);
        currentDate.setHours(0, 0, 0, 0);

        // 计算天数差（毫秒转天数）
        const diffTime = currentDate.getTime() - lastDate.getTime();
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

        return Math.max(0, diffDays); // 确保返回非负数
    }

    // 检查并更新每日登录数据
    private checkAndUpdateDailyLogin() {
        // Log.Debug(this.TAG + " checkAndUpdateDailyLogin");
        let currentTime = Date.now();
        if (!this._dailyLoginData || this._dailyLoginData === null) {
            return;
        }

        let lastLoginTime = this._dailyLoginData.lastLoginTime;
        // 计算跨了多少天
        const daysDiff = this.getDaysDifference(lastLoginTime, currentTime);
        if (daysDiff > 0) {
            Log.Debug(this.TAG + " checkAndUpdateDailyLogin 跨天数 = " + daysDiff);
            // 如果所有奖励都已领取完，重置到第1天
            if (this.isAllRewardsClaimed()) {
                Log.Debug(this.TAG + " checkAndUpdateDailyLogin 所有奖励全部领取，重置到第1天");
                this._dailyLoginData.index = 1;
                this._dailyLoginData.isClaim = false;
                this._dailyLoginData.claimedDays = [];
                this.resetDailyLoginRewardCfg();
            } else {
                // 根据跨天数更新index
                // 如果跨了N天，新的index = min(原index + N, 7)
                // 特殊情况：如果跨了超过7天，index直接设为7，所有奖励都可以领取
                if (daysDiff >= 7) {
                    Log.Debug(this.TAG + " checkAndUpdateDailyLogin 跨了7天或以上，index设为7");
                    this._dailyLoginData.index = 7;
                } else {
                    // 计算新的index，但不能超过7
                    const newIndex = Math.min(this._dailyLoginData.index + daysDiff, 7);
                    Log.Debug(this.TAG + " checkAndUpdateDailyLogin 原index = " + this._dailyLoginData.index + " 新index = " + newIndex);
                    this._dailyLoginData.index = newIndex;
                }
                // 重置isClaim，因为新的一天可能还没领取
                this._dailyLoginData.isClaim = false;
            }

            this._dailyLoginData.lastLoginTime = currentTime;
            StorageManager.Instance.set(this.KEY_DAILY_LOGIN_DATA, this._dailyLoginData);
            EventCenter.dispatchEvent(EventName.DailyLoginRedDotRefresh);
            Log.Debug(this.TAG + " checkAndUpdateDailyLogin 更新数据 = " + JSON.stringify(this._dailyLoginData));
        }
    }

    // 判断是否所有奖励都已领取
    private isAllRewardsClaimed(): boolean {
        // 如果已领取的天数包含1-7，说明所有奖励都已领取
        return this._dailyLoginData.claimedDays.length === 7 &&
            this._dailyLoginData.claimedDays.every((day, index) => day === index + 1);
    }

    // 获取数据
    public getDailyLoginData(): DailyLoginData {
        return this._dailyLoginData;
    }

    // 领取奖励，返回奖励信息和是否需要显示广告
    public getRewardInfo(index: number): DailyLoginRewardInfo | null {
        let config = this._dailyLoginConfig.get(index);
        if (!config) {
            Log.Error("DailyLoginMgr claimReward: 配置不存在，index = " + index);
            return null;
        }

        // 获取所有奖励信息（支持多个奖励，如Day7）
        let rewards: DailyLoginRewardItem[] = [];

        let rewardAmount: number[] = config.RewardAmount;
        let maxGoldCardCount = parseInt(ClientConfig.globalConfig.GoldenCardAmount.Value);
        let totalGoldCardCount = UserDataMgr.Instance.goldenCardNumber;
        let dailyLoginCardLimit = parseInt(ClientConfig.globalConfig.DailyLoginCardLimit.Value);
        if (totalGoldCardCount >= maxGoldCardCount || this._dailyLoginData.goldenCardCount >= dailyLoginCardLimit) {
            rewardAmount = config.RewardAmountCardLimit;
        }
        Log.Debug(this.TAG + " getRewardInfo 用户当前总的金卡数量 totalGoldCardCount = " + totalGoldCardCount);
        Log.Debug(this.TAG + " getRewardInfo 金卡总数量限制 maxGoldCardCount = " + maxGoldCardCount);
        Log.Debug(this.TAG + " getRewardInfo 用户当前每日登录领取的金卡数量 this._dailyLoginData.goldenCardCount = " + this._dailyLoginData.goldenCardCount);
        Log.Debug(this.TAG + " getRewardInfo 每日登录领取的金卡数量限制 dailyLoginCardLimit = " + dailyLoginCardLimit);
        Log.Debug(this.TAG + " getRewardInfo rewardAmount = " + JSON.stringify(rewardAmount));

        if (config.RewardType && config.RewardType.length > 0 && rewardAmount && rewardAmount.length > 0) {
            let maxLength = Math.min(config.RewardType.length, rewardAmount.length);
            for (let i = 0; i < maxLength; i++) {
                let type = config.RewardType[i];
                let amount = rewardAmount[i];
                rewards.push({
                    rewardType: type as RewardType,
                    rewardAmount: amount,
                });
            }
        }
        Log.Debug(this.TAG + " getRewardInfo  index = " + index + " rewards = " + JSON.stringify(rewards));

        // Day3、Day7奖励领取完后，必定起广告
        let shouldShowAd = (index === 3 || index === 7);
        return {
            rewards: rewards,
            shouldShowAd: shouldShowAd,
        };
    }

    public getDailyLoginRewardInfo(index: number): DailyLoginRewardInfo {
        return this._dailyLoginRewardCfg[index];
    }

    // 领取奖励
    public claimReward(index: number) {
        let rewardInfo = this.getDailyLoginRewardInfo(index);
        if (!rewardInfo) {
            Log.Error("DailyLoginMgr claimReward: 奖励信息不存在，index = " + index);
            return null;
        }

        // 检查是否已领取
        if (this._dailyLoginData.claimedDays.indexOf(index) !== -1) {
            Log.Error("DailyLoginMgr claimReward: 奖励已领取，index = " + index);
            return null;
        }

        // 检查是否可以领取（必须在index范围内）
        if (index > this._dailyLoginData.index) {
            Log.Error("DailyLoginMgr claimReward: 奖励还未解锁，index = " + index + " 当前最大index = " + this._dailyLoginData.index);
            return null;
        }

        // 标记为已领取
        if (this._dailyLoginData.claimedDays.indexOf(index) === -1) {
            this._dailyLoginData.claimedDays.push(index);
            this._dailyLoginData.claimedDays.sort((a, b) => a - b); // 排序
        }

        // 如果领取的是当前index的奖励，更新isClaim
        if (index === this._dailyLoginData.index) {
            this._dailyLoginData.isClaim = true;
        }

        let isNeedOffX = false;
        if (rewardInfo.rewards.length == 2) {
            isNeedOffX = true;
        }

        for (let i = 0; i < rewardInfo.rewards.length; i++) {
            let reward = rewardInfo.rewards[i];
            if (reward.rewardType == RewardType.Money) {
                UserDataMgr.Instance.addMoneyNumber(reward.rewardAmount, false);
            } else if (reward.rewardType == RewardType.GoldenCard) {
                UserDataMgr.Instance.addGoldenCardNumber(reward.rewardAmount, false);
                this._dailyLoginData.goldenCardCount += reward.rewardAmount;
            }
        }

        StorageManager.Instance.set(this.KEY_DAILY_LOGIN_DATA, this._dailyLoginData);

        EventCenter.dispatchEvent(EventName.DailyLoginRedDotRefresh);

        Log.Debug(this.TAG + " claimReward 领取奖励完成，index = " + index + " 奖励信息 = " + JSON.stringify(rewardInfo));
        Log.Debug(this.TAG + " claimReward 领取奖励完成，更新数据 = " + JSON.stringify(this._dailyLoginData));
        return rewardInfo;
    }

    // 获取奖励列表 展示用
    public getDailyLoginConfig(): Map<number, DailyLoginConfig> {
        return this._dailyLoginConfig;
    }

    // 获取指定日期的奖励状态
    public getRewardState(date: number): DailyLoginRewardState {
        if (date < 1 || date > 7) {
            return DailyLoginRewardState.Normal;
        }

        // 检查是否已领取
        if (this._dailyLoginData.claimedDays.indexOf(date) !== -1) {
            return DailyLoginRewardState.Claimed;
        }

        // 如果指定日期小于等于当前index，说明可以领取
        if (date <= this._dailyLoginData.index) {
            return DailyLoginRewardState.CanClaim;
        }

        // 如果指定日期大于当前index，说明还没到
        return DailyLoginRewardState.Normal;
    }

    // 是否可领取当前奖励（检查是否有任何未领取的奖励）
    public canClaimReward(): boolean {
        // 检查是否有任何在index范围内的奖励未领取
        for (let i = 1; i <= this._dailyLoginData.index && i <= 7; i++) {
            if (this._dailyLoginData.claimedDays.indexOf(i) === -1) {
                return true;
            }
        }
        return false;
    }

    // 是否有未领取的奖励（用于红点提示）
    public hasUnclaimedReward(): boolean {
        if (!this.isFunctionOpen()) {
            return false;
        }
        return this.canClaimReward();
    }

    // 是否应该弹出界面（每天首次登录）
    public shouldShowPopupOnFirstLogin(): boolean {
        if (!this.isFunctionOpen()) {
            return false;
        }

        let currentTime = Date.now();
        let lastPopupTime = this._dailyLoginData.lastPopupTime;

        // 判断是否跨天
        if (Tools.isCrossDay(lastPopupTime, currentTime)) {
            // 更新弹出时间
            this._dailyLoginData.lastPopupTime = currentTime;
            StorageManager.Instance.set(this.KEY_DAILY_LOGIN_DATA, this._dailyLoginData);
            return true;
        }

        return false;
    }

    // 标记已弹出界面（在界面打开时调用）
    public markPopupShown() {
        let currentTime = Date.now();
        this._dailyLoginData.lastPopupTime = currentTime;
        StorageManager.Instance.set(this.KEY_DAILY_LOGIN_DATA, this._dailyLoginData);
    }

    // 获取当前登录天数
    public getCurrentDay(): number {
        return this._dailyLoginData.index;
    }
}
