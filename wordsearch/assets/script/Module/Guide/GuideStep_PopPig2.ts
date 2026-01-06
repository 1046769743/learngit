// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { NativeApi } from "../../Platform/Android/NativeApi";
import { GameMgr } from "../Game/GameMgr";
import Language from "../Language/Language";
import { GuideMgr } from "./GuideMgr";
import { GuideStep } from "./GuideStep";

const { ccclass, property } = cc._decorator;

@ccclass
export default class GuideStep_PopPig2 extends GuideStep {

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

        GuideMgr.Instance.guideUI.show();

        let tips = Language.instance.getDes("66");
        let guideNodeKey = TargetNodeKeys.POP_PIG_2;
        let guideNode = UIManager.Instance.getTargetNode(guideNodeKey);
        GuideMgr.Instance.guideUI.showTarget(guideNode, null, false);

        setTimeout(() => {
            const targetWorldPos = guideNode.convertToWorldSpaceAR(cc.v2(0, 0));
            const targetLocalPos = GuideMgr.Instance.guideUI.node.convertToNodeSpaceAR(targetWorldPos);
            let offX = targetLocalPos.x;
            let offY = targetLocalPos.y + 300;
            GuideMgr.Instance.guideUI.showTips(tips, 500, 180, offY, offX);
        }, 200);
        this._isCanClick = true;
    }

    onClickMask(e: any): void {
        if (!this._isCanClick) return;
        if (this._isClick) return;

        this._isClick = true;
        NativeApi.instance.buryPoint("Guide08");
        this.onEnd();
    }

    onClick(e: any): void {
        if (!this._isCanClick) return;
        if (this._isClick) return;

        this._isClick = true;
        NativeApi.instance.buryPoint("Guide08");
        this.onEnd();
    }
}
