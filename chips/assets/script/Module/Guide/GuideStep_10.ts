// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { Log } from "../../FrameWork/Log";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { NativeApi } from "../../Platform/Android/NativeApi";
import { SOUND_NAME, SoundManager } from "../Audio/SoundManager";
import CurrencyManager from "../Currency/CurrencyManager";
import { GameMgr } from "../Game/GameMgr";
import Language from "../Language/Language";
import UserDataMgr from "../UserData/UserDataMgr";
import WithdrawMgr from "../Withdraw/WithdrawMgr";
import { GuideMgr } from "./GuideMgr";
import { GuideStep } from "./GuideStep";

const { ccclass, property } = cc._decorator;

@ccclass
export default class GuideStep_10 extends GuideStep {

    private _isClick: boolean = false;
    private _isCanClick: boolean = false;

    onEnter() {
        super.onEnter();

        this.isCheckCanStart = true;
    }

    CheckCanStart(): boolean {
        Log.Debug(`${GuideMgr.TAG} GuideStep_0_1 CheckCanStart GameMgr.Instance.GameUI != null ${GameMgr.Instance.getGameUI() != null}`);
        return GameMgr.Instance.getGameUI() != null;
    }

    onStart() {
        super.onStart();

        // 上报事件
        // NativeApi.instance.uploadGuideEvent(1);

        GuideMgr.Instance.guideUI.show();

        let tips = Language.instance.getDes("47");
        let targetNode = UIManager.Instance.getTargetNode(TargetNodeKeys.GUIDE_WITHDRAW);
        GuideMgr.Instance.guideUI.showTarget(targetNode);

        setTimeout(() => {
            const targetWorldPos = targetNode.convertToWorldSpaceAR(cc.v2(0, 0));
            const targetLocalPos = GuideMgr.Instance.guideUI.node.convertToNodeSpaceAR(targetWorldPos);
            let offX = targetLocalPos.x - 20;
            let offY = targetLocalPos.y - 150;
            GuideMgr.Instance.guideUI.showTips(tips, 500, 180, offY, offX);
        }, 200);



        this._isCanClick = true;
    }

    onClick(e: any): void {
        if (!this._isCanClick) return;
        if (this._isClick) return;
        // if (GameMgr.Instance.GameUI.curPlayingAnim) return;

        this._isClick = true;

        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        WithdrawMgr.Instance.openWithdraw(1);

        NativeApi.instance.buryPoint("Guide06");
        // // 打点
        // let esData = {
        //     Amonut: UserDataMgr.Instance.moneyNumber
        // }
        // NativeApi.instance.buryPoint("WithdrawClick", JSON.stringify(esData));

        this.onEnd();
    }
}
