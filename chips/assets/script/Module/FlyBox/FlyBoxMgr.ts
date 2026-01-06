// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

const { ccclass, property } = cc._decorator;

@ccclass
export default class FlyBoxMgr {

    private static _instance: FlyBoxMgr = null;

    public static get Instance(): FlyBoxMgr {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new FlyBoxMgr();
        return this._instance;
    }

    // 连续两次点击关闭按键，则第二次关闭后，必定起广告
    // 拒绝次数
    private _rejectCount: number = 0;

    public init() {
        this._rejectCount = 0;
    }

    public addRejectCount() {
        this._rejectCount++;
    }

    // 是否是强制rv
    public isForceRv() {
        return this._rejectCount >= 2;
    }

    public resetRejectCount() {
        this._rejectCount = 0;
    }
}
