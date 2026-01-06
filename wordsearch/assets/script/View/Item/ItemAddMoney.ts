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
export default class ItemAddMoney extends cc.Component {

    @property(cc.Sprite)
    iconMoney: cc.Sprite = null;

    @property(cc.Label)
    label: cc.Label = null;

    updateShow(str: string, rewardType: RewardType = RewardType.Money) {
        this.label.string = str;
        if (rewardType == RewardType.Money) {
            CurrencyManager.instance.changeMoneyIcon(this.iconMoney);
        } else if (rewardType == RewardType.GoldenCard) {
            ResourceManager.loadRes("Atlas/Common/daoju", cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.iconMoney)) {
                    this.iconMoney.spriteFrame = frame;
                }
            });
        }
    }
}
