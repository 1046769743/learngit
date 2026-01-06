// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { ObjectPoolManager } from "../../Common/ObjectPoolManager";
import { Log } from "../../FrameWork/Log";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemCombo extends cc.Component {
    @property(cc.Node)
    bgNode: cc.Node = null;

    @property(cc.Node)
    comboNode: cc.Node = null;

    @property([cc.Node])
    nodes: cc.Node[] = [];

    public reset() {
        this.nodes.forEach(node => {
            node.active = false;
        });
    }

    public playEffect(effectIndex: number) {

        if (effectIndex >= this.nodes.length) {
            effectIndex = this.nodes.length - 1;
        }

        // 越界
        this.nodes[effectIndex].active = true;

        // 播放动画
        // this.bgNode.active = true;
        // this.bgNode.scaleX = 0;
        // this.bgNode.scaleY = 0.5;
        // this.bgNode.opacity = 255;
        // cc.tween(this.bgNode)
        //     .to(0.4, { scaleX: 1, scaleY: 1 }, { easing: cc.easing.sineInOut })
        //     .to(0.6, { scaleX: 1.3, scaleY: 1.3, opacity: 0 }, { easing: cc.easing.sineInOut })
        //     .call(() => {
        //         this.bgNode.active = false;
        //     })
        //     .start();

        this.comboNode.active = true;
        this.comboNode.scaleX = 0;
        this.comboNode.scaleY = 0.3;
        this.comboNode.opacity = 255;
        cc.tween(this.comboNode)
            .to(0.4, { scaleX: 0.7, scaleY: 0.7 }, { easing: cc.easing.sineInOut })
            .to(0.6, { scaleX: 0.9, scaleY: 0.9, opacity: 0 }, { easing: cc.easing.sineInOut })
            .call(() => {
                this.comboNode.active = false;
                this.node.removeFromParent();
                ObjectPoolManager.instance.putNode(this.node);
            })
            .start();

        this.playSound(effectIndex);
    }


    private playSound(effectIndex: number) {
        let soundName = "";
        switch (effectIndex) {
            case 0:
                soundName = SOUND_NAME.Good;
                break;
            case 1:
                soundName = SOUND_NAME.Great;
                break;
            case 2:
                soundName = SOUND_NAME.Amazing;
                break;
            case 3:
                soundName = SOUND_NAME.Excellent;
                break;
            case 4:
                soundName = SOUND_NAME.Perfect;
                break;
        }
        if (soundName == "") {
            return;
        }
        // SoundManager.Instance.PlaySound(soundName);
    }

}
