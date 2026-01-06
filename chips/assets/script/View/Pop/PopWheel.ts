// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { ObjectPoolManager } from "../../Common/ObjectPoolManager";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import { GameMgr } from "../../Module/Game/GameMgr";
import RewardMgr, { WheelRewardType } from "../../Module/Reward/RewardMgr";
import WheelMgr from "../../Module/Wheel/WheelMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import ItemSlotSprite from "../Item/ItemSlotSprite";
import BasePop from "./BasePop";
import PopReward from "./PopReward";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopWheel extends BasePop {

    @property(cc.Node)
    nodeItemsContent1: cc.Node = null;

    @property(cc.Node)
    nodeItemsContent2: cc.Node = null;

    @property(cc.Node)
    nodeItemsContent3: cc.Node = null;

    @property(cc.Prefab)
    prefabItem: cc.Prefab = null;

    start() {
        this.init();
    }

    private init() {
        // 打点
        let esData = {
            level: GameMgr.Instance.GetCurProgress(),
        }
        NativeApi.instance.buryPoint("Slotsbeigin", JSON.stringify(esData));

        // let rewardInfo = RewardMgr.Instance.getWheelRewardTypeAndValue();
        let rewardInfo = { type: WheelRewardType.Dollar, value: 0 };
        Log.Debug('PopWheel rewardInfo = ' + rewardInfo.type + ' ' + rewardInfo.value);

        // 初始位置
        let initPos = cc.v3(0, 102, 0);
        //道具的目标位置
        let bulbPos = cc.v3(0, 3365, 0);
        //dollar 的位置
        let dollarPos = cc.v3(0, 3540, 0);
        //777的位置
        let seven77Pos = cc.v3(0, 3725, 0);

        for (let i = 0; i < 3; i++) {
            let nodeItemsContent = this['nodeItemsContent' + (i + 1)];
            for (let j = 0; j < 50; j++) {
                let item = ObjectPoolManager.instance.getNode(this.prefabItem);
                let wheelRewardType = (j % 3 + 1) as WheelRewardType;
                item.getComponent(ItemSlotSprite).setSprite(wheelRewardType);
                nodeItemsContent.addChild(item);
            }
        }

        let targetPos = bulbPos;
        switch (rewardInfo.type) {
            case WheelRewardType.Dollar:
                targetPos = dollarPos;
                break;
            case WheelRewardType.Bulb:
                targetPos = bulbPos;
                break;
            case WheelRewardType.Seven77:
                targetPos = seven77Pos;
                break;
        }

        this.nodeItemsContent1.setPosition(initPos);
        cc.tween(this.nodeItemsContent1)
            .to(3, { position: targetPos }, { easing: 'sineInOut' })
            .start();

        this.nodeItemsContent2.setPosition(initPos);
        cc.tween(this.nodeItemsContent2)
            .delay(0.2)
            .to(3, { position: targetPos }, { easing: 'sineInOut' })
            .start();

        this.nodeItemsContent3.setPosition(initPos);
        cc.tween(this.nodeItemsContent3)
            .delay(0.4)
            .to(3.01, { position: targetPos }, { easing: 'sineInOut' })
            .call(() => {
                this.onClose();
                // 是否可以播放777动画
                if (rewardInfo.type == WheelRewardType.Seven77) {
                    // 播放777动画
                    UIManager.Instance.open(PrefabDefine.PopJackpoy);
                } else {
                    // UIManager.Instance.open(PrefabDefine.PopReward, (popup) => {
                    //     let wheelConfig = WheelMgr.Instance.getCurrentWheelConfig();
                    //     let popReward = popup.getComponent(PopReward) as PopReward;
                    //     let adRewardAmount = wheelConfig.ADRewardAmount;
                    //     if (adRewardAmount <= 0) {
                    //         adRewardAmount = 2
                    //     }
                    //     popReward.updateUI(rewardInfo.isOneReward, rewardInfo.type, rewardInfo.value, rewardInfo.value * adRewardAmount, adRewardAmount);
                    // });
                }
            })
            .start();

        SoundManager.Instance.PlaySound(SOUND_NAME.WheelSpin);
    }

    private onClose() {
        WheelMgr.Instance.nextWheel();
        UIManager.Instance.close(PrefabDefine.PopWheel);
    }

}
