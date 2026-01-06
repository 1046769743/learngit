// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { CollectEffectType, CollectMultipleEffect, EffectManager } from "../../Common/EffectManager";
import { RewardType } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import AdMgr, { AdType, ModuleType } from "../../Module/AdModel/AdMgr";
import PigMgr from "../../Module/Pig/PigMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import ItemPopTop from "../Common/ItemPopTop";
import RewardsContent from "../Common/RewardsContent";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopPigAnim extends BasePop {
    @property(sp.Skeleton)
    skeletonPig: sp.Skeleton = null;

    @property(RewardsContent)
    rewardsContent: RewardsContent = null;

    @property(DlgBtn)
    btnCollect: DlgBtn = null;

    @property(ItemPopTop)
    itemPopTop: ItemPopTop = null;

    @property(cc.Node)
    nodeTitle: cc.Node = null;

    private rewards: { type: RewardType, value: number }[] = [];

    start() {
        this.btnCollect.addClickCallback(this.onCollectClick, this);
        EventCenter.on(EventName.onAdComplete, this.onAdComplete, this);

        this.initUI();
        this.showEnterAnim();
    }

    protected onDestroy(): void {
        EventCenter.off(EventName.onAdComplete, this.onAdComplete, this);
    }

    private initUI() {
        this.rewards = PigMgr.Instance.getReward();
        this.rewards = this.rewards.reverse();
        this.rewardsContent.updateUI(this.rewards);

        this.itemPopTop.node.active = false;
        this.nodeTitle.active = false;
        this.rewardsContent.node.active = false;
        this.btnCollect.node.active = false;
    }

    showEnterAnim() {
        this.skeletonPig.setAnimation(0, "animation", false);
        this.scheduleOnce(() => {
            this.nodeTitle.active = true;
            this.rewardsContent.node.active = true;
            this.btnCollect.node.active = true;
            this.nodeTitle.opacity = 0;
            this.rewardsContent.node.opacity = 0;
            this.btnCollect.node.opacity = 0;
            cc.tween(this.nodeTitle)
                .to(0.5, { opacity: 255 })
                .start();
            cc.tween(this.rewardsContent.node)
                .to(0.5, { opacity: 255 })
                .start();
            cc.tween(this.btnCollect.node)
                .to(0.5, { opacity: 255 })
                .start();

            NativeApi.instance.buryPoint("PiggyQuestFinish");
        }, 2);
    }

    // 收集按钮点击
    private onCollectClick() {
        this.btnCollect.interactable = false;
        AdMgr.Instance.showAd(ModuleType.PigReward, AdType.PigReward);
    }

    private onAdComplete(isSuccess: boolean, moduleType: ModuleType) {
        if (isSuccess && moduleType === ModuleType.PigReward) {
            let rewards = this.rewards;
            let hasGoldenCard = false;
            for (let reward of rewards) {
                if (reward.type === RewardType.GoldenCard) {
                    hasGoldenCard = true;
                }
            }
            if (hasGoldenCard) {
                PigMgr.Instance.resetContinuousMissGoldenCardCount();
            } else {
                PigMgr.Instance.addContinuousMissGoldenCardCount();
            }
            PigMgr.Instance.setCollectedReward(true);
            this.playCollectAnim();
        } else {
            this.btnCollect.interactable = true;
        }
    }

    // 播放收集动效
    private playCollectAnim() {
        Log.Debug("zq------ playCollectAnim");
        this.itemPopTop.node.active = true;
        this.itemPopTop.updateUI();

        let rewards = this.rewards;


        let collectMultipleEffects: CollectMultipleEffect[] = [];
        for (let i = 0; i < rewards.length; i++) {
            let reward = rewards[i];
            let collectType = CollectEffectType.Money;
            let targetPos = null;
            let startPos = null;
            let collectNum = 10;
            let collectCallback = null;
            if (reward.type == RewardType.Money) {
                UserDataMgr.Instance.addMoneyNumber(reward.value, false);

                collectType = CollectEffectType.Money;
                startPos = this.rewardsContent.getRewardStartPos(RewardType.Money);
                targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.POP_TOP_MONEY);
                collectNum = 10;
                collectCallback = () => {
                    EventCenter.dispatchEvent(EventName.RefreshMoneyNumber, reward.value);
                    UIManager.Instance.close(PrefabDefine.PopPigAnim);
                };

            } else if (reward.type == RewardType.GoldenCard) {
                UserDataMgr.Instance.addGoldenCardNumber(reward.value, false);

                collectType = CollectEffectType.GoldenCard;
                startPos = this.rewardsContent.getRewardStartPos(RewardType.GoldenCard);
                targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.POP_TOP_GOLDEN_CARD);
                collectNum = 10;
                collectCallback = () => {
                    EventCenter.dispatchEvent(EventName.UpdateGoldenCardNumber, reward.value);
                    UIManager.Instance.close(PrefabDefine.PopPigAnim);
                };
            }

            collectMultipleEffects.push({
                collectType: collectType,
                num: collectNum,
                startPos: startPos,
                targetPos: targetPos,
                collectCallback: collectCallback,
            });
        }
        EffectManager.instance.playCollectMultipleEffect(collectMultipleEffects);
    }

}
