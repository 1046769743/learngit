// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { CollectEffectType } from "../../Common/EffectManager";
import { RewardType } from "../../Common/EnumDefine";
import { ObjectPoolManager } from "../../Common/ObjectPoolManager";
import { Log } from "../../FrameWork/Log";
import ResourceManager from "../../FrameWork/ResourceManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemTips extends cc.Component {

    @property(cc.Label)
    laContent: cc.Label = null;

    @property(cc.Node)
    nodeBg: cc.Node = null;

    public initContent(content: string) {
        this.laContent.string = content;
        this.scheduleOnce(() => {
            this.nodeBg.height = this.laContent.node.height + 60;
        }, 0.05);

        this.node.active = true;
        this.node.scaleY = 0;
        this.node.opacity = 255;
        cc.tween(this.node)
            .to(0.2, { scaleY: 1 })
            .delay(0.5)
            .to(0.4, { opacity: 0 })
            .call(() => {
                this.node.removeFromParent();
                ObjectPoolManager.instance.putNode(this.node);
            })
            .start();
    }
}
