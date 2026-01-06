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
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import { NativeApi } from "../../Platform/Android/NativeApi";
import PopReward from "../../View/Pop/PopReward";
import PopRewardClaim from "../../View/Pop/PopRewardClaim";
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
    DoubleReward = 0, // 关卡结算 双倍奖励
    ClaimReward = 1, // 关卡结算 单倍奖励
    SlotDoubleReward = 2,
    SlotClaimReward = 3,
    FlyBox = 4, // 飞行宝箱
    FlyBoxClaim = 5, // 飞行宝箱界面关闭时强弹广告
    BulbReward = 6,
    LuckWheel = 7, // 黄金转盘
    LuckWheelClaim = 8, // 关闭黄金转盘界面
    DailyLogin = 9, // 每日签到 
    DailyLoginClaim = 10,
    PigReward = 11, // 小猪奖励
    PigRewardClaim = 12, // 小猪奖励界面关闭时强弹广告

    DailyLogin3 = 14, // 每日签到 3天
    DailyLogin7 = 15, // 每日签到 7天
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

    // 当前看广告的功能模块
    private _currentAdModule: ModuleType = ModuleType.None;

    public getCurrentAdModule(): ModuleType {
        return this._currentAdModule;
    }

    public showAd(moduleType: ModuleType, adType: AdType) {
        Log.Debug("AdMgr showAd: " + moduleType);
        this._currentAdModule = moduleType;
        NativeApi.instance.showVideo(adType);
    }

    public onAdComplete(isSuccess: boolean) {
        Log.Debug("AdMgr onAdComplete: " + isSuccess);
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

            TaskMgr.Instance.addTaskFinishCount(TaskType.AdFinish);
            PigMgr.Instance.addTaskProgress(TaskType.AllTypeAd);
        }

        EventCenter.dispatchEvent(EventName.onAdComplete, isSuccess, this._currentAdModule);
        this._currentAdModule = ModuleType.None;
    }
}
