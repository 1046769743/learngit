// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import { GameMgr } from "../../Module/Game/GameMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopSetting extends BasePop {

    @property(cc.Button)
    btnClose: cc.Button = null;

    @property(cc.Label)
    labelTitle: cc.Label = null;

    @property(cc.Label)
    labelUserId: cc.Label = null;

    @property(cc.Button)
    btnSound: cc.Button = null;

    @property(cc.Label)
    btnSoundLabel: cc.Label = null;

    @property(cc.Node)
    soundOnNode: cc.Node = null;

    @property(cc.Node)
    soundOffNode: cc.Node = null;

    @property(cc.Button)
    btnMusic: cc.Button = null;

    @property(cc.Label)
    btnMusicLabel: cc.Label = null;

    @property(cc.Node)
    musicOnNode: cc.Node = null;

    @property(cc.Node)
    musicOffNode: cc.Node = null;

    @property(cc.Button)
    btnUseTheme: cc.Button = null;

    @property(cc.Button)
    btnPrivacyPolicy: cc.Button = null;

    @property(cc.Button)
    btnDebug: cc.Button = null;

    start() {
        this.btnClose.node.on('click', this.onClose, this);
        this.btnSound.node.on('click', this.onSound, this);
        this.btnMusic.node.on('click', this.onMusic, this);
        this.btnUseTheme.node.on('click', this.onUseTheme, this);
        this.btnPrivacyPolicy.node.on('click', this.onPrivacyPolicy, this);
        this.btnDebug.node.on('click', this.onDebug, this);

        this.soundOnNode.active = SoundManager.Instance.IsSoundOn;
        this.soundOffNode.active = !SoundManager.Instance.IsSoundOn;
        this.musicOnNode.active = SoundManager.Instance.IsMusicOn;
        this.musicOffNode.active = !SoundManager.Instance.IsMusicOn;

        this.labelUserId.string = UserDataMgr.Instance.userId;
    }

    onClose() {
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        UIManager.Instance.close(PrefabDefine.PopSetting);
    }

    onSound() {
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        SoundManager.Instance.SetSoundOn(!SoundManager.Instance.IsSoundOn);
        this.soundOnNode.active = SoundManager.Instance.IsSoundOn;
        this.soundOffNode.active = !SoundManager.Instance.IsSoundOn;
    }

    onMusic() {
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        SoundManager.Instance.SetMusicOn(!SoundManager.Instance.IsMusicOn);
        this.musicOnNode.active = SoundManager.Instance.IsMusicOn;
        this.musicOffNode.active = !SoundManager.Instance.IsMusicOn;
    }

    onUseTheme() {
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        NativeApi.instance.termsOfUse();
    }

    onPrivacyPolicy() {
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        NativeApi.instance.privacyPolicy();
    }

    private _debugClickCount: number = 0;
    onDebug() {
        this._debugClickCount++;
        if (this._debugClickCount < 3) {
            return;
        }
        this._debugClickCount = 0;
        if (NativeApi.instance.getDebugBuild()) {
            UIManager.Instance.open(PrefabDefine.PopDebug);
            UIManager.Instance.close(PrefabDefine.PopSetting);
        }
    }
}
