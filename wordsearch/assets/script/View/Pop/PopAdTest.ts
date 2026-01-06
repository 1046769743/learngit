// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import AdMgr, { AdType, ModuleType } from "../../Module/AdModel/AdMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import { ReceiveEventManager } from "../../Platform/Android/ReceiveEventManager";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopAdTest extends cc.Component {

    @property(cc.Label)
    label: cc.Label = null;

    @property(cc.Button)
    buttonSuccess: cc.Button = null;

    @property(cc.Button)
    buttonFail: cc.Button = null;

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {}

    public CurrentAdtype = AdType.None;

    start() {
        this.buttonSuccess.node.on("click", this.onButtonSuccess, this);
        this.buttonFail.node.on("click", this.onButtonFail, this);

        let moduleType = AdMgr.Instance.getCurrentAdModule();
        let str = "";
        if (AdMgr.Instance.VideoAdTypeList.includes(AdMgr.Instance.getCurrentAdType())) {
            str += "激励视频";
        } else if (AdMgr.Instance.InterstitialAdTypeList.includes(AdMgr.Instance.getCurrentInterstitialAdType())) {
            str += "插屏广告";
            moduleType = AdMgr.Instance.getCurrentInterstitialAdModule();
        }
        this.label.string = str + " " + ModuleType[moduleType] || "None";
    }

    onButtonSuccess() {
        let adType = AdMgr.Instance.getCurrentAdType();
        if (adType == AdType.None) {
            adType = AdMgr.Instance.getCurrentInterstitialAdType();
        }
        let data = {
            showAdRes: 1,
            adType: adType
        };
        ReceiveEventManager.showVideoCallBack(JSON.stringify(data));
        UIManager.Instance.close(PrefabDefine.PopAdTest);
    }

    onButtonFail() {
        let adType = AdMgr.Instance.getCurrentAdType();
        if (adType == AdType.None) {
            adType = AdMgr.Instance.getCurrentInterstitialAdType();
        }
        let data = {
            showAdRes: 0,
            adType: adType
        };
        ReceiveEventManager.showVideoCallBack(JSON.stringify(data));
        UIManager.Instance.close(PrefabDefine.PopAdTest);
    }

    // update (dt) {}
}
