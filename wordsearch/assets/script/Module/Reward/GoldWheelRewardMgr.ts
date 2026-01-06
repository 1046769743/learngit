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

@ccclass
export default class GoldWheelRewardMgr {

    private static _instance: GoldWheelRewardMgr;

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new GoldWheelRewardMgr();
        return this._instance;
    }

    private readonly TAG: string = "RewardMgr";

    public init() {
    }


    // 根据当前用户金额数，获取对应的奖励配置
    public getRewardConfig(): RewardConfig {
        let watchedAdCount = UserDataMgr.Instance.watchedAdCount;
        let configKey = ConfigKey.GoldWheelReward;
        let rewardMap = ClientConfig.getConfig(configKey);

        for (let key in rewardMap) {
            let rewardConfig = rewardMap[key];
            if (watchedAdCount < rewardConfig.WatchedAdCount) {
                return rewardConfig;
            }
        }
        return null;
    }
}
