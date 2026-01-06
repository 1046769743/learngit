import { AudioManager } from './AudioManager';
import { StorageManager } from '../../FrameWork/storage/StorageManager';
import { Log } from '../../FrameWork/Log';
// import { NativeApi } from '../../Platform/Android/NativeApi';
const { ccclass, property } = cc._decorator;

@ccclass('SoundManager')
export class SoundManager {
    private static _instance: SoundManager;

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }

        this._instance = new SoundManager();
        return this._instance;
    }


    mClips = new Map<string, cc.AudioClip>();


    IsMusicOn: boolean = true;
    IsSoundOn: boolean = true;
    IsVibrateOn: boolean = true;
    IsGUideOn: boolean = true;

    public InitSound() {
        this.IsMusicOn = StorageManager.Instance.get("musicOn", "true") === "true";
        this.IsSoundOn = StorageManager.Instance.get("soundOn", "true") === "true";
        this.IsVibrateOn = StorageManager.Instance.get("isVibrateOn", "true") === "true";

        StorageManager.Instance.set("soundOn", this.IsSoundOn);
        Log.Debug("SoundManager InitSound" + this.IsMusicOn + " " + this.IsSoundOn + " " + this.IsVibrateOn + " " + this.IsGUideOn);
    }

    public SetSoundOn(isOn: boolean) {
        this.IsSoundOn = isOn;
        // 存本地
        StorageManager.Instance.set("soundOn", isOn ? "true" : "false");


    }

    public SetMusicOn(isOn: boolean) {
        this.IsMusicOn = isOn;
        // 存本地
        StorageManager.Instance.set("musicOn", isOn ? "true" : "false");

        if (isOn) {
            this.PlayMusic(SOUND_NAME.BgMusic);
        } else {
            this.StopMusic();
        }
    }

    public async PlayMusic(name: string) {
        if (!this.IsMusicOn) {
            return;
        }

        let clip = await this.GetClip(name);
        if (clip != null) {
            AudioManager.Instance.PlayMusic(clip);
        }
    }

    public StopMusic() {
        // 停止背景音乐
        AudioManager.Instance.StopAllMusic();
    }

    public async PlaySound(name: string) {
        return;
        if (!this.IsSoundOn) return;
        let clip = await this.GetClip(name);
        if (clip != null) {
            AudioManager.Instance.PlayEffect(clip);
        }
    }

    public async StopSound(name: string) {
        AudioManager.Instance.StopEffect(name);
    }

    public async StopGuide() {
        AudioManager.Instance.StopGuideSound();
    }

    public async PlayGuide(name: string) {
        if (!this.IsGUideOn) {
            return;
        }
        let clip = await this.GetClip(name);
        if (clip != null) {
            AudioManager.Instance.PlayGuideSound(clip);
        }


    }
    public PlayVibrate() {
        if (!this.IsVibrateOn) return;
        // NativeApi.instance.onVibrate();
    }

    public GetSoundNameByCount(count: number) {
        switch (count) {
            case 1:
                return SOUND_NAME.Slide1;
            case 2:
                return SOUND_NAME.Slide2;
            case 3:
                return SOUND_NAME.Slide3;
            case 4:
                return SOUND_NAME.Slide4;
            case 5:
                return SOUND_NAME.Slide5;
            case 6:
                return SOUND_NAME.Slide6;
        }

        return null;
    }

    GetClip(path: string): Promise<cc.AudioClip> {
        return new Promise((resolve, reject) => {
            // 如果字典中已经存在该AudioClip，直接返回
            if (this.mClips.get(path) != null) {
                resolve(this.mClips.get(path));
            } else {
                // 否则加载AudioClip并存入字典
                cc.resources.load(path, cc.AudioClip, (err, clip) => {
                    if (err) {
                        reject(err);
                    } else {
                        this.mClips.set(path, clip);
                        resolve(clip);
                    }
                });
            }
        });
    }
}

export class SOUND_NAME {
    static readonly BgMusic = "Audio/bgm";
    static readonly BtnClick = "Audio/button";
    static readonly BulbHit = "Audio/bulb_hit";
    static readonly BulbRotate = "Audio/bulb_rotate";
    static readonly CollectMoney = "Audio/collect_money";
    static readonly WordError = "Audio/word_error";
    static readonly WordRight = "Audio/word_right";

    static readonly WheelSpin = "Audio/wheel_spin";
    static readonly LevelComplete = "Audio/level_complete";

    static readonly Slide1 = "Audio/slide_1";
    static readonly Slide2 = "Audio/slide_2";
    static readonly Slide3 = "Audio/slide_3";
    static readonly Slide4 = "Audio/slide_4";
    static readonly Slide5 = "Audio/slide_5";
    static readonly Slide6 = "Audio/slide_6";

    static readonly Good = "Audio/good";
    static readonly Great = "Audio/great";
    static readonly Amazing = "Audio/amazing";
    static readonly Excellent = "Audio/excellent";
    static readonly Perfect = "Audio/unbelievable";


    static readonly Slot_Unlock = "Audio/sound_slot_unlock";
    static readonly Deal_Chips = "Audio/sound_deal_chips";
    static readonly Chips_Merge = "Audio/sound_merge";
    static readonly Combo = "Audio/sound_combo";
    static readonly Game_Over = "Audio/sound_game_over";
    static readonly Chips_Move = "Audio/sound_move_chips";
    static readonly Chips_Move_2 = "Audio/sound_move_chips_2";
    static readonly Chips_Move_4 = "Audio/sound_move_chips_4";
    static readonly Chips_Move_6 = "Audio/sound_move_chips_6";
    static readonly Chips_Move_8 = "Audio/sound_move_chips_8";
    static readonly Chips_Move_Fail = "Audio/sound_move_fail";
    static readonly Chips_Shuffe = "Audio/sound_shuffe";
    static readonly Slot_Select = "Audio/sound_slot_select";
    static readonly Redpacket_Earning = "Audio/sound_earning_red_packet";
    static readonly Redpacket_Earning2 = "Audio/sound_earning_red_packet2";

    static readonly Guide1 = "Audio/guide1";
    static readonly Guide2 = "Audio/guide2";
    static readonly Guide3 = "Audio/guide3";
    static readonly Guide4 = "Audio/guide4";
    static readonly Guide5 = "Audio/guide5";
    static readonly Guide11 = "Audio/guide11";

    static readonly Bar_Move = "Audio/sound_bar_move";
    static readonly Chip_Remove = "Audio/sound_chip_remove";
}