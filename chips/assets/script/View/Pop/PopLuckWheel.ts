// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { CollectEffectType, EffectManager } from "../../Common/EffectManager";
import { RewardType } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import ResourceManager from "../../FrameWork/ResourceManager";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import AdMgr, { AdType, ModuleType } from "../../Module/AdModel/AdMgr";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import { GuideMgr, GuideType } from "../../Module/Guide/GuideMgr";
import Language from "../../Module/Language/Language";
import LuckWheelMgr, { LuckWheelType } from "../../Module/LuckWheel/LuckWheelMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import ItemPopTop from "../Common/ItemPopTop";
import ItemLuckWheel from "../Item/ItemLuckWheel";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopLuckWheel extends BasePop {
    // 普通转盘
    @property(cc.Node)
    nodeNormalLuckWheel: cc.Node = null;

    @property(ItemLuckWheel)
    normalLuckWheel: ItemLuckWheel = null;

    @property(DlgBtn)
    btnNormalSpin: DlgBtn = null;

    @property(DlgBtn)
    btnClose: DlgBtn = null;

    @property(cc.Node)
    nodeGrayBgBtn: cc.Node = null;

    // 黄金转盘
    @property(cc.Node)
    nodeGoldenLuckWheel: cc.Node = null;

    @property(ItemLuckWheel)
    goldenLuckWheel: ItemLuckWheel = null;

    @property(DlgBtn)
    btnGoldenSpin: DlgBtn = null;

    @property(DlgBtn)
    btnCloseGolden: DlgBtn = null;

    @property(ItemPopTop)
    itemPopTop: ItemPopTop = null;

    // 光圈
    @property(cc.Node)
    nodeLight1: cc.Node = null;
    @property(cc.Node)
    nodeLight2: cc.Node = null;
    @property(cc.Node)
    nodeLight3: cc.Node = null;
    @property(cc.Node)
    nodeLight4: cc.Node = null;

    // 幕布
    @property(cc.Node)
    nodeCurtain: cc.Node = null;
    @property(cc.Node)
    nodeLeft: cc.Node = null;
    @property(cc.Node)
    nodeRight: cc.Node = null;

    // 光圈动画的间隔
    private lightInterval: number = 0;
    // 当前是否在转动
    private isSpinning: boolean = false;

    start() {
        this.btnNormalSpin.addClickCallback(this.onNormalSpin, this);
        this.btnGoldenSpin.addClickCallback(this.onGoldenSpin, this);
        this.btnClose.addClickCallback(this.onClose, this);
        this.btnCloseGolden.addClickCallback(this.onCloseGolden, this);
        EventCenter.on(EventName.GuideLuckWheelClick, this.onNormalSpin, this);
        EventCenter.on(EventName.onAdComplete, this.onAdComplete, this);

        this.nodeNormalLuckWheel.active = true;
        this.nodeGoldenLuckWheel.active = false;

        this.nodeLight1.active = false;
        this.nodeLight2.active = true;
        this.nodeLight3.active = false;
        this.nodeLight4.active = true;
        this.itemPopTop.updateUI();
        this.itemPopTop.node.active = false;

        let rewardInfos = LuckWheelMgr.Instance.getCurrentLuckWheelShowRewardList();
        Log.Debug("PopLuckWheel rewardInfos", JSON.stringify(rewardInfos));
        this.normalLuckWheel.updateUI(rewardInfos);

        if (this.isNormalButtonClickable()) {
            this.nodeGrayBgBtn.active = false;

            // 判断是否显示黄金转盘
            if (LuckWheelMgr.Instance.isShowGoldWheel() && LuckWheelMgr.Instance.isClaimMoneyReward()) {
                this.updateGoldenLuckWheel(false);
            }

        } else {
            this.nodeGrayBgBtn.active = true;
            this.showLastLuckWheelUI();
        }

        this.scheduleOnce(() => {
            this.tryGuide();
        }, 0.5);
    }

    protected update(dt: number): void {
        this.lightInterval += dt;
        if (this.lightInterval >= 0.3) {
            this.lightInterval = 0;
            this.nodeLight1.active = !this.nodeLight1.active;
            this.nodeLight2.active = !this.nodeLight2.active;
            this.nodeLight3.active = !this.nodeLight3.active;
            this.nodeLight4.active = !this.nodeLight4.active;
        }
    }

    // 普通按钮是否可以点击
    private isNormalButtonClickable(): boolean {
        let currentProgress = LuckWheelMgr.Instance.getCurrentFinishWordCount();
        let targetProgress = LuckWheelMgr.Instance.getTargetWordCount();
        return currentProgress >= targetProgress;
    }

    // 显示上次转盘的UI
    private showLastLuckWheelUI() {
        let rewardIndex = LuckWheelMgr.Instance.getCurrentLuckWheelRewardIndex();
        Log.Debug("PopLuckWheel showLastLuckWheelUI rewardIndex", rewardIndex);
        if (rewardIndex == -1) {
            return;
        }
        Log.Debug("PopLuckWheel rewardIndex", rewardIndex);

        let nodeWheel = this.normalLuckWheel.node;
        const targetOffset = 360 - rewardIndex * 45;
        const totalRotation = -(13 * 360 + targetOffset);
        nodeWheel.angle = totalRotation;
        this.normalLuckWheel.onlyShowSelect(rewardIndex);
    }

    private updateGoldenLuckWheel(isAnim: boolean = true) {
        this.itemPopTop.node.active = false;

        if (isAnim) {
            this.nodeCurtain.active = true;
            this.nodeLeft.position.x = -720;
            this.nodeRight.position.x = 720;
            cc.tween(this.nodeLeft)
                .to(0.3, { position: cc.v3(-360, 0, 0) })
                .delay(0.3)
                .to(0.3, { position: cc.v3(-720, 0, 0) })
                .start();
            cc.tween(this.nodeRight)
                .to(0.3, { position: cc.v3(360, 0, 0) })
                .delay(0.3)
                .to(0.3, { position: cc.v3(720, 0, 0) })
                .call(() => {
                    this.nodeCurtain.active = false;
                })
                .start();

            this.scheduleOnce(() => {
                this.nodeGoldenLuckWheel.active = true;
                this.nodeNormalLuckWheel.active = false;
                this.btnCloseGolden.node.active = false;
                this.btnGoldenSpin.interactable = true;

                this.scheduleOnce(() => {
                    this.btnCloseGolden.node.active = true;
                    this.btnCloseGolden.interactable = true;
                }, 2);

                let rewardInfos = LuckWheelMgr.Instance.getCurrentGoldenLuckWheelShowRewardList();
                this.goldenLuckWheel.updateUI(rewardInfos);
            }, 0.3);
        } else {
            this.nodeGoldenLuckWheel.active = true;
            this.nodeNormalLuckWheel.active = false;
            this.btnCloseGolden.node.active = false;
            this.btnGoldenSpin.interactable = true;

            this.scheduleOnce(() => {
                this.btnCloseGolden.node.active = true;
                this.btnCloseGolden.interactable = true;
            }, 2);

            let rewardInfos = LuckWheelMgr.Instance.getCurrentGoldenLuckWheelShowRewardList();
            this.goldenLuckWheel.updateUI(rewardInfos);
        }

    }

    // 尝试引导
    private tryGuide() {
        if (StorageManager.Instance.getBoolean("isGuideLuckWheel", false)) {
            return;
        }
        StorageManager.Instance.set("isGuideLuckWheel", true);

        UIManager.Instance.registerTargetNode(TargetNodeKeys.LUCK_WHEEL_SPIN, this.btnNormalSpin.node);
        GuideMgr.Instance.changeStep(GuideType.NewUser, 1002);
    }

    private onNormalSpin() {
        Log.Debug("PopLuckWheel onNormalSpin")
        if (this.isSpinning) {
            return;
        }
        if (!this.isNormalButtonClickable()) {
            let currentProgress = LuckWheelMgr.Instance.getCurrentFinishWordCount();
            let targetProgress = LuckWheelMgr.Instance.getTargetWordCount();
            let str = Language.instance.getDes("62");
            str = str.replace("%s", (targetProgress - currentProgress).toString());
            UIManager.Instance.showToast("62", str);
            return;
        }
        this.btnClose.enabled = false;
        this.btnNormalSpin.enabled = false;
        this.onSpin(LuckWheelType.Money);

        NativeApi.instance.buryPoint("CommonSpinButtonClick");
    }

    private onGoldenSpin() {
        if (this.isSpinning) {
            return;
        }
        LuckWheelMgr.Instance.resetGoldenWheelCloseCount();
        AdMgr.Instance.showAd(ModuleType.LuckWheel, AdType.LuckWheel);
        NativeApi.instance.buryPoint("GoldSpinButtonClick");
    }

    private onAdComplete(isSuccess: boolean, moduleType: ModuleType) {
        Log.Debug("PopLuckWheel onAdComplete: " + moduleType, isSuccess);
        if (moduleType !== ModuleType.LuckWheel) {
            return;
        }
        if (isSuccess) {
            this.onSpin(LuckWheelType.Golden);
        } else {
            UIManager.Instance.close(PrefabDefine.PopLuckWheel);
        }
    }

    private onSpin(type: LuckWheelType) {
        Log.Debug("PopLuckWheel onSpin")
        let rewardIndex = -1;
        if (type === LuckWheelType.Money) {
            rewardIndex = LuckWheelMgr.Instance.getCurrentLuckWheelRewardIndex();
        } else {
            rewardIndex = LuckWheelMgr.Instance.getCurrentGoldenLuckWheelRewardIndex();
        }
        if (rewardIndex == -1) {
            return;
        }

        Log.Debug("PopLuckWheel rewardIndex", rewardIndex);

        this.isSpinning = true;
        let nodeWheel = null;
        if (type === LuckWheelType.Money) {
            nodeWheel = this.normalLuckWheel.node;
        } else {
            nodeWheel = this.goldenLuckWheel.node;
        }

        nodeWheel.angle = 0;
        this.btnGoldenSpin.interactable = false;
        this.btnNormalSpin.interactable = false;
        this.btnClose.interactable = false;
        this.btnCloseGolden.interactable = false;

        const targetOffset = 360 - rewardIndex * 45;
        const totalRotation = -(13 * 360 + targetOffset);

        cc.tween(nodeWheel)
            .to(5, { angle: totalRotation }, { easing: 'quadInOut' })
            .call(() => {
                this.onLuckWheelEnd(type);
            })
            .start();
    }

    private onLuckWheelEnd(type: LuckWheelType) {
        // 播放选中动画
        let rewardIndex = -1;
        let itemLuckWheel = null;
        if (type === LuckWheelType.Money) {
            rewardIndex = LuckWheelMgr.Instance.getCurrentLuckWheelRewardIndex();
            itemLuckWheel = this.normalLuckWheel;
        } else {
            itemLuckWheel = this.goldenLuckWheel;
            rewardIndex = LuckWheelMgr.Instance.getCurrentGoldenLuckWheelRewardIndex();
        }
        if (rewardIndex >= 0) {
            itemLuckWheel.playSelectAnimation(rewardIndex, () => {
                this.isSpinning = false;
                this.onCollectReward(type);
            });
        }
    }

    private onCollectReward(type: LuckWheelType) {
        if (this.isSpinning) {
            return;
        }
        this.itemPopTop.node.active = true;
        this.itemPopTop.updateUI();

        let reward = LuckWheelMgr.Instance.getLuckWheelReward(type);
        if (type === LuckWheelType.Golden) {
            if (reward.type === RewardType.GoldenCard) {
                LuckWheelMgr.Instance.resetGoldenWheelMissCount();
            } else {
                LuckWheelMgr.Instance.addGoldenWheelMissCount();
            }

            LuckWheelMgr.Instance.nextLuckWheel();
        } else {
            LuckWheelMgr.Instance.claimMoneyReward();
        }

        let itemLuckWheel = null;
        if (type === LuckWheelType.Money) {
            itemLuckWheel = this.normalLuckWheel;
        } else {
            itemLuckWheel = this.goldenLuckWheel;
        }

        if (reward.value > 0) {
            SoundManager.Instance.PlaySound(SOUND_NAME.CollectMoney);
            let startPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.CENTER_POINT);
            startPos = cc.v2(startPos.x, startPos.y + 150);
            let targetPos = null;
            let effectType = CollectEffectType.Money;
            if (reward.type === RewardType.Money) {
                targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.POP_TOP_MONEY);
                effectType = CollectEffectType.Money;
            } else if (reward.type === RewardType.GoldenCard) {
                targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.POP_TOP_GOLDEN_CARD);
                effectType = CollectEffectType.GoldenCard;
            }

            EffectManager.instance.playCollectEffect(effectType, 10, startPos, targetPos, () => {
                if (reward.type === RewardType.Money) {
                    UserDataMgr.Instance.addMoneyNumber(reward.value, false);
                } else if (reward.type === RewardType.GoldenCard) {
                    UserDataMgr.Instance.addGoldenCardNumber(reward.value, false);
                }
                // 是否要显示黄金转盘
                if (type === LuckWheelType.Money) {
                    if (LuckWheelMgr.Instance.isShowGoldWheel()) {
                        this.updateGoldenLuckWheel();
                    } else {
                        this.onClose();
                    }
                } else {
                    this.onClose();
                }
            });
        }
    }

    private onClose() {
        if (this.isSpinning) {
            return;
        }
        EventCenter.dispatchEvent(EventName.UpdateLuckWheelProgress);
        UIManager.Instance.close(PrefabDefine.PopLuckWheel);
    }

    private onCloseGolden() {
        Log.Debug("PopLuckWheel onCloseGolden -----------------------");
        LuckWheelMgr.Instance.addGoldenWheelCloseCount();
        if (LuckWheelMgr.Instance.isShowGoldenWheelAd()) {
            LuckWheelMgr.Instance.resetGoldenWheelCloseCount();
            // this.onGoldenSpin();
            AdMgr.Instance.showAd(ModuleType.GoldenWheelClose, AdType.LuckWheelClaim);
        }
        EventCenter.dispatchEvent(EventName.UpdateLuckWheelProgress);
        UIManager.Instance.close(PrefabDefine.PopLuckWheel);
    }

    onDestroy() {
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.LUCK_WHEEL_SPIN);
        EventCenter.off(EventName.onAdComplete, this.onAdComplete, this);
        EventCenter.off(EventName.GuideLuckWheelClick, this.onNormalSpin, this);
    }
}
