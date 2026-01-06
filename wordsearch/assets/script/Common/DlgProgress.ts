// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

const { ccclass, property } = cc._decorator;

@ccclass
export default class DlgProgress extends cc.Component {
    @property(cc.Label)
    progress: cc.Label = null;

    @property(cc.Sprite)
    progressBar: cc.Sprite = null;

    public updateUI(progress: number, total: number) {
        this.progress.string = `${progress}/${total}`;
        this.progressBar.fillRange = progress / total;
    }
}
