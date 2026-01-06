// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import RewardMgr from "../../Module/Reward/RewardMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconH5 extends cc.Component {

    @property(cc.Button)
    btn: cc.Button = null;

    @property
    isTempShow: boolean = false;

    start() {
        this.node.active = false;
        this.btn.node.on("click", this.onBtnClick, this);
        EventCenter.on(EventName.ShowH5ViewIcon, this.onShowH5ViewIcon, this);
    }

    onBtnClick() {
        NativeApi.instance.showH5View();
        if (this.isTempShow) {
            this.node.active = false;
            setTimeout(() => {
                this.node.active = true;
            }, 180000);
        }
    }

    onShowH5ViewIcon(isAttributionUser: boolean) {
        let reward = RewardMgr.Instance.getH5RewardConfig();
        NativeApi.instance.updateH5Cfg(reward);
        this.node.active = true;
    }
}
