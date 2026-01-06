// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { RewardType, TaskType } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { NativeApi } from "../../Platform/Android/NativeApi";
import FlyBoxMgr from "../FlyBox/FlyBoxMgr";
import PigMgr from "../Pig/PigMgr";
import RewardMgr, { WheelRewardType } from "../Reward/RewardMgr";
import TaskMgr from "../TaskModule/TaskMgr";
import UserDataMgr from "../UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;

export enum ModuleType {
    None = -1, // 没有模块
    LevelFinish = 0,
    PropsHit = 1,
    PropsRotation = 2,
    CommonReward = 3,
    FlyBox = 4,
    LuckWheel = 5,
    DailyLogin = 6,
    GoldenWheelClose = 7,
    PigReward = 8,
}

export enum AdType {
    None = -1,
    // 激励视频 0 开头
    DoubleReward = 0, // 关卡结算 双倍奖励  激励视频
    SlotDoubleReward = 1,  // 激励视频
    FlyBox = 2, // 飞行宝箱   激励视频
    LuckWheel = 3, // 黄金转盘 激励视频
    DailyLogin = 4, // 每日签到 激励视频
    PigReward = 5, // 小猪奖励 激励视频

    // 激励视频 可以有admob 100 开头
    BulbReward = 100, // 激励视频 

    // 插屏广告 200 开头
    ClaimReward = 201, // 关卡结算 单倍奖励   插屏广告
    SlotClaimReward = 202,  // 插屏广告
    FlyBoxClaim = 203, // 飞行宝箱界面关闭时强弹广告  插屏广告
    LuckWheelClaim = 204, // 关闭黄金转盘界面 插屏广告
    DailyLoginClaim = 205, // 每日签到 插屏广告
    PigRewardClaim = 206, // 小猪奖励界面关闭时强弹广告 插屏广告
    DailyLogin3 = 207, // 每日签到 3天 插屏广告
    DailyLogin7 = 208, // 每日签到 7天 插屏广告
    GameWinCollect = 209, // 游戏结算点collect 插屏广告
}

@ccclass
export default class AdMgr {
    private static _instance: AdMgr;

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new AdMgr();
        return this._instance;
    }

    // 激励视频广告类型列表
    public readonly VideoAdTypeList: AdType[] = [
        AdType.DoubleReward,
        AdType.LuckWheel,
        AdType.FlyBox,
        AdType.BulbReward,
        AdType.SlotDoubleReward,
        AdType.DailyLogin,
        AdType.PigReward,
    ]
    // 插屏广告类型列表
    public readonly InterstitialAdTypeList: AdType[] = [
        AdType.ClaimReward,
        AdType.SlotClaimReward,
        AdType.FlyBoxClaim,
        AdType.LuckWheelClaim,
        AdType.DailyLoginClaim,
        AdType.PigRewardClaim,
        AdType.DailyLogin3,
        AdType.DailyLogin7,
        AdType.GameWinCollect,
    ];

    // 当前看广告的功能模块
    private _currentAdModule: ModuleType = ModuleType.None;
    // 当前看插屏广告的功能模块
    private _currentInterstitialAdModule: ModuleType = ModuleType.None;
    // 当前看广告的类型
    private _currentAdType: AdType = AdType.None;
    // 当前看插屏广告的类型
    private _currentInterstitialAdType: AdType = AdType.None;

    public getCurrentAdModule(): ModuleType {
        return this._currentAdModule;
    }

    public getCurrentAdType(): AdType {
        return this._currentAdType;
    }

    public getCurrentInterstitialAdType(): AdType {
        return this._currentInterstitialAdType;
    }

    public getCurrentInterstitialAdModule(): ModuleType {
        return this._currentInterstitialAdModule;
    }

    public showAd(moduleType: ModuleType, adType: AdType) {
        Log.Debug("AdMgr showAd: " + moduleType);
        this._currentAdModule = moduleType;
        this._currentAdType = adType;
        NativeApi.instance.showVideo(adType);
    }

    public showInterstitialAd(moduleType: ModuleType, adType: AdType) {
        Log.Debug("AdMgr showInterstitialAd: " + moduleType);
        this._currentInterstitialAdModule = moduleType;
        this._currentInterstitialAdType = adType;
        NativeApi.instance.showVideo(adType);
    }

    private onInterstitialAdComplete(isSuccess: boolean, adType: AdType) {
        Log.Debug("AdMgr onInterstitialAdComplete: " + isSuccess);
        if (this._currentInterstitialAdType == AdType.None || this._currentInterstitialAdType != adType) {
            return;
        }
        this._currentInterstitialAdModule = ModuleType.None;
        this._currentInterstitialAdType = AdType.None;
        EventCenter.dispatchEvent(EventName.onInterstitialAdComplete, isSuccess, this._currentInterstitialAdModule);
    }

    private onVideoAdComplete(isSuccess: boolean, adType: AdType) {
        if (this._currentAdType == AdType.None || this._currentAdType != adType) {
            return;
        }
        Log.Debug("AdMgr onVideoAdComplete: " + isSuccess);
        if (isSuccess) {
            switch (this._currentAdModule) {
                case ModuleType.LevelFinish:
                    break;
                case ModuleType.PropsHit:
                    // 第二版需求， 看完广告，直接帮用户用掉
                    UserDataMgr.Instance.addTipNumber(1, false);
                    EventCenter.dispatchEvent(EventName.UseHitEvent);
                    break;
                case ModuleType.PropsRotation:
                    break;
                case ModuleType.FlyBox:
                    let reward = RewardMgr.Instance.getFlyBoxRewardConfig();
                    UserDataMgr.Instance.addMoneyNumber(reward, true);
                    FlyBoxMgr.Instance.resetRejectCount();

                    PigMgr.Instance.addTaskProgress(TaskType.BoxAd);
                    break;
                case ModuleType.LuckWheel:
                    break;
            }

            switch (this._currentAdType) {
                case AdType.DoubleReward:
                case AdType.LuckWheel:
                case AdType.FlyBox:
                    UserDataMgr.Instance.addWatchedAdCount();
                    break;
            }

            TaskMgr.Instance.addTaskFinishCount(TaskType.AdFinish);
            PigMgr.Instance.addTaskProgress(TaskType.AllTypeAd);
        }

        EventCenter.dispatchEvent(EventName.onAdComplete, isSuccess, this._currentAdModule);
        this._currentAdModule = ModuleType.None;
    }

    public onAdComplete(isSuccess: boolean, adType: AdType) {
        Log.Debug("AdMgr onAdComplete: " + isSuccess);

        this.onInterstitialAdComplete(isSuccess, adType);
        this.onVideoAdComplete(isSuccess, adType);

    }
}
