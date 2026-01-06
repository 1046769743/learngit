// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import CurrencyManager from "../../Module/Currency/CurrencyManager";
import { WheelRewardType } from "../../Module/Reward/RewardMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemSlotSprite extends cc.Component {
    @property(cc.Sprite)
    spriteDollar: cc.Sprite = null;

    @property(cc.Sprite)
    spriteBulb: cc.Sprite = null;

    @property(cc.Sprite)
    spriteSeven77: cc.Sprite = null;

    public setSprite(wheelRewardType: WheelRewardType) {
        this.spriteDollar.node.active = false;
        this.spriteBulb.node.active = false;
        this.spriteSeven77.node.active = false;
        if (wheelRewardType == WheelRewardType.Dollar) {
            this.spriteDollar.node.active = true;
            CurrencyManager.instance.changeMoneyIcon(this.spriteDollar);
        } else if (wheelRewardType == WheelRewardType.Bulb) {
            this.spriteBulb.node.active = true;
        } else if (wheelRewardType == WheelRewardType.Seven77) {
            this.spriteSeven77.node.active = true;
        }
    }
}
