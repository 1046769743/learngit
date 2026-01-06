// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { CollectEffectType, EffectManager } from "../../Common/EffectManager";
import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { GuideMgr, GuideType } from "../../Module/Guide/GuideMgr";
import LuckWheelMgr from "../../Module/LuckWheel/LuckWheelMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemLuckyWheel extends cc.Component {

    @property(cc.Sprite)
    progress: cc.Sprite = null;

    @property(DlgBtn)
    btn: DlgBtn = null;

    @property(cc.Label)
    labelProgress: cc.Label = null;

    @property(cc.Node)
    spineNode: cc.Node = null;

    @property(cc.Node)
    normalNode: cc.Node = null;

    start() {
        this.btn.addClickCallback(this.onBtnClick, this);

        this.updateProgress();
        EventCenter.on(EventName.UpdateLuckWheelProgress, this.updateProgress, this);
        EventCenter.on(EventName.LevelFinish, this.isOpen, this);
        UIManager.Instance.registerTargetNode(TargetNodeKeys.LUCK_WHEEL_ICON, this.node);
        this.isOpen();
    }

    onDestroy() {
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.LUCK_WHEEL_ICON);
        EventCenter.off(EventName.UpdateLuckWheelProgress, this.updateProgress, this);
        EventCenter.off(EventName.LevelFinish, this.isOpen, this);
    }

    private isOpen() {
        let isOpen = LuckWheelMgr.Instance.isFunctionOpen();
        this.node.active = isOpen;

        if (isOpen) {
            let isShowed = StorageManager.Instance.getBoolean("icon_lucky_wheel_showed", false)
            if (!isShowed) {
                GuideMgr.Instance.changeStep(GuideType.NewUser, 1001);
                StorageManager.Instance.set("icon_lucky_wheel_showed", true);

                this.updateProgress();
            }
        }
    }

    private updateProgress(addNum: number = 0) {
        if (!this.node.active) {
            return;
        }
        let currentProgress = LuckWheelMgr.Instance.getCurrentFinishWordCount();
        let targetProgress = LuckWheelMgr.Instance.getTargetWordCount();
        this.labelProgress.string = `${currentProgress}/${targetProgress}`;
        this.progress.fillRange = currentProgress / targetProgress;

        if (addNum > 0) {
            this.scheduleOnce(() => {
                let startNode = this.node.getChildByName("startNode");
                let targetNode = this.node.getChildByName("targetNode");
                let worldStartPos = startNode.convertToWorldSpaceAR(cc.v2(0, 0));
                let worldTargetPos = targetNode.convertToWorldSpaceAR(cc.v2(0, 0));
                EffectManager.instance.playAddProgressEffect(CollectEffectType.LuckyWheel, worldStartPos, worldTargetPos, addNum, () => {
                    startNode.active = false;
                    targetNode.active = false;
                });
            }, 0.1);
        }

        this.refreshRedDot();
    }

    private refreshRedDot() {
        let redDot = this.node.getChildByName("red");
        if (redDot) {
            redDot.scale = 0.8;
            let currentProgress = LuckWheelMgr.Instance.getCurrentFinishWordCount();
            let targetProgress = LuckWheelMgr.Instance.getTargetWordCount();
            redDot.active = currentProgress >= targetProgress;

            if (LuckWheelMgr.Instance.isShowGoldWheel() && LuckWheelMgr.Instance.isClaimMoneyReward()) {
                this.spineNode.active = true;
                this.normalNode.active = false;
            } else {
                this.spineNode.active = false;
                this.normalNode.active = true;
            }
            this.progress.node.parent.active = !redDot.active;
        }
    }

    private onBtnClick() {
        UIManager.Instance.open(PrefabDefine.PopLuckWheel);
    }
}
