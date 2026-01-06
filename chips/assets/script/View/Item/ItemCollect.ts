// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { CollectEffectType } from "../../Common/EffectManager";
import { RewardType } from "../../Common/EnumDefine";
import { Log } from "../../FrameWork/Log";
import ResourceManager from "../../FrameWork/ResourceManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemCollect extends cc.Component {

    @property(cc.Sprite)
    sprite: cc.Sprite = null;

    updateIcon(rewardType: CollectEffectType = CollectEffectType.Money) {
        Log.Debug("ItemCollect updateIcon name = " + CurrencyManager.instance.getOneMoneyIcon());
        if (rewardType == CollectEffectType.Money) {
            ResourceManager.loadRes(CurrencyManager.instance.getOneMoneyIcon(), cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.sprite)) {
                    this.sprite.spriteFrame = frame;
                } else {
                    Log.Error("ItemCollect loadRes error, url = " + CurrencyManager.instance.getOneMoneyIcon());
                }
            });
        }
    }
}
