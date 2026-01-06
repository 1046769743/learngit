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
    normalNode: cc.Node = null;

    @property(cc.Node)
    grayNode: cc.Node = null;

    @property(cc.Node)
    redDotNode: cc.Node = null;

    start() {
        this.btn.addClickCallback(this.onBtnClick, this);
        EventCenter.on(EventName.UpdateLuckWheelProgress, this.updateProgress, this);
        EventCenter.on(EventName.UpdateCompletedWordCount, this.isOpen, this);
        UIManager.Instance.registerTargetNode(TargetNodeKeys.LUCK_WHEEL_ICON, this.node);

        this.updateProgress();
        this.isOpen();
    }

    onDestroy() {
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.LUCK_WHEEL_ICON);
        EventCenter.off(EventName.UpdateLuckWheelProgress, this.updateProgress, this);
        EventCenter.off(EventName.UpdateCompletedWordCount, this.isOpen, this);
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
        let currentProgress = LuckWheelMgr.Instance.getProgress();
        let targetProgress = LuckWheelMgr.Instance.getTargetCount();
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

        if (currentProgress >= targetProgress) {
            this.grayNode.active = false;
            this.normalNode.active = true;
            this.redDotNode.active = true;
        } else {
            this.grayNode.active = true;
            this.normalNode.active = false;
            this.redDotNode.active = false;
        }
    }

    private onBtnClick() {
        let currentProgress = LuckWheelMgr.Instance.getProgress();
        let targetProgress = LuckWheelMgr.Instance.getTargetCount();
        if (currentProgress >= targetProgress) {
            UIManager.Instance.open(PrefabDefine.PopLuckWheel);
        }
    }
}
