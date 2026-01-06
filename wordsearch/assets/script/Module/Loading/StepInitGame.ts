import { Tools } from '../../Common/Tools';
import { Log } from '../../FrameWork/Log';
import { PrefabDefine } from '../../FrameWork/PrefabDefine';
import { UIManager } from '../../FrameWork/UIManager';
import { GuideMgr } from '../Guide/GuideMgr';
import { LoadingStep } from './LoadingStep';

const { ccclass, property } = cc._decorator;

@ccclass
export class StepInitGame extends LoadingStep {
    onStart() {
        Log.Debug("StepInitGame onStart");

        let self = this;
        Log.Debug("StepInitGame onStart time = " + (new Date().getTime() - Tools.startTime));
        UIManager.Instance.showHUD(PrefabDefine.HomeUI, () => {
            GuideMgr.Instance.init();
            Log.Debug("StepInitGame onStart time2 = " + (new Date().getTime() - Tools.startTime));
            self.onEnd();
        });  // 加载首页
    }

    onFrame(deltaTime: number) {

    }

    onEnd() {
        this.IsOver = true;
        Log.Debug("StepInitGame onEnd");
    }
}

