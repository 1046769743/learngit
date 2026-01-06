// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import DlgProgress from "../../Common/DlgProgress";
import { CollectEffectType, EffectManager } from "../../Common/EffectManager";
import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { GameMgr } from "../../Module/Game/GameMgr";
import { GuideMgr, GuideType } from "../../Module/Guide/GuideMgr";
import Language from "../../Module/Language/Language";
import PigMgr from "../../Module/Pig/PigMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconPig extends cc.Component {
    @property(DlgBtn)
    btn: DlgBtn = null;

    @property(DlgProgress)
    progress: DlgProgress = null;

    @property(sp.Skeleton)
    skeleton: sp.Skeleton = null;

    @property(cc.Label)
    labTips: cc.Label = null;

    private readonly KEY_ICON_PIG_GUIDE = "icon_pig_guide";

    private _guideComplete: boolean = false;
    start() {
        EventCenter.on(EventName.LevelFinish, this.onLevelFinish, this);
        EventCenter.on(EventName.CompletePigTask, this.onCompletePigTask, this);
        EventCenter.on(EventName.PigRedDotRefresh, this.refreshRedDot, this);

        this.btn.addClickCallback(this.onBtnClick, this);
        UIManager.Instance.registerTargetNode(TargetNodeKeys.ICON_PIG, this.node);

        this.updateProgress();
        this.refreshRedDot();

        this._guideComplete = StorageManager.Instance.getBoolean(this.KEY_ICON_PIG_GUIDE, false);

        this.node.active = PigMgr.Instance.isFeatureOpen();
        this.tryGuide();
    }

    // 尝试引导
    private tryGuide() {
        if (!this.node.active) {
            return;
        }

        // 引导
        if (this._guideComplete) {
            return;
        }

        GuideMgr.Instance.changeStep(GuideType.NewUser, 2001);
        StorageManager.Instance.set(this.KEY_ICON_PIG_GUIDE, true);
        this._guideComplete = true;
    }

    private onLevelFinish() {
        if (this.node.active) {
            return;
        }
        this.node.active = PigMgr.Instance.isFeatureOpen();
        this.tryGuide();
    }

    private onCompletePigTask(hammerCount: number) {
        // 未开启
        if (!this.node.active) {
            return;
        }

        this.updateProgress();
        this.refreshRedDot();
        // 未引导过
        if (!this._guideComplete) {
            return;
        }

        this.scheduleOnce(() => {
            this.tryPlayCollectEffect(hammerCount);
        }, 0.3);
    }

    // 更新进度
    private updateProgress() {
        let targetHammerCount = PigMgr.Instance.getTargetHammerCount();
        let hammerCount = PigMgr.Instance.getHammerCount();
        this.progress.updateUI(hammerCount, targetHammerCount);
        this.refreshRedDot();
    }

    private tryPlayCollectEffect(hammerCount: number) {
        this.scheduleOnce(() => {
            let startNode = this.node.getChildByName("startNode");
            let targetNode = this.node.getChildByName("targetNode");
            let worldStartPos = startNode.convertToWorldSpaceAR(cc.v2(0, 0));
            let worldTargetPos = targetNode.convertToWorldSpaceAR(cc.v2(0, 0));
            EffectManager.instance.playAddProgressEffect(CollectEffectType.Hammer, worldStartPos, worldTargetPos, hammerCount, () => {
                startNode.active = false;
                targetNode.active = false;
            });
        }, 0.1);
    }

    // 刷新红点
    private refreshRedDot() {
        let allCompleted = PigMgr.Instance.isShowTaskAllCompleted();
        let collectedReward = PigMgr.Instance.getCollectedReward();
        let redDot = this.node.getChildByName("red");
        if (redDot) {
            redDot.active = allCompleted && !collectedReward;
            redDot.scale = 0.8;
        }

        this.labTips.node.active = false;
        this.progress.node.active = true;
        if (this.skeleton) {
            if (!allCompleted) {
                this.skeleton.setAnimation(0, "animation2", true);
            }

            if (allCompleted && !collectedReward) {
                this.skeleton.setAnimation(0, "animation", true);
                this.labTips.node.active = true;
                this.labTips.string = Language.instance.getDes("69");
            }

            if (allCompleted && collectedReward) {
                this.skeleton.setAnimation(0, "animation3", true);
                this.progress.node.active = false;
            }
        }
    }

    onBtnClick() {
        Log.Debug("IconPig onBtnClick");
        UIManager.Instance.open(PrefabDefine.PopPig);
    }
}
