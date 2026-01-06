// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { RewardType } from "../../Common/EnumDefine";
import ItemReward from "./ItemReward";

const { ccclass, property } = cc._decorator;

@ccclass
export default class RewardsContent extends cc.Component {

    @property(ItemReward)
    itemRewards: ItemReward[] = [];

    public updateUI(rewardInfos: { type: RewardType, value: number }[]) {

        for (let i = 0; i < this.itemRewards.length; i++) {
            this.itemRewards[i].node.active = false;
        }

        let len = Math.min(rewardInfos.length, this.itemRewards.length);
        // 根据屏幕宽度和len 计算初始x 和 间隔（使用本地坐标）
        let screenWidth = 700;
        let interval = screenWidth / len;
        let startX = -screenWidth / 2 + interval / 2;

        for (let i = 0; i < rewardInfos.length; i++) {
            let rewardInfo = rewardInfos[i];
            this.itemRewards[i].node.active = true;
            this.itemRewards[i].node.position = cc.v3(startX + i * interval, 0, 0);
            this.itemRewards[i].updateUI(rewardInfo.type, rewardInfo.value);
        }
    }

    public getRewardStartPos(rewardType: RewardType): cc.Vec2 {
        for (let i = 0; i < this.itemRewards.length; i++) {
            let itemReward = this.itemRewards[i];
            if (itemReward.rewardType == rewardType) {
                return itemReward.getIconWorldPos();
            }
        }
        return cc.v2(0, 0);
    }
}
