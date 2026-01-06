// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { RewardType } from "../../Common/EnumDefine";
import { Log } from "../../FrameWork/Log";
import ResourceManager from "../../FrameWork/ResourceManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import { LuckWheelReward } from "../../Module/LuckWheel/LuckWheelMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemLuckWheel extends cc.Component {

    updateUI(rewardInfos: LuckWheelReward[]) {
        for (let i = 0; i < rewardInfos.length; i++) {
            let item = this.node.getChildByName("item" + (i + 1));
            let spriteIcon = item.getChildByName("icon").getComponent(cc.Sprite);
            let rewardInfo = rewardInfos[i];
            if (rewardInfo.type == RewardType.Money) {
                let path = CurrencyManager.instance.getMoreMoneyIcon();
                ResourceManager.loadRes(path, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                    if (frame && cc.isValid(spriteIcon)) {
                        spriteIcon.spriteFrame = frame;
                    } else {
                        Log.Error("PopLuckWheel loadRes error, url = " + path);
                    }
                });
                spriteIcon.node.scale = 0.35;

                let labelReward = item.getChildByName("reward").getComponent(cc.Label);
                labelReward.string = CurrencyManager.instance.formatMoneyForWheel(rewardInfo.value);
            } else {
                let path = "Atlas/Common/golden_card";
                ResourceManager.loadRes(path, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                    if (frame && cc.isValid(spriteIcon)) {
                        spriteIcon.spriteFrame = frame;
                    } else {
                        Log.Error("PopLuckWheel loadRes error, url = " + path);
                    }
                });
                spriteIcon.node.scale = 0.7;

                let labelReward = item.getChildByName("reward").getComponent(cc.Label);
                labelReward.string = "+" + rewardInfo.value.toString();
            }


            let select = item.getChildByName("select");
            select.active = false;
        }
    }

    playSelectAnimation(index: number, callback: () => void) {
        let item = this.node.getChildByName("item" + (index + 1));
        let select = item.getChildByName("select");
        select.active = true;
        select.opacity = 0;
        cc.tween(select)
            .to(0.15, { opacity: 255 })
            .to(0.15, { opacity: 0 })
            .to(0.15, { opacity: 255 })
            .to(0.15, { opacity: 0 })
            .to(0.15, { opacity: 255 })
            .to(0.15, { opacity: 0 })
            .to(0.15, { opacity: 255 })
            .call(() => {
                if (callback) {
                    callback();
                }
            })
            .start();
    }

    onlyShowSelect(index: number) {
        let item = this.node.getChildByName("item" + (index + 1));
        let select = item.getChildByName("select");
        select.active = true;
        select.opacity = 255;
    }

    public getSelectPosition(index: number) {
        let item = this.node.getChildByName("item" + (index + 1));
        let iconNode = item.getChildByName("icon");
        let localPos = iconNode.convertToNodeSpaceAR(iconNode.position);
        let worldPos = this.node.convertToWorldSpaceAR(localPos);
        return worldPos;
    }

}