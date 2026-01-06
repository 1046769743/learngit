// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { Log } from "../../FrameWork/Log";
import { NativeApi } from "../../Platform/Android/NativeApi";
import { GameMgr } from "../Game/GameMgr";
import Language from "../Language/Language";
import { GuideMgr } from "./GuideMgr";
import { GuideStep } from "./GuideStep";

const { ccclass, property } = cc._decorator;

@ccclass
export default class GuideStep_4 extends GuideStep {

    private _isClick: boolean = false;
    private _isCanClick: boolean = false;

    onEnter() {
        super.onEnter();

        GuideMgr.Instance.guideUI.show();

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

        GuideMgr.Instance.guideUI.hide();
        GuideMgr.Instance.guideUI.show();
        GuideMgr.Instance.guideUI.showCloseTipsLabel();

        let tips = Language.instance.getDes("91");
        GuideMgr.Instance.guideUI.showTips(tips, 500, 160, 0, 0);
        let gameUI = GameMgr.Instance.getGameUI();
        let guideNode = gameUI.nodeGuide;
        guideNode.width = 0;
        guideNode.height = 0;
        GuideMgr.Instance.guideUI.showTarget(guideNode, null, false);
        this._isCanClick = true;
    }

    onClickMask(e: any): void {
        if (!this._isCanClick) return;
        if (this._isClick) return;
        // if (GameMgr.Instance.GameUI.curPlayingAnim) return;

        this._isClick = true;

        // GameMgr.Instance.GameUI.onClickSlot(0);
        NativeApi.instance.buryPoint("Guide04");

        this.onEnd();
    }
}
