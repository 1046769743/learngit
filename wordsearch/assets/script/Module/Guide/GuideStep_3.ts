// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { GameMgr } from "../Game/GameMgr";
import Language from "../Language/Language";
import { GuideMgr } from "./GuideMgr";
import { GuideStep } from "./GuideStep";

const { ccclass, property } = cc._decorator;

@ccclass
export default class GuideStep_3 extends GuideStep {

    private _isClick: boolean = false;
    private _isCanClick: boolean = false;

    constructor() {
        super();
        EventCenter.on(EventName.GuideStep1Finished, this.onGuideStep1Finished, this);
    }

    onGuideStep1Finished() {
        this.onEnd();
    }

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

        GuideMgr.Instance.guideUI.show();

        let tips = Language.instance.getDes("90");
        GuideMgr.Instance.guideUI.showTips(tips, 500, 160, -230, -80);
        let gameUI = GameMgr.Instance.getGameUI();
        gameUI.setGuide1GuideNodeSizeAndPosition("CAT");
        GuideMgr.Instance.guideUI.showSwipeTarget(gameUI.nodeGuide, cc.v2(-1, 0), 400, null, true, () => {
            Log.Debug('GuideStep_1 onGuideSwipeComplete');
        });
        // GuideMgr.Instance.guideUI.showTarget(GameMgr.Instance.GameUI.guideTargetSlot0, GameMgr.Instance.GameUI.guideTargetSlot0);

        this._isCanClick = true;
    }

    onClick(e: any): void {
        if (!this._isCanClick) return;
        if (this._isClick) return;
        // if (GameMgr.Instance.GameUI.curPlayingAnim) return;

        this._isClick = true;

        // GameMgr.Instance.GameUI.onClickSlot(0);

        this.onEnd();
    }


}
