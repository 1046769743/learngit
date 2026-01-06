const { ccclass, property } = cc._decorator;

@ccclass
export class AudioManager extends cc.Component {

    private static _instance: AudioManager;
    static get Instance() {
        if (this._instance) {
            return this._instance;
        }

        return this._instance;
    }
    static set Instance(value: AudioManager) {
        this._instance = value;
    }
    musicSource: cc.AudioSource;
    effectSource: cc.AudioSource[] = [];
    mGuideSource: cc.AudioSource;
    private musicVolume: number = 1;
    public get MusicVolume(): number {
        return this.musicVolume;
    }
    public set MusicVolume(value: number) {
        this.musicVolume = value;
        this.musicSource.volume = this.musicVolume;
        if (this.musicVolume <= 0) {
            this.StopAllMusic();
        }
    }

    private effectVolume: number = 1;
    public get EffectVolume(): number {
        return this.effectVolume;
    }
    public set EffectVolume(value: number) {
        this.effectVolume = value;
        for (let item of this.effectSource) {
            item.volume = this.effectVolume;
        }
    }

    start() {
        AudioManager.Instance = this;
        this.musicSource = this.node.addComponent(cc.AudioSource) as cc.AudioSource;
        this.mGuideSource = this.node.addComponent(cc.AudioSource) as cc.AudioSource;
    }

    public PlayMusic(clip: cc.AudioClip) {
        if (clip == null) return;
        if (this.musicSource.clip != null && this.musicSource.clip.name === clip.name) {
            if (!this.musicSource.isPlaying) {
                this.musicSource.play();
                return;
            }
        }
        this.musicSource.volume = this.musicVolume;
        this.musicSource.clip = clip;
        this.musicSource.loop = true;
        this.musicSource.play();
    }

    public StopEffect(name: string) {
        for (let item of this.effectSource) {
            if (item.isPlaying && item.clip.name == name) {
                item.stop();
            }
        }
    }

    public PlayEffect(clip: cc.AudioClip) {
        if (clip == null) return;
        let count = 0;
        let source: cc.AudioSource = null;
        for (let item of this.effectSource) {
            if (item.isPlaying) {
                if (item.clip.name == clip.name) {
                    count += 1;
                    if (count >= 3) {
                        return;
                    }
                }
            }
            else {
                source = item;
            }
        }

        if (source != null) this.PlayEffectWithSorce(clip, source);
        else {
            if (this.effectSource.length < 15) {
                let audio = this.node.addComponent(cc.AudioSource) as cc.AudioSource;
                this.PlayEffectWithSorce(clip, audio);
                this.effectSource.push(audio);
            }
        }
    }

    PlayEffectWithSorce(clip: cc.AudioClip, source: cc.AudioSource) {
        source.volume = this.effectVolume;
        source.clip = clip;
        source.loop = false;
        source.play();
    }

    StopAllMusic() {
        if (this.musicSource.isPlaying) {
            this.musicSource.stop();
        }
    }

    PlayGuideSound(clip: cc.AudioClip) {
        if (clip == null) return;
        this.mGuideSource.stop();
        if (this.mGuideSource.clip != null && this.mGuideSource.clip.name === clip.name) {
            if (!this.mGuideSource.isPlaying) {
                this.mGuideSource.play();
                return;
            }
        }
        this.mGuideSource.volume = this.musicVolume;
        this.mGuideSource.clip = clip;
        this.mGuideSource.loop = false;
        this.mGuideSource.play();
    }

    StopGuideSound() {
        if (this.mGuideSource.isPlaying) {
            this.mGuideSource.stop();
        }
    }
}
