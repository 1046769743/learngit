const { ccclass, property } = cc._decorator;

@ccclass
export class LoadingStep {
    IsOver: boolean = false; // 是否结束的标记

    onStart() {

    }

    onFrame(deltaTime: number) {

    }

    onEnd() {
        this.IsOver = true;
    }
}