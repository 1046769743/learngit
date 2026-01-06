// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { RewardType } from "../../Common/EnumDefine";
import ResourceManager from "../../FrameWork/ResourceManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemReward extends cc.Component {

    @property(cc.Sprite)
    spriteReward: cc.Sprite = null;

    @property(cc.Label)
    labelReward: cc.Label = null;

    public rewardType: RewardType = RewardType.None;
    public rewardValue: number = 0;

    updateUI(rewardType: RewardType, rewardValue: number) {
        this.rewardType = rewardType;
        this.rewardValue = rewardValue;
        let iconPath = "";
        if (rewardType == RewardType.Money) {
            iconPath = CurrencyManager.instance.getMoreMoneyIcon();
            this.labelReward.string = CurrencyManager.instance.formatMoney(rewardValue, true);
            this.spriteReward.node.scale = 0.65;
        } else if (rewardType == RewardType.GoldenCard) {
            iconPath = "Atlas/Common/golden_card";
            this.labelReward.string = rewardValue.toString();
            this.spriteReward.node.scale = 1;
        }

        ResourceManager.loadRes(iconPath, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
            if (frame && cc.isValid(this.spriteReward)) {
                this.spriteReward.spriteFrame = frame;
            }
        });
    }

    getIconWorldPos(): cc.Vec2 {
        let worldPos = this.spriteReward.node.parent.convertToWorldSpaceAR(this.spriteReward.node.position);
        return cc.v2(worldPos.x, worldPos.y);
    }
}
