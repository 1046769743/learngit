// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemWord extends cc.Component {

    @property(cc.Label)
    label: cc.Label = null;

    @property(cc.Node)
    checkMark: cc.Node = null; // 打勾图标

    // 完成的颜色
    private readonly COMPLETED_COLOR = cc.color(169, 169, 169);
    // 未完成的颜色
    private readonly UNCOMPLETED_COLOR = cc.color(44, 44, 44);

    private _isFound: boolean = false;

    public updateWord(text: string) {
        this.label.node.color = this.UNCOMPLETED_COLOR;
        this.label.string = text;
    }

    public setFound(found: boolean) {
        this._isFound = found;

        if (found) {
            // 找到单词时的效果
            this.label.node.color = this.COMPLETED_COLOR;
            if (this.checkMark) {
                this.checkMark.active = true;
            }

            // 可以添加找到动画
            this.playFoundAnimation();
        } else {
            // 重置状态
            this.label.node.color = this.UNCOMPLETED_COLOR;
            if (this.checkMark) {
                this.checkMark.active = false;
            }
        }
    }

    public isFound(): boolean {
        return this._isFound;
    }

    private playFoundAnimation() {
        // 找到单词的动画效果
        this.node.scale = 1.0;
        cc.tween(this.node)
            .to(0.15, { scale: 1.3 })
            .to(0.15, { scale: 1.0 })
            .start();
    }

    public reset() {
        this._isFound = false;
        this.label.node.color = this.UNCOMPLETED_COLOR;
        if (this.checkMark) {
            this.checkMark.active = false;
        }
        this.node.scale = 1.0;
    }
}
