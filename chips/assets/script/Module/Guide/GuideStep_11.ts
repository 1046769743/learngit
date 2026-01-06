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
export default class GuideStep_11 extends GuideStep {

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

        let tips = Language.instance.getDes("48");
        GuideMgr.Instance.guideUI.showTips(tips, 400, 150, -430, 100);
        let gameUI = GameMgr.Instance.getGameUI();
        let guideNode = gameUI.nodeGuideHit;
        GuideMgr.Instance.guideUI.showTarget(guideNode);
        // GuideMgr.Instance.guideUI.setFingerOffsetPos(0, -50);
        this._isCanClick = true;
    }

    onClick(e: any): void {
        if (!this._isCanClick) return;
        if (this._isClick) return;
        // if (GameMgr.Instance.GameUI.curPlayingAnim) return;

        this._isClick = true;

        let gameUI = GameMgr.Instance.getGameUI();
        gameUI.onBtnHitWordClick();

        NativeApi.instance.buryPoint("Guide05");

        this.onEnd();
    }
}
