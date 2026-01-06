// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import DailyLoginMgr from "../../Module/DailyLogin/DailyLoginMgr";
import { GameMgr } from "../../Module/Game/GameMgr";
import { GuideMgr, GuideType } from "../../Module/Guide/GuideMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconDailyLogin extends cc.Component {
    @property(DlgBtn)
    btn: DlgBtn = null;

    start() {
        EventCenter.on(EventName.LevelFinish, this.onLevelFinish, this);
        EventCenter.on(EventName.DailyLoginRedDotRefresh, this.refreshRedDot, this);

        this.btn.addClickCallback(this.onBtnClick, this);

        this.node.active = DailyLoginMgr.Instance.isFunctionOpen();
        this.refreshRedDot();
    }

    private onLevelFinish() {
        if (this.node.active) {
            return;
        }
        this.node.active = DailyLoginMgr.Instance.isFunctionOpen();
        this.refreshRedDot();
    }

    // 刷新红点
    public refreshRedDot() {
        let redDot = this.node.getChildByName("red");
        if (redDot) {
            redDot.scale = 0.8;
            redDot.active = DailyLoginMgr.Instance.hasUnclaimedReward();
        }
    }

    onBtnClick() {
        Log.Debug("IconPig onBtnClick");
        UIManager.Instance.open(PrefabDefine.PopDailyLogin);
    }
}
