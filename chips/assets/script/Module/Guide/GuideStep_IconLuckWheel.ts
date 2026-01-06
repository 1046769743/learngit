// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { NativeApi } from "../../Platform/Android/NativeApi";
import { GameMgr } from "../Game/GameMgr";
import Language from "../Language/Language";
import { GuideMgr } from "./GuideMgr";
import { GuideStep } from "./GuideStep";

const { ccclass, property } = cc._decorator;

@ccclass
export default class GuideStep_IconLuckWheel extends GuideStep {

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
        let guideNodeKey = TargetNodeKeys.LUCK_WHEEL_ICON;
        let guideNode = UIManager.Instance.getTargetNode(guideNodeKey);
        GuideMgr.Instance.guideUI.showTarget(guideNode);

        setTimeout(() => {
            const targetWorldPos = guideNode.convertToWorldSpaceAR(cc.v2(0, 0));
            const targetLocalPos = GuideMgr.Instance.guideUI.node.convertToNodeSpaceAR(targetWorldPos);
            let offX = targetLocalPos.x;
            let offY = targetLocalPos.y - 180;
            let tips = Language.instance.getDes("64");
            GuideMgr.Instance.guideUI.showTips(tips, 500, 180, offY, offX);
        }, 200);

        this._isCanClick = true;
    }

    onClick(e: any): void {
        if (!this._isCanClick) return;
        if (this._isClick) return;
        // if (GameMgr.Instance.GameUI.curPlayingAnim) return;

        this._isClick = true;

        UIManager.Instance.open(PrefabDefine.PopLuckWheel);
        NativeApi.instance.buryPoint("Guide10");

        this.onEnd();
    }
}
