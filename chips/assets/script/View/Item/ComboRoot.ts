// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { ObjectPoolManager } from "../../Common/ObjectPoolManager";
import { Log } from "../../FrameWork/Log";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import ItemCombo from "./ItemCombo";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ComboRoot extends cc.Component {
    @property(cc.Prefab)
    private effectNodePrefab: cc.Prefab = null;

    // 效果节点数量
    private maxEffectNodeCount: number = 5;
    // 连续的次数
    private lianxucishu: number = 0;
    // 上一次完成的时间 秒
    private lastTime: number = 0;
    // 记录当前关卡已完成的combo类型
    private completedComboTypes: Set<string> = new Set();

    start() {
        this.reset();
        this.clearChildren();
    }

    public clearChildren() {
        for (let i = this.node.children.length - 1; i >= 0; i--) {
            let node = this.node.children[i];
            ObjectPoolManager.instance.putNode(node);
        }
    }

    public reset() {
        this.lianxucishu = 0;
        this.lastTime = 0;
        this.completedComboTypes.clear();
    }

    public onFound(word: string, direction: cc.Vec2) {
        // Log.Debug("ItemCombo onFound");
        // // 大于3s重置连击
        // if (this.lastTime > 0 && cc.sys.now() - this.lastTime > 5000) {
        //     Log.Debug("ItemCombo onFound 时间超出5秒");
        //     this.reset();
        // }

        // this.lianxucishu++;
        // this.lastTime = cc.sys.now();

        // // 首个单词不显示
        // if (this.lianxucishu < 2) {
        //     Log.Debug("ItemCombo onFound 首个单词不显示");
        //     return;
        // }

        // // 越界
        // let effectIndex = this.lianxucishu - 2;
        // if (effectIndex >= this.maxEffectNodeCount) {
        //     effectIndex = this.maxEffectNodeCount - 1;
        // }

        // let effectNode = ObjectPoolManager.instance.getNode(this.effectNodePrefab);
        // if (effectNode) {
        //     let itemCombo = effectNode.getComponent(ItemCombo) as ItemCombo;
        //     itemCombo.reset();
        //     itemCombo.playEffect(effectIndex);
        //     effectNode.parent = this.node;
        // }

        /*
        单词长度：
            2. 同一个关卡，首次完成一个5字母单词（不是斜的）给与good
            3. 同一个关卡，首次完成一个6字母单词给与（不是斜的）给与excellent
            4. 同一个关卡，首次完成一个5字母斜的单词给与（是斜的）给与great
            5. 同一个关卡，首次完成一个6字母斜的单词给与（是斜的）perfect
        */

        // 判断单词长度（只处理5或6字母的单词）
        const wordLength = word.length;
        if (wordLength !== 5 && wordLength !== 6) {
            return;
        }

        // 判断是否是斜的（direction的x和y都不为0）
        const isDiagonal = direction.x !== 0 && direction.y !== 0;

        // 生成combo类型标识
        const comboType = `${wordLength}_${isDiagonal ? 'diagonal' : 'normal'}`;

        // 如果已经完成过这种类型，不显示
        if (this.completedComboTypes.has(comboType)) {
            return;
        }

        // 标记为已完成
        this.completedComboTypes.add(comboType);

        // 根据类型确定effectIndex
        let effectIndex = -1;
        if (wordLength === 5 && !isDiagonal) {
            effectIndex = 0; // good
        } else if (wordLength === 6 && !isDiagonal) {
            effectIndex = 3; // excellent
        } else if (wordLength === 5 && isDiagonal) {
            effectIndex = 1; // great
        } else if (wordLength === 6 && isDiagonal) {
            effectIndex = 4; // perfect
        }

        // 如果找到了对应的效果，显示
        if (effectIndex >= 0) {
            let effectNode = ObjectPoolManager.instance.getNode(this.effectNodePrefab);
            if (effectNode) {
                let itemCombo = effectNode.getComponent(ItemCombo) as ItemCombo;
                itemCombo.reset();
                itemCombo.playEffect(effectIndex);
                effectNode.parent = this.node;
                Log.Debug("ComboRoot onFound 显示combo效果: " + comboType + ", effectIndex: " + effectIndex);
            }
        }
    }
}
